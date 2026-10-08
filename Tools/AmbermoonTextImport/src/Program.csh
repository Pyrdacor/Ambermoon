//! AmbermoonTextImport: exports the texts of a text file of the game (map texts, Text.amb, ...) into text files and
//! imports them again (a port of AmbermoonTools/AmbermoonTextImport).
//!
//!   AmbermoonTextImport -e <gameDataPath> <file> <outPath> [options]
//!   AmbermoonTextImport -i <gameDataPath> <file> <inPath> [options]
namespace AmbermoonTextImport;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.Serialization;

enum ErrorCode : int
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

/// The options after the command.
struct Options
{
    bool PreserveWhitespaces;
    bool PreserveZeros;
    bool HexSubfileNames;
    bool ExtendedCompression;
}

const string PlaceholderIndexFile = "placeholders.idx";

// the sections of Text.amb: the names of their folders (the properties of the TextContainer of the original)
const ReadOnlySlice<string> TextContainerSections =
[
    "WorldNames", "FormatMessages", "Messages", "AutomapTypeNames", "OptionNames", "MusicNames", "SpellClassNames",
    "SpellNames", "LanguageNames", "ClassNames", "RaceNames", "SkillNames", "AttributeNames", "SkillShortNames",
    "AttributeShortNames", "ItemTypeNames", "ConditionNames", "UITexts", "VersionString", "DateAndLanguageString"
];

void Exit(ErrorCode errorCode)
{
    Environment.Exit((int)errorCode);
}

void Usage()
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
    Console.WriteLine("-> AmbermoonTextImport -e \"C:\\Ambermoon\\Amberfiles\" 1Map_texts.amb \"C:\\AmbermoonData\\Texts\" -pzx");
    Console.WriteLine();
    Console.WriteLine("Options:");
    Console.WriteLine(" --preserve-whitespaces / -p :     Preserve whitespaces");
    Console.WriteLine(" --preserve-zero-bytes / -z  :     Preserve 0-bytes");
    Console.WriteLine(" --hex-subfile-names / -x    :     Subfile name with hex numbering");
    Console.WriteLine(" --extended-compression / -c :     Extended compression");
    Console.WriteLine(" Those can be combined like -pzx or -xz.");
    Console.WriteLine();
}

void InvalidArguments()
{
    Console.WriteLine("Invalid arguments.");
    Console.WriteLine();
    Usage();
    Exit(ErrorCode.InvalidArguments);
}

int Main(string[] args)
{
    if (args.Length == 0)
    {
        Console.WriteLine("Invalid number of arguments.");
        Console.WriteLine();
        Usage();
        return (int)ErrorCode.InvalidNumberOfArguments;
    }

    var options = List<string>.Create();
    var parameters = List<string>.Create();

    foreach (var arg in args)
    {
        if (arg.StartsWith("-"))
            options.Add(ToLowerNet(arg));
        else
            parameters.Add(arg);
    }

    if (options.Contains("--help") || options.Contains("-h"))
    {
        Usage();
        return (int)ErrorCode.NoError;
    }

    if (options.Count() < 1 || options.Count() > 4 || parameters.Count() != 3)
    {
        InvalidArguments();
        return 0;
    }

    var additionalOptions = ParseOptions(options);

    if (options[0] == "-e")
        Export(parameters[0], parameters[1], parameters[2], additionalOptions);
    else if (options[0] == "-i")
        Import(parameters[0], parameters[1], parameters[2], additionalOptions);
    else
        InvalidArguments();

    return (int)ErrorCode.NoError;
}

// the options after the first one; exits the program with a message if one is invalid
Options ParseOptions(List<string> args)
{
    var options = Options { };

    for (var a = 1; a < args.Count(); a += 1)
    {
        var arg = args[a];
        if (arg == "--preserve-whitespaces")
            options.PreserveWhitespaces = true;
        else if (arg == "--preserve-zero-bytes")
            options.PreserveZeros = true;
        else if (arg == "--hex-subfile-names")
            options.HexSubfileNames = true;
        else if (arg == "--extended-compression")
            options.ExtendedCompression = true;
        else
        {
            // (all options start with '-')
            int length = LengthNet(arg);
            if (length < 2 || length > 5)
                InvalidArguments();

            for (var i = 1; i < arg.Length; i += 1)
            {
                if (arg[i] == 'p')
                    options.PreserveWhitespaces = true;
                else if (arg[i] == 'z')
                    options.PreserveZeros = true;
                else if (arg[i] == 'x')
                    options.HexSubfileNames = true;
                else if (arg[i] == 'c')
                    options.ExtendedCompression = true;
                else
                    InvalidArguments();
            }
        }
    }

    return options;
}

