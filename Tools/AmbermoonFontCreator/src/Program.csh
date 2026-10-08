// AmbermoonFontCreator <font_spec> <small_glyphs_image> <large_glyphs_image> <out_path>: makes a font file of the new
// format of the extro (see FontSpec) from a JSON specification and two glyph atlases (16 glyphs per row).

using System;
using System.Image;
using Ambermoon;

void Usage()
{
    Console.WriteLine("AmbermoonFontCreator <font_spec> <small_glyphs_image> <large_glyphs_image> <out_path>");
    Console.WriteLine("Example: AmbermoonFontCreator font.json SmallGlyphs.png LargeGlyphs.png MyFont");
}

int Main(string[] args)
{
    if (args.Length != 4)
    {
        Usage();
        return 1;
    }
    string fontSpecFile = args[0];
    string smallGlyphs = args[1];
    string largeGlyphs = args[2];
    string output = args[3];

    if (!FileExists(fontSpecFile))
    {
        Console.WriteError("Font specification file '" + fontSpecFile + "' does not exist.\n");
        Usage();
        return 1;
    }
    if (!FileExists(smallGlyphs))
    {
        Console.WriteError("Small glyphs image '" + smallGlyphs + "' does not exist.\n");
        Usage();
        return 1;
    }
    if (!FileExists(largeGlyphs))
    {
        Console.WriteError("Large glyphs image '" + largeGlyphs + "' does not exist.\n");
        Usage();
        return 1;
    }

    if (Directory.Exists(output))
        output = Path.Combine(output, "AmbermoonFont.bin");
    else
    {
        var directory = Path.GetDirectory(output);
        if (!IsWhiteSpaceOnlyNet(directory) && !Directory.Create(directory))
        {
            Console.WriteError("Cannot create the folder '" + directory + "'.\n");
            return 1;
        }
    }

    var spec = ReadFontSpec(fontSpecFile);
    if (spec is not FontSpec fontSpec)
    {
        // the original ends with an exception for invalid JSON, and only gives this message for "null"
        Console.WriteError("Failed to deserialize font specification from '" + fontSpecFile + "'.\n");
        Usage();
        return 1;
    }
    return CreateFonts(output, fontSpec, smallGlyphs, largeGlyphs);
}

// File.Exists of .NET: false for folders.
bool FileExists(StringSlice path)
{
    return File.Exists(path) && !Directory.Exists(path);
}

/// The font specification (the JSON file): the property names in any case, the missing ones have the defaults.
struct FontSpec
{
    int NumChars;
    int NumGlyphs;
    int SmallGlyphHeight;
    int LargeGlyphHeight;
    int SmallUsedGlyphHeight;
    int LargeUsedGlyphHeight;
    int SmallLineHeight;
    int LargeLineHeight;
    int SmallSpaceAdvance;
    int LargeSpaceAdvance;
    List<uint8> GlyphMapping;
}

// The specification of a JSON file; null if it is no object of these properties (JsonSerializer.Deserialize of the
// original: integers for the numbers, an array of bytes for the mapping, other properties are ignored).
Optional<FontSpec> ReadFontSpec(StringSlice path)
{
    if (ReadAllTextNet(path) is not string text)
        return null;
    if (Json.Parse(text) is not JsonValue root)
        return null;
    if (!root.IsObject())
        return null;
    var spec = FontSpec { SmallGlyphHeight = 11, LargeGlyphHeight = 22, SmallUsedGlyphHeight = 10, LargeUsedGlyphHeight = 21,
                          SmallLineHeight = 12, LargeLineHeight = 23, SmallSpaceAdvance = 6, LargeSpaceAdvance = 10,
                          GlyphMapping = List<uint8>.Create() };
    foreach (var key in root.Keys())
    {
        var value = root.Get(key);
        string name = key.ToLower();
        if (name == "glyphmapping")
        {
            if (!value.IsArray())
                return null;
            spec.GlyphMapping = List<uint8>.Create();
            foreach (var item in value.Items())
            {
                if (Integer(item, 0, 255) is not int b)
                    return null;
                spec.GlyphMapping.Add((uint8)b);
            }
            continue;
        }
        if (name != "numchars" && name != "numglyphs" && name != "smallglyphheight" && name != "largeglyphheight" &&
            name != "smallusedglyphheight" && name != "largeusedglyphheight" && name != "smalllineheight" &&
            name != "largelineheight" && name != "smallspaceadvance" && name != "largespaceadvance")
            continue;
        if (Integer(value, int.MinValue, int.MaxValue) is not int n)
            return null;
        switch (name)
        {
            case "numchars": spec.NumChars = n; break;
            case "numglyphs": spec.NumGlyphs = n; break;
            case "smallglyphheight": spec.SmallGlyphHeight = n; break;
            case "largeglyphheight": spec.LargeGlyphHeight = n; break;
            case "smallusedglyphheight": spec.SmallUsedGlyphHeight = n; break;
            case "largeusedglyphheight": spec.LargeUsedGlyphHeight = n; break;
            case "smalllineheight": spec.SmallLineHeight = n; break;
            case "largelineheight": spec.LargeLineHeight = n; break;
            case "smallspaceadvance": spec.SmallSpaceAdvance = n; break;
            default: spec.LargeSpaceAdvance = n; break;
        }
    }
    return spec;
}

