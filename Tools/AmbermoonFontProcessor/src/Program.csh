// AmbermoonFontProcessor <imagePath> [commandFile]: edits a glyph atlas (16 glyphs per row; 16 pixels wide and 11 high,
// or 32 wide and 22 high): copies glyphs into the free slots and saves the atlas as PNG.
//
// This is the GlyphTool of the original, whose program does nothing as it is (the call of GlyphTool.Main is commented
// out). Commands: copy <index> | save [path] | exit.

using System;
using System.Image;
using Ambermoon;

const int GlyphsPerRow = 16;

struct GlyphTool
{
    Image Bmp;
    string ImagePath;
    int GlyphWidth;
    int GlyphHeight;
    int TotalGlyphs;
    int FreeIndex;
    bool Exit;

    void ProcessCommand(StringSlice line)
    {
        var parts = List<string>.Create();
        foreach (var part in line.Split(' '))
        {
            var trimmed = TrimNet(part);
            if (trimmed.Length > 0)
                parts.Add(trimmed.ToString());
        }
        if (parts.Count() == 0)
            return;
        string command = ToLowerNet(parts[0]);
        if (command == "exit")
        {
            // (in the original "exit" does nothing: it returns from the command, and the program goes on)
            Exit = true;
            return;
        }
        if (command == "copy")
        {
            var parsed = parts.Count() >= 2 ? ParseInt(parts[1]) : null;
            if (parsed is not int srcIndex)
            {
                Console.WriteLine("Usage: copy <index>");
                return;
            }
            if (srcIndex < 0 || srcIndex >= TotalGlyphs)
            {
                Console.WriteLine("Source index out of bounds.");
                return;
            }
            if (FreeIndex == TotalGlyphs)
            {
                AddGlyphRow();
                TotalGlyphs += GlyphsPerRow;
                Console.WriteLine("New glyph row was added to make space.");
            }
            CopyGlyph(srcIndex, FreeIndex);
            Console.WriteLine("Copied glyph " + srcIndex.ToString() + " to " + FreeIndex.ToString() + ".");
            FreeIndex += 1;
            return;
        }
        if (command == "save")
        {
            string outPath = parts.Count() >= 2 ? parts[1] : Path.Combine(Path.GetDirectory(ImagePath), Path.GetFileName(ImagePath));
            if (Bmp.Save(outPath, ImageFormat.Png) is error e)
                Console.WriteLine("Save failed: " + e.Message);
            else
                Console.WriteLine("Saved to: " + outPath);
            return;
        }
        Console.WriteLine("Unknown command. Use: addrow | copy <index> | save [path] | exit");
    }

    // A new row of glyphs at the bottom, transparent black (Graphics.Clear(Color.Transparent) of GDI+ gives 0).
    void AddGlyphRow()
    {
        var bigger = Image.Create(Bmp.Width, Bmp.Height + GlyphHeight);
        bigger.Copy(Bmp, 0, 0);
        Bmp = bigger;
        DrawnByGdi(0, 0, Bmp.Width, Bmp.Height - GlyphHeight);
    }

    // The pixels of a part after Graphics.DrawImage of GDI+: they go through premultiplied alpha, which loses
    // precision in the colors of half transparent pixels (measured for all colors and alphas).
    void DrawnByGdi(int x, int y, int width, int height)
    {
        for (var row = y; row < y + height; row += 1)
        {
            for (var column = x; column < x + width; column += 1)
            {
                uint32 p = Bmp.Pixels[row * Bmp.Width + column];
                uint32 a = p >> 24;
                if (a == 255)
                    continue;
                if (a == 0)
                {
                    Bmp.Pixels[row * Bmp.Width + column] = 0;
                    continue;
                }
                uint32 reciprocal = (255u << 16) / a;
                uint32 result = a << 24;
                for (var shift = 0; shift <= 16; shift += 8)
                {
                    uint32 c = (p >> shift) & 0xFF;
                    uint32 premultiplied = (c * a + 127) / 255;
                    result |= ((premultiplied * reciprocal) >> 16) << shift;
                }
                Bmp.Pixels[row * Bmp.Width + column] = result;
            }
        }
    }

    void CopyGlyph(int fromIndex, int toIndex)
    {
        int fromX = (fromIndex % GlyphsPerRow) * GlyphWidth;
        int fromY = (fromIndex / GlyphsPerRow) * GlyphHeight;
        int toX = (toIndex % GlyphsPerRow) * GlyphWidth;
        int toY = (toIndex / GlyphsPerRow) * GlyphHeight;
        var source = Bmp;
        Bmp.Copy(source, fromX, fromY, GlyphWidth, GlyphHeight, toX, toY);
        DrawnByGdi(toX, toY, GlyphWidth, GlyphHeight);
    }
}

int Main(string[] args)
{
    if (args.Length < 1)
    {
        Console.WriteLine("Usage: AmbermoonFontProcessor <imagePath>");
        return 0;
    }
    string imagePath = args[0];
    if (!File.Exists(imagePath) || Directory.Exists(imagePath))
    {
        Console.WriteLine("File not found: " + imagePath);
        return 0;
    }
    var loaded = Image.Load(imagePath);
    if (loaded is not Image bmp)
    {
        Console.WriteLine("Failed to load image: " + loaded.Message);
        return 0;
    }

    int glyphWidth = bmp.Width / GlyphsPerRow;
    bool large = glyphWidth == 32;
    int glyphHeight = large ? 22 : 11;
    if (bmp.Width % GlyphsPerRow != 0 || bmp.Height % glyphHeight != 0)
    {
        Console.WriteLine("Invalid bitmap dimensions for glyph layout.");
        return 0;
    }
    int totalGlyphs = GlyphsPerRow * (bmp.Height / glyphHeight);

    int freeIndex = -1;
    while (freeIndex < 0 || freeIndex > totalGlyphs)
    {
        Console.Write("Enter index of first free glyph slot: ");
        // (the original asks again forever at the end of the input)
        if (Console.ReadLine() is not string input)
            return 0;
        freeIndex = ParseInt(input) is int index ? index : -1;
        if (freeIndex < 0)
        {
            Console.WriteLine("Invalid index.");
            freeIndex = -1;
        }
    }

    var tool = GlyphTool { Bmp = bmp, ImagePath = imagePath, GlyphWidth = glyphWidth, GlyphHeight = glyphHeight,
                           TotalGlyphs = totalGlyphs, FreeIndex = freeIndex };
    if (args.Length >= 2)
    {
        var read = ReadAllTextNet(args[1]);
        if (read is not string text)
        {
            Console.WriteLine("Cannot read the command file '" + args[1] + "'.");
            return 1;
        }
        foreach (var line in SplitLinesNet(text))
        {
            if (IsWhiteSpaceOnlyNet(line))
                continue;
            Console.WriteLine("> " + line);
            tool.ProcessCommand(line);
            if (tool.Exit)
                return 0;
        }
    }

    Console.WriteLine("Enter commands: copy <index> | save [path] | exit");
    while (!tool.Exit)
    {
        Console.Write("> ");
        // (the original asks again forever at the end of the input)
        if (Console.ReadLine() is not string line)
            break;
        if (IsWhiteSpaceOnlyNet(line))
            continue;
        tool.ProcessCommand(line);
    }
    return 0;
}
