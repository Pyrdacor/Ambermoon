//! AmbermoonMonsterEditor: shows and changes values of the monsters in Monster_char_data.amb (Monster_char.amb since
//! version 1.14) of the game data in the current folder (a port of AmbermoonTools/AmbermoonMonsterEditor).
//!
//!   AmbermoonMonsterEditor --list
//!   AmbermoonMonsterEditor <monsterIdOrName> <offset> <size> [<value>]
//!   AmbermoonMonsterEditor --all <offset> <size>
//!   AmbermoonMonsterEditor --all-not-0 <offset> <size>
namespace AmbermoonMonsterEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Characters;
using Ambermoon.Data.Legacy.Serialization;

enum ErrorCode : int
{
    NoError,
    InvalidNumberOfArguments,
    InvalidOptions,
    UnableToLoadGameData,
    UnableToLoadMonsters,
    NoMonsterWithIdOrName,
    InvalidArgumentFormat,
    ArgumentOutOfRange,
    UnableToCreateBackup
}

/// The monster files of the game data and the monsters in them.
struct Monsters
{
    /// Monster_char_data.amb or Monster_char.amb
    string FileName;
    /// All files of the container by their number (also the empty ones).
    Dictionary<int, DataReader> Files;
    /// The numbers of the monsters (the files that are not empty) and their names, in the order of the container.
    List<int> Indices;
    List<string> Names;
}

/// The size of the data of a monster.
const int MonsterDataSize = 810;

void Usage()
{
    Console.WriteLine("USAGE: AmbermoonMonsterEditor --list");
    Console.WriteLine("       AmbermoonMonsterEditor <monsterIdOrName> <offset> <size>");
    Console.WriteLine("       AmbermoonMonsterEditor <monsterIdOrName> <offset> <size> <value>");
    Console.WriteLine("       AmbermoonMonsterEditor --all <offset> <size>");
    Console.WriteLine("       AmbermoonMonsterEditor --all-not-0 <offset> <size>");
    Console.WriteLine();
    Console.WriteLine("1st version shows all monsters with their id and name.");
    Console.WriteLine("2nd version shows a value at the given offset with a given size.");
    Console.WriteLine("3rd version changes a value at the given offset.");
    Console.WriteLine("4th version list the value for all monsters.");
    Console.WriteLine();
    Console.WriteLine("The <monsterIdOrName> param is case-insensitive.");
    Console.WriteLine("The <offset> param is in bytes and can be decimal or hex (with 0x prefix).");
    Console.WriteLine("The <size> param is in bytes. So possible values are 1, 2 and 4.");
    Console.WriteLine("The <value> param can be decimal or hex (add the prefix 0x then).");
    Console.WriteLine();
    Console.WriteLine("Example 1: Show portrait index of spider");
    Console.WriteLine("-> AmbermoonMonsterValueChanger Spider 9 2");
    Console.WriteLine("Example 2: Set gold amount of zombie master to 1000");
    Console.WriteLine("-> AmbermoonMonsterValueChanger \"ZOMBIE MASTER\" 0x18 2 1000");
    Console.WriteLine("Example 3: Set combat attack damage of bandit to 32");
    Console.WriteLine("-> AmbermoonMonsterValueChanger bandit 0xda 2 0x20");
    Console.WriteLine();
}

void Exit(ErrorCode errorCode)
{
    Environment.Exit((int)errorCode);
}

// the game data of the current folder (the original looks into the folder of the program first)
GameData LoadGameData()
{
    var gameData = GameData.Create();

    if (gameData.Load(Directory.GetCurrentDirectory()) is error loadError)
    {
        // the original tells "not found" exceptions apart from the others
        var message = loadError.Message;
        if (message.StartsWith("Unable to find") || message.StartsWith("Unabled to find") ||
            message.StartsWith("Given data folder"))
            Console.WriteLine("Unable to load game data. Ensure you run this tool next to Ambermoon game data files.");
        else
            Console.WriteLine("Unable to load game data: " + message);
        Exit(ErrorCode.UnableToLoadGameData);
    }

    return gameData;
}

