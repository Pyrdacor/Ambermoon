// AmbermoonImageConverter <imageFile> <paletteFile> <outFile> <format> [frames] [palOffset] [tindex] [findex]: converts
// an image into the bit planes of a graphic of the game, with the colors of one of its palettes.

using System;
using System.Image;
using Ambermoon;

void Usage()
{
    Console.WriteLine("USAGE: AmbermoonImageConverter <imageFile> <paletteFile> <outFile> <format> [frames] [palOffset] [tindex] [findex]");
    Console.WriteLine("       AmbermoonImageConverter --help");
    Console.WriteLine();
    Console.WriteLine("Creates an image data file from a graphic and a palette. This file can then be used in Ambermoon.");
    Console.WriteLine();
    Console.WriteLine("<imageFile>   Image file (PNG, BMP, etc)");
    Console.WriteLine("<paletteFile> Palette data file from the original game data");
    Console.WriteLine("<outFile>     Path where the output file should be created");
    Console.WriteLine("<format>      3: 3 bit planes (mostly UI graphics)");
    Console.WriteLine("              4: 4 bit planes (floors, lab background, intro, etc)");
    Console.WriteLine("              5: 5 bit planes (items, monsters, tile graphics, etc)");
    Console.WriteLine("              0: 4 bit 3D textures (walls, overlays, objects)");
    Console.WriteLine("              1: multi-tile graphic (16x16 parts with 5bpp");
    Console.WriteLine("[frames]      Number of frames (default: 1)");
    Console.WriteLine("[palOffset]   Palette offset (default: 0)");
    Console.WriteLine("              Based on <format> this is limited to 0 (5 bpp), 16 (4 bpp) or 24 (3 bpp).");
    Console.WriteLine("[tindex]      Transparent color index (default: 0)");
    Console.WriteLine("[findex]      Forbidden color index (default: 32)");
    Console.WriteLine();
    Console.WriteLine("Note: The provided palette must be a decompressed/extracted single file like Palettes/001.");
    Console.WriteLine("      Do not pass the whole container Palettes.amb here!");
    Console.WriteLine("Note: The tool tries to use similar palette indices if the given image contains colors which");
    Console.WriteLine("      are not part of the given palette. However this has its limits. The tool will error if");
    Console.WriteLine("      the color is too far away from every palette color.");
    Console.WriteLine();
}

