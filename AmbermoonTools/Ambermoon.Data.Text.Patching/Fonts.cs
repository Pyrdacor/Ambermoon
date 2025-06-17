using Ambermoon.Data.Serialization;

namespace Ambermoon.Data.Text.Patching;

public class Fonts
{
    public byte NumChars { get; set; }
    public byte NumGlyphs { get; set; }
    public byte SmallFontHeight { get; set; }
    public byte LargeFontHeight { get; set; }
    public byte UsedSmallFontHeight { get; set; }
    public byte UsedLargeFontHeight { get; set; }
    public byte SmallLineHeight { get; set; }
    public byte LargeLineHeight { get; set; }
    public byte SmallSpaceAdvance { get; set; }
    public byte LargeSpaceAdvance { get; set; }
    public byte[] GlyphMapping { get; set; }
    public byte[] SmallAdvanceValues { get; set; }
    public byte[] LargeAdvanceValues { get; set; }
    public byte[] SmallGlyphData { get; set; }
    public byte[] LargeGlyphData { get; set; }

    public Fonts()
    {
        GlyphMapping = [];
        SmallAdvanceValues = [];
        LargeAdvanceValues = [];
        SmallGlyphData = [];
        LargeGlyphData = [];
    }

    public Fonts(IDataReader reader)
    {
        NumChars = reader.ReadByte();
        NumGlyphs = reader.ReadByte();
        SmallFontHeight = reader.ReadByte();
        LargeFontHeight = reader.ReadByte();
        UsedSmallFontHeight = reader.ReadByte();
        UsedLargeFontHeight = reader.ReadByte();
        SmallLineHeight = reader.ReadByte();
        LargeLineHeight = reader.ReadByte();
        SmallSpaceAdvance = reader.ReadByte();
        LargeSpaceAdvance = reader.ReadByte();
        GlyphMapping = reader.ReadBytes(NumChars);
        SmallAdvanceValues = reader.ReadBytes(NumGlyphs);
        LargeAdvanceValues = reader.ReadBytes(NumGlyphs);
        SmallGlyphData = reader.ReadBytes(NumGlyphs * 2 * SmallFontHeight);
        LargeGlyphData = reader.ReadBytes(NumGlyphs * 4 * LargeFontHeight);
    }

    public void Write(IDataWriter dataWriter)
    {
        dataWriter.Write(NumChars);
        dataWriter.Write(NumGlyphs);
        dataWriter.Write(SmallFontHeight);
        dataWriter.Write(LargeFontHeight);
        dataWriter.Write(UsedSmallFontHeight);
        dataWriter.Write(UsedLargeFontHeight);
        dataWriter.Write(SmallLineHeight);
        dataWriter.Write(LargeLineHeight);
        dataWriter.Write(SmallSpaceAdvance);
        dataWriter.Write(LargeSpaceAdvance);
        dataWriter.Write(GlyphMapping);
        dataWriter.Write(SmallAdvanceValues);
        dataWriter.Write(LargeAdvanceValues);
        dataWriter.Write(SmallGlyphData);
        dataWriter.Write(LargeGlyphData);
    }
}
