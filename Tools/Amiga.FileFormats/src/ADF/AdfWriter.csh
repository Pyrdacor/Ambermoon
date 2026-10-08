namespace Amiga.FileFormats.ADF;

using System;
using Ambermoon;

/// The results of writing an ADF disk image.
enum ADFWriteResult : int
{
    Success = 0,
    OmittedEmptyDirectories = 1,
    DiskFullError = 2,
    WriteAccessError = 3
}

/// The file systems of AmigaDOS disks.
enum FileSystem : int
{
    /// The old file system: data blocks with a header of 24 bytes.
    OFS = 0,
    /// The fast file system: data blocks without a header.
    FFS = 1
}

/// The boot code of bootable disks (Amiga.FileFormats.ADF's `ADFWriter.DefaultBootCode`).
const ReadOnlySlice<uint8> DefaultBootCode = [
    0x43, 0xFA, 0x00, 0x3E, 0x70, 0x25, 0x4E, 0xAE, 0xFD, 0xD8, 0x4A, 0x80, 0x67, 0x0C, 0x22, 0x40, 0x08, 0xE9, 0x00, 0x06,
    0x00, 0x22, 0x4E, 0xAE, 0xFE, 0x62, 0x43, 0xFA, 0x00, 0x18, 0x4E, 0xAE, 0xFF, 0xA0, 0x4A, 0x80, 0x67, 0x0A, 0x20, 0x40,
    0x20, 0x68, 0x00, 0x16, 0x70, 0x00, 0x4E, 0x75, 0x70, 0xFF, 0x4E, 0x75,
    // "dos.library", "expansion.library"
    0x64, 0x6F, 0x73, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72, 0x79, 0x00,
    0x65, 0x78, 0x70, 0x61, 0x6E, 0x73, 0x69, 0x6F, 0x6E, 0x2E, 0x6C, 0x69, 0x62, 0x72, 0x61, 0x72, 0x79, 0x00
];

const int _SectorSize = 512;

/// A file of an ADF image: its path on the disk (`/` between directories) and its data.
struct AdfFile
{
    string Path;
    uint8[] Data;
}

/// The settings of an ADF image ([WriteAdf]).
struct AdfConfiguration
{
    FileSystem FileSystem;
    bool InternationalMode;
    bool Bootable;
    bool HD;
}

// A directory of the image while it is made.
struct _AdfDirectory
{
    string Path;
    int Parent;               // -1: in the root
    List<string> Files;       // names, in the order in which they were added
    List<string> Directories;
}

struct _AdfSizedFile
{
    string Path;
    int Size;
}

// A disk image while it is made: the sectors, the directories, the sectors of the files and directories.
struct _AdfBuilder
{
    uint8[] Data;
    AdfConfiguration Configuration;
    List<_AdfDirectory> Directories;
    Dictionary<string, int> DirectoryIndex;
    List<string> RootFiles;
    Dictionary<string, int> FileParents;          // path -> directory index, -1 for the root
    Dictionary<string, List<int>> FileSectors;
    Dictionary<string, int> DirectorySectors;
    Dictionary<int, string> FilesBySector;
    Dictionary<int, string> DirectoriesBySector;
    Dictionary<string, uint8[]> FileData;
    int SectorCount;
    int RootBlockSector;
    int EntrySector;
    int AllocatedSectorCount;
    bool Full;
    DateTime Now;

    // NextSector of the original: the sectors after the bitmap block up to the end, then from sector 2 on
    int NextSector()
    {
        int sector = EntrySector;
        EntrySector += 1;
        AllocatedSectorCount += 1;
        if (sector == 0)
            sector = 2;
        if (EntrySector == SectorCount)
            EntrySector = 2;
        else if (EntrySector == RootBlockSector)
            Full = true; // not enough sectors (the original throws here)
        return sector;
    }

    void EnsureDirectorySector(int directory)
    {
        if (Directories[directory].Parent >= 0)
            EnsureDirectorySector(Directories[directory].Parent);
        if (!DirectorySectors.ContainsKey(Directories[directory].Path))
            DirectorySectors[Directories[directory].Path] = NextSector();
    }