// the monsters of the game data; empty files are no monsters (the original fails at them: the monster files of the
// game have empty ones)
Monsters LoadMonsters()
{
    var gameData = LoadGameData();
    string fileName = "Monster_char_data.amb";
    var container = gameData.Files.TryGet(fileName);

    if (container == null)
    {
        fileName = "Monster_char.amb";
        container = gameData.Files.TryGet(fileName);
    }

    if (container is not FileContainer monsterContainer)
    {
        Console.WriteLine("Unable to load monsters from game data. Is Monster_char_data.amb present in the game data files?");
        Exit(ErrorCode.UnableToLoadMonsters);
        return Monsters { };
    }

    var monsters = Monsters
    {
        FileName = fileName,
        Files = monsterContainer.Files,
        Indices = List<int>.Create(),
        Names = List<string>.Create()
    };

    foreach (var entry in monsterContainer.Files.Entries())
    {
        var reader = entry.Value;
        if (reader.Size() == 0)
            continue;
        reader.Position = 0;
        // (the original also reads the battle graphics, which this tool does not use)
        if (MonsterReader.ReadMonster((uint32)entry.Key, ref reader, null) is not Monster monster)
        {
            Console.WriteLine($"Unable to load monsters from game data. Invalid {fileName} file.");
            Exit(ErrorCode.UnableToLoadMonsters);
            return monsters;
        }
        monsters.Indices.Add(entry.Key);
        monsters.Names.Add(monster.Character.Name);
    }

    return monsters;
}

void ListMonsters()
{
    var monsters = LoadMonsters();

    for (var i = 0; i < monsters.Indices.Count(); i += 1)
        Console.WriteLine($"{FormatIndex(monsters.Indices[i])}: {monsters.Names[i]}");

    Console.WriteLine();
}

// a number of a monster with at least 3 digits
string FormatIndex(int index)
{
    return index.ToString().PadLeft(3, '0');
}

uint32 ReadValue(DataReader file, int64 offset, int64 size)
{
    file.Position = (int)offset;
    switch (size)
    {
        case 1: return file.ReadByte();
        case 2: return file.ReadWord();
        case 4: return file.ReadDword();
        default: return 0;
    }
}

// the value unsigned (decimal and hex) and signed (as the original computes it: the sign bit and the magnitude)
void PrintValue(uint32 value, int64 size)
{
    string hex = value.ToString("x" + (size * 2).ToString());
    int sizeShift = (int)size * 8 - 1;
    uint32 signBit = (uint32)1 << sizeShift;
    int64 signed = value & (signBit - 1);
    if ((value & signBit) != 0)
        signed = -signed;

    Console.WriteLine($" Dec unsigned: {value}");
    Console.WriteLine($" Hex unsigned: {hex}");
    Console.WriteLine($" Dec signed  : {signed}");
    Console.WriteLine();
}

void ShowMonsterValues(int64 offset, int64 size, bool onlyNotZero)
{
    var monsters = LoadMonsters();

    Console.WriteLine(" -- Value --");

    for (var i = 0; i < monsters.Indices.Count(); i += 1)
    {
        int index = monsters.Indices[i];
        uint32 value = ReadValue(monsters.Files[index], offset, size);
        if (onlyNotZero && value == 0)
            continue;
        Console.WriteLine($"{FormatIndex(index)}: {monsters.Names[i]}");
        PrintValue(value, size);
    }

    Console.WriteLine();
}

void ShowMonsterValue(DataReader monsterFile, int64 offset, int64 size)
{
    Console.WriteLine(" -- Value --");
    PrintValue(ReadValue(monsterFile, offset, size), size);
}

// `long.Parse` of a parameter (all parameters are upper case): hex with the prefix 0X, else decimal
Optional<int64> ParseNumber(string text)
{
    if (text.StartsWith("0X"))
        return ParseHexLong(text[2..]);
    return ParseLong(text);
}

