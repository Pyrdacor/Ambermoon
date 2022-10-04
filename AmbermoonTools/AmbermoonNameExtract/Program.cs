using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;

enum NameType
{
    PartyMember,
    NPC,
    Monster,
    Place,
    GotoPoint,
    Dictionary,
    Item
}

public static class Program
{
    public static void Main(string[] args)
    {
        if (args.Length != 3 && args.Length != 4)
        {
            Usage();
        }
        else
        {
            if (args[0] == "e")
            {
                if (args.Length == 3)
                    ExportGameData(args[1], args[2]);
                else
                    Export(args[1], args[2], args[3]);
            }
            else if (args[0] == "i")
            {
                if (args.Length == 3)
                    ImportGameData(args[1], args[2]);
                else
                    Import(args[1], args[2], args[3]);
            }
            else
            {
                Console.WriteLine("Invalid command: " + args[0]);
                Usage();
            }
        }
    }

    static void Usage()
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

    static void ExportGameData(string gameDataPath, string targetDirectory)
    {
        var gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false, GameData.VersionPreference.Post114);

        gameData.Load(gameDataPath);

        Export(gameData.Files["Save.00/Party_char.amb"], Path.Combine(targetDirectory, "Party_char"), "0");
        Export(gameData.Files["NPC_char.amb"], Path.Combine(targetDirectory, "NPC_char"), "1");
        Export(gameData.Files["Monster_char.amb"], Path.Combine(targetDirectory, "Monster_char"), "2");
        Export(gameData.Files["Place_data"], Path.Combine(targetDirectory, "Place_data"), "3");
        Export(gameData.Files["2Map_data.amb"], Path.Combine(targetDirectory, "2Map_data"), "4");
        Export(gameData.Files["3Map_data.amb"], Path.Combine(targetDirectory, "3Map_data"), "4");
        Export(gameData.Files["Dict.amb"], Path.Combine(targetDirectory, "Dict"), "5");
        Export(gameData.Files["Objects.amb"], Path.Combine(targetDirectory, "Objects"), "6");
    }

    static void ImportGameData(string gameDataPath, string sourceDirectory)
    {
        var gameData = new GameData(GameData.LoadPreference.ForceExtracted, null, false, GameData.VersionPreference.Post114);

        gameData.Load(gameDataPath);

        Import(Path.Combine(gameDataPath, "Save.00", "Party_char.amb"), gameData.Files["Save.00/Party_char.amb"],
            Path.Combine(sourceDirectory, "Party_char"), "0");
        Import(Path.Combine(gameDataPath, "NPC_char.amb"), gameData.Files["NPC_char.amb"],
            Path.Combine(sourceDirectory, "NPC_char"), "1");
        Import(Path.Combine(gameDataPath, "Monster_char.amb"), gameData.Files["Monster_char.amb"],
            Path.Combine(sourceDirectory, "Monster_char"), "2");
        Import(Path.Combine(gameDataPath, "Place_data"), gameData.Files["Place_data"],
            Path.Combine(sourceDirectory, "Place_data"), "3");
        Import(Path.Combine(gameDataPath, "2Map_data.amb"), gameData.Files["2Map_data.amb"],
            Path.Combine(sourceDirectory, "2Map_data"), "4");
        Import(Path.Combine(gameDataPath, "3Map_data.amb"), gameData.Files["3Map_data.amb"],
            Path.Combine(sourceDirectory, "3Map_data"), "4");
        Import(Path.Combine(gameDataPath, "Dict.amb"), gameData.Files["Dict.amb"],
            Path.Combine(sourceDirectory, "Dict"), "5");
        Import(Path.Combine(gameDataPath, "Objects.amb"), gameData.Files["Objects.amb"],
            Path.Combine(sourceDirectory, "Objects"), "6");
    }

    static void Export(IFileContainer fileContainer, string targetDirectory, string type)
    {
        if (!int.TryParse(type, out int t))
        {
            Console.WriteLine("Invalid export type: " + type);
            Usage();
        }
        else
        {
            Dictionary<uint, string>? result;

            switch ((NameType)t)
            {
                case NameType.PartyMember:
                case NameType.NPC:
                case NameType.Monster:
                    result = ExtractCharacterNames(fileContainer);
                    break;
                case NameType.Place:
                    result = ExtractPlaceNames(fileContainer);
                    break;
                case NameType.GotoPoint:
                    result = ExtractGotoPoints(fileContainer);
                    break;
                case NameType.Dictionary:
                    result = ExtractDictionary(fileContainer);
                    break;
                case NameType.Item:
                    result = ExtractItemNames(fileContainer);
                    break;
                default:
                    Console.WriteLine("Invalid export type: " + t);
                    Usage();
                    return;
            }

            Directory.CreateDirectory(targetDirectory);

            foreach (var entry in result)
            {
                if (entry.Key > 0xffff)
                {
                    var subdir = Path.Combine(targetDirectory, (entry.Key >> 16).ToString("000"));
                    Directory.CreateDirectory(subdir);
                    var path = Path.Combine(subdir, $"{entry.Key & 0xffff:000}.txt");
                    File.WriteAllText(path, entry.Value);
                }
                else
                {
                    var path = Path.Combine(targetDirectory, $"{entry.Key:000}.txt");
                    File.WriteAllText(path, entry.Value);
                }
            }
        }
    }

    static void Export(string sourceFile, string targetDirectory, string type)
    {
        using var file = File.OpenRead(sourceFile);
        Export(new FileReader().ReadFile("", new DataReader(file)), targetDirectory, type);
    }

    static Dictionary<uint, string> ReadTexts(string directory)
    {
        return Directory.GetFiles(directory, "*.txt").ToDictionary
        (
            f => uint.Parse(Path.GetFileNameWithoutExtension(f)),
            f => File.ReadAllText(f)
        );
    }

    static readonly AmbermoonEncoding encoding = new AmbermoonEncoding();

    static string LimitText(string text, int maxLength, bool addSpaces)
    {
        string FillText()
        {
            if (!addSpaces)
                return text.PadRight(maxLength, '\0');

            int initialLength = text.Length;
            text = text.PadRight(maxLength, ' ');
            var bytes = encoding.GetBytes(text);
            bytes[initialLength] = 0;
            bytes[^1] = 0;
            return encoding.GetString(bytes);
        }

        return text.Length >= maxLength ? text.Substring(0, maxLength - 1) + "\0" : FillText();
    }

    static Dictionary<uint, string> ExtractCharacterNames(IFileContainer fileContainer)
    {
        var names = new Dictionary<uint, string>();

        foreach (var file in fileContainer.Files)
        {
            if (file.Value.Size == 0)
                continue;

            file.Value.Position = 0x112;
            names.Add((uint)file.Key, file.Value.ReadString(16).Trim('\0', ' '));
        }

        return names;
    }

    static readonly string[] CharTypeNames = new string[3]
    {
        "party member",
        "NPC",
        "monster"
    };

    static IDataWriter PatchCharacterNames(int charType, IFileContainer fileContainer, string sourceDirectory)
    {
        var names = ExtractCharacterNames(fileContainer);
        var patchNames = ReadTexts(sourceDirectory);
        var keys = names.Keys;

        foreach (var key in keys)
        {
            if (patchNames.TryGetValue(key, out var value))
                names[key] = value;
            else
            {
                Console.WriteLine($"Enter {CharTypeNames[charType]} name for '{names[key]}':");
                names[key] = Console.ReadLine()!;
            }
        }

        var files = new Dictionary<uint, byte[]>();

        foreach (var file in fileContainer.Files)
        {
            if (file.Value.Size == 0)
                continue;

            var writer = new DataWriter();
            file.Value.Position = 0;
            writer.Write(file.Value.ReadBytes(0x112));
            writer.WriteWithoutLength(LimitText(names[(uint)file.Key], 16, false));
            file.Value.Position += 16;
            writer.Write(file.Value.ReadToEnd());
            files.Add((uint)file.Key, writer.ToArray());
        }

        var containerWriter = new DataWriter();
        if (charType == 0)
            FileWriter.WriteContainer(containerWriter, files, FileType.AMBR);
        else
            //FileWriter.WriteContainer(containerWriter, files, FileType.AMNP);
            FileWriter.WriteContainer(containerWriter, files, FileType.AMBR);

        return containerWriter;
    }

    static Dictionary<uint, string> ExtractPlaceNames(IFileContainer fileContainer)
    {
        var places = Places.Load(new PlacesReader(), fileContainer.Files[1]);

        return places.Entries.Select((e, i) => new { e, i }).ToDictionary(e => (uint)e.i, e => e.e.Name);
    }

    static IDataWriter PatchPlaceNames(IFileContainer fileContainer, string sourceDirectory)
    {
        var names = ExtractPlaceNames(fileContainer);
        var patchNames = ReadTexts(sourceDirectory);
        var keys = names.Keys;

        foreach (var key in keys)
        {
            if (patchNames.TryGetValue(key, out var value))
                names[key] = value;
            else
            {
                Console.WriteLine($"Enter place name for '{names[key]}':");
                names[key] = Console.ReadLine()!;
            }
        }

        var writer = new DataWriter();
        fileContainer.Files[1].Position = 0;
        writer.Write(fileContainer.Files[1].ReadBytes(2 + names.Count * 32));

        var sortedNames = new SortedDictionary<uint, string>(names);

        foreach (var name in sortedNames)
            writer.WriteWithoutLength(LimitText(name.Value, 30, false));

        var containerWriter = new DataWriter();
        FileWriter.WriteJH(containerWriter, writer.ToArray(), 0xd2e7, true);

        return containerWriter;
    }

    static Dictionary<uint, string> ExtractGotoPoints(IFileContainer fileContainer)
    {
        var names = new Dictionary<uint, string>();

        foreach (var file in fileContainer.Files)
        {
            if (file.Value.Size == 0)
                continue;

            var gotoPoints = MapReader.ReadGotoPoints(file.Value);
            uint index = (uint)file.Key << 16;

            foreach (var gotoPoint in gotoPoints)
                names.Add(index++, gotoPoint.Name.Trim('\0', ' '));
        }

        return names;
    }

    static IDataWriter PatchGotoPoints(IFileContainer fileContainer, string sourceDirectory)
    {
        var names = ExtractGotoPoints(fileContainer);
        var files = new Dictionary<uint, byte[]>();

        foreach (var file in fileContainer.Files)
        {
            if (file.Value.Size == 0)
                continue;

            var writer = new DataWriter();
            file.Value.Position = 0;

            if (names.Any(n => (n.Key >> 16) == file.Key))
            {
                var patchNames = ReadTexts(Path.Combine(sourceDirectory, $"{file.Key:000}"));
                var keys = names.Keys.Where(k => (k >> 16) == file.Key);

                foreach (var key in keys)
                {
                    if (patchNames.TryGetValue(key & 0xffff, out var value))
                        names[key] = value;
                    else
                    {
                        Console.WriteLine($"Enter goto point name for '{names[key]}':");
                        names[key] = Console.ReadLine()!;
                    }
                }

                var sortedNames = new SortedDictionary<uint, string>(names.Where(n => (n.Key >> 16) == file.Key)
                    .ToDictionary(n => n.Key, n => n.Value)).ToList();

                int gotoPointOffset = MapReader.GetGotoPointOffset(file.Value);
                file.Value.Position = 2;
                writer.Write(file.Value.ReadBytes(gotoPointOffset));
                writer.Write((ushort)sortedNames.Count);
                for (int i = 0; i < sortedNames.Count; ++i)
                {
                    writer.Write(file.Value.ReadBytes(4));
                    writer.WriteWithoutLength(LimitText(sortedNames[i].Value, 16, false));
                    file.Value.Position += 16;
                }            
            }
            else
            {
                writer.Write(file.Value.ReadToEnd());
            }

            files.Add((uint)file.Key, writer.ToArray());
        }

        var containerWriter = new DataWriter();
        //FileWriter.WriteContainer(containerWriter, files, FileType.AMNP);
        FileWriter.WriteContainer(containerWriter, files, FileType.AMBR);

        return containerWriter;
    }

    static Dictionary<uint, string> ExtractDictionary(IFileContainer fileContainer)
    {
        var dictionary = TextDictionary.Load(new TextDictionaryReader(), KeyValuePair.Create("", fileContainer.Files[1]));

        return dictionary.Entries.Select((e, i) => new { e, i }).ToDictionary(e => (uint)e.i, e => e.e);
    }

    static IDataWriter PatchDictionary(IFileContainer fileContainer, string sourceDirectory)
    {
        var names = ExtractDictionary(fileContainer);
        var patchNames = ReadTexts(sourceDirectory);
        var keys = names.Keys;

        foreach (var key in keys)
        {
            if (patchNames.TryGetValue(key, out var value))
                names[key] = value;
            else
            {
                Console.WriteLine($"Enter dictionary entry for '{names[key]}':");
                names[key] = Console.ReadLine()!;
            }
        }

        var writer = new DataWriter();
        var sortedNames = new SortedDictionary<uint, string>(names);

        writer.Write((ushort)names.Count);

        foreach (var name in sortedNames)
            writer.Write(name.Value);

        var containerWriter = new DataWriter();
        //FileWriter.WriteJH(containerWriter, writer.ToArray(), 0xd2e7, true);
        containerWriter.Write(writer.ToArray());

        return containerWriter;
    }

    static Dictionary<uint, string> ExtractItemNames(IFileContainer fileContainer)
    {
        var names = new Dictionary<uint, string>();
        var reader = fileContainer.Files[1];
        int itemCount = reader.ReadWord();
        var itemReader = new ItemReader();

        for (uint i = 1; i <= itemCount; ++i) // in original Ambermoon there are 402 items
            names.Add(i, Item.Load(i, itemReader, reader).Name.Trim('\0', ' '));

        return names;
    }

    static IDataWriter PatchItemNames(IFileContainer fileContainer, string sourceDirectory)
    {
        var names = ExtractItemNames(fileContainer);
        var patchNames = ReadTexts(sourceDirectory);
        var keys = names.Keys;

        foreach (var key in keys)
        {
            if (patchNames.TryGetValue(key, out var value))
                names[key] = value;
            else
            {
                Console.WriteLine($"Enter item name for '{names[key]}':");
                names[key] = Console.ReadLine()!;
            }
        }

        var writer = new DataWriter();
        var sortedNames = new SortedDictionary<uint, string>(names).ToList();
        fileContainer.Files[1].Position = 2;
        writer.Write((ushort)sortedNames.Count);

        for (int i = 0; i < sortedNames.Count; ++i)
        {
            writer.Write(fileContainer.Files[1].ReadBytes(40));
            writer.WriteWithoutLength(LimitText(sortedNames[i].Value, 20, false));
            fileContainer.Files[1].Position += 20;
        }

        var containerWriter = new DataWriter();
        //FileWriter.WriteJH(containerWriter, writer.ToArray(), 0xd2e7, true);
        containerWriter.Write(writer.ToArray());

        return containerWriter;
    }

    static void Import(string targetFile, string sourceDirectory, string type)
    {
        using (var file = File.OpenRead(targetFile))
        {
            Import(targetFile, new FileReader().ReadFile("", new DataReader(file)), sourceDirectory, type);
        }
    }

    static void Import(string targetFile, IFileContainer fileContainer, string sourceDirectory, string type)
    {
        IDataWriter? dataWriter = Import(fileContainer, sourceDirectory, type);

        if (dataWriter == null)
            return;

        var tempFileName = Path.GetTempFileName();
        using (var tempFile = File.Create(tempFileName))
        {
            dataWriter.CopyTo(tempFile);
        }

        if (File.Exists(targetFile + ".backup"))
            File.Delete(targetFile + ".backup");

        File.Move(targetFile, targetFile + ".backup");
        File.Move(tempFileName, targetFile);
    }

    static IDataWriter? Import(IFileContainer fileContainer, string sourceDirectory, string type)
    {
        if (!int.TryParse(type, out int t))
        {
            Console.WriteLine("Invalid import type: " + type);
            Usage();
            return null;
        }
        else
        {
            IDataWriter? result;

            switch ((NameType)t)
            {
                case NameType.PartyMember:
                    result = PatchCharacterNames(0, fileContainer, sourceDirectory);
                    break;
                case NameType.NPC:
                    result = PatchCharacterNames(1, fileContainer, sourceDirectory);
                    break;
                case NameType.Monster:
                    result = PatchCharacterNames(2, fileContainer, sourceDirectory);
                    break;
                case NameType.Place:
                    result = PatchPlaceNames(fileContainer, sourceDirectory);
                    break;
                case NameType.GotoPoint:
                    result = PatchGotoPoints(fileContainer, sourceDirectory);
                    break;
                case NameType.Dictionary:
                    result = PatchDictionary(fileContainer, sourceDirectory);
                    break;
                case NameType.Item:
                    result = PatchItemNames(fileContainer, sourceDirectory);
                    break;
                default:
                    Console.WriteLine("Invalid import type: " + t);
                    Usage();
                    return null;
            }

            return result;
        }
    }
}
