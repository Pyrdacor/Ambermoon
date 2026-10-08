namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;

// the first bytes of the first hunk of an imploded executable
const ReadOnlySlice<uint8> _ImplodeHunkHeader = [0x48, 0xe7, 0xff, 0xff, 0x49, 0xfa, 0x00, 0x5e, 0x3c, 0x3c];

/// The kinds of hunks of an Amiga executable.
enum HunkType : uint32
{
    Code = 0x3E9,
    Data = 0x3EA,
    BSS = 0x3EB,
    RELOC32 = 0x3EC,
    END = 0x3F2
}

/// A hunk of an Amiga executable: code or data (with `Data`), BSS (only a size), RELOC32 (relocations: for each hunk
/// number the offsets, in `Entries`) or END.
struct Hunk
{
    HunkType Type;
    /// The size in dwords (code, data, BSS) or in bytes (RELOC32).
    uint32 Size;
    uint32 MemoryFlags;
    /// The number of dwords of the data (code, data) or to allocate (BSS).
    uint32 NumEntries;
    uint8[] Data;
    Dictionary<uint32, List<uint32>> Entries;

    /// A code or data hunk of `data` (its length a multiple of 4).
    /// @error the size is no multiple of 4.
    static Error<Hunk> Create(HunkType type, uint32 memoryFlags, uint8[] data)
    {
        if (data.Length % 4 != 0)
            return error("Hunk data size must be a multiple of 4.");
        uint32 entries = (uint32)data.Length / 4;
        return Hunk { Type = type, MemoryFlags = memoryFlags, Data = data, Size = entries, NumEntries = entries };
    }

    /// A BSS hunk that allocates `numEntries` dwords.
    static Hunk CreateBss(uint32 memoryFlags, uint32 numEntries)
    {
        return Hunk { Type = HunkType.BSS, MemoryFlags = memoryFlags, Size = numEntries, NumEntries = numEntries };
    }

    /// An END hunk.
    static Hunk CreateEnd()
    {
        return Hunk { Type = HunkType.END };
    }
}

/// Reads and writes Amiga executables (hunk files), and executables packed with the Imploder ("deplodes" them).
///
/// The imploder creates
/// - 1 first code hunk (startup code)
/// - n BSS hunks (one for each in the deploded file except for RELOC32 hunks) which allocate empty memory
/// - then another code hunk (actual decompression logic)
/// - then a data hunk (compressed data of all destination hunks)
/// - and finally another BSS hunk (decompression buffer)
///
/// The hunk sizes of the deploded hunks match the sizes of the BSS allocations. AM2_CPU has 8 hunks: code, RELOC32,
/// 2 BSS, 2 data (the data of the game), another RELOC32 and another BSS.
struct AmigaExecutable
{
    /// Writes the hunks as an executable.
    /// @error invalid memory flags or sizes, sizes that do not match the data.
    static Error<void> Write(ref DataWriter writer, List<Hunk> hunks)
    {
        var realHunks = List<Hunk>.Create();
        foreach (var hunk in hunks)
        {
            if (hunk.Type != HunkType.END && hunk.Type != HunkType.RELOC32)
                realHunks.Add(hunk);
        }

        writer.WriteDword(0x000003F3);
        writer.WriteDword(0);
        writer.WriteDword((uint32)realHunks.Count());
        writer.WriteDword(0);
        writer.WriteDword((uint32)realHunks.Count() - 1);

        foreach (var hunk in realHunks)
        {
            if ((hunk.MemoryFlags & 0x3fffffff) != 0 || hunk.MemoryFlags == 0xc0000000)
                return error(_DataError("Invalid hunk memory flags"));
            if (hunk.Size > 0x3fffffff)
                return error(_DataError("Invalid hunk size"));
            writer.WriteDword(hunk.Size | hunk.MemoryFlags);
        }

        foreach (var hunk in hunks)
        {
            writer.WriteDword((uint32)hunk.Type);

            switch (hunk.Type)
            {
                case HunkType.Code:
                case HunkType.Data:
                    if ((uint32)hunk.Data.Length != hunk.NumEntries * 4)
                        return error(_DataError("Mismatching NumEntries value and Data length for code/data hunk."));
                    if (hunk.NumEntries != hunk.Size)
                        return error(_DataError("Mismatching NumEntries value and hunk size for code/data hunk."));
                    writer.WriteDword(hunk.NumEntries);
                    writer.WriteBytes(hunk.Data);
                    break;
                case HunkType.BSS:
                    if (hunk.NumEntries != hunk.Size)
                        return error(_DataError("Mismatching NumEntries value and hunk size for BSS hunk."));
                    writer.WriteDword(hunk.NumEntries);
                    break;
                case HunkType.RELOC32:
                {
                    int start = writer.Position();
                    foreach (var entry in hunk.Entries.Entries())
                    {
                        writer.WriteDword((uint32)entry.Value.Count());
                        writer.WriteDword(entry.Key);
                        foreach (var offset in entry.Value)
                            writer.WriteDword(offset);
                    }
                    writer.WriteDword(0); // end marker
                    if ((uint32)(writer.Position() - start) != hunk.Size)
                        return error("[Application] Error writing RELOC32 hunk data");
                    break;
                }
                default:
                    break;
            }
        }

        if (hunks.Count() == 0 || hunks[hunks.Count() - 1].Type != HunkType.END)
            writer.WriteDword((uint32)HunkType.END);
        return;
    }