// the name of a text file or sub-file folder for a number
string FileName(int number, Options options)
{
    return options.HexSubfileNames ? number.ToString("X").PadLeft(3, '0') : number.ToString().PadLeft(3, '0');
}

// the folder of the texts of the file: the given one if it ends with the name of the file, else a folder in it
string TextFolder(string path, string file)
{
    var trimmed = ToLowerNet(path);
    int end = trimmed.Length;
    while (end > 0 && (trimmed[end - 1] == '/' || trimmed[end - 1] == '\\'))
        end -= 1;
    if (EndsWithNet(trimmed[0..end], ToLowerNet(file)))
        return path;
    return Path.Combine(path, file);
}

bool IsTextAmb(string file)
{
    return ToLowerNet(Path.GetFileName(file)) == "text.amb";
}

// the texts of a section of Text.amb
List<string> SectionTexts(TextContainer container, int section)
{
    switch (section)
    {
        case 0: return container.WorldNames;
        case 1: return container.FormatMessages;
        case 2: return container.Messages;
        case 3: return container.AutomapTypeNames;
        case 4: return container.OptionNames;
        case 5: return container.MusicNames;
        case 6: return container.SpellClassNames;
        case 7: return container.SpellNames;
        case 8: return container.LanguageNames;
        case 9: return container.ClassNames;
        case 10: return container.RaceNames;
        case 11: return container.SkillNames;
        case 12: return container.AttributeNames;
        case 13: return container.SkillShortNames;
        case 14: return container.AttributeShortNames;
        case 15: return container.ItemTypeNames;
        case 16: return container.ConditionNames;
        case 17: return container.UITexts;
        default:
        {
            var single = List<string>.Create();
            single.Add(section == 18 ? container.VersionString : container.DateAndLanguageString);
            return single;
        }
    }
}

// writes the texts as 000.txt, 001.txt, ... (UTF-8 with a byte order mark, as the original writes them)
bool WriteTextFiles(string folder, List<string> texts, Options options)
{
    if (!Directory.Create(folder))
        return false;
    for (var i = 0; i < texts.Count(); i += 1)
    {
        var path = Path.Combine(folder, FileName(i, options) + ".txt");
        if (File.WriteAllText(path, "\uFEFF" + texts[i]) is error)
            return false;
    }
    return true;
}

void FailWith(string message, ErrorCode errorCode)
{
    Console.WriteLine("failed");
    Console.WriteLine(message);
    Console.WriteLine();
    Exit(errorCode);
}

