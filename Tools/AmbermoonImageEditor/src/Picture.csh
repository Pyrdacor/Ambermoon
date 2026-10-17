// The picture that is edited: palette indices with a palette (up to 256 colors), or ARGB pixels for images with more
// colors. Amiga graphics are always indexed, with 1 << bpp colors, and color 0 is transparent.

using System;
using System.Image;

const int MaxPaletteColors = 256;

struct Picture
{
    int Width;
    int Height;
    bool Indexed;
    /// The palette indices (indexed pictures).
    uint8[] Indices;
    /// The colors as ARGB (indexed pictures).
    List<uint32> Palette;
    /// The pixels as ARGB (pictures with more than 256 colors).
    uint32[] Pixels;
    /// Color 0 is transparent (Amiga graphics).
    bool TransparentZero;

    /// A new Amiga graphic: all pixels color 0, the default palette cut to 1 << bpp colors.
    static Picture CreateAmiga(int width, int height, int bpp)
    {
        var palette = AmigaPalette(bpp, 0);
        return Picture
        {
            Width = width,
            Height = height,
            Indexed = true,
            Indices = new uint8[width * height],
            Palette = palette,
            Pixels = new uint32[0],
            TransparentZero = true
        };
    }

    /// A picture of indices with a palette (an Amiga graphic that was read).
    static Picture FromIndices(int width, int height, uint8[] indices, List<uint32> palette)
    {
        return Picture
        {
            Width = width,
            Height = height,
            Indexed = true,
            Indices = indices,
            Palette = palette,
            Pixels = new uint32[0],
            TransparentZero = true
        };
    }

    /// A picture of an image: indexed if it has at most 256 colors (in the order they appear; fully transparent pixels
    /// become one color), else ARGB.
    static Picture FromImage(Image image)
    {
        var lookup = Dictionary<uint32, int>.Create();
        var palette = List<uint32>.Create();
        var indices = new uint8[image.Width * image.Height];
        bool indexed = true;
        for (var i = 0; i < image.Pixels.Length && indexed; i += 1)
        {
            uint32 color = _Normal(image.Pixels[i]);
            if (lookup.TryGet(color) is int known)
            {
                indices[i] = (uint8)known;
                continue;
            }
            if (palette.Count() == MaxPaletteColors)
            {
                indexed = false;
                break;
            }
            lookup[color] = palette.Count();
            indices[i] = (uint8)palette.Count();
            palette.Add(color);
        }
        var picture = Picture
        {
            Width = image.Width,
            Height = image.Height,
            Indexed = indexed,
            Indices = indexed ? indices : new uint8[0],
            Palette = indexed ? palette : List<uint32>.Create(),
            Pixels = indexed ? new uint32[0] : image.Pixels.Clone(),
            TransparentZero = false
        };
        if (!indexed)
        {
            for (var i = 0; i < picture.Pixels.Length; i += 1)
                picture.Pixels[i] = _Normal(picture.Pixels[i]);
        }
        return picture;
    }

    // all fully transparent colors are one
    static uint32 _Normal(uint32 color)
    {
        return (color >> 24) == 0 ? (uint32)0 : color;
    }

    Picture Clone()
    {
        var copy = this;
        copy.Indices = Indices.Clone();
        copy.Pixels = Pixels.Clone();
        var palette = List<uint32>.Create();
        foreach (var color in Palette)
            palette.Add(color);
        copy.Palette = palette;
        return copy;
    }

    bool Contains(int x, int y)
    {
        return x >= 0 && y >= 0 && x < Width && y < Height;
    }

    // ---- colors ----

    /// The color of a palette index as it is shown (color 0 transparent if wanted).
    uint32 IndexColor(int index)
    {
        if (index < 0 || index >= Palette.Count())
            return 0xffff00ffu;
        if (index == 0 && TransparentZero)
            return 0;
        return Palette[index];
    }

