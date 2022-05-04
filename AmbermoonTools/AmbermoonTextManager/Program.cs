using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace AmbermoonTextImport
{
    class Program
    {
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
            PreserveWhitespaces,
            PreserveZeros,
            HexSubfileNames
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
            Console.WriteLine(" --hex-subfile-names / -x    :     Subfile name with hex numbering");
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

            var options = new List<string>();
            var parameters = new List<string>();

            foreach (var arg in args)
            {
                if (arg.StartsWith("--"))
                    options.Add(arg.ToLower());
                else if (arg.StartsWith("-"))
                    options.Add(arg.ToLower());
                else
                    parameters.Add(arg);
            }

            if (options.Contains("--help") || options.Contains("-h"))
            {
                Usage();
                Exit(ErrorCode.NoError);
                return;
            }

            if (parameters.Count != 2 || options.Count < 1 || options.Count > 2)
            {
                Console.WriteLine("Invalid arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidArguments);
                return;
            }

            var additionalOptions = ParseOptions(options.Skip(1).ToArray());

            if (additionalOptions == null)
                return;

            if (options[0] == "-e")
            {
                Export(parameters[0], parameters[1], additionalOptions);
            }
            else if (options[0] == "-i")
            {
                Import(parameters[0], parameters[1], additionalOptions);
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

        static List<Option> ParseOptions(IEnumerable<string> args)
        {
            var options = new List<Option>();

            try
            {
                foreach (var arg in args)
                {
                    if (arg == "--hex-subfile-names")
                        options.Add(Option.HexSubfileNames);
                    else if (arg.StartsWith("-"))
                    {
                        if (arg.Length != 2)
                            throw new Exception();

                        for (int i = 1; i < arg.Length; ++i)
                        {
                            if (arg[i] == 'x')
                                options.Add(Option.HexSubfileNames);
                            else
                                throw new Exception();
                        }
                    }
                    else
                        throw new Exception();
                }

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

        static void Export(string gameDataPath, string outputPath, List<Option> options)
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

            var fileNameComparer = new FileNameComparer();
            var filenameCreator = options.Contains(Option.HexSubfileNames)
                ? (Func<int, string>)(i => i.ToString("X3"))
                : i => i.ToString("000");
            string outPath;

            // TODO: intro, outro, etc

            if (!gameData.Files.TryGetValue("Dict.amb", out var dictionary))
            {
                if (!gameData.Files.TryGetValue("Dictionary.english", out dictionary))
                {
                    if (!gameData.Files.TryGetValue("Dictionary.german", out dictionary))
                        dictionary = null;
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
                int numEntries = reader.ReadWord();

                Console.WriteLine($"Writing {numEntries} dictionary entries.");

                for (int i = 0; i < numEntries; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    File.WriteAllText(fileOutPath, reader.ReadString());
                }
            }

            if (gameData.Files.TryGetValue("Text.amb", out var textAmb))
            {
                outPath = Path.Combine(outputPath, textAmb.Name);
                var reader = textAmb.Files[1];
                var textContainerReader = new TextContainerReader();
                var textContainer = new TextContainer();
                textContainerReader.ReadTextContainer(textContainer, reader, false);

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
                        File.WriteAllText(fileOutPath, texts[i]);
                    }
                }

                var foo = new TextContainerWriter();
                var writer = new DataWriter();
                foo.WriteTextContainer(textContainer, writer, false);
                using var bar = File.Create(@"C:\Projects\AmigaAsm\NewAmbermoon\foo.amb");
                writer.CopyTo(bar);
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

            ExportCharNames("Monster_char_data.amb", "Monster_char.amb");
            ExportCharNames("Party_char.amb");
            ExportCharNames("NPC_char.amb");

            if (gameData.Files.TryGetValue("Place_data", out var container))
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

                var placeReader = new PlacesReader();
                var places = Places.Load(placeReader, container.Files[1]);

                for (int i = 0; i < places.Entries.Count; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    File.WriteAllText(fileOutPath, places.Entries[i].Name);
                }
            }

            if (gameData.Files.TryGetValue("Objects.amb", out container))
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
                reader.Position = reader.Size - 4;
                int numIcons = reader.ReadWord();
                int numItems = reader.ReadWord();
                reader.Position = numIcons * 160;

                for (int i = 0; i < numItems; ++i)
                {
                    var fileOutPath = Path.Combine(outPath, filenameCreator(i) + ".txt");
                    reader.Position += 40;
                    File.WriteAllText(fileOutPath, reader.ReadString(20).TrimEnd(' ', '\0'));
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

            WriteGotoPointNames("1Map_data.amb");
            WriteGotoPointNames("2Map_data.amb");
            WriteGotoPointNames("3Map_data.amb");

            foreach (var textContainerFile in gameData.Files.Where(f => TextContainerFiles.Contains(f.Key, fileNameComparer)))
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

        static bool AskForConfirmation(string message)
        {
            Console.WriteLine(message);
            Console.Write("Do you want to continue (Y/N)? ");

            return Console.ReadLine().ToLower() == "y";
        }

        static void Import(string gameDataPath, string inputPath, List<Option> options)
        {
            /*string inPath = inputPath;

            if (!inputPath.ToLower().TrimEnd(new char[] { '/', '\\' }).EndsWith(file.ToLower()))
                inPath = Path.Combine(inputPath, file);

            Console.Write($"Looking for text data in '{inPath}' ... ");

            if (!Directory.Exists(inPath))
            {
                Console.WriteLine("failed");
                Console.WriteLine($"Directory does not exist.");
                Console.WriteLine();
                Exit(ErrorCode.DirectoryNotFound);
                return;
            }

            var subDirs = Directory.GetDirectories(inPath);

            if (subDirs.Length == 0)
            {
                Console.WriteLine("failed");

                if (!AskForConfirmation("No sub directory exists so the resulting data file will be empty!"))
                {
                    Console.WriteLine("Directory does not exist.");
                    Console.WriteLine();
                    Exit(ErrorCode.Aborted);
                    return;
                }
            }

            var textFiles = new Dictionary<int, List<string>>();
            var regex = new Regex(options.Contains(Option.HexSubfileNames) ? "^[0-9a-fA-F]{3}$" : "^[0-9]{3}$", RegexOptions.Compiled);
            int foundTextCount = 0;
            var filenameParser = options.Contains(Option.HexSubfileNames)
                ? (Func<string, int>)(name => int.Parse(name, System.Globalization.NumberStyles.AllowHexSpecifier))
                : name => int.Parse(name);

            foreach (var subDir in subDirs)
            {
                string dirName = Path.GetFileName(subDir); // Note: GetFileName will retrieve last directory part in this case.

                if (regex.IsMatch(dirName))
                {
                    var list = new List<string>();
                    var localTextFiles = new List<string>(Directory.GetFiles(subDir).Where(f => regex.IsMatch(Path.GetFileNameWithoutExtension(f))));
                    localTextFiles.Sort();

                    for (int i = 0; i < localTextFiles.Count; ++i)
                    {
                        if (i != filenameParser(Path.GetFileNameWithoutExtension(localTextFiles[i])))
                        {
                            Console.WriteLine($"Text files must be numbered from 0 to n without gaps. Missing number before {i:000}.txt.");
                            Console.WriteLine();
                            Exit(ErrorCode.WrongFileNumbering);
                            return;
                        }
                    }

                    list.AddRange(localTextFiles.Select(f => File.ReadAllText(f, Encoding.UTF8)));

                    foundTextCount += list.Count;

                    textFiles[filenameParser(dirName)] = list;
                }
            }

            if (foundTextCount == 0)
            {
                Console.WriteLine("failed");

                if (!AskForConfirmation("No text files with the right names exist so the resulting data file will be empty!"))
                {
                    Console.WriteLine("No text files found.");
                    Console.WriteLine();
                    Exit(ErrorCode.Aborted);
                    return;
                }
            }
            else
            {
                Console.WriteLine("done");
                Console.WriteLine($"Found {foundTextCount} texts in {textFiles.Count} filled sub-directories.");
            }

            Console.Write("Collecting text data ... ");
            Dictionary<uint, byte[]> data;

            try
            {
                data = textFiles.Select(f =>
                {
                    var dataWriter = new Ambermoon.Data.Legacy.Serialization.DataWriter();
                    if (f.Value.Count != 0)
                        Ambermoon.Data.Legacy.Serialization.TextWriter.WriteTexts(dataWriter, f.Value, TrimCharsFromOptions(options), true);
                    return new KeyValuePair<uint, byte[]>((uint)f.Key, dataWriter.ToArray());
                }).ToDictionary(x => x.Key, x => x.Value);
            }
            catch
            {
                Console.WriteLine("failed");
                Console.WriteLine("Error while transforming texts to data.");
                Exit(ErrorCode.UnableToTransformTexts);
                return;
            }

            Console.WriteLine("done");

            var outPath = Path.IsPathRooted(file) ? file : Path.Combine(gameDataPath, file);

            Console.Write($"Writing data to '{outPath}' ... ");

            try
            {
                Directory.CreateDirectory(Path.GetDirectoryName(outPath));
            }
            catch
            {
                Console.WriteLine("failed");
                Console.WriteLine($"Unable to create output directory '{outPath}'.");
                Console.WriteLine();
                Exit(ErrorCode.UnableToCreateDirectory);
                return;
            }

            if (File.Exists(outPath))
            {
                string backup = outPath + ".backup";

                if (!File.Exists(backup))
                {
                    Console.WriteLine("halted");
                    Console.WriteLine($"Target file exists and there is no backup.");
                    Console.Write($"Creating backup at '{backup}' ... ");

                    try
                    {
                        File.Copy(outPath, backup);
                    }
                    catch
                    {
                        Console.WriteLine("failed");
                        Console.WriteLine("Failed to create backup. Import is now aborted.");
                        Console.WriteLine();
                        Exit(ErrorCode.UnableToCreateBackup);
                        return;
                    }

                    Console.WriteLine("done");
                    Console.Write("Resuming data writing ... ");
                }
            }

            var containerWriter = new Ambermoon.Data.Legacy.Serialization.DataWriter();

            try
            {
                Ambermoon.Data.Legacy.Serialization.FileWriter.WriteContainer(containerWriter, data, Ambermoon.Data.Legacy.Serialization.FileType.AMNP);

                using var stream = File.Create(outPath);
                containerWriter.CopyTo(stream);
            }
            catch
            {
                Console.WriteLine("failed");
                Console.WriteLine($"Failed to write data to '{outPath}'.");
                Console.WriteLine();
                Exit(ErrorCode.UnableToWriteData);
                return;
            }

            Console.WriteLine("done");*/
        }
    }
}
