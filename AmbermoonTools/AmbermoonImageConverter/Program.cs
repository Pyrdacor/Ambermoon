using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;

namespace AmbermoonImageConverter
{
    class Program
    {
        // args[0]: Image
        // args[1]: Palette file
        // args[2]: Output image
        // args[3]: Format (5: 5bit, 4: 4bit, 3: 3bit, 0: 4bit texture)
        // args[4]: Frames (default 1)
        static void Main(string[] args)
        {
            // TODO: Later add both ways of conversion and support 3, 4 and 5 bit images as well as palettes.

            var imageData = LoadImageData(args[0], out int width, out int height);
            var palette = LoadPalette(args[1]);
            var palIndices = new byte[imageData.Length / 4];
            int format = int.Parse(args[3]);
            int bpp = format;

            if (bpp == 0)
                bpp = 4;

            int frames = args.Length == 4 ? 1 : int.Parse(args[4]);

            for (int i = 0; i < palIndices.Length; ++i)
            {
                palIndices[i] = FindPaletteIndex(palette, BitConverter.ToUInt32(imageData, i * 4), (byte)((1 << bpp) - 1));
            }

            var outputData = new byte[height * bpp * width / 8];
            int frameWidth = width / frames;
            int sizePerFrame = height * bpp * frameWidth / 8;
            int scanLine = format == 0 ? 8 : frameWidth;
            int scans = format == 0 ? (frameWidth + 7) / 8 : 1;

            for (int f = 0; f < frames; ++f)
            {
                for (int y = 0; y < height; ++y)
                {
                    int baseIndex = f * sizePerFrame + y * bpp * frameWidth / 8;
                    int xoff = 0;

                    for (int s = 0; s < scans; ++s)
                    {
                        for (int p = 0; p < bpp; ++p)
                        {
                            for (int x = 0; x < scanLine; ++x)
                            {
                                int bitIndex = x % 8;
                                int bit = (palIndices[y * width + f * frameWidth + x + xoff] >> p) & 0x1;
                                bit <<= (7 - bitIndex);
                                outputData[baseIndex + p * scanLine / 8 + x / 8] |= (byte)bit;
                            }
                        }

                        baseIndex += 4;
                        xoff += 8;
                    }
                }
            }

            File.WriteAllBytes(args[2], outputData);
        }

        static byte FindPaletteIndex(uint[] palette, uint color, byte max)
        {
            max = Math.Min(max, (byte)31);

            if ((color & 0xff000000) == 0) // transparent
                return 0;

            uint r = (color >> 16) & 0xf0;
            uint g = (color >> 8) & 0xf0;
            uint b = color & 0xf0;

            color = 0xff000000 | (r << 16) | (r << 12) | (g << 8) | (g << 4) | b | (b >> 4);

            var diffs = new SortedDictionary<int, int>();

            for (int i = 0; i <= max; ++i)
            {
                if (palette[i] == color)
                    return (byte)i;

                var diffA = Math.Abs((int)(color >> 24) - (int)(palette[i] >> 24));
                var diffR = Math.Abs((int)((color >> 16) & 0xff) - (int)((palette[i] >> 16) & 0xff));
                var diffG = Math.Abs((int)((color >> 8) & 0xff) - (int)((palette[i] >> 8)& 0xff));
                var diffB = Math.Abs((int)((color & 0xff) - (int)(palette[i] & 0xff)));
                int diff = diffB * diffB + diffG * diffG + diffR * diffR + diffA * diffA;

                if (!diffs.ContainsKey(diff))
                    diffs.Add(diff, i);
            }

            if (diffs.First().Value != 0)
                throw new Exception();

            return (byte)diffs.First().Value;
        }

        static uint[] LoadPalette(string filename)
        {
            var palette = new uint[32];
            using var binarReader = new BinaryReader(File.OpenRead(filename));

            for (int i = 0; i < 32; ++i)
            {
                byte ar = binarReader.ReadByte();
                byte gb = binarReader.ReadByte();
                int a = 0xff;
                int r = ((ar << 4) & 0xf0) | (ar & 0x0f);
                int g = (gb >> 4) | (gb & 0xf0);
                int b = ((gb << 4) & 0xf0) | (gb & 0x0f);
                palette[i] = ((uint)a << 24) | ((uint)r << 16) | ((uint)g << 8) | (uint)b;
            }

            return palette;
        }

        static byte[] LoadImageData(string filename, out int width, out int height)
        {
            var bitmap = (Bitmap)Image.FromFile(filename);
            width = bitmap.Width;
            height = bitmap.Height;
            var data = bitmap.LockBits(new Rectangle(0, 0, width, height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            var buffer = new byte[width * height * 4]; // we assume all images have a width of a multiple of 4
            Marshal.Copy(data.Scan0, buffer, 0, buffer.Length);
            bitmap.UnlockBits(data);
            return buffer;
        }
    }
}
