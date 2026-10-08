namespace Ambermoon.Data.Legacy.Compression;

using System;
using Ambermoon.Data.Legacy.Serialization;

/// Advanced LOB ([LobType.Extended], Ambermoon Advanced). The first byte of an entry tells what it is:
///
/// - `00 CC`: a run of 35 to 290 zeros (CC + 35)
/// - `01` to `7F`: that many literals follow
/// - `100LLLLO OOOOOOOO`: a small match, 3 to 18 bytes, 1 to 512 bytes back
/// - `101LLLLL LLOOOOOO OOOO`: a large match, 3 to 130 bytes, 1 to 1024 bytes back (two large matches share the byte
///   of their last 4 bits)
/// - `110CCCCC <literal>`: a run of 3 to 34 times the literal
/// - `111LLLLL`: a single literal from 0 to 31
struct AdvancedLob
{
    /// `data` compressed (the result has an even length).
    static Error<uint8[]> CompressData(uint8[] data)
    {
        if (data.Length == 0)
            return error(_OutOfBounds);
        var c = _AdvancedLobCompressor {
            Data = data,
            Out = ByteList.Create(data.Length),
            Literals = ByteList.Create(127),
            Trie = MatchTrie.Create(_AdvancedLobMaxLargeMatchOffset),
            LargeMatchReserveIndex = -1,
            Failure = ""
        };
        c.Run();
        if (c.Failure.Length > 0)
            return error(c.Failure);
        if (c.Trie.Error().Length > 0)
            return error(c.Trie.Error());
        return c.Out.ToArray();
    }

    /// Decompresses `decodedSize` bytes from the reader's position on.
    static Error<DataReader> Decompress(ref DataReader reader, uint32 decodedSize)
    {
        int size = (int)decodedSize;
        var decoded = new uint8[size];
        int decodeIndex = 0;
        bool useLargeMatchReserve = false;
        int largeMatchReserve = 0;

        while (decodeIndex < size)
        {
            int header = reader.ReadByte();

            if (header == 0) // a run of zeros
            {
                int amount = reader.ReadByte() + 35;
                if (decodeIndex + amount > size)
                    return error(_OutOfBounds);
                decodeIndex += amount; // the array is zeroed
            }
            else if (header < 128) // literals
            {
                if (decodeIndex + header > size)
                    return error(_OutOfBounds);
                for (var i = 0; i < header; i += 1)
                    decoded[decodeIndex + i] = reader.ReadByte();
                decodeIndex += header;
            }
            else
            {
                int mode = (header >> 5) & 3;
                int offset = 0;
                int length = 0;

                if (mode == 0) // a small match
                {
                    length = ((header >> 1) & 0xf) + 3;
                    offset = ((header & 0x1) << 8) | reader.ReadByte();
                }
                else if (mode == 1) // a large match
                {
                    length = (header & 0x1f) << 2;
                    offset = reader.ReadByte();
                    length |= offset >> 6;
                    length += 3;
                    offset = (offset & 0x3f) << 4;
                    if (useLargeMatchReserve)
                    {
                        offset |= largeMatchReserve;
                    }
                    else
                    {
                        largeMatchReserve = reader.ReadByte();
                        offset |= largeMatchReserve >> 4;
                        largeMatchReserve &= 0xf;
                    }
                    useLargeMatchReserve = !useLargeMatchReserve;
                }
                else if (mode == 2) // a run of a literal
                {
                    length = (header & 0x1f) + 3;
                    uint8 literal = reader.ReadByte();
                    if (decodeIndex + length > size)
                        return error(_OutOfBounds);
                    for (var i = 0; i < length; i += 1)
                        decoded[decodeIndex + i] = literal;
                    decodeIndex += length;
                    continue;
                }
                else // mode 3: a small literal
                {
                    decoded[decodeIndex] = (uint8)(header & 0x1f);
                    decodeIndex += 1;
                    continue;
                }

                offset += 1;
                int sourceIndex = decodeIndex - offset;
                if (sourceIndex < 0 || decodeIndex + length > size)
                    return error(_OutOfBounds);
                for (var i = 0; i < length; i += 1)
                    decoded[decodeIndex + i] = decoded[sourceIndex + i];
                decodeIndex += length;
            }

            if (reader.Overrun())
                return error(_OutOfBounds);
        }
        if (reader.Overrun())
            return error(_OutOfBounds);

        if (reader.Position % 2 != 0 && reader.Position < reader.Size())
            reader.Position += 1;

        return DataReader.FromData(decoded);
    }
}

