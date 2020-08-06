namespace Ambermoon.Data
{
    public interface IText
    {
        public byte[] GlyphIndices { get; }
        public int LineCount { get; }
        public int MaxLineSize { get; }
    }
}
