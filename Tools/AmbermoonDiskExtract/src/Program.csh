//! AmbermoonDiskExtract: extracts the files of the game from its ADF disk images (a port of
//! AmbermoonTools/AmbermoonDiskExtract).
namespace AmbermoonDiskExtract;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Compression;
using Ambermoon.Data.Legacy.Serialization;

void Usage()
{
    Console.WriteLine();
    Console.WriteLine("Usage: AmbermoonDiskExtract <folder_with_adfs> [dest_path]");
    Console.WriteLine("       AmbermoonDiskExtract -u <folder_with_adfs> [dest_path]");
    Console.WriteLine();
    Console.WriteLine("First version extracts the encoded files.");
    Console.WriteLine("Second version extracts all files as raw files or AMBR containers.");
    Console.WriteLine();
}

int Main(string[] args)
{
    if (args.Length < 1 || args.Length > 3)
    {
        Usage();
        return 1;
    }

    if (args.Length == 3 && args[0] != "-u")
    {
        Usage();
        return 1;
    }

    bool uncompressed = args[0] == "-u";
    string gameDataPath = uncompressed ? (args.Length > 1 ? args[1] : "") : args[0];
    var gameData = GameData.Create(LoadPreference.ForceAdf, false);

    if (gameDataPath.Length == 0 || gameData.Load(gameDataPath) is error)
    {
        Console.WriteLine($"No valid ADF files found at '{gameDataPath}'.");
        return 1;
    }

    // without a destination the current folder (the original writes into the folder of the program)
    string outPath = uncompressed ? (args.Length == 3 ? args[2] : ".") : (args.Length == 2 ? args[1] : ".");

    foreach (var file in gameData.Files.Entries())
    {
        var writer = new DataWriter();
        var container = file.Value;
        var header = container.Header();
        var fileType = (header & 0xffff0000) == (uint32)FileType.JH ? FileType.JH : (FileType)header;
        Error<void> written;

        switch (fileType)
        {
            case FileType.JH:
            case FileType.LOB:
            case FileType.VOL1:
                if (uncompressed)
                {
                    writer.WriteBytes(_File1(container));
                    written = Ok();
                }
                else
                    written = FileWriter.Write(ref writer, container, LobType.Ambermoon, FileDictionaryCompression.None, null);
                break;
            case FileType.AMBR:
            case FileType.AMNC:
            case FileType.AMNP:
            case FileType.AMPC:
                if (uncompressed)
                {
                    var files = Dictionary<uint32, uint8[]>.Create();
                    foreach (var number in container.Numbers())
                        files[(uint32)number] = container.Files[number].ToArray();
                    written = FileWriter.WriteContainer(ref writer, files, FileType.AMBR);
                }
                else
                    written = FileWriter.Write(ref writer, container, LobType.Ambermoon, FileDictionaryCompression.None, null);
                break;
            default: // raw
                writer.WriteBytes(_File1(container));
                written = Ok();
                break;
        }

        var filePath = Path.Combine(outPath, file.Key);
        if (written is error e)
            return WriteError(outPath, e.Message);
        var directory = Path.GetDirectory(filePath);
        if ((directory.Length != 0 && !Directory.Create(directory)) ||
            File.WriteAllBytes(filePath, writer.AsSlice()) is error)
            return WriteError(outPath, $"Could not write file '{filePath}'.");
    }

    return 0;
}

Error<void> Ok()
{
    return;
}

// the data of file 1 (an empty file has none)
uint8[] _File1(FileContainer container)
{
    if (container.Files.TryGet(1) is DataReader reader)
        return reader.ToArray();
    return new uint8[0];
}

int WriteError(string outPath, string message)
{
    Console.WriteLine($"Error writing ADF content to '{outPath}': {message}");
    return 1;
}