// the state of AdvancedLob.CompressData (the local functions of the original are its methods)
struct _AdvancedLobCompressor
{
    uint8[] Data;
    ByteList Out;
    MatchTrie Trie;
    ByteList Literals;
    int RleCount;
    uint8 RleLiteral;
    int LargeMatchReserveIndex;
    int I;
    bool JustFoundRle;
    string Failure;

    void Run()
    {
        int length = Data.Length;

        if (_CheckRle())
        {
            Trie.Add(Data, 0, Math.Min(_AdvancedLobMaxLargeMatchLength, length));
            Trie.Add(Data, 1, Math.Min(_AdvancedLobMaxLargeMatchLength, length - 1));
            Trie.Add(Data, 2, Math.Min(_AdvancedLobMaxLargeMatchLength, length - 2));
            I += 3;
        }
        else
        {
            Trie.Add(Data, 0, _AdvancedLobMaxLargeMatchLength);
            Literals.Add(Data[I]);
            I += 1;
        }

        while (I < length)
        {
            JustFoundRle = false;

            if (RleCount != 0 && Data[I] == RleLiteral)
            {
                RleCount += 1;
                I += 1;
                continue;
            }
            else if (RleCount == 0 && _CheckRle())
            {
                JustFoundRle = true;
                _WriteCurrentData(false, true, 0, false);
            }
            else if (RleCount >= 3)
            {
                int rleCountBackup = RleCount;
                uint8 rleLiteralBackup = RleLiteral;
                if (_CheckRle())
                {
                    JustFoundRle = true;
                    RleCount = rleCountBackup;
                    _WriteCurrentData(false, false, rleLiteralBackup, true);
                    RleCount = 3;
                }
            }

            int maxMatchLength = Math.Min(length - I, _AdvancedLobMaxLargeMatchLength);
            var match = Trie.GetLongestMatch(Data, I, maxMatchLength);
            int rleLength = JustFoundRle ? _CheckRleLength(I) : 0;

            if (I - match.Offset <= _AdvancedLobMaxLargeMatchOffset && match.Length >= _AdvancedLobMinMatchLength && match.Length > rleLength)
            {
                Trie.Add(Data, I, maxMatchLength);
                if (!JustFoundRle)
                    _WriteCurrentData(false, false, 0, false);
                else
                    RleCount = 0;
                _AddMatch(I - match.Offset, match.Length);
                for (var j = 1; j < match.Length; j += 1)
                    Trie.Add(Data, I + j, Math.Min(_AdvancedLobMaxLargeMatchLength, length - I - j));
                I += match.Length;
            }
            else if (JustFoundRle)
            {
                I += 3;
            }
            else
            {
                if (RleCount < 3)
                    Trie.Add(Data, I, maxMatchLength);
                _WriteCurrentData(true, false, 0, false);
                Literals.Add(Data[I]);
                I += 1;
            }
        }

        _WriteCurrentData(false, false, 0, false);

        if (Out.Count() % 2 != 0)
            Out.Add(0);
    }

    bool _CheckRle()
    {
        if (Data.Length - I >= 3 && Data[I] == Data[I + 1] && Data[I] == Data[I + 2])
        {
            RleLiteral = Data[I];
            RleCount = 3;
            return true;
        }
        return false;
    }

    int _CheckRleLength(int index)
    {
        int length = 1;
        uint8 literal = Data[index];
        for (var i = index + 1; i < Data.Length; i += 1)
        {
            if (Data[i] != literal)
                break;
            length += 1;
            if (length == 290)
                break; // enough for our purposes
        }
        return length;
    }