    int SectorRank(int sector)
    {
        return sector >= RootBlockSector ? sector - RootBlockSector : sector + RootBlockSector;
    }

    // The entries of a directory grouped by the hash of their names: the sectors of each hash in the order of their
    // rank, the hashes in the order of their first entry.
    List<_AdfChain> HashChains(List<string> directoryNames, List<string> fileNames, string prefix)
    {
        var chains = List<_AdfChain>.Create();
        foreach (var name in directoryNames)
            _AddToChain(ref chains, name, DirectorySectors[prefix + name]);
        foreach (var name in fileNames)
            _AddToChain(ref chains, name, FileSectors[prefix + name][0]);
        for (var c = 0; c < chains.Count(); c += 1)
        {
            // OrderBy(SectorRank): stable, the sectors are different
            var sectors = chains[c].Sectors;
            for (var i = 1; i < sectors.Count(); i += 1)
            {
                int s = sectors[i];
                int j = i - 1;
                while (j >= 0 && SectorRank(sectors[j]) > SectorRank(s))
                {
                    sectors[j + 1] = sectors[j];
                    j -= 1;
                }
                sectors[j + 1] = s;
            }
        }
        return chains;
    }

    void _AddToChain(ref List<_AdfChain> chains, string name, int sector)
    {
        uint32 hash = HashName(name, Configuration.InternationalMode);
        for (var c = 0; c < chains.Count(); c += 1)
        {
            if (chains[c].Hash == hash)
            {
                chains[c].Sectors.Add(sector);
                return;
            }
        }
        var sectors = List<int>.Create();
        sectors.Add(sector);
        chains.Add(_AdfChain { Hash = hash, Sectors = sectors });
    }

    void WriteSector(int sector, uint8[] block)
    {
        Array.Copy(block, 0, Data, sector * _SectorSize, _SectorSize);
    }

    void WriteEntries(List<_AdfChain> chains, int parentSector)
    {
        foreach (var chain in chains)
        {
            for (var i = 0; i < chain.Sectors.Count(); i += 1)
            {
                int sector = chain.Sectors[i];
                int nextSector = i == chain.Sectors.Count() - 1 ? 0 : chain.Sectors[i + 1];
                if (DirectoriesBySector.TryGet(sector) is string directoryPath)
                {
                    var directory = Directories[DirectoryIndex[directoryPath]];
                    var subChains = HashChains(directory.Directories, directory.Files, directory.Path + "/");
                    WriteSector(sector, _DirectoryBlock(_FileName(directoryPath), sector, subChains, nextSector, parentSector, Now));
                    WriteEntries(subChains, sector);
                }
                else if (FilesBySector.TryGet(sector) is string filePath)
                    WriteFile(filePath, sector, nextSector, parentSector);
            }
        }
    }

    void WriteFile(string filePath, int sector, int nextSector, int parentSector)
    {
        var sectors = FileSectors[filePath];
        var data = FileData[filePath];
        var dataSectors = _Range(sectors, 1, 72);
        int extensionSector = sectors.Count() > 73 ? sectors[73] : 0;
        int dataIndex = 0;
        int sectorListOffset = 74;
        WriteSector(sector, _FileBlock(_FileName(filePath), sectors[0], dataSectors, extensionSector, data.Length, nextSector, parentSector, Now));
        int dataBlockStartIndex = 1;
        while (true)
        {
            // (the data block before an extension block points at the sector after it, as in the original)
            int endDataSector = extensionSector == 0 ? 0 : extensionSector + 1;
            for (var d = 0; d < dataSectors.Count(); d += 1)
            {
                int nextDataSector = d == dataSectors.Count() - 1 ? endDataSector : dataSectors[d + 1];
                WriteSector(dataSectors[d], _DataBlock(sectors[0], dataBlockStartIndex + d, nextDataSector, data, ref dataIndex, Configuration.FileSystem));
            }
            if (extensionSector == 0)
                break;
            dataBlockStartIndex += 72;
            dataSectors = _Range(sectors, sectorListOffset, 72);
            int nextExtensionSector = sectors.Count() > sectorListOffset + 72 ? sectors[sectorListOffset + 72] : 0;
            WriteSector(extensionSector, _FileExtensionBlock(sectors[0], extensionSector, dataSectors, nextExtensionSector));
            extensionSector = nextExtensionSector;
            sectorListOffset += 73;
        }
    }
}