    /// The color of a pixel: an index (indexed pictures) or ARGB.
    uint32 Get(int x, int y)
    {
        int i = x + y * Width;
        return Indexed ? (uint32)Indices[i] : Pixels[i];
    }

    void Set(int x, int y, uint32 value)
    {
        if (!Contains(x, y))
            return;
        int i = x + y * Width;
        if (Indexed)
            Indices[i] = (uint8)value;
        else
            Pixels[i] = value;
    }

    /// The value that makes a pixel transparent: index 0 of an Amiga graphic, a transparent palette color (added if
    /// there is room), or transparent ARGB. -1 if an indexed picture has no room for it.
    int64 TransparentValue()
    {
        if (!Indexed)
            return 0;
        if (TransparentZero)
            return 0;
        for (var i = 0; i < Palette.Count(); i += 1)
        {
            if ((Palette[i] >> 24) == 0)
                return i;
        }
        if (Palette.Count() >= MaxPaletteColors)
            return -1;
        Palette.Add(0);
        return Palette.Count() - 1;
    }

    // ---- drawing ----

    /// A line of pixels (both ends included).
    void Line(int x0, int y0, int x1, int y1, uint32 value, int size)
    {
        int dx = Math.Abs(x1 - x0);
        int dy = -Math.Abs(y1 - y0);
        int sx = x0 < x1 ? 1 : -1;
        int sy = y0 < y1 ? 1 : -1;
        int err = dx + dy;
        while (true)
        {
            Dot(x0, y0, value, size);
            if (x0 == x1 && y0 == y1)
                break;
            int e2 = 2 * err;
            if (e2 >= dy)
            {
                err += dy;
                x0 += sx;
            }
            if (e2 <= dx)
            {
                err += dx;
                y0 += sy;
            }
        }
    }

    /// A square of `size` pixels with the pixel in its middle (for even sizes left and up of the middle).
    void Dot(int x, int y, uint32 value, int size)
    {
        int start = -(size - 1) / 2;
        for (var by = 0; by < size; by += 1)
        {
            for (var bx = 0; bx < size; bx += 1)
                Set(x + start + bx, y + start + by, value);
        }
    }

    /// Fills the area of the color at the pixel (connected horizontally and vertically).
    void Fill(int x, int y, uint32 value)
    {
        if (!Contains(x, y))
            return;
        uint32 old = Get(x, y);
        if (old == value)
            return;
        var stack = List<int>.Create();
        stack.Add(x + y * Width);
        while (stack.Count() > 0)
        {
            int i = stack[stack.Count() - 1];
            stack.RemoveAt(stack.Count() - 1);
            int px = i % Width;
            int py = i / Width;
            if (Get(px, py) != old)
                continue;
            Set(px, py, value);
            if (px > 0) stack.Add(i - 1);
            if (px < Width - 1) stack.Add(i + 1);
            if (py > 0) stack.Add(i - Width);
            if (py < Height - 1) stack.Add(i + Width);
        }
    }

    /// Replaces the color of the pixel everywhere.
    void Replace(int x, int y, uint32 value)
    {
        if (!Contains(x, y))
            return;
        uint32 old = Get(x, y);
        for (var py = 0; py < Height; py += 1)
        {
            for (var px = 0; px < Width; px += 1)
            {
                if (Get(px, py) == old)
                    Set(px, py, value);
            }
        }
    }

    // ---- showing and saving ----

    /// The picture as an image (transparent where it is transparent).
    Image ToImage()
    {
        var image = Image.Create(Width, Height);
        RenderInto(image);
        return image;
    }

    /// The picture as it is shown: transparent pixels over a checkerboard.
    Image ToCheckedImage()
    {
        var image = Image.Create(Width, Height);
        RenderInto(image);
        CheckerBehind(image);
        return image;
    }

