namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data;

/// Reads the graphics of the game (planar palette graphics, textures, 16 bit colors, attached sprites).
struct GraphicReader
{
    /// Reads a graphic in the format of `info` at the position of the reader; with a `maskColor` other than 0 that
    /// color becomes 0 (transparent) and 0 becomes 32.
    /// @error an attached sprite that is not 16, 32, 48 or 64 pixels wide.
    static Error<Graphic> ReadGraphic(ref DataReader reader, GraphicInfo info, uint8 maskColor)
    {
        var graphic = Graphic { Width = info.Width, Height = info.Height };

        switch (info.GraphicFormat)
        {
            case GraphicFormat.Palette5Bit:
                _ReadPaletteGraphic(ref graphic, ref reader, 5, info, info.Width);
                break;
            case GraphicFormat.Palette4Bit:
                _ReadPaletteGraphic(ref graphic, ref reader, 4, info, info.Width);
                break;
            case GraphicFormat.Palette3Bit:
                _ReadPaletteGraphic(ref graphic, ref reader, 3, info, info.Width);
                break;
            case GraphicFormat.Texture4Bit:
                _ReadPaletteGraphic(ref graphic, ref reader, 4, info, 8);
                break;
            case GraphicFormat.XRGB16:
            {
                int n = graphic.Width * graphic.Height;
                graphic.Data = new uint8[n * 4];
                for (var i = 0; i < n; i += 1)
                {
                    uint16 color = reader.ReadWord();
                    uint8 r = (uint8)((color >> 8) & 0x0f);
                    uint8 g = (uint8)((color >> 4) & 0x0f);
                    uint8 b = (uint8)(color & 0x0f);
                    graphic.Data[i * 4 + 0] = (uint8)(r | (r << 4));
                    graphic.Data[i * 4 + 1] = (uint8)(g | (g << 4));
                    graphic.Data[i * 4 + 2] = (uint8)(b | (b << 4));
                    graphic.Data[i * 4 + 3] = 255;
                }
                break;
            }
            case GraphicFormat.RGBA32:
                graphic.Data = reader.ReadBytes(graphic.Width * graphic.Height * 4);
                break;
            case GraphicFormat.AttachedSprite:
            {
                // Attached sprites are two Amiga hardware sprites (2bpp each).
                //
                // word[2]           ControlWords
                // word[2 * Height]  Data (2 words for each pixel row)
                // long              Next pointer
                //
                // Each sprite has a width of 16 pixel. The first sprite gives the lower 2 bits and the second sprite
                // the higher 2 bits of a 4 bit color index. The color index starts at 16 (transparent) and can
                // otherwise have the values 17 to 31.
                if (graphic.Width % 16 != 0)
                    return error("Attached sprites must have a width which is a multiple of 16.");
                if (graphic.Width > 64)
                    return error("Attached sprites has a max width of 64 pixels.");
                graphic.IndexedGraphic = true;
                graphic.Data = new uint8[graphic.Width * graphic.Height];
                int numSprites = 2 * graphic.Width / 16;
                for (var s = 0; s < numSprites; s += 1)
                {
                    reader.Position += 4; // skip the 2 control words

                    int line0Add = s % 2 == 0 ? 1 : 4;
                    int line1Add = s % 2 == 0 ? 2 : 8;

                    for (var y = 0; y < graphic.Height; y += 1)
                    {
                        uint16 line0 = reader.ReadWord();
                        uint16 line1 = reader.ReadWord();
                        uint16 mask = 0x8000;

                        for (var x = 0; x < 16; x += 1)
                        {
                            int index = (s / 2) * 16 + x + y * graphic.Width;
                            int colorIndex = graphic.Data[index];
                            if ((line0 & mask) != 0)
                                colorIndex |= line0Add;
                            if ((line1 & mask) != 0)
                                colorIndex |= line1Add;
                            graphic.Data[index] = (uint8)colorIndex;
                            mask >>= 1;
                        }
                    }

                    reader.Position += 4; // skip the next pointer
                }

                // adjust indices
                for (var i = 0; i < graphic.Data.Length; i += 1)
                {
                    if (graphic.Data[i] != 0)
                        graphic.Data[i] += 16;
                }
                break;
            }
        }

        if (maskColor != 0)
        {
            graphic.ReplaceColor(0, 32);
            graphic.ReplaceColor(maskColor, 0);
        }

        return graphic;
    }

    /// Reads a graphic in the format of `info`.
    static Error<Graphic> ReadGraphic(ref DataReader reader, GraphicInfo info)
    {
        return ReadGraphic(ref reader, info, 0);
    }

    // a planar graphic: per row (or per group of 'pixelsPerPlane' pixels) the planes one after the other
    static void _ReadPaletteGraphic(ref Graphic graphic, ref DataReader reader, int planes, GraphicInfo info, int pixelsPerPlane)
    {
        graphic.IndexedGraphic = true;
        graphic.Data = new uint8[graphic.Width * graphic.Height];

        int ppp = pixelsPerPlane;
        int planeSize = (_ToNextBoundary(ppp) + 7) / 8;
        int scanLine = _ToNextBoundary(graphic.Width);
        int sizeToRead = (scanLine * planes * graphic.Height + 7) / 8;
        var data = reader.ReadBytes(sizeToRead);
        int bitIndex = 0;
        int byteIndex = 0;
        int offset = 0;
        int planeCycles = ppp == info.Width ? 1 : (graphic.Width + ppp - 1) / ppp;

        for (var y = 0; y < graphic.Height; y += 1)
        {
            for (var n = 0; n < planeCycles; n += 1)
            {
                for (var x = 0; x < ppp; x += 1)
                {
                    int mx = n * ppp + x;
                    if (mx >= graphic.Width)
                        break;

                    int paletteIndex = 0;
                    for (var p = 0; p < planes; p += 1)
                    {
                        int at = offset + p * planeSize + byteIndex;
                        if (at < data.Length && (data[at] & (1 << (7 - bitIndex))) != 0)
                            paletteIndex |= 1 << p;
                    }

                    var index = (uint8)(paletteIndex + info.PaletteOffset);
                    graphic.Data[mx + y * graphic.Width] = info.Alpha && index == info.PaletteOffset ? info.ColorKey : index;

                    bitIndex += 1;
                    if (bitIndex == 8)
                    {
                        bitIndex = 0;
                        byteIndex += 1;
                    }
                }

                offset += planes * planeSize;
                byteIndex = 0;
                bitIndex = 0;
            }
        }
    }

    static int _ToNextBoundary(int size)
    {
        return size % 8 == 0 ? size : size + (8 - size % 8);
    }
}

/// Reads a palette: 32 colors of 16 bits (XRGB) as RGBA (GraphicProvider.ReadPalette).
Graphic ReadPalette(ref DataReader reader)
{
    var info = GraphicInfo { Width = 32, Height = 1, GraphicFormat = GraphicFormat.XRGB16 };
    if (GraphicReader.ReadGraphic(ref reader, info) is Graphic palette)
        return palette;
    return Graphic.Create(32, 1, 0);
}
