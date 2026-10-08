namespace Ambermoon;

using System;

/// Whether `path` is a file (not a directory).
bool IsFile(StringSlice path)
{
    return File.Exists(path) && !Directory.Exists(path);
}

/// The paths of the files in a directory (`Directory.GetFiles(directory)`), sorted by name (byte by byte); empty if
/// the directory does not exist.
List<string> GetFiles(StringSlice directory)
{
    var result = List<string>.Create();
    foreach (var name in Directory.GetEntries(directory))
    {
        var path = Path.Combine(directory, name);
        if (!Directory.Exists(path))
            result.Add(path);
    }
    return result;
}

/// The paths of the directories in a directory (`Directory.GetDirectories(directory)`), sorted by name.
List<string> GetDirectories(StringSlice directory)
{
    var result = List<string>.Create();
    foreach (var name in Directory.GetEntries(directory))
    {
        var path = Path.Combine(directory, name);
        if (Directory.Exists(path))
            result.Add(path);
    }
    return result;
}

/// The paths of the files in a directory whose names match `pattern` (`Directory.GetFiles(directory, pattern,
/// option)`): `*` is any number of characters, `?` one character, `*.*` all files. With `recursive` also the files of
/// all directories below it (the files of a directory first, then those of its directories, each sorted by name).
List<string> FindFiles(StringSlice directory, StringSlice pattern, bool recursive)
{
    var result = List<string>.Create();
    _FindFiles(directory, pattern == "*.*" ? "*" : pattern, recursive, result);
    return result;
}

void _FindFiles(StringSlice directory, StringSlice pattern, bool recursive, List<string> result)
{
    var directories = List<string>.Create();
    foreach (var name in Directory.GetEntries(directory))
    {
        var path = Path.Combine(directory, name);
        if (Directory.Exists(path))
            directories.Add(path);
        else if (MatchesWildcard(name, pattern))
            result.Add(path);
    }
    if (recursive)
    {
        foreach (var path in directories)
            _FindFiles(path, pattern, true, result);
    }
}

/// Whether `name` matches a file name pattern with `*` (any number of characters) and `?` (one character).
bool MatchesWildcard(StringSlice name, StringSlice pattern)
{
    // the usual greedy matching with a step back to the last '*'
    int n = 0;
    int p = 0;
    int star = -1;
    int starName = 0;
    while (n < name.Length)
    {
        if (p < pattern.Length && (pattern[p] == '?' || pattern[p] == name[n]) && pattern[p] != '*')
        {
            if (pattern[p] == '?')
                n = _NextCharacter(name, n);
            else
                n += 1;
            p += 1;
        }
        else if (p < pattern.Length && pattern[p] == '*')
        {
            star = p;
            starName = n;
            p += 1;
        }
        else if (star >= 0)
        {
            p = star + 1;
            starName = _NextCharacter(name, starName);
            n = starName;
        }
        else
            return false;
    }
    while (p < pattern.Length && pattern[p] == '*')
        p += 1;
    return p == pattern.Length;
}

// the index of the character after the one at 'i' (characters of more than one byte are one character for '?')
int _NextCharacter(StringSlice text, int i)
{
    i += 1;
    while (i < text.Length && (text[i] & 0xC0) == 0x80)
        i += 1;
    return i;
}

/// The text of a file like `File.ReadAllText(path, Encoding.UTF8)` of .NET: UTF-8 without a byte order mark, or UTF-16
/// or UTF-32 when the file starts with their byte order mark. Bytes that are no valid UTF-8 become U+FFFD (one for
/// each maximal invalid part, as .NET does). `null` if the file cannot be read.
Optional<string> ReadAllTextNet(StringSlice path)
{
    if (File.ReadAllBytes(path) is not uint8[] bytes)
        return null;
    return DecodeTextNet(bytes);
}