struct _AdfChain
{
    uint32 Hash;
    List<int> Sectors;
}

List<int> _Range(List<int> list, int start, int count)
{
    var result = List<int>.Create();
    for (var i = start; i < list.Count() && i < start + count; i += 1)
        result.Add(list[i]);
    return result;
}

string _FileName(StringSlice path)
{
    int slash = path.LastIndexOf('/');
    return slash < 0 ? path.ToString() : path[slash + 1..].ToString();
}

/// An ADF image of the files (`ADFWriter.WriteADFFile` with streams): the volume `name`, the files in the order given
/// (the order decides where they are placed: the largest first, from the middle of the disk on). `now` is the time of
/// the blocks. An error when the files do not fit on the disk.
ADFWriteResult WriteAdf(List<AdfFile> files, StringSlice name, AdfConfiguration configuration, DateTime now, ref uint8[] image)
{
    var b = _AdfBuilder
    {
        Data = new uint8[configuration.HD ? 512 * 22 * 2 * 80 : 512 * 11 * 2 * 80], Configuration = configuration,
        Directories = List<_AdfDirectory>.Create(), DirectoryIndex = Dictionary<string, int>.Create(), RootFiles = List<string>.Create(),
        FileParents = Dictionary<string, int>.Create(), FileSectors = Dictionary<string, List<int>>.Create(),
        DirectorySectors = Dictionary<string, int>.Create(), FilesBySector = Dictionary<int, string>.Create(),
        DirectoriesBySector = Dictionary<int, string>.Create(), FileData = Dictionary<string, uint8[]>.Create(),
        SectorCount = configuration.HD ? 3520 : 1760, RootBlockSector = configuration.HD ? 1760 : 880, Now = now
    };
    b.EntrySector = b.RootBlockSector + 2;
    b.AllocatedSectorCount = 2;

    // the directories and the files
    var allFiles = List<_AdfSizedFile>.Create();
    foreach (var file in files)
    {
        var parts = file.Path.Split('/');
        if (parts.Length > 1)
        {
            string path = parts[0].ToString();
            int parent = -1;
            for (var i = 0; i < parts.Length - 1; i += 1)
            {
                if (i != 0)
                    path += "/" + parts[i];
                if (b.DirectoryIndex.TryGet(path) is int existing)
                    parent = existing;
                else
                {
                    if (parent >= 0)
                        b.Directories[parent].Directories.Add(parts[i].ToString());
                    b.Directories.Add(_AdfDirectory { Path = path, Parent = parent, Files = List<string>.Create(), Directories = List<string>.Create() });
                    parent = b.Directories.Count() - 1;
                    b.DirectoryIndex[path] = parent;
                }
            }
            string fileName = parts[parts.Length - 1].ToString();
            b.Directories[parent].Files.Add(fileName);
            string key = path + "/" + fileName;
            allFiles.Add(_AdfSizedFile { Path = key, Size = file.Data.Length });
            b.FileParents[key] = parent;
            b.FileData[key] = file.Data;
        }
        else
        {
            b.RootFiles.Add(file.Path);
            allFiles.Add(_AdfSizedFile { Path = file.Path, Size = file.Data.Length });
            b.FileParents[file.Path] = -1;
            b.FileData[file.Path] = file.Data;
        }
    }

    // the sectors: the largest files first (List.Sort of .NET, not stable: its order for equal sizes)
    var sorted = allFiles.ToArray();
    _IntrospectiveSortBySizeDescending(sorted);
    foreach (var file in sorted)
    {
        int parent = b.FileParents[file.Path];
        if (parent >= 0)
            b.EnsureDirectorySector(parent);
        int count = _SectorCountOfFileSize(file.Size, configuration.FileSystem);
        var sectors = List<int>.Create();
        for (var i = 0; i < count; i += 1)
            sectors.Add(b.NextSector());
        if (b.Full)
            return ADFWriteResult.DiskFullError;
        b.FileSectors[file.Path] = sectors;
        b.FilesBySector[sectors[0]] = file.Path;
    }
    foreach (var entry in b.DirectorySectors.Entries())
        b.DirectoriesBySector[entry.Value] = entry.Key;

    // the root entries: the directories in the root, then the files in the root
    var rootDirectories = List<string>.Create();
    foreach (var directory in b.Directories)
    {
        if (directory.Parent < 0)
            rootDirectories.Add(directory.Path);
    }
    var rootChains = b.HashChains(rootDirectories, b.RootFiles, "");
    b.WriteEntries(rootChains, b.RootBlockSector);
    b.WriteSector(b.RootBlockSector, _RootBlock(rootChains, b.RootBlockSector, name, now));
    b.WriteSector(b.RootBlockSector + 1, _BitmapBlock(configuration.HD, b.AllocatedSectorCount));
    _WriteBootBlock(ref b.Data, configuration);
    image = b.Data;
    return ADFWriteResult.Success;
}

