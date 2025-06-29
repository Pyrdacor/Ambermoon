using System.Drawing;
using Ambermoon.Data;

namespace AmbermoonBitmaps;

public class PaletteColors
{
    public readonly Color[] Colors = new Color[32];

    public PaletteColors()
    {

    }

    public PaletteColors(Graphic palette)
    {
        for (int i = 0; i < Colors.Length; i++)
        {
            var r = palette.Data[i * 2] & 0xf;
            var gb = palette.Data[i * 2 + 1];
            var g = gb >> 4;
            var b = gb & 0xf;

            r |= (r << 4);
            g |= (g << 4);
            b |= (b << 4);

            Colors[i] = Color.FromArgb(255, r, g, b);
        }
    }
}
