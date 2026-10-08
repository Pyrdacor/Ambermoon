//! AmbermoonNameExtract: exports the names of the game (party members, NPCs, monsters, places, goto points, the
//! dictionary, items) into text files and imports them again (a port of AmbermoonTools/AmbermoonNameExtract).
//!
//!   AmbermoonNameExtract e <container> <outdir> <type>
//!   AmbermoonNameExtract i <container> <srcdir> <type>
//!   AmbermoonNameExtract e <gamedatapath> <outdir>
//!   AmbermoonNameExtract i <gamedatapath> <srcdir>
namespace AmbermoonNameExtract;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

enum NameType : int
{
    PartyMember,
    NPC,
    Monster,
    Place,
    GotoPoint,
    Dictionary,
    Item
}

const ReadOnlySlice<string> CharTypeNames = ["party member", "NPC", "monster"];

// where the name of a character is in its data
const int CharacterNameOffset = 0x112;

int Main(string[] args)
{
    if (args.Length != 3 && args.Length != 4)
    {
        Usage();
        return 0;
    }

    Error<void> result;

    if (args[0] == "e")
        result = args.Length == 3 ? ExportGameData(args[1], args[2]) : ExportFile(args[1], args[2], args[3]);
    else if (args[0] == "i")
        result = args.Length == 3 ? ImportGameData(args[1], args[2]) : ImportFile(args[1], args[2], args[3]);
    else
    {
        Console.WriteLine("Invalid command: " + args[0]);
        Usage();
        return 0;
    }

    // (the original ends with an exception in these cases)
    if (result is error e)
    {
        Console.WriteLine(e.Message);
        return 1;
    }
    return 0;
}

void Usage()
{
    Console.WriteLine("Usage: AmbermoonNameExtract e <container> <outdir> <type>");
    Console.WriteLine("       AmbermoonNameExtract i <container> <srcdir> <type>");
    Console.WriteLine("       AmbermoonNameExtract e <gamedatapath> <outdir>");
    Console.WriteLine("       AmbermoonNameExtract i <gamedatapath> <srcdir>");
    Console.WriteLine("");
    Console.WriteLine("First version exports names from a container to an output directory.");
    Console.WriteLine("Second version re-imports names from a directory into the container.");
    Console.WriteLine("Third version exports all names from game data to an output directory.");
    Console.WriteLine("Fourth version re-imports all names from a directory into the extracted game data.");
    Console.WriteLine("");
    Console.WriteLine("Types:");
    Console.WriteLine(" 0: Party member");
    Console.WriteLine(" 1: NPC");
    Console.WriteLine(" 2: Monster");
    Console.WriteLine(" 3: Place");
    Console.WriteLine(" 4: Goto point");
    Console.WriteLine(" 5: Dictionary");
    Console.WriteLine(" 6: Item");
    Console.WriteLine("");
}

// ---- the files of the game data ----

// the containers of the game data with the names and the folders of their texts, with the type of names
const ReadOnlySlice<string> GameDataFiles =
[
    "Save.00/Party_char.amb", "NPC_char.amb", "Monster_char.amb", "Place_data", "2Map_data.amb", "3Map_data.amb",
    "Dict.amb", "Objects.amb"
];
const ReadOnlySlice<string> GameDataFolders =
[
    "Party_char", "NPC_char", "Monster_char", "Place_data", "2Map_data", "3Map_data", "Dict", "Objects"
];
const ReadOnlySlice<string> GameDataTypes = ["0", "1", "2", "3", "4", "4", "5", "6"];

// a file of the game data (for the original's KeyNotFoundException)
Error<FileContainer> GameDataFile(GameData gameData, string name)
{
    if (gameData.Files.TryGet(name) is not FileContainer container)
        return error($"The given key '{name}' was not present in the dictionary.");
    return container;
}

