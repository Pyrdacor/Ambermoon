namespace Ambermoon.Data.Legacy.Serialization;

using System;

const ReadOnlySlice<uint8> _LiteralBase = [6, 10, 10, 18];
const ReadOnlySlice<uint8> _LiteralExtraBits = [1, 1, 1, 1, 2, 3, 3, 4, 4, 5, 7, 14];

/// Decompresses data of the Imploder ("deplodes" it): imploded executables and IMP! data.
struct Deploder
{
    /// Deplodes IMP! data at the position of the reader (behind it afterwards).
    /// @error no IMP! data, or the data is damaged.
    static Error<uint8[]> DeplodeFimp(ref DataReader reader)
    {
        if (reader.PeekDword() != 0x494d5021) // "IMP!"
            return error("[Data] No valid IMP data");

        int position = reader.Position;
        reader.Position += 4; // skip header
        int explodedSize = (int)(reader.ReadDword() & 0x7fffffff);
        int implodedSize = (int)(reader.ReadDword() & 0x7fffffff);
        reader.Position = reader.Position - 12 + implodedSize;
        var initialData = reader.ReadBytes(12);
        uint32 firstLiteralLength = reader.ReadDword();
        bool evenData = (reader.ReadByte() & 0x80) != 0; // bit 0x80 means even data
        uint8 initialBitBuffer = reader.ReadByte();
        var table = reader.ReadBytes(8 * 2 + 12 * 1);
        int footerSize = 12 + 4 + 2 + 8 * 2 + 12 * 1 + 4; // the last 4 bytes are a checksum but we don't care about it

        if (!evenData)
        {
            footerSize += 1;
            implodedSize -= 1;
        }
        if (reader.Overrun() || implodedSize < 12)
            return error("[Data] Error exploding data");

        var prepared = new uint8[implodedSize];
        for (var i = 0; i < 3; i += 1)
            Array.Copy(initialData, i * 4, prepared, (2 - i) * 4, 4);
        reader.Position = position + 12;
        var rest = reader.ReadBytes(implodedSize - 12);
        Array.Copy(rest, 0, prepared, 12, implodedSize - 12);
        reader.Position += footerSize;

        if (Deplode(prepared, implodedSize, table, firstLiteralLength, initialBitBuffer, explodedSize) is not uint8[] output)
            return error("[Data] Error exploding data");
        if (output.Length != explodedSize)
            return error("[Data] Exploded size does not match the value in the header");
        return output;
    }

