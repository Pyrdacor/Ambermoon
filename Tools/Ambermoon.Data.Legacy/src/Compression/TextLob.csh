namespace Ambermoon.Data.Legacy.Compression;

using System;
using Ambermoon.Data.Legacy.Serialization;

/// Text LOB ([LobType.Text], Ambermoon Advanced): for texts, which have many short matches but never the bytes 1 to
/// 31. A byte of 32 or more is itself, 31 is a zero, and the bytes below 31 start a match:
///
/// - `0000OOOO OOOO`: 2 bytes, 3 to 258 bytes back (12 bits: two such matches share the byte of their last 4 bits)
/// - `0001OOOO OOOOOLLL`: 3 to 10 bytes, 3 to 482 bytes back
///
/// The data starts with a count of bytes (0 to 255) that are copied as they are (a header before the texts).
struct TextLob
{
    /// `data` compressed (the result has an even length), or why it cannot be compressed this way.
    static Error<uint8[]> CompressData(uint8[] data)
    {
        var compressed = ByteList.Create(data.Length);
        var trie = MatchTrie.Create(_TextLobMaxMatchOffset);
        int length = data.Length;
        int matchReserveIndex = -1;

        // the bytes up to the last one from 1 to 31 are copied as they are
        int skipBytes = 0;
        for (var k = length - 1; k >= 0; k -= 1)
        {
            if (data[k] > 0 && data[k] < 32)
            {
                skipBytes = k + 1;
                break;
            }
        }
        if (skipBytes > 255)
            return error("[Data] Data can't be compressed with text lob.");

        compressed.Add((uint8)skipBytes);
        int i = 0;
        while (i < skipBytes)
        {
            compressed.Add(data[i]);
            i += 1;
        }

        // the first byte cannot be a match
        if (i >= length)
            return error(_OutOfBounds);
        trie.Add(data, i, _TextLobMaxMatchLength);
        if (data[i] == 0)
            compressed.Add(0x1f);
        else
            compressed.Add(data[i]);
        i += 1;

        while (i < length)
        {
            if (data[i] > 0 && data[i] < 32)
                return error("[Data] Unsupported text data at index " + i.ToString() + ".");
            int maxMatchLength = Math.Min(_TextLobMaxMatchLength, length - i);
            var match = trie.GetLongestMatch(data, i, maxMatchLength);
            trie.Add(data, i, maxMatchLength);

            int matchOffset = i - match.Offset;
            int matchLength = match.Length;

            if (matchOffset >= _TextLobMinMatchOffset && matchOffset <= _TextLobMaxMatchOffset &&
                (matchLength > 2 || (matchLength > 1 && matchOffset <= _TextLobMaxSmallMatchOffset)))
            {
                int offset = matchOffset - _TextLobMinMatchOffset;
                if (matchLength == 2)
                {
                    compressed.Add((uint8)(offset >> 4));
                    if (matchReserveIndex != -1)
                    {
                        compressed[matchReserveIndex] = (uint8)(compressed[matchReserveIndex] | (offset & 0xf));
                        matchReserveIndex = -1;
                    }
                    else
                    {
                        matchReserveIndex = compressed.Count();
                        compressed.Add((uint8)((offset & 0xf) << 4));
                    }
                }
                else
                {
                    compressed.Add((uint8)(0x10 | (offset >> 5)));
                    compressed.Add((uint8)(((offset & 0x1f) << 3) | (matchLength - 3)));
                }

                for (var j = 1; j < matchLength; j += 1)
                    trie.Add(data, i + j, Math.Min(_TextLobMaxMatchLength, length - i - j));
                i += matchLength;
            }
            else
            {
                compressed.Add(data[i] == 0 ? (uint8)0x1f : data[i]);
                i += 1;
            }
        }

        if (compressed.Count() % 2 != 0)
            compressed.Add(0x1f); // a single zero if it was read by accident

        if (trie.Error().Length > 0)
            return error(trie.Error());
        return compressed.ToArray();
    }

    /// Decompresses `decodedSize` bytes from the reader's position on.
    static Error<DataReader> Decompress(ref DataReader reader, uint32 decodedSize)
    {
        int size = (int)decodedSize;
        var decoded = new uint8[size];
        int decodeIndex = 0;
        int matchReserve = 0;
        bool useMatchReserve = false;

        int start = reader.Position;
        int skipBytes = reader.ReadByte();
        if (skipBytes > size)
            return error(_OutOfBounds);
        for (var i = 0; i < skipBytes; i += 1)
            decoded[i] = reader.ReadByte();
        decodeIndex = skipBytes;

        while (decodeIndex < size)
        {
            int header = reader.ReadByte();
            if (reader.Overrun())
                return error(_OutOfBounds);

            if (header == 31)
            {
                decoded[decodeIndex] = 0;
                decodeIndex += 1;
            }
            else if (header >= 32)
            {
                decoded[decodeIndex] = (uint8)header;
                decodeIndex += 1;
            }
            else // a match
            {
                int matchOffset;
                int matchLength;
                if ((header & 0x10) != 0)
                {
                    matchLength = reader.ReadByte();
                    matchOffset = (matchLength >> 3) | ((header & 0xf) << 5);
                    matchLength = (matchLength & 0x7) + 3;
                }
                else
                {
                    matchLength = 2;
                    matchOffset = (header & 0xf) << 4;
                    if (useMatchReserve)
                    {
                        matchOffset |= matchReserve & 0xf;
                    }
                    else
                    {
                        matchReserve = reader.ReadByte();
                        matchOffset |= matchReserve >> 4;
                    }
                    useMatchReserve = !useMatchReserve;
                }

                matchOffset += _TextLobMinMatchOffset;
                int matchIndex = decodeIndex - matchOffset;
                if (matchIndex < 0 || decodeIndex + matchLength > size)
                    return error(_OutOfBounds);
                for (var n = 0; n < matchLength; n += 1)
                    decoded[decodeIndex + n] = decoded[matchIndex + n];
                decodeIndex += matchLength;
            }
        }
        if (reader.Overrun())
            return error(_OutOfBounds);

        if ((reader.Position - start) % 2 != 0)
            reader.Position += 1; // the byte that aligns the data

        return DataReader.FromData(decoded);
    }
}

const int _TextLobMaxMatchLength = 10;
const int _TextLobMinMatchOffset = 3;
const int _TextLobMaxSmallMatchOffset = 258;
const int _TextLobMaxMatchOffset = 482;
