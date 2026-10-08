namespace Amiga.FileFormats.LHA;

using System;
using Ambermoon;

/// The results of writing an LHA archive.
enum LHAWriteResult : int
{
    /// A warning: the empty directories were left out.
    OmittedEmptyDirectories = -1,
    Success = 0,
    DiskFullError = 1,
    WriteAccessError = 2,
    UnsupportedCompressionMethod = 3,
    InvalidLHAObject = 4
}

// A file of an archive.
struct _LhaFile
{
    string Name;
    uint8[] Data;
    DateTime LastWrite;
}

// A directory of an archive: its files and directories in the order in which they were added.
struct _LhaDirectory
{
    string Name;
    string Path;          // the root is "/", its directories "//name", below them "//name/sub" (as in the original)
    List<int> Files;      // indices into LhaArchive.Files
    List<int> Directories;
}

/// An LHA archive that is written (Amiga.FileFormats.LHA's `Archive.CreateEmpty`): files are added with their path
/// (directories are made for them), then [LhaArchive.Write] makes the archive with level 1 headers.
struct LhaArchive
{
    List<_LhaDirectory> Directories;
    List<_LhaFile> Files;

    static LhaArchive Create()
    {
        var archive = LhaArchive { Directories = List<_LhaDirectory>.Create(), Files = List<_LhaFile>.Create() };
        archive.Directories.Add(_LhaDirectory { Name = "<root>", Path = "/", Files = List<int>.Create(), Directories = List<int>.Create() });
        return archive;
    }

    /// Adds a file; `path` is relative (`/` or `\` between directories), the time is the one of its header.
    void AddFile(StringSlice path, uint8[] data, DateTime lastWrite)
    {
        string normalized = path.ToString().Replace("\\", "/");
        var parts = normalized.Split('/');
        int parent = 0;
        for (var i = 0; i < parts.Length - 1; i += 1)
            parent = _AddDirectory(parent, parts[i].ToString());
        Files.Add(_LhaFile { Name = parts[parts.Length - 1].ToString(), Data = data, LastWrite = lastWrite });
        Directories[parent].Files.Add(Files.Count() - 1);
    }

    int _AddDirectory(int parent, string name)
    {
        foreach (var index in Directories[parent].Directories)
        {
            if (Directories[index].Name == name)   // (case-sensitive, like the dictionary of the original)
                return index;
        }
        Directories.Add(_LhaDirectory { Name = name, Path = Directories[parent].Path + "/" + name, Files = List<int>.Create(),
                                        Directories = List<int>.Create() });
        int added = Directories.Count() - 1;
        Directories[parent].Directories.Add(added);
        return added;
    }

    /// The bytes of the archive: the files of a directory, then its directories (empty ones are not stored). An error
    /// for a time that a header cannot hold (before 1980 or after 2107).
    Error<uint8[]> Write(CompressionMethod method)
    {
        var output = List<uint8>.Create();
        try _WriteDirectory(ref output, 0, method);
        return output.ToArray();
    }

    Error<void> _WriteDirectory(ref List<uint8> output, int index, CompressionMethod method)
    {
        foreach (var fileIndex in Directories[index].Files)
        {
            var file = Files[fileIndex];
            var compressed = LhaCompress(file.Data, method);
            var used = compressed.Stored ? CompressionMethod.None : method;
            try _WriteHeader(ref output, Directories[index].Path, file.Name, used, compressed.Data.Length, file.Data.Length,
                             file.LastWrite, compressed.Crc);
            output.AddRange(compressed.Data);
        }
        foreach (var directory in Directories[index].Directories)
            try _WriteDirectory(ref output, directory, method);
        return;
    }
}