int _SectorCountOfFileSize(int size, FileSystem fileSystem)
{
    // a header block, the data blocks, an extension block for every 72 data blocks after the first 72
    int sizePerDataBlock = fileSystem == FileSystem.OFS ? _SectorSize - 24 : _SectorSize;
    int dataBlocks = (size + sizePerDataBlock - 1) / sizePerDataBlock;
    return Math.Max(1, (dataBlocks + 71) / 72) + dataBlocks;
}

/// The hash of a name in a directory (0 to 71).
uint32 HashName(StringSlice name, bool internationalMode)
{
    var units = _Utf16Units(name);
    uint32 hash = (uint32)units.Count();
    for (var i = 0; i < units.Count(); i += 1)
    {
        hash *= 13;
        hash += (uint32)_AdfToUpper(units[i], internationalMode);
        hash &= 0x7ff;
    }
    return hash % 72;
}

int _AdfToUpper(int c, bool internationalMode)
{
    if (internationalMode)
        return (c >= 'a' && c <= 'z') || (c >= 224 && c <= 254 && c != 247) ? c - ('a' - 'A') : c;
    return c >= 'a' && c <= 'z' ? c - ('a' - 'A') : c;
}

// The UTF-16 units of a text (the chars of .NET).
List<int> _Utf16Units(StringSlice text)
{
    var units = List<int>.Create();
    var bytes = text.AsBytes();
    int i = 0;
    while (i < bytes.Length)
    {
        int b = bytes[i];
        int cp;
        int length;
        if (b < 0x80) { cp = b; length = 1; }
        else if (b >= 0xF0 && i + 3 < bytes.Length) { cp = ((b & 7) << 18) | ((bytes[i + 1] & 63) << 12) | ((bytes[i + 2] & 63) << 6) | (bytes[i + 3] & 63); length = 4; }
        else if (b >= 0xE0 && i + 2 < bytes.Length) { cp = ((b & 15) << 12) | ((bytes[i + 1] & 63) << 6) | (bytes[i + 2] & 63); length = 3; }
        else if (i + 1 < bytes.Length) { cp = ((b & 31) << 6) | (bytes[i + 1] & 63); length = 2; }
        else { cp = 0xFFFD; length = 1; }
        if (cp >= 0x10000)
        {
            units.Add(0xD800 + ((cp - 0x10000) >> 10));
            units.Add(0xDC00 + ((cp - 0x10000) & 0x3FF));
        }
        else
            units.Add(cp);
        i += length;
    }
    return units;
}

// Encoding.ASCII.GetBytes of the first `count` characters, padded with zeros.
void _WriteName(ref _BlockWriter w, StringSlice name, int padTo)
{
    var units = _Utf16Units(name);
    int length = Math.Min(units.Count(), padTo);
    w.Byte((uint8)length);
    for (var i = 0; i < padTo; i += 1)
        w.Byte(i < length ? (uint8)(units[i] < 0x80 ? units[i] : '?') : 0);
}

