//! AmbermoonTextManager: exports all texts and names of the game (dictionary, Text.amb, characters, places, items, goto
//! points, map and other texts) into text files and imports them again (a port of
//! AmbermoonTools/AmbermoonTextManager).
//!
//!   AmbermoonTextManager -e <inGameDataPath> <outFolderPath> [options]
//!   AmbermoonTextManager -i <outGameDataPath> <inFolderPath> [options]
namespace AmbermoonTextManager;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.ExecutableData;
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

const string PlaceholderIndexFile = "placeholders.idx";

const ReadOnlySlice<string> TextContainerFiles =
[
    "1Map_texts.amb", "2Map_texts.amb", "3Map_texts.amb", "NPC_texts.amb", "Object_texts.amb", "Party_texts.amb"
];

const ReadOnlySlice<string> DictionaryFiles = ["Dict.amb", "Dictionary.english", "Dictionary.german"];

// the options: -e or -i, the others and the files to consider (lowercase; none: all)
bool ExportMode = false;
bool ImportMode = false;
bool HexSubfileNames = false;
bool NewCompression = false;
bool UnicodeNormalization = false;
List<string> Files = List<string>.Create();

void Exit(ErrorCode errorCode)
{
    Environment.Exit((int)errorCode);
}

void Usage()
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
    Console.WriteLine(" --hex-subfile-names / -x     : Subfile names with hex numbering");
    Console.WriteLine(" --file <name> / -f <name>    : Only consider this file (can be repeated for more)");
    Console.WriteLine("   Use names like Place_data or 2Map_texts.amb here.");
    Console.WriteLine("   If no file is given explicitly, all files are considered.");
    Console.WriteLine(" --use-new-compression / -c   : Uses new compression algorithms (Advanced only)");
    Console.WriteLine(" --unicode-normalization / -u : Normalizes characters like á to a");
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
    if (args.Length < 3)
    {
        Console.WriteLine("Invalid number of arguments.");
        Console.WriteLine();
        Usage();
        return (int)ErrorCode.InvalidNumberOfArguments;
    }

    foreach (var arg in args)
    {
        if (arg == "--help" || arg == "-h")
        {
            Usage();
            return (int)ErrorCode.NoError;
        }
    }

    var remainingArgs = ParseOptions(args);

    if (remainingArgs.Count() < 2 || (!ExportMode && !ImportMode && !HexSubfileNames && !NewCompression && !UnicodeNormalization))
    {
        InvalidArguments();
        return 0;
    }

    if (ExportMode && ImportMode)
    {
        InvalidArguments();
        return 0;
    }

    if (ExportMode)
        Export(remainingArgs[0], remainingArgs[1]);
    else if (ImportMode)
        Import(remainingArgs[0], remainingArgs[1]);
    else
        InvalidArguments();

    return (int)ErrorCode.NoError;
}

// sets the options and gives the other arguments; exits the program with a message if an option is invalid
List<string> ParseOptions(string[] args)
{
    var remainingArgs = List<string>.Create();

    for (var i = 0; i < args.Length; i += 1)
    {
        string arg = args[i];
        bool addFile = false;

        if (arg == "--hex-subfile-names")
            HexSubfileNames = true;
        else if (arg == "--file")
            addFile = true;
        else if (arg == "--use-new-compression")
            NewCompression = true;
        else if (arg == "--unicode-normalization")
            UnicodeNormalization = true;
        else if (arg.StartsWith("-"))
        {
            if (LengthNet(arg) != 2)
                InvalidArguments();

            if (arg[1] == 'f')
                addFile = true;
            else if (arg[1] == 'e')
                ExportMode = true;
            else if (arg[1] == 'i')
                ImportMode = true;
            else if (arg[1] == 'x')
                HexSubfileNames = true;
            else if (arg[1] == 'c')
                NewCompression = true;
            else if (arg[1] == 'u')
                UnicodeNormalization = true;
            else
                InvalidArguments();
        }
        else
            remainingArgs.Add(arg);

        if (addFile)
        {
            if (i == args.Length - 1)
                InvalidArguments();

            i += 1;
            string file = args[i];

            if (file.StartsWith("-"))
                InvalidArguments();

            Files.Add(ToLowerNet(file));
        }
    }

    return remainingArgs;
}

