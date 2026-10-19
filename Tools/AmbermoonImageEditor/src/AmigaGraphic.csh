// The graphics of the Amiga: palette graphics in bit planes (1, 3, 4 or 5 bits per pixel), the presets of the formats
// of Ambermoon, and the palette files of the game (32 colors of 16 bits, X4R4G4B4 big endian).
//
// A row of a graphic is a multiple of 8 pixels wide in the data (the rest of the last byte is unused). The planes come
// one after the other for each row: row 0 plane 0, row 0 plane 1, ..., row 1 plane 0, ... In 8 pixel slices ("one
// byte per row", the 3D textures of Ambermoon) they come one after the other for each 8 pixels of a row instead.
// Frames are graphics of the same size one after the other.

using System;

/// How an Amiga graphic is stored.
struct AmigaFormat
{
    int Width;          // of one frame
    int Height;
    int Bpp;            // 1, 3, 4 or 5
    int Frames;
    bool Slices;        // 8 pixel slices (one byte per plane and row)
    int Preset;         // the index in Presets() (0: none)

    static AmigaFormat Create(int width, int height, int bpp)
    {
        return AmigaFormat { Width = width, Height = height, Bpp = bpp, Frames = 1 };
    }

    /// The size of one frame in bytes.
    int FrameSize()
    {
        return Height * ((Width + 7) / 8) * Bpp;
    }

    int DataSize()
    {
        return FrameSize() * Math.Max(1, Frames);
    }

    /// Whether the format can be stored in 8 pixel slices (4 bits per pixel, or 1 bit and at most 8 pixels wide).
    bool SlicesAllowed()
    {
        return Bpp == 4 || (Bpp == 1 && Width <= 8);
    }
}

/// A predefined format: a name and the values it fixes (0: free).
struct FormatPreset
{
    string Name;
    int Width;
    int Height;
    int Bpp;
    bool Slices;
}

List<FormatPreset> Presets()
{
    var presets = List<FormatPreset>.Create();
    presets.Add(FormatPreset { Name = "None" });
    presets.Add(FormatPreset { Name = "Wall texture (3D)", Width = 128, Height = 80, Bpp = 4, Slices = true });
    presets.Add(FormatPreset { Name = "Object texture (3D)", Bpp = 4, Slices = true });
    presets.Add(FormatPreset { Name = "Overlay texture (3D)", Bpp = 4, Slices = true });
    presets.Add(FormatPreset { Name = "Floor/ceiling (3D)", Width = 64, Height = 64, Bpp = 4 });
    presets.Add(FormatPreset { Name = "Item graphic", Width = 16, Height = 16, Bpp = 5 });
    presets.Add(FormatPreset { Name = "Tile graphic (2D)", Width = 16, Height = 16, Bpp = 5 });
    presets.Add(FormatPreset { Name = "NPC graphic (2D)", Width = 16, Height = 32, Bpp = 5 });
    presets.Add(FormatPreset { Name = "Portrait", Width = 32, Height = 34, Bpp = 5 });
    presets.Add(FormatPreset { Name = "Picture 80x80", Width = 80, Height = 80, Bpp = 5 });
    presets.Add(FormatPreset { Name = "Monster (combat)", Bpp = 5 });
    return presets;
}

List<string> PresetNames()
{
    var names = List<string>.Create();
    foreach (var preset in Presets())
        names.Add(preset.Name);
    return names;
}

/// The values of a format with those its preset fixes.
AmigaFormat ApplyPreset(AmigaFormat format)
{
    var presets = Presets();
    if (format.Preset <= 0 || format.Preset >= presets.Count())
        return format;
    var preset = presets[format.Preset];
    if (preset.Width > 0)
        format.Width = preset.Width;
    if (preset.Height > 0)
        format.Height = preset.Height;
    if (preset.Bpp > 0)
    {
        format.Bpp = preset.Bpp;
        format.Slices = preset.Slices;
    }
    return format;
}

/// The bits per pixel that can be chosen and their names.
int[] AllowedBpp()
{
    return [1, 3, 4, 5];
}

List<string> BppNames()
{
    var names = List<string>.Create();
    foreach (var bpp in AllowedBpp())
        names.Add($"{bpp} BPP ({1 << bpp} colors)");
    return names;
}