// A block of 512 bytes, written big-endian.
struct _BlockWriter
{
    uint8[] Data;
    int Position;

    static _BlockWriter Create()
    {
        return _BlockWriter { Data = new uint8[_SectorSize] };
    }

    void Byte(uint8 value)
    {
        Data[Position] = value;
        Position += 1;
    }

    void Dword(uint32 value)
    {
        Data[Position] = (uint8)(value >> 24);
        Data[Position + 1] = (uint8)(value >> 16);
        Data[Position + 2] = (uint8)(value >> 8);
        Data[Position + 3] = (uint8)value;
        Position += 4;
    }

    void Zeros(int count)
    {
        Position += count;
    }

    // Util.WriteDateTime of the original: days since 1978-01-01, minutes, ticks of 1/50 s
    void DateTime(DateTime t)
    {
        uint32 days = 0;
        for (var year = 1978; year < t.Year(); year += 1)
            days += _IsLeap(year) ? 366u : 365u;
        if (t.Month() > 1)
        {
            for (var m = 0; m < t.Month() - 1; m += 1)
                days += (uint32)_DaysInMonth(t.Year(), m);
        }
        days = (uint32)(Math.Max(2, (int)days + t.Day()) - 2);
        Dword(days);
        Dword((uint32)(t.Hour() * 60 + t.Minute()));
        Dword((uint32)(t.Second() * 50 + t.Millisecond() / 20));
    }

    // the checksum of header blocks (at offset 20): the words summed up to 0
    void HeaderChecksum()
    {
        uint32 sum = 0;
        for (var i = 0; i < _SectorSize; i += 4)
        {
            if (i != 20)
                sum = unchecked(sum + _BigEndian(Data, i));
        }
        uint32 checksum = unchecked(0u - sum);
        Data[20] = (uint8)(checksum >> 24);
        Data[21] = (uint8)(checksum >> 16);
        Data[22] = (uint8)(checksum >> 8);
        Data[23] = (uint8)checksum;
    }
}

bool _IsLeap(int year)
{
    return year % 4 == 0 && (year % 400 == 0 || year % 100 != 0);
}

int _DaysInMonth(int year, int month)
{
    const ReadOnlySlice<int> days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return month == 1 && _IsLeap(year) ? 29 : days[month];
}

uint32 _BigEndian(uint8[] data, int pos)
{
    return ((uint32)data[pos] << 24) | ((uint32)data[pos + 1] << 16) | ((uint32)data[pos + 2] << 8) | data[pos + 3];
}

uint8[] _RootBlock(List<_AdfChain> chains, int rootBlockSector, StringSlice name, DateTime now)
{
    var w = _BlockWriter.Create();
    w.Dword(2);    // T_HEADER
    w.Dword(0);
    w.Dword(0);
    w.Dword(72);   // the size of the hash table
    w.Dword(0);
    w.Dword(0);    // the checksum
    _WriteHashTable(ref w, chains);
    w.Dword(0xffffffffu);                 // the bitmap is valid
    w.Dword((uint32)(rootBlockSector + 1)); // the bitmap block
    w.Zeros(25 * 4);                      // the other bitmap pointers and the bitmap extension
    w.DateTime(now);                      // last change of the root directory
    _WriteName(ref w, name, 30);
    w.Byte(0);
    w.Dword(0);
    w.Dword(0);
    w.DateTime(now);                      // last change of the disk
    w.DateTime(now);                      // creation
    w.Dword(0);
    w.Dword(0);
    w.Dword(0);                           // no directory cache
    w.Dword(1);                           // ST_ROOT
    w.HeaderChecksum();
    return w.Data;
}

void _WriteHashTable(ref _BlockWriter w, List<_AdfChain> chains)
{
    var table = new uint32[72];
    foreach (var chain in chains)
        table[chain.Hash] = (uint32)chain.Sectors[0];
    for (var i = 0; i < 72; i += 1)
        w.Dword(table[i]);
}

