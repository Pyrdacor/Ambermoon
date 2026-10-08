namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;

/// The version of the game files to look for.
enum VersionPreference : int32
{
    Any,
    Pre114,
    Post114
}

/// Reads the files of the game from an ADF disk image (the Amiga file systems OFS and FFS, also international).
struct ADFReader
{
    /// The files of the game that are on the disk: all names of the game (see [GameFiles]) are looked up, also those
    /// of other disks. As in the original, a file in a directory that is missing is looked up in the directory above.
    /// @error no ADF image, or its data is damaged (the messages of the original's IOExceptions).
    static Error<Dictionary<string, uint8[]>> ReadADF(uint8[] image, VersionPreference versionPreference)
    {
        var files = GameFiles(false, versionPreference);
        var adf = _Adf { Image = image };

        // Reading bootblock (sectors 1 and 2 -> byte 0 - 1023)
        if (image.Length < 4 || image[0] != 'D' || image[1] != 'O' || image[2] != 'S')
            return error("Invalid ADF file header.");

        switch (image[3] & 0x07)
        {
            case 0: // OFS
                break;
            case 1: // FFS
                adf.Ffs = true;
                break;
            case 2: // OFS/INTL
            case 4: // OFS/DIRC/INTL
                adf.International = true;
                break;
            case 3: // FFS/INTL
            case 5: // FFS/DIRC/INTL
                adf.Ffs = true;
                adf.International = true;
                break;
            default:
                return error("Invalid ADF file format.");
        }

        // Reading rootblock (sector 880 -> offset 0x6e000)
        adf.Position = 0x6e000;

        if (try adf.ReadDword() != 2 || // type = T_HEADER
            try adf.ReadDword() != 0 || // header_key = unused
            try adf.ReadDword() != 0 || // high_seq = unused
            try adf.ReadDword() != 0x48 || // ht_size = 0x48
            try adf.ReadDword() != 0) // first_data = unused
            return error("Invalid ADF file format.");

        adf.Position += 4; // skip checksum

        var hashTable = new uint32[72];
        for (var i = 0; i < 72; i += 1)
            hashTable[i] = try adf.ReadDword();

        // skip the bitmap flags and pointers (26 dwords), the first bitmap extension block, the dates of the last root
        // alteration (12 bytes), the volume name (32 bytes), unused bytes (8), the dates of the last disk alteration
        // and of the creation (12 bytes each), the next hash and the parent directory
        adf.Position += 26 * 4 + 4 + 12 + 32 + 8 + 12 + 12 + 4 + 4;

        if (try adf.ReadDword() != 0 || // extension must be 0
            try adf.ReadDword() != 1) // block secondary type = ST_ROOT (1)
            return error("Invalid ADF file format.");

        var loadedFiles = Dictionary<string, uint8[]>.Create();
        var directoryHashTables = Dictionary<string, uint32[]>.Create();

        foreach (var file in files.Keys())
        {
            var currentHashTable = hashTable;
            var parts = file.Split('/');

            if (parts.Length > 1)
            {
                string directoryPath = "";

                for (var i = 0; i < parts.Length - 1; i += 1)
                {
                    if (i != 0)
                        directoryPath += "/";
                    directoryPath += parts[i];

                    if (directoryHashTables.TryGet(directoryPath) is uint32[] known)
                        currentHashTable = known;
                    else
                    {
                        if (try adf.GetSector(currentHashTable, parts[i]) is not _Sector sector)
                            continue;
                        if (try adf.GetHashTable(sector) is not uint32[] table)
                            return error(_NotADirectory(directoryPath));
                        currentHashTable = table;
                        directoryHashTables[directoryPath] = table;
                    }
                }
            }

            if (try adf.GetSector(currentHashTable, parts[parts.Length - 1]) is _Sector fileSector)
            {
                if (try adf.GetData(fileSector, 0) is uint8[] data)
                    loadedFiles[file] = data;
                else
                    return error(_NotAFile(file));
            }
        }

        return loadedFiles;
    }
}

string _NotADirectory(string path)
{
    // the original ends with a NullReferenceException
    return $"'{path}' is no directory.";
}

