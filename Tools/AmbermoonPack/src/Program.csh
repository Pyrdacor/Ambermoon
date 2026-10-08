// AmbermoonPack: packs files into the file formats of Ambermoon and unpacks them again. A port of AmbermoonPack of
// https://github.com/Pyrdacor/Ambermoon (AmbermoonTools); see ../README.md for what is different.
namespace AmbermoonPack;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.Serialization;

const int ErrorInvalidUsage = 1;
const int ErrorInvalidType = 2;
const int ErrorSourceFound = 3;
const int ErrorWritingToDestination = 4;
const int ErrorInvalidJHKey = 5;
const int ErrorExecution = 6;
const int ErrorInvalidSourceFile = 7;
const int ErrorInvalidFileIndices = 8;

void Usage()
{
    Console.WriteLine();
    Console.WriteLine("Usage: AmbermoonPack <type> <source> <dest> [key] [options]");
    Console.WriteLine("       AmbermoonPack REPACK <source> <dest> [options]");
    Console.WriteLine("       AmbermoonPack UNPACK <source> <dest>");
    Console.WriteLine("       AmbermoonPack UNITEM <source> <dest>");
    Console.WriteLine("       AmbermoonPack PKITEM <source> <dest>");
    Console.WriteLine();
    Console.WriteLine("The first version packs a directory of single files into a container.");
    Console.WriteLine("UNPACK unpacks a container to a directory of single files.");
    Console.WriteLine("REPACK packs a container to a different format.");
    Console.WriteLine("UNITEM unpacks an item container to a single item files.");
    Console.WriteLine("PKITEM packs a directory of item files into an item container.");
    Console.WriteLine();
    Console.WriteLine(" <type>     JH, LOB, VOL1, AMNC, AMNP, AMBR, AMPC, JH+AMBR, JH+LOB");
    Console.WriteLine(" <source>   Source file or directory path");
    Console.WriteLine(" <dest>     Destination file path");
    Console.WriteLine(" [key]      Optional encrypt key for JH files");
    Console.WriteLine(" [options]  See below");
    Console.WriteLine();
    Console.WriteLine("Don't use the compression options if you plan to pack data for the original!");
    Console.WriteLine();
    Console.WriteLine("Options:");
    Console.WriteLine();
    Console.WriteLine(" -dN: Dictionary compression");
    Console.WriteLine("      N=0: None (default)");
    Console.WriteLine("      N=1: Half file size entry size");
    Console.WriteLine("      N=2: Use file size sections (to compress gaps)");
    Console.WriteLine("      N=3: Combines 1 and 2");
    Console.WriteLine("      N=4: Uses 1 and if valuable also 2");
    Console.WriteLine(" -cN: Lob compression");
    Console.WriteLine("      N=0: Original Lob (default)");
    Console.WriteLine("      N=1: Extended Lob");
    Console.WriteLine("      N=2: Advanced Lob");
    Console.WriteLine("      N=3: Use best of 0, 1 and 2");
    Console.WriteLine("      N=4: Text Lob");
    Console.WriteLine("      N=5: Use best of 0 and 4");
    Console.WriteLine("      Note that for AMNP, the raw data is used if the best compression is worse.");
    Console.WriteLine(" -v: Verbose. Prints compression info for each subfile to the console.");
    Console.WriteLine();
    Console.WriteLine("Examples:");
    Console.WriteLine();
    Console.WriteLine(" AmbermoonPack LOB \"my\\path\\to\\file\" \"test.amb\"");
    Console.WriteLine(" AmbermoonPack AMNP \"my\\path\\to\\dir\\with\\files\" \"test.amb\"");
    Console.WriteLine(" AmbermoonPack JH+LOB \"my\\path\\to\\dir\\with\\textfiles\\001\" \"Text.amb\" 0xd2e7");
    Console.WriteLine(" AmbermoonPack UNITEM \"my\\path\\to\\file\" \"my\\path\\to\\dir\"");
    Console.WriteLine();
    Console.WriteLine("Note:");
    Console.WriteLine(" If the files have names like 001, 002, etc this is used as the");
    Console.WriteLine(" file number inside the resulting container. Otherwise they are");
    Console.WriteLine(" sorted alphabetically and numbered 1 to n.");
    Console.WriteLine();
    Console.WriteLine("Error codes:");
    Console.WriteLine(" 0: No error");
    Console.WriteLine(" 1: Invalid usage");
    Console.WriteLine(" 2: Invalid type");
    Console.WriteLine(" 3: Source not found");
    Console.WriteLine(" 4: Destination write error");
    Console.WriteLine(" 5: Invalid JH encrypt key");
    Console.WriteLine(" 6: Internal program error");
    Console.WriteLine(" 7: Invalid source file for repack");
    Console.WriteLine(" 8: Invalid file numbering for item pack");
    Console.WriteLine();
}