uint8[] _DirectoryBlock(StringSlice name, int sector, List<_AdfChain> chains, int nextHashSector, int parentSector, DateTime now)
{
    var w = _BlockWriter.Create();
    w.Dword(2);    // T_HEADER
    w.Dword((uint32)sector);
    w.Dword(0);
    w.Dword(0);
    w.Dword(0);
    w.Dword(0);    // the checksum
    _WriteHashTable(ref w, chains);
    w.Zeros(4 * 4);
    w.Byte(0);     // no comment
    w.Zeros(79);
    w.Zeros(3 * 4);
    w.DateTime(now);
    _WriteName(ref w, name, 30);
    w.Byte(0);
    w.Zeros(8 * 4);
    w.Dword((uint32)nextHashSector);
    w.Dword((uint32)parentSector);
    w.Dword(0);    // no directory cache
    w.Dword(2);    // ST_USERDIR
    w.HeaderChecksum();
    return w.Data;
}

uint8[] _FileBlock(StringSlice name, int sector, List<int> dataSectors, int extensionSector, int dataSize, int nextHashSector,
                   int parentSector, DateTime now)
{
    var w = _BlockWriter.Create();
    w.Dword(2);    // T_HEADER
    w.Dword((uint32)sector);
    w.Dword((uint32)dataSectors.Count());
    w.Dword(0);
    // the first data block (the original ends with an exception for an empty file)
    w.Dword(dataSectors.Count() > 0 ? (uint32)dataSectors[0] : 0u);
    w.Dword(0);    // the checksum
    for (var i = 0; i < 72; i += 1)
    {
        int index = 71 - i;
        w.Dword(index < dataSectors.Count() ? (uint32)dataSectors[index] : 0u);
    }
    w.Zeros(3 * 4);
    w.Dword((uint32)dataSize);
    w.Byte(0);     // no comment
    w.Zeros(79);
    w.Zeros(3 * 4);
    w.DateTime(now);
    _WriteName(ref w, name, 30);
    w.Byte(0);
    w.Zeros(8 * 4);
    w.Dword((uint32)nextHashSector);
    w.Dword((uint32)parentSector);
    w.Dword((uint32)extensionSector);
    w.Dword(unchecked((uint32)(-3)));   // ST_FILE
    w.HeaderChecksum();
    return w.Data;
}

uint8[] _FileExtensionBlock(int fileHeaderSector, int sector, List<int> dataSectors, int nextExtensionSector)
{
    var w = _BlockWriter.Create();
    w.Dword(16);   // T_LIST
    w.Dword((uint32)sector);
    w.Dword((uint32)dataSectors.Count());
    w.Dword(0);
    w.Dword(0);
    w.Dword(0);    // the checksum
    for (var i = 0; i < 72; i += 1)
    {
        int index = 71 - i;
        w.Dword(index < dataSectors.Count() ? (uint32)dataSectors[index] : 0u);
    }
    w.Zeros(47 * 4);
    w.Dword((uint32)fileHeaderSector);
    w.Dword((uint32)nextExtensionSector);
    w.Dword(unchecked((uint32)(-3)));   // ST_FILE
    w.HeaderChecksum();
    return w.Data;
}

uint8[] _DataBlock(int fileHeaderSector, int index, int nextDataSector, uint8[] data, ref int dataIndex, FileSystem fileSystem)
{
    var w = _BlockWriter.Create();
    int left = data.Length - dataIndex;
    if (fileSystem == FileSystem.FFS)
    {
        int size = Math.Min(_SectorSize, left);
        Array.Copy(data, dataIndex, w.Data, 0, size);
        dataIndex += size;
        return w.Data;
    }
    int count = Math.Min(_SectorSize - 24, left);
    w.Dword(8);    // T_DATA
    w.Dword((uint32)fileHeaderSector);
    w.Dword((uint32)index);
    w.Dword((uint32)count);
    w.Dword((uint32)nextDataSector);
    w.Dword(0);    // the checksum
    Array.Copy(data, dataIndex, w.Data, 24, count);
    dataIndex += count;
    w.HeaderChecksum();
    return w.Data;
}

