using System.Drawing;
using System.Text.Json;
using System.Text.Json.Serialization;
using AmbermoonFontCreator;

if (args.Length != 4)
{
    Usage();
    return 1;
}


var fontSpecFile = args[0];
var smallGlyphs = args[1];
var largeGlyphs = args[2];
var output = args[3];

if (!File.Exists(fontSpecFile))
{
    Console.Error.WriteLine($"Font specification file '{fontSpecFile}' does not exist.");
    Usage();
    return 1;
}

if (!File.Exists(smallGlyphs))
{
    Console.Error.WriteLine($"Small glyphs image '{smallGlyphs}' does not exist.");
    Usage();
    return 1;
}

if (!File.Exists(largeGlyphs))
{
    Console.Error.WriteLine($"Large glyphs image '{largeGlyphs}' does not exist.");
    Usage();
    return 1;
}

if (Directory.Exists(output))
{
    output = Path.Combine(output, "AmbermoonFont.bin");
}
else
{
    var directory = Path.GetDirectoryName(output);

    if (!string.IsNullOrWhiteSpace(directory))
        Directory.CreateDirectory(directory);
}

var jsonOptions = new JsonSerializerOptions
{
    PropertyNameCaseInsensitive = true,
    Converters =
    {
        new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)
    }
};

var fontSpec = JsonSerializer.Deserialize<FontSpec>(File.ReadAllText(fontSpecFile), jsonOptions);

if (fontSpec == null)
{
    Console.Error.WriteLine($"Failed to deserialize font specification from '{fontSpecFile}'.");
    Usage();
    return 1;
}

return CreateFonts(output, fontSpec, smallGlyphs, largeGlyphs);

static void Usage()
{
    Console.WriteLine("AmbermoonFontCreator <font_spec> <small_glyphs_image> <large_glyphs_image> <out_path>");
    Console.WriteLine("Example: AmbermoonFontCreator font.json SmallGlyphs.png LargeGlyphs.png MyFont");
}

static int CreateFonts(string filename, FontSpec fontSpec, string smallGlyphImagePath, string largeGlyphImagePath)
{
    if (fontSpec.NumChars <= 0)
    {
        Console.Error.WriteLine("Font specification has no characters defined.");
        return 1;
    }

    if (fontSpec.NumGlyphs <= 0)
    {
        Console.Error.WriteLine("Font specification has no glyphs defined.");
        return 1;
    }

    if (fontSpec.SmallGlyphHeight <= 0 || fontSpec.LargeGlyphHeight <= 0 ||
        fontSpec.SmallUsedGlyphHeight <= 0 || fontSpec.LargeUsedGlyphHeight <= 0 ||
        fontSpec.SmallLineHeight <= 0 || fontSpec.LargeLineHeight <= 0 ||
        fontSpec.SmallUsedGlyphHeight > fontSpec.SmallGlyphHeight ||
        fontSpec.LargeUsedGlyphHeight > fontSpec.LargeGlyphHeight)
    {
        Console.Error.WriteLine("Font specification has invalid glyph heights.");
        return 1;
    }

    if (fontSpec.GlyphMapping.Count != fontSpec.NumChars)
    {
        Console.Error.WriteLine($"Glyph mapping length {fontSpec.GlyphMapping.Count} does not match number of characters {fontSpec.NumChars}.");
        return 1;
    }

    using var smallGlyphBitmap = new Bitmap(smallGlyphImagePath);
    using var largeGlyphBitmap = new Bitmap(largeGlyphImagePath);

    if (smallGlyphBitmap.Height % fontSpec.SmallGlyphHeight != 0)
    {
        Console.Error.WriteLine($"Small glyphs image height {smallGlyphBitmap.Height} is not a multiple of small glyph height {fontSpec.SmallGlyphHeight}.");
        return 1;
    }

    if (largeGlyphBitmap.Height % fontSpec.LargeGlyphHeight != 0)
    {
        Console.Error.WriteLine($"Large glyphs image height {largeGlyphBitmap.Height} is not a multiple of large glyph height {fontSpec.LargeGlyphHeight}.");
        return 1;
    }

    if (smallGlyphBitmap.Width != 16 * 16)
    {
        Console.Error.WriteLine($"Small glyphs image width {smallGlyphBitmap.Width} is not equal to 16 * 16 = 256 pixels.");
        return 1;
    }

    if (largeGlyphBitmap.Width != 16 * 32)
    {
        Console.Error.WriteLine($"Large glyphs image width {largeGlyphBitmap.Width} is not equal to 16 * 32 = 512 pixels.");
        return 1;
    }

    using var writer = new BinaryWriter(File.Create(filename));

    writer.Write(fontSpec.NumChars);
    writer.Write(fontSpec.NumGlyphs);
    writer.Write(fontSpec.SmallGlyphHeight);
    writer.Write(fontSpec.LargeGlyphHeight);
    // Used heights
    writer.Write(fontSpec.SmallUsedGlyphHeight);
    writer.Write(fontSpec.LargeUsedGlyphHeight);
    // Line heights
    writer.Write(fontSpec.SmallLineHeight);
    writer.Write(fontSpec.LargeLineHeight);
    // Space advances
    writer.Write(fontSpec.SmallSpaceAdvance);
    writer.Write(fontSpec.LargeSpaceAdvance);

    writer.Write([..fontSpec.GlyphMapping]);

    if (fontSpec.GlyphMapping.Count % 2 == 1)
        writer.Write((byte)0);

    var smallAdvances = GetGlyphAdvances(smallGlyphBitmap, 11);

    if (smallAdvances.Length != fontSpec.NumGlyphs)
    {
        Console.Error.WriteLine($"Small glyph advances count {smallAdvances.Length} does not match number of glyphs {fontSpec.NumGlyphs}.");
        return 1;
    }

    writer.Write(smallAdvances);

    if (smallAdvances.Length % 2 == 1)
        writer.Write((byte)0);

    var largeAdvances = GetGlyphAdvances(largeGlyphBitmap, 22);

    if (largeAdvances.Length != fontSpec.NumGlyphs)
    {
        Console.Error.WriteLine($"Large glyph advances count {largeAdvances.Length} does not match number of glyphs {fontSpec.NumGlyphs}.");
        return 1;
    }

    writer.Write(largeAdvances);

    if (largeAdvances.Length % 2 == 1)
        writer.Write((byte)0);

    var smallGlyphs = ExtractGlyphDataFromBitmap(smallGlyphBitmap, false, 11, fontSpec.NumGlyphs);

    writer.Write(smallGlyphs);

    var largeGlyphs = ExtractGlyphDataFromBitmap(largeGlyphBitmap, true, 22, fontSpec.NumGlyphs);

    writer.Write(largeGlyphs);

    while (writer.BaseStream.Position % 4 != 0)
    {
        writer.Write((byte)0); // Pad to 4-byte boundary
    }

    return 0;
}