// the options (-dN, -cN, -v) and the other arguments
struct Options
{
    bool Valid;
    bool Verbose;
    LobType LobType;
    FileDictionaryCompression FileDictionaryCompression;
    string[] Args;
}

Options ParseOptions(string[] args)
{
    var options = Options { LobType = LobType.Ambermoon, FileDictionaryCompression = FileDictionaryCompression.None };
    var dictionaryCompressOptions = List<string>.Create();
    var compressOptions = List<string>.Create();
    var rest = List<string>.Create();
    foreach (var arg in args)
    {
        if (arg.StartsWith("-d"))
            dictionaryCompressOptions.Add(arg);
        if (arg.StartsWith("-c"))
            compressOptions.Add(arg);
        if (arg == "-v")
            options.Verbose = true;
        if (arg.Length == 0 || arg[0] != '-')
            rest.Add(arg);
    }

    if (dictionaryCompressOptions.Count() > 1 || compressOptions.Count() > 1)
        return options;

    if (dictionaryCompressOptions.Count() == 1)
    {
        string option = dictionaryCompressOptions[0];
        if (option.Length != 3 || !Char.IsDigit(option[2]) || option[2] - '0' > 4)
            return options;
        options.FileDictionaryCompression = (FileDictionaryCompression)(option[2] - '0');
    }

    if (compressOptions.Count() == 1)
    {
        string option = compressOptions[0];
        if (option.Length != 3 || !Char.IsDigit(option[2]) || option[2] - '0' > 6)
            return options;
        switch (option[2] - '0')
        {
            case 1:
                options.LobType = LobType.LZRS;
                break;
            case 2:
                options.LobType = LobType.Extended;
                break;
            case 3:
                options.LobType = LobType.TakeBest;
                break;
            case 4:
                options.LobType = LobType.Text;
                break;
            case 5:
                options.LobType = LobType.TakeBestForText;
                break;
            default:
                options.LobType = LobType.Ambermoon;
                break;
        }
    }

    options.Args = rest.ToArray();
    options.Valid = true;
    return options;
}

// the file types that can be named on the command line (Enum.TryParse of the original: the names in capitals, or a
// number)
Optional<FileType> ParseFileType(string name)
{
    for (var i = 0; i < Enum<FileType>.Count; i += 1)
    {
        if (Enum<FileType>.Names[i] == name)
            return Enum<FileType>.Values[i];
    }
    var trimmed = name.Trim();
    if (trimmed.Length > 0 && trimmed.Length <= 10 && _AllDigits(trimmed) && trimmed.ParseInt64() is int64 number && number <= 4294967295)
        return (FileType)(uint32)number;
    return null;
}

bool _AllDigits(StringSlice text)
{
    foreach (var c in text)
    {
        if (!Char.IsDigit(c))
            return false;
    }
    return true;
}

void Exit(int code)
{
    Environment.Exit(code);
}