// The bitmap: the sectors from the middle of the disk on up to the last allocated one are used (the entries are
// allocated in this order), the root and the bitmap block always.
uint8[] _BitmapBlock(bool hd, int allocatedSectorCount)
{
    var bitmap = new uint8[508];
    int halfSectorCount = hd ? 1760 : 880;
    int sectorCount = halfSectorCount * 2;
    int endSector = (halfSectorCount + allocatedSectorCount) % sectorCount;
    if (endSector < halfSectorCount)
        endSector += 2; // the boot blocks are skipped in the first half
    int index = 0;
    int firstHalfEmptyLongs = endSector == 2 || endSector > halfSectorCount ? (halfSectorCount - 2) / 32 : 0;
    for (var i = 0; i < firstHalfEmptyLongs * 4; i += 1)
    {
        bitmap[index] = 0xff;   // free
        index += 1;
    }
    if (firstHalfEmptyLongs == 0 && endSector >= 34)
        index += Math.Min((endSector - 2) / 32, (halfSectorCount - 2) / 32) * 4;
    int totalLongs = (sectorCount - 2 + 31) / 32;
    int currentLong = index / 4;
    int currentSector = 2 + index * 8;
    while (currentLong < totalLongs)
    {
        currentLong += 1;
        uint32 mask = 0;
        for (var i = 0; i < 32 && currentSector < sectorCount; i += 1)
        {
            bool free;
            if (currentSector == halfSectorCount || currentSector == halfSectorCount + 1)
                free = false;
            else if (currentSector < halfSectorCount)
                free = endSector > halfSectorCount || endSector <= currentSector;
            else
                free = endSector > halfSectorCount && endSector <= currentSector;
            if (free)
                mask |= 1u << i;
            currentSector += 1;
        }
        bitmap[index] = (uint8)(mask >> 24);
        bitmap[index + 1] = (uint8)(mask >> 16);
        bitmap[index + 2] = (uint8)(mask >> 8);
        bitmap[index + 3] = (uint8)mask;
        index += 4;
    }
    uint32 sum = 0;
    for (var i = 0; i < 508; i += 4)
        sum = unchecked(sum + _BigEndian(bitmap, i));
    var w = _BlockWriter.Create();
    w.Dword(unchecked(0u - sum));
    Array.Copy(bitmap, 0, w.Data, 4, 508);
    return w.Data;
}

void _WriteBootBlock(ref uint8[] data, AdfConfiguration configuration)
{
    int flags = (int)configuration.FileSystem + (configuration.InternationalMode ? 2 : 0);
    data[0] = 'D';
    data[1] = 'O';
    data[2] = 'S';
    data[3] = (uint8)flags;
    for (var i = 4; i < 1024; i += 1)
        data[i] = 0;
    data[8] = 0;
    data[9] = 0;
    data[10] = 0x03;
    data[11] = 0x70;   // the root block: 880 (also for HD disks, like the original)
    if (configuration.Bootable)
    {
        for (var i = 0; i < DefaultBootCode.Length; i += 1)
            data[12 + i] = DefaultBootCode[i];
    }
    // the checksum: the sum with carry over 1024 bytes, inverted
    uint32 checksum = 0;
    for (var i = 0; i < 1024; i += 4)
    {
        uint32 before = checksum;
        checksum = unchecked(checksum + _BigEndian(data, i));
        if (checksum < before)
            checksum = unchecked(checksum + 1);
    }
    checksum = ~checksum;
    data[4] = (uint8)(checksum >> 24);
    data[5] = (uint8)(checksum >> 16);
    data[6] = (uint8)(checksum >> 8);
    data[7] = (uint8)checksum;
}

// List<T>.Sort(Comparison) of .NET (introsort, not stable) with the comparison of the original: larger sizes first.
void _IntrospectiveSortBySizeDescending(_AdfSizedFile[] keys)
{
    if (keys.Length > 1)
        _IntroSort(keys, 0, keys.Length, 2 * (_Log2(keys.Length) + 1));
}

