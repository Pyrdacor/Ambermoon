namespace Ambermoon3DMapEditor
{
    internal class Texture
    {
        public Texture(int atlasX, int atlasY, int width, int height)
        {
            AtlasX = atlasX;
            AtlasY = atlasY;
            Width = width;
            Height = height;
        }

        public int AtlasX { get; }
        public int AtlasY { get; }
        public int Width { get; }
        public int Height { get; }
    }
}