// A JSON number that is an integer from min to max.
Optional<int> Integer(JsonValue value, int min, int max)
{
    if (!value.IsNumber())
        return null;
    double d = value.AsNumber();
    if (d != Math.Floor(d) || d < min || d > max)
        return null;
    return (int)d;
}

// The font file.
int CreateFonts(string filename, FontSpec fontSpec, string smallGlyphImagePath, string largeGlyphImagePath)
{
    if (fontSpec.NumChars <= 0)
    {
        Console.WriteError("Font specification has no characters defined.\n");
        return 1;
    }
    if (fontSpec.NumGlyphs <= 0)
    {
        Console.WriteError("Font specification has no glyphs defined.\n");
        return 1;
    }
    if (fontSpec.SmallGlyphHeight <= 0 || fontSpec.LargeGlyphHeight <= 0 ||
        fontSpec.SmallUsedGlyphHeight <= 0 || fontSpec.LargeUsedGlyphHeight <= 0 ||
        fontSpec.SmallLineHeight <= 0 || fontSpec.LargeLineHeight <= 0 ||
        fontSpec.SmallUsedGlyphHeight > fontSpec.SmallGlyphHeight ||
        fontSpec.LargeUsedGlyphHeight > fontSpec.LargeGlyphHeight)
    {
        Console.WriteError("Font specification has invalid glyph heights.\n");
        return 1;
    }
    if (fontSpec.GlyphMapping.Count() != fontSpec.NumChars)
    {
        Console.WriteError("Glyph mapping length " + fontSpec.GlyphMapping.Count().ToString() + " does not match number of characters " +
                           fontSpec.NumChars.ToString() + ".\n");
        return 1;
    }

    // (the original ends with an exception for files that are no images)
    if (Image.Load(smallGlyphImagePath) is not Image smallGlyphBitmap)
    {
        Console.WriteError("Small glyphs image '" + smallGlyphImagePath + "' cannot be read.\n");
        return 1;
    }
    if (Image.Load(largeGlyphImagePath) is not Image largeGlyphBitmap)
    {
        Console.WriteError("Large glyphs image '" + largeGlyphImagePath + "' cannot be read.\n");
        return 1;
    }
    if (smallGlyphBitmap.Height % fontSpec.SmallGlyphHeight != 0)
    {
        Console.WriteError("Small glyphs image height " + smallGlyphBitmap.Height.ToString() + " is not a multiple of small glyph height " +
                           fontSpec.SmallGlyphHeight.ToString() + ".\n");
        return 1;
    }
    if (largeGlyphBitmap.Height % fontSpec.LargeGlyphHeight != 0)
    {
        Console.WriteError("Large glyphs image height " + largeGlyphBitmap.Height.ToString() + " is not a multiple of large glyph height " +
                           fontSpec.LargeGlyphHeight.ToString() + ".\n");
        return 1;
    }
    if (smallGlyphBitmap.Width != 16 * 16)
    {
        Console.WriteError("Small glyphs image width " + smallGlyphBitmap.Width.ToString() + " is not equal to 16 * 16 = 256 pixels.\n");
        return 1;
    }
    if (largeGlyphBitmap.Width != 16 * 32)
    {
        Console.WriteError("Large glyphs image width " + largeGlyphBitmap.Width.ToString() + " is not equal to 16 * 32 = 512 pixels.\n");
        return 1;
    }

    // the file is written up to an error, like the original (whose writer is closed at the return)
    var writer = List<uint8>.Create();
    int result = WriteFont(ref writer, fontSpec, smallGlyphBitmap, largeGlyphBitmap);
    while (result == 0 && writer.Count() % 4 != 0)
        writer.Add(0); // Pad to 4-byte boundary
    if (File.WriteAllBytes(filename, writer.ToArray()) is error e)
    {
        Console.WriteError(e.Message + "\n");
        return 1;
    }
    return result;
}