/// The text of bytes as [ReadAllTextNet] reads them.
string DecodeTextNet(uint8[] bytes)
{
    int n = bytes.Length;
    if (n >= 4 && bytes[0] == 0xFF && bytes[1] == 0xFE && bytes[2] == 0 && bytes[3] == 0)
        return _DecodeUtf32(bytes, 4, false);
    if (n >= 4 && bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 0xFE && bytes[3] == 0xFF)
        return _DecodeUtf32(bytes, 4, true);
    if (n >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE)
        return _DecodeUtf16(bytes, 2, false);
    if (n >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF)
        return _DecodeUtf16(bytes, 2, true);
    int start = n >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF ? 3 : 0;
    if (Encoding.UTF8().GetString(bytes, start, n - start) is string text)
        return text;
    return _RepairUtf8(bytes, start);
}

// UTF-8 with every maximal invalid part replaced by U+FFFD
string _RepairUtf8(uint8[] bytes, int start)
{
    var output = new uint8[(bytes.Length - start) * 3];
    int o = 0;
    int i = start;
    while (i < bytes.Length)
    {
        int b = bytes[i];
        if (b < 0x80)
        {
            output[o] = (uint8)b;
            o += 1;
            i += 1;
            continue;
        }
        // the number of continuation bytes and the range of the first of them
        int more = 0;
        int low = 0x80;
        int high = 0xBF;
        if (b >= 0xC2 && b <= 0xDF)
            more = 1;
        else if (b == 0xE0)
        {
            more = 2;
            low = 0xA0;
        }
        else if ((b >= 0xE1 && b <= 0xEC) || b == 0xEE || b == 0xEF)
            more = 2;
        else if (b == 0xED)
        {
            more = 2;
            high = 0x9F;
        }
        else if (b == 0xF0)
        {
            more = 3;
            low = 0x90;
        }
        else if (b >= 0xF1 && b <= 0xF3)
            more = 3;
        else if (b == 0xF4)
        {
            more = 3;
            high = 0x8F;
        }
        int j = i + 1;
        int got = 0;
        while (got < more && j < bytes.Length)
        {
            int c = bytes[j];
            int lo = got == 0 ? low : 0x80;
            int hi = got == 0 ? high : 0xBF;
            if (c < lo || c > hi)
                break;
            j += 1;
            got += 1;
        }
        if (more > 0 && got == more)
        {
            for (var k = i; k < j; k += 1)
            {
                output[o] = bytes[k];
                o += 1;
            }
        }
        else
            o = _PutCodePoint(output, o, 0xFFFD);
        i = more == 0 ? i + 1 : j;
    }
    return string.FromBytes(output, 0, o);
}

string _DecodeUtf16(uint8[] bytes, int start, bool bigEndian)
{
    var output = new uint8[(bytes.Length - start) / 2 * 3 + 3];
    int o = 0;
    int i = start;
    while (i + 1 < bytes.Length)
    {
        int unit = bigEndian ? (bytes[i] << 8) | bytes[i + 1] : bytes[i] | (bytes[i + 1] << 8);
        i += 2;
        if (unit >= 0xD800 && unit <= 0xDBFF && i + 1 < bytes.Length)
        {
            int next = bigEndian ? (bytes[i] << 8) | bytes[i + 1] : bytes[i] | (bytes[i + 1] << 8);
            if (next >= 0xDC00 && next <= 0xDFFF)
            {
                i += 2;
                o = _PutCodePoint(output, o, 0x10000 + ((unit - 0xD800) << 10) + (next - 0xDC00));
                continue;
            }
        }
        o = _PutCodePoint(output, o, unit >= 0xD800 && unit <= 0xDFFF ? 0xFFFD : unit);
    }
    if (i < bytes.Length)
        o = _PutCodePoint(output, o, 0xFFFD);
    return string.FromBytes(output, 0, o);
}