bool CheckFile(string name)
{
    return Files.Count() == 0 || Files.Contains(ToLowerNet(name));
}

// the name of a text file or sub-file folder for a number
string FileName(int number)
{
    return HexSubfileNames ? number.ToString("X").PadLeft(3, '0') : number.ToString().PadLeft(3, '0');
}

void CreateDirectoryOrExit(string path)
{
    if (!Directory.Create(path))
    {
        Console.WriteLine($"Unable to create output directory '{path}'.");
        Console.WriteLine();
        Exit(ErrorCode.UnableToCreateDirectory);
    }
}

// writes a text: UTF-8 with a byte order mark (`withBom`, File.WriteAllText with Encoding.UTF8) or without (as the
// original writes the names)
void WriteText(string path, string text, bool withBom)
{
    if (File.WriteAllText(path, withBom ? "\uFEFF" + text : text) is error)
    {
        Console.WriteLine($"Could not write file '{path}'.");
        Exit(ErrorCode.UnableToCreateTextFiles);
    }
}

// TrimEnd(' ', '\0')
string TrimEndSpacesAndZeros(StringSlice text)
{
    int end = text.Length;
    while (end > 0 && (text[end - 1] == ' ' || text[end - 1] == 0))
        end -= 1;
    return text[0..end].ToString();
}

// ---- export ----

void Export(string gameDataPath, string outputPath)
{
    var gameData = GameData.Create(LoadPreference.PreferExtracted, false);

    if (gameData.Load(gameDataPath) is error loadError)
    {
        Console.WriteLine("Failed to load game data: " + loadError.Message);
        Console.WriteLine();
        Exit(ErrorCode.UnableToLoadGameData);
        return;
    }

    // TODO: intro, outro, etc (as in the original)

    bool anyDictionary = false;
    foreach (var name in DictionaryFiles)
    {
        if (CheckFile(name))
            anyDictionary = true;
    }

    if (anyDictionary)
        ExportDictionary(gameData, outputPath);

    if (CheckFile("Text.amb") && gameData.Files.TryGet("Text.amb") is FileContainer textAmb)
    {
        var reader = textAmb.Files[1];
        reader.Position = 0;
        if (TextContainerReader.ReadTextContainer(ref reader, false) is not TextContainer textContainer)
        {
            Console.WriteLine("Unable to read text data.");
            Exit(ErrorCode.UnableToReadTextData);
            return;
        }
        WriteAllTexts(Path.Combine(outputPath, textAmb.Name), textContainer);
    }
    else if (CheckFile("AM2_CPU") || CheckFile("AM2_BLIT"))
    {
        var textContainer = try_or_exit(TextContainerFromExecutable(gameData));
        WriteAllTexts(Path.Combine(outputPath, "Text.amb"), textContainer);
    }

    if (CheckFile("Monster_char_data.amb") || CheckFile("Monster_char.amb"))
        ExportCharNames(gameData, outputPath, "Monster_char_data.amb", "Monster_char.amb");
    if (CheckFile("Party_char.amb"))
        ExportCharNames(gameData, outputPath, "Save.00/Party_char.amb", "");
    if (CheckFile("NPC_char.amb"))
        ExportCharNames(gameData, outputPath, "NPC_char.amb", "");

    if (CheckFile("Place_data") && gameData.Files.TryGet("Place_data") is FileContainer placeData)
    {
        var outPath = Path.Combine(outputPath, "Place_data");
        CreateDirectoryOrExit(outPath);

        var reader = placeData.Files[1];
        reader.Position = 0;
        int count = reader.ReadWord();
        reader.Position += count * 32;

        for (var i = 0; i < count; i += 1)
            WriteText(Path.Combine(outPath, FileName(i) + ".txt"), TrimNamePadding(reader.ReadString(30)), false);
    }

    if (CheckFile("Objects.amb") && gameData.Files.TryGet("Objects.amb") is FileContainer objects)
    {
        var outPath = Path.Combine(outputPath, "Objects.amb");
        CreateDirectoryOrExit(outPath);

        var reader = objects.Files[1];
        reader.Position = 0;
        int numItems = reader.ReadWord();

        for (var i = 0; i < numItems; i += 1)
        {
            reader.Position += 40;
            WriteText(Path.Combine(outPath, FileName(i) + ".txt"), TrimEndSpacesAndZeros(reader.ReadString(20)), false);
        }
    }
    else if (CheckFile("AM2_CPU") || CheckFile("AM2_BLIT"))
    {
        var outPath = Path.Combine(outputPath, "Objects.amb");
        var exeData = try_or_exit(ExecutableData.FromGameData(gameData));
        CreateDirectoryOrExit(outPath);

        if (exeData.ItemManager is ItemManager itemManager)
        {
            int i = 0;
            foreach (var item in itemManager.Items.Values())
            {
                WriteText(Path.Combine(outPath, FileName(i) + ".txt"), TrimEndSpacesAndZeros(item.Name), false);
                i += 1;
            }
        }
    }

    if (CheckFile("1Map_data.amb"))
        WriteGotoPointNames(gameData, outputPath, "1Map_data.amb");
    if (CheckFile("2Map_data.amb"))
        WriteGotoPointNames(gameData, outputPath, "2Map_data.amb");
    if (CheckFile("3Map_data.amb"))
        WriteGotoPointNames(gameData, outputPath, "3Map_data.amb");

    // the text files in the order of the game data
    foreach (var entry in gameData.Files.Entries())
    {
        bool isTextContainer = false;
        foreach (var name in TextContainerFiles)
        {
            if (CheckFile(name) && ToLowerNet(name) == ToLowerNet(entry.Key))
                isTextContainer = true;
        }
        if (isTextContainer)
            ExportTextContainer(entry.Value, Path.Combine(outputPath, entry.Key));
    }
}

