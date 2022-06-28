using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Runtime.InteropServices;

namespace AmbermoonMapEditor2D
{
    internal class ImageCache
    {
        readonly Dictionary<uint, Graphic> palettes;
        readonly Dictionary<uint, IDataReader> tilesets;
        static readonly GraphicReader graphicReader = new GraphicReader();
        static readonly GraphicInfo PaletteGraphicInfo = new GraphicInfo
        {
            Alpha = false,
            GraphicFormat = GraphicFormat.XRGB16,
            Width = 32,
            Height = 1
        };
        static readonly GraphicInfo TileGraphicInfo = new GraphicInfo
        {
            Alpha = true,
            GraphicFormat = GraphicFormat.Palette5Bit,
            Width = 16,
            Height = 16
        };

        // First key: Tileset index
        // Second key: Graphic index
        // Third key: Palette index
        Dictionary<uint, Dictionary<uint, Dictionary<uint, Bitmap>>> images = new Dictionary<uint, Dictionary<uint, Dictionary<uint, Bitmap>>>();

        // TODO: Maybe allow adding new palettes later
        public int PaletteCount => palettes.Count;

        public ImageCache(IGameData gameData)
        {
            var icons1 = gameData.Files["1Icon_gfx.amb"];
            var icons2 = gameData.Files["2Icon_gfx.amb"];
            var icons3 = gameData.Files["3Icon_gfx.amb"];
            palettes = gameData.Files["Palettes.amb"].Files.ToDictionary(f => (uint)f.Key, f => ReadPalette(f.Value));
            tilesets = new Dictionary<uint, IDataReader>();

            void AddTilesets(IFileContainer container)
            {
                foreach (var file in container.Files)
                {
                    if (file.Value.Size != 0)
                        tilesets.Add((uint)file.Key, file.Value);
                }
            }

            AddTilesets(icons1);
            AddTilesets(icons2);
            AddTilesets(icons3);
        }

        internal Color GetPaletteColor(uint paletteIndex, uint colorIndex)
        {
            colorIndex %= 32;

            int r = palettes[paletteIndex].Data[colorIndex * 4 + 0];
            int g = palettes[paletteIndex].Data[colorIndex * 4 + 1];
            int b = palettes[paletteIndex].Data[colorIndex * 4 + 2];

            return Color.FromArgb(r, g, b);
        }

        public int GetImageCount(uint tilesetIndex)
        {
            const int sizePerImage = 16 * 16 * 5 / 8;
            return tilesets[tilesetIndex].Size / sizePerImage;
        }

        public Bitmap GetImage(uint tilesetIndex, uint graphicIndex, uint paletteIndex)
        {
            if (!images.TryGetValue(tilesetIndex, out var tileset))
            {
                var image = LoadImage();
                images.Add(tilesetIndex, new Dictionary<uint, Dictionary<uint, Bitmap>>
                {
                    { graphicIndex, new Dictionary<uint, Bitmap> { { paletteIndex, image } } }
                });
                return image;
            }
            else if (!tileset.TryGetValue(graphicIndex, out var graphic))
            {
                var image = LoadImage();
                tileset.Add(graphicIndex, new Dictionary<uint, Bitmap> { { paletteIndex, image } });
                return image;
            }
            else if (!graphic.TryGetValue(paletteIndex, out var image))
            {
                image = LoadImage();
                graphic.Add(paletteIndex, image);
                return image;
            }
            else
            {
                return image;
            }

            Bitmap LoadImage() => this.LoadImage(tilesets[tilesetIndex], graphicIndex, palettes[paletteIndex], true);
        }

        static Graphic ReadPalette(IDataReader dataReader)
        {
            var graphic = new Graphic();
            graphicReader.ReadGraphic(graphic, dataReader, PaletteGraphicInfo);
            return graphic;
        }

        internal Bitmap LoadImage(IDataReader dataReader, uint paletteIndex, GraphicInfo graphicInfo)
        {
            var graphic = new Graphic();
            graphicReader.ReadGraphic(graphic, dataReader, graphicInfo);

            return GraphicToBitmap(graphic, paletteIndex, graphicInfo.Alpha);
        }

        public Bitmap GraphicToBitmap(Graphic graphic, uint paletteIndex, bool alpha)
        {
            var bitmap = new Bitmap(graphic.Width, graphic.Height);
            var imageData = bitmap.LockBits(new Rectangle(0, 0, graphic.Width, graphic.Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            var pixelData = GetPixelData(graphic, palettes[paletteIndex], alpha);
            Marshal.Copy(pixelData, 0, imageData.Scan0, pixelData.Length);
            bitmap.UnlockBits(imageData);

            return bitmap;
        }

        public byte[] GetBitplaneData(uint tilesetIndex, uint graphicIndex)
        {
            var dataReader = tilesets[tilesetIndex];
            const int sizePerImage = 16 * 16 * 5 / 8;
            dataReader.Position = (int)graphicIndex * sizePerImage;
            return dataReader.ReadBytes(sizePerImage);
        }

        Bitmap LoadImage(IDataReader dataReader, uint graphicIndex, Graphic palette, bool alpha)
        {
            const int sizePerImage = 16 * 16 * 5 / 8;
            dataReader.Position = (int)graphicIndex * sizePerImage;
            var graphic = new Graphic();
            graphicReader.ReadGraphic(graphic, dataReader, TileGraphicInfo);

            var bitmap = new Bitmap(16, 16);
            var imageData = bitmap.LockBits(new Rectangle(0, 0, 16, 16), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            var pixelData = GetPixelData(graphic, palette, alpha);
            Marshal.Copy(pixelData, 0, imageData.Scan0, pixelData.Length);
            bitmap.UnlockBits(imageData);

            return bitmap;
        }

        byte[] GetPixelData(Graphic graphic, Graphic palette, bool alpha)
        {
            byte[] pixelData = new byte[graphic.Width * graphic.Height * 4];

            for (int y = 0; y < graphic.Height; ++y)
            {
                for (int x = 0; x < graphic.Width; ++x)
                {
                    int index = x + y * graphic.Width;
                    int dIndex = index << 2;
                    index = graphic.Data[index] << 2;

                    if (alpha && index == 0)
                    {
                        pixelData[dIndex + 0] = 0;
                        pixelData[dIndex + 1] = 0;
                        pixelData[dIndex + 2] = 0;
                        pixelData[dIndex + 3] = 0;
                    }
                    else
                    {
                        pixelData[dIndex + 2] = palette.Data[index];
                        pixelData[dIndex + 1] = palette.Data[index + 1];
                        pixelData[dIndex + 0] = palette.Data[index + 2];
                        pixelData[dIndex + 3] = palette.Data[index + 3];
                    }
                }
            }

            return pixelData;
        }
    }
}
