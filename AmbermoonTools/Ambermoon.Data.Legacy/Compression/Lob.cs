using System.Collections.Generic;

namespace Ambermoon.Data.Legacy.Compression
{
    public static class Lob
    {
        const int MinMatchLength = 3;
        const int MaxMatchLength = 18;

        public static byte[] CompressData(byte[] data)
        {
            // ease algorithm by not compressing very small data (22 bytes)
            if (data.Length < MinMatchLength + MaxMatchLength + 1)
                return data;

            var compressedData = new List<byte>(data.Length / 2);
            var trie = new LobPatriciaTrie();
            int currentHeaderPosition = 0;
            byte currentHeaderBitMask = 1 << 4; // skip first 3 bits
            byte currentHeader = 0xe0; // first 3 entries/bytes are no matches
            compressedData.Add(0); // add header dummy
            int i = 0;

            void AddByte(byte b, bool last = false)
            {
                currentHeader |= currentHeaderBitMask;
                compressedData.Add(b);
                PostAdd(last);
            }

            void AddMatch(int offset, int length, bool last = false)
            {
                byte b1 = (byte)(((offset >> 4) & 0xf0) | ((length - 3) & 0x0f));
                compressedData.Add(b1);
                compressedData.Add((byte)(offset & 0xff));
                PostAdd(last);
            }

            void PostAdd(bool last)
            {
                currentHeaderBitMask >>= 1;

                if (currentHeaderBitMask == 0)
                {
                    compressedData[currentHeaderPosition] = currentHeader;
                    currentHeaderBitMask = 0x80;
                    currentHeader = 0;

                    if (!last)
                    {
                        currentHeaderPosition = compressedData.Count;
                        compressedData.Add(0); // new header
                    }
                }
            }

            // Note: The multiple for loops avoid additional if branches and therefore hopefully add to speed.

            for (; i < MinMatchLength; ++i)
            {
                // first 3 bytes can not contain matches
                trie.Add(data, i, MaxMatchLength);
                compressedData.Add(data[i]);
            }

            for (; i < MaxMatchLength; ++i)
            {
                var match = trie.GetLongestMatch(data, i, i);

                trie.Add(data, i, MaxMatchLength);

                if (match.Value > 2)
                {
                    AddMatch(i - match.Key, match.Value);
                    i += match.Value - 1; // -1 cause of for's ++i
                }
                else
                    AddByte(data[i]);
            }

            for (; i <= data.Length - MaxMatchLength; ++i)
            {
                var match = trie.GetLongestMatch(data, i, MaxMatchLength);

                trie.Add(data, i, MaxMatchLength);

                if (match.Value > 2)
                {
                    AddMatch(i - match.Key, match.Value, i + match.Value == data.Length);
                    i += match.Value - 1; // -1 cause of for's ++i
                }
                else
                    AddByte(data[i]);
            }

            for (; i <= data.Length - 3; ++i)
            {
                int length = data.Length - i;
                var match = trie.GetLongestMatch(data, i, length);

                trie.Add(data, i, length);

                if (match.Value > 2)
                {
                    AddMatch(i - match.Key, match.Value, i + match.Value == data.Length);
                    i += match.Value - 1; // -1 cause of for's ++i
                }
                else
                    AddByte(data[i]);
            }

            for (; i < data.Length; ++i)
            {
                AddByte(data[i], i == data.Length - 1);
            }

            compressedData[currentHeaderPosition] = currentHeader;

            return compressedData.ToArray();
        }
    }
}
