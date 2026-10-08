namespace Ambermoon.Release;

using System;
using System.Compression;
using Ambermoon;

/// A zip file of a folder like `ZipFile.CreateFromDirectory(folder, zip, CompressionLevel.SmallestSize, false)` of
/// .NET on Windows: the files and the empty folders in the order of .NET (breadth first, NTFS order), names with `/`,
/// the times of the last write as MS-DOS times; the files deflated (empty ones stored), header fields as .NET writes
/// them: .NET 9 and newer set the flag of the maximum compression in the files (`net9`), .NET 8 does not. (The deflate
/// data is the one of System.Compression at level 9, not the one of zlib.)
Error<void> CreateZip(StringSlice sourceDirectory, StringSlice zipPath, bool net9)
{
    var output = List<uint8>.Create();
    var central = List<uint8>.Create();
    int count = 0;
    string root = sourceDirectory.ToString();
    foreach (var entry in FileSystemEntriesWindows(sourceDirectory))
    {
        string name = _RelativeName(root, entry.Path);
        uint8[] data;
        bool directory = entry.IsDirectory;
        if (directory)
        {
            if (Directory.GetEntries(entry.Path).Count() > 0)
                continue;   // only empty folders get an entry
            name += "/";
            data = new uint8[0];
        }
        else
        {
            var read = File.ReadAllBytes(entry.Path);
            if (read is not uint8[] bytes)
                return error("cannot read '" + entry.Path + "'");
            data = bytes;
        }
        // (.NET gives the entries of empty folders the current time)
        var time = directory ? ReleaseNow() : File.GetLastWriteTime(entry.Path) is DateTime t ? t : DateTime.Now();
        bool stored = directory || data.Length == 0;
        var compressed = stored ? data : Deflate.Compress(data, 9);
        var nameBytes = name.AsBytes().ToArray();
        int flags = directory || !net9 ? 0 : 2; // 2: maximum compression
        if (!_IsAscii(name))
            flags |= 0x800;                     // UTF-8 names
        uint32 crc = Crc32.Compute(data);
        uint32 dos = _DosDateTime(time);
        int offset = output.Count();

        _Le32(ref output, 0x04034b50);
        _Le16(ref output, 20);                  // version needed
        _Le16(ref output, flags);
        _Le16(ref output, stored ? 0 : 8);
        _Le32(ref output, dos);
        _Le32(ref output, crc);
        _Le32(ref output, (uint32)compressed.Length);
        _Le32(ref output, (uint32)data.Length);
        _Le16(ref output, nameBytes.Length);
        _Le16(ref output, 0);
        output.AddRange(nameBytes);
        output.AddRange(compressed);

        _Le32(ref central, 0x02014b50);
        _Le16(ref central, 20);                 // made by: MS-DOS, 2.0
        _Le16(ref central, 20);
        _Le16(ref central, flags);
        _Le16(ref central, stored ? 0 : 8);
        _Le32(ref central, dos);
        _Le32(ref central, crc);
        _Le32(ref central, (uint32)compressed.Length);
        _Le32(ref central, (uint32)data.Length);
        _Le16(ref central, nameBytes.Length);
        _Le16(ref central, 0);                  // extra
        _Le16(ref central, 0);                  // comment
        _Le16(ref central, 0);                  // disk
        _Le16(ref central, 0);                  // internal attributes
        _Le32(ref central, 0);                  // external attributes
        _Le32(ref central, (uint32)offset);
        central.AddRange(nameBytes);
        count += 1;
    }
    int centralOffset = output.Count();
    output.AddRange(central.ToArray());
    _Le32(ref output, 0x06054b50);
    _Le16(ref output, 0);
    _Le16(ref output, 0);
    _Le16(ref output, count);
    _Le16(ref output, count);
    _Le32(ref output, (uint32)central.Count());
    _Le32(ref output, (uint32)centralOffset);
    _Le16(ref output, 0);
    if (File.WriteAllBytes(zipPath, output.ToArray()) is error e)
        return error(e.Message);
    return;
}

