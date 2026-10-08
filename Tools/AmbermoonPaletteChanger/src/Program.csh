// AmbermoonPaletteChanger <image> <palette> <colors> <output>: replaces each color of an image by the nearest color of
// a palette of the game (the first `colors` colors of the palette file; color 0 is transparent).

using System;
using System.Image;
using Ambermoon;
using AmbermoonBitmaps;

int Main(string[] args)
{
    if (args.Length < 4)
    {
        Console.WriteLine("USAGE: AmbermoonPaletteChanger <imageFile> <paletteFile> <numColors> <outFile>");
        return 1;
    }
    var loaded = GdiBitmap.Load(args[0]);
    if (loaded is not GdiBitmap bitmap)
    {
        Console.WriteLine("Failed to read image file: " + loaded.Message);
        return 1;
    }
    var read = File.ReadAllBytes(args[1]);
    if (read is not uint8[] palette)
    {
        Console.WriteLine("Failed to read palette file '" + args[1] + "'.");
        return 1;
    }
    if (ParseInt(args[2]) is not int numColors)
    {
        Console.WriteLine("Invalid number of colors: " + args[2]);
        return 1;
    }
    if (numColors < 1 || numColors * 2 > palette.Length)
    {
        Console.WriteLine("The number of colors must be 1 to " + (palette.Length / 2).ToString() + " (the size of the palette file).");
        return 1;
    }

    // color 0 is Color.Transparent of .NET: transparent white, which counts as white below (alpha is not compared)
    var colors = new uint32[numColors];
    colors[0] = 0x00FFFFFFu;
    for (var i = 1; i < numColors; i += 1)
    {
        uint32 r = palette[i * 2] & 0xfu;
        uint32 gb = palette[i * 2 + 1];
        uint32 g = gb >> 4;
        uint32 b = gb & 0xfu;
        colors[i] = 0xFF000000u | ((r | (r << 4)) << 16) | ((g | (g << 4)) << 8) | (b | (b << 4));
    }

    // SetPixel of GDI+ drops alpha in images without it (24 bits, 32 bits without alpha)
    uint32 alphaOr = bitmap.Kind == GdiPixelKind.Rgb ? 0xFF000000u : 0u;
    var matched = Dictionary<uint32, uint32>.Create();
    var pixels = bitmap.Image.Pixels;
    for (var i = 0; i < pixels.Length; i += 1)
    {
        uint32 color = pixels[i];
        uint32 best;
        if (matched.TryGet(color) is uint32 known)
            best = known;
        else
        {
            best = FindBestColor(color, colors);
            matched[color] = best;
        }
        pixels[i] = best | alphaOr;
    }

    // Bitmap.Save(path) writes the format of the file that was loaded, whatever the extension
    if (bitmap.Image.Save(args[3], bitmap.RawFormat) is error e)
    {
        Console.WriteLine("Failed to write output file: " + e.Message);
        return 1;
    }
    return 0;
}

// The palette color nearest to `color` (Euclidean distance of red, green and blue); the first of equally near ones.
uint32 FindBestColor(uint32 color, uint32[] colors)
{
    uint32 best = colors[0];
    int smallest = Distance(color, colors[0]);
    for (var i = 0; i < colors.Length; i += 1)
    {
        int distance = Distance(color, colors[i]);
        if (distance < smallest)
        {
            smallest = distance;
            best = colors[i];
        }
    }
    return best;
}

// The square of the distance (the original compares its square root: the same order).
int Distance(uint32 a, uint32 b)
{
    int dr = (int)((a >> 16) & 0xFF) - (int)((b >> 16) & 0xFF);
    int dg = (int)((a >> 8) & 0xFF) - (int)((b >> 8) & 0xFF);
    int db = (int)(a & 0xFF) - (int)(b & 0xFF);
    return dr * dr + dg * dg + db * db;
}