int Main(string[] arguments)
{
    var options = ParseOptions(arguments);

    if (!options.Valid)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    string[] args = options.Args;

    if (args.Length != 3 && args.Length != 4)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    Optional<FileType> type = null;
    bool additionalLobCompression = false;
    string op = args[0].ToUpper();

    if (op == "REPACK")
    {
        type = null;
    }
    else if (op == "UNPACK")
    {
        Unpack(args);
        return 0;
    }
    else if (op == "JH+LOB")
    {
        type = FileType.JH;
        additionalLobCompression = true;
    }
    else if (op == "JH+AMBR")
    {
        type = FileType.JHPlusAMBR;
    }
    else if (op == "UNITEM")
    {
        UnpackItems(args);
        return 0;
    }
    else if (op == "PKITEM")
    {
        PackItems(args);
        return 0;
    }
    else if (ParseFileType(op.TrimEnd('+').ToString()) is FileType fileType)
    {
        type = fileType;
    }
    else
    {
        Console.WriteLine("Invalid type '" + args[0] + "'");
        Usage();
        Exit(ErrorInvalidType);
    }

    // a key can be given for JH files (and, other than in the original, for JH+AMBR)
    bool withKey = type is FileType t && (t == FileType.JH || t == FileType.JHPlusAMBR);
    if (!withKey && args.Length == 4)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    if (!IsFile(args[1]))
    {
        bool fileOnly = !(type is FileType ft) || ft == FileType.JH || ft == FileType.LOB || ft == FileType.VOL1;
        if (fileOnly)
        {
            Console.WriteLine("Source file '" + args[1] + "' not found.");
            Usage();
            Exit(ErrorSourceFound);
        }
        else if (!Directory.Exists(args[1]))
        {
            Console.WriteLine("Source file or directory '" + args[1] + "' not found.");
            Usage();
            Exit(ErrorSourceFound);
        }
    }

    var writer = new DataWriter();
    bool verbose = options.Verbose;
    Action<int, int, Optional<int>> printCompression = (uncompressedSize, compressedSize, subfile) =>
        PrintCompression(verbose, uncompressedSize, compressedSize, subfile);

    if (!(type is FileType packType))
    {
        // REPACK
        if (Repack(ref writer, args[1], options.LobType, options.FileDictionaryCompression, printCompression) is error e)
        {
            Console.WriteLine("Invalid source file for REPACK.");
            Console.WriteLine("Error: " + e.Message);
            Exit(ErrorInvalidSourceFile);
        }
    }
    else if (Pack(ref writer, packType, args, additionalLobCompression, options, printCompression) is error e)
    {
        Console.WriteLine("Internal error: " + e.Message);
        Exit(ErrorExecution);
    }

    WriteFile(args[2], writer);

    Console.WriteLine("File was written successfully.");
    return 0;
}

void PrintCompression(bool verbose, int uncompressedSize, int compressedSize, Optional<int> subfile)
{
    if (!verbose)
        return;
    string ratio = FormatFloat((float)compressedSize * 100.0f / (float)uncompressedSize, 2);
    if (subfile is int number)
        Console.WriteLine($"{number:D3}: {uncompressedSize,-10} -> {compressedSize,-10} ({ratio}%)");
    else
        Console.WriteLine($"Compression result: {uncompressedSize,-10} -> {compressedSize,-10} ({ratio}%)");
}

// packs args[1] (a file or a directory of files) as 'type'
Error<void> Pack(ref DataWriter writer, FileType type, string[] args, bool additionalLobCompression, Options options,
                 Action<int, int, Optional<int>> printCompression)
{
    if (type == FileType.JH || type == FileType.JHPlusAMBR)
    {
        string keyString;
        if (args.Length == 4)
        {
            keyString = args[3];
        }
        else
        {
            Console.Write("Enter encrypt key (16 bit): ");
            if (Console.ReadLine() is not string line)
                return error("Object reference not set to an instance of an object.");
            keyString = line;
        }

        var key = ParseKey(keyString);
        if (key is error e)
        {
            if (e.Code == KeyError.Overflow)
                return error(e.Message);
            Console.WriteLine("Invalid encrypt key. Provide a value from 0 to 65535 (or hex 0x0000 to 0xffff).");
            Exit(ErrorInvalidJHKey);
        }
        uint16 encryptKey = try key;

        if (type == FileType.JHPlusAMBR)
        {
            // an AMBR container, JH-encrypted (the original tool fails here: it treats JH+AMBR like a container type)
            var files = try GetContainerData(args[1]);
            var ambrWriter = new DataWriter();
            try FileWriter.WriteContainer(ref ambrWriter, files, FileType.AMBR, null, LobType.Ambermoon, options.FileDictionaryCompression, null);
            var ambr = ambrWriter.ToArray();
            if (ambr.Length % 2 != 0)
            {
                var aligned = new uint8[ambr.Length + 1];
                Array.Copy(ambr, 0, aligned, 0, ambr.Length);
                ambr = aligned;
            }
            return FileWriter.WriteJH(ref writer, ambr, encryptKey, false);
        }

        var data = try _ReadAllBytes(args[1]);
        // (the original does not pass the LOB type on here: JH+LOB is always the LOB of the original)
        return FileWriter.WriteJH(ref writer, data, encryptKey, additionalLobCompression);
    }

    if (type == FileType.LOB || type == FileType.VOL1)
    {
        var data = try _ReadAllBytes(args[1]);
        if (type == FileType.LOB)
            try FileWriter.WriteLob(ref writer, data, options.LobType, null);
        else
            try FileWriter.WriteVol1(ref writer, data, options.LobType, null);
        printCompression(data.Length, writer.Size(), null);
        return;
    }

    var containerFiles = try GetContainerData(args[1]);
    return FileWriter.WriteContainer(ref writer, containerFiles, type, null, options.LobType, options.FileDictionaryCompression, printCompression);
}