    /// Draws the picture into an image of its size.
    void RenderInto(Image image)
    {
        if (Indexed)
        {
            var colors = new uint32[Palette.Count()];
            for (var i = 0; i < colors.Length; i += 1)
                colors[i] = IndexColor(i);
            for (var i = 0; i < Indices.Length; i += 1)
            {
                int index = (int)Indices[i];
                image.Pixels[i] = index < colors.Length ? colors[index] : 0xffff00ffu;
            }
        }
        else
        {
            for (var i = 0; i < Pixels.Length; i += 1)
                image.Pixels[i] = Pixels[i];
        }
    }

    /// The bits per pixel the picture needs as an Amiga graphic (0: too many colors).
    int NeededBpp()
    {
        if (!Indexed)
            return 0;
        int highest = 0;
        foreach (var index in Indices)
            highest = Math.Max(highest, (int)index);
        int count = Math.Max(highest + 1, TransparentZero ? 0 : Palette.Count());
        foreach (var bpp in AllowedBpp())
        {
            if (count <= (1 << bpp))
                return bpp;
        }
        return 0;
    }
}

/// Puts a checkerboard behind the transparent pixels of an image (blending the half transparent ones).
void CheckerBehind(Image image)
{
    for (var y = 0; y < image.Height; y += 1)
    {
        for (var x = 0; x < image.Width; x += 1)
        {
            int i = x + y * image.Width;
            uint32 color = image.Pixels[i];
            uint32 alpha = color >> 24;
            if (alpha == 255)
                continue;
            uint32 back = (((x >> 2) + (y >> 2)) & 1) == 0 ? (uint32)0x9c : (uint32)0x6c;
            uint32 r = (((color >> 16) & 0xff) * alpha + back * (255 - alpha)) / 255;
            uint32 g = (((color >> 8) & 0xff) * alpha + back * (255 - alpha)) / 255;
            uint32 b = ((color & 0xff) * alpha + back * (255 - alpha)) / 255;
            image.Pixels[i] = 0xff000000u | (r << 16) | (g << 8) | b;
        }
    }
}

// ---- normalizing the colors ----

/// The picture as an Amiga graphic of `bpp` bits per pixel: color 0 is transparent (and taken by transparent pixels),
/// the other colors are reduced to 12 bits and to at most (1 << bpp) - 1 colors (median cut), every pixel gets the
/// nearest of them.
Picture Normalize(Picture picture, int bpp)
{
    int count = 1 << bpp;
    // the colors of the picture with how often they appear (12 bits, opaque only)
    var counts = Dictionary<int, int>.Create();
    int pixels = picture.Width * picture.Height;
    var source = new uint32[pixels];
    for (var i = 0; i < pixels; i += 1)
    {
        int x = i % picture.Width;
        int y = i / picture.Width;
        uint32 color = picture.Indexed ? picture.IndexColor((int)picture.Get(x, y)) : picture.Get(x, y);
        source[i] = color;
        if ((color >> 24) < 128)
            continue;
        int amiga = ToAmigaColor(color);
        if (counts.TryGet(amiga) is int known)
            counts[amiga] = known + 1;
        else
            counts[amiga] = 1;
    }

    var colors = List<int>.Create();
    var weights = List<int>.Create();
    foreach (var entry in counts.Entries())
    {
        colors.Add(entry.Key);
        weights.Add(entry.Value);
    }
    var palette = List<uint32>.Create();
    palette.Add(picture.Indexed && picture.Palette.Count() > 0 && picture.TransparentZero ? picture.Palette[0] : 0xff000000u);
    foreach (var color in _MedianCut(colors, weights, count - 1))
        palette.Add(FromAmigaColor(color));
    while (palette.Count() < count)
        palette.Add(0xff000000u);

    var indices = new uint8[pixels];
    var nearest = Dictionary<uint32, int>.Create();
    for (var i = 0; i < pixels; i += 1)
    {
        uint32 color = source[i];
        if ((color >> 24) < 128)
            continue;
        if (nearest.TryGet(color) is int found)
        {
            indices[i] = (uint8)found;
            continue;
        }
        int best = 1;
        int bestDistance = int.MaxValue;
        for (var p = 1; p < count; p += 1)
        {
            int distance = _Distance(color, palette[p]);
            if (distance < bestDistance)
            {
                best = p;
                bestDistance = distance;
            }
        }
        nearest[color] = best;
        indices[i] = (uint8)best;
    }
    return Picture.FromIndices(picture.Width, picture.Height, indices, palette);
}