// the value of a result; exits the program with its message if it is an error (the original ends with an exception)
T try_or_exit<T>(Error<T> result)
{
    if (result is error e)
    {
        Console.WriteLine(e.Message);
        Exit(ErrorCode.UnableToReadTextData);
    }
    if (result is T value)
        return value;
    Exit(ErrorCode.UnableToReadTextData);
    return default(T);
}

// Trim('\0', ' ')
string TrimNamePadding(StringSlice text)
{
    int start = 0;
    int end = text.Length;
    while (start < end && (text[start] == ' ' || text[start] == 0))
        start += 1;
    while (end > start && (text[end - 1] == ' ' || text[end - 1] == 0))
        end -= 1;
    return text[start..end].ToString();
}

void ExportDictionary(GameData gameData, string outputPath)
{
    Optional<FileContainer> dictionary = null;
    foreach (var name in DictionaryFiles)
    {
        if (dictionary == null && gameData.Files.TryGet(name) is FileContainer found)
            dictionary = found;
    }
    if (dictionary is not FileContainer container)
        return;

    var outPath = Path.Combine(outputPath, container.Name);
    CreateDirectoryOrExit(outPath);

    var reader = container.Files[1];
    reader.Position = 0;
    int numEntries = reader.ReadWord();

    Console.WriteLine($"Writing {numEntries} dictionary entries.");

    for (var i = 0; i < numEntries; i += 1)
        WriteText(Path.Combine(outPath, FileName(i) + ".txt"), reader.ReadLengthPrefixedString(), false);
}

