namespace AmbermoonBitmaps;

using System;
using System.Image;
using Ambermoon.Data;

/// Graphics of the game as images.
struct Converter
{
    /// The image of an indexed graphic with the colors of a palette graphic; color index 0 is transparent.
    static Image GraphicToBitmap(Graphic graphic, Graphic palette)
    {
        return GraphicToBitmap(graphic, PaletteColors.FromPalette(palette), 0);
    }

    /// The image of an indexed graphic with the colors of `palette`; the pixels of `colorKeyIndex` are transparent
    /// black (`null`: none).
    /// @panics when the graphic has a color index of 32 or more.
    static Image GraphicToBitmap(Graphic graphic, PaletteColors palette, Optional<int> colorKeyIndex)
    {
        int key = colorKeyIndex is int k ? k : -1;
        var image = Image.Create(graphic.Width, graphic.Height);
        int count = graphic.Width * graphic.Height;
        for (var i = 0; i < count; i += 1)
        {
            int colorIndex = graphic.Data[i];
            image.Pixels[i] = colorIndex == key ? 0u : palette.Colors[colorIndex].ToArgb();
        }
        return image;
    }
}