string _NotAFile(string path)
{
    // the original ends with an ArgumentNullException
    return $"'{path}' is no file.";
}

enum _SectorType : uint8
{
    Unknown,
    File,
    Directory
}

// a header block of a file or directory (or an extension block of a file)
struct _Sector
{
    _SectorType Type;
    string Name;
    uint32 NextHashBlock;
    uint32 ParentBlock;
    uint32 FirstExtensionBlock;
    uint32 Offset;
    uint32 Length;
}

// an ADF image and a position in it
struct _Adf
{
    uint8[] Image;
    int64 Position;
    bool Ffs;
    bool International;

    Error<uint32> ReadDword()
    {
        if (Position < 0 || Position + 4 > Image.Length)
            return error("Unable to read beyond the end of the stream.");
        int p = (int)Position;
        Position += 4;
        return ((uint32)Image[p] << 24) | ((uint32)Image[p + 1] << 16) | ((uint32)Image[p + 2] << 8) | Image[p + 3];
    }

    Error<uint8> ReadByte()
    {
        if (Position < 0 || Position >= Image.Length)
            return error("Unable to read beyond the end of the stream.");
        Position += 1;
        return Image[(int)Position - 1];
    }

    // up to 'count' bytes (fewer at the end, as BinaryReader.ReadBytes)
    ReadOnlySlice<uint8> ReadBytes(int count)
    {
        int64 start = Position < 0 ? 0 : (Position > Image.Length ? Image.Length : Position);
        int64 end = start + count > Image.Length ? Image.Length : start + count;
        Position = start + count;
        return Image[(int)start..(int)end];
    }

    // the hash of a name as AmigaDOS computes it: the index in the hash table of a directory
    uint32 Hash(StringSlice name)
    {
        // the length and the characters as .NET counts them (UTF-16 units); the names of the game are ASCII
        var codePoints = _CodePoints(name);
        uint32 hash = (uint32)codePoints.Count();

        foreach (var c in codePoints)
        {
            hash = unchecked(hash * 13);
            hash = unchecked(hash + (uint32)_ToUpper(c, International));
            hash &= 0x7ff;
        }

        return hash % 72;
    }

    // the header block of a name in a hash table; null if it is not there
    Error<Optional<_Sector>> GetSector(uint32[] hashTable, StringSlice name)
    {
        var hash = Hash(name);

        // as in the original: names with the hash 0 are not found
        if (hash == 0)
            return null;

        var upperName = ToUpperNet(name);

        if (try ReadSector(hashTable[hash], false) is not _Sector first)
            return null;
        var sector = first;

        while (ToUpperNet(sector.Name) != upperName && sector.NextHashBlock != 0)
        {
            if (try ReadSector(sector.NextHashBlock, false) is not _Sector next)
                return null;
            sector = next;
        }

        if (ToUpperNet(sector.Name) != upperName)
            return null;

        return sector;
    }

    // the sector of a block; null for block 0
    Error<Optional<_Sector>> ReadSector(uint32 block, bool expectExtension)
    {
        if (block == 0)
            return null;

        int64 offset = (int64)block * 512;
        Position = offset;
        var type = try ReadDword();

        if ((type != 2 && !expectExtension) || (type != 16 && expectExtension)) // primary type (T_HEADER or T_LIST)
            return error("Unexpected ADF sector type.");

        if (try ReadDword() != block)
            return error("Invalid ADF sector.");

        // move pointer to file size
        Position = offset + 512 - 188;
        var sector = _Sector { Offset = (uint32)offset, Length = try ReadDword() };

        // move pointer to name length
        Position = offset + 512 - 80;
        int nameLength = try ReadByte();
        if (nameLength > 30)
            nameLength = 30;
        sector.Name = Latin1Encoding.GetString(ReadBytes(nameLength));

        // move pointer to next hash ptr
        Position = offset + 512 - 16;
        sector.NextHashBlock = try ReadDword();
        sector.ParentBlock = try ReadDword();
        sector.FirstExtensionBlock = try ReadDword();

        var secondaryType = (int)(try ReadDword());

        if (secondaryType == -3)
            sector.Type = _SectorType.File;
        else if (secondaryType == 2)
            sector.Type = _SectorType.Directory;

        return sector;
    }