/// An offset into the data of a monster and the size of a value there.
struct ValueLocation
{
    int64 Offset;
    int64 Size;
}

/// The offset and the size of the parameters at `index` and `index + 1`; exits the program with a message if they are
/// missing, no numbers or out of range.
ValueLocation ReadOffsetAndSize(List<string> parameters, int index)
{

    // (the original ends with an exception when they are missing)
    if (parameters.Count() < index + 2)
    {
        Console.WriteLine("Invalid number of arguments.");
        Console.WriteLine();
        Usage();
        Exit(ErrorCode.InvalidNumberOfArguments);
        return ValueLocation { };
    }

    if (ParseNumber(parameters[index]) is not int64 offset)
    {
        Console.WriteLine("Invalid <offset> parameter value: " + parameters[index]);
        Exit(ErrorCode.InvalidArgumentFormat);
        return ValueLocation { };
    }

    if (ParseNumber(parameters[index + 1]) is not int64 size)
    {
        Console.WriteLine("Invalid <size> parameter value: " + parameters[index + 1]);
        Exit(ErrorCode.InvalidArgumentFormat);
        return ValueLocation { };
    }

    // (the original shows the parameters 1 and 2 here, which are not the offset and the size of --all)
    if (offset < 0 || offset > MonsterDataSize - 1)
    {
        Console.WriteLine($"Parameter <offset> must be between 0 and {MonsterDataSize - 1} but was: " + parameters[index]);
        Exit(ErrorCode.ArgumentOutOfRange);
    }
    else if (size != 1 && size != 2 && size != 4)
    {
        Console.WriteLine("Parameter <size> must be 1, 2 or 4 but was: " + parameters[index + 1]);
        Exit(ErrorCode.ArgumentOutOfRange);
    }
    else if (offset + size > MonsterDataSize)
    {
        Console.WriteLine($"Parameter <offset> plus <size> exceeds total size of {MonsterDataSize}. Please adjust values.");
        Exit(ErrorCode.ArgumentOutOfRange);
    }

    return ValueLocation { Offset = offset, Size = size };
}

// whether the value fits into the size (from the signed minimum to the unsigned maximum); negative values become
// `max + value` as in the original (-1 of 1 byte is 254)
bool CheckSize(ref int64 value, int64 numBytes)
{
    int64 min = numBytes == 1 ? -128 : numBytes == 2 ? -32768 : -2147483648;
    int64 max = numBytes == 1 ? 255 : numBytes == 2 ? 65535 : 4294967295;

    if (value < min || value > max)
        return false;

    if (value < 0)
        value = max + value;

    return true;
}

