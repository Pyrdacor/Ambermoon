namespace Ambermoon.Data;

using System;

/// The formats of the graphics of the game.
enum GraphicFormat : int32
{
    Palette5Bit,
    Palette4Bit,
    Palette3Bit,
    Texture4Bit,
    XRGB16,
    RGBA32,
    AttachedSprite
}

/// How a graphic is stored: its format, size, whether color 0 is transparent, the first palette index.
struct GraphicInfo
{
    GraphicFormat GraphicFormat;
    int Width;
    int Height;
    bool Alpha;
    uint8 PaletteOffset;
    uint8 ColorKey;

    int BitsPerPixel()
    {
        switch (GraphicFormat)
        {
            case GraphicFormat.Palette5Bit: return 5;
            case GraphicFormat.Palette4Bit: return 4;
            case GraphicFormat.Palette3Bit: return 3;
            case GraphicFormat.Texture4Bit: return 4;
            case GraphicFormat.XRGB16: return 16;
            case GraphicFormat.RGBA32: return 32;
            default: return 4; // AttachedSprite
        }
    }

    int DataSize()
    {
        return (Width * Height * BitsPerPixel() + 7) / 8;
    }
}

/// A graphic: palette indices (one byte per pixel) or RGBA colors (4 bytes per pixel).
///
/// Unlike the class of the original, a graphic is a value whose data array is shared by its copies: changing pixels
/// changes them for all copies, changing the size only for the one changed.
struct Graphic
{
    int Width;
    int Height;
    uint8[] Data;
    bool IndexedGraphic;

    /// An indexed graphic of the size, all pixels `colorIndex`.
    static Graphic Create(int width, int height, uint8 colorIndex)
    {
        var data = new uint8[width * height];
        if (colorIndex != 0)
        {
            for (var i = 0; i < data.Length; i += 1)
                data[i] = colorIndex;
        }
        return Graphic { Width = width, Height = height, Data = data, IndexedGraphic = true };
    }

    /// An indexed graphic of the data (its length must be width * height).
    /// @error the size of the data does not match.
    static Error<Graphic> FromIndexedData(int width, int height, uint8[] data)
    {
        if (data.Length != width * height)
            return error("Invalid graphic data size.");
        return Graphic { Width = width, Height = height, Data = data, IndexedGraphic = true };
    }

    /// A copy with its own data.
    Graphic Clone()
    {
        return Graphic { Width = Width, Height = Height, Data = Data == null ? null : Data.Clone(), IndexedGraphic = IndexedGraphic };
    }

    /// Replaces a color index by another.
    void ReplaceColor(uint8 oldColorIndex, uint8 newColorIndex)
    {
        for (var i = 0; i < Data.Length; i += 1)
        {
            if (Data[i] == oldColorIndex)
                Data[i] = newColorIndex;
        }
    }

    /// The pixels of an area as a new graphic.
    /// @error the graphic is not indexed or the area is not inside of it.
    Error<Graphic> GetArea(int x, int y, int width, int height)
    {
        if (!IndexedGraphic)
            return error("[Application] GetArea cannot be used on non-indexed graphics.");
        if (x < 0 || y < 0 || x + width > Width || y + height > Height)
            return error("[Application] Invalid area provided for Graphic.GetArea.");

        var graphic = Create(width, height, 0);
        for (var ty = 0; ty < height; ty += 1)
        {
            for (var tx = 0; tx < width; tx += 1)
                graphic.Data[tx + ty * width] = Data[x + tx + (y + ty) * Width];
        }
        return graphic;
    }

    /// Draws an overlay at (x, y); with `blend` its color 0 is transparent.
    /// @error a graphic is not indexed or the overlay is not inside.
    Error<void> AddOverlay(int64 x, int64 y, Graphic overlay, bool blend)
    {
        if (!overlay.IndexedGraphic || !IndexedGraphic)
            return error("[Application] Non-indexed graphics can not be used with overlays.");
        if (x < 0 || y < 0 || x + overlay.Width > Width || y + overlay.Height > Height)
            return error("Overlay is outside the bounds.");

        for (var r = 0; r < overlay.Height; r += 1)
        {
            for (var c = 0; c < overlay.Width; c += 1)
            {
                uint8 index = overlay.Data[c + r * overlay.Width];
                if (!blend || index != 0)
                    Data[(int)x + c + ((int)y + r) * Width] = index;
            }
        }
        return;
    }

