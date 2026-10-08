namespace Ambermoon.Data.Legacy.Compression;

using System;
using Ambermoon.Data.Legacy.Serialization;

/// Extended LOB ([LobType.LZRS], Ambermoon Advanced): matches of 3 to 16 bytes (more with additional count bytes) up
/// to 1024 bytes back, which also carry up to 3 literals; runs of the same byte as matches with offset 1; blocks of
/// literals.
struct ExtendedLob
{
    /// `data` compressed (the result has an even length).
    static Error<uint8[]> CompressData(uint8[] data)
    {
        if (data.Length == 0)
            return error(_OutOfBounds);
        var c = _ExtendedLobCompressor {
            Data = data,
            Out = ByteList.Create(data.Length),
            Trie = MatchTrie.Create(_ExtendedLobMaxMatchOffset),
            LastMatchHeaderIndex = -1,
            LastLiteral = -1,
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

        int literalCount = reader.ReadByte();
        bool moreCountBytes = false;
        if (literalCount == 0)
        {
            literalCount = 256;
            moreCountBytes = true;
        }

        while (true)
        {
            if (decodeIndex + literalCount > size)
                return error(_OutOfBounds);
            for (var i = 0; i < literalCount; i += 1)
                decoded[decodeIndex + i] = reader.ReadByte();
            decodeIndex += literalCount;
            if (!moreCountBytes)
                break;
            literalCount = reader.ReadByte();
            moreCountBytes = literalCount == 255;
            if (reader.Overrun())
                return error(_OutOfBounds);
        }

        while (decodeIndex < size)
        {
            int header = reader.ReadWord();
            if (reader.Overrun())
                return error(_OutOfBounds);

            if ((header & 0xe000) != 0xe000) // a match
            {
                int offset = (header & 0x3ff) + 1;
                int length = (header >> 12) + 3;
                literalCount = (header >> 10) & 0x3;

                if (length == 16)
                {
                    int count = 255;
                    while (count == 255)
                    {
                        count = reader.ReadByte();
                        length += count;
                        if (reader.Overrun())
                            return error(_OutOfBounds);
                    }
                }

                int sourceIndex = decodeIndex - offset;
                if (sourceIndex < 0 || decodeIndex + length + literalCount > size)
                    return error(_OutOfBounds);
                for (var i = 0; i < length; i += 1)
                    decoded[decodeIndex + i] = decoded[sourceIndex + i];
                decodeIndex += length;
                for (var i = 0; i < literalCount; i += 1)
                    decoded[decodeIndex + i] = reader.ReadByte();
                decodeIndex += literalCount;
            }
            else // literals
            {
                literalCount = (header >> 8) & 0x1f;
                moreCountBytes = literalCount == 31;
                decoded[decodeIndex] = (uint8)(header & 0xff);
                decodeIndex += 1;

                while (true)
                {
                    if (decodeIndex + literalCount > size)
                        return error(_OutOfBounds);
                    for (var i = 0; i < literalCount; i += 1)
                        decoded[decodeIndex + i] = reader.ReadByte();
                    decodeIndex += literalCount;
                    if (!moreCountBytes)
                        break;
                    literalCount = reader.ReadByte();
                    moreCountBytes = literalCount == 255;
                    if (reader.Overrun())
                        return error(_OutOfBounds);
                }
            }
        }
        if (reader.Overrun())
            return error(_OutOfBounds);

        if (reader.Position % 2 != 0 && reader.Position < reader.Size())
            reader.Position += 1;

        return DataReader.FromData(decoded);
    }
}

// the state of ExtendedLob.CompressData (the local functions of the original are its methods)
struct _ExtendedLobCompressor
{
    uint8[] Data;
    ByteList Out;
    MatchTrie Trie;
    ByteList Literals;
    int RleCount;
    uint8 RleLiteral;
    int LastMatchHeaderIndex;
    int I;
    bool JustFoundRle;
    int LastLiteral;
    string Failure;

    void Run()
    {
        int length = Data.Length;
        Trie.Add(Data, 0, _ExtendedLobMaxMatchLength);
        Literals.Add(Data[I]);
        I += 1;

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
                I += _ExtendedLobMinRLELength;
                continue;
            }
            else if (RleCount >= _ExtendedLobMinRLELength)
            {
                int rleCountBackup = RleCount;
                uint8 rleLiteralBackup = RleLiteral;
                if (_CheckRle())
                {
                    JustFoundRle = true;
                    RleCount = rleCountBackup;
                    _WriteCurrentData(false, false, rleLiteralBackup, true);
                    RleCount = _ExtendedLobMinRLELength;
                }
            }

            int maxMatchLength = Math.Min(length - I, _ExtendedLobMaxMatchLength);
            var match = Trie.GetLongestMatch(Data, I, maxMatchLength);
            int rleLength = JustFoundRle ? _CheckRleLength(I) : 0;
            int matchOffset = I - match.Offset;