Error<void> ExportGameData(string gameDataPath, string targetDirectory)
{
    var gameData = GameData.Create(LoadPreference.PreferExtracted, false, VersionPreference.Post114);
    try gameData.Load(gameDataPath);

    for (var i = 0; i < GameDataFiles.Length; i += 1)
    {
        var container = try GameDataFile(gameData, GameDataFiles[i]);
        try Export(container, Path.Combine(targetDirectory, GameDataFolders[i]), GameDataTypes[i]);
    }
    return;
}

Error<void> ImportGameData(string gameDataPath, string sourceDirectory)
{
    var gameData = GameData.Create(LoadPreference.ForceExtracted, false, VersionPreference.Post114);
    try gameData.Load(gameDataPath);

    for (var i = 0; i < GameDataFiles.Length; i += 1)
    {
        var container = try GameDataFile(gameData, GameDataFiles[i]);
        try Import(Path.Combine(gameDataPath, GameDataFiles[i]), container, Path.Combine(sourceDirectory, GameDataFolders[i]),
                   GameDataTypes[i]);
    }
    return;
}

// the container of a file
Error<FileContainer> ReadContainer(string path)
{
    if (File.ReadAllBytes(path) is not uint8[] data)
        return error($"Could not find file '{Path.GetFullPath(path)}'.");
    return FileReader.ReadFile("", DataReader.FromData(data));
}

// the type of names; null (after the message and the usage) if it is none
Optional<NameType> ParseType(string type, string what)
{
    if (ParseInt(type) is not int t)
    {
        Console.WriteLine($"Invalid {what} type: " + type);
        Usage();
        return null;
    }
    if (t < 0 || t > (int)NameType.Item)
    {
        Console.WriteLine($"Invalid {what} type: " + t.ToString());
        Usage();
        return null;
    }
    return (NameType)t;
}

// ---- export ----

Error<void> ExportFile(string sourceFile, string targetDirectory, string type)
{
    var container = try ReadContainer(sourceFile);
    return Export(container, targetDirectory, type);
}

Error<void> Export(FileContainer fileContainer, string targetDirectory, string type)
{
    if (ParseType(type, "export") is not NameType nameType)
        return;

    var names = try ExtractNames(fileContainer, nameType);

    if (!Directory.Create(targetDirectory))
        return error($"Could not create the folder '{targetDirectory}'.");

    foreach (var entry in names.Entries())
    {
        string path;
        if (entry.Key > 0xffff)
        {
            var subdirectory = Path.Combine(targetDirectory, Number3(entry.Key >> 16));
            if (!Directory.Create(subdirectory))
                return error($"Could not create the folder '{subdirectory}'.");
            path = Path.Combine(subdirectory, Number3(entry.Key & 0xffff) + ".txt");
        }
        else
            path = Path.Combine(targetDirectory, Number3(entry.Key) + ".txt");

        if (File.WriteAllText(path, entry.Value) is error)
            return error($"Could not write file '{path}'.");
    }
    return;
}

// a number with at least 3 digits
string Number3(uint32 number)
{
    return number.ToString().PadLeft(3, '0');
}