string _DecodeUtf32(uint8[] bytes, int start, bool bigEndian)
{
    var output = new uint8[(bytes.Length - start) / 4 * 4 + 3];
    int o = 0;
    int i = start;
    while (i + 3 < bytes.Length)
    {
        int64 value = bigEndian
            ? ((int64)bytes[i] << 24) | (bytes[i + 1] << 16) | (bytes[i + 2] << 8) | bytes[i + 3]
            : bytes[i] | (bytes[i + 1] << 8) | (bytes[i + 2] << 16) | ((int64)bytes[i + 3] << 24);
        i += 4;
        bool valid = value <= 0x10FFFF && (value < 0xD800 || value > 0xDFFF);
        o = _PutCodePoint(output, o, valid ? (int)value : 0xFFFD);
    }
    if (i < bytes.Length)
        o = _PutCodePoint(output, o, 0xFFFD);
    return string.FromBytes(output, 0, o);
}

// writes a code point as UTF-8 at 'o'; the index behind it
int _PutCodePoint(uint8[] output, int o, int codePoint)
{
    if (codePoint < 0x80)
    {
        output[o] = (uint8)codePoint;
        return o + 1;
    }
    if (codePoint < 0x800)
    {
        output[o] = (uint8)(0xC0 | (codePoint >> 6));
        output[o + 1] = (uint8)(0x80 | (codePoint & 0x3F));
        return o + 2;
    }
    if (codePoint < 0x10000)
    {
        output[o] = (uint8)(0xE0 | (codePoint >> 12));
        output[o + 1] = (uint8)(0x80 | ((codePoint >> 6) & 0x3F));
        output[o + 2] = (uint8)(0x80 | (codePoint & 0x3F));
        return o + 3;
    }
    output[o] = (uint8)(0xF0 | (codePoint >> 18));
    output[o + 1] = (uint8)(0x80 | ((codePoint >> 12) & 0x3F));
    output[o + 2] = (uint8)(0x80 | ((codePoint >> 6) & 0x3F));
    output[o + 3] = (uint8)(0x80 | (codePoint & 0x3F));
    return o + 4;
}

/// An entry of a directory tree ([FileSystemEntriesWindows]): its path and whether it is a directory.
struct NetEntry
{
    string Path;
    bool IsDirectory;
}

/// The files and directories below `directory` in the order in which .NET gives them on Windows
/// (`Directory.GetFiles(directory, "*", SearchOption.AllDirectories)`, `EnumerateFileSystemInfos`): the entries of a
/// directory in the order of NTFS (the names compared in upper case), then those of its directories, level by level.
/// The directory itself is not included; empty if it does not exist.
List<NetEntry> FileSystemEntriesWindows(StringSlice directory)
{
    var result = List<NetEntry>.Create();
    var pending = Queue<string>.Create();
    pending.Enqueue(directory.ToString());
    while (pending.TryDequeue() is string current)
    {
        var names = List<_NtfsName>.Create();
        foreach (var name in Directory.GetEntries(current))
            names.Add(_NtfsName { Key = ToUpperNet(name), Name = name });
        names.Sort();
        foreach (var entry in names)
        {
            var path = Path.Combine(current, entry.Name);
            bool isDirectory = Directory.Exists(path);
            result.Add(NetEntry { Path = path, IsDirectory = isDirectory });
            if (isDirectory)
                pending.Enqueue(path);
        }
    }
    return result;
}

/// The paths of the files below `directory` in the order of .NET on Windows (see [FileSystemEntriesWindows]).
List<string> GetFilesWindows(StringSlice directory)
{
    var result = List<string>.Create();
    foreach (var entry in FileSystemEntriesWindows(directory))
    {
        if (!entry.IsDirectory)
            result.Add(entry.Path);
    }
    return result;
}

// A name in the order of NTFS: upper case, ordinal.
struct _NtfsName : IComparable<_NtfsName>
{
    string Key;
    string Name;

    int CompareTo(_NtfsName other)
    {
        int c = Key.CompareTo(other.Key);
        return c != 0 ? c : Name.CompareTo(other.Name);
    }
}