/// Extracts a zip file into a folder like `ZipFile.ExtractToDirectory`: folders are created, the files get the times
/// of their entries as their last write times.
Error<void> ExtractZip(StringSlice zipPath, StringSlice targetDirectory)
{
    var read = File.ReadAllBytes(zipPath);
    if (read is not uint8[] zip)
        return error("cannot read '" + zipPath + "'");
    int end = -1;
    for (var i = zip.Length - 22; i >= 0 && i >= zip.Length - 22 - 65535; i -= 1)
    {
        if (_ReadLe32(zip, i) == 0x06054b50u)
        {
            end = i;
            break;
        }
    }
    if (end < 0)
        return error("'" + zipPath + "' is no zip file");
    int count = _ReadLe16(zip, end + 10);
    int pos = (int)_ReadLe32(zip, end + 16);
    Directory.Create(targetDirectory);
    for (var n = 0; n < count; n += 1)
    {
        if (pos + 46 > zip.Length || _ReadLe32(zip, pos) != 0x02014b50u)
            return error("damaged zip file '" + zipPath + "'");
        int method = _ReadLe16(zip, pos + 10);
        uint32 dos = _ReadLe32(zip, pos + 12);
        int compressedSize = (int)_ReadLe32(zip, pos + 20);
        int nameLength = _ReadLe16(zip, pos + 28);
        int extraLength = _ReadLe16(zip, pos + 30);
        int commentLength = _ReadLe16(zip, pos + 32);
        int local = (int)_ReadLe32(zip, pos + 42);
        string name = string.FromBytes(zip, pos + 46, nameLength).Replace("\\", "/");
        pos += 46 + nameLength + extraLength + commentLength;

        if (name.Contains("..") || name.StartsWith("/"))
            return error("the zip entry '" + name + "' is outside of the folder");
        string target = Path.Combine(targetDirectory, name);
        if (name.EndsWith("/"))
        {
            Directory.Create(target);
            continue;
        }
        string parent = Path.GetDirectory(target);
        if (parent.Length > 0)
            Directory.Create(parent);
        int dataStart = local + 30 + _ReadLe16(zip, local + 26) + _ReadLe16(zip, local + 28);
        if (dataStart + compressedSize > zip.Length)
            return error("damaged zip file '" + zipPath + "'");
        var raw = zip[dataStart..dataStart + compressedSize];
        uint8[] data;
        if (method == 0)
            data = raw.ToArray();
        else if (method == 8)
        {
            var inflated = Deflate.Decompress(raw);
            if (inflated is not uint8[] bytes)
                return error("damaged zip entry '" + name + "': " + inflated.Message);
            data = bytes;
        }
        else
            return error("the zip entry '" + name + "' has an unknown compression method");
        if (File.WriteAllBytes(target, data) is error e)
            return error(e.Message);
        File.SetLastWriteTime(target, _FromDosDateTime(dos));
    }
    return;
}

string _RelativeName(string root, string path)
{
    int length = root.Length;
    if (!root.EndsWith("/") && !root.EndsWith("\\"))
        length += 1;
    return path[length..].ToString().Replace("\\", "/");
}

bool _IsAscii(StringSlice text)
{
    foreach (var b in text.AsBytes())
    {
        if (b >= 0x80)
            return false;
    }
    return true;
}

// The MS-DOS date (high word) and time (low word) of a local time; before 1980: 1980-01-01 00:00 (like .NET).
uint32 _DosDateTime(DateTime time)
{
    if (time.Year() < 1980)
        return (uint32)((1 << 5) | 1) << 16;
    uint32 dosTime = (uint32)((time.Second() / 2) | (time.Minute() << 5) | (time.Hour() << 11));
    uint32 dosDate = (uint32)(time.Day() | (time.Month() << 5) | ((time.Year() - 1980) << 9));
    return (dosDate << 16) | dosTime;
}

DateTime _FromDosDateTime(uint32 dos)
{
    int date = (int)(dos >> 16);
    int time = (int)(dos & 0xFFFF);
    int year = 1980 + (date >> 9);
    int month = Math.Max(1, Math.Min(12, (date >> 5) & 15));
    int day = Math.Max(1, date & 31);
    int hour = Math.Min(23, time >> 11);
    int minute = Math.Min(59, (time >> 5) & 63);
    int second = Math.Min(59, (time & 31) * 2);
    return DateTime.Create(year, month, day, hour, minute, second);
}

void _Le16(ref List<uint8> output, int value)
{
    output.Add((uint8)value);
    output.Add((uint8)(value >> 8));
}

void _Le32(ref List<uint8> output, uint32 value)
{
    output.Add((uint8)value);
    output.Add((uint8)(value >> 8));
    output.Add((uint8)(value >> 16));
    output.Add((uint8)(value >> 24));
}

int _ReadLe16(uint8[] data, int pos)
{
    return data[pos] | (data[pos + 1] << 8);
}

uint32 _ReadLe32(uint8[] data, int pos)
{
    return (uint32)data[pos] | ((uint32)data[pos + 1] << 8) | ((uint32)data[pos + 2] << 16) | ((uint32)data[pos + 3] << 24);
}
