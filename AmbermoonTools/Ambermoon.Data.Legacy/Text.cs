namespace Ambermoon.Data.Legacy
{
    public class Text : IText
    {
        public Text(byte[] glyphIndices)
        {
            GlyphIndices = glyphIndices;
            int currentLineSize = 0;
            LineCount = 1;

            for (int i = 0; i < glyphIndices.Length; ++i)
            {
                if (glyphIndices[i] == (byte)'^')
                {
                    if (currentLineSize > MaxLineSize)
                        MaxLineSize = currentLineSize;

                    ++LineCount;
                }
            }
        }

        /// <summary>
        /// This should  only use letters, digits and some punctuation marks.
        /// </summary>
        /// <param name="text"></param>
        public Text(string text)
            : this(DataReader.Encoding.GetBytes(text))
        {

        }

        public byte[] GlyphIndices { get; }
        public int LineCount { get; }
        public int MaxLineSize { get; }
    }
}
