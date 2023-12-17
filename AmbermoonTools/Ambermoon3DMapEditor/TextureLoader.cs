using Ambermoon.Data;

namespace Ambermoon3DMapEditor
{
    internal static class TextureLoader
    {
        public static List<Texture> Load(List<Graphic> graphics, out PaletteTextureAtlas textureAtlas)
        {
            int maxAtlasWidth = Math.Max(320, graphics.Max(g => g.Width));
            int atlasWidth = 0;
            int atlasHeight = 0;
            int atlasX = 0;
            int atlasY = 0;
            var textures = new List<KeyValuePair<Texture, Graphic>>();
            var emptyRects = new List<Rectangle>();

            void AddTexture(int x, int y, Graphic graphic) => textures.Add(KeyValuePair.Create(new Texture(x, y, graphic.Width, graphic.Height), graphic));

            bool TryUseEmptyRect(Graphic graphic)
            {
                for (int i = emptyRects.Count - 1; i >= 0; i--)
                {
                    var emptyRect = emptyRects[i];

                    if (emptyRect.Width >= graphic.Width && emptyRect.Height >= graphic.Height)
                    {
                        AddTexture(emptyRect.X, emptyRect.Y, graphic);

                        emptyRects.RemoveAt(i);
                        
                        int wDiff = emptyRect.Width - graphic.Width;
                        int hDiff = emptyRect.Height - graphic.Height;

                        if (wDiff > 0 ||  hDiff > 0)
                        {
                            if (wDiff > hDiff)
                            {
                                emptyRects.Add(new Rectangle(emptyRect.X + graphic.Width, emptyRect.Y, wDiff, emptyRect.Height));

                                if (hDiff > 0)
                                    emptyRects.Add(new Rectangle(emptyRect.X, emptyRect.Y + graphic.Height, graphic.Width, hDiff));
                            }
                            else
                            {
                                emptyRects.Add(new Rectangle(emptyRect.X, emptyRect.Y + graphic.Height, emptyRect.Width, hDiff));

                                if (wDiff > 0)
                                    emptyRects.Add(new Rectangle(emptyRect.X + graphic.Width, emptyRect.Y, wDiff, graphic.Height));
                            }

                            emptyRects.Sort((a, b) => (b.Height * 1000 + b.Width).CompareTo(a.Height * 1000 + a.Width));
                        }

                        return true;
                    }
                }

                return false;
            }

            var sortedGraphics = new List<Graphic>(graphics);
            sortedGraphics.Sort((a, b) => (b.Height * 1000 + b.Width).CompareTo(a.Height * 1000 + a.Width));

            foreach (var graphic in sortedGraphics)
            {
                if (atlasWidth == 0)
                {
                    atlasWidth = graphic.Width;
                    atlasHeight = graphic.Height;
                    atlasX = atlasWidth;
                    AddTexture(0, 0, graphic);
                    continue;
                }

                if (TryUseEmptyRect(graphic))
                    continue;

                if (atlasX + graphic.Width > maxAtlasWidth)
                {
                    if (atlasX < atlasWidth)
                    {
                        emptyRects.Add(new Rectangle(atlasX, atlasY, atlasWidth - atlasX, atlasHeight - atlasY));
                        emptyRects.Sort((a, b) => (b.Height * 1000 + b.Width).CompareTo(a.Height * 1000 + a.Width));
                    }
                    AddTexture(0, atlasHeight, graphic);
                    atlasX = graphic.Width;
                    atlasY = atlasHeight;
                    atlasHeight += graphic.Height;
                }
                else
                {
                    AddTexture(atlasX, atlasY, graphic);
                    atlasX += graphic.Width;
                    if (atlasX > atlasWidth)
                    {
                        if (atlasY > 0)
                        {
                            emptyRects.Add(new Rectangle(atlasWidth, 0, atlasX - atlasWidth, atlasY));
                            emptyRects.Sort((a, b) => (b.Height * 1000 + b.Width).CompareTo(a.Height * 1000 + a.Width));
                        }
                        atlasWidth = atlasX;
                    }
                }
            }

            textures = textures.OrderBy(t => graphics.IndexOf(t.Value)).ToList();

            textureAtlas = BuildAtlas(atlasWidth, atlasHeight, textures);

            return textures.Select(t => t.Key).ToList();
        }

        private static PaletteTextureAtlas BuildAtlas(int width, int height, List<KeyValuePair<Texture, Graphic>> textures)
        {
            var data = new byte[width * height];

            foreach (var texture in textures)
            {
                for (int y = 0; y < texture.Key.Height; y++)
                {
                    int index = (texture.Key.AtlasY + y) * width + texture.Key.AtlasX;
                    int gIndex = y * texture.Value.Width;

                    for (int x = 0; x < texture.Key.Width; x++)
                    {
                        data[index++] = texture.Value.Data[gIndex++];
                    }
                }
            }

            return new PaletteTextureAtlas(width, height, data);
        }
    }
}
