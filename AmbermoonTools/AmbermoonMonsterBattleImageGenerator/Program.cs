using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.GameDataRepository.Data;
using Ambermoon.Data.Legacy.Serialization;
using System.Drawing;
using System.Runtime.InteropServices;

namespace AmbermoonMonsterBattleImageGenerator
{
	internal class Program
	{
		static string GetOrAskParameter(string[] args, int index, string name)
		{
			if (index < args.Length)
				return args[index];

			Console.Write($"{name}: ");
			return Console.ReadLine()!;
		}

		static void Main(string[] args)
		{
			var monsterFile = GetOrAskParameter(args, 0, "Monster file");
			var paletteFile = GetOrAskParameter(args, 1, "Palette file");
			var graphicsFile = GetOrAskParameter(args, 2, "Graphics file");
			var outputFile = GetOrAskParameter(args, 3, "Output file");

			var monster = (MonsterData)MonsterData.Deserialize(new DataReader(File.ReadAllBytes(monsterFile)), false);

			var graphicData = File.ReadAllBytes(graphicsFile);
			var graphic = new Graphic();
			var graphicInfo = new GraphicInfo
			{
				Width = (int)monster.OriginalFrameWidth,
				Height = (int)monster.OriginalFrameHeight,
				GraphicFormat = GraphicFormat.Palette5Bit,
				Alpha = true
			};
			new GraphicReader().ReadGraphic(graphic, new DataReader(graphicData), graphicInfo);

			using var bitmap = new Bitmap(graphicInfo.Width, graphicInfo.Height);
			var bitmapData = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
			var pixelLine = new byte[bitmap.Width * 4];
			var ptr = bitmapData.Scan0;
			var originalPalette = File.ReadAllBytes(paletteFile);
			var palette = new byte[64];

			for (int i = 0; i < 32; i++)
			{
				int pi = monster.CustomPalette[i];
				palette[i * 2] = originalPalette[pi * 2];
				palette[i * 2 + 1] = originalPalette[pi * 2 + 1];
			}

			int index = 0;

			for (int y = 0; y < bitmap.Height; y++)
			{
				int lineIndex = 0;

				for (int x = 0; x < bitmap.Width; x++)
				{
					var color = graphic.Data[index++];

					if (color == 0)
					{
						pixelLine[lineIndex++] = 0;
						pixelLine[lineIndex++] = 0;
						pixelLine[lineIndex++] = 0;
						pixelLine[lineIndex++] = 0;
					}
					else
					{
						var ar = palette[color * 2];
						var gb = palette[color * 2 + 1];
						var r = ar & 0x0f;
						r |= (r << 4);
						var g = gb & 0xf0;
						g |= (g >> 4);
						var b = gb & 0x0f;
						b |= (b << 4);

						pixelLine[lineIndex++] = (byte)b;
						pixelLine[lineIndex++] = (byte)g;
						pixelLine[lineIndex++] = (byte)r;
						pixelLine[lineIndex++] = 0xff;
					}
				}

				Marshal.Copy(pixelLine, 0, ptr, pixelLine.Length);
				ptr += pixelLine.Length;
			}

			bitmap.UnlockBits(bitmapData);
			bitmap.Save(outputFile, System.Drawing.Imaging.ImageFormat.Png);

			using var palBitmap = new Bitmap(16, 5);
			var palBitmapData = palBitmap.LockBits(new Rectangle(0, 0, palBitmap.Width, palBitmap.Height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

			var palImageData = new byte[80 * 4];

			for (int i = 1; i < 32; i++)
			{
				var ar = originalPalette[i * 2];
				var gb = originalPalette[i * 2 + 1];
				var r = ar & 0x0f;
				r |= (r << 4);
				var g = gb & 0xf0;
				g |= (g >> 4);
				var b = gb & 0x0f;
				b |= (b << 4);

				palImageData[i * 4 + 0] = (byte)b;
				palImageData[i * 4 + 1] = (byte)g;
				palImageData[i * 4 + 2] = (byte)r;
				palImageData[i * 4 + 3] = 0xff;

				ar = palette[i * 2];
				gb = palette[i * 2 + 1];
				r = ar & 0x0f;
				r |= (r << 4);
				g = gb & 0xf0;
				g |= (g >> 4);
				b = gb & 0x0f;
				b |= (b << 4);

				int j = 32 + 16 + i;
				palImageData[j * 4 + 0] = (byte)b;
				palImageData[j * 4 + 1] = (byte)g;
				palImageData[j * 4 + 2] = (byte)r;
				palImageData[j * 4 + 3] = 0xff;
			}

			Marshal.Copy(palImageData, 0, palBitmapData.Scan0, palImageData.Length);

			palBitmap.UnlockBits(palBitmapData);
			palBitmap.Save("palette.png", System.Drawing.Imaging.ImageFormat.Png);
		}
	}
}