    // the hash table of a directory; null if the sector is no directory
    Error<Optional<uint32[]>> GetHashTable(_Sector sector)
    {
        if (sector.Type != _SectorType.Directory)
            return null;

        var hashTable = new uint32[72];
        Position = (int64)sector.Offset + 24;

        for (var i = 0; i < 72; i += 1)
            hashTable[i] = try ReadDword();

        return hashTable;
    }

    // the data of a file (its size from the header if 'fileSize' is 0); null if the sector is no file
    Error<Optional<uint8[]>> GetData(_Sector sector, uint32 fileSize)
    {
        if (sector.Type != _SectorType.File)
            return null;

        string invalid = $"Invalid ADF file data for file \"{sector.Name}\".";

        if (fileSize == 0)
        {
            Position = (int64)sector.Offset + 512 - 188; // offset to file size
            fileSize = try ReadDword();
        }
        if (fileSize > (uint32)Image.Length)
            return error(invalid);

        Position = (int64)sector.Offset + 24;

        var fileData = new uint8[fileSize];
        var dataOffsets = new uint32[72];

        for (var i = 0; i < 72; i += 1)
            dataOffsets[71 - i] = try ReadDword();

        int offset = 0;

        for (var i = 0; i < 72; i += 1)
        {
            if (dataOffsets[i] == 0)
                break;

            int left = fileData.Length - offset;
            try AppendData(fileData, ref offset, dataOffsets[i], left < 512 ? left : 512);
        }

        if (sector.FirstExtensionBlock != 0)
        {
            if (try ReadSector(sector.FirstExtensionBlock, true) is not _Sector extensionSector)
                return error(invalid);

            if (try GetData(extensionSector, fileSize - (uint32)offset) is not uint8[] extensionData)
                return error(invalid);

            if ((uint32)(offset + extensionData.Length) != fileSize)
                return error(invalid);

            Array.Copy(extensionData, 0, fileData, offset, extensionData.Length);
            offset = (int)fileSize;
        }

        if ((uint32)offset != fileSize)
            return error(invalid);

        return fileData;
    }

    // appends the data of a data block
    Error<void> AppendData(uint8[] buffer, ref int offset, uint32 block, int maxSize)
    {
        Position = (int64)block * 512;

        if (Ffs)
        {
            var data = ReadBytes(maxSize < 0 ? 0 : maxSize);
            if (offset + data.Length > buffer.Length)
                return error("Invalid file data sector size.");
            for (var i = 0; i < data.Length; i += 1)
                buffer[offset + i] = data[i];
            offset += data.Length;
        }
        else // OFS
        {
            if (try ReadDword() != 8)
                return error("Invalid file data sector header.");

            Position += 8; // skip some bytes

            var size = try ReadDword();

            if (size > 512 - 24 || (int64)size > maxSize)
                return error("Invalid file data sector size.");

            Position += 8; // skip some bytes

            var data = ReadBytes((int)size);
            for (var i = 0; i < data.Length; i += 1)
                buffer[offset + i] = data[i];
            offset += data.Length;
        }
        return;
    }
}

// the code points of a text
List<int> _CodePoints(StringSlice text)
{
    var result = List<int>.Create();
    int i = 0;
    while (i < text.Length)
    {
        int b = text[i];
        int length = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        if (i + length > text.Length)
            length = text.Length - i;
        int value = length == 1 ? b : b & (0xFF >> (length + 1));
        for (var k = 1; k < length; k += 1)
            value = (value << 6) | (text[i + k] & 0x3F);
        result.Add(value);
        i += length;
    }
    return result;
}

// the upper case of a character for the hash: in international mode a-z and the Latin-1 letters, else like .NET
int _ToUpper(int c, bool international)
{
    if (international)
        return (c >= 'a' && c <= 'z') || (c >= 224 && c <= 254 && c != 247) ? c - ('a' - 'A') : c;
    return ToUpperCodePoint(c);
}
