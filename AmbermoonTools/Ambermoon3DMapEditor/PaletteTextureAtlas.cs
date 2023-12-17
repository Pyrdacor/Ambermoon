namespace Ambermoon3DMapEditor
{
    internal class PaletteTextureAtlas
    {
        private readonly byte[] data;

        public PaletteTextureAtlas(int width, int height, byte[] data)
        {
            this.data = data;
            Width = width;
            Height = height;
        }

        public int Width { get; }

        public int Height { get; }

        public TextureAtlas ToTextureAtlas(Palette palette, bool transparency)
        {
            var data = new byte[this.data.Length * 4];
            int i = 0;

            foreach (var index in this.data)
            {
                var color = transparency && index == 0 ? Color.Transparent : palette.Colors[index];
                data[i++] = color.R;
                data[i++] = color.G;
                data[i++] = color.B;
                data[i++] = color.A;
            }

            return new TextureAtlas(Width, Height, data);
        }
    }
}