// the files of a container: the file itself, or the files of a directory
Error<Dictionary<uint32, uint8[]>> GetContainerData(string source)
{
    if (IsFile(source))
        return GetContainerDataFromFiles([source]);
    return GetContainerDataFromFiles(GetFiles(source).ToArray());
}

// REPACK: reads a file of the game and writes it again (with other compression options)
Error<void> Repack(ref DataWriter writer, string source, LobType lobType, FileDictionaryCompression fileDictionaryCompression,
                   Action<int, int, Optional<int>> printCompression)
{
    var containerData = try _ReadAllBytes(source);
    var container = try FileReader.ReadFile(Path.GetFileName(source), DataReader.Create(containerData));
    var containerType = (FileType)container.Header();

    switch (containerType)
    {
        case FileType.JH:
        case FileType.JHPlusAMBR:
        {
            var tempReader = DataReader.FromData(containerData);
            uint32 header = tempReader.ReadDword();
            var key = (uint16)(((header & 0xffff0000) >> 16) ^ (header & 0x0000ffff));
            if (containerType == FileType.JHPlusAMBR)
            {
                // the AMBR container again, JH-encrypted with the same key (the original fails here)
                var ambrWriter = new DataWriter();
                try FileWriter.WriteContainer(ref ambrWriter, _FileData(container), FileType.AMBR, null, LobType.Ambermoon,
                                              fileDictionaryCompression, null);
                var ambr = ambrWriter.ToArray();
                if (ambr.Length % 2 != 0)
                {
                    var aligned = new uint8[ambr.Length + 1];
                    Array.Copy(ambr, 0, aligned, 0, ambr.Length);
                    ambr = aligned;
                }
                return FileWriter.WriteJH(ref writer, ambr, key, false);
            }
            var decrypted = DataReader.FromData(JH.Crypt(ref tempReader, key));
            if (decrypted.Size() < 4)
                return error("Specified argument was out of the range of valid values. (Parameter 'length')");
            header = decrypted.ReadDword(); // a LOB/VOL1 header?
            bool lob = header == (uint32)FileType.LOB || header == (uint32)FileType.VOL1;
            return FileWriter.WriteJH(ref writer, container.Files[1].ToArray(), key, lob);
        }
        case FileType.LOB:
            return FileWriter.WriteLob(ref writer, container.Files[1].ToArray(), lobType, null);
        case FileType.VOL1:
            return FileWriter.WriteVol1(ref writer, container.Files[1].ToArray(), lobType, null);
        default:
            return FileWriter.WriteContainer(ref writer, _FileData(container), containerType, null, lobType, fileDictionaryCompression,
                                             printCompression);
    }
}

Dictionary<uint32, uint8[]> _FileData(FileContainer container)
{
    var files = Dictionary<uint32, uint8[]>.Create();
    foreach (var entry in container.Files.Entries())
        files[(uint32)entry.Key] = entry.Value.ToArray();
    return files;
}

