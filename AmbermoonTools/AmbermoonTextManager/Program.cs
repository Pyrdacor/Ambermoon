﻿using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using static Ambermoon.Data.Legacy.Compression.LobCompression;

namespace AmbermoonTextImport
{
    class Program
    {
        const string PlaceholderIndexFile = "placeholders.idx";

        enum ErrorCode
        {
            Aborted = -1,
            NoError,
            InvalidNumberOfArguments,
            InvalidArguments,
            UnableToLoadGameData,
            UnableToCreateDirectory,
            UnableToReadTextData,
            UnableToCreateTextFiles,
            DirectoryNotFound,
            WrongFileNumbering,
            UnableToTransformTexts,
            UnableToCreateBackup,
            UnableToWriteData
        }

        enum Option
        {
            Export,
            Import,
            HexSubfileNames,
            NewCompression
        }

        static void Exit(ErrorCode errorCode)
        {
            Environment.Exit((int)errorCode);
        }

        static void Usage()
        {
            Console.WriteLine("USAGE: AmbermoonTextManager -e <inGameDataPath> <outFolderPath> [options]");
            Console.WriteLine("       AmbermoonTextManager -i <outGameDataPath> <inFolderPath> [options]");
            Console.WriteLine("       AmbermoonTextManager --help");
            Console.WriteLine();
            Console.WriteLine("-e: Extract text manager file to text files in target folder.");
            Console.WriteLine("-i: Import text files from source folder into text manager.");
            Console.WriteLine();
            Console.WriteLine("The gameDataPath params are local directories where the game files or ADFs are.");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine("-> AmbermoonTextManager -e \"C:\\Ambermoon\\Amberfiles\" \"C:\\AmbermoonData\\Texts\" -x");
            Console.WriteLine("-> AmbermoonTextManager -i \"C:\\Ambermoon\\Amberfiles\" \"C:\\AmbermoonData\\Texts\" --hex-subfile-names");
            Console.WriteLine();
            Console.WriteLine("Options:");
            Console.WriteLine(" --hex-subfile-names / -x    : Subfile names with hex numbering");
            Console.WriteLine(" --file <name> / -f <name>   : Only consider this file (can be repeated for more)");
            Console.WriteLine("   Use names like Place_data or 2Map_texts.amb here.");
            Console.WriteLine("   If no file is given explicitly, all files are considered.");
            Console.WriteLine(" --use-new-compression / -c  : Uses new compression algorithms (Advanced only).");
            Console.WriteLine();
        }

