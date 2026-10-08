namespace Ambermoon.Release;

using System;
using System.Compression;
using Ambermoon;

/// A tar.gz file of the files of a folder like SharpZipLib's `TarArchive` over a `GZipOutputStream` (as the release
/// creators use it): the files in the order of .NET (breadth first, NTFS order), named by their paths without
/// `workingDirectory` (the current directory of the original) or else without the root of the path, `/` between
/// directories; GNU tar headers with the mode 0700, the user "user" and the group "None", the time of the last write;
/// records of 10240 bytes. The gzip data is the one of System.Compression at level 6.
Error<void> CreateTarball(StringSlice sourceDirectory, StringSlice tarballPath, StringSlice workingDirectory, DateTime now)
{
    var tar = List<uint8>.Create();
    foreach (var file in GetFilesWindows(sourceDirectory))
    {
        var read = File.ReadAllBytes(file);
        if (read is not uint8[] data)
            return error("cannot read '" + file + "'");
        string name = _TarName(file, workingDirectory);
        var time = File.GetLastWriteTimeUtc(file) is DateTime t ? t : DateTime.UtcNow();
        var nameBytes = name.AsBytes().ToArray();
        if (nameBytes.Length > 100)
        {
            // a GNU long name: an entry "././@LongLink" (type L) with the name, then the entry
            tar.AddRange(_TarHeader("././@LongLink".AsBytes(), 420, nameBytes.Length + 1, 0, 'L'));
            var longName = new uint8[(nameBytes.Length + 1 + 511) / 512 * 512];
            for (var i = 0; i < nameBytes.Length; i += 1)
                longName[i] = nameBytes[i];
            tar.AddRange(longName);
        }
        tar.AddRange(_TarHeader(nameBytes, 33216, data.Length, time.ToUnixSeconds(), '0'));
        tar.AddRange(data);
        int padding = (512 - data.Length % 512) % 512;
        for (var i = 0; i < padding; i += 1)
            tar.Add(0);
    }
    // the end: two empty blocks, then the record is filled up
    for (var i = 0; i < 1024; i += 1)
        tar.Add(0);
    while (tar.Count() % 10240 != 0)
        tar.Add(0);

    var bytes = tar.ToArray();
    var gz = List<uint8>.Create();
    int mtime = (int)now.ToUnixSeconds();
    gz.AddRange([0x1f, 0x8b, 8, 0, (uint8)mtime, (uint8)(mtime >> 8), (uint8)(mtime >> 16), (uint8)(mtime >> 24), 0, 255]);
    gz.AddRange(Deflate.Compress(bytes, 6));
    _Le32(ref gz, Crc32.Compute(bytes));
    _Le32(ref gz, (uint32)bytes.Length);
    if (File.WriteAllBytes(tarballPath, gz.ToArray()) is error e)
        return error(e.Message);
    return;
}

// TarEntry.GetFileTarHeader: the path without the current directory (ordinal), without its root, '\' as '/'.
string _TarName(StringSlice path, StringSlice workingDirectory)
{
    string name = path.ToString().Replace("/", "\\");
    string cwd = workingDirectory.ToString().Replace("/", "\\");
    if (cwd.Length > 0 && name.StartsWith(cwd))
        name = name[cwd.Length..].ToString();
    // the root: a drive ("C:") and the slashes after it
    int start = 0;
    if (name.Length >= 2 && name[1] == ':')
        start = 2;
    while (start < name.Length && (name[start] == '\\' || name[start] == '/'))
        start += 1;
    return name[start..].ToString().Replace("\\", "/");
}

uint8[] _TarHeader(ReadOnlySlice<uint8> name, int mode, int64 size, int64 mtime, char type)
{
    var h = new uint8[512];
    for (var i = 0; i < name.Length && i < 100; i += 1)
        h[i] = name[i];
    _Octal(h, 100, 8, mode);
    _Octal(h, 108, 8, 0);
    _Octal(h, 116, 8, 0);
    _Octal(h, 124, 12, size);
    _Octal(h, 136, 12, mtime);
    for (var i = 148; i < 156; i += 1)
        h[i] = ' ';
    h[156] = (uint8)type;
    var magic = "ustar\0 \0".AsBytes();
    for (var i = 0; i < 8; i += 1)
        h[257 + i] = magic[i];
    var user = "user".AsBytes();
    for (var i = 0; i < user.Length; i += 1)
        h[265 + i] = user[i];
    var group = "None".AsBytes();
    for (var i = 0; i < group.Length; i += 1)
        h[297 + i] = group[i];
    int checksum = 0;
    for (var i = 0; i < 512; i += 1)
        checksum += h[i];
    _Octal(h, 148, 7, checksum);   // six digits and a zero; the space after it stays
    return h;
}

// GetOctalBytes of SharpZipLib: the digits right-aligned with leading zeros, then a zero byte.
void _Octal(uint8[] h, int offset, int length, int64 value)
{
    int index = length - 1;
    h[offset + index] = 0;
    index -= 1;
    int64 v = value;
    while (index >= 0 && v > 0)
    {
        h[offset + index] = (uint8)('0' + (int)(v & 7));
        v >>= 3;
        index -= 1;
    }
    while (index >= 0)
    {
        h[offset + index] = '0';
        index -= 1;
    }
}
