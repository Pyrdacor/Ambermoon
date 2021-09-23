using Ambermoon.Data;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using static Ambermoon.Data.Legacy.Serialization.AmigaExecutable;

namespace AmbermoonItemEditor
{
    internal class Executable
    {
        readonly List<IHunk> hunks;
        readonly List<Item> items;
        int lastItemAmount = 0;
        const int ItemDataSize = 60;
        const int TrailingDataSize = 68;
        
        public Executable(IDataReader dataReader)
        {
            hunks = Read(dataReader);

            var itemManager = new ExecutableData(hunks).ItemManager;
            items = new List<Item>(itemManager.Items);
            lastItemAmount = items.Count;
        }

        public void AddItem()
        {
            items.Add(new Item { Index = (uint)items.Count });
        }

        public void RemoveItem(int index)
        {
            items.RemoveAt(index);

            for (int i = index; i < items.Count; ++i)
                items[i].Index = (uint)(i + 1);
        }

        public void PrintItems()
        {
            int numRows = (items.Count + 1) / 2;
            var rows = Enumerable.Repeat("", numRows).ToArray();
            int index = 0;
            int[] trim = new int[2] { 0, 24 };

            foreach (var item in items)
                rows[index % numRows] = rows[index % numRows].PadRight(trim[index++ / numRows]) + $"{item.Index:000}: {item.Name}";
            
            foreach (var row in rows)
                Console.WriteLine(row);
        }

        public void Save(System.IO.Stream stream)
        {
            // Note: There are 5 references to the data behind the items. We have to adjust those.
            // They are stored like this: 4A 39 00 01 56 EC
            // Here 00 01 56 EC is the offset (relative to the data hunk).
            // It can be calculated by data hunk size - 68.
            // Search for the old offset and replace it with the new one.

            var lastDataHunk = (Hunk)hunks.LastOrDefault(hunk => hunk.Type == HunkType.Data);
            uint lastTrailingDataOffset = lastDataHunk.Size - TrailingDataSize;
            var searchBytes = new byte[6]
            {
                0x4A, 0x39,
                (byte)(lastTrailingDataOffset >> 24),
                (byte)(lastTrailingDataOffset >> 16),
                (byte)(lastTrailingDataOffset >> 8),
                (byte)lastTrailingDataOffset
            };
            uint newTrailingDataOffset = (uint)(lastTrailingDataOffset + (items.Count - lastItemAmount) * ItemDataSize);
            var replaceBytes = new byte[4]
            {
                (byte)(newTrailingDataOffset >> 24),
                (byte)(newTrailingDataOffset >> 16),
                (byte)(newTrailingDataOffset >> 8),
                (byte)newTrailingDataOffset
            };
            int newDataSize = (int)(lastDataHunk.Size - lastItemAmount * ItemDataSize + items.Count * ItemDataSize);
            while (newDataSize % 4 != 0)
                ++newDataSize;
            var newData = new byte[newDataSize];
            int itemOffset = (int)(lastDataHunk.Size - TrailingDataSize - lastItemAmount * ItemDataSize);
            Buffer.BlockCopy(lastDataHunk.Data, 0, newData, 0, itemOffset);

            // Adjust item count
            newData[itemOffset - 4] = (byte)(items.Count >> 8);
            newData[itemOffset - 3] = (byte)items.Count;
            newData[itemOffset - 2] = newData[itemOffset - 4];
            newData[itemOffset - 1] = newData[itemOffset - 3];

            int n = 0;
            int i = 0;
            int matchLength = 0;
            while (i < itemOffset && n < 5)
            {
                if (newData[i++] == searchBytes[matchLength])
                {
                    if (++matchLength == 6)
                    {
                        newData[i - matchLength + 0] = 0x4A;
                        newData[i - matchLength + 1] = 0x39;
                        newData[i - matchLength + 2] = replaceBytes[0];
                        newData[i - matchLength + 3] = replaceBytes[1];
                        newData[i - matchLength + 4] = replaceBytes[2];
                        newData[i - matchLength + 5] = replaceBytes[3];
                        ++n;
                        matchLength = 0;
                    }
                }
                else
                {
                    i -= (matchLength - 1);
                    continue;
                }
            }

            if (n != 5)
                throw new Exception("Not all 5 data references were found.");

            var writer = new DataWriter(newData);
            foreach (var item in items)
                ItemWriter.WriteItem(item, writer);
            Buffer.BlockCopy(lastDataHunk.Data, lastDataHunk.Data.Length - TrailingDataSize, newData, writer.Position, TrailingDataSize);
            int index = hunks.IndexOf(lastDataHunk);
            hunks[index] = new Hunk(HunkType.Data)
            {
                NumEntries = (uint)newDataSize / 4,
                Data = newData
            };
            var executableWriter = new DataWriter();
            Write(executableWriter, hunks);
            executableWriter.CopyTo(stream);
        }
    }
}
