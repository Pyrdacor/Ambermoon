using Ambermoon.Data;
using System.Runtime.InteropServices;

namespace Ambermoon3DMapEditor
{
    internal static class GraphicHelper
    {
        public static Bitmap[] GraphicToBitmaps(Graphic graphic, Graphic palette, int frameWidth, bool transparency)
        {
            int numFrames = graphic.Width / frameWidth;
            var frames = new List<Bitmap>(numFrames);

            for (int i = 0; i < numFrames; i++)
            {
                frames.Add(GraphicToBitmap(graphic.GetArea(i * frameWidth, 0, frameWidth, graphic.Height), palette, transparency));
            }

            return frames.ToArray();
        }

        public static Bitmap GraphicToBitmap(Graphic graphic, Graphic palette, bool transparency, bool portrait = false)
        {
            if (portrait)
            {
                if (transparency)
                {
                    for (int i = 0; i < graphic.Data.Length; i++)
                    {
                        if (graphic.Data[i] == 0)
                            graphic.Data[i] = 25;
                    }
                }

                for (int i = 0; i < graphic.Data.Length; i++)
                {
                    if (graphic.Data[i] == 32)
                        graphic.Data[i] = 0;
                }
            }

            var pixelData = graphic.ToPixelData(palette, (byte)(transparency ? (portrait ? 25 : 0) : 32));

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
