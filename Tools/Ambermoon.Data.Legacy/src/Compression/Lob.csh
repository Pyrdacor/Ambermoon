namespace Ambermoon.Data.Legacy.Compression;

using System;
using Ambermoon.Data.Legacy.Serialization;

/// The LOB compression of the original game (Lothar Becks): a header byte for every 8 entries, each a literal byte
/// (bit 1) or a match of 3 to 18 bytes up to 4095 bytes back (bit 0, 2 bytes).
struct Lob
{
    /// `data` compressed (the result has an even length if `data` has).
    static Error<uint8[]> CompressData(uint8[] data)
    {
        if (data.Length == 0)
            return error(_OutOfBounds);
        var w = _LobWriter { Out = ByteList.Create(data.Length), HeaderBitMask = 0x80 >> 1, Header = 0x80 };
        w.Out.Add(0); // the first header, written later
        var trie = MatchTrie.Create();
        int length = data.Length;

        // the first byte cannot be a match
        trie.Add(data, 0, _LobMaxMatchLength);
        w.Out.Add(data[0]);
        int i = 1;

        while (i <= length - _LobMaxMatchLength)
        {
            var match = trie.GetLongestMatch(data, i, _LobMaxMatchLength);
            trie.Add(data, i, _LobMaxMatchLength);
            if (match.Length > 2)
            {
                w.AddMatch(i - match.Offset, match.Length, i + match.Length == length);
                for (var j = 1; j < match.Length; j += 1)
                    trie.Add(data, i + j, Math.Min(_LobMaxMatchLength, length - i - j));
                i += match.Length;
            }
            else
            {
                w.AddByte(data[i], false);
                i += 1;
            }
        }

        while (i <= length - _LobMinMatchLength)
        {
            int rest = length - i;
            var match = trie.GetLongestMatch(data, i, rest);
            trie.Add(data, i, rest);
            if (match.Length > 2)
            {
                w.AddMatch(i - match.Offset, match.Length, i + match.Length == length);
                for (var j = 1; j < match.Length; j += 1)
                    trie.Add(data, i + j, rest - j);
                i += match.Length;
            }
            else
            {
                w.AddByte(data[i], false);
                i += 1;
            }
        }

        while (i < length)
        {
            w.AddByte(data[i], i == length - 1);
            i += 1;
        }

        if (w.HeaderBitMask != 0x80)
            w.Out[w.HeaderPosition] = (uint8)w.Header;
        if (trie.Error().Length > 0)
            return error(trie.Error());
        return w.Out.ToArray();
    }

    /// Decompresses `decodedSize` bytes from the reader's position on.
    static Error<DataReader> Decompress(ref DataReader reader, uint32 decodedSize)
    {
        // (the bytes are read with an index of their own and checked once per header and per match, not with a call per
        // byte: on a 68000 that is several times faster)
        var decoded = new uint8[(int)decodedSize];
        if (reader.Overrun())
            return error(_OutOfBounds);
        var data = reader.Bytes();
        int at = reader.Position;
        int to = 0;
        while (to < decoded.Length)
        {
            if (at < 0 || at >= data.Length)
                return error(_OutOfBounds);
            int header = data[at];
            at += 1;
            // the bits of the header from the highest on: 0 a match, 1 a literal byte
            for (var bit = 0x80; bit != 0 && to < decoded.Length; bit >>= 1)
            {
                if ((header & bit) == 0) // a match
                {
                    if (at + 1 >= data.Length)
                        return error(_OutOfBounds);
                    int first = data[at];
                    int from = to - (((first << 4) & 0xff00) | data[at + 1]);
                    int stop = to + (first & 0x0f) + 3;
                    at += 2;
                    if (from < 0 || stop > decoded.Length)
                        return error(_OutOfBounds);
                    while (to < stop)
                    {
                        decoded[to] = decoded[from];
                        to += 1;
                        from += 1;
                    }
                }
                else // a literal byte
                {
                    if (at >= data.Length)
                        return error(_OutOfBounds);
                    decoded[to] = data[at];
                    at += 1;
                    to += 1;
                }
            }
        }
        reader.Position = at;
        return DataReader.FromData(decoded);
    }
}

// the state of Lob.CompressData: the output and the header byte that is being filled
struct _LobWriter
{
    ByteList Out;
    int HeaderPosition;
    int HeaderBitMask;
    int Header;

    void AddByte(uint8 b, bool last)
    {
        Header |= HeaderBitMask;
        Out.Add(b);
        _PostAdd(last);
    }

    void AddMatch(int offset, int length, bool last)
    {
        Out.Add((uint8)(((offset >> 4) & 0xf0) | ((length - 3) & 0x0f)));
        Out.Add((uint8)(offset & 0xff));
        _PostAdd(last);
    }

    void _PostAdd(bool last)
    {
        HeaderBitMask >>= 1;
        if (HeaderBitMask == 0)
        {
            Out[HeaderPosition] = (uint8)Header;
            HeaderBitMask = 0x80;
            Header = 0;
            if (!last)
            {
                HeaderPosition = Out.Count();
                Out.Add(0); // the next header
            }
            else if (Out.Count() % 2 == 1)
            {
                Out.Add(0xc0); // a header, then 2 padding bytes
                Out.Add(0);
                Out.Add(0);
            }
        }
        else if (last && Out.Count() % 2 == 1)
        {
            Out.Add(0); // padding
        }
    }
}

const int _LobMinMatchLength = 3;
const int _LobMaxMatchLength = 18;