void Export(string gameDataPath, string file, string outputPath, Options options)
{
    var gameData = GameData.Create(LoadPreference.PreferExtracted, false);

    if (gameData.Load(gameDataPath) is error loadError)
    {
        Console.WriteLine("Failed to load game data: " + loadError.Message);
        Console.WriteLine();
        Exit(ErrorCode.UnableToLoadGameData);
        return;
    }

    Optional<FileContainer> found = null;
    foreach (var entry in gameData.Files.Entries())
    {
        if (found == null && EqualsNet(entry.Key, file))
            found = entry.Value;
    }

    if (found is not FileContainer container)
    {
        Console.WriteLine($"Failed to find file '{file}' in game data.");
        Console.WriteLine();
        Exit(ErrorCode.UnableToLoadGameData);
        return;
    }

    string outPath = TextFolder(outputPath, file);

    if (!Directory.Create(outPath))
    {
        Console.WriteLine($"Unable to create output directory '{outPath}'.");
        Console.WriteLine();
        Exit(ErrorCode.UnableToCreateDirectory);
        return;
    }

    if (container.Files.Count() == 1 && IsTextAmb(file))
    {
        Console.Write("Reading texts from text container ... ");

        var reader = container.Files[1];
        reader.Position = 0;
        if (TextContainerReader.ReadTextContainer(ref reader, false) is not TextContainer textContainer)
        {
            FailWith("Unable to read text data.", ErrorCode.UnableToReadTextData);
            return;
        }

        Console.WriteLine("done");

        for (var section = 0; section < TextContainerSections.Length; section += 1)
        {
            var fileOutPath = Path.Combine(outPath, TextContainerSections[section]);

            Console.Write($"Writing texts to '{fileOutPath}' ... ");

            if (!WriteTextFiles(fileOutPath, SectionTexts(textContainer, section), options))
            {
                FailWith("Unable to write text files.", ErrorCode.UnableToCreateTextFiles);
                return;
            }

            if (section == 17) // UITexts
            {
                var indexWriter = new DataWriter();
                indexWriter.WriteWord((uint16)textContainer.UITextWithPlaceholderIndices.Count());
                foreach (var index in textContainer.UITextWithPlaceholderIndices)
                    indexWriter.WriteWord((uint16)index);

                if (File.WriteAllBytes(Path.Combine(fileOutPath, PlaceholderIndexFile), indexWriter.AsSlice()) is error)
                {
                    FailWith("Unable to write placeholder index file.", ErrorCode.UnableToCreateTextFiles);
                    return;
                }
            }

            Console.WriteLine("done");
        }
    }
    else
    {
        foreach (var textFile in container.Files.Entries())
        {
            Console.Write($"Reading texts from sub-file {textFile.Key} ... ");

            var read = TextReader.ReadTexts(textFile.Value, !options.PreserveWhitespaces, !options.PreserveZeros);
            if (read is not List<string> texts)
            {
                FailWith("Unable to read text data.", ErrorCode.UnableToReadTextData);
                return;
            }

            Console.WriteLine("done");

            var fileOutPath = Path.Combine(outPath, FileName(textFile.Key, options));

            Console.Write($"Writing texts to '{fileOutPath}' ... ");

            if (!WriteTextFiles(fileOutPath, texts, options))
            {
                FailWith("Unable to write text files.", ErrorCode.UnableToCreateTextFiles);
                return;
            }

            Console.WriteLine("done");
        }
    }
}

// asks whether to continue; the end of the input is no
bool AskForConfirmation(string message)
{
    Console.WriteLine(message);
    Console.Write("Do you want to continue (Y/N)? ");

    return Console.ReadLine() is string line && ToLowerNet(line) == "y";
}

