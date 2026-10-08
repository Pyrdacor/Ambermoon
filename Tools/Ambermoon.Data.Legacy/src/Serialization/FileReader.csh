namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data.Legacy.Compression;

/// Reads the files of the game: a single file (JH, LOB, VOL1 or raw) or a container (AMNC, AMNP, AMBR, AMPC, AMTX),
/// with the files decrypted and decompressed.
struct FileReader
{
    /// A container of the given files.
    static FileContainer Create(string name, FileType fileType, Dictionary<int, DataReader> files)
    {
        return FileContainer { Name = name, FileType = fileType, Files = files };
    }

    /// A raw file (no header) with the data as file 1.
    static FileContainer CreateRawFile(string name, uint8[] fileData)
    {
        var files = Dictionary<int, DataReader>.Create();
        files[1] = DataReader.FromData(fileData);
        return FileContainer { Name = name, FileType = FileType.None, Files = files };
    }

    /// An AMBR container of the given files.
    static FileContainer CreateRawContainer(string name, Dictionary<int, uint8[]> fileData)
    {
        var files = Dictionary<int, DataReader>.Create();
        foreach (var entry in fileData.Entries())
            files[entry.Key] = DataReader.FromData(entry.Value);
        return FileContainer { Name = name, FileType = FileType.AMBR, Files = files };
    }

    /// Reads the file in `rawData`.
    static Error<FileContainer> ReadRawFile(string name, uint8[] rawData)
    {
        return ReadFile(name, DataReader.FromData(rawData));
    }

    /// Reads the file in `reader` (from its start).
    static Error<FileContainer> ReadFile(string name, DataReader reader)
    {
        if (reader.Size() == 0)
            return FileContainer { Name = name, FileType = FileType.None, Files = Dictionary<int, DataReader>.Create() };

        reader.Position = 0;
        uint32 header = reader.ReadDword();
        var fileType = (header & 0xffff0000) == (uint32)FileType.JH ? FileType.JH : (FileType)header;
        bool singleFile;

        switch (fileType)
        {
            case FileType.JH:
            case FileType.LOB:
            case FileType.VOL1:
                singleFile = true;
                break;
            case FileType.AMNC:
            case FileType.AMNP:
            case FileType.AMBR:
            case FileType.AMPC:
            case FileType.AMTX:
                singleFile = false;
                break;
            default:
            {
                // a raw file
                var files = Dictionary<int, DataReader>.Create();
                files[1] = DataReader.FromData(reader.ToArray());
                return FileContainer { Name = name, FileType = FileType.None, Files = files };
            }
        }
        if (reader.Overrun())
            return error(_TooShort);

        reader.Position = 0;
        return _ProcessFileInfo(name, fileType, singleFile, ref reader);
    }

