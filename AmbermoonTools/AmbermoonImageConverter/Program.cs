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
        static void Usage()
        {
            Console.WriteLine("USAGE: AmbermoonImageConverter <imageFile> <paletteFile> <outFile> <format> [frames] [palOffset] [tindex] [findex]");
            Console.WriteLine("       AmbermoonImageConverter --help");
            Console.WriteLine();
            Console.WriteLine("Creates an image data file from a graphic and a palette. This file can then be used in Ambermoon.");
            Console.WriteLine();
            Console.WriteLine("<imageFile>   Image file (PNG, BMP, etc)");
            Console.WriteLine("<paletteFile> Palette data file from the original game data");
            Console.WriteLine("<outFile>     Path where the output file should be created");
            Console.WriteLine("<format>      3: 3 bit planes (mostly UI graphics)");
            Console.WriteLine("              4: 4 bit planes (floors, lab background, intro, etc)");
            Console.WriteLine("              5: 5 bit planes (items, monsters, tile graphics, etc)");
            Console.WriteLine("              0: 4 bit 3D textures (walls, overlays, objects)");
            Console.WriteLine("[frames]      Number of frames (default: 1)");
            Console.WriteLine("[palOffset]   Palette offset (default: 0)");
            Console.WriteLine("              Based on <format> this is limited to 0 (5 bpp), 16 (4 bpp) or 24 (3 bpp).");
            Console.WriteLine("[tindex]      Transparent color index (default: 0)");
            Console.WriteLine("[findex]      Forbidden color index (default: 32)");
            Console.WriteLine();
            Console.WriteLine("Note: The provided palette must be a decompressed/extracted single file like Palettes/001.");
            Console.WriteLine("      Do not pass the whole container Palettes.amb here!");
            Console.WriteLine("Note: The tool tries to use similar palette indices if the given image contains colors which");
            Console.WriteLine("      are not part of the given palette. However this has its limits. The tool will error if");
            Console.WriteLine("      the color is too far away from every palette color.");
            Console.WriteLine();
        }

        // args[0]: Image
        // args[1]: Palette file
        // args[2]: Output image
        // args[3]: Format (5: 5bit, 4: 4bit, 3: 3bit, 0: 4bit texture)
        // args[4]: Frames (default 1)
        // args[5]: Palette index offset (default: 0)
        // args[6]: Transparent color index (default: 0)
        static void Main(string[] args)
        {
            if (args.Contains("--help"))
            {
                Usage();
                return;
            }

            if (args.Length < 4 || args.Length > 8)
            {
                Console.WriteLine("Invalid number of arguments.");
                Console.WriteLine();
                Usage();
                return;
            }

            // TODO: Later add both ways of conversion and support 3, 4 and 5 bit images as well as palettes.

            byte[] imageData;
            int width;
            int height;

            try
            {
                imageData = LoadImageData(args[0], out width, out height);
            }
            catch
            {
                Console.WriteLine("Failed to read image file.");
                Console.WriteLine();
                Usage();
                return;
            }

            uint[] palette;

            try
            {
                palette = LoadPalette(args[1]);
            }
            catch
            {
                Console.WriteLine("Failed to read palette file.");
                Console.WriteLine();
                Usage();
                return;
            }

            var palIndices = new byte[imageData.Length / 4];
            
            if (!int.TryParse(args[3], out int format))
            {
                Console.WriteLine("Invalid format given.");
                Console.WriteLine();
                Usage();
                return;
            }

            int bpp = format;

            if (bpp == 0)
                bpp = 4;
            else if (bpp < 3 || bpp > 5)
            {
                Console.WriteLine("Invalid format given.");
                Console.WriteLine();
                Usage();
                return;
            }

            int frames = args.Length < 5 ? 1 : int.Parse(args[4]);
            int paletteIndexOffset = args.Length < 6 ? 0 : Math.Max(0, int.Parse(args[5]));
            int transparentColorIndex = args.Length < 7 ? 0 : Math.Max(0, int.Parse(args[6]));
            int forbiddenColorIndex = args.Length < 8 ? 32 : Math.Max(0, int.Parse(args[7]));
            if (bpp == 5)
                paletteIndexOffset = 0;
            else if (bpp == 4)
                paletteIndexOffset = Math.Min(16, paletteIndexOffset);
            else
                paletteIndexOffset = Math.Min(24, paletteIndexOffset);
            byte minIndex = (byte)paletteIndexOffset;
            byte maxIndex = (byte)((1 << bpp) - 1 + paletteIndexOffset);

            if (frames == 0)
            {
                Console.WriteLine("Frames must not be 0.");
                Console.WriteLine();
                Usage();
                return;
            }

            if (width == 0 || height == 0)
            {
                Console.WriteLine("Image dimensions are invalid.");
                Console.WriteLine();
                return;
            }

            for (int i = 0; i < palIndices.Length; ++i)
            {
                palIndices[i] = FindPaletteIndex(palette, BitConverter.ToUInt32(imageData, i * 4), minIndex, maxIndex, (byte)transparentColorIndex, (byte)forbiddenColorIndex);
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

            try
            {
                File.WriteAllBytes(args[2], outputData);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to write output file.");
                Console.WriteLine("  " + ex.Message);

                while (ex.InnerException != null)
                {
                    Console.WriteLine(ex.InnerException.Message);
                    ex = ex.InnerException;
                }

                Console.WriteLine();
            }
        }

        static readonly Dictionary<uint, byte> mappedPaletteIndices = new();

        static byte FindPaletteIndex(uint[] palette, uint color, byte min, byte max, byte transparentColorIndex, byte forbiddenColorIndex)
        {
            if (mappedPaletteIndices.TryGetValue(color, out var index))
                return index;

            max = Math.Min(max, (byte)31);

            if ((color >> 24) == transparentColorIndex && transparentColorIndex != forbiddenColorIndex) // transparent
                return transparentColorIndex;

            uint r = (color >> 16) & 0xf0;
            uint g = (color >> 8) & 0xf0;
            uint b = color & 0xf0;

            color = 0xff000000 | (r << 16) | (r << 12) | (g << 8) | (g << 4) | b | (b >> 4);

            if (mappedPaletteIndices.TryGetValue(color, out index))
                return index;

            var diffs = new SortedDictionary<int, int>();

            for (int i = min; i <= max; ++i)
            {
                if (i == forbiddenColorIndex)
                    continue;

                if (palette[i] == color)
                {
                    if (mappedPaletteIndices.TryAdd(color, (byte)i))
                        return (byte)i;
                    else
                        return mappedPaletteIndices[color];
                }

                var diffA = Math.Abs((int)(color >> 24) - (int)(palette[i] >> 24));
                var diffR = Math.Abs((int)((color >> 16) & 0xff) - (int)((palette[i] >> 16) & 0xff));
                var diffG = Math.Abs((int)((color >> 8) & 0xff) - (int)((palette[i] >> 8)& 0xff));
                var diffB = Math.Abs((int)((color & 0xff) - (int)(palette[i] & 0xff)));
                int diff = diffB * diffB + diffG * diffG + diffR * diffR + diffA * diffA;

                if (!diffs.ContainsKey(diff))
                    diffs.Add(diff, i);
            }

            if (diffs.First().Key > 2 * 0x22 * 0x22)
                throw new Exception();
            else
            {
                uint paletteColor = palette[diffs.First().Value];
                Console.WriteLine($"Warning: Color {color >> 24:x2}{r:x2}{g:x2}{b:x2} was changed to palette color {paletteColor >> 24:x2}{(paletteColor >> 16) & 0xff:x2}{(paletteColor >> 8) & 0xff:x2}{paletteColor & 0xff:x2}");
                mappedPaletteIndices.Add(color, (byte)diffs.First().Value);
                return (byte)diffs.First().Value;
            }
        }

        static uint[] LoadPalette(string filename)
        {
            using var stream = File.OpenRead(filename);
            var palette = new uint[32];
            int a = 0xff;

            if (stream.Length != 64)
            {
                using var image = (Bitmap)Image.FromStream(stream);
                var data = image.LockBits(new Rectangle(0, 0, image.Width, image.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
                var buffer = new byte[32 * 4];
                Marshal.Copy(data.Scan0, buffer, 0, 32 * 4);
                image.UnlockBits(data);

                for (int i = 0; i < 32; ++i)
                {                    
                    int r = buffer[i * 4 + 2];
                    int g = buffer[i * 4 + 1];
                    int b = buffer[i * 4 + 0];
                    palette[i] = ((uint)a << 24) | ((uint)r << 16) | ((uint)g << 8) | (uint)b;
                }

                return palette;
            }

            using var binarReader = new BinaryReader(stream);

            for (int i = 0; i < 32; ++i)
            {
                byte ar = binarReader.ReadByte();
                byte gb = binarReader.ReadByte();
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