void Unpack(string[] args)
{
    if (args.Length != 3)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    var file = LoadForUnpack(args[1]);
    string outDir = args[2];

    if (IsFile(outDir))
        outDir = Path.GetDirectory(outDir);

    if (outDir.Length == 0 || !Directory.Create(outDir))
    {
        Console.WriteLine("Failed to create output directory");
        Exit(ErrorWritingToDestination);
    }

    foreach (var number in file.Numbers())
    {
        var subfile = file.Files[number];
        if (File.WriteAllBytes(Path.Combine(outDir, number.ToString("D3")), subfile.ReadToEnd()) is error)
        {
            Console.WriteLine("Failed to write output files");
            Exit(ErrorWritingToDestination);
        }
    }
}

// reads the file to unpack, or ends the program with the error of UNPACK
FileContainer LoadForUnpack(string path)
{
    if (!IsFile(path))
    {
        Console.WriteLine("Source file '" + path + "' not found.");
        Usage();
        Exit(ErrorSourceFound);
    }

    var loaded = _ReadAllBytes(path);
    if (loaded is error readError)
    {
        Console.WriteLine("Error loading file: " + readError.Message);
        Exit(ErrorInvalidSourceFile);
    }
    var file = FileReader.ReadFile("", DataReader.Create(loaded is uint8[] bytes ? bytes : new uint8[0]));
    if (file is FileContainer container)
        return container;
    if (file is error e)
        Console.WriteLine("Error loading file: " + e.Message);
    Exit(ErrorInvalidSourceFile);
    return new();
}

// UNITEM: the items of an item file (file 1: a word with the count, then 60 bytes per item) as files 001, 002, ...
// (The original unpacks to a temporary directory first; this reads the container in memory.)
void UnpackItems(string[] args)
{
    if (args.Length != 3)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    var file = LoadForUnpack(args[1]);
    if (file.Files.TryGet(1) is not DataReader items)
    {
        Console.WriteLine("Error loading file: the file has no subfile 001.");
        Exit(ErrorInvalidSourceFile);
        return;
    }
    var reader = items;
    int itemCount = reader.ReadWord();
    if (reader.Overrun())
    {
        Console.WriteLine("Error loading file: the item data is too short.");
        Exit(ErrorInvalidSourceFile);
    }

    if (!Directory.Create(args[2]))
    {
        Console.WriteLine("Failed to create output directory");
        Exit(ErrorWritingToDestination);
    }

    for (var i = 0; i < itemCount; i += 1)
    {
        if (reader.Remaining() < 60 || File.WriteAllBytes(Path.Combine(args[2], (i + 1).ToString("D3")), reader.ReadBytes(60)) is error)
        {
            Console.WriteLine("Failed to write output files");
            Exit(ErrorWritingToDestination);
        }
    }
}

void WriteFile(string path, DataWriter dataWriter)
{
    string destinationDirectory = Path.GetDirectory(path);
    string problem = "";
    if (destinationDirectory.Trim().Length != 0 && !Directory.Create(destinationDirectory))
        problem = "Could not create the directory '" + destinationDirectory + "'.";
    else if (File.WriteAllBytes(path, dataWriter.ToArray()) is error e)
        problem = e.Message;

    if (problem.Length > 0)
    {
        Console.WriteLine("Error writing to destination '" + path + "': " + problem);
        Console.WriteLine(" Ensure to specify a valid file path.");
        Console.WriteLine(" Ensure that you have write permission.");
        Console.WriteLine(" Ensure that the file is not opened in another program.");
        Exit(ErrorWritingToDestination);
    }
}

// PKITEM: item files 001, 002, ... (60 bytes each) as an item file (JH with key 0xd2e7, LOB inside)
void PackItems(string[] args)
{
    if (args.Length != 3)
    {
        Usage();
        Exit(ErrorInvalidUsage);
    }

    if (!Directory.Exists(args[1]))
    {
        Console.WriteLine("Source directory '" + args[1] + "' not found.");
        Usage();
        Exit(ErrorSourceFound);
    }

    var found = GetContainerDataFromFiles(GetFiles(args[1]).ToArray());
    if (found is error readError)
    {
        Console.WriteLine("Internal error: " + readError.Message);
        Exit(ErrorExecution);
    }
    var files = found is Dictionary<uint32, uint8[]> d ? d : Dictionary<uint32, uint8[]>.Create();

    var numbers = List<uint32>.Create();
    foreach (var key in files.Keys())
        numbers.Add(key);
    numbers.Sort();

    if (numbers.Count() == 0 || numbers[numbers.Count() - 1] != (uint32)numbers.Count())
    {
        Console.WriteLine("Invalid file numbering. Ensure file names starting at 001 and without gaps.");
        Exit(ErrorInvalidFileIndices);
    }

    var dataWriter = new DataWriter();
    dataWriter.WriteWord((uint16)files.Count());
    foreach (var number in numbers)
        dataWriter.WriteBytes(files[number]);

    var outputWriter = new DataWriter();
    if (FileWriter.WriteJH(ref outputWriter, dataWriter.ToArray(), 0xd2e7, true) is error e)
    {
        Console.WriteLine("Internal error: " + e.Message);
        Exit(ErrorExecution);
    }

    WriteFile(args[2], outputWriter);

    Console.WriteLine("File was written successfully.");
}