    /// Reads the hunks of an executable; an imploded executable is deploded.
    /// @error the data is no valid executable (or imploded executable).
    static Error<List<Hunk>> Read(DataReader reader)
    {
        return Read(reader, true);
    }

    /// Reads the hunks of an executable; with `deplodeIfNecessary` an imploded executable is deploded.
    static Error<List<Hunk>> Read(DataReader reader, bool deplodeIfNecessary)
    {
        reader.Position = 0;
        string invalid = _DataError("Invalid executable file.");

        if (reader.ReadDword() != 0x000003F3)
            return error(invalid);
        if (reader.ReadDword() != 0) // number of library strings (should be 0)
            return error(invalid);

        uint32 numHunks = reader.ReadDword();
        uint32 firstHunk = reader.ReadDword();
        uint32 lastHunk = reader.ReadDword();

        if ((uint32)(lastHunk - firstHunk + 1) != numHunks || numHunks > (uint32)reader.Remaining() / 4)
            return error(invalid);

        var hunkSizes = new uint32[numHunks];
        var hunkMemoryFlags = new uint32[numHunks];

        for (var i = 0; i < (int)numHunks; i += 1)
        {
            uint32 hunkSize = reader.ReadDword();
            uint32 memFlags = hunkSize & 0xc0000000;

            if (memFlags == 0xc0000000) // extended mem flags
                memFlags = reader.ReadDword() & 0x80000000;

            hunkSizes[i] = hunkSize & 0x3FFFFFFF;
            hunkMemoryFlags[i] = memFlags;
        }

        var hunks = List<Hunk>.Create();
        int realHunkIndex = 0;
        // RELOC32 and END hunks are not counted in the header: the loop runs on for them
        int64 count = numHunks;

        for (int64 i = 0; i < count; i += 1)
        {
            if (reader.Remaining() < 4)
                return error(invalid);
            var type = (HunkType)(reader.ReadDword() & 0x1fffffff);
            Hunk hunk;

            switch (type)
            {
                case HunkType.Code:
                case HunkType.Data:
                {
                    if (realHunkIndex >= hunkSizes.Length)
                        return error(invalid);
                    uint32 numEntries = reader.ReadDword();
                    if (numEntries > (uint32)reader.Remaining() / 4)
                        return error(invalid);
                    hunk = Hunk
                    {
                        Type = type,
                        Size = hunkSizes[realHunkIndex],
                        MemoryFlags = hunkMemoryFlags[realHunkIndex],
                        NumEntries = numEntries,
                        Data = reader.ReadBytes((int)numEntries * 4)
                    };
                    realHunkIndex += 1;
                    break;
                }
                case HunkType.BSS:
                {
                    if (realHunkIndex >= hunkSizes.Length)
                        return error(invalid);
                    uint32 allocSize = reader.ReadDword();
                    hunk = Hunk
                    {
                        Type = type,
                        Size = hunkSizes[realHunkIndex],
                        MemoryFlags = hunkMemoryFlags[realHunkIndex],
                        NumEntries = allocSize
                    };
                    realHunkIndex += 1;
                    break;
                }
                case HunkType.RELOC32:
                {
                    var entries = try _ReadRelocations(ref reader, false);
                    hunk = Hunk { Type = type, Size = (uint32)entries.Size, Entries = entries.Entries };
                    count += 1;
                    break;
                }
                case HunkType.END:
                    hunk = Hunk.CreateEnd();
                    count += 1;
                    break;
                default:
                    return error(_DataError($"Unsupported hunk type: {(uint32)type}."));
            }

            if (reader.Overrun())
                return error(invalid);
            hunks.Add(hunk);
        }

        // There might be an END hunk at the end
        if (reader.Position <= reader.Size() - 4)
        {
            if ((HunkType)(reader.PeekDword() & 0x1fffffff) == HunkType.END)
            {
                reader.Position += 4;
                hunks.Add(Hunk.CreateEnd());
            }
        }

        if (!deplodeIfNecessary || hunks.Count() == 0)
            return hunks;

        var firstData = hunks[0].Data;
        bool imploded = firstData != null && firstData.Length >= _ImplodeHunkHeader.Length;

        if (imploded)
        {
            for (var i = 0; i < _ImplodeHunkHeader.Length; i += 1)
            {
                if (firstData[i] != _ImplodeHunkHeader[i])
                {
                    imploded = false;
                    break;
                }
            }
        }

        if (!imploded && firstData != null)
        {
            // Check if it is library imploded.
            int n = firstData.Length < 200 ? firstData.Length : 200;
            if (Latin1Encoding.GetString(firstData[0..n]).Contains("I need explode.library"))
                return error("Library imploded files are not supported!");
        }

        return imploded ? _ReadImploded(hunks) : hunks;
    }

