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
            if (index == 0 || index > items.Count)
                return;

            --index;

            items.RemoveAt(index);

            for (int i = index; i < items.Count; ++i)
                items[i].Index = (uint)(i + 1);
        }

        public int ItemCount => items.Count;

        public void UpdateItem(int index, Func<Item, Item> updater)
        {
            items[index] = updater?.Invoke(items[index]) ?? items[index];
            items[index].Index = (uint)index + 1;
        }

        public void PrintItems()
        {
            int numRows = (items.Count + 2) / 3;
            var rows = Enumerable.Repeat("", numRows).ToArray();
            int index = 0;
            int[] trim = new int[3] { 0, 26, 52 };

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
            uint lastTrailingDataOffset = (uint)lastDataHunk.Data.Length - TrailingDataSize;
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
            int newDataSize = (int)(lastDataHunk.Data.Length - lastItemAmount * ItemDataSize + items.Count * ItemDataSize);
            while (newDataSize % 4 != 0)
                ++newDataSize;
            var newData = new byte[newDataSize];
            int itemOffset = (int)(lastDataHunk.Data.Length - TrailingDataSize - lastItemAmount * ItemDataSize);
            Buffer.BlockCopy(lastDataHunk.Data, 0, newData, 0, itemOffset);

            // Adjust item count
            newData[itemOffset - 4] = (byte)(items.Count >> 8);
            newData[itemOffset - 3] = (byte)items.Count;
            newData[itemOffset - 2] = newData[itemOffset - 4];
            newData[itemOffset - 1] = newData[itemOffset - 3];

            int n = 0;
            int i = 0;
            int matchLength = 0;
            var codeHunk = (Hunk)hunks.FirstOrDefault(h => h.Type == HunkType.Code);
            var codeHunkData = codeHunk.Data;
            while (i <= codeHunkData.Length - 6 && n < 5)
            {
                if (codeHunkData[i++] == searchBytes[matchLength])
                {
                    if (++matchLength == 6)
                    {
                        codeHunkData[i - matchLength + 0] = 0x4A;
                        codeHunkData[i - matchLength + 1] = 0x39;
                        codeHunkData[i - matchLength + 2] = replaceBytes[0];
                        codeHunkData[i - matchLength + 3] = replaceBytes[1];
                        codeHunkData[i - matchLength + 4] = replaceBytes[2];
                        codeHunkData[i - matchLength + 5] = replaceBytes[3];
                        ++n;
                        matchLength = 0;
                    }
                }
                else if (matchLength != 0)
                {
                    i -= (matchLength - 1);
                    matchLength = 0;
                    continue;
                }
            }

            if (n != 5)
                throw new Exception("Not all 5 data references were found.");

            var writer = new DataWriter();
            foreach (var item in items)
                ItemWriter.WriteItem(item, writer);
            var itemData = writer.ToArray();
            Buffer.BlockCopy(itemData, 0, newData, itemOffset, itemData.Length);
            Buffer.BlockCopy(lastDataHunk.Data, lastDataHunk.Data.Length - TrailingDataSize, newData, itemOffset + itemData.Length, TrailingDataSize);
            int index = hunks.IndexOf(lastDataHunk);
            hunks[index] = new Hunk(HunkType.Data, lastDataHunk.MemoryFlags, newData);
            index = hunks.IndexOf(codeHunk);
            hunks[index] = new Hunk(HunkType.Code, codeHunk.MemoryFlags, codeHunkData);
            var executableWriter = new DataWriter();
            Write(executableWriter, hunks);
            executableWriter.CopyTo(stream);
        }
    }
}