// Files named by numbers (001, 002.bin, ...) are the files with these numbers; if no file has such a name, the files
// are numbered 1 to n in the order of their names.
Error<Dictionary<uint32, uint8[]>> GetContainerDataFromFiles(string[] files)
{
    var result = Dictionary<uint32, uint8[]>.Create();
    var list = List<string>.Create();
    foreach (var file in files)
        list.Add(file);
    list.Sort();

    bool anyDigitMatch = false;
    foreach (var file in files)
    {
        if (_IsNumber(Path.GetStem(file)))
            anyDigitMatch = true;
    }

    uint32 lastIndex = 0;
    foreach (var file in list)
    {
        uint32 index = lastIndex + 1;
        string stem = Path.GetStem(file);
        if (_IsNumber(stem))
        {
            int64 number = stem.Length <= 10 && stem.ParseInt64() is int64 n ? n : -1;
            if (number < 0 || number > 4294967295)
                return error("Value was either too large or too small for a UInt32.");
            index = (uint32)number;
        }
        else if (anyDigitMatch)
        {
            continue;
        }

        result[index] = try _ReadAllBytes(file);
        lastIndex = index;
    }

    return result;
}

bool _IsNumber(StringSlice name)
{
    return name.Length > 0 && _AllDigits(name);
}

Error<uint8[]> _ReadAllBytes(string path)
{
    if (File.ReadAllBytes(path) is uint8[] bytes)
        return bytes;
    return error("Could not find file '" + Path.GetFullPath(path) + "'.");
}

error KeyError
{
    Invalid,
    Overflow
}

// a key like ushort.Parse: "0x" and hexadecimal digits, or decimal digits (with a sign); spaces around it are allowed
KeyError<uint16> ParseKey(string text)
{
    var trimmed = text.Trim(); // (white space between "0x" and the digits is allowed as well, like in the original)
    bool hex = text.Length >= 2 && text[0] == '0' && (text[1] == 'x' || text[1] == 'X');
    if (hex)
    {
        var digits = text[2..].Trim();
        if (digits.Length == 0)
            return error(KeyError.Invalid);
        uint32 value = 0;
        foreach (var c in digits)
        {
            if (!Char.IsHexDigit(c))
                return error(KeyError.Invalid);
            value = value * 16 + (uint32)Char.HexValue(c);
            if (value > 0xffff)
            {
                // the rest must still be hex digits, otherwise it is a format error
                foreach (var rest in digits)
                {
                    if (!Char.IsHexDigit(rest))
                        return error(KeyError.Invalid);
                }
                return error("Value was either too large or too small for a UInt16.", KeyError.Overflow);
            }
        }
        return (uint16)value;
    }

    bool negative = false;
    StringSlice number = trimmed;
    if (number.Length > 0 && (number[0] == '+' || number[0] == '-'))
    {
        negative = number[0] == '-';
        number = number[1..];
    }
    if (number.Length == 0 || !_AllDigits(number))
        return error(KeyError.Invalid);
    bool large = false;
    uint32 result = 0;
    foreach (var c in number)
    {
        if (result <= 0xffff)
            result = result * 10 + (uint32)(c - '0');
        if (result > 0xffff)
            large = true;
    }
    if (large || (negative && result != 0))
        return error("Value was either too large or too small for a UInt16.", KeyError.Overflow);
    return (uint16)result;
}
