using System.Drawing;

namespace AmbermoonPaletteChanger
{
	internal class Program
	{
        // Args:
        // - [0] Image file path
        // - [1] Palette file path
        // - [2] Number of colors in the palette
        // - [3] Output file path
        static void Main(string[] args)
		{
			var image = (Bitmap)Bitmap.FromFile(args[0]);
			var palette = File.ReadAllBytes(args[1]);
			int numColors = int.Parse(args[2]);
			var outFileName = args[3];

			var paletteColors = new Color[numColors];

			paletteColors[0] = Color.Transparent;

			for (int i = 1; i < numColors; i++)
			{
				var r = palette[i * 2] & 0xf;
				var gb = palette[i * 2 + 1];
				var g = gb >> 4;
				var b = gb & 0xf;
				r |= (byte)(r << 4);
				g |= (byte)(g << 4);
				b |= (byte)(b << 4);
				paletteColors[i] = Color.FromArgb(255, r, g, b);
			}

			for (int y = 0; y < image.Height; y++)
			{
				for (int x = 0; x < image.Width; x++)
				{
					var color = image.GetPixel(x, y);
					image.SetPixel(x, y, FindBestColor(color, paletteColors));
				}
			}

			image.Save(outFileName);
		}

		static readonly Dictionary<int, Color> matchedColors = [];

		static Color FindBestColor(Color targetColor, Color[] paletteColors)
		{
			if (matchedColors.TryGetValue(targetColor.ToArgb(), out var matchedColor))
				return matchedColor;

			var targetLab = RgbToLab(targetColor);

			Color closestColor = paletteColors[0];
			double smallestDistance = GetColorDistance(targetColor, paletteColors[0]);//DeltaE(targetLab, RgbToLab(paletteColors[0]));

			// Iterate through the palette to find the closest color
			foreach (var color in paletteColors)
			{
				double distance = GetColorDistance(targetColor, color);//DeltaE(targetLab, RgbToLab(color));
				if (distance < smallestDistance)
				{
					smallestDistance = distance;
					closestColor = color;
				}
			}

			matchedColors.Add(targetColor.ToArgb(), closestColor);

			return closestColor;
		}

		private static double GetColorDistance(Color color1, Color color2)
		{
			// Calculate the Euclidean distance between two RGB colors
			double rDifference = color1.R - color2.R;
			double gDifference = color1.G - color2.G;
			double bDifference = color1.B - color2.B;

			return Math.Sqrt(rDifference * rDifference + gDifference * gDifference + bDifference * bDifference);
		}

		private static (double L, double a, double b) RgbToLab(Color color)
		{
			var (x, y, z) = RgbToXyz(color);
			return XyzToLab(x, y, z);
		}

		private static (double x, double y, double z) RgbToXyz(Color color)
		{
			// Normalize the RGB values to the range [0, 1]
			double r = color.R / 255.0;
			double g = color.G / 255.0;
			double b = color.B / 255.0;

			// Convert to a gamma-corrected linear RGB value
			r = r > 0.04045 ? Math.Pow((r + 0.055) / 1.055, 2.4) : r / 12.92;
			g = g > 0.04045 ? Math.Pow((g + 0.055) / 1.055, 2.4) : g / 12.92;
			b = b > 0.04045 ? Math.Pow((b + 0.055) / 1.055, 2.4) : b / 12.92;

			// Convert RGB to XYZ using the D65 illuminant (sRGB color space)
			double x = r * 0.4124 + g * 0.3576 + b * 0.1805;
			double y = r * 0.2126 + g * 0.7152 + b * 0.0722;
			double z = r * 0.0193 + g * 0.1192 + b * 0.9505;

			// Multiply by 100 to adjust for the XYZ space scale
			return (x * 100, y * 100, z * 100);
		}

		private static (double L, double a, double b) XyzToLab(double x, double y, double z)
		{
			// Reference white (D65 illuminant)
			double refX = 95.047;
			double refY = 100.000;
			double refZ = 108.883;

			x /= refX;
			y /= refY;
			z /= refZ;

			x = x > 0.008856 ? Math.Pow(x, 1.0 / 3.0) : (7.787 * x) + (16.0 / 116.0);
			y = y > 0.008856 ? Math.Pow(y, 1.0 / 3.0) : (7.787 * y) + (16.0 / 116.0);
			z = z > 0.008856 ? Math.Pow(z, 1.0 / 3.0) : (7.787 * z) + (16.0 / 116.0);

			double l = (116 * y) - 16;
			double a = 500 * (x - y);
			double b = 200 * (y - z);

			return (l, a, b);
		}

		private static double DeltaE((double L, double a, double b) lab1, (double L, double a, double b) lab2)
		{
			double deltaL = lab1.L - lab2.L;
			double deltaA = lab1.a - lab2.a;
			double deltaB = lab1.b - lab2.b;

			return Math.Sqrt(deltaL * deltaL + deltaA * deltaA + deltaB * deltaB);
		}
	}
}
