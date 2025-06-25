namespace AmbermoonFontCreator;

internal class FontSpec
{
    public int NumChars { get; set; }
    public int NumGlyphs { get; set; }
    public int SmallGlyphHeight { get; set; } = 11;
    public int LargeGlyphHeight { get; set; } = 22;
    public int SmallUsedGlyphHeight { get; set; } = 10;
    public int LargeUsedGlyphHeight { get; set; } = 21;
    public int SmallLineHeight { get; set; } = 12;
    public int LargeLineHeight { get; set; } = 23;
    public int SmallSpaceAdvance { get; set; } = 6;
    public int LargeSpaceAdvance { get; set; } = 10;
    public List<byte> GlyphMapping { get; set; } = [];
}