int BppIndex(int bpp)
{
    var allowed = AllowedBpp();
    for (var i = 0; i < allowed.Length; i += 1)
    {
        if (allowed[i] == bpp)
            return i;
    }
    return allowed.Length - 1;
}

/// Reads the pixels (palette indices) of an Amiga graphic; frames are put side by side.
/// @error the data is too short.
Error<uint8[]> DecodePlanar(uint8[] data, AmigaFormat format)
{
    int frames = Math.Max(1, format.Frames);
    if (format.Width <= 0 || format.Height <= 0)
        return error("The width and the height must be at least 1.");
    if (data.Length < format.DataSize())
        return error($"The file has {data.Length} bytes, the format needs {format.DataSize()}.");
    int bytesPerRow = (format.Width + 7) / 8;
    int totalWidth = format.Width * frames;
    var pixels = new uint8[totalWidth * format.Height];
    for (var f = 0; f < frames; f += 1)
    {
        int frameOffset = f * format.FrameSize();
        for (var y = 0; y < format.Height; y += 1)
        {
            for (var x = 0; x < format.Width; x += 1)
            {
                int value = 0;
                for (var p = 0; p < format.Bpp; p += 1)
                {
                    int at = frameOffset + _PlaneByte(format, bytesPerRow, x, y, p);
                    if (((int)data[at] & (0x80 >> (x & 7))) != 0)
                        value |= 1 << p;
                }
                pixels[f * format.Width + x + y * totalWidth] = (uint8)value;
            }
        }
    }
    return pixels;
}

/// Writes pixels (palette indices below 1 << bpp, frames side by side) as an Amiga graphic.
/// @error a pixel does not fit into the bits per pixel, or the width is no multiple of the frame width.
Error<uint8[]> EncodePlanar(uint8[] pixels, int totalWidth, AmigaFormat format)
{
    int frames = Math.Max(1, format.Frames);
    if (format.Width * frames != totalWidth)
        return error($"The image is {totalWidth} pixels wide, {frames} frames of {format.Width} need {format.Width * frames}.");
    int bytesPerRow = (format.Width + 7) / 8;
    int max = 1 << format.Bpp;
    var data = new uint8[format.DataSize()];
    for (var f = 0; f < frames; f += 1)
    {
        int frameOffset = f * format.FrameSize();
        for (var y = 0; y < format.Height; y += 1)
        {
            for (var x = 0; x < format.Width; x += 1)
            {
                int value = (int)pixels[f * format.Width + x + y * totalWidth];
                if (value >= max)
                    return error($"The pixel {f * format.Width + x}, {y} has the color {value}, more than {format.Bpp} BPP can store (normalize the colors first).");
                for (var p = 0; p < format.Bpp; p += 1)
                {
                    if ((value & (1 << p)) != 0)
                    {
                        int at = frameOffset + _PlaneByte(format, bytesPerRow, x, y, p);
                        data[at] = (uint8)((int)data[at] | (0x80 >> (x & 7)));
                    }
                }
            }
        }
    }
    return data;
}

// where the byte of a pixel in a plane is (in a frame)
int _PlaneByte(AmigaFormat format, int bytesPerRow, int x, int y, int plane)
{
    int rowStart = y * bytesPerRow * format.Bpp;
    if (format.Slices)
        return rowStart + (x >> 3) * format.Bpp + plane;
    return rowStart + plane * bytesPerRow + (x >> 3);
}

// ---- palettes ----

const int PaletteFileColors = 32;

/// The palette of the user interface of Ambermoon (the first palette in AM2_CPU): the items, the portraits and the
/// graphics of the user interface use it. It is also the palette of a new graphic.
uint32[] UiPalette()
{
    uint16[] colors = [0x000, 0xedc, 0xffe, 0xbbc, 0x89a, 0x578, 0x256, 0x034, 0xfc9, 0xea7, 0xc85, 0xa63, 0x842, 0x521,
                       0xb80, 0xda0, 0xfc0, 0xf90, 0xc60, 0x812, 0xc43, 0xe63, 0xaa4, 0x573, 0x254, 0x509, 0x222, 0x443,
                       0x665, 0x887, 0xaa9, 0xccb];
    var palette = new uint32[colors.Length];
    for (var i = 0; i < colors.Length; i += 1)
        palette[i] = FromAmigaColor((int)colors[i]);
    return palette;
}

