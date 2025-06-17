using Ambermoon.Data.Serialization;

namespace Ambermoon.Data.Text.Patching;

public class Font
{
    public byte NumChars { get; set; }
    public byte NumGlyphs { get; set; }
    public byte FontHeight { get; set; }
    public byte UsedFontHeight { get; set; }
    public byte LineHeight { get; set; }
    public byte SpaceAdvance { get; set; }
    public byte[] GlyphMapping { get; set; }
    public byte[] AdvanceValues { get; set; }
    public byte[] GlyphData { get; set; }

    public Font()
    {
        GlyphMapping = [];
        AdvanceValues = [];
        GlyphData = [];
    }

    public Font(IDataReader reader)
    {
        NumChars = reader.ReadByte();
        NumGlyphs = reader.ReadByte();
        FontHeight = reader.ReadByte();
        UsedFontHeight = reader.ReadByte();
        LineHeight = reader.ReadByte();
        SpaceAdvance = reader.ReadByte();
        GlyphMapping = reader.ReadBytes(NumChars);
        AdvanceValues = reader.ReadBytes(NumGlyphs);
        GlyphData = reader.ReadBytes(NumGlyphs * 2 * FontHeight);
    }

    public void Write(IDataWriter dataWriter)
    {
        dataWriter.Write(NumChars);
        dataWriter.Write(NumGlyphs);
        dataWriter.Write(FontHeight);
        dataWriter.Write(UsedFontHeight);
        dataWriter.Write(LineHeight);
        dataWriter.Write(SpaceAdvance);
        dataWriter.Write(GlyphMapping);
        dataWriter.Write(AdvanceValues);
        dataWriter.Write(GlyphData);
    }
}
