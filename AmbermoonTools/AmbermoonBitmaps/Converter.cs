using System.Drawing;
using System.Runtime.InteropServices;
using Ambermoon.Data;

namespace AmbermoonBitmaps;

public static class Converter
{
    public static Bitmap GraphicToBitmap(Graphic graphic, Graphic palette) => GraphicToBitmap(graphic, new PaletteColors(palette));

    public static Bitmap GraphicToBitmap(Graphic graphic, PaletteColors palette, int? colorKeyIndex = 0)
    {
        var bitmap = new Bitmap(graphic.Width, graphic.Height);
        var data = bitmap.LockBits(new(0, 0, graphic.Width, graphic.Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        int sourceIndex = 0;
        int targetIndex = 0;
        var targetData = new byte[graphic.Width * graphic.Height * 4];

        for (int y = 0; y < graphic.Height; y++)
        {
            for (int x = 0; x < graphic.Width; x++)
            {
                int colorIndex = graphic.Data[sourceIndex++];

                if (colorKeyIndex == colorIndex)
                {
                    targetData[targetIndex++] = 0; // Blue
                    targetData[targetIndex++] = 0; // Green
                    targetData[targetIndex++] = 0; // Red
                    targetData[targetIndex++] = 0; // Alpha
                }
                else
                {
                    var color = palette.Colors[colorIndex];
                    targetData[targetIndex++] = color.B; // Blue
                    targetData[targetIndex++] = color.G; // Green
                    targetData[targetIndex++] = color.R; // Red
                    targetData[targetIndex++] = color.A; // Alpha
                }
            }
        }

        Marshal.Copy(targetData, 0, data.Scan0, targetData.Length);

        bitmap.UnlockBits(data);

        return bitmap;
    }
}
