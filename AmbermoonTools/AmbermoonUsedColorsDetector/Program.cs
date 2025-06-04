using Ambermoon.Data;
using Ambermoon.Data.Legacy;

namespace AmbermoonUsedColorsDetector
{
	internal class Program
	{
		static void Main(string[] args)
		{
			var mapIndex = uint.Parse(args[0]);

			var gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false);
			gameData.Load(args[1]);

			var map = gameData.MapManager.GetMap(mapIndex);
			var lab = gameData.MapManager.GetLabdataForMap(map);

			var colorIndices = new Dictionary<int, HashSet<uint>>(16);

			void CheckGraphics(IEnumerable<Graphic> graphics, uint offset, Func<int, uint> textureIndexProvider)
			{
				int g = 0;

				foreach (var graphic in graphics)
				{
					for (int i = 0; i < graphic.Data.Length; i++)
					{
						if (!colorIndices.TryGetValue(graphic.Data[i], out var list))
						{
							list = [];
							colorIndices[graphic.Data[i]] = list;
						}

						list.Add(offset + textureIndexProvider(g));
					}

					g++;
				}
			}

			CheckGraphics(lab.WallGraphics, 0, index => lab.Walls[index].TextureIndex);
			CheckGraphics(lab.ObjectGraphics, 1000, index => lab.ObjectInfos[index].TextureIndex);

			foreach (var colorIndex in colorIndices.OrderBy(e => e.Key))
			{
				foreach (var textureIndex in colorIndex.Value)
				{
					Console.WriteLine($"Color {colorIndex.Key:00} (used in {(textureIndex < 1000 ? "wall" : "object")} texture {textureIndex%1000:000})");
				}
			}

			if (colorIndices.Count == 16)
			{
				Console.WriteLine("All colors used.");
			}
			else
			{
				Console.WriteLine("Not all colors used.");

				for (int i = 0; i < 16; i++)
				{
					if (!colorIndices.ContainsKey(i))
					{
						Console.WriteLine($"Color {i:00} not used.");
					}
				}
			}
		}
	}
}
