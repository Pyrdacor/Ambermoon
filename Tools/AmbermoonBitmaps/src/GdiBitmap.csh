namespace AmbermoonBitmaps;

using System;
using System.Image;

/// The pixel format that GDI+ (`System.Drawing` of the original tools) gives an image file when it loads it: it decides
/// whether `SetPixel` keeps alpha (and whether it works at all).
enum GdiPixelKind : uint8
{
    /// A palette (`Format1bppIndexed`, `Format4bppIndexed`, `Format8bppIndexed`): `SetPixel` and `Graphics` fail in
    /// GDI+.
    Indexed = 0,
    /// True color without alpha (`Format24bppRgb`, `Format32bppRgb`): pixels that are set become opaque.
    Rgb = 1,
    /// True color with alpha (`Format32bppArgb`).
    Argb = 2
}

/// An image as the original tools load it with `new Bitmap(path)`: the pixels (the same as GDI+ gives), the pixel
/// format GDI+ chooses and the format of the file (`RawFormat`, which `Bitmap.Save(path)` writes).
struct GdiBitmap
{
    Image Image;
    GdiPixelKind Kind;
    ImageFormat RawFormat;

    /// Loads an image file (PNG, BMP; PPM, which GDI+ cannot read, as true color without alpha).
    /// @error ImageError the file cannot be read or is no image.
    static ImageError<GdiBitmap> Load(StringSlice path)
    {
        var read = File.ReadAllBytes(path);
        if (read is not uint8[] bytes)
            return error("cannot open the image file '" + path + "'", ImageError.CannotOpen);
        var decoded = Image.Decode(bytes);
        if (decoded is not Image image)
            return error(decoded.Message + " in '" + path + "'", decoded.Code);
        var format = Image.DetectFormat(bytes) is ImageFormat f ? f : ImageFormat.Png;
        return GdiBitmap { Image = image, Kind = KindOf(bytes), RawFormat = format };
    }

    /// The pixel format GDI+ gives the image file `data` (which must be a valid PNG, BMP or PPM file).
    static GdiPixelKind KindOf(ReadOnlySlice<uint8> data)
    {
        if (Image.DetectFormat(data) is ImageFormat format)
        {
            if (format == ImageFormat.Png)
                return _PngKind(data);
            if (format == ImageFormat.Bmp)
                return _BmpKind(data);
        }
        return GdiPixelKind.Rgb;
    }

    // PNG: 1-bit gray and palettes of 1, 4 and 8 bits are indexed without tRNS; 8-bit RGB without tRNS has no alpha;
    // everything else (also 2-bit palettes) is ARGB.
    static GdiPixelKind _PngKind(ReadOnlySlice<uint8> data)
    {
        if (data.Length < 29)
            return GdiPixelKind.Argb;
        int depth = data[24];
        int colorType = data[25];
        bool transparency = false;
        int pos = 8;
        while (pos + 8 <= data.Length)
        {
            int length = (data[pos] << 24) | (data[pos + 1] << 16) | (data[pos + 2] << 8) | data[pos + 3];
            if (length < 0)
                break;
            if (data[pos + 4] == 't' && data[pos + 5] == 'R' && data[pos + 6] == 'N' && data[pos + 7] == 'S')
                transparency = true;
            if (data[pos + 4] == 'I' && data[pos + 5] == 'D' && data[pos + 6] == 'A' && data[pos + 7] == 'T')
                break;   // tRNS comes before the image data
            pos += 12 + length;
        }
        if (transparency)
            return GdiPixelKind.Argb;
        if ((colorType == 3 && (depth == 1 || depth == 4 || depth == 8)) || (colorType == 0 && depth == 1))
            return GdiPixelKind.Indexed;
        if (colorType == 2 && depth == 8)
            return GdiPixelKind.Rgb;
        return GdiPixelKind.Argb;
    }

    // BMP: uncompressed 1, 4 and 8 bits are indexed; only an alpha mask (BITMAPV4HEADER and newer, or
    // BI_ALPHABITFIELDS) gives ARGB; RLE and the rest have no alpha.
    static GdiPixelKind _BmpKind(ReadOnlySlice<uint8> data)
    {
        if (data.Length < 30)
            return GdiPixelKind.Rgb;
        int headerSize = data[14] | (data[15] << 8);
        int bpp = headerSize == 12 ? data[24] | (data[25] << 8) : data[28] | (data[29] << 8);
        int compression = headerSize == 12 || data.Length < 34 ? 0 : data[30];
        if (bpp <= 8 && compression == 0)
            return GdiPixelKind.Indexed;
        if ((compression == 3 || compression == 6) && (headerSize >= 56 || compression == 6) && 14 + 56 <= data.Length)
        {
            int at = 54 + 12;
            if ((data[at] | data[at + 1] | data[at + 2] | data[at + 3]) != 0)
                return GdiPixelKind.Argb;
        }
        return GdiPixelKind.Rgb;
    }
}