void WriteAllTexts(string outPath, TextContainer textContainer)
{
    Console.WriteLine("Writing all texts from Text.amb.");

    WriteSectionTexts(outPath, "WorldNames", textContainer.WorldNames, textContainer);
    WriteSectionTexts(outPath, "FormatMessages", textContainer.FormatMessages, textContainer);
    WriteSectionTexts(outPath, "AutomapTypeNames", textContainer.AutomapTypeNames, textContainer);
    WriteSectionTexts(outPath, "OptionNames", textContainer.OptionNames, textContainer);
    WriteSectionTexts(outPath, "MusicNames", textContainer.MusicNames, textContainer);
    WriteSectionTexts(outPath, "SpellClassNames", textContainer.SpellClassNames, textContainer);
    WriteSectionTexts(outPath, "SpellNames", textContainer.SpellNames, textContainer);
    WriteSectionTexts(outPath, "LanguageNames", textContainer.LanguageNames, textContainer);
    WriteSectionTexts(outPath, "ClassNames", textContainer.ClassNames, textContainer);
    WriteSectionTexts(outPath, "RaceNames", textContainer.RaceNames, textContainer);
    WriteSectionTexts(outPath, "SkillNames", textContainer.SkillNames, textContainer);
    WriteSectionTexts(outPath, "AttributeNames", textContainer.AttributeNames, textContainer);
    WriteSectionTexts(outPath, "SkillShortNames", textContainer.SkillShortNames, textContainer);
    WriteSectionTexts(outPath, "AttributeShortNames", textContainer.AttributeShortNames, textContainer);
    WriteSectionTexts(outPath, "ItemTypeNames", textContainer.ItemTypeNames, textContainer);
    WriteSectionTexts(outPath, "ConditionNames", textContainer.ConditionNames, textContainer);
    WriteSectionTexts(outPath, "UITexts", textContainer.UITexts, textContainer);
    var date = List<string>.Create();
    date.Add(textContainer.DateAndLanguageString);
    WriteSectionTexts(outPath, "DateAndLanguageString", date, textContainer);
    var version = List<string>.Create();
    version.Add(textContainer.VersionString);
    WriteSectionTexts(outPath, "VersionString", version, textContainer);
    WriteSectionTexts(outPath, "Messages", textContainer.Messages, textContainer);
}

void WriteSectionTexts(string outPath, string folderName, List<string> texts, TextContainer textContainer)
{
    string path = Path.Combine(outPath, folderName);
    CreateDirectoryOrExit(path);

    for (var i = 0; i < texts.Count(); i += 1)
        WriteText(Path.Combine(path, FileName(i) + ".txt"), texts[i], true);

    if (folderName == "UITexts")
    {
        var indexWriter = new DataWriter();
        indexWriter.WriteWord((uint16)textContainer.UITextWithPlaceholderIndices.Count());
        foreach (var index in textContainer.UITextWithPlaceholderIndices)
            indexWriter.WriteWord((uint16)index);
        if (File.WriteAllBytes(Path.Combine(path, PlaceholderIndexFile), indexWriter.AsSlice()) is error)
        {
            Console.WriteLine($"Could not write file '{Path.Combine(path, PlaceholderIndexFile)}'.");
            Exit(ErrorCode.UnableToCreateTextFiles);
        }
    }
}

// the values of a dictionary with an enum key sorted by the number of the key
List<string> ByKey<K>(Dictionary<K, string> entries)
{
    var keys = List<int64>.Create();
    foreach (var key in entries.Keys())
        keys.Add((int64)key);
    keys.Sort();
    var values = List<string>.Create(keys.Count());
    foreach (var key in keys)
    {
        foreach (var entry in entries.Entries())
        {
            if ((int64)entry.Key == key)
            {
                values.Add(entry.Value);
                break;
            }
        }
    }
    return values;
}

void AddRange(List<string> target, List<string> values, int skip, int take)
{
    for (var i = skip; i < values.Count() && i - skip < take; i += 1)
        target.Add(values[i]);
}

