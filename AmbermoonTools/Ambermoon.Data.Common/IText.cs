using System.Collections.Generic;

namespace Ambermoon.Data
{
    public enum SpecialGlyph
    {
        SoftSpace = 94, // expressed with a normal space character
        HardSpace, // expressed with $
        NewLine, // expressed with ^
        FirstColor // everything >= this is a color from 0 to 31
    }

    public interface ITextProcessor
    {
        IText ProcessText(string text, List<string> dictionary);
    }

    public interface IText
    {
        public byte[] GlyphIndices { get; }
        public int LineCount { get; }
        public int MaxLineSize { get; }
    }
}
