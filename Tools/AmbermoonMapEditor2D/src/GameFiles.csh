// The files of the game on disk: containers are changed by replacing the encoded data of single subfiles, so that the
// other subfiles keep their bytes (the original compressed some files differently than the LOB packer of the tools).

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

/// A container file as it is stored: its header and the encoded data of its subfiles (index 0 is subfile 1).
struct RawContainer
{
    FileType FileType;
    List<uint8[]> Subfiles;

    /// Reads the subfiles of a container file without decoding them.
    /// @error the file is no container or is damaged.
    static Error<RawContainer> Read(uint8[] data)
    {
        if (data.Length < 6)
            return error("The file is too short for a container.");
        uint32 header = ((uint32)data[0] << 24) | ((uint32)data[1] << 16) | ((uint32)data[2] << 8) | (uint32)data[3];
        var fileType = (FileType)header;
        if (fileType != FileType.AMNP && fileType != FileType.AMPC && fileType != FileType.AMBR && fileType != FileType.AMNC)
            return error("The file is no container (AMNP, AMPC, AMBR or AMNC).");
        int count = ((int)data[4] << 8) | (int)data[5];
        int position = 6 + 4 * count;
        if (position > data.Length)
            return error("The container is damaged.");
        var subfiles = List<uint8[]>.Create(count);
        for (var i = 0; i < count; i += 1)
        {
            int at = 6 + 4 * i;
            int size = ((int)data[at] << 24) | ((int)data[at + 1] << 16) | ((int)data[at + 2] << 8) | (int)data[at + 3];
            if (size < 0 || position + size > data.Length)
                return error("The container is damaged.");
            var subfile = new uint8[size];
            Array.Copy(data, position, subfile, 0, size);
            subfiles.Add(subfile);
            position += size;
        }
        return RawContainer { FileType = fileType, Subfiles = subfiles };
    }

    /// The container as it is stored.
    uint8[] ToArray()
    {
        var writer = new DataWriter();
        writer.WriteDword((uint32)FileType);
        writer.WriteWord((uint16)Subfiles.Count());
        foreach (var subfile in Subfiles)
            writer.WriteDword((uint32)subfile.Length);
        foreach (var subfile in Subfiles)
            writer.WriteBytes(subfile);
        return writer.ToArray();
    }

    /// Replaces the data of a subfile (number from 1 on), encoded like the container encodes it (LOB compression and JH
    /// encryption with the number as key). Subfiles are added up to the number if there are less.
    /// @error the data cannot be encoded.
    Error<void> Replace(int number, uint8[] data)
    {
        while (Subfiles.Count() < number)
            Subfiles.Add(new uint8[0]);
        Subfiles[number - 1] = try _Encode(number, data);
        return;
    }

    /// Adds empty subfiles until there are `count` of them.
    void EnsureCount(int count)
    {
        while (Subfiles.Count() < count)
            Subfiles.Add(new uint8[0]);
    }

    // the encoded data of a subfile: a container of the same type with only this subfile, cut out of it
    Error<uint8[]> _Encode(int number, uint8[] data)
    {
        if (data.Length == 0)
            return new uint8[0];
        var files = Dictionary<uint32, uint8[]>.Create();
        files[(uint32)number] = data;
        var writer = new DataWriter();
        try FileWriter.WriteContainer(ref writer, files, FileType);
        var container = try Read(writer.ToArray());
        return container.Subfiles[number - 1];
    }
}

/// Replaces a subfile of a container file on disk.
/// @error the file cannot be read or written, or is no container.
Error<void> ReplaceSubfile(string path, int number, uint8[] data)
{
    if (File.ReadAllBytes(path) is not uint8[] bytes)
        return error($"Could not read '{path}'.");
    var container = try RawContainer.Read(bytes);
    try container.Replace(number, data);
    if (File.WriteAllBytes(path, container.ToArray()) is error)
        return error($"Could not write '{path}'.");
    return;
}

/// Makes a container file on disk have at least `count` subfiles (empty ones are added).
/// @error the file cannot be read or written, or is no container.
Error<void> EnsureSubfileCount(string path, int count)
{
    if (File.ReadAllBytes(path) is not uint8[] bytes)
        return error($"Could not read '{path}'.");
    var container = try RawContainer.Read(bytes);
    if (container.Subfiles.Count() >= count)
        return;
    container.EnsureCount(count);
    if (File.WriteAllBytes(path, container.ToArray()) is error)
        return error($"Could not write '{path}'.");
    return;
}

/// The data of a tileset as it is stored in Icon_data.amb (TilesetWriter of Ambermoon.net).
uint8[] WriteTileset(Tileset tileset)
{
    var writer = new DataWriter();
    writer.WriteWord((uint16)tileset.Tiles.Length);
    foreach (var tile in tileset.Tiles)
    {
        writer.WriteDword((uint32)tile.Flags);
        writer.WriteWord((uint16)tile.GraphicIndex);
        writer.WriteByte((uint8)tile.NumAnimationFrames);
        writer.WriteByte(tile.ColorIndex);
    }
    return writer.ToArray();
}