/// The colors of a new graphic and of a graphic that is opened: the palette of the user interface.
uint32[] DefaultPalette()
{
    return UiPalette();
}

/// Palette 1 of Ambermoon (Palettes.amb).
uint32[] FirstMapPalette()
{
    uint16[] colors = [0x000, 0xeed, 0x9b5, 0x8a4, 0x793, 0x683, 0x573, 0x462, 0x351, 0x241, 0x131, 0x020, 0x224, 0x346,
                       0x368, 0x499, 0xcb0, 0xb75, 0x983, 0x762, 0x541, 0x320, 0xc40, 0xd80, 0x533, 0x854, 0x222, 0x443,
                       0x665, 0x887, 0xaa9, 0xccb];
    var palette = new uint32[colors.Length];
    for (var i = 0; i < colors.Length; i += 1)
        palette[i] = FromAmigaColor((int)colors[i]);
    return palette;
}

/// A color of 12 bits (0RGB) as ARGB.
uint32 FromAmigaColor(int color)
{
    uint32 r = (uint32)((color >> 8) & 0xf) * 17;
    uint32 g = (uint32)((color >> 4) & 0xf) * 17;
    uint32 b = (uint32)(color & 0xf) * 17;
    return 0xff000000u | (r << 16) | (g << 8) | b;
}

/// An ARGB color as 12 bits (0RGB), rounded to the nearest of the 16 steps.
int ToAmigaColor(uint32 argb)
{
    int r = ((int)((argb >> 16) & 0xff) + 8) / 17;
    int g = ((int)((argb >> 8) & 0xff) + 8) / 17;
    int b = ((int)(argb & 0xff) + 8) / 17;
    return (r << 8) | (g << 4) | b;
}

/// Reads a palette file of the game: 32 colors of 16 bits.
/// @error the file is not 64 bytes long.
Error<uint32[]> ReadPaletteFile(uint8[] data)
{
    if (data.Length != 2 * PaletteFileColors)
        return error($"A palette file has 64 bytes (32 colors of 16 bits); this one has {data.Length}.");
    var palette = new uint32[PaletteFileColors];
    for (var i = 0; i < PaletteFileColors; i += 1)
        palette[i] = FromAmigaColor(((int)data[2 * i] << 8) | (int)data[2 * i + 1]);
    return palette;
}

/// A palette file of the game: 32 colors, those of the picture from `offset` on, black for the others.
uint8[] WritePaletteFile(List<uint32> colors, int offset)
{
    var data = new uint8[2 * PaletteFileColors];
    for (var i = 0; i < colors.Count() && offset + i < PaletteFileColors; i += 1)
    {
        int color = ToAmigaColor(colors[i]);
        data[2 * (offset + i)] = (uint8)(color >> 8);
        data[2 * (offset + i) + 1] = (uint8)(color & 0xff);
    }
    return data;
}

/// The palette offsets an Amiga graphic can have in the 32 colors of a palette file: 0 or 16 for 4 bits per pixel,
/// 0, 16 or 24 for 3 bits, only 0 for the others.
List<int> PaletteOffsets(int bpp)
{
    var offsets = List<int>.Create();
    offsets.Add(0);
    if (bpp == 4 || bpp == 3)
        offsets.Add(16);
    if (bpp == 3)
        offsets.Add(24);
    return offsets;
}

/// The colors of a new Amiga graphic: 1 << bpp colors of the default palette from `offset` on (black and white for
/// 1 bit).
List<uint32> AmigaPalette(int bpp, int offset)
{
    var palette = List<uint32>.Create();
    var colors = DefaultPalette();
    int count = 1 << bpp;
    for (var i = 0; i < count; i += 1)
        palette.Add(offset + i < colors.Length ? colors[offset + i] : 0xff000000u);
    if (bpp == 1)
    {
        palette[0] = 0xff000000u;
        palette[1] = 0xffffffffu;
    }
    return palette;
}
