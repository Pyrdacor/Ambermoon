using Ambermoon.Data;
using Ambermoon.Data.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;

namespace AmbermoonItemEditor
{
    internal abstract class ItemManager
    {
        protected readonly List<Item> items;

        public ItemManager(IDataReader dataReader)
        {
            items = Load(dataReader);
        }

        protected abstract List<Item> Load(IDataReader dataReader);

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

        public Item GetItem(int index) => items[index];

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

        public List<Item> FindItems(string partialName)
        {
            if (string.IsNullOrWhiteSpace(partialName))
                return new List<Item>();

            partialName = partialName.ToLower();
            return items.Where(item => item.Name.ToLower().Contains(partialName)).ToList();
        }

        public abstract void Save(System.IO.Stream stream);
    }
}