int _Distance(uint32 a, uint32 b)
{
    int dr = (int)((a >> 16) & 0xff) - (int)((b >> 16) & 0xff);
    int dg = (int)((a >> 8) & 0xff) - (int)((b >> 8) & 0xff);
    int db = (int)(a & 0xff) - (int)(b & 0xff);
    // weighted like the eye: green counts most
    return 3 * dr * dr + 4 * dg * dg + 2 * db * db;
}

// at most `count` colors (12 bits) for colors with weights: the box with the widest range of a channel is split at
// its weighted median until there are enough boxes; each box gives its weighted average
List<int> _MedianCut(List<int> colors, List<int> weights, int count)
{
    var result = List<int>.Create();
    if (colors.Count() == 0 || count <= 0)
        return result;
    if (colors.Count() <= count)
    {
        foreach (var color in colors)
            result.Add(color);
        return result;
    }
    // boxes as lists of positions in colors
    var boxes = List<List<int>>.Create();
    var all = List<int>.Create();
    for (var i = 0; i < colors.Count(); i += 1)
        all.Add(i);
    boxes.Add(all);
    while (boxes.Count() < count)
    {
        // the box with the widest channel
        int bestBox = -1;
        int bestChannel = 0;
        int bestRange = 0;
        for (var b = 0; b < boxes.Count(); b += 1)
        {
            if (boxes[b].Count() < 2)
                continue;
            for (var channel = 0; channel < 3; channel += 1)
            {
                int low = 15;
                int high = 0;
                foreach (var i in boxes[b])
                {
                    int v = (colors[i] >> (8 - 4 * channel)) & 0xf;
                    low = Math.Min(low, v);
                    high = Math.Max(high, v);
                }
                if (high - low > bestRange)
                {
                    bestRange = high - low;
                    bestBox = b;
                    bestChannel = channel;
                }
            }
        }
        if (bestBox < 0)
            break;
        var box = boxes[bestBox];
        int shift = 8 - 4 * bestChannel;
        // sort the box by the channel (16 values: counting sort)
        var sorted = List<int>.Create();
        for (var v = 0; v < 16; v += 1)
        {
            foreach (var i in box)
            {
                if (((colors[i] >> shift) & 0xf) == v)
                    sorted.Add(i);
            }
        }
        int total = 0;
        foreach (var i in sorted)
            total += weights[i];
        // split at the weighted median, but at a change of the value, and never empty
        int sum = 0;
        int split = 1;
        for (var k = 0; k < sorted.Count() - 1; k += 1)
        {
            sum += weights[sorted[k]];
            split = k + 1;
            if (2 * sum >= total)
                break;
        }
        var first = List<int>.Create();
        var second = List<int>.Create();
        for (var k = 0; k < sorted.Count(); k += 1)
        {
            if (k < split)
                first.Add(sorted[k]);
            else
                second.Add(sorted[k]);
        }
        boxes[bestBox] = first;
        boxes.Add(second);
    }
    foreach (var box in boxes)
    {
        int64 r = 0;
        int64 g = 0;
        int64 b = 0;
        int64 total = 0;
        foreach (var i in box)
        {
            int64 w = weights[i];
            r += w * ((colors[i] >> 8) & 0xf);
            g += w * ((colors[i] >> 4) & 0xf);
            b += w * (colors[i] & 0xf);
            total += w;
        }
        if (total == 0)
            continue;
        int color = (int)((r + total / 2) / total) << 8 | (int)((g + total / 2) / total) << 4 | (int)((b + total / 2) / total);
        if (!result.Contains(color))
            result.Add(color);
    }
    return result;
}