Error<Dictionary<uint32, string>> ExtractNames(FileContainer fileContainer, NameType nameType)
{
    switch (nameType)
    {
        case NameType.PartyMember:
        case NameType.NPC:
        case NameType.Monster:
            return ExtractCharacterNames(fileContainer);
        case NameType.Place:
            return ExtractPlaceNames(fileContainer);
        case NameType.GotoPoint:
            return ExtractGotoPoints(fileContainer);
        case NameType.Dictionary:
            return ExtractDictionary(fileContainer);
        default:
            return ExtractItemNames(fileContainer);
    }
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

Error<DataReader> File1(FileContainer fileContainer)
{
    if (fileContainer.Files.TryGet(1) is not DataReader reader)
        return error("The given key '1' was not present in the dictionary.");
    // (the original reads from where the reader is: after loading the game data that is its end)
    reader.Position = 0;
    return reader;
}

Error<Dictionary<uint32, string>> ExtractCharacterNames(FileContainer fileContainer)
{
    var names = Dictionary<uint32, string>.Create();

    foreach (var file in fileContainer.Files.Entries())
    {
        var reader = file.Value;
        if (reader.Size() == 0)
            continue;

        reader.Position = CharacterNameOffset;
        names[(uint32)file.Key] = TrimNamePadding(reader.ReadString(16));
        if (reader.Overrun())
            return error("[Data] Invalid character data.");
    }

    return names;
}

Error<Dictionary<uint32, string>> ExtractPlaceNames(FileContainer fileContainer)
{
    var reader = try File1(fileContainer);
    var names = Dictionary<uint32, string>.Create();
    int count = reader.ReadWord();
    reader.Position += count * 32;

    for (var i = 0; i < count; i += 1)
        names[(uint32)i] = TrimNamePadding(reader.ReadString(30));

    if (reader.Overrun())
        return error("[Data] Invalid place data.");
    return names;
}

Error<Dictionary<uint32, string>> ExtractGotoPoints(FileContainer fileContainer)
{
    var names = Dictionary<uint32, string>.Create();

    foreach (var file in fileContainer.Files.Entries())
    {
        var reader = file.Value;
        if (reader.Size() == 0)
            continue;

        var gotoPoints = try MapReader.ReadGotoPoints(ref reader);
        uint32 index = (uint32)file.Key << 16;

        foreach (var gotoPoint in gotoPoints.GotoPoints)
        {
            names[index] = TrimNamePadding(gotoPoint.Name);
            index += 1;
        }
    }

    return names;
}

Error<Dictionary<uint32, string>> ExtractDictionary(FileContainer fileContainer)
{
    var reader = try File1(fileContainer);
    var names = Dictionary<uint32, string>.Create();
    int count = reader.ReadWord();

    for (var i = 0; i < count; i += 1)
        names[(uint32)i] = reader.ReadLengthPrefixedString();

    if (reader.Overrun())
        return error("[Data] Invalid dictionary data.");
    return names;
}

Error<Dictionary<uint32, string>> ExtractItemNames(FileContainer fileContainer)
{
    var reader = try File1(fileContainer);
    var names = Dictionary<uint32, string>.Create();
    int itemCount = reader.ReadWord();

    for (uint32 i = 1; i <= (uint32)itemCount; i += 1) // in original Ambermoon there are 402 items
    {
        var item = try ItemReader.ReadItem(i, ref reader);
        names[i] = TrimNamePadding(item.Name);
    }

    return names;
}

// ---- import ----

// the keys of the names in their order
List<uint32> KeyList(Dictionary<uint32, string> names)
{
    var keys = List<uint32>.Create(names.Count());
    foreach (var key in names.Keys())
        keys.Add(key);
    return keys;
}

// the texts of the files *.txt of a folder by the numbers of their names
Error<Dictionary<uint32, string>> ReadTexts(string directory)
{
    if (!Directory.Exists(directory))
        return error($"Could not find a part of the path '{Path.GetFullPath(directory)}'.");

    var texts = Dictionary<uint32, string>.Create();

    foreach (var file in FindFiles(directory, "*.txt", false))
    {
        string stem = Path.GetStem(file);
        if (ParseUInt(stem) is not uint32 key)
            return error($"The input string '{stem}' was not in a correct format.");
        if (texts.ContainsKey(key))
            return error($"An item with the same key has already been added. Key: {key}");
        if (ReadAllTextNet(file) is not string text)
            return error($"Could not find file '{Path.GetFullPath(file)}'.");
        texts[key] = text;
    }

    return texts;
}

// the names with those of the texts; the others are asked for
Error<void> PatchNames(Dictionary<uint32, string> names, Dictionary<uint32, string> patchNames, List<uint32> keys,
                       uint32 patchKeyMask, string what)
{
    foreach (var key in keys)
    {
        if (patchNames.TryGet(key & patchKeyMask) is string value)
            names[key] = value;
        else
        {
            Console.WriteLine($"Enter {what} for '{names[key]}':");
            // (the original ends with an exception at the end of the input; nothing is written)
            if (Console.ReadLine() is not string line)
                return error("The input ended.");
            names[key] = line;
        }
    }
    return;
}

// the bytes of a name in a field of `maxLength` bytes: at most `maxLength - 1` characters (the last byte is a zero),
// filled up with zeros
uint8[] LimitText(string text, int maxLength)
{
    return _FieldBytes(text, maxLength, maxLength - 1);
}

uint8[] _FieldBytes(string text, int fieldLength, int maxCharacters)
{
    // the characters (one byte each in the encoding)
    var bytes = AmbermoonEncoding.GetBytes(text);
    var field = new uint8[fieldLength];
    int length = bytes.Length < maxCharacters ? bytes.Length : maxCharacters;
    Array.Copy(bytes, 0, field, 0, length);
    return field;
}

Error<void> ImportFile(string targetFile, string sourceDirectory, string type)
{
    var container = try ReadContainer(targetFile);
    return Import(targetFile, container, sourceDirectory, type);
}

// replaces the file by the one with the imported names; the old one is kept as <file>.backup
Error<void> Import(string targetFile, FileContainer fileContainer, string sourceDirectory, string type)
{
    if (ParseType(type, "import") is not NameType nameType)
        return;

    var data = try PatchedData(fileContainer, sourceDirectory, nameType);
    string backupFile = targetFile + ".backup";

    if (File.Copy(targetFile, backupFile, true) is error)
        return error($"Could not write file '{backupFile}'.");
    if (File.WriteAllBytes(targetFile, data) is error)
        return error($"Could not write file '{targetFile}'.");
    return;
}

Error<uint8[]> PatchedData(FileContainer fileContainer, string sourceDirectory, NameType nameType)
{
    switch (nameType)
    {
        case NameType.PartyMember:
        case NameType.NPC:
        case NameType.Monster:
            return PatchCharacterNames((int)nameType, fileContainer, sourceDirectory);
        case NameType.Place:
            return PatchPlaceNames(fileContainer, sourceDirectory);
        case NameType.GotoPoint:
            return PatchGotoPoints(fileContainer, sourceDirectory);
        case NameType.Dictionary:
            return PatchDictionary(fileContainer, sourceDirectory);
        default:
            return PatchItemNames(fileContainer, sourceDirectory);
    }
}

// the bytes of a part of the data (zeros behind its end)
uint8[] Bytes(uint8[] data, int start, int count)
{
    var bytes = new uint8[count < 0 ? 0 : count];
    for (var i = 0; i < bytes.Length; i += 1)
        bytes[i] = start + i >= 0 && start + i < data.Length ? data[start + i] : (uint8)0;
    return bytes;
}

// the bytes of the data from `start` to its end
uint8[] Rest(uint8[] data, int start)
{
    return start >= data.Length ? new uint8[0] : Bytes(data, start, data.Length - start);
}

Error<uint8[]> PatchCharacterNames(int charType, FileContainer fileContainer, string sourceDirectory)
{
    var names = try ExtractCharacterNames(fileContainer);
    var patchNames = try ReadTexts(sourceDirectory);
    try PatchNames(names, patchNames, KeyList(names), 0xffffffff, CharTypeNames[charType] + " name");

    var files = Dictionary<uint32, uint8[]>.Create();

    foreach (var file in fileContainer.Files.Entries())
    {
        if (file.Value.Size() == 0)
            continue;

        var data = file.Value.ToArray();
        var writer = new DataWriter();
        writer.WriteBytes(Bytes(data, 0, CharacterNameOffset));
        writer.WriteBytes(LimitText(names[(uint32)file.Key], 16));
        writer.WriteBytes(Rest(data, CharacterNameOffset + 16));
        files[(uint32)file.Key] = writer.ToArray();
    }

    var containerWriter = new DataWriter();
    try FileWriter.WriteContainer(ref containerWriter, files, FileType.AMBR);
    return containerWriter.ToArray();
}

Error<uint8[]> PatchPlaceNames(FileContainer fileContainer, string sourceDirectory)
{
    var names = try ExtractPlaceNames(fileContainer);
    var patchNames = try ReadTexts(sourceDirectory);
    var keys = KeyList(names);
    try PatchNames(names, patchNames, keys, 0xffffffff, "place name");

    var reader = try File1(fileContainer);
    var writer = new DataWriter();
    writer.WriteBytes(Bytes(reader.ToArray(), 0, 2 + names.Count() * 32));

    keys.Sort();
    // (the original keeps at most 29 characters: a place name of 30 characters, which the game has, loses its last)
    foreach (var key in keys)
        writer.WriteBytes(_FieldBytes(names[key], 30, 30));

    var containerWriter = new DataWriter();
    try FileWriter.WriteJH(ref containerWriter, writer.ToArray(), 0xd2e7, true);
    return containerWriter.ToArray();
}

Error<uint8[]> PatchGotoPoints(FileContainer fileContainer, string sourceDirectory)
{
    var names = try ExtractGotoPoints(fileContainer);
    var files = Dictionary<uint32, uint8[]>.Create();

    foreach (var file in fileContainer.Files.Entries())
    {
        if (file.Value.Size() == 0)
            continue;

        var data = file.Value.ToArray();
        var keys = List<uint32>.Create();
        foreach (var key in names.Keys())
        {
            if ((key >> 16) == (uint32)file.Key)
                keys.Add(key);
        }

        if (keys.Count() == 0)
        {
            files[(uint32)file.Key] = data;
            continue;
        }

        var patchNames = try ReadTexts(Path.Combine(sourceDirectory, Number3((uint32)file.Key)));
        try PatchNames(names, patchNames, keys, 0xffff, "goto point name");
        keys.Sort();

        var reader = file.Value;
        var gotoPoints = try MapReader.ReadGotoPoints(ref reader);
        int offset = gotoPoints.Offset;

        // (the original drops the first two bytes of the map and the automap types of 3D maps behind the goto points,
        // which breaks the maps)
        var writer = new DataWriter();
        writer.WriteBytes(Bytes(data, 0, offset));
        writer.WriteWord((uint16)keys.Count());
        int position = offset + 2;
        foreach (var key in keys)
        {
            writer.WriteBytes(Bytes(data, position, 4));
            writer.WriteBytes(LimitText(names[key], 16));
            position += 20;
        }
        writer.WriteBytes(Rest(data, position));
        files[(uint32)file.Key] = writer.ToArray();
    }

    var containerWriter = new DataWriter();
    try FileWriter.WriteContainer(ref containerWriter, files, FileType.AMBR);
    return containerWriter.ToArray();
}

Error<uint8[]> PatchDictionary(FileContainer fileContainer, string sourceDirectory)
{
    var names = try ExtractDictionary(fileContainer);
    var patchNames = try ReadTexts(sourceDirectory);
    var keys = KeyList(names);
    try PatchNames(names, patchNames, keys, 0xffffffff, "dictionary entry");

    var writer = new DataWriter();
    writer.WriteWord((uint16)names.Count());
    keys.Sort();

    foreach (var key in keys)
    {
        var bytes = AmbermoonEncoding.GetBytes(names[key]);
        if (bytes.Length > 255)
            return error("[Data] Strings must not exceed 255 characters.");
        writer.WriteByte((uint8)bytes.Length);
        writer.WriteBytes(bytes);
    }

    // (raw: the original does not encrypt it either)
    return writer.ToArray();
}

Error<uint8[]> PatchItemNames(FileContainer fileContainer, string sourceDirectory)
{
    var names = try ExtractItemNames(fileContainer);
    var patchNames = try ReadTexts(sourceDirectory);
    var keys = KeyList(names);
    try PatchNames(names, patchNames, keys, 0xffffffff, "item name");

    var data = (try File1(fileContainer)).ToArray();
    var writer = new DataWriter();
    writer.WriteWord((uint16)keys.Count());
    keys.Sort();

    int position = 2;
    foreach (var key in keys)
    {
        writer.WriteBytes(Bytes(data, position, 40));
        writer.WriteBytes(LimitText(names[key], 20));
        position += 60;
    }

    return writer.ToArray();
}