// This function determines the horizontal pixel advance values of a glyph atlas.
// It calculates the real visible width of each glyph by checking the pixels in the bitmap.
// The advance is always the calculated width plus 1.
// The generated values can be used in the new font format.
static byte[] GetGlyphAdvances(Bitmap bitmap, int glyphHeight, int glyphsPerRow = 16)
{
    int glyphWidth = bitmap.Width / glyphsPerRow;
    int totalRows = bitmap.Height / glyphHeight;
    int totalGlyphs = glyphsPerRow * totalRows;

    var advances = new List<byte>(totalGlyphs);
    int glyphCount = 0;

    for (int index = 0; index < totalGlyphs; index++)
    {
        int gx = (index % glyphsPerRow) * glyphWidth;
        int gy = (index / glyphsPerRow) * glyphHeight;

        int width = 0;

        for (int y = 0; y < glyphHeight; y++)
        {
            for (int x = width; x < glyphWidth; x++)
            {
                Color pixel = bitmap.GetPixel(gx + x, gy + y);

                if (pixel.A > 0)
                {
                    if (x >= width)
                        width = x + 1;
                }
            }
        }

        if (width == 0)
        {
            glyphCount = index;
            break;
        }

        advances.Add((byte)(width + 1));
    }

    return [.. advances.Take(glyphCount)];
}

// This function extracts the glyph data from a bitmap image.
// The glyph data is basically the format which the Amiga executable expects.
// For small glyphs it always reads a big endian word (16 bits). The highest bit is the first pixel, the lowest the last pixel.
// For large glyphs it reads a big endian long (32 bits) in the same way.
// If a pixel bit is set, there is color (usually white), otherwise it is transparent (not rendered).
//
// The function expects an image which is a glyph atlas (multiple glyphs). By default 16 glyphs per row.
static byte[] ExtractGlyphDataFromBitmap(Bitmap bmp, bool large, int glyphHeight, int glyphCount, int glyphsPerRow = 16)
{
    if (bmp.Width % glyphsPerRow != 0)
        throw new ArgumentException($"Bitmap width {bmp.Width} is not a multiple of {glyphsPerRow}.");

    int glyphWidth = bmp.Width / glyphsPerRow;

    if (large && glyphWidth != 32)
        throw new ArgumentException($"Bitmap width {bmp.Width} is not valid for large glyphs (expected 32).");
    if (!large && glyphWidth != 16)
        throw new ArgumentException($"Bitmap width {bmp.Width} is not valid for small glyphs (expected 16).");

    int bytesPerRow = glyphWidth / 8;

    int glyphsInRow = bmp.Width / glyphWidth;
    int glyphRows = bmp.Height / glyphHeight;

    byte[] result = new byte[glyphCount * glyphHeight * bytesPerRow];

    int resultOffset = 0;

    for (int glyphIndex = 0; glyphIndex < glyphCount; glyphIndex++)
    {
        int glyphX = (glyphIndex % glyphsPerRow) * glyphWidth;
        int glyphY = (glyphIndex / glyphsPerRow) * glyphHeight;

        for (int row = 0; row < glyphHeight; row++)
        {
            uint bits = 0;

            for (int bit = 0; bit < glyphWidth; bit++)
            {
                Color color = bmp.GetPixel(glyphX + bit, glyphY + row);
                bool isSet = color.ToArgb() == Color.White.ToArgb(); // treat white as "on"
                bits <<= 1;
                if (isSet)
                    bits |= 1;
            }

            // Store as big endian
            for (int i = bytesPerRow - 1; i >= 0; i--)
            {
                result[resultOffset + i] = (byte)(bits & 0xFF);
                bits >>= 8;
            }

            resultOffset += bytesPerRow;
        }
    }

    return result;
}