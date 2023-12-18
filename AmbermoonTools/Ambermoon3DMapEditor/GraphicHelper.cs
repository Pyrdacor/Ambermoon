using Ambermoon.Data;
using System.Runtime.InteropServices;

namespace Ambermoon3DMapEditor
{
    internal static class GraphicHelper
    {
        public static Bitmap[] GraphicToBitmaps(Graphic graphic, Graphic palette, int frameWidth)
        {
            int numFrames = graphic.Width / frameWidth;
            var frames = new List<Bitmap>(numFrames);

            for (int i = 0; i < numFrames; i++)
            {
                frames.Add(GraphicToBitmap(graphic.GetArea(i * frameWidth, 0, frameWidth, graphic.Height), palette));
            }

            return frames.ToArray();
        }

        public static Bitmap GraphicToBitmap(Graphic graphic, Graphic palette)
        {
            var pixelData = graphic.ToPixelData(palette);

            for (int i = 0; i < graphic.Width * graphic.Height; i++)
            {
                var temp = pixelData[i * 4 + 2];
                pixelData[i * 4 + 2] = pixelData[i * 4 + 0];
                pixelData[i * 4 + 0] = temp;
            }

            var bitmap = new Bitmap(graphic.Width, graphic.Height);
            var bitmapData = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

            Marshal.Copy(pixelData, 0, bitmapData.Scan0, pixelData.Length);

            bitmap.UnlockBits(bitmapData);

            return bitmap;
        }
    }
}