// Text.amb of the texts in the executable (versions before 1.14)
Error<TextContainer> TextContainerFromExecutable(GameData gameData)
{
    var exeData = try ExecutableData.FromGameData(gameData);
    var textContainer = TextContainer.Create();
    const int all = 1000000;

    if (exeData.WorldNames is WorldNames worldNames)
        AddRange(textContainer.WorldNames, ByKey(worldNames.Entries), 0, all);
    if (exeData.Messages is Messages messages)
        AddRange(textContainer.FormatMessages, messages.Entries, 0, 26);
    if (exeData.AutomapNames is AutomapNames automapNames)
        AddRange(textContainer.AutomapTypeNames, ByKey(automapNames.Entries), 2, all);
    if (exeData.OptionNames is OptionNames optionNames)
        AddRange(textContainer.OptionNames, ByKey(optionNames.Entries), 0, all);
    if (exeData.SongNames is SongNames songNames)
        AddRange(textContainer.MusicNames, ByKey(songNames.Entries), 0, all);
    if (exeData.SpellTypeNames is SpellTypeNames spellTypeNames)
        AddRange(textContainer.SpellClassNames, ByKey(spellTypeNames.Entries), 0, all);
    if (exeData.SpellNames is SpellNames spellNames)
        AddRange(textContainer.SpellNames, ByKey(spellNames.Entries), 1, all);
    if (exeData.LanguageNames is LanguageNames languageNames)
        AddRange(textContainer.LanguageNames, ByKey(languageNames.Entries), 0, all);
    if (exeData.ClassNames is ClassNames classNames)
        AddRange(textContainer.ClassNames, ByKey(classNames.Entries), 0, all);
    if (exeData.RaceNames is RaceNames raceNames)
        AddRange(textContainer.RaceNames, ByKey(raceNames.Entries), 0, all);
    if (exeData.SkillNames is SkillNames skillNames)
        AddRange(textContainer.SkillNames, ByKey(skillNames.Entries), 0, all);
    if (exeData.AttributeNames is AttributeNames attributeNames)
        AddRange(textContainer.AttributeNames, ByKey(attributeNames.Entries), 0, 9);
    if (exeData.SkillNames is SkillNames skillShortNames)
        AddRange(textContainer.SkillShortNames, ByKey(skillShortNames.ShortNames), 0, all);
    if (exeData.AttributeNames is AttributeNames attributeShortNames)
        AddRange(textContainer.AttributeShortNames, ByKey(attributeShortNames.ShortNames), 0, 8);
    if (exeData.ItemTypeNames is ItemTypeNames itemTypeNames)
        AddRange(textContainer.ItemTypeNames, ByKey(itemTypeNames.Entries), 1, all);
    if (exeData.ConditionNames is ConditionNames conditionNames)
        AddRange(textContainer.ConditionNames, ByKey(conditionNames.Entries), 1, all);

    const ReadOnlySlice<int> placeholderIndices = [13, 17, 28, 29, 30, 31, 32, 33, 34, 35, 36, 41];
    foreach (var index in placeholderIndices)
        textContainer.UITextWithPlaceholderIndices.Add(index);

    if (exeData.UITexts is UITexts uiTexts)
    {
        var sorted = List<int64>.Create();
        foreach (var key in uiTexts.Entries.Keys())
            sorted.Add((int64)key);
        sorted.Sort();

        for (var i = 0; i < sorted.Count() && i < 11; i += 1)
            textContainer.UITexts.Add(_ProcessUIText(textContainer, uiTexts.Entries[(UITextIndex)sorted[i]]));
        textContainer.UITexts.Add(uiTexts.Entries[UITextIndex.BothSexes]);
        for (var i = 11; i < sorted.Count(); i += 1)
        {
            var key = (UITextIndex)sorted[i];
            if (key != UITextIndex.BothSexes && key != UITextIndex.Placeholder2Digit &&
                key != UITextIndex.Placeholder2DigitInParentheses)
                textContainer.UITexts.Add(_ProcessUIText(textContainer, uiTexts.Entries[key]));
        }
    }

    textContainer.DateAndLanguageString = exeData.DataInfoString;
    textContainer.VersionString = exeData.DataVersionString;
    if (exeData.Messages is Messages allMessages)
        AddRange(textContainer.Messages, allMessages.Entries, 26, all);

    // TODO: format messages and messages do not work (as in the original)

    return textContainer;
}