    static Error<FileContainer> _ProcessFileInfo(string name, FileType fileType, bool singleFile, ref DataReader reader)
    {
        var container = FileContainer { Name = name, FileType = fileType, Files = Dictionary<int, DataReader>.Create() };

        if (singleFile)
        {
            var file = try _DecodeFile(ref reader, fileType, 1);

            // AMBR can be inside JH
            if (fileType == FileType.JH && file.Size() >= 4 && file.PeekDword() == (uint32)FileType.AMBR)
            {
                file.Position = 4;
                file.ReadWord(); // the number of files
                return _ProcessFileInfo(name, FileType.JHPlusAMBR, false, ref file);
            }

            // LOB can be inside JH
            if (fileType == FileType.JH && file.Size() >= 4 && file.PeekDword() == (uint32)FileType.LOB)
                container.FileType = FileType.JHPlusLOB;

            container.Files[1] = file;
            return container;
        }

        reader.Position = 4; // behind the header
        int fileCount = reader.ReadWord();
        int type = fileCount >> 14;
        fileCount &= 0x3ff;
        var data = reader.ToArray();

        if (type == 0 || type == 2)
        {
            // a table of all file sizes (dwords, or words for type 2)
            int entrySize = type == 2 ? 2 : 4;
            int offset = 6 + fileCount * entrySize;

            for (var i = 1; i <= fileCount; i += 1)
            {
                int fileSize = type == 2 ? (int)reader.ReadWord() : (int)reader.ReadDword();
                if (reader.Overrun())
                    return error(_TooShort);
                if (fileSize == 0)
                {
                    container.Files[i] = DataReader.FromData(new uint8[0]);
                }
                else
                {
                    if (fileSize < 0 || offset + fileSize > data.Length)
                        return error(_BadRange);
                    var subfile = DataReader.Create(data, offset, fileSize);
                    container.Files[i] = try _DecodeFile(ref subfile, fileType, i);
                }
                offset += fileSize;
            }

            reader.Position = offset;
        }
        else
        {
            // sections: runs of files with consecutive numbers, files outside of them are empty
            var fileOffsets = Dictionary<int, int>.Create();
            var fileSizes = Dictionary<int, int>.Create();
            int sectionCount = reader.ReadWord();
            if (sectionCount == 0)
                return error("[Data] Invalid container section count.");

            int offset = 0; // relative for now
            for (var i = 0; i < sectionCount; i += 1)
            {
                int index = reader.ReadWord();
                int sectionSize = reader.ReadWord();
                for (var j = 0; j < sectionSize; j += 1)
                {
                    int fileSize = type == 3 ? (int)reader.ReadWord() : (int)reader.ReadDword();
                    if (fileOffsets.ContainsKey(index))
                        return error("An item with the same key has already been added. Key: " + index.ToString());
                    fileOffsets[index] = offset;
                    fileSizes[index] = fileSize;
                    index += 1;
                    offset += fileSize;
                }
                if (reader.Overrun())
                    return error(_TooShort);
            }

            offset = reader.Position;
            for (var i = 1; i <= fileCount; i += 1)
            {
                if (fileSizes.TryGet(i) is int size && size > 0)
                {
                    int start = offset + fileOffsets[i];
                    if (start + size > data.Length)
                        return error(_BadRange);
                    var subfile = DataReader.Create(data, start, size);
                    container.Files[i] = try _DecodeFile(ref subfile, fileType, i);
                }
                else
                {
                    container.Files[i] = DataReader.FromData(new uint8[0]);
                }
            }
        }

        return container;
    }

    // decrypts and decompresses a file (a single file or a file of a container)
    static Error<DataReader> _DecodeFile(ref DataReader file, FileType containerType, int fileNumber)
    {
        var reader = file;
        uint32 header = reader.Size() < 4 ? 0u : reader.PeekDword();
        var fileType = (header & 0xffff0000) == (uint32)FileType.JH ? FileType.JH : (FileType)header;

        if (fileType == FileType.JH)
        {
            reader.Position += 4; // the header
            var key = (uint16)(((header & 0xffff0000) >> 16) ^ (header & 0x0000ffff));
            reader = DataReader.FromData(JH.Crypt(ref reader, key));
        }
        else if (containerType == FileType.AMNC) // the files of AMNC containers are always encrypted
        {
            reader = DataReader.FromData(JH.Crypt(ref reader, (uint16)fileNumber));
        }

        header = reader.Size() < 4 ? 0u : reader.PeekDword(); // the header may have changed above (it is no JH header now)
        fileType = (FileType)header;

        if (fileType == FileType.LOB || fileType == FileType.VOL1)
        {
            reader.Position += 4; // the header
            uint32 lobHeader = reader.PeekDword();
            uint32 decodedSize = lobHeader & 0x00ffffff;
            var lobType = (LobType)(lobHeader >> 24);

            if (containerType == FileType.AMNP) // the files of AMNP containers are always encrypted
            {
                reader.Position += 4; // the decoded size
                reader = DataReader.FromData(JH.Crypt(ref reader, (uint16)fileNumber));
                reader.Position += 4; // the encoded size
            }
            else
            {
                reader.Position += 8; // the decoded and the encoded size
            }
            if (reader.Overrun() || reader.Position > reader.Size())
                return error(_TooShort);

            return LobCompression.Decompress(ref reader, decodedSize, lobType);
        }

        if (containerType == FileType.AMNP) // the files of AMNP containers are always encrypted
        {
            // the header must be 0 (FileType.None)
            if (reader.ReadDword() != (uint32)FileType.None || reader.Overrun())
                return error("[Data] Invalid AMNP file data.");
            reader = DataReader.FromData(JH.Crypt(ref reader, (uint16)fileNumber));
        }

        return reader;
    }
}

const string _TooShort = "The data ends too early.";
const string _BadRange = "Offset and length were out of bounds for the array or count is greater than the number of elements from index to the end of the source collection.";