void SetMonsterValue(Monsters monsters, int monsterIndex, int64 offset, int64 size, int64 value)
{
    var files = Dictionary<uint32, uint8[]>.Create();

    foreach (var entry in monsters.Files.Entries())
    {
        var data = entry.Value.ToArray();

        if (entry.Key == monsterIndex)
        {
            // the value big-endian at the offset (the data of a monster is at least MonsterDataSize bytes)
            var changed = new uint8[data.Length];
            Array.Copy(data, 0, changed, 0, data.Length);
            for (var i = 0; i < (int)size; i += 1)
                changed[(int)offset + i] = (uint8)((value >> (((int)size - 1 - i) * 8)) & 0xff);
            data = changed;
        }

        files[(uint32)entry.Key] = data;
    }

    var writer = new DataWriter();
    if (FileWriter.WriteContainer(ref writer, files, FileType.AMBR) is error writeError)
    {
        Console.WriteLine(writeError.Message);
        Exit(ErrorCode.UnableToCreateBackup);
        return;
    }

    string monsterDataFile = Path.Combine(Directory.GetCurrentDirectory(), monsters.FileName);
    string backupFile = monsterDataFile + ".backup";

    if (!File.Exists(monsterDataFile))
    {
        Console.WriteLine("No monster data file found at: " + monsterDataFile);
        Exit(ErrorCode.UnableToCreateBackup);
        return;
    }

    if (!File.Exists(backupFile))
    {
        Console.WriteLine("No backup file exists. Creating backup at: " + backupFile);

        if (File.Copy(monsterDataFile, backupFile) is error)
        {
            Console.WriteLine("Failed to create backup at: " + backupFile);
            Exit(ErrorCode.UnableToCreateBackup);
            return;
        }

        Console.Write("Backup created successfully. Changing monster data ... ");
    }
    else
    {
        Console.Write("Backup file does already exist. Changing monster data ... ");
    }

    if (File.WriteAllBytes(monsterDataFile, writer.AsSlice()) is error)
    {
        Console.Write("failed");
        Console.Write("Restoring backup ... ");

        if (File.Copy(backupFile, monsterDataFile, true) is error)
            Console.WriteLine("failed. Please restore backup yourself.");
        else
            Console.WriteLine("done");
    }
    else
        Console.Write("done");

    Console.WriteLine();
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
            parameters.Add(ToUpperNet(arg));
    }

    if (options.Contains("--help") || options.Contains("-h"))
    {
        Usage();
        return (int)ErrorCode.NoError;
    }

    if (options.Contains("--list") || options.Contains("-l"))
    {
        ListMonsters();
        return (int)ErrorCode.NoError;
    }

    if (options.Contains("--all") || options.Contains("-a") || options.Contains("--all-not-0"))
    {
        bool onlyNotZero = !options.Contains("--all") && !options.Contains("-a");
        var location = ReadOffsetAndSize(parameters, 0);
        ShowMonsterValues(location.Offset, location.Size, onlyNotZero);
        return (int)ErrorCode.NoError;
    }

    if (options.Count() != 0)
    {
        Console.WriteLine("Invalid options: " + string.Join(" ", options.ToArray()));
        Console.WriteLine();
        Usage();
        return (int)ErrorCode.InvalidOptions;
    }

    if (parameters.Count() < 3 || parameters.Count() > 4)
    {
        Console.WriteLine("Invalid number of arguments.");
        Console.WriteLine();
        Usage();
        return (int)ErrorCode.InvalidNumberOfArguments;
    }

    var monsters = LoadMonsters();
    int monsterIndex = -1;

    if (ParseInt(parameters[0]) is int monsterId)
    {
        // (an empty file is no monster: the original ends with an exception reading from it)
        if (monsters.Indices.Contains(monsterId))
            monsterIndex = monsterId;
        else
        {
            Console.WriteLine($"No monster exists with id {monsterId}.");
            return (int)ErrorCode.NoMonsterWithIdOrName;
        }
    }
    else
    {
        for (var i = 0; i < monsters.Indices.Count() && monsterIndex < 0; i += 1)
        {
            if (ToUpperNet(monsters.Names[i]) == parameters[0])
                monsterIndex = monsters.Indices[i];
        }

        if (monsterIndex < 0)
        {
            Console.WriteLine($"No monster exists with name '{parameters[0]}'.");
            return (int)ErrorCode.NoMonsterWithIdOrName;
        }
    }

    var valueLocation = ReadOffsetAndSize(parameters, 1);
    int64 offset = valueLocation.Offset;
    int64 size = valueLocation.Size;

    if (parameters.Count() == 3)
        ShowMonsterValue(monsters.Files[monsterIndex], offset, size);
    else
    {
        if (ParseNumber(parameters[3]) is not int64 parsedValue)
        {
            Console.WriteLine("Invalid <value> parameter value: " + parameters[3]);
            return (int)ErrorCode.InvalidArgumentFormat;
        }

        int64 value = parsedValue;

        if (!CheckSize(ref value, size))
        {
            Console.WriteLine($"Parameter <value> is too big for given <size> of {size}: " + parameters[3]);
            return (int)ErrorCode.ArgumentOutOfRange;
        }

        SetMonsterValue(monsters, monsterIndex, offset, size, value);
    }

    return (int)ErrorCode.NoError;
}
