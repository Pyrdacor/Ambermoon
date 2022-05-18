using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System.Collections.Generic;
using System.IO;

namespace AmbermoonItemEditor
{
    internal class Items : ItemManager
    {
        public Items(string filename)
            : base(Read(filename))
        {

        }

        static IDataReader Read(string filename)
        {
            var reader = new FileReader();
            var container = reader.ReadFile("", File.ReadAllBytes(filename));

            return container.Files[1];
        }

        protected override List<Item> Load(IDataReader dataReader)
        {
            int itemCount = dataReader.ReadWord();
            var reader = new ItemReader();
            var items = new List<Item>(itemCount);

            for (int i = 0; i < itemCount; ++i)
            {
                var item = new Item { Index = (uint)(i + 1) };
                reader.ReadItem(item, dataReader);
                items.Add(item);
            }

            return items;
        }

        public override void Save(Stream stream)
        {
            var writer = new DataWriter();

            writer.Write((ushort)ItemCount);

            foreach (var item in items)
                ItemWriter.WriteItem(item, writer);

            writer.CopyTo(stream);
        }
    }
}