// the placeholders "{0:00}" of a UI text that has placeholders as numbers "01" (the regular expression
// \{[0-9]:(0+)\} of the original)
string _ProcessUIText(TextContainer textContainer, string text)
{
    if (!textContainer.UITextWithPlaceholderIndices.Contains(textContainer.UITexts.Count()))
        return text;

    var result = StringBuilder.Create();
    int i = 0;
    while (i < text.Length)
    {
        if (text[i] == '{' && i + 4 < text.Length && text[i + 1] >= '0' && text[i + 1] <= '9' && text[i + 2] == ':' &&
            text[i + 3] == '0')
        {
            int p = i + 3;
            while (p < text.Length && text[p] == '0')
                p += 1;
            if (p < text.Length && text[p] == '}')
            {
                for (var d = 0; d < p - (i + 3); d += 1)
                    result.Append(d.ToString());
                i = p + 1;
                continue;
            }
        }
        result.Append((char)text[i]);
        i += 1;
    }
    return result.ToString();
}

void ExportCharNames(GameData gameData, string outputPath, string filename, string fallbackFilename)
{
    var found = gameData.Files.TryGet(filename);
    if (found == null && fallbackFilename.Length != 0)
    {
        found = gameData.Files.TryGet(fallbackFilename);
        filename = fallbackFilename;
    }
    if (found is not FileContainer container)
        return;

    var outPath = Path.Combine(outputPath, filename);
    CreateDirectoryOrExit(outPath);

    foreach (var file in container.Files.Entries())
    {
        var reader = file.Value;
        if (reader.Size() == 0)
            continue;

        reader.Position = 0x0112;
        WriteText(Path.Combine(outPath, FileName(file.Key) + ".txt"), TrimEndSpacesAndZeros(reader.ReadString(16)), false);
    }
}

// whether a map is a 3D map (the type in the third byte)
bool Is3DMap(DataReader reader)
{
    return reader.Size() > 2 && reader.Get(2) == 1;
}

void WriteGotoPointNames(GameData gameData, string outputPath, string filename)
{
    if (gameData.Files.TryGet(filename) is not FileContainer container)
        return;

    var outPath = Path.Combine(outputPath, filename);
    CreateDirectoryOrExit(outPath);

    foreach (var file in container.Files.Entries())
    {
        var reader = file.Value;
        if (reader.Size() == 0 || !Is3DMap(reader))
            continue; // no 3D map

        var map = try_or_exit(MapReader.ReadMap((uint32)file.Key, ref reader, null));

        if (map.GotoPoints.Count() > 0)
        {
            var fileOutPath = Path.Combine(outPath, FileName(file.Key));
            CreateDirectoryOrExit(fileOutPath);

            for (var i = 0; i < map.GotoPoints.Count(); i += 1)
                WriteText(Path.Combine(fileOutPath, FileName(i) + ".txt"), map.GotoPoints[i].Name, false);
        }
    }
}

void ExportTextContainer(FileContainer container, string outPath)
{
    CreateDirectoryOrExit(outPath);

    foreach (var textFile in container.Files.Entries())
    {
        Console.Write($"Reading texts from sub-file {textFile.Key} ... ");

        if (TextReader.ReadTexts(textFile.Value, true, true) is not List<string> texts)
        {
            Console.WriteLine("failed");
            Console.WriteLine("Unable to read text data.");
            Console.WriteLine();
            Exit(ErrorCode.UnableToReadTextData);
            return;
        }

        Console.WriteLine("done");

        var fileOutPath = Path.Combine(outPath, FileName(textFile.Key));

        Console.Write($"Writing texts to '{fileOutPath}' ... ");

        bool written = Directory.Create(fileOutPath);
        for (var i = 0; written && i < texts.Count(); i += 1)
            written = File.WriteAllText(Path.Combine(fileOutPath, FileName(i) + ".txt"), "\uFEFF" + texts[i]) is not error;

        if (!written)
        {
            Console.WriteLine("failed");
            Console.WriteLine("Unable to write text files.");
            Console.WriteLine();
            Exit(ErrorCode.UnableToCreateTextFiles);
            return;
        }

        Console.WriteLine("done");
    }
}
