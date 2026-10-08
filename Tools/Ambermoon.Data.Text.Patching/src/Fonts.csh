namespace Ambermoon.Data.Text.Patching;

using System;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

/// A font of one size: the glyphs for the characters from 32 on, their advance values and their data (2 bytes per
/// row).
struct Font
{
    uint8 NumChars;
    uint8 NumGlyphs;
    uint8 FontHeight;
    uint8 UsedFontHeight;
    uint8 LineHeight;
    uint8 SpaceAdvance;
    uint8[] GlyphMapping;
    uint8[] AdvanceValues;
    uint8[] GlyphData;

    /// @error the data ends too early.
    static Error<Font> Read(ref DataReader reader)
    {
        var font = Font { };
        font.NumChars = reader.ReadByte();
        font.NumGlyphs = reader.ReadByte();
        font.FontHeight = reader.ReadByte();
        font.UsedFontHeight = reader.ReadByte();
        font.LineHeight = reader.ReadByte();
        font.SpaceAdvance = reader.ReadByte();
        font.GlyphMapping = reader.ReadBytes(font.NumChars);
        font.AdvanceValues = reader.ReadBytes(font.NumGlyphs);
        font.GlyphData = reader.ReadBytes(font.NumGlyphs * 2 * font.FontHeight);
        if (reader.Overrun())
            return error("Specified argument was out of the range of valid values. (Parameter 'length')");
        return font;
    }

    void Write(ref DataWriter writer)
    {
        writer.WriteByte(NumChars);
        writer.WriteByte(NumGlyphs);
        writer.WriteByte(FontHeight);
        writer.WriteByte(UsedFontHeight);
        writer.WriteByte(LineHeight);
        writer.WriteByte(SpaceAdvance);
        writer.WriteBytes(GlyphMapping);
        writer.WriteBytes(AdvanceValues);
        writer.WriteBytes(GlyphData);
    }
}

/// A small and a large font with the same glyph mapping (the fonts of the intro and the extro).
struct Fonts
{
    uint8 NumChars;
    uint8 NumGlyphs;
    uint8 SmallFontHeight;
    uint8 LargeFontHeight;
    uint8 UsedSmallFontHeight;
    uint8 UsedLargeFontHeight;
    uint8 SmallLineHeight;
    uint8 LargeLineHeight;
    uint8 SmallSpaceAdvance;
    uint8 LargeSpaceAdvance;
    uint8[] GlyphMapping;
    uint8[] SmallAdvanceValues;
    uint8[] LargeAdvanceValues;
    uint8[] SmallGlyphData;
    uint8[] LargeGlyphData;

    /// @error the data ends too early.
    static Error<Fonts> Read(ref DataReader reader)
    {
        var fonts = Fonts { };
        fonts.NumChars = reader.ReadByte();
        fonts.NumGlyphs = reader.ReadByte();
        fonts.SmallFontHeight = reader.ReadByte();
        fonts.LargeFontHeight = reader.ReadByte();
        fonts.UsedSmallFontHeight = reader.ReadByte();
        fonts.UsedLargeFontHeight = reader.ReadByte();
        fonts.SmallLineHeight = reader.ReadByte();
        fonts.LargeLineHeight = reader.ReadByte();
        fonts.SmallSpaceAdvance = reader.ReadByte();
        fonts.LargeSpaceAdvance = reader.ReadByte();
        fonts.GlyphMapping = reader.ReadBytes(fonts.NumChars);
        fonts.SmallAdvanceValues = reader.ReadBytes(fonts.NumGlyphs);
        fonts.LargeAdvanceValues = reader.ReadBytes(fonts.NumGlyphs);
        fonts.SmallGlyphData = reader.ReadBytes(fonts.NumGlyphs * 2 * fonts.SmallFontHeight);
        fonts.LargeGlyphData = reader.ReadBytes(fonts.NumGlyphs * 4 * fonts.LargeFontHeight);
        if (reader.Overrun())
            return error("Specified argument was out of the range of valid values. (Parameter 'length')");
        return fonts;
    }

    void Write(ref DataWriter writer)
    {
        writer.WriteByte(NumChars);
        writer.WriteByte(NumGlyphs);
        writer.WriteByte(SmallFontHeight);
        writer.WriteByte(LargeFontHeight);
        writer.WriteByte(UsedSmallFontHeight);
        writer.WriteByte(UsedLargeFontHeight);
        writer.WriteByte(SmallLineHeight);
        writer.WriteByte(LargeLineHeight);
        writer.WriteByte(SmallSpaceAdvance);
        writer.WriteByte(LargeSpaceAdvance);
        writer.WriteBytes(GlyphMapping);
        writer.WriteBytes(SmallAdvanceValues);
        writer.WriteBytes(LargeAdvanceValues);
        writer.WriteBytes(SmallGlyphData);
        writer.WriteBytes(LargeGlyphData);
    }
}

/// Patches of executables.
struct Patch
{
    /// Replaces the last data hunk (a placeholder of 12 bytes: the header of the fonts) by the fonts.
    /// @error there is no data hunk or it is not the placeholder.
    static Error<void> Fonts(List<Hunk> hunks, Fonts fonts)
    {
        var writer = new DataWriter();
        fonts.Write(ref writer);
        return _Font(hunks, writer, 12);
    }

    /// Replaces the last data hunk (a placeholder of 8 bytes: the header of the font) by the font.
    /// @error there is no data hunk or it is not the placeholder.
    static Error<void> Font(List<Hunk> hunks, Font font)
    {
        var writer = new DataWriter();
        font.Write(ref writer);
        return _Font(hunks, writer, 8);
    }

    static Error<void> _Font(List<Hunk> hunks, DataWriter fontData, int expectedHeaderSize)
    {
        int fontHunkIndex = -1;
        for (var i = 0; i < hunks.Count(); i += 1)
        {
            if (hunks[i].Type == HunkType.Data)
                fontHunkIndex = i;
        }

        if (fontHunkIndex < 0)
            return error("[Data] Font patching failed: No font data hunk found in the executable.");

        var fontHunk = hunks[fontHunkIndex];
        if ((int64)fontHunk.Size * 4 != expectedHeaderSize)
            return error($"[Data] Unexpected font hunk size: {(int64)fontHunk.Size * 4}. Expected: {expectedHeaderSize}.");

        while (fontData.Position() % 4 != 0)
            fontData.WriteByte(0); // Align to long boundary

        hunks[fontHunkIndex] = try Hunk.Create(HunkType.Data, fontHunk.MemoryFlags, fontData.ToArray());
        return;
    }
}