// whether a name (without its extension) is a number of 3 digits, hex digits with `hex` (the regular expression of the
// original: "^[0-9]{3}$", where $ also matches before a line break at the end)
bool IsNumberName(StringSlice name, bool hex)
{
    var digits = name.Length == 4 && name[3] == '\n' ? name[0..3] : name;
    if (digits.Length != 3)
        return false;
    foreach (var c in digits)
    {
        bool isDigit = c >= '0' && c <= '9';
        bool isHex = (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
        if (!isDigit && !(hex && isHex))
            return false;
    }
    return true;
}

int ParseNumberName(StringSlice name, bool hex)
{
    var digits = name.Length == 4 ? name[0..3] : name;
    int value = 0;
    foreach (var c in digits)
        value = value * (hex ? 16 : 10) + Char.HexValue(c);
    return value;
}

// the stem of a file name (without the last extension)
string Stem(StringSlice path)
{
    return Path.GetStem(Path.GetFileName(path));
}

// sorts paths as .NET's culture-aware sort does for names of digits and hex digits: by their values, then a
// lowercase letter before an uppercase one
void SortNumberPaths(List<string> paths)
{
    for (var i = 1; i < paths.Count(); i += 1)
    {
        var path = paths[i];
        int j = i;
        while (j > 0 && _CompareNumberPaths(paths[j - 1], path) > 0)
        {
            paths[j] = paths[j - 1];
            j -= 1;
        }
        paths[j] = path;
    }
}

int _CompareNumberPaths(string a, string b)
{
    int length = a.Length < b.Length ? a.Length : b.Length;
    for (var i = 0; i < length; i += 1)
    {
        int ka = _PrimaryKey(a[i]);
        int kb = _PrimaryKey(b[i]);
        if (ka != kb)
            return ka < kb ? -1 : 1;
    }
    if (a.Length != b.Length)
        return a.Length < b.Length ? -1 : 1;
    for (var i = 0; i < length; i += 1)
    {
        if (a[i] != b[i])
        {
            // the same letter in another case: lowercase first
            bool lowerA = a[i] >= 'a' && a[i] <= 'z';
            return lowerA ? -1 : 1;
        }
    }
    return 0;
}

int _PrimaryKey(uint8 c)
{
    if (c >= 'A' && c <= 'Z')
        return c + 32;
    return c;
}

// the texts of the text files of a folder; null (after the message) if they are not numbered without gaps
Optional<List<string>> ReadNumberedTexts(List<string> files, bool hex, bool failedFirst)
{
    SortNumberPaths(files);

    for (var i = 0; i < files.Count(); i += 1)
    {
        if (i != ParseNumberName(Stem(files[i]), hex))
        {
            if (failedFirst)
                Console.WriteLine("failed");
            Console.WriteLine($"Text files must be numbered from 0 to n without gaps. Missing number before {i.ToString().PadLeft(3, '0')}.txt.");
            Console.WriteLine();
            Exit(ErrorCode.WrongFileNumbering);
            return null;
        }
    }

    var texts = List<string>.Create(files.Count());
    foreach (var file in files)
        texts.Add(ReadAllTextNet(file) is string text ? text : "");
    return texts;
}

void Import(string gameDataPath, string file, string inputPath, Options options)
{
    string inPath = TextFolder(inputPath, file);

    Console.Write($"Looking for text data in '{inPath}' ... ");

    if (!Directory.Exists(inPath))
    {
        FailWith("Directory does not exist.", ErrorCode.DirectoryNotFound);
        return;
    }

    var subDirs = GetDirectories(inPath);

    if (subDirs.Count() == 0)
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

    bool hex = options.HexSubfileNames;
    var outPath = Path.IsRooted(file) ? file : Path.Combine(gameDataPath, file);

    if (IsTextAmb(file))
    {
        var sections = List<List<string>>.Create();
        var placeholderIndices = List<int>.Create(12);
        int foundTextCount = 0;

        for (var section = 0; section < TextContainerSections.Length; section += 1)
        {
            var name = TextContainerSections[section];
            bool exists = false;
            foreach (var subDir in subDirs)
            {
                if (Path.GetFileName(subDir) == name)
                    exists = true;
            }
            if (!exists)
            {
                FailWith($"Sub-directory {name} does not exist.", ErrorCode.Aborted);
                return;
            }

            string directory = Path.Combine(inPath, name);
            var files = List<string>.Create();
            foreach (var path in FindFiles(directory, "*.txt", false))
            {
                if (IsNumberName(Stem(path), hex))
                    files.Add(path);
            }

            if (files.Count() == 0)
            {
                FailWith($"Sub-directory {name} contains not files.", ErrorCode.Aborted);
                return;
            }

            if (ReadNumberedTexts(files, hex, true) is not List<string> texts)
                return;
            sections.Add(texts);
            foundTextCount += texts.Count();

            if (section == 17) // UITexts: the indices of the texts with placeholders
            {
                string indexFilePath = Path.Combine(directory, PlaceholderIndexFile);
                string placeholderError = "";

                Optional<uint8[]> indexFile = null;
                if (IsFile(indexFilePath) && File.ReadAllBytes(indexFilePath) is uint8[] bytes)
                    indexFile = bytes;
                if (indexFile is not uint8[] indexData)
                    placeholderError = "No placeholder index file was found for the UI texts.";
                else
                {
                    var indexReader = DataReader.FromData(indexData);
                    int count = indexReader.Size() < 2 ? 0 : indexReader.ReadWord();

                    if (count == 0 || indexReader.Size() != count * 2 + 2)
                        placeholderError = "The placeholder index file is empty or invalid.";
                    else
                    {
                        for (var i = 0; i < count; i += 1)
                            placeholderIndices.Add(indexReader.ReadWord());
                    }
                }

                if (placeholderError.Length != 0)
                {
                    FailWith(placeholderError + "\nThis might be a mistake and will break dynamic values in the game!", ErrorCode.Aborted);
                    return;
                }
            }
        }

        Console.WriteLine("done");
        Console.WriteLine($"Found {foundTextCount} texts in {sections.Count()} filled sub-directories.");

        for (var section = 0; section < sections.Count(); section += 1)
            Console.WriteLine($" {sections[section].Count().ToString().PadLeft(3, ' ')} in {TextContainerSections[section]}");

        var textContainer = TextContainer.Create();
        for (var section = 0; section < 18; section += 1)
        {
            var target = SectionTexts(textContainer, section);
            foreach (var text in sections[section])
                target.Add(text);
        }
        textContainer.VersionString = sections[18][0];
        textContainer.DateAndLanguageString = sections[19][0];
        foreach (var index in placeholderIndices)
            textContainer.UITextWithPlaceholderIndices.Add(index);

        var dataWriter = new DataWriter();
        // (the original ends with an exception if the texts do not fit)
        if (TextContainerWriter.WriteTextContainer(textContainer, ref dataWriter, false) is error writeError)
        {
            Console.WriteLine(writeError.Message);
            Exit(ErrorCode.UnableToTransformTexts);
            return;
        }

        Console.Write($"Writing data to '{outPath}' ... ");
        PrepareOutput(outPath);

        var fileWriter = new DataWriter();
        var lobType = options.ExtendedCompression ? LobType.TakeBest : LobType.Ambermoon;
        if (FileWriter.WriteJH(ref fileWriter, dataWriter.ToArray(), 0xd2e7, true, false, lobType) is error ||
            File.WriteAllBytes(outPath, fileWriter.AsSlice()) is error)
        {
            FailWith($"Failed to write data to '{outPath}'.", ErrorCode.UnableToWriteData);
            return;
        }

        Console.WriteLine("done");
    }
    else
    {
        var textFiles = Dictionary<int, List<string>>.Create();
        int foundTextCount = 0;

        // (in the order of their names; the original takes them in the order of the file system)
        foreach (var subDir in subDirs)
        {
            string dirName = Path.GetFileName(subDir);

            if (!IsNumberName(dirName, hex))
                continue;

            var localTextFiles = List<string>.Create();
            foreach (var path in GetFiles(subDir))
            {
                if (IsNumberName(Stem(path), hex))
                    localTextFiles.Add(path);
            }

            if (ReadNumberedTexts(localTextFiles, hex, false) is not List<string> texts)
                return;

            foundTextCount += texts.Count();
            textFiles[ParseNumberName(dirName, hex)] = texts;
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
            Console.WriteLine($"Found {foundTextCount} texts in {textFiles.Count()} filled sub-directories.");
        }

        Console.Write("Collecting text data ... ");

        var data = Dictionary<uint32, uint8[]>.Create();
        foreach (var entry in textFiles.Entries())
        {
            var dataWriter = new DataWriter();
            if (entry.Value.Count() != 0)
                TextWriter.WriteTexts(ref dataWriter, entry.Value, !options.PreserveWhitespaces, !options.PreserveZeros, true);
            data[(uint32)entry.Key] = dataWriter.ToArray();
        }

        Console.WriteLine("done");

        Console.Write($"Writing data to '{outPath}' ... ");
        PrepareOutput(outPath);

        var containerWriter = new DataWriter();
        bool extended = options.ExtendedCompression;
        // (the original fails for a file 0 and for no files at all: "Failed to write data")
        bool valid = data.Count() != 0 && !data.ContainsKey(0);
        if (!valid || FileWriter.WriteContainer(ref containerWriter, data, FileType.AMNP, null,
                                                extended ? LobType.TakeBestForText : LobType.Ambermoon,
                                                extended ? FileDictionaryCompression.UseBest : FileDictionaryCompression.None,
                                                null) is error ||
            File.WriteAllBytes(outPath, containerWriter.AsSlice()) is error)
        {
            FailWith($"Failed to write data to '{outPath}'.", ErrorCode.UnableToWriteData);
            return;
        }

        Console.WriteLine("done");
    }
}

// creates the folder of the output file and a backup of the file if it exists and has none
void PrepareOutput(string outPath)
{
    var directory = Path.GetDirectory(outPath);
    if (directory.Length == 0 || !Directory.Create(directory))
    {
        FailWith($"Unable to create output directory '{outPath}'.", ErrorCode.UnableToCreateDirectory);
        return;
    }

    if (!IsFile(outPath))
        return;

    string backup = outPath + ".backup";

    if (File.Exists(backup))
        return;

    Console.WriteLine("halted");
    Console.WriteLine("Target file exists and there is no backup.");
    Console.Write($"Creating backup at '{backup}' ... ");

    if (File.Copy(outPath, backup) is error)
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