    // writes a pending run, or (unless more literals follow) the pending literals
    void _WriteCurrentData(bool nextIsLiteral, bool noRle, uint8 useRleLiteral, bool hasRleLiteral)
    {
        if (RleCount >= 3 && !noRle)
        {
            if (Literals.Count() != 0 && Failure.Length == 0)
                Failure = "[Application] There should be no stored literals when a RLE is compressed.";

            int index = I - RleCount;
            int addTrieCount = RleCount;
            if (index < 3)
            {
                int reduce = 3 - index;
                addTrieCount -= reduce;
                index += reduce;
            }
            for (var j = 0; j < addTrieCount; j += 1)
                Trie.Add(Data, index + j, Math.Min(_AdvancedLobMaxLargeMatchLength, Data.Length - index - j));

            uint8 literal = hasRleLiteral ? useRleLiteral : RleLiteral;

            if (literal == 0)
            {
                while (RleCount >= 35)
                {
                    int count = Math.Min(RleCount, 290);
                    Out.Add(0);
                    Out.Add((uint8)(count - 35));
                    RleCount -= count;
                }
                if (RleCount >= 3)
                {
                    int count = Math.Min(RleCount, 34);
                    Out.Add((uint8)(0xc0 | (count - 3)));
                    Out.Add(0);
                    RleCount -= count;
                }
            }
            else
            {
                while (RleCount >= 3)
                {
                    int count = Math.Min(RleCount, 34);
                    Out.Add((uint8)(0xc0 | (count - 3)));
                    Out.Add(literal);
                    RleCount -= count;
                }
            }

            // (the original adds the current run literal here, not the one of the run)
            while (RleCount != 0)
            {
                Literals.Add(RleLiteral);
                RleCount -= 1;
            }
        }

        if (!nextIsLiteral && Literals.Count() != 0)
        {
            while (Literals.Count() != 0)
            {
                // short sequences of small bytes are single literals
                if (Literals.Count() < 10 && _AllSmall())
                {
                    for (var i = 0; i < Literals.Count(); i += 1)
                        Out.Add((uint8)(Literals[i] | 0xe0));
                    Literals.Clear();
                    break;
                }
                int count = Math.Min(127, Literals.Count());
                Out.Add((uint8)count);
                for (var i = 0; i < count; i += 1)
                    Out.Add(Literals[i]);
                Literals.RemoveFirst(count);
            }
        }
    }

    bool _AllSmall()
    {
        for (var i = 0; i < Literals.Count(); i += 1)
        {
            if (Literals[i] > 31)
                return false;
        }
        return true;
    }

    void _AddMatch(int offset, int length)
    {
        if (length > _AdvancedLobMaxSmallMatchLength || offset > _AdvancedLobMaxSmallMatchOffset)
        {
            // a large match
            offset -= 1;
            length -= _AdvancedLobMinMatchLength;
            Out.Add((uint8)(0xa0 | (length >> 2)));
            Out.Add((uint8)(((length & 0x3) << 6) | (offset >> 4)));
            if (LargeMatchReserveIndex == -1)
            {
                LargeMatchReserveIndex = Out.Count();
                Out.Add((uint8)((offset & 0xf) << 4));
            }
            else
            {
                Out[LargeMatchReserveIndex] = (uint8)(Out[LargeMatchReserveIndex] | (offset & 0xf));
                LargeMatchReserveIndex = -1;
            }
        }
        else
        {
            // a small match
            int b1 = 0x80 | ((length - _AdvancedLobMinMatchLength) << 1);
            offset -= 1;
            if (offset > 255)
                b1 += 1;
            Out.Add((uint8)b1);
            Out.Add((uint8)(offset & 0xff));
        }
    }
}

const int _AdvancedLobMinMatchLength = 3;
const int _AdvancedLobMaxSmallMatchLength = 3 + 0xf;
const int _AdvancedLobMaxLargeMatchLength = 3 + 0x7f;
const int _AdvancedLobMaxSmallMatchOffset = 1 + 0x1ff;
const int _AdvancedLobMaxLargeMatchOffset = 1 + 0x3ff;
