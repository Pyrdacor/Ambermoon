using Ambermoon.Data.Legacy;
using System;
using System.Collections.Generic;
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
            Console.WriteLine("USAGE: AmbermoonTextImport -e <gameDataPath> <file> <outPath> [options]");
            Console.WriteLine("       AmbermoonTextImport -i <gameDataPath> <file> <inPath> [options]");
            Console.WriteLine("       AmbermoonTextImport --help");
            Console.WriteLine();
            Console.WriteLine("1st version exports all texts of the given file (e.g. 1Map_texts.amb).");
            Console.WriteLine("2nd version imports all texts into the given file.");
            Console.WriteLine();
            Console.WriteLine("The <gameDataPath> param is a local directory where the game files or ADFs are.");
            Console.WriteLine("  or should be placed in case of import.");
            Console.WriteLine("The <outPath> param is a local directory where to store the text files.");
            Console.WriteLine("The <inPath> param is a local directory where to load the text files from.");
            Console.WriteLine("The export will create a sub-folder with the name of the file.");
            Console.WriteLine("The exported text files are numbered like 001.txt, 002.txt, etc.");
            Console.WriteLine("The import expects the same file names and sub-folder structure.");
            Console.WriteLine("The import will create a backup if not present already.");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine("-> AmbermoonTextImport -e \"C:\\Ambermoon\\Amberfiles\" 1Map_texts.amb \"C:\\AmbermoonData\\Texts\"");
            Console.WriteLine("-> AmbermoonTextImport -i \"C:\\Ambermoon\\Amberfiles\" 1Map_texts.amb \"C:\\AmbermoonData\\Texts\"");
            Console.WriteLine("-> AmbermoonTextImport -e \"C:\\Ambermoon\\Amberfiles\" 1Map_texts.amb \"C:\\AmbermoonData\\Texts\" -pzh");
            Console.WriteLine();
            Console.WriteLine("Options:");
            Console.WriteLine(" --preserve-whitespaces / -p :     Preserve whitespaces");
            Console.WriteLine(" --preserve-zero-bytes / -z  :     Preserve 0-bytes");
            Console.WriteLine(" --hex-subfile-names / -h    :     Subfile name with hex numbering");
            Console.WriteLine(" Those can be combined like -pzh or -hz.");
            Console.WriteLine();
        }

        static void Main(string[] args)
        {
            if (args.Length == 0)
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

            if (options.Count < 1 || options.Count > 4|| parameters.Count != 3)
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
                Export(parameters[0], parameters[1], parameters[2], additionalOptions);
            }
            else if (options[0] == "-i")
            {
                Import(parameters[0], parameters[1], parameters[2], additionalOptions);
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
                    if (arg == "--preserve-whitespaces")
                        options.Add(Option.PreserveWhitespaces);
                    else if (arg == "--preserve-zero-bytes")
                        options.Add(Option.PreserveZeros);
                    else if (arg == "--hex-subfile-names")
                        options.Add(Option.HexSubfileNames);
                    else if (arg.StartsWith("-"))
                    {
                        if (arg.Length < 2 || arg.Length > 4)
                            throw new Exception();

                        for (int i = 1; i < arg.Length; ++i)
                        {
                            if (arg[i] == 'p')
                                options.Add(Option.PreserveWhitespaces);
                            else if (arg[i] == 'z')
                                options.Add(Option.PreserveZeros);
                            else if (arg[i] == 'h')
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

        static char[] TrimCharsFromOptions(List<Option> options)
        {
            bool preserveWhitespaces = options.Contains(Option.PreserveWhitespaces);
            bool preserveZeroBytes = options.Contains(Option.PreserveZeros);

            if (preserveWhitespaces)
            {
                if (preserveZeroBytes)
                    return new char[] { };
                else
                    return new char[] { '\0' };
            }
            else if (preserveZeroBytes)
                return new char[] { ' ' };
            else
                return new char[] { ' ', '\0' };
        }

        static void Export(string gameDataPath, string file, string outputPath, List<Option> options)
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

            var container = gameData.Files.FirstOrDefault(f => string.Compare(f.Key, file) == 0).Value;

            if (container == null)
            {
                Console.WriteLine($"Failed to find file '{file}' in game data.");
                Console.WriteLine();
                Exit(ErrorCode.UnableToLoadGameData);
                return;
            }

            string outPath = outputPath;

            if (!outputPath.ToLower().TrimEnd(new char[] { '/', '\\' }).EndsWith(file.ToLower()))
                outPath = Path.Combine(outputPath, file);

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

            foreach (var textFile in container.Files)
            {
                Console.Write($"Reading texts from sub-file {textFile.Key} ... ");
                List<string> texts;

                try
                {
                    texts = Ambermoon.Data.Legacy.Serialization.TextReader.ReadTexts(textFile.Value, TrimCharsFromOptions(options));
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

                var filenameCreator = options.Contains(Option.HexSubfileNames)
                    ? (Func<int, string>)(i => i.ToString("X3"))
                    : i => i.ToString("000");
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

        static bool AskForConfirmation(string message)
        {
            Console.WriteLine(message);
            Console.Write("Do you want to continue (Y/N)? ");

            return Console.ReadLine().ToLower() == "y";
        }

        static void Import(string gameDataPath, string file, string inputPath, List<Option> options)
        {
            string inPath = inputPath;

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
                        if (i != int.Parse(Path.GetFileNameWithoutExtension(localTextFiles[i])))
                        {
                            Console.WriteLine($"Text files must be numbered from 0 to n without gaps. Missing number before {i:000}.txt.");
                            Console.WriteLine();
                            Exit(ErrorCode.WrongFileNumbering);
                            return;
                        }
                    }

                    list.AddRange(localTextFiles.Select(f => File.ReadAllText(f, Encoding.UTF8)));

                    foundTextCount += list.Count;

                    if (list.Count != 0)
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
                    Ambermoon.Data.Legacy.Serialization.TextWriter.WriteTexts(dataWriter, f.Value, TrimCharsFromOptions(options));
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

            Console.WriteLine("done");
        }
    }
}