int Main(string[] args)
{
    foreach (var a in args)
    {
        if (a == "--help")
        {
            Usage();
            return 0;
        }
    }
    if (args.Length < 4 || args.Length > 8)
    {
        Console.WriteLine("Invalid number of arguments.");
        Console.WriteLine();
        Usage();
        return 0;
    }

    if (Image.Load(args[0]) is not Image image)
    {
        Console.WriteLine("Failed to read image file.");
        Console.WriteLine();
        Usage();
        return 0;
    }
    if (LoadPalette(args[1]) is not uint32[] palette)
    {
        Console.WriteLine("Failed to read palette file.");
        Console.WriteLine();
        Usage();
        return 0;
    }
    int width = image.Width;
    int height = image.Height;
    var palIndices = new uint8[image.Pixels.Length];

    if (ParseInt(args[3]) is not int format)
    {
        Console.WriteLine("Invalid format given.");
        Console.WriteLine();
        Usage();
        return 0;
    }
    int bpp = format;
    if (bpp == 0)
        bpp = 4;
    else if (bpp == 1)
        bpp = 5;
    else if (bpp < 3 || bpp > 5)
    {
        Console.WriteLine("Invalid format given.");
        Console.WriteLine();
        Usage();
        return 0;
    }

    // the optional numbers (int.Parse of the original ends with an exception for other texts)
    var numbers = new int[] { 1, 0, 0, 32 };
    for (var i = 4; i < args.Length; i += 1)
    {
        if (ParseInt(args[i]) is not int n)
        {
            Console.WriteLine("Invalid number '" + args[i] + "'.");
            return 1;
        }
        numbers[i - 4] = i == 4 ? n : Math.Max(0, n);
    }
    int frames = numbers[0];
    int paletteIndexOffset = numbers[1];
    int transparentColorIndex = numbers[2];
    int forbiddenColorIndex = numbers[3];
    if (bpp == 5)
        paletteIndexOffset = 0;
    else if (bpp == 4)
        paletteIndexOffset = Math.Min(16, paletteIndexOffset);
    else
        paletteIndexOffset = Math.Min(24, paletteIndexOffset);
    int minIndex = paletteIndexOffset;
    int maxIndex = (1 << bpp) - 1 + paletteIndexOffset;

    if (frames == 0)
    {
        Console.WriteLine("Frames must not be 0.");
        Console.WriteLine();
        Usage();
        return 0;
    }
    else if (frames == 1 && format == 1)
    {
        Console.WriteLine("You should specify more than 1 frame if using format 1 (multi-tile).");
        Console.WriteLine();
        Usage();
        return 0;
    }
    if (format == 1 && (width % 16 != 0 || height % 16 != 0))
    {
        Console.WriteLine("Image dimensions must be a multiple of 16 for multi-tile images.");
        Console.WriteLine();
        return 0;
    }

    var mapper = PaletteMapper { Palette = palette, Mapped = Dictionary<uint32, uint8>.Create() };
    for (var i = 0; i < palIndices.Length; i += 1)
    {
        var found = mapper.FindPaletteIndex(image.Pixels[i], (uint8)minIndex, (uint8)maxIndex, (uint8)transparentColorIndex,
                                            (uint8)forbiddenColorIndex);
        if (found is not uint8 index)
        {
            Console.WriteLine("No palette color can be used for the color " + image.Pixels[i].ToString("x8") + ".");
            return 1;
        }
        palIndices[i] = index;
    }

    var outputData = new uint8[height * bpp * width / 8];
    int frameWidth = format == 1 ? 16 : width / frames;
    int frameHeight = format == 1 ? 16 : height;
    int sizePerFrame = frameHeight * bpp * frameWidth / 8;
    int scanLine = format == 0 ? 8 : frameWidth;
    int scans = format == 0 ? (frameWidth + 7) / 8 : 1;
    var planes = Planes { Indices = palIndices, Output = outputData };

    if (format == 1) // multi-tile image for 2D maps
    {
        int rows = height / 16;
        int framesPerRow = width / 16;
        int lastRowFrames = frames % framesPerRow;
        if (lastRowFrames == 0)
            lastRowFrames = framesPerRow;
        int totalFrameIndex = 0;
        for (var r = 0; r < rows; r += 1)
        {
            int frameCount = r == rows - 1 ? lastRowFrames : framesPerRow;
            for (var f = 0; f < frameCount; f += 1)
            {
                for (var y = 0; y < frameHeight; y += 1)
                {
                    int baseIndex = totalFrameIndex * sizePerFrame + y * bpp * 2; // 2 = 16px / 8bits
                    for (var p = 0; p < bpp; p += 1)
                    {
                        for (var x = 0; x < scanLine; x += 1)
                            planes.Put((r * 16 + y) * width + f * frameWidth + x, p, baseIndex + p * scanLine / 8 + x / 8, x % 8);
                    }
                }
                totalFrameIndex += 1;
            }
        }
    }
    else
    {
        for (var f = 0; f < frames; f += 1)
        {
            for (var y = 0; y < frameHeight; y += 1)
            {
                int baseIndex = f * sizePerFrame + y * bpp * frameWidth / 8;
                int xoff = 0;
                for (var s = 0; s < scans; s += 1)
                {
                    for (var p = 0; p < bpp; p += 1)
                    {
                        for (var x = 0; x < scanLine; x += 1)
                            planes.Put(y * width + f * frameWidth + x + xoff, p, baseIndex + p * scanLine / 8 + x / 8, x % 8);
                    }
                    baseIndex += 4;
                    xoff += 8;
                }
            }
        }
    }
    if (planes.OutOfRange)
    {
        // the original ends with an IndexOutOfRangeException
        Console.WriteLine("The image does not fit the format and the number of frames.");
        return 1;
    }

    if (File.WriteAllBytes(args[2], outputData) is error e)
    {
        Console.WriteLine("Failed to write output file.");
        Console.WriteLine("  " + e.Message);
        Console.WriteLine();
    }
    return 0;
}

// Sets the bits of the bit planes; an index outside of the image or the output is remembered (the original ends there
// with an exception).
struct Planes
{
    uint8[] Indices;
    uint8[] Output;
    bool OutOfRange;

    void Put(int pixel, int plane, int target, int bitIndex)
    {
        if (OutOfRange || pixel < 0 || pixel >= Indices.Length || target < 0 || target >= Output.Length)
        {
            OutOfRange = true;
            return;
        }
        int bit = (Indices[pixel] >> plane) & 0x1;
        Output[target] |= (uint8)(bit << (7 - bitIndex));
    }
}