int _Log2(int value)
{
    int log = 0;
    while (value > 1)
    {
        value >>= 1;
        log += 1;
    }
    return log;
}

// comparer(a, b) = b.Size.CompareTo(a.Size)
int _CompareSize(_AdfSizedFile a, _AdfSizedFile b)
{
    return b.Size < a.Size ? -1 : b.Size > a.Size ? 1 : 0;
}

void _IntroSort(_AdfSizedFile[] keys, int lo, int count, int depthLimit)
{
    int partitionSize = count;
    while (partitionSize > 1)
    {
        if (partitionSize <= 16)
        {
            if (partitionSize == 2)
            {
                _SwapIfGreater(keys, lo, lo + 1);
                return;
            }
            if (partitionSize == 3)
            {
                _SwapIfGreater(keys, lo, lo + 1);
                _SwapIfGreater(keys, lo, lo + 2);
                _SwapIfGreater(keys, lo + 1, lo + 2);
                return;
            }
            _InsertionSort(keys, lo, partitionSize);
            return;
        }
        if (depthLimit == 0)
        {
            _HeapSort(keys, lo, partitionSize);
            return;
        }
        depthLimit -= 1;
        int p = _PickPivotAndPartition(keys, lo, partitionSize);
        _IntroSort(keys, lo + p + 1, partitionSize - (p + 1), depthLimit);
        partitionSize = p;
    }
}

void _SwapIfGreater(_AdfSizedFile[] keys, int i, int j)
{
    if (_CompareSize(keys[i], keys[j]) > 0)
        _Swap(keys, i, j);
}

void _Swap(_AdfSizedFile[] keys, int i, int j)
{
    var t = keys[i];
    keys[i] = keys[j];
    keys[j] = t;
}

int _PickPivotAndPartition(_AdfSizedFile[] keys, int lo, int count)
{
    int hi = count - 1;
    int middle = hi >> 1;
    _SwapIfGreater(keys, lo, lo + middle);
    _SwapIfGreater(keys, lo, lo + hi);
    _SwapIfGreater(keys, lo + middle, lo + hi);
    var pivot = keys[lo + middle];
    _Swap(keys, lo + middle, lo + hi - 1);
    int left = 0;
    int right = hi - 1;
    while (left < right)
    {
        left += 1;
        while (_CompareSize(keys[lo + left], pivot) < 0)
            left += 1;
        right -= 1;
        while (_CompareSize(pivot, keys[lo + right]) < 0)
            right -= 1;
        if (left >= right)
            break;
        _Swap(keys, lo + left, lo + right);
    }
    if (left != hi - 1)
        _Swap(keys, lo + left, lo + hi - 1);
    return left;
}

void _HeapSort(_AdfSizedFile[] keys, int lo, int n)
{
    for (var i = n >> 1; i >= 1; i -= 1)
        _DownHeap(keys, lo, i, n);
    for (var i = n; i > 1; i -= 1)
    {
        _Swap(keys, lo, lo + i - 1);
        _DownHeap(keys, lo, 1, i - 1);
    }
}

void _DownHeap(_AdfSizedFile[] keys, int lo, int i, int n)
{
    var d = keys[lo + i - 1];
    while (i <= n >> 1)
    {
        int child = 2 * i;
        if (child < n && _CompareSize(keys[lo + child - 1], keys[lo + child]) < 0)
            child += 1;
        if (!(_CompareSize(d, keys[lo + child - 1]) < 0))
            break;
        keys[lo + i - 1] = keys[lo + child - 1];
        i = child;
    }
    keys[lo + i - 1] = d;
}

void _InsertionSort(_AdfSizedFile[] keys, int lo, int count)
{
    for (var i = 0; i < count - 1; i += 1)
    {
        var t = keys[lo + i + 1];
        int j = i;
        while (j >= 0 && _CompareSize(t, keys[lo + j]) < 0)
        {
            keys[lo + j + 1] = keys[lo + j];
            j -= 1;
        }
        keys[lo + j + 1] = t;
    }
}
