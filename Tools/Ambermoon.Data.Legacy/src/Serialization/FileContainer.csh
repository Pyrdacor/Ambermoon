namespace Ambermoon.Data.Legacy.Serialization;

using System;

/// A file of the game as [FileReader] reads it: a single file (number 1) or the files of a container (numbers from
/// 1 on), decrypted and decompressed. (IFileContainer of Ambermoon.Data.Common.)
struct FileContainer
{
    /// The name it was read with.
    string Name;
    /// Its format.
    FileType FileType;
    /// The files by their number, each a reader at position 0.
    Dictionary<int, DataReader> Files;

    /// The header of the format: (uint)FileType (for JH without the key).
    uint32 Header()
    {
        return (uint32)FileType;
    }

    /// The numbers of the files in ascending order.
    int[] Numbers()
    {
        var keys = Files.Keys();
        var numbers = List<int>.Create(keys.Length);
        foreach (var key in keys)
            numbers.Add(key);
        numbers.Sort();
        return numbers.ToArray();
    }
}
