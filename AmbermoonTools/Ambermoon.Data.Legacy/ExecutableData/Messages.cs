using System.Collections.Generic;

namespace Ambermoon.Data.Legacy.ExecutableData
{
    /// <summary>
    /// All kind of ingame messages.
    /// 
    /// They follow after the <see cref="InsertDiskMessages"/>.
    /// 
    /// They are stored as sections. A section can contain
    /// just null-terminated texts after each other or a
    /// offset section similar to <see cref="InsertDiskMessages"/> etc.
    /// 
    /// An offset section starts with a word-aligned 0-longword which
    /// must be skipped then.
    /// 
    /// I am not sure yet if I understand this encoding correctly
    /// but it works for now to parse all messages.
    /// </summary>
    public class Messages
    {
        public List<string> Entries { get; } = new List<string>();
        // Found 300 words in-between the messages. Maybe something with dictionary entries? Words to say?
        public List<uint> UnknownIndices { get; }
        const int NumFirstMessages = 69;
        const int NumSecondMessages = 295;

        /// <summary>
        /// The position of the data reader should be at
        /// the start of the message sections just behind the
        /// insert disk messages.
        /// 
        /// It will be behind all the message sections after this.
        /// </summary>
        public Messages(IDataReader dataReader)
        {
            while (Entries.Count < NumFirstMessages)
                ReadSection(dataReader);

            --dataReader.Position;
            dataReader.AlignToWord();

            int numIndices = (int)dataReader.ReadDword();
            UnknownIndices = new List<uint>(numIndices);

            for (int i = 0; i < numIndices; ++i)
                UnknownIndices.Add(dataReader.ReadWord());

            while (Entries.Count < NumFirstMessages + NumSecondMessages)
                ReadSection(dataReader);

            --dataReader.Position;
            dataReader.AlignToWord();
        }

        void ReadSection(IDataReader dataReader)
        {
            if (dataReader.PeekDword() == 0) // offset section
            {
                dataReader.AlignToWord();
                dataReader.Position += 4;

                var offsets = new List<uint>();
                int endOffset = dataReader.Position;

                while (dataReader.PeekByte() == 0)
                {
                    offsets.Add(dataReader.ReadDword());
                    dataReader.ReadDword(); // TODO: always 0?
                }

                for (int i = 0; i < offsets.Count; ++i)
                {
                    dataReader.Position = (int)offsets[i];
                    Entries.Add(dataReader.ReadNullTerminatedString());

                    if (dataReader.Position > endOffset)
                        endOffset = dataReader.Position;
                }

                dataReader.Position = endOffset;
            }
            else // just a text
            {
                Entries.Add(dataReader.ReadNullTerminatedString());
            }            
        }
    }
}