// The header of an entry (level 1): the name in the header (or in an extended header when longer than 228
// characters), the directory in an extended header (0xff between directories).
Error<void> _WriteHeader(ref List<uint8> output, string directoryName, string name, CompressionMethod method, int packedSize,
                          int originalSize, DateTime lastWrite, uint16 crc)
{
    var timestamp = _GenericTimestamp(lastWrite);
    if (timestamp is not uint32 time)
        return error("Dates before 1980 or after 2107 are not supported.");
    var nameBytes = _AsciiBytes(name);
    int nameLength = nameBytes.Length > 228 ? 0 : nameBytes.Length;
    var h = List<uint8>.Create();
    h.Add((uint8)(25 + nameLength));   // header size
    h.Add(0);                           // checksum, set below
    foreach (var b in CompressionMethodName(method).AsBytes())
        h.Add(b);
    _AddLittle32(ref h, 0);             // skip size, set below
    _AddLittle32(ref h, (uint32)originalSize);
    _AddLittle32(ref h, time);
    h.Add(0x20);                        // MS-DOS attribute (a normal file)
    h.Add(1);                           // level
    h.Add((uint8)nameLength);
    if (nameLength > 0)
        h.AddRange(nameBytes);
    h.Add((uint8)crc);
    h.Add((uint8)(crc >> 8));
    h.Add('A');                         // the operating system: Amiga
    if (nameLength == 0)
        _AddExtendedHeader(ref h, 0x01, nameBytes);
    var directory = directoryName.TrimStart('/');
    if (directory.Length > 0)
    {
        var dir = directory.EndsWith("/") ? directory.ToString() : directory.ToString() + "/";
        var dirBytes = _AsciiBytes(dir);
        for (var i = 0; i < dirBytes.Length; i += 1)
        {
            if (dirBytes[i] == '/')
                dirBytes[i] = 0xff;
        }
        _AddExtendedHeader(ref h, 0x02, dirBytes);
    }
    h.Add(0);                           // the end of the extended headers
    h.Add(0);
    uint32 skipSize = (uint32)(h.Count() - (27 + nameLength) + packedSize);
    h[7] = (uint8)skipSize;
    h[8] = (uint8)(skipSize >> 8);
    h[9] = (uint8)(skipSize >> 16);
    h[10] = (uint8)(skipSize >> 24);
    int checksum = 0;
    for (var i = 2; i < 2 + 25 + nameLength; i += 1)
        checksum += h[i];
    h[1] = (uint8)(checksum & 0xff);
    output.AddRange(h.ToArray());
    return;
}

void _AddExtendedHeader(ref List<uint8> h, uint8 type, uint8[] data)
{
    int size = 1 + data.Length + 2;   // the type, the data, the size of the next extension
    h.Add((uint8)size);
    h.Add((uint8)(size >> 8));
    h.Add(type);
    h.AddRange(data);
}

void _AddLittle32(ref List<uint8> h, uint32 value)
{
    h.Add((uint8)value);
    h.Add((uint8)(value >> 8));
    h.Add((uint8)(value >> 16));
    h.Add((uint8)(value >> 24));
}

// Encoding.ASCII.GetBytes of .NET: '?' for each UTF-16 unit that is not ASCII.
uint8[] _AsciiBytes(StringSlice text)
{
    var result = List<uint8>.Create();
    int i = 0;
    var bytes = text.AsBytes();
    while (i < bytes.Length)
    {
        int b = bytes[i];
        if (b < 0x80)
        {
            result.Add((uint8)b);
            i += 1;
            continue;
        }
        int length = b >= 0xF0 ? 4 : b >= 0xE0 ? 3 : 2;
        result.Add('?');
        if (length == 4)
            result.Add('?');   // a surrogate pair
        i += length;
    }
    return result.ToArray();
}

// The MS-DOS timestamp of a local time (2 s steps); null before 1980 and after 2107.
Optional<uint32> _GenericTimestamp(DateTime time)
{
    int year = time.Year();
    if (year < 1980 || year > 2107)
        return null;
    return ((uint32)(year - 1980) << 25) | ((uint32)time.Month() << 21) | ((uint32)time.Day() << 16) | ((uint32)time.Hour() << 11) |
           ((uint32)time.Minute() << 5) | ((uint32)time.Second() >> 1);
}

/// Writes all files below `directoryPath` into the LHA archive `lhaFilePath` (`LHAWriter.WriteLHAFile`): in the order
/// of .NET on Windows, with the times of their last change, compressed with `method` (stored when that does not make a
/// file smaller); empty directories are left out.
LHAWriteResult WriteLhaFile(StringSlice lhaFilePath, StringSlice directoryPath, CompressionMethod method)
{
    if (CompressionMethodName(method).Length == 0)
        return LHAWriteResult.UnsupportedCompressionMethod;
    var archive = LhaArchive.Create();
    int rootLength = directoryPath.Length;
    if (!directoryPath.EndsWith("/") && !directoryPath.EndsWith("\\"))
        rootLength += 1;
    foreach (var file in GetFilesWindows(directoryPath))
    {
        if (File.ReadAllBytes(file) is not uint8[] data)
            return LHAWriteResult.WriteAccessError;
        var time = File.GetLastWriteTime(file) is DateTime t ? t : DateTime.Now();
        archive.AddFile(file[rootLength..], data, time);
    }
    var written = archive.Write(method);
    if (written is not uint8[] bytes)
        return LHAWriteResult.WriteAccessError;
    if (File.WriteAllBytes(lhaFilePath, bytes) is error)
        return LHAWriteResult.WriteAccessError;
    return LHAWriteResult.Success;
}
