namespace AmbermoonTextManager;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.Serialization;

// the game data of the import: loaded when it is first needed
string ImportGameDataPath = "";
string ImportInputPath = "";
Optional<GameData> LoadedGameData = null;

GameData ImportGameData()
{
    if (LoadedGameData is GameData loaded)
        return loaded;

    var gameData = GameData.Create(LoadPreference.ForceExtracted, false);
    if (gameData.Load(ImportGameDataPath) is error loadError)
    {
        Console.WriteLine("Failed to load game data: " + loadError.Message);
        Console.WriteLine();
        Exit(ErrorCode.UnableToLoadGameData);
    }
    LoadedGameData = gameData;
    return gameData;
}

// ends the program with a message where the original ends with an exception
void Fail(string message, ErrorCode errorCode)
{
    Console.WriteLine(message);
    Exit(errorCode);
}

// whether a name (without its extension) is a number of 3 digits (hex digits with -x)
bool IsNumberName(StringSlice name)
{
    if (name.Length != 3)
        return false;
    foreach (var c in name)
    {
        bool isDigit = c >= '0' && c <= '9';
        bool isHex = (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
        if (!isDigit && !(HexSubfileNames && isHex))
            return false;
    }
    return true;
}

uint32 ParseNumberName(StringSlice name)
{
    uint32 value = 0;
    foreach (var c in name)
        value = value * (HexSubfileNames ? (uint32)16 : 10) + (uint32)Char.HexValue(c);
    return value;
}

// the folder of a file of the texts: in the input folder unless it is rooted or starts with the input folder
string TextDirectory(string containerFile)
{
    if (Path.IsRooted(containerFile) || StartsWithNet(containerFile, ImportInputPath))
        return containerFile;
    return Path.Combine(ImportInputPath, containerFile);
}

// a text file: without line breaks at its end, normalized with -u
string ReadTextFile(string path)
{
    string text = ReadAllTextNet(path) is string content ? content : "";
    int end = text.Length;
    while (end > 0 && (text[end - 1] == '\r' || text[end - 1] == '\n'))
        end -= 1;
    text = text[0..end].ToString();

    if (UnicodeNormalization)
        text = ReplaceSpecialLetters(RemoveDiacritics(text));

    return text;
}

// the texts of the files 000.txt, 001.txt, ... of a folder by their numbers (from 1 with `zeroBased`), the missing
// numbers up to the highest as empty texts; shows "Looking for text data in ..."
Dictionary<uint32, string> ReadTexts(string containerFile, bool zeroBased)
{
    string directory = TextDirectory(containerFile);

    Console.Write($"Looking for text data in '{directory}' ... ");

    if (!Directory.Exists(directory))
    {
        Console.WriteLine();
        Fail($"Could not find a part of the path '{Path.GetFullPath(directory)}'.", ErrorCode.DirectoryNotFound);
    }

    var entries = Dictionary<uint32, string>.Create();
    uint32 maxIndex = 0;

    foreach (var file in FindFiles(directory, "*.txt", false))
    {
        var name = Path.GetStem(Path.GetFileName(file));
        if (!IsNumberName(name))
            continue;
        uint32 index = ParseNumberName(name) + (zeroBased ? (uint32)1 : 0);
        if (entries.ContainsKey(index))
        {
            Console.WriteLine();
            Fail($"An item with the same key has already been added. Key: {index}", ErrorCode.WrongFileNumbering);
        }
        entries[index] = ReadTextFile(file);
        if (index > maxIndex)
            maxIndex = index;
    }

    var sorted = Dictionary<uint32, string>.Create();
    for (uint32 i = 0; i <= maxIndex; i += 1)
    {
        if (entries.TryGet(i) is string text)
            sorted[i] = text;
        else if (i != 0)
            sorted[i] = "";
    }
    return sorted;
}

void PrintDone()
{
    Console.WriteLine("done");
    Console.WriteLine();
}

// the texts of the folders 000, 001, ... of a folder, each joined with line breaks, by the numbers of the folders
// (each folder shows "Looking for text data in ... done"; the folders in the order of their names)
Dictionary<uint32, string> ReadSubFolderTexts(string containerFile)
{
    string directory = TextDirectory(containerFile);
    var result = Dictionary<uint32, string>.Create();

    if (!Directory.Exists(directory))
        Fail($"Could not find a part of the path '{Path.GetFullPath(directory)}'.", ErrorCode.DirectoryNotFound);

    foreach (var subDirectory in GetDirectories(directory))
    {
        string name = Path.GetFileName(subDirectory);
        if (!IsNumberName(name))
            continue;

        var texts = ReadTexts(Path.Combine(directory, name), true);
        var joined = StringBuilder.Create();
        bool first = true;
        foreach (var text in texts.Values())
        {
            if (!first)
                joined.Append("\n");
            joined.Append(text);
            first = false;
        }
        uint32 key = ParseNumberName(name);
        if (result.ContainsKey(key))
            Fail($"An item with the same key has already been added. Key: {key}", ErrorCode.WrongFileNumbering);
        result[key] = joined.ToString();
        PrintDone();
    }

    return result;
}

// the keys of texts in their order
List<uint32> Keys(Dictionary<uint32, string> texts)
{
    var keys = List<uint32>.Create(texts.Count());
    foreach (var key in texts.Keys())
        keys.Add(key);
    keys.Sort();
    return keys;
}

int _CharacterBytes(uint8 b)
{
    return b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
}

int _DecodeAt(StringSlice text, int i, int length)
{
    if (i + length > text.Length)
        return text[i];
    int b = text[i];
    if (length == 1)
        return b;
    int value = b & (0xFF >> (length + 1));
    for (var k = 1; k < length; k += 1)
        value = (value << 6) | (text[i + k] & 0x3F);
    return value;
}

// the bytes of a text in a field of `size` bytes (SizeString of the original): without white space at its start
// (`trimStart`), filled up with 0s; a longer text is cut (with a warning) to `size - 1` characters and a 0
// (`needsTermNull`) or to `size` characters
uint8[] SizeString(int size, string text, bool trimStart, bool needsTermNull)
{
    string str = trimStart ? TrimStartNet(text).ToString() : text;
    int length = LengthNet(str);
    string sized;

    if (length < size)
        sized = str;
    else if (needsTermNull)
    {
        sized = FirstCharactersNet(str, size - 1).ToString();
        Console.WriteLine($"WARNING: String '{str}' was shortened to '{_TrimEndZeros(sized)}' because the max size is {size - 1} without terminating null.");
    }
    else
    {
        sized = FirstCharactersNet(str, size).ToString();
        if (length > size)
            Console.WriteLine($"WARNING: String '{str}' was shortened to '{sized}' because the max size is {size}.");
    }

    var bytes = AmbermoonEncoding.GetBytes(sized);
    var field = new uint8[size];
    Array.Copy(bytes, 0, field, 0, bytes.Length < size ? bytes.Length : size);
    return field;
}

string _TrimEndZeros(string text)
{
    int end = text.Length;
    while (end > 0 && text[end - 1] == 0)
        end -= 1;
    return text[0..end].ToString();
}

// writes a JH file: with -c the smaller of the best LOB compression and none, else LOB-compressed (`useLob`) or not
void WriteSingleFile(string outputFileName, uint8[] data, bool useLob)
{
    var writer = new DataWriter();
    bool written;

    if (NewCompression)
    {
        var compressed = new DataWriter();
        var plain = new DataWriter();
        written = FileWriter.WriteJH(ref compressed, data, 0xd2e7, true, false, LobType.TakeBest) is not error &&
                  FileWriter.WriteJH(ref plain, data, 0xd2e7, false) is not error;
        writer = compressed.Size() < plain.Size() ? compressed : plain;
    }
    else
        written = FileWriter.WriteJH(ref writer, data, 0xd2e7, useLob) is not error;

    if (!written || File.WriteAllBytes(outputFileName, writer.AsSlice()) is error)
    {
        Console.WriteLine($"Failed to write data to '{outputFileName}'.");
        Console.WriteLine();
        Exit(ErrorCode.UnableToWriteData);
    }
}

// writes the data of a file of the game data: nothing for no data, a message for a file that is not in the game data
void WriteGameDataFile(string containerFile, Error<Optional<uint8[]>> result)
{
    if (result is error e)
    {
        // (the original shows the exception with its stack trace)
        Console.WriteLine();
        Console.WriteLine("Failed: " + e.Message);
        Console.WriteLine();
        Exit(ErrorCode.UnableToWriteData);
        return;
    }

    if (result is not Optional<uint8[]> optional)
        return;

    if (optional is uint8[] data)
    {
        if (data.Length == 0)
            return;

        string outputFileName = Path.Combine(ImportGameDataPath, containerFile);
        if (File.WriteAllBytes(outputFileName, data) is error)
        {
            Console.WriteLine($"Failed to write data to '{outputFileName}'.");
            Console.WriteLine();
            Exit(ErrorCode.UnableToWriteData);
        }
    }
    else
    {
        Console.WriteLine($"{containerFile} was not found in target folder. Skipped it.");
        Console.WriteLine();
    }
}

Error<uint8[]> WriteContainerData(Dictionary<uint32, uint8[]> files, FileType fileType)
{
    // (the original: "The first file must have index 1 and not 0.", and Max() of no files)
    if (files.ContainsKey(0))
        return error("[Data] The first file must have index 1 and not 0.");
    if (files.Count() == 0)
        return error("Sequence contains no elements");

    var writer = new DataWriter();
    try FileWriter.WriteContainer(ref writer, files, fileType, null,
                                  NewCompression ? LobType.TakeBest : LobType.Ambermoon,
                                  NewCompression ? FileDictionaryCompression.UseBest : FileDictionaryCompression.None, null);
    return writer.ToArray();
}

void Import(string gameDataPath, string inputPath)
{
    ImportGameDataPath = gameDataPath;
    ImportInputPath = inputPath;

    CreateDirectoryOrExit(gameDataPath);

    // TODO: intro, outro, etc (as in the original)

    foreach (var dictionaryFile in DictionaryFiles)
    {
        if (CheckFile(dictionaryFile))
        {
            ImportDictionary(dictionaryFile);
            break;
        }
    }

    if (CheckFile("Text.amb"))
        ImportTextAmb();

    if (CheckFile("Monster_char.amb"))
        ImportCharNames("Monster_char.amb");
    else if (CheckFile("Monster_char_data.amb"))
        ImportCharNames("Monster_char_data.amb");
    if (CheckFile("Party_char.amb"))
        ImportCharNames("Save.00/Party_char.amb");
    if (CheckFile("NPC_char.amb"))
        ImportCharNames("NPC_char.amb");

    if (CheckFile("Place_data"))
        ImportPlaceNames();

    if (CheckFile("Objects.amb"))
        ImportItemNames();

    if (CheckFile("1Map_data.amb"))
        ImportGotoPointNames("1Map_data.amb");
    if (CheckFile("2Map_data.amb"))
        ImportGotoPointNames("2Map_data.amb");
    if (CheckFile("3Map_data.amb"))
        ImportGotoPointNames("3Map_data.amb");

    foreach (var file in TextContainerFiles)
    {
        if (CheckFile(file))
            ImportTextContainer(file);
    }
}

void ImportDictionary(string dictionaryFile)
{
    var texts = ReadTexts(dictionaryFile, true);
    var writer = new DataWriter();
    writer.WriteWord((uint16)texts.Count());

    foreach (var key in Keys(texts))
    {
        writer.WriteByte((uint8)(LengthNet(texts[key]) & 0xff));
        writer.WriteBytes(AmbermoonEncoding.GetBytes(texts[key]));
    }

    do
        writer.WriteByte(0);
    while (writer.Position() % 4 != 0);

    var containerWriter = new DataWriter();
    var written = FileWriter.WriteJH(ref containerWriter, writer.ToArray(), 0xd2e7, true, false,
                                     NewCompression ? LobType.TakeBestForText : LobType.Ambermoon);
    if (written is error && NewCompression)
    {
        // the text LOB cannot compress all data (the original ends with "Data can't be compressed with text lob")
        containerWriter = new DataWriter();
        written = FileWriter.WriteJH(ref containerWriter, writer.ToArray(), 0xd2e7, true, false, LobType.Ambermoon);
    }
    if (written is error e)
        WriteGameDataFile(dictionaryFile, error(e.Message));
    else
        WriteGameDataFile(dictionaryFile, (Optional<uint8[]>)containerWriter.ToArray());
    PrintDone();
}

void ImportTextAmb()
{
    var textContainer = TextContainer.Create();

    Console.WriteLine("Reading all texts from Text.amb.");

    ReadSection("Messages", textContainer.Messages);
    ReadSection("WorldNames", textContainer.WorldNames);
    ReadSection("FormatMessages", textContainer.FormatMessages);
    ReadSection("AutomapTypeNames", textContainer.AutomapTypeNames);
    ReadSection("OptionNames", textContainer.OptionNames);
    ReadSection("MusicNames", textContainer.MusicNames);
    ReadSection("SpellClassNames", textContainer.SpellClassNames);
    ReadSection("SpellNames", textContainer.SpellNames);
    ReadSection("LanguageNames", textContainer.LanguageNames);
    ReadSection("ClassNames", textContainer.ClassNames);
    ReadSection("RaceNames", textContainer.RaceNames);
    ReadSection("SkillNames", textContainer.SkillNames);
    ReadSection("AttributeNames", textContainer.AttributeNames);
    ReadSection("SkillShortNames", textContainer.SkillShortNames);
    ReadSection("AttributeShortNames", textContainer.AttributeShortNames);
    ReadSection("ItemTypeNames", textContainer.ItemTypeNames);
    ReadSection("ConditionNames", textContainer.ConditionNames);
    ReadSection("UITexts", textContainer.UITexts);
    var versionStrings = List<string>.Create();
    ReadSection("DateAndLanguageString", versionStrings);
    ReadSection("VersionString", versionStrings);
    if (versionStrings.Count() < 2)
        Fail("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')", ErrorCode.UnableToReadTextData);
    textContainer.DateAndLanguageString = versionStrings[0];
    textContainer.VersionString = versionStrings[1];

    string indexFilePath = Path.Combine(Path.Combine(Path.Combine(ImportInputPath, "Text.amb"), "UITexts"), PlaceholderIndexFile);
    if (File.ReadAllBytes(indexFilePath) is not uint8[] indexData)
    {
        Fail($"Could not find file '{Path.GetFullPath(indexFilePath)}'.", ErrorCode.UnableToReadTextData);
        return;
    }
    var indexReader = DataReader.FromData(indexData);
    int count = indexReader.ReadWord();
    for (var i = 0; i < count; i += 1)
        textContainer.UITextWithPlaceholderIndices.Add(indexReader.ReadWord());
    if (indexReader.Overrun())
        Fail("Specified argument was out of the range of valid values. (Parameter 'length')", ErrorCode.UnableToReadTextData);

    var writer = new DataWriter();
    if (TextContainerWriter.WriteTextContainer(textContainer, ref writer, false) is error writeError)
        Fail(writeError.Message, ErrorCode.UnableToTransformTexts);

    WriteSingleFile(Path.Combine(ImportGameDataPath, "Text.amb"), writer.ToArray(), true);
}

void ReadSection(string folderName, List<string> texts)
{
    var files = ReadTexts(Path.Combine("Text.amb", folderName), true);
    foreach (var key in Keys(files))
        texts.Add(files[key]);
    PrintDone();
}

void ImportCharNames(string filename)
{
    var entries = ReadTexts(filename, false);
    WriteGameDataFile(filename, PatchedCharacters(filename, entries));
    PrintDone();
}

Error<Optional<uint8[]>> PatchedCharacters(string filename, Dictionary<uint32, string> entries)
{
    var gameData = ImportGameData();
    if (gameData.Files.TryGet(filename) is not FileContainer container)
        return (Optional<uint8[]>)null;

    var files = Dictionary<uint32, uint8[]>.Create();
    foreach (var key in Keys(entries))
    {
        if (container.Files.TryGet((int)key) is not DataReader reader)
            return error($"The given key '{key}' was not present in the dictionary.");

        if (reader.Size() == 0)
        {
            files[key] = new uint8[0];
            continue;
        }

        var data = reader.ToArray();
        var writer = new DataWriter();
        writer.WriteBytes(data, 0, 0x0112 < data.Length ? 0x0112 : data.Length);
        writer.WriteBytes(SizeString(16, entries[key], true, true));
        if (data.Length > 0x0112 + 16)
            writer.WriteBytes(data, 0x0112 + 16, data.Length - 0x0112 - 16);
        files[key] = writer.ToArray();
    }

    bool party = ToLowerNet(Path.GetFileName(filename)).StartsWith("party");
    var containerData = try WriteContainerData(files, party ? FileType.AMBR : FileType.AMPC);
    return (Optional<uint8[]>)containerData;
}

void ImportPlaceNames()
{
    var entries = ReadTexts("Place_data", true);
    var gameData = ImportGameData();

    if (gameData.Files.TryGet("Place_data") is not FileContainer container)
        return;

    var file = container.Files[1];
    var data = file.ToArray();
    int placeCount = data.Length < 2 ? 0 : (data[0] << 8) | data[1];

    if (placeCount != entries.Count())
        Fail("Mismatching place data/text count.", ErrorCode.UnableToTransformTexts);

    var writer = new DataWriter();
    int header = 2 + placeCount * 32;
    writer.WriteBytes(data, 0, header < data.Length ? header : data.Length);
    for (uint32 i = 1; i <= (uint32)placeCount; i += 1)
        writer.WriteBytes(SizeString(30, entries[i], true, false));

    WriteSingleFile(Path.Combine(ImportGameDataPath, "Place_data"), writer.ToArray(), true);
    PrintDone();
}

void ImportItemNames()
{
    var entries = ReadTexts("Objects.amb", true);
    var gameData = ImportGameData();

    if (gameData.Files.TryGet("Objects.amb") is not FileContainer container)
        return;

    var reader = container.Files[1];
    reader.Position = 0;
    int itemCount = reader.ReadWord();

    if (itemCount != entries.Count())
        Fail("Mismatching item data/text count.", ErrorCode.UnableToTransformTexts);

    var writer = new DataWriter();
    writer.WriteWord((uint16)itemCount);
    for (uint32 i = 1; i <= (uint32)itemCount; i += 1)
    {
        writer.WriteBytes(reader.ReadBytes(40));
        reader.Position += 20;
        writer.WriteBytes(SizeString(20, entries[i], true, true));
    }
    if (reader.Overrun())
        Fail("Specified argument was out of the range of valid values. (Parameter 'length')", ErrorCode.UnableToTransformTexts);

    WriteSingleFile(Path.Combine(ImportGameDataPath, "Objects.amb"), writer.ToArray(), true);
    PrintDone();
}

void ImportGotoPointNames(string filename)
{
    var entries = ReadSubFolderTexts(filename);
    WriteGameDataFile(filename, PatchedGotoPoints(filename, entries));
}

Error<Optional<uint8[]>> PatchedGotoPoints(string filename, Dictionary<uint32, string> entries)
{
    if (entries.Count() == 0)
        return (Optional<uint8[]>)new uint8[0];

    var gameData = ImportGameData();
    if (gameData.Files.TryGet(filename) is not FileContainer container)
        return (Optional<uint8[]>)null;

    var files = Dictionary<uint32, uint8[]>.Create();

    foreach (var entry in container.Files.Entries())
    {
        var reader = entry.Value;
        uint32 key = (uint32)entry.Key;
        var data = reader.ToArray();

        if (reader.Size() == 0)
        {
            files[key] = new uint8[0];
            continue;
        }

        // 2D maps and maps without texts stay as they are
        if (!Is3DMap(reader))
        {
            files[key] = data;
            continue;
        }
        if (entries.TryGet(key) is not string nameString)
        {
            files[key] = data;
            continue;
        }

        var map = try MapReader.ReadMap(key, ref reader, null);
        var names = nameString.Split('\n');

        if (map.GotoPoints.Count() != names.Length)
            return error($"Mismatching goto point data/text count for map {key}.");

        if (map.GotoPoints.Count() == 0)
        {
            files[key] = data;
            continue;
        }

        // (the original computes where the goto points are without characters that move by the hour, which have 12
        // positions instead of 288)
        var gotoPoints = try MapReader.ReadGotoPoints(ref reader);
        int position = gotoPoints.Offset + 2;
        var writer = new DataWriter();
        writer.WriteBytes(data, 0, position);

        for (var i = 0; i < names.Length; i += 1)
        {
            writer.WriteBytes(data, position, 4);
            writer.WriteBytes(SizeString(16, names[i].ToString(), true, false));
            position += 20;
        }

        writer.WriteBytes(data, position, data.Length - position);
        files[key] = writer.ToArray();
    }

    var containerData = try WriteContainerData(files, FileType.AMPC);
    return (Optional<uint8[]>)containerData;
}

void ImportTextContainer(string file)
{
    var entries = ReadSubFolderTexts(file);
    WriteGameDataFile(file, PatchedTextContainer(file, entries));
}

Error<Optional<uint8[]>> PatchedTextContainer(string file, Dictionary<uint32, string> entries)
{
    if (entries.Count() == 0)
        return (Optional<uint8[]>)new uint8[0];

    var gameData = ImportGameData();
    if (!gameData.Files.ContainsKey(file))
        return (Optional<uint8[]>)null;

    var containerFiles = Dictionary<uint32, uint8[]>.Create();

    foreach (var key in Keys(entries))
    {
        var value = entries[key];
        if (value.Length == 0)
        {
            containerFiles[key] = new uint8[0];
            continue;
        }

        var texts = List<string>.Create();
        foreach (var text in value.Split('\n'))
            texts.Add(text.ToString());
        var writer = new DataWriter();
        TextWriter.WriteTexts(ref writer, texts, true, true, true);
        containerFiles[key] = writer.ToArray();
    }

    var containerData = try WriteContainerData(containerFiles, FileType.AMNP);
    return (Optional<uint8[]>)containerData;
}

// ---- -u ----

// the text without the marks of its letters ("á" becomes "a"): the letters decomposed (NFD), the non-spacing marks
// removed (as in the original with Normalize(FormD) and Normalize(FormC); here for Latin, Greek and Cyrillic letters)
string RemoveDiacritics(string text)
{
    var result = StringBuilder.Create();
    int i = 0;
    while (i < text.Length)
    {
        int length = _CharacterBytes(text[i]);
        if (i + length > text.Length)
            length = text.Length - i;
        int c = _DecodeAt(text, i, length);
        i += length;

        if (_IsNonSpacingMark(c))
            continue;
        int b = _BaseLetter(c);
        if (b == c)
            result.Append(text[i - length..i]);
        else
            result.Append(_Encode(b));
    }
    return result.ToString();
}

bool _IsNonSpacingMark(int c)
{
    int low = 0;
    int high = NonSpacingMarks.Length / 2 - 1;
    while (low <= high)
    {
        int middle = (low + high) / 2;
        if (c < NonSpacingMarks[middle * 2])
            high = middle - 1;
        else if (c > NonSpacingMarks[middle * 2 + 1])
            low = middle + 1;
        else
            return true;
    }
    return false;
}

int _BaseLetter(int c)
{
    int low = 0;
    int high = DecomposedCharacters.Length - 1;
    while (low <= high)
    {
        int middle = (low + high) / 2;
        if (c < DecomposedCharacters[middle])
            high = middle - 1;
        else if (c > DecomposedCharacters[middle])
            low = middle + 1;
        else
            return DecomposedBases[middle];
    }
    return c;
}

string _Encode(int c)
{
    var bytes = new uint8[4];
    int n;
    if (c < 0x80)
    {
        bytes[0] = (uint8)c;
        n = 1;
    }
    else if (c < 0x800)
    {
        bytes[0] = (uint8)(0xC0 | (c >> 6));
        bytes[1] = (uint8)(0x80 | (c & 0x3F));
        n = 2;
    }
    else
    {
        bytes[0] = (uint8)(0xE0 | (c >> 12));
        bytes[1] = (uint8)(0x80 | ((c >> 6) & 0x3F));
        bytes[2] = (uint8)(0x80 | (c & 0x3F));
        n = 3;
    }
    return string.FromBytes(bytes, 0, n);
}

string ReplaceSpecialLetters(string text)
{
    return text.Replace("œ", "oe").Replace("Œ", "OE").Replace("æ", "ae").Replace("Æ", "AE").Replace("ß", "ss")
               .Replace("ø", "o").Replace("Ø", "O").Replace("đ", "d").Replace("Đ", "D");
}