    // the relocations: for each hunk number the offsets (with 'deltas' each offset is added to the one before)
    static Error<_Relocations> _ReadRelocations(ref DataReader reader, bool deltas)
    {
        var entries = Dictionary<uint32, List<uint32>>.Create();
        int start = reader.Position;
        uint32 numOffsets;

        while ((numOffsets = reader.ReadDword()) != 0)
        {
            if (numOffsets > (uint32)reader.Remaining() / 4)
                return error(_DataError("Invalid executable file."));
            uint32 hunkNumber = reader.ReadDword();
            if (entries.ContainsKey(hunkNumber))
                return error(_DataError("Invalid executable file."));
            var list = List<uint32>.Create((int)numOffsets);
            uint32 current = 0;
            for (var o = 0; o < (int)numOffsets; o += 1)
            {
                if (deltas)
                {
                    current = unchecked(current + reader.ReadDword());
                    list.Add(current);
                }
                else
                    list.Add(reader.ReadDword());
            }
            entries[hunkNumber] = list;
        }

        if (reader.Overrun())
            return error(_DataError("Invalid executable file."));
        return _Relocations { Entries = entries, Size = reader.Position - start };
    }

    static Error<List<Hunk>> _ReadImploded(List<Hunk> imploderHunks)
    {
        // TODO (as in the original): There is one known bug where the second code hunk of AM2_BLIT is read as a data
        // hunk instead.
        var deploded = try Deplode(imploderHunks);
        var hunkSizes = deploded.HunkSizes;
        var hunkMemFlags = deploded.MemoryFlags;
        var hunks = List<Hunk>.Create();
        var reader = DataReader.FromData(deploded.Data);
        int hunkSizeIndex = 0;
        string invalidSize = _DataError("Invalid hunk data size.");

        while (true)
        {
            uint32 header = reader.ReadDword();
            uint32 flags = header >> 30;
            uint32 hunkSize = header & 0x3FFFFFFF;

            // Note: The following is just guessing from analyzing the data but it works quite good.
            // Code hunks seem to have flags = 0.
            // BSS and DATA have flags = 2 or 3 (BSS has size 0).
            // 3 is used if no END hunk follows. This is the case for DATA hunks with RELOC32 following or hunks at the end.
            // RELOC32 seems to have flags = 1.
            // END hunks are inserted after each hunk expect for flags = 3 or if a RELOC32 follows.
            // An END hunk should also not be added at the very end.

            if (flags == 2 || flags == 3) // BSS or DATA
            {
                if (reader.Position < reader.Size() && (reader.PeekDword() & 0x3fffffff) != 0) // a size follows -> no BSS but DATA
                {
                    hunkSize = reader.ReadDword() & 0x3fffffff;

                    if (hunkSizeIndex >= hunkSizes.Count() || hunkSize * 4 != hunkSizes[hunkSizeIndex])
                        return error(invalidSize);

                    hunks.Add(Hunk
                    {
                        Type = HunkType.Data,
                        Size = hunkSize,
                        MemoryFlags = hunkMemFlags[hunkSizeIndex],
                        NumEntries = hunkSize,
                        Data = reader.ReadBytes((int)hunkSize * 4)
                    });
                }
                else // BSS
                {
                    if (hunkSizeIndex == hunkSizes.Count() && reader.Position == reader.Size())
                        break;
                    if (hunkSizeIndex >= hunkSizes.Count())
                        return error(invalidSize);

                    hunks.Add(Hunk.CreateBss(hunkMemFlags[hunkSizeIndex], hunkSizes[hunkSizeIndex] / 4));
                }

                hunkSizeIndex += 1;
            }
            else if (flags == 0) // CODE
            {
                if (hunkSizeIndex >= hunkSizes.Count() || hunkSize * 4 != hunkSizes[hunkSizeIndex])
                    return error(invalidSize);

                hunks.Add(Hunk
                {
                    Type = HunkType.Code,
                    Size = hunkSize,
                    MemoryFlags = hunkMemFlags[hunkSizeIndex],
                    NumEntries = hunkSize,
                    Data = reader.ReadBytes((int)hunkSize * 4)
                });

                hunkSizeIndex += 1;
            }
            else // RELOC32 (the imploder stores the offsets as deltas)
            {
                var relocations = try _ReadRelocations(ref reader, true);
                hunks.Add(Hunk
                {
                    Type = HunkType.RELOC32,
                    Size = (uint32)relocations.Size,
                    MemoryFlags = hunkSizeIndex == 0 ? 0 : hunkMemFlags[hunkSizeIndex - 1],
                    Entries = relocations.Entries
                });
            }

            if (reader.Overrun())
                return error(_DataError("Invalid executable file."));

            if (reader.Position <= reader.Size() - 4)
            {
                uint32 nextFlags = reader.PeekDword() >> 30;

                if (nextFlags == 1) // RELOC32 follows, do not add END
                    continue;
            }

            if (reader.Position == reader.Size())
                break;

            // add END hunk if necessary
            if (flags != 3)
                hunks.Add(Hunk.CreateEnd());
        }

        if (hunks.Count() != 0 && hunks[hunks.Count() - 1].Type == HunkType.END)
            hunks.RemoveAt(hunks.Count() - 1);

        return hunks;
    }