    /// Deplodes `implodedSize` bytes of `source` (read backwards from that end). The output starts as
    /// `initialOutputSize` zeros that are overwritten (and stay where the output is shorter, as in the original).
    /// `null` if the data is damaged.
    static Optional<uint8[]> Deplode(uint8[] source, int implodedSize, ReadOnlySlice<uint8> table,
                                     uint32 firstLiteralLength, uint8 initialBitBuffer, int initialOutputSize)
    {
        if (implodedSize < 0 || implodedSize > source.Length || table.Length < 28)
            return null;
        var state = _DeplodeState
        {
            Source = source,
            Input = implodedSize,
            BitBuffer = initialBitBuffer,
            Output = new uint8[initialOutputSize < 64 ? 64 : initialOutputSize],
            Size = initialOutputSize
        };
        var matchBase = new int[8];

        // read the 'base' part of the explosion table
        for (var x = 0; x < 8; x += 1)
            matchBase[x] = (table[x * 2] << 8) | table[x * 2 + 1];

        uint32 literalLength = firstLiteralLength; // word at offset 0x1E6 in the last code hunk
        int output = 0;

        while (true)
        {
            // copy literal run
            for (uint32 i = 0; i < literalLength; i += 1)
            {
                uint8 b = state.NextByte();
                if (state.Failed || !state.Set(output, b))
                    return null;
                output += 1;
            }

            // main exit point - after the literal copy
            if (state.Input <= 0)
                break;

            // static Huffman encoding of the match length and selector:
            //
            // 0     -> selector = 0, match_len = 1
            // 10    -> selector = 1, match_len = 2
            // 110   -> selector = 2, match_len = 3
            // 1110  -> selector = 3, match_len = 4
            // 11110 -> selector = 3, match_len = 5 + next three bits (5-12)
            // 11111 -> selector = 3, match_len = (next input byte)-1 (0-254)
            uint32 selector;
            uint32 matchLength;

            if (state.ReadBits(1) != 0)
            {
                if (state.ReadBits(1) != 0)
                {
                    if (state.ReadBits(1) != 0)
                    {
                        selector = 3;

                        if (state.ReadBits(1) != 0)
                        {
                            if (state.ReadBits(1) != 0) // 11111
                            {
                                matchLength = state.NextByte();

                                if (matchLength == 0)
                                    return null; // bad input

                                matchLength -= 1;
                            }
                            else // 11110
                                matchLength = 5 + state.ReadBits(3);
                        }
                        else // 1110
                            matchLength = 4;
                    }
                    else // 110
                    {
                        selector = 2;
                        matchLength = 3;
                    }
                }
                else // 10
                {
                    selector = 1;
                    matchLength = 2;
                }
            }
            else // 0
            {
                selector = 0;
                matchLength = 1;
            }

            // another Huffman tuple, for deciding the base value (y) and number of extra bits required from the input
            // stream (x) to create the length of the next literal run. Selector is 0-3, as previously obtained.
            //
            // 0  -> base = 0,                      extra = {1,1,1,1}[selector]
            // 10 -> base = 2,                      extra = {2,3,3,4}[selector]
            // 11 -> base = {6,10,10,18}[selector]  extra = {4,5,7,14}[selector]
            uint32 y = 0;
            uint32 x = selector;
            if (state.ReadBits(1) != 0)
            {
                if (state.ReadBits(1) != 0) // 11
                {
                    y = _LiteralBase[(int)x];
                    x += 8;
                }
                else // 10
                {
                    y = 2;
                    x += 4;
                }
            }
            x = _LiteralExtraBits[(int)x];

            // next literal run length: read [x] bits and add [y]
            literalLength = y + state.ReadBits(x);

            // another Huffman tuple, for deciding the match distance: _base and _extra are from the explosion table,
            // as passed into the deplode function.
            //
            // 0  -> base = 1                        extra = _extra[selector + 0]
            // 10 -> base = 1 + _base[selector + 0]  extra = _extra[selector + 4]
            // 11 -> base = 1 + _base[selector + 4]  extra = _extra[selector + 8]
            int64 match = output - 1;
            x = selector;
            if (state.ReadBits(1) != 0)
            {
                if (state.ReadBits(1) != 0)
                {
                    match -= matchBase[(int)selector + 4];
                    x += 8;
                }
                else
                {
                    match -= matchBase[(int)selector];
                    x += 4;
                }
            }
            x = table[(int)x + 16];

            // obtain the value of the next [x] extra bits and add it to the match offset
            match -= state.ReadBits(x);

            if (state.Failed)
                return null;

            // copy match
            for (uint32 i = 0; i < matchLength + 1; i += 1)
            {
                if (match < 0 || match >= state.Size)
                    return null;
                if (!state.Set(output, state.Output[(int)match]))
                    return null;
                output += 1;
                match += 1;
            }
        }

        // the data is valid if all input bytes are used (as they should)
        if (!(state.Input == 0 || (implodedSize % 2 == 1 && state.Input == -1)) || state.Failed)
            return null;
        return state.Output[0..state.Size].ToArray();
    }
}

// the input (read backwards), the bit buffer and the output of a deplode
struct _DeplodeState
{
    uint8[] Source;
    int Input;
    uint8 BitBuffer;
    uint8[] Output;
    int Size;
    bool Failed;

    // the next byte of the input (backwards). The original reads the byte before the data when the size is odd (on
    // .NET a byte of padding, 0); reading further is an error.
    uint8 NextByte()
    {
        Input -= 1;
        if (Input < 0)
        {
            if (Input < -1)
                Failed = true;
            return 0;
        }
        return Source[Input];
    }

    uint32 ReadBits(uint32 count)
    {
        uint32 result = 0;

        if ((count & 0x80) != 0)
        {
            result = NextByte();
            count &= 0x7f;
        }

        for (uint32 i = 0; i < count; i += 1)
        {
            uint8 bit = (uint8)(BitBuffer >> 7);
            BitBuffer = (uint8)(BitBuffer << 1);

            if (BitBuffer == 0)
            {
                uint8 temp = bit;
                BitBuffer = NextByte();
                bit = (uint8)(BitBuffer >> 7);
                BitBuffer = (uint8)(BitBuffer << 1);
                if (temp != 0)
                    BitBuffer += 1;
            }

            result = (result << 1) | bit;
        }

        return result;
    }

    // writes the byte at 'index': the end appends it
    bool Set(int index, uint8 value)
    {
        if (index > Size)
            return false;
        if (index == Size)
        {
            if (Size == Output.Length)
            {
                var bigger = new uint8[Output.Length * 2];
                Array.Copy(Output, 0, bigger, 0, Size);
                Output = bigger;
            }
            Size += 1;
        }
        Output[index] = value;
        return true;
    }
}