int WriteFont(ref List<uint8> writer, const ref FontSpec fontSpec, const ref Image smallGlyphBitmap, const ref Image largeGlyphBitmap)
{
    writer.Add((uint8)fontSpec.NumChars);
    writer.Add((uint8)fontSpec.NumGlyphs);
    writer.Add((uint8)fontSpec.SmallGlyphHeight);
    writer.Add((uint8)fontSpec.LargeGlyphHeight);
    // Used heights
    writer.Add((uint8)fontSpec.SmallUsedGlyphHeight);
    writer.Add((uint8)fontSpec.LargeUsedGlyphHeight);
    // Line heights
    writer.Add((uint8)fontSpec.SmallLineHeight);
    writer.Add((uint8)fontSpec.LargeLineHeight);
    // Space advances
    writer.Add((uint8)fontSpec.SmallSpaceAdvance);
    writer.Add((uint8)fontSpec.LargeSpaceAdvance);
    foreach (var b in fontSpec.GlyphMapping)
        writer.Add(b);
    if (fontSpec.GlyphMapping.Count() % 2 == 1)
        writer.Add(0);

    // (the advances and the glyphs use the heights 11 and 22, not those of the specification, like the original)
    var smallAdvances = GetGlyphAdvances(smallGlyphBitmap, 11);
    if (smallAdvances.Length != fontSpec.NumGlyphs)
    {
        Console.WriteError("Small glyph advances count " + smallAdvances.Length.ToString() + " does not match number of glyphs " +
                           fontSpec.NumGlyphs.ToString() + ".\n");
        return 1;
    }
    writer.AddRange(smallAdvances);
    if (smallAdvances.Length % 2 == 1)
        writer.Add(0);

    var largeAdvances = GetGlyphAdvances(largeGlyphBitmap, 22);
    if (largeAdvances.Length != fontSpec.NumGlyphs)
    {
        Console.WriteError("Large glyph advances count " + largeAdvances.Length.ToString() + " does not match number of glyphs " +
                           fontSpec.NumGlyphs.ToString() + ".\n");
        return 1;
    }
    writer.AddRange(largeAdvances);
    if (largeAdvances.Length % 2 == 1)
        writer.Add(0);

    writer.AddRange(ExtractGlyphDataFromBitmap(smallGlyphBitmap, false, 11, fontSpec.NumGlyphs));
    writer.AddRange(ExtractGlyphDataFromBitmap(largeGlyphBitmap, true, 22, fontSpec.NumGlyphs));
    return 0;
}

// The horizontal advance of each glyph of an atlas: the width of its visible pixels (alpha above 0) plus 1, up to the
// first empty glyph. An atlas without an empty glyph gives none (like the original).
uint8[] GetGlyphAdvances(const ref Image bitmap, int glyphHeight)
{
    int glyphsPerRow = 16;
    int glyphWidth = bitmap.Width / glyphsPerRow;
    int totalRows = bitmap.Height / glyphHeight;
    int totalGlyphs = glyphsPerRow * totalRows;
    var advances = List<uint8>.Create();
    int glyphCount = 0;
    for (var index = 0; index < totalGlyphs; index += 1)
    {
        int gx = (index % glyphsPerRow) * glyphWidth;
        int gy = (index / glyphsPerRow) * glyphHeight;
        int width = 0;
        for (var y = 0; y < glyphHeight; y += 1)
        {
            for (var x = width; x < glyphWidth; x += 1)
            {
                if ((bitmap.GetArgb(gx + x, gy + y) >> 24) > 0)
                    width = x + 1;
            }
        }
        if (width == 0)
        {
            glyphCount = index;
            break;
        }
        advances.Add((uint8)(width + 1));
    }
    var result = new uint8[glyphCount];
    for (var i = 0; i < glyphCount; i += 1)
        result[i] = advances[i];
    return result;
}

// The glyph data of the executable: a big-endian word (small glyphs) or long (large glyphs) per row, the highest bit
// is the first pixel; white pixels are set.
uint8[] ExtractGlyphDataFromBitmap(const ref Image bmp, bool large, int glyphHeight, int glyphCount)
{
    int glyphsPerRow = 16;
    int glyphWidth = bmp.Width / glyphsPerRow;
    int bytesPerRow = glyphWidth / 8;
    var result = new uint8[glyphCount * glyphHeight * bytesPerRow];
    int resultOffset = 0;
    for (var glyphIndex = 0; glyphIndex < glyphCount; glyphIndex += 1)
    {
        int glyphX = (glyphIndex % glyphsPerRow) * glyphWidth;
        int glyphY = (glyphIndex / glyphsPerRow) * glyphHeight;
        for (var row = 0; row < glyphHeight; row += 1)
        {
            uint32 bits = 0;
            for (var bit = 0; bit < glyphWidth; bit += 1)
            {
                bits <<= 1;
                if (bmp.GetArgb(glyphX + bit, glyphY + row) == 0xFFFFFFFFu)  // treat white as "on"
                    bits |= 1;
            }
            // Store as big endian
            for (var i = bytesPerRow - 1; i >= 0; i -= 1)
            {
                result[resultOffset + i] = (uint8)(bits & 0xFF);
                bits >>= 8;
            }
            resultOffset += bytesPerRow;
        }
    }
    return result;
}
