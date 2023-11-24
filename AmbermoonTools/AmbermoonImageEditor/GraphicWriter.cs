using Ambermoon.Data;
using Ambermoon.Data.Serialization;

namespace AmbermoonImageEditor
{
    public class GraphicWriter
    {
        private static void WriteIndexed(IDataWriter writer, Graphic graphic, int bpp, int paletteOffset = 0, int? bytesPerRow = null)
        {
            if (!graphic.IndexedGraphic)
                throw new InvalidOperationException($"Only indexed graphics can be stored in {bpp}BPP format.");

            if (graphic.Width == 0 || graphic.Height == 0)
                return;

            int maxValue = (1 << bpp) - 1;
            var planes = new List<byte>[bpp];
            for (int i = 0;  i < bpp; i++)
                planes[i] = new();
            int bit = 0;

            void SetBit(int plane)
            {
                var p = planes[plane];
                int bitIndex = bit % 8;

                if (bitIndex == 0)
                    p.Add(0x80);
                else
                    p[^1] |= (byte)(1 << (7 - bitIndex));
            }

            void SkipBit(int plane)
            {
                if (bit % 8 == 0)
                    planes[plane].Add(0);
            }

            for (int j = 0; j < graphic.Data.Length; ++j)
            {
                if (j % graphic.Width == 0 && bit % 8 != 0)
                {
                    bit += 8 - bit % 8;
                }

                var index = graphic.Data[j];

                int realIndex = index - paletteOffset;

                if (realIndex < 0 || realIndex > maxValue)
                    throw new ArgumentOutOfRangeException($"Graphic data contains an index which is out of range for {bpp} bit images.");

                for (int i = 0; i < bpp; ++i)
                {
                    if ((realIndex & (1 << i)) != 0)
                        SetBit(i);
                    else
                        SkipBit(i);
                }

                ++bit;
            }

            int scanLine = (graphic.Width + 7) / 8;
            bytesPerRow ??= scanLine;
            int rows = graphic.Height * scanLine / bytesPerRow.Value;

            for (int r = 0; r < rows; ++r)
            {
                int index = r * bytesPerRow.Value;

                for (int p = 0; p < bpp; ++p)
                {
                    for (int i = 0; i < bytesPerRow; ++i)
                    {
                        writer.Write(planes[p][index + i]);
                    }
                }
            }
        }

        public static void Write(IDataWriter writer, Graphic graphic, GraphicFormat graphicFormat, int paletteOffset = 0, int frames = 1)
        {
            void EnsureCorrectDataSize(int bytesPerPixel)
            {
                int expectedSize = graphic.Width * graphic.Height * bytesPerPixel;

                if (expectedSize != graphic.Data.Length)
                    throw new InvalidDataException("Given graphic data size mismatches the expected size.");
            }

            if (frames > 1)
            {
                int widthPerFrame = graphic.Width / frames;

                if (widthPerFrame == 0)
                    throw new ArgumentOutOfRangeException(nameof(frames));

                for (int i = 0; i < frames; ++i)
                {
                    Write(writer, graphic.GetArea(i * widthPerFrame, 0, widthPerFrame, graphic.Height), graphicFormat, paletteOffset);
                }

                return;
            }

            switch (graphicFormat)
            {
                case GraphicFormat.Palette3Bit:
                    EnsureCorrectDataSize(1);
                    WriteIndexed(writer, graphic, 3, paletteOffset);
                    break;
                case GraphicFormat.Palette4Bit:
                    EnsureCorrectDataSize(1);
                    WriteIndexed(writer, graphic, 4, paletteOffset);
                    break;
                case GraphicFormat.Palette5Bit:
                    EnsureCorrectDataSize(1);
                    WriteIndexed(writer, graphic, 5, paletteOffset);
                    break;
                case GraphicFormat.Texture4Bit:
                    EnsureCorrectDataSize(1);
                    WriteIndexed(writer, graphic, 4, paletteOffset, 1);
                    break;
                case GraphicFormat.RGBA32:
                    EnsureCorrectDataSize(4);
                    if (graphic.IndexedGraphic)
                        throw new InvalidOperationException($"Indexed graphics can not be stored in RGBA32 format.");
                    writer.Write(graphic.Data);
                    break;
                case GraphicFormat.XRGB16:
                {
                    if (graphic.IndexedGraphic)
                        throw new InvalidOperationException($"Indexed graphics can not be stored in XRGB16 format.");

                    int size16 = graphic.Width * graphic.Height * 2;
                    int size32 = size16 * 2;

                    if (size16 == graphic.Data.Length)
                    {
                        // Already in right format
                        writer.Write(graphic.Data);
                    }
                    else if (size32 == graphic.Data.Length)
                    {
                        // RGBA32 -> XRGB16
                        for (int i = 0; i < graphic.Data.Length / 4; ++i)
                        {
                            int index = i * 4;
                            int r = graphic.Data[index + 0] >> 4;
                            int g = graphic.Data[index + 1] & 0xf0;
                            int b = graphic.Data[index + 2] >> 4;
                            // we omit alpha
                            writer.Write((byte)r);
                            writer.Write((byte)(g | b));
                        }
                    }
                    else
                    {
                        throw new InvalidDataException("Given graphic data size mismatches the expected size.");
                    }
                    break;
                }
            }
        }
    }
}
