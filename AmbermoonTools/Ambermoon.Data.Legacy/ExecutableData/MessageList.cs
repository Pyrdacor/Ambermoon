using System.Collections.Generic;

namespace Ambermoon.Data.Legacy.ExecutableData
{
    public class MessageList
    {
        public List<string> Entries { get; }

        protected internal MessageList(IDataReader dataReader, int numEntries)
        {
            Entries = new List<string>(numEntries);
            var offsets = new uint[numEntries];
            int endOffset = dataReader.Position;

            for (int i = 0; i < numEntries; ++i)
            {
                offsets[i] = dataReader.ReadDword();
                dataReader.ReadDword(); // TODO: always 0?
            }

            for (int i = 0; i < numEntries; ++i)
            {
                dataReader.Position = (int)offsets[i];
                Entries.Add(dataReader.ReadNullTerminatedString());

                if (dataReader.Position > endOffset)
                    endOffset = dataReader.Position;
            }

            dataReader.Position = endOffset;
            dataReader.AlignToWord();
        }
    }
}
