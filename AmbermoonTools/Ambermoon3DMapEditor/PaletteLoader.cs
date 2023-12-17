using Ambermoon.Data;

namespace Ambermoon3DMapEditor
{
    internal class PaletteLoader
    {
        public static List<Palette> LoadPalettes(List<Graphic> graphics)
        {
            return graphics.Select(g => LoadPalette(g)).ToList();
        }

        public static Palette LoadPalette(Graphic graphic)
        {
            var colors = new Color[32];
            int j = 0;

            for (int i = 0; i < 32; i++)
            {
                int r = graphic.Data[j++];
                int g = graphic.Data[j++];
                int b = graphic.Data[j++];
                int a = graphic.Data[j++];
                colors[i] = Color.FromArgb(a, r, g, b);
            }

            return new Palette(colors);
        }
    }
}
