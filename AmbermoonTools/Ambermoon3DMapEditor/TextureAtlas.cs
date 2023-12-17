using OpenTK.Graphics.OpenGL;

namespace Ambermoon3DMapEditor
{
    internal class TextureAtlas : IDisposable
    {
        private readonly int index;
        private bool disposedValue;

        public TextureAtlas(int width, int height, byte[] data)
        {
            index = GL.GenTexture();
            Width = width;
            Height = height;

            Bind();

            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureWrapS, (int)TextureWrapMode.Repeat);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureWrapT, (int)TextureWrapMode.Repeat);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, (int)TextureMinFilter.Nearest);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, (int)TextureMagFilter.Nearest);

            GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.Rgba, width, height, 0, PixelFormat.Rgba, PixelType.UnsignedByte, data);
            //GL.GenerateMipmap(GenerateMipmapTarget.Texture2D);
        }

        public int Width { get; }

        public int Height { get; }

        public void Bind()
        {
            GL.BindTexture(TextureTarget.Texture2D, index);
        }

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    GL.DeleteTexture(index);
                }

                disposedValue = true;
            }
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }
}