        static void Main(string[] args)
        {
            if (args.Length < 3)
            {
                Console.WriteLine("Invalid number of arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidNumberOfArguments);
                return;
            }

            if (args.Contains("--help") || args.Contains("-h"))
            {
                Usage();
                Exit(ErrorCode.NoError);
                return;
            }

            var options = ParseOptions(ref args, out var files);

            if (options == null)
                return;

            if (args.Length < 2 || options.Count < 1)
            {
                Console.WriteLine("Invalid arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidArguments);
                return;
            }

            if (options.Contains(Option.Export) && options.Contains(Option.Import))
            {
                Console.WriteLine("Invalid arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidArguments);
                return;
            }

            if (options[0] == Option.Export)
            {
                Export(args[0], args[1], options.Skip(1).ToList(), files);
            }
            else if (options[0] == Option.Import)
            {
                Import(args[0], args[1], options.Skip(1).ToList(), files);
            }
            else
            {
                Console.WriteLine("Invalid arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidArguments);
                return;
            }
        }

        static List<Option> ParseOptions(ref string[] args, out List<string> files)
        {
            var options = new List<Option>();
            var foundFiles = new List<string>();
            files = null;
            var remainingArgs = new List<string>();

            try
            {
                for (int i = 0; i < args.Length; ++i)
                {
                    string arg = args[i];

                    if (arg == "--hex-subfile-names")
                        options.Add(Option.HexSubfileNames);
                    else if (arg == "--file")
                        AddFile(args);
                    else if (arg == "--use-new-compression")
                        options.Add(Option.NewCompression);
                    else if (arg.StartsWith("-"))
                    {
                        if (arg.Length != 2)
                            throw new Exception();

                        if (arg[1] == 'f')
                            AddFile(args);
                        else if (arg[1] == 'e')
                            options.Insert(0, Option.Export);
                        else if (arg[1] == 'i')
                            options.Insert(0, Option.Import);
                        else
                        {
                            for (int n = 1; n < arg.Length; ++n)
                            {
                                if (arg[n] == 'x')
                                    options.Add(Option.HexSubfileNames);
                                else if (arg[n] == 'c')
                                    options.Add(Option.NewCompression);
                                else
                                    throw new Exception();
                            }
                        }
                    }
                    else
                        remainingArgs.Add(arg);

                    void AddFile(string[] args)
                    {
                        if (i == args.Length - 1)
                            throw new Exception();

                        string file = args[++i];

                        if (file.StartsWith('-'))
                            throw new Exception();

                        foundFiles.Add(file.ToLower());
                    }
                }

                files = foundFiles;
                args = remainingArgs.ToArray();

                return options;
            }
            catch
            {
                Console.WriteLine("Invalid arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidArguments);
                return null;
            }
        }

        static readonly string[] TextContainerFiles = new string[]
        {
            "1Map_texts.amb",
            "2Map_texts.amb",
            "3Map_texts.amb",
            "NPC_texts.amb",
            "Object_texts.amb",
            "Party_texts.amb"
        };

        static readonly string[] DictionaryFiles = new string[]
        {
            "Dict.amb",
            "Dictionary.english",
            "Dictionary.german"
        };

        class FileNameComparer : IEqualityComparer<string>
        {
            public bool Equals(string x, string y)
            {
                return string.Compare(x, y, true) == 0;
            }

            public int GetHashCode([DisallowNull] string obj)
            {
                return obj.ToLower().GetHashCode();
            }
        }

        static void Export(string gameDataPath, string outputPath, List<Option> options, List<string> files)
        {
            var gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false);

            try
            {
                gameData.Load(gameDataPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to load game data: " + ex.Message);
                Console.WriteLine();
                Exit(ErrorCode.UnableToLoadGameData);
                return;
            }

            bool CheckFile(string name) => name != null && (files == null || files.Count == 0 || files.Contains(name.ToLower()));
            bool CheckAnyFile(params string[] names) => names != null && names.Any(CheckFile);
            bool CheckAndGetFile(string name, out IFileContainer fileContainer)
            {
                fileContainer = null;
                return CheckFile(name) && gameData.Files.TryGetValue(name, out fileContainer);
            }

            var fileNameComparer = new FileNameComparer();
            var filenameCreator = options.Contains(Option.HexSubfileNames)
                ? (Func<int, string>)(i => i.ToString("X3"))
                : i => i.ToString("000");
            string outPath;

            // TODO: intro, outro, etc

            IFileContainer dictionary = null;

            if (CheckAnyFile(DictionaryFiles))
            {
                foreach (var dictionaryFile in DictionaryFiles)
                {
                    if (gameData.Files.TryGetValue(dictionaryFile, out dictionary))
                        break;
                }
            }

            if (dictionary != null)
            {
                outPath = Path.Combine(outputPath, dictionary.Name);

                try
                {
                    Directory.CreateDirectory(outPath);
                }
                catch
                {
                    Console.WriteLine($"Unable to create output directory '{outPath}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToCreateDirectory);
                    return;
                }

                var reader = dictionary.Files[1];
                reader.Position = 0;
                int numEntries = reader.ReadWord();

                Console.WriteLine($"Writing {numEntries} dictionary entries.");

                for (int i = 0; i < numEntries; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    File.WriteAllText(fileOutPath, reader.ReadString());
                }
            }

            void WriteAllTexts(TextContainer textContainer)
            {
                Console.WriteLine("Writing all texts from Text.amb.");

                WriteTexts("WorldNames", textContainer.WorldNames);
                WriteTexts("FormatMessages", textContainer.FormatMessages);
                WriteTexts("AutomapTypeNames", textContainer.AutomapTypeNames);
                WriteTexts("OptionNames", textContainer.OptionNames);
                WriteTexts("MusicNames", textContainer.MusicNames);
                WriteTexts("SpellClassNames", textContainer.SpellClassNames);
                WriteTexts("SpellNames", textContainer.SpellNames);
                WriteTexts("LanguageNames", textContainer.LanguageNames);
                WriteTexts("ClassNames", textContainer.ClassNames);
                WriteTexts("RaceNames", textContainer.RaceNames);
                WriteTexts("SkillNames", textContainer.SkillNames);
                WriteTexts("AttributeNames", textContainer.AttributeNames);
                WriteTexts("SkillShortNames", textContainer.SkillShortNames);
                WriteTexts("AttributeShortNames", textContainer.AttributeShortNames);
                WriteTexts("ItemTypeNames", textContainer.ItemTypeNames);
                WriteTexts("ConditionNames", textContainer.ConditionNames);
                WriteTexts("UITexts", textContainer.UITexts);
                WriteTexts("DateAndLanguageString", new() { textContainer.DateAndLanguageString });
                WriteTexts("VersionString", new() { textContainer.VersionString });
                WriteTexts("Messages", textContainer.Messages);

                void WriteTexts(string folderName, List<string> texts)
                {
                    string path = Path.Combine(outPath, folderName);

                    try
                    {
                        Directory.CreateDirectory(path);
                    }
                    catch
                    {
                        Console.WriteLine($"Unable to create output directory '{path}'.");
                        Console.WriteLine();
                        Exit(ErrorCode.UnableToCreateDirectory);
                        return;
                    }

                    for (int i = 0; i < texts.Count; ++i)
                    {
                        var fileOutPath = Path.Combine(path, filenameCreator(i) + ".txt");
                        File.WriteAllText(fileOutPath, texts[i], Encoding.UTF8);
                    }

                    if (folderName.ToLower() == nameof(TextContainer.UITexts).ToLower())
                    {
                        var indexWriter = new DataWriter();

                        indexWriter.Write((ushort)textContainer.UITextWithPlaceholderIndices.Count);
                        textContainer.UITextWithPlaceholderIndices.ForEach(i => indexWriter.Write((ushort)i));

                        File.WriteAllBytes(Path.Combine(path, PlaceholderIndexFile), indexWriter.ToArray());
                    }
                }
            }

            if (CheckAndGetFile("Text.amb", out var textAmb))
            {
                outPath = Path.Combine(outputPath, textAmb.Name);
                var reader = textAmb.Files[1];
                reader.Position = 0;
                var textContainerReader = new TextContainerReader();
                var textContainer = new TextContainer();
                textContainerReader.ReadTextContainer(textContainer, reader, false);

                WriteAllTexts(textContainer);
            }
            else if (CheckFile("AM2_CPU") || CheckFile("AM2_BLIT"))
            {
                outPath = Path.Combine(outputPath, "Text.amb");
                var exeData = ExecutableData.FromGameData(gameData);
                var textContainer = new TextContainer();
                textContainer.WorldNames.AddRange(exeData.WorldNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.FormatMessages.AddRange(exeData.Messages.Entries.Take(26));
                textContainer.AutomapTypeNames.AddRange(exeData.AutomapNames.Entries.OrderBy(e => (int)e.Key).Skip(2).Select(e => e.Value));
                textContainer.OptionNames.AddRange(exeData.OptionNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.MusicNames.AddRange(exeData.SongNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.SpellClassNames.AddRange(exeData.SpellTypeNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.SpellNames.AddRange(exeData.SpellNames.Entries.OrderBy(e => (int)e.Key).Skip(1).Select(e => e.Value));
                textContainer.LanguageNames.AddRange(exeData.LanguageNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.ClassNames.AddRange(exeData.ClassNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.RaceNames.AddRange(exeData.RaceNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.SkillNames.AddRange(exeData.SkillNames.Entries.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.AttributeNames.AddRange(exeData.AttributeNames.Entries.OrderBy(e => (int)e.Key).Take(9).Select(e => e.Value));
                textContainer.SkillShortNames.AddRange(exeData.SkillNames.ShortNames.OrderBy(e => (int)e.Key).Select(e => e.Value));
                textContainer.AttributeShortNames.AddRange(exeData.AttributeNames.ShortNames.OrderBy(e => (int)e.Key).Take(8).Select(e => e.Value));
                textContainer.ItemTypeNames.AddRange(exeData.ItemTypeNames.Entries.OrderBy(e => (int)e.Key).Skip(1).Select(e => e.Value));
                textContainer.ConditionNames.AddRange(exeData.ConditionNames.Entries.OrderBy(e => (int)e.Key).Skip(1).Select(e => e.Value));
                textContainer.UITextWithPlaceholderIndices.AddRange(new int[]
                {
                    13, 17, 28, 29, 30, 31, 32, 33, 34, 35, 36, 41
                });
                textContainer.UITexts.AddRange(exeData.UITexts.Entries.OrderBy(e => (int)e.Key).Take(11).Select(e => ProcessUIText(e.Value)));
                textContainer.UITexts.Add(exeData.UITexts.Entries[UITextIndex.BothSexes]);
                textContainer.UITexts.AddRange(exeData.UITexts.Entries.OrderBy(e => (int)e.Key).Skip(11).Where(e => e.Key != UITextIndex.BothSexes && e.Key != UITextIndex.Placeholder2Digit && e.Key !=UITextIndex.Placeholder2DigitInParentheses).Select(e => ProcessUIText(e.Value)));
                textContainer.DateAndLanguageString = exeData.DataInfoString;
                textContainer.VersionString = exeData.DataVersionString;
                textContainer.Messages.AddRange(exeData.Messages.Entries.Skip(26));
                
                // TODO: format messages and messages do not work. I guess we need to prepare formatted messages.

                string ProcessUIText(string text)
                {
                    if (textContainer.UITextWithPlaceholderIndices.Contains(textContainer.UITexts.Count))
                    {
                        var regex = new Regex(@"\{[0-9]:(0+)\}");

                        text = regex.Replace(text, match => string.Join("", Enumerable.Repeat(0, match.Groups[1].Length).Select((_, i) => i.ToString())));
                    }

                    return text;
                }

                WriteAllTexts(textContainer);
            }

            void ExportCharNames(string filename, string fallbackFilename = null)
            {
                if (!gameData.Files.TryGetValue(filename, out var container))
                {
                    if (fallbackFilename == null || !gameData.Files.TryGetValue(fallbackFilename, out container))
                        return;

                    filename = fallbackFilename;
                }

                outPath = Path.Combine(outputPath, filename);

                try
                {
                    Directory.CreateDirectory(outPath);
                }
                catch
                {
                    Console.WriteLine($"Unable to create output directory '{outPath}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToCreateDirectory);
                    return;
                }

                foreach (var file in gameData.Files[filename].Files)
                {
                    if (file.Value.Size == 0)
                        continue;

                    var fileOutPath = Path.Combine(outPath, filenameCreator(file.Key) + ".txt");
                    file.Value.Position = 0x0112;
                    File.WriteAllText(fileOutPath, file.Value.ReadString(16).TrimEnd(' ', '\0'));
                }
            }

            if (CheckFile("Monster_char_data.amb") || CheckFile("Monster_char.amb"))
                ExportCharNames("Monster_char_data.amb", "Monster_char.amb");
            if (CheckFile("Party_char.amb"))
                ExportCharNames("Save.00/Party_char.amb");
            if (CheckFile("NPC_char.amb"))
                ExportCharNames("NPC_char.amb");

            if (CheckAndGetFile("Place_data", out var container))
            {
                outPath = Path.Combine(outputPath, "Place_data");

                try
                {
                    Directory.CreateDirectory(outPath);
                }
                catch
                {
                    Console.WriteLine($"Unable to create output directory '{outPath}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToCreateDirectory);
                    return;
                }

                container.Files[1].Position = 0;
                var placeReader = new PlacesReader();
                var places = Places.Load(placeReader, container.Files[1]);

                for (int i = 0; i < places.Entries.Count; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    File.WriteAllText(fileOutPath, places.Entries[i].Name);
                }
            }

            if (CheckAndGetFile("Objects.amb", out container))
            {
                outPath = Path.Combine(outputPath, "Objects.amb");

                try
                {
                    Directory.CreateDirectory(outPath);
                }
                catch
                {
                    Console.WriteLine($"Unable to create output directory '{outPath}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToCreateDirectory);
                    return;
                }

                var reader = container.Files[1];
                reader.Position = 0;
                int numItems = reader.ReadWord();

                for (int i = 0; i < numItems; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    reader.Position += 40;
                    File.WriteAllText(fileOutPath, reader.ReadString(20).TrimEnd(' ', '\0'));
                }
            }
            else if (CheckFile("AM2_CPU") || CheckFile("AM2_BLIT"))
            {
                outPath = Path.Combine(outputPath, "Objects.amb");
                var exeData = ExecutableData.FromGameData(gameData);

                try
                {
                    Directory.CreateDirectory(outPath);
                }
                catch
                {
                    Console.WriteLine($"Unable to create output directory '{outPath}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToCreateDirectory);
                    return;
                }

                var items = exeData.ItemManager.Items;

                for (int i = 0; i < items.Count; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    File.WriteAllText(fileOutPath, items[i].Name.TrimEnd(' ', '\0'));
                }
            }

            void WriteGotoPointNames(string filename)
            {
                if (gameData.Files.TryGetValue(filename, out container))
                {
                    outPath = Path.Combine(outputPath, filename);

                    try
                    {
                        Directory.CreateDirectory(outPath);
                    }
                    catch
                    {
                        Console.WriteLine($"Unable to create output directory '{outPath}'.");
                        Console.WriteLine();
                        Exit(ErrorCode.UnableToCreateDirectory);
                        return;
                    }

                    foreach (var file in container.Files)
                    {
                        if (file.Value.Size == 0)
                            continue;

                        file.Value.Position = 0;
                        var mapReader = new MapReader();
                        if ((file.Value.PeekDword() & 0x0000ff00) != 0x00000100)
                            continue; // no 3D map
                        var map = Map.LoadWithoutTexts((uint)file.Key, mapReader, file.Value, null);
                        
                        if (map.GotoPoints != null && map.GotoPoints.Count > 0)
                        {
                            var fileOutPath = Path.Combine(outPath, filenameCreator(file.Key));

                            try
                            {
                                Directory.CreateDirectory(fileOutPath);
                            }
                            catch
                            {
                                Console.WriteLine($"Unable to create output directory '{fileOutPath}'.");
                                Console.WriteLine();
                                Exit(ErrorCode.UnableToCreateDirectory);
                                return;
                            }

                            for (int i = 0; i < map.GotoPoints.Count; ++i)
                            {
                                var textOutPath = Path.Combine(fileOutPath, filenameCreator(i) + ".txt");
                                File.WriteAllText(textOutPath, map.GotoPoints[i].Name);
                            }
                        }
                    }
                }
            }

            if (CheckFile("1Map_data.amb"))
                WriteGotoPointNames("1Map_data.amb");
            if (CheckFile("2Map_data.amb"))
                WriteGotoPointNames("2Map_data.amb");
            if (CheckFile("3Map_data.amb"))
                WriteGotoPointNames("3Map_data.amb");

            var textContainerFilesToProcess = TextContainerFiles.Where(f => CheckFile(f));

            if (textContainerFilesToProcess.Any())
            {
                foreach (var textContainerFile in gameData.Files.Where(f => textContainerFilesToProcess.Contains(f.Key, fileNameComparer)))
                {
                    outPath = Path.Combine(outputPath, textContainerFile.Key);

                    try
                    {
                        Directory.CreateDirectory(outPath);
                    }
                    catch
                    {
                        Console.WriteLine($"Unable to create output directory '{outPath}'.");
                        Console.WriteLine();
                        Exit(ErrorCode.UnableToCreateDirectory);
                        return;
                    }

                    foreach (var textFile in textContainerFile.Value.Files)
                    {
                        Console.Write($"Reading texts from sub-file {textFile.Key} ... ");
                        List<string> texts;

                        try
                        {
                            textFile.Value.Position = 0;
                            texts = Ambermoon.Data.Legacy.Serialization.TextReader.ReadTexts(textFile.Value, new char[] { ' ', '\0' });
                        }
                        catch
                        {
                            Console.WriteLine("failed");
                            Console.WriteLine($"Unable to read text data.");
                            Console.WriteLine();
                            Exit(ErrorCode.UnableToReadTextData);
                            return;
                        }

                        Console.WriteLine("done");

                        var fileOutPath = Path.Combine(outPath, filenameCreator(textFile.Key));

                        Console.Write($"Writing texts to '{fileOutPath}' ... ");

                        try
                        {
                            Directory.CreateDirectory(fileOutPath);

                            for (int i = 0; i < texts.Count; ++i)
                            {
                                File.WriteAllText(Path.Combine(fileOutPath, filenameCreator(i) + ".txt"), texts[i], Encoding.UTF8);
                            }
                        }
                        catch
                        {
                            Console.WriteLine("failed");
                            Console.WriteLine($"Unable to write text files.");
                            Console.WriteLine();
                            Exit(ErrorCode.UnableToCreateTextFiles);
                            return;
                        }

                        Console.WriteLine("done");
                    }
                }
            }
        }

        static void Import(string gameDataPath, string inputPath, List<Option> options, List<string> files)
        {
            GameData gameData = null;
            Func<GameData> gameDataProvider = () =>
            {
                if (gameData != null)
                    return gameData;

                gameData = new GameData(GameData.LoadPreference.ForceExtracted, null, false);

                try
                {
                    gameData.Load(gameDataPath);
                    return gameData;
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Failed to load game data: " + ex.Message);
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToLoadGameData);
                    return null;
                }
            };

            bool CheckFile(string name) => name != null && (files == null || files.Count == 0 || files.Contains(name.ToLower()));
            string CheckAnyFile(params string[] names)
            {
                if (names == null)
                    return null;

                return names.FirstOrDefault(CheckFile);
            }

            bool hexNames = options.Contains(Option.HexSubfileNames);
            var fileNameMatcher = hexNames
                ? new Regex(@"^[0-9a-f]{3}$", RegexOptions.Compiled | RegexOptions.IgnoreCase)
                : new Regex(@"^[0-9]{3}$", RegexOptions.Compiled | RegexOptions.IgnoreCase);
            Func<string, uint> fileIndexParser = hexNames
                ? name => uint.Parse(name, System.Globalization.NumberStyles.AllowHexSpecifier)
                : name => uint.Parse(name);

            bool WriteFile(string outputFileName, Func<string, byte[], bool> writer, byte[] data)
            {
                try
                {
                    writer(outputFileName, data);
                    return true;
                }
                catch
                {
                    Console.WriteLine($"Failed to write data to '{outputFileName}'.");
                    Console.WriteLine();
                    Exit(ErrorCode.UnableToWriteData);
                    return false;
                }
            }

            bool WriteSingleFile(string outputFileName, byte[] data, bool useLob = false)
            {
                return WriteFile(outputFileName, (string fileName, byte[] data) =>
                {
                    if (options.Contains(Option.NewCompression))
                    {
                        var compressWriter1 = new DataWriter();
                        FileWriter.WriteJH(compressWriter1, data, 0xd2e7, true, false, LobCompression.LobType.TakeBest);
                        var compressWriter2 = new DataWriter();
                        FileWriter.WriteJH(compressWriter2, data, 0xd2e7, false);
                        if (compressWriter1.Size < compressWriter2.Size)
                            File.WriteAllBytes(fileName, compressWriter1.ToArray());
                        else
                            File.WriteAllBytes(fileName, compressWriter2.ToArray());
                    }
                    else
                    {
                        var compressWriter = new DataWriter();
                        FileWriter.WriteJH(compressWriter, data, 0xd2e7, useLob);
                        File.WriteAllBytes(fileName, compressWriter.ToArray());
                    }
                    return true;
                }, data);
            }

            bool ProcessAndWriteFiles(string containerFile, Func<SortedDictionary<uint, string>, byte[]> processor, bool zeroBased, bool withMultipleTextsForSubFiles = false)
            {
                string outputFileName = Path.Combine(gameDataPath, containerFile);

                return ProcessFiles(containerFile, fileEntries =>
                {
                    try
                    {
                        var data = processor(fileEntries);

                        if (data != null)
                        {
                            if (data.Length == 0)
                                return true;

                            try
                            {
                                File.WriteAllBytes(outputFileName, data);
                            }
                            catch
                            {
                                Console.WriteLine($"Failed to write data to '{outputFileName}'.");
                                Console.WriteLine();
                                Exit(ErrorCode.UnableToWriteData);
                                return false;
                            }
                        }
                        else
                        {
                            Console.WriteLine($"{containerFile} was not found in target folder. Skipped it.");
                            Console.WriteLine();
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine();
                        Console.WriteLine("Failed: " + ex.ToString());
                        Console.WriteLine();
                        Exit(ErrorCode.UnableToWriteData);
                        return false;
                    }

                    return true;
                }, zeroBased, withMultipleTextsForSubFiles);
            }

            bool ProcessFiles(string containerFile, Func<SortedDictionary<uint, string>, bool> processor, bool zeroBased, bool withMultipleTextsForSubFiles = false)
            {
                string directory = Path.IsPathRooted(containerFile) || containerFile.StartsWith(inputPath) ? containerFile : Path.Combine(inputPath, containerFile);
                Func<uint, uint> indexAdjust = zeroBased ? index => index + 1 : index => index;

                if (withMultipleTextsForSubFiles)
                {
                    var subDirs = Directory.GetDirectories(directory)
                        .Select(f => new { path = f, name = Path.GetFileName(f) })
                        .Where(f => fileNameMatcher.IsMatch(f.name))
                        .ToList();
                    var result = new SortedDictionary<uint, string>();
                    foreach (var subDir in subDirs)
                    {
                        if (!ProcessFiles(Path.Combine(directory, subDir.name), texts =>
                        {
                            result.Add(indexAdjust(fileIndexParser(subDir.name)), string.Join('\n', texts.Values));
                            return true;
                        }, true))
                        return false;
                    }

                    processor(result);

                    return true;
                }

                Console.Write($"Looking for text data in '{directory}' ... ");

                var files = Directory.GetFiles(directory, "*.txt")
                    .Select(f => new { path = f, name = Path.GetFileNameWithoutExtension(f) })
                    .Where(f => fileNameMatcher.IsMatch(f.name));
                var fileEntries = new SortedDictionary<uint, string>(files.ToDictionary(f => indexAdjust(fileIndexParser(f.name)), f => File.ReadAllText(f.path, Encoding.UTF8).TrimEnd('\r', '\n')));
                uint maxIndex = fileEntries.Keys.DefaultIfEmpty().Max();
                
                if (fileEntries.Count != maxIndex)
                {
                    for (uint i = 1; i <= maxIndex; ++i)
                    {
                        if (!fileEntries.ContainsKey(i))
                            fileEntries.Add(i, "");
                    }
                }

                if (processor(fileEntries))
                {
                    Console.WriteLine("done");
                    Console.WriteLine();
                    return true;
                }
                else
                {
                    return false;
                }
            }

            // TODO: intro, outro, etc

            try
            {
                Directory.CreateDirectory(gameDataPath);
            }
            catch
            {
                Console.WriteLine($"Unable to create output directory '{gameDataPath}'.");
                Console.WriteLine();
                Exit(ErrorCode.UnableToCreateDirectory);
                return;
            }

            string dictionaryFile = CheckAnyFile(DictionaryFiles);

            if (dictionaryFile != null)
            {
                if (!ProcessAndWriteFiles(dictionaryFile, texts =>
                {
                    var writer = new DataWriter();
                    writer.Write((ushort)texts.Count);

                    foreach (var text in texts)
                    {
                        writer.Write((byte)text.Value.Length);
                        writer.WriteWithoutLength(text.Value);
                    }

                    byte zero = 0;

                    do
                    {
                        writer.Write(zero);
                    } while (writer.Position % 4 != 0);

                    var containerWriter = new DataWriter();
                    bool newComp = options.Contains(Option.NewCompression);
                    FileWriter.WriteJH(containerWriter, writer.ToArray(), 0xd2e7, true, false, newComp ? LobCompression.LobType.TakeBestForText : LobCompression.LobType.Ambermoon);
                    return containerWriter.ToArray();
                }, true))
                return;
            }

            if (CheckFile("Text.amb"))
            {
                var textContainer = new TextContainer();

                Console.WriteLine("Reading all texts from Text.amb.");

                ReadTexts("Messages", textContainer.Messages);
                ReadTexts("WorldNames", textContainer.WorldNames);
                ReadTexts("FormatMessages", textContainer.FormatMessages);
                ReadTexts("AutomapTypeNames", textContainer.AutomapTypeNames);
                ReadTexts("OptionNames", textContainer.OptionNames);
                ReadTexts("MusicNames", textContainer.MusicNames);
                ReadTexts("SpellClassNames", textContainer.SpellClassNames);
                ReadTexts("SpellNames", textContainer.SpellNames);
                ReadTexts("LanguageNames", textContainer.LanguageNames);
                ReadTexts("ClassNames", textContainer.ClassNames);
                ReadTexts("RaceNames", textContainer.RaceNames);
                ReadTexts("SkillNames", textContainer.SkillNames);
                ReadTexts("AttributeNames", textContainer.AttributeNames);
                ReadTexts("SkillShortNames", textContainer.SkillShortNames);
                ReadTexts("AttributeShortNames", textContainer.AttributeShortNames);
                ReadTexts("ItemTypeNames", textContainer.ItemTypeNames);
                ReadTexts("ConditionNames", textContainer.ConditionNames);
                ReadTexts("UITexts", textContainer.UITexts);
                List<string> versionStrings = new();
                ReadTexts("DateAndLanguageString", versionStrings);
                ReadTexts("VersionString", versionStrings);
                textContainer.DateAndLanguageString = versionStrings[0];
                textContainer.VersionString = versionStrings[1];

                string indexFilePath = Path.Combine(inputPath, "Text.amb", "UITexts", PlaceholderIndexFile);
                var indexReader = new DataReader(File.ReadAllBytes(indexFilePath));

                int count = indexReader.ReadWord();

                for (int i = 0; i < count; ++i)
                    textContainer.UITextWithPlaceholderIndices.Add(indexReader.ReadWord());

                void ReadTexts(string folderName, List<string> texts)
                {
                    ProcessFiles(Path.Combine("Text.amb", folderName), files =>
                    {
                        texts.AddRange(files.Values);
                        return true;
                    }, true);
                }

                var writer = new DataWriter();
                var textContainerWriter = new TextContainerWriter();

                textContainerWriter.WriteTextContainer(textContainer, writer, false);

                string outputFileName = Path.Combine(gameDataPath, "Text.amb");

                WriteSingleFile(outputFileName, writer.ToArray(), true);
            }

            static string SizeString(int size, string str, bool trimStart = true, bool needsTermNull = true)
            {
                if (trimStart)
                    str = str.TrimStart();

                if (str.Length < size)
                {
                    return str.PadRight(size, '\0');
                }
                else
                {
                    if (needsTermNull)
                    {
                        string newString = str[0..(size - 1)] + "\0";
                        Console.WriteLine($"WARNING: String '{str}' was shortened to '{newString.TrimEnd('\0')}' because the max size is {size - 1} without terminating null.");
                        return newString;
                    }
                    else
                    {
                        string newString = str[0..size];
                        if (str.Length > size)
                            Console.WriteLine($"WARNING: String '{str}' was shortened to '{newString}' because the max size is {size}.");
                        return newString;
                    }
                }
            }

            void ImportCharNames(string filename)
            {
                ProcessAndWriteFiles(filename, entries =>
                {
                    var gameData = gameDataProvider();

                    if (gameData == null || !gameData.Files.ContainsKey(filename))
                        return null;

                    var containerFiles = gameData.Files[filename].Files;
                    var files = entries.ToDictionary(entry => entry.Key, entry =>
                    {
                        var reader = containerFiles[(int)entry.Key];

                        if (reader.Size == 0)
                            return Array.Empty<byte>();

                        reader.Position = 0;

                        var writer = new DataWriter(reader.ReadBytes(0x0112));
                        writer.WriteWithoutLength(SizeString(16, entry.Value));
                        reader.Position += 16;
                        writer.Write(reader.ReadToEnd());
                        return writer.ToArray();
                    });
                    var containerWriter = new DataWriter();
                    bool newComp = options.Contains(Option.NewCompression);
                    FileWriter.WriteContainer(containerWriter, files,
                        Path.GetFileName(filename).ToLower().StartsWith("party") ? FileType.AMBR : FileType.AMPC, null,
                        newComp ? LobCompression.LobType.TakeBest : LobCompression.LobType.Ambermoon,
                        newComp ? FileDictionaryCompression.UseBest : FileDictionaryCompression.None);
                    return containerWriter.ToArray();
                }, false);
            }

            if (CheckFile("Monster_char.amb"))
                ImportCharNames("Monster_char.amb");
            else if (CheckFile("Monster_char_data.amb"))
                ImportCharNames("Monster_char_data.amb");
            if (CheckFile("Party_char.amb"))
                ImportCharNames("Save.00/Party_char.amb");
            if (CheckFile("NPC_char.amb"))
                ImportCharNames("NPC_char.amb");

            string filename = "Place_data";

            if (CheckFile(filename))
            {
                string outputFileName = Path.Combine(gameDataPath, filename);

                ProcessFiles(filename, entries =>
                {
                    var gameData = gameDataProvider();

                    if (gameData == null || !gameData.Files.ContainsKey(filename))
                        return false;

                    var file = gameData.Files[filename].Files[1];
                    file.Position = 0;
                    int placeCount = file.PeekWord();

                    if (placeCount != entries.Count)
                        throw new Exception("Mismatching place data/text count.");

                    var writer = new DataWriter();
                    writer.Write(file.ReadBytes(2 + placeCount * 32));
                    for (uint i = 1; i <= placeCount; ++i)
                    {
                        writer.WriteWithoutLength(SizeString(30, entries[i], true, false));
                    }
                    return WriteSingleFile(outputFileName, writer.ToArray(), true);
                }, true);
            }

            filename = "Objects.amb";

            if (CheckFile(filename))
            {
                string outputFileName = Path.Combine(gameDataPath, filename);

                ProcessFiles(filename, entries =>
                {
                    var gameData = gameDataProvider();

                    if (gameData == null || !gameData.Files.ContainsKey(filename))
                        return false;

                    var file = gameData.Files[filename].Files[1];
                    file.Position = 0;
                    int itemCount = file.ReadWord();

                    if (itemCount != entries.Count)
                        throw new Exception("Mismatching item data/text count.");

                    var writer = new DataWriter();
                    writer.Write((ushort)itemCount);
                    for (uint i = 1; i <= itemCount; ++i)
                    {
                        writer.Write(file.ReadBytes(40));
                        file.Position += 20;
                        writer.WriteWithoutLength(SizeString(20, entries[i]));
                    }
                    return WriteSingleFile(outputFileName, writer.ToArray(), true);
                }, true);
            }

            void ReadGotoPointNames(string filename)
            {
                ProcessAndWriteFiles(filename, entries =>
                {
                    if (entries.Count == 0)
                        return Array.Empty<byte>();

                    var gameData = gameDataProvider();

                    if (gameData == null || !gameData.Files.ContainsKey(filename))
                        return null;

                    var mapReader = new MapReader();
                    var containerFiles = gameData.Files[filename].Files;
                    var files = containerFiles.ToDictionary(entry => (uint)entry.Key, entry =>
                    {
                        var reader = containerFiles[entry.Key];

                        if (reader.Size == 0)
                            return Array.Empty<byte>();

                        reader.Position = 0;

                        if ((reader.PeekDword() & 0x0000ff00) != 0x00000100 || !entries.TryGetValue((uint)entry.Key, out var nameString))
                            return reader.ReadToEnd(); // just return the data for 2D maps

                        var map = Map.LoadWithoutTexts((uint)entry.Key, mapReader, reader, null);
                        var names = nameString.Split('\n');

                        if (map.GotoPoints.Count != names.Length)
                            throw new Exception($"Mismatching goto point data/text count for map {entry.Key}.");

                        reader.Position = 0;

                        if (map.GotoPoints.Count == 0)
                            return reader.ReadToEnd(); // just return the data if there are no goto points

                        var writer = new DataWriter(reader.ReadBytes(0x014c + map.Width * map.Height * 2 +
                            2 + map.EventList.Count * 2 + 2 + map.Events.Count * 12));

                        foreach (var mapChar in map.CharacterReferences ?? Array.Empty<Map.CharacterReference>())
                        {
                            if (mapChar == null)
                                continue;

                            if (mapChar.Type != CharacterType.Monster &&
                                !mapChar.CharacterFlags.HasFlag(Map.CharacterReference.Flags.RandomMovement) &&
                                !mapChar.CharacterFlags.HasFlag(Map.CharacterReference.Flags.Stationary))
                            {
                                writer.Write(reader.ReadBytes(288 * 2));
                            }
                            else
                            {
                                writer.Write(reader.ReadBytes(2));
                            }
                        }

                        writer.Write(reader.ReadBytes(2)); // goto point count

                        for (int i = 0; i < map.GotoPoints.Count; ++i)
                        {
                            writer.Write(reader.ReadBytes(4));
                            writer.WriteWithoutLength(SizeString(16, names[i], true, false));
                            reader.Position += 16;
                        }

                        writer.Write(reader.ReadToEnd());
                        return writer.ToArray();
                    });
                    foreach (var existingFile in containerFiles)
                        files.TryAdd((uint)existingFile.Key, existingFile.Value.ReadToEnd());
                    var containerWriter = new DataWriter();
                    bool newComp = options.Contains(Option.NewCompression);
                    FileWriter.WriteContainer(containerWriter, files,
                        FileType.AMPC, null,
                        newComp ? LobCompression.LobType.TakeBest : LobCompression.LobType.Ambermoon,
                        newComp ? FileDictionaryCompression.UseBest : FileDictionaryCompression.None);
                    return containerWriter.ToArray();
                }, false, true);
            }

            void CheckAndRead(string file, Action<string> reader)
            {
                if (CheckFile(file))
                    reader(file);
            }

            CheckAndRead("1Map_data.amb", ReadGotoPointNames);
            CheckAndRead("2Map_data.amb", ReadGotoPointNames);
            CheckAndRead("3Map_data.amb", ReadGotoPointNames);

            CheckAndRead("1Map_texts.amb", ReadTextContainers);
            CheckAndRead("2Map_texts.amb", ReadTextContainers);
            CheckAndRead("3Map_texts.amb", ReadTextContainers);
            CheckAndRead("NPC_texts.amb", ReadTextContainers);
            CheckAndRead("Object_texts.amb", ReadTextContainers);
            CheckAndRead("Party_texts.amb", ReadTextContainers);

            void ReadTextContainers(string file)
            {
                ProcessAndWriteFiles(file, entries =>
                {
                    if (entries.Count == 0)
                        return Array.Empty<byte>();

                    var gameData = gameDataProvider();

                    if (gameData == null || !gameData.Files.ContainsKey(file))
                        return null;

                    var containerFiles = new Dictionary<uint, byte[]>(entries.Count);

                    foreach (var entry in entries)
                    {
                        if (entry.Value.Length == 0)
                        {
                            containerFiles.Add(entry.Key, Array.Empty<byte>());
                            continue;
                        }

                        var texts = new List<string>(entry.Value.Split('\n'));
                        var dataWriter = new DataWriter();

                        Ambermoon.Data.Legacy.Serialization.TextWriter.WriteTexts(dataWriter, texts);

                        containerFiles.Add(entry.Key, dataWriter.ToArray());
                    }

                    var containerWriter = new DataWriter();
                    bool newComp = options.Contains(Option.NewCompression);
                    FileWriter.WriteContainer(containerWriter, containerFiles, FileType.AMNP, null,
                        newComp ? LobType.TakeBest : LobType.Ambermoon,
                        newComp ? FileDictionaryCompression.UseBest : FileDictionaryCompression.None);
                    return containerWriter.ToArray();
                }, false, true);
            }
        }
    }
}
