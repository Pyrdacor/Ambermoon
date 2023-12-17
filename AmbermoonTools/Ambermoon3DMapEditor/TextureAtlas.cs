using OpenTK.Graphics.OpenGL;
using System.Runtime.InteropServices;

namespace Ambermoon3DMapEditor
{
    internal class TextureAtlas : IDisposable
    {
        private readonly int index;
        private bool disposedValue;
        private readonly byte[] data;

        public TextureAtlas(int width, int height, byte[] data)
        {
            index = GL.GenTexture();
            Width = width;
            Height = height;
            this.data = data;

            Bind();

            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureWrapS, (int)TextureWrapMode.Repeat);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureWrapT, (int)TextureWrapMode.Repeat);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, (int)TextureMinFilter.Nearest);
            GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, (int)TextureMagFilter.Nearest);

            GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.Rgba, width, height, 0, PixelFormat.Rgba, PixelType.UnsignedByte, data);
            //GL.GenerateMipmap(GenerateMipmapTarget.Texture2D);

            for (int i = 0; i < width * height; ++i)
            {
                var temp = this.data[i * 4 + 2];
                this.data[i * 4 + 2] = this.data[i * 4 + 0];
                this.data[i * 4 + 0] = temp;
            }
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

        public Bitmap ToBitmap()
        {
            var bitmap = new Bitmap(Width, Height);
            var bitmapData = bitmap.LockBits(new Rectangle(0, 0, Width, Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

            Marshal.Copy(data, 0, bitmapData.Scan0, data.Length);

            bitmap.UnlockBits(bitmapData);

            return bitmap;
        }
    }
}