            if (matchOffset >= _ExtendedLobMinMatchOffset && matchOffset <= _ExtendedLobMaxMatchOffset && match.Length >= _ExtendedLobMinMatchLength && match.Length > rleLength)
            {
                Trie.Add(Data, I, maxMatchLength);
                if (!JustFoundRle)
                    _WriteCurrentData(false, false, 0, false);
                else
                    RleCount = 0;
                LastLiteral = Data[match.Offset + match.Length - 1];
                _AddMatch(I - match.Offset, match.Length);
                for (var j = 1; j < match.Length; j += 1)
                    Trie.Add(Data, I + j, Math.Min(_ExtendedLobMaxMatchLength, length - I - j));
                I += match.Length;
            }
            else if (JustFoundRle)
            {
                I += _ExtendedLobMinRLELength;
            }
            else
            {
                if (RleCount < _ExtendedLobMinRLELength)
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

    void _WriteAdditionalCount(int additionalCount)
    {
        int count = 255;
        while (count == 255)
        {
            count = Math.Min(additionalCount, 255);
            Out.Add((uint8)count);
            additionalCount -= count;
        }
    }

    bool _WriteMoreLiterals()
    {
        int consumedCount = Math.Min(255, Literals.Count());
        Out.Add((uint8)consumedCount);
        for (var i = 0; i < consumedCount; i += 1)
            Out.Add(Literals[i]);
        Literals.RemoveFirst(consumedCount);
        return consumedCount == 255;
    }

    bool _CheckRle()
    {
        if (Data.Length - I >= _ExtendedLobMinRLELength && Data[I] == Data[I + 1] && Data[I] == Data[I + 2] && Data[I] == Data[I + 3])
        {
            RleLiteral = Data[I];
            RleCount = _ExtendedLobMinRLELength;
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
            if (length == _ExtendedLobMaxMatchLength)
                break; // enough for our purposes
        }
        return length;
    }

    // the literals so far: in the last match (up to 3), then in literal blocks
    void _ProcessLiterals()
    {
        int remainingLiteralCount = Literals.Count();
        if (remainingLiteralCount == 0)
            return;

        int firstLiteralCount;

        if (LastMatchHeaderIndex != -1)
        {
            // 0 to 3 literals go into the last match
            firstLiteralCount = Math.Min(3, remainingLiteralCount);
            Out[LastMatchHeaderIndex] = (uint8)(Out[LastMatchHeaderIndex] | (firstLiteralCount << 2));

            if (remainingLiteralCount <= 3)
            {
                for (var i = 0; i < Literals.Count(); i += 1)
                    Out.Add(Literals[i]);
                LastLiteral = Literals.Last();
                Literals.Clear();
                return;
            }

            for (var i = 0; i < firstLiteralCount; i += 1)
                Out.Add(Literals[i]);
            Literals.RemoveFirst(firstLiteralCount);
            remainingLiteralCount -= firstLiteralCount;
        }
        else
        {
            // the first literals of the data have an encoding of their own
            if (Literals.Count() < 256)
            {
                Out.Add((uint8)Literals.Count());
                for (var i = 0; i < Literals.Count(); i += 1)
                    Out.Add(Literals[i]);
                LastLiteral = Literals.Last();
                Literals.Clear();
                return;
            }

            // (the original takes the last of the remaining literals here, and fails if there are exactly 256)
            LastLiteral = Literals.Last();
            Out.Add(0);
            for (var i = 0; i < 256; i += 1)
                Out.Add(Literals[i]);
            Literals.RemoveFirst(256);
            while (_WriteMoreLiterals())
            {
            }
            return;
        }

        // a new literal block
        firstLiteralCount = Math.Min(remainingLiteralCount, 32);
        Out.Add((uint8)(0xe0 | (firstLiteralCount - 1)));
        LastLiteral = Literals.Last();
        for (var i = 0; i < firstLiteralCount; i += 1)
            Out.Add(Literals[i]);
        Literals.RemoveFirst(firstLiteralCount);

        if (firstLiteralCount == 32)
        {
            while (_WriteMoreLiterals())
            {
            }
        }
    }

    // writes a pending run, or (unless more literals follow) the pending literals
    void _WriteCurrentData(bool nextIsLiteral, bool noRle, uint8 useRleLiteral, bool hasRleLiteral)
    {
        if (RleCount >= _ExtendedLobMinRLELength && !noRle)
        {
            int index = I - RleCount;
            int addTrieCount = RleCount;
            if (index < _ExtendedLobMinRLELength)
            {
                int reduce = _ExtendedLobMinRLELength - index;
                addTrieCount -= reduce;
                index += reduce;
            }
            for (var j = 0; j < addTrieCount; j += 1)
                Trie.Add(Data, index + j, Math.Min(_ExtendedLobMaxMatchLength, Data.Length - index - j));

            uint8 literal = hasRleLiteral ? useRleLiteral : RleLiteral;
            bool rleLiteralAlreadyThere = (Literals.Count() != 0 && Literals.Last() == literal) ||
                                          (Literals.Count() == 0 && LastLiteral == literal);
            if (!rleLiteralAlreadyThere)
            {
                RleCount -= 1; // the run does not include its first byte
                Literals.Add(literal); // that is a part of the literals before it instead
            }

            _ProcessLiterals();
            LastLiteral = literal;
            LastMatchHeaderIndex = Out.Count();

            int firstCount = Math.Min(RleCount, 16);
            Out.Add((uint8)((firstCount - 3) << 4));
            Out.Add(0); // offset 1
            RleCount -= firstCount;
            if (firstCount == 16)
            {
                _WriteAdditionalCount(RleCount);
                RleCount = 0;
            }
            return;
        }

        if (!nextIsLiteral && Literals.Count() != 0)
            _ProcessLiterals();
    }

    void _AddMatch(int offset, int length)
    {
        int firstMatchLength = Math.Min(16, length);
        length -= firstMatchLength;
        offset -= 1;
        LastMatchHeaderIndex = Out.Count();
        Out.Add((uint8)(((firstMatchLength - 3) << 4) | (offset >> 8)));
        Out.Add((uint8)(offset & 0xff));
        if (firstMatchLength == 16)
            _WriteAdditionalCount(length);
    }
}

const int _ExtendedLobMinMatchLength = 3;
const int _ExtendedLobMaxMatchLength = 32;
const int _ExtendedLobMinMatchOffset = 1;
const int _ExtendedLobMaxMatchOffset = 1024;
const int _ExtendedLobMinRLELength = 4;