    /// Draws an overlay at (x, y) with color 0 transparent.
    Error<void> AddOverlay(int64 x, int64 y, Graphic overlay)
    {
        return AddOverlay(x, y, overlay, true);
    }

    /// The graphics side by side.
    static Graphic Concat(ReadOnlySlice<Graphic> graphics)
    {
        int width = 0;
        int height = 0;
        foreach (var graphic in graphics)
        {
            width += graphic.Width;
            if (graphic.Height > height)
                height = graphic.Height;
        }
        var result = Create(width, height, 0);
        int x = 0;
        foreach (var graphic in graphics)
        {
            result.AddOverlay(x, 0, graphic, false);
            x += graphic.Width;
        }
        return result;
    }

    /// A graphic of `colorIndex` that increases every `rowsPerIncrease` rows from `startY` on up to `endColorIndex`.
    static Graphic CreateGradient(int width, int height, int startY, int rowsPerIncrease, uint8 colorIndex, uint8 endColorIndex)
    {
        var graphic = Create(width, height, colorIndex);
        for (var y = startY; y < height; y += 1)
        {
            if (colorIndex < endColorIndex && (y - startY) % rowsPerIncrease == 0)
                colorIndex += 1;
            for (var x = 0; x < width; x += 1)
                graphic.Data[x + y * width] = colorIndex;
        }
        return graphic;
    }

    /// A copy scaled by a factor (nearest pixel).
    Graphic CreateScaled(float factor)
    {
        if (FloatEqual(factor, 1.0f))
            return this;
        if (FloatEqual(factor, 0.0f) || Width == 0 || Height == 0)
            return Create(0, 0, 0);
        return _Scaled(FloorToInt(factor * Width), FloorToInt(factor * Height), factor, factor);
    }

    /// A copy scaled to a size (nearest pixel).
    Graphic CreateScaled(int width, int height)
    {
        if (width == Width && height == Height)
            return this;
        if (Width == 0 || Height == 0 || width == 0 || height == 0)
            return Create(0, 0, 0);
        return _Scaled(width, height, (float)width / Width, (float)height / Height);
    }

    Graphic _Scaled(int width, int height, float xFactor, float yFactor)
    {
        var graphic = Create(width, height, 0);
        graphic.IndexedGraphic = IndexedGraphic;
        for (var y = 0; y < height; y += 1)
        {
            for (var x = 0; x < width; x += 1)
            {
                int sourceX = RoundToInt(x / xFactor);
                int sourceY = RoundToInt(y / yFactor);
                if (sourceX > Width - 1)
                    sourceX = Width - 1;
                if (sourceY > Height - 1)
                    sourceY = Height - 1;
                graphic.Data[x + y * width] = Data[sourceX + sourceY * Width];
            }
        }
        return graphic;
    }

    /// The RGBA colors of the pixels: indexed graphics with a palette (32 colors of 4 bytes; `alphaIndex` stays
    /// transparent), others as they are.
    uint8[] ToPixelData(Graphic palette, uint8 alphaIndex)
    {
        if (!IndexedGraphic)
            return Data;
        var data = new uint8[Width * Height * 4];
        for (var i = 0; i < Width * Height; i += 1)
        {
            uint8 index = Data[i];
            if (index != alphaIndex)
            {
                index %= 32;
                for (var c = 0; c < 4; c += 1)
                    data[i * 4 + c] = palette.Data[index * 4 + c];
            }
        }
        return data;
    }
}

/// Whether two floats differ by less than 0.00001 (Util.FloatEqual).
bool FloatEqual(float f1, float f2)
{
    float d = f1 - f2;
    return (d < 0 ? -d : d) < 0.00001f;
}

/// (int)Math.Floor(f) (Util.Floor).
int FloorToInt(float f)
{
    int i = (int)f;
    return (float)i > f ? i - 1 : i;
}

/// (int)Math.Round(f): to the nearest integer, halves to the even one (Util.Round).
int RoundToInt(float f)
{
    int floor = FloorToInt(f);
    float rest = f - floor;
    if (rest > 0.5f)
        return floor + 1;
    if (rest < 0.5f)
        return floor;
    return floor % 2 == 0 ? floor : floor + 1;
}