// The palette index of each color of the image, remembered for the next pixels of the same color.
struct PaletteMapper
{
    uint32[] Palette;
    Dictionary<uint32, uint8> Mapped;

    // null when no palette index can be used (the original ends with an exception).
    Optional<uint8> FindPaletteIndex(uint32 color, uint8 min, uint8 max, uint8 transparentColorIndex, uint8 forbiddenColorIndex)
    {
        if (Mapped.TryGet(color) is uint8 known)
            return known;
        max = (uint8)Math.Min((int)max, 31);
        if ((color >> 24) == transparentColorIndex && transparentColorIndex != forbiddenColorIndex) // transparent
            return transparentColorIndex;

        uint32 r = (color >> 16) & 0xf0;
        uint32 g = (color >> 8) & 0xf0;
        uint32 b = color & 0xf0;
        color = 0xff000000u | (r << 16) | (r << 12) | (g << 8) | (g << 4) | b | (b >> 4);
        if (Mapped.TryGet(color) is uint8 rounded)
            return rounded;

        int bestDiff = -1;
        int bestIndex = 0;
        for (int i = min; i <= max; i += 1)
        {
            if (i == forbiddenColorIndex)
                continue;
            if (Palette[i] == color)
                return _Remember(color, (uint8)i);
            if (i == transparentColorIndex)
            {
                if ((color >> 24) == 0)
                    return _Remember(color, (uint8)i);
                continue;
            }
            int diffA = Math.Abs((int)(color >> 24) - (int)(Palette[i] >> 24));
            int diffR = Math.Abs((int)((color >> 16) & 0xff) - (int)((Palette[i] >> 16) & 0xff));
            int diffG = Math.Abs((int)((color >> 8) & 0xff) - (int)((Palette[i] >> 8) & 0xff));
            int diffB = Math.Abs((int)(color & 0xff) - (int)(Palette[i] & 0xff));
            int diff = diffB * diffB + diffG * diffG + diffR * diffR + diffA * diffA;
            // the smallest difference, the first index of equal ones (SortedDictionary.First of the original)
            if (bestDiff < 0 || diff < bestDiff)
            {
                bestDiff = diff;
                bestIndex = i;
            }
        }
        if (bestDiff < 0)
            return null;
        uint32 paletteColor = Palette[bestIndex];
        Console.WriteLine("Warning: Color " + (color >> 24).ToString("x2") + r.ToString("x2") + g.ToString("x2") + b.ToString("x2") +
                          " was changed to palette color " + (paletteColor >> 24).ToString("x2") + ((paletteColor >> 16) & 0xff).ToString("x2") +
                          ((paletteColor >> 8) & 0xff).ToString("x2") + (paletteColor & 0xff).ToString("x2"));
        Mapped[color] = (uint8)bestIndex;
        return (uint8)bestIndex;
    }

    uint8 _Remember(uint32 color, uint8 index)
    {
        // TryAdd: an index that is there already stays
        if (Mapped.TryGet(color) is uint8 known)
            return known;
        Mapped[color] = index;
        return index;
    }
}

// A palette file of the game (64 bytes: 32 colors of 0R GB), or an image whose first 32 pixels are the colors; all
// opaque. null if it cannot be read.
Optional<uint32[]> LoadPalette(StringSlice path)
{
    if (File.ReadAllBytes(path) is not uint8[] bytes)
        return null;
    var palette = new uint32[32];
    if (bytes.Length != 64)
    {
        if (Image.Decode(bytes) is not Image image)
            return null;
        if (image.Pixels.Length < 32)
            return null;
        for (var i = 0; i < 32; i += 1)
            palette[i] = 0xFF000000u | (image.Pixels[i] & 0x00FFFFFFu);
        return palette;
    }
    for (var i = 0; i < 32; i += 1)
    {
        int ar = bytes[i * 2];
        int gb = bytes[i * 2 + 1];
        uint32 r = (uint32)(((ar << 4) & 0xf0) | (ar & 0x0f));
        uint32 g = (uint32)((gb >> 4) | (gb & 0xf0));
        uint32 b = (uint32)(((gb << 4) & 0xf0) | (gb & 0x0f));
        palette[i] = 0xFF000000u | (r << 16) | (g << 8) | b;
    }
    return palette;
}
