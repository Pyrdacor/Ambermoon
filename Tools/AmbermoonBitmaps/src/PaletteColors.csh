namespace AmbermoonBitmaps;

using System;
using System.Image;
using Ambermoon.Data;

/// The 32 colors of a palette of the game (a graphic of 2 bytes per color: 0R, GB with 4 bits each).
struct PaletteColors
{
    Color[] Colors;

    /// 32 colors that are all transparent black.
    static PaletteColors Create()
    {
        return PaletteColors { Colors = new Color[32] };
    }

    /// The colors of a palette graphic: each 4-bit component is repeated (0xA becomes 0xAA), all opaque.
    static PaletteColors FromPalette(Graphic palette)
    {
        var p = Create();
        for (var i = 0; i < p.Colors.Length; i += 1)
        {
            int r = palette.Data[i * 2] & 0xf;
            int gb = palette.Data[i * 2 + 1];
            int g = gb >> 4;
            int b = gb & 0xf;
            p.Colors[i] = Color.FromArgb(255, r | (r << 4), g | (g << 4), b | (b << 4));
        }
        return p;
    }
}