    /// The deploded data of an imploded executable (read without deploding), with the sizes (in bytes) and the
    /// memory flags of its hunks.
    static Error<DeplodedData> Deplode(DataReader reader)
    {
        var hunks = try Read(reader, false);
        return Deplode(hunks);
    }

    static Error<DeplodedData> Deplode(List<Hunk> imploderHunks)
    {
        string invalid = _DataError("Invalid imploded data.");
        int lastCode = -1;
        int lastData = -1;
        var bssHunks = List<Hunk>.Create();
        for (var i = 0; i < imploderHunks.Count(); i += 1)
        {
            var type = imploderHunks[i].Type;
            if (type == HunkType.Code)
                lastCode = i;
            else if (type == HunkType.Data)
                lastData = i;
            else if (type == HunkType.BSS)
                bssHunks.Add(imploderHunks[i]);
        }
        if (lastCode < 0 || lastData < 0 || imploderHunks[lastCode].Data.Length < 0x1E9 || bssHunks.Count() == 0)
            return error(invalid);

        var code = imploderHunks[lastCode].Data;
        var data = imploderHunks[lastData].Data;

        // Values are located at offset 0x188 in last code hunk.
        // The bit length (last 12 bytes) can have a special encoding.
        // If smaller than 8 the normal value is stored (e.g. 0x07).
        // But if 8 or more the length is encoded by subtracting 8 and setting the most significant bit to 1.
        // In those cases first a full byte from the input stream is read and then continued with the remaining
        // bits from the bit buffer.
        var table = code[0x188..0x188 + 8 * 2 + 12].ToArray();
        var hunkSizes = List<uint32>.Create();
        var memFlags = List<uint32>.Create();
        for (var i = 0; i < bssHunks.Count() - 1; i += 1)
        {
            hunkSizes.Add(bssHunks[i].NumEntries * 4);
            memFlags.Add(bssHunks[i].MemoryFlags);
        }
        uint32 firstLiteralLength = ((uint32)code[0x1E6] << 8) | code[0x1E7];
        uint8 initialBitBuffer = code[0x1E8];
        uint32 dataSize = ((uint32)code[0x08] << 24) | ((uint32)code[0x09] << 16) | ((uint32)code[0x0A] << 8) | code[0x0B];

        // the deploded data is at least the size of the imploded data: the output starts as that many zeros
        var output = Deploder.Deplode(data, (int)dataSize, table, firstLiteralLength, initialBitBuffer, data.Length);
        if (output is not uint8[] deploded)
            return error(invalid);
        return DeplodedData { Data = deploded, HunkSizes = hunkSizes, MemoryFlags = memFlags };
    }
}

/// What [AmigaExecutable.Deplode] gives: the data and the sizes (in bytes) and memory flags of the hunks.
struct DeplodedData
{
    uint8[] Data;
    List<uint32> HunkSizes;
    List<uint32> MemoryFlags;
}

struct _Relocations
{
    Dictionary<uint32, List<uint32>> Entries;
    int Size;
}

// the message of an AmbermoonException of the data
string _DataError(string message)
{
    return "[Data] " + message;
}
