//! AmbermoonUsedColorsDetector: shows which colors the wall and object textures of a 3D map use (a port of
//! AmbermoonTools/AmbermoonUsedColorsDetector).
//!
//!   AmbermoonUsedColorsDetector <map index> <game data folder>
namespace AmbermoonUsedColorsDetector;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;

int Fail(string message)
{
    Console.WriteLine(message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length < 2)
        return Fail("Usage: AmbermoonUsedColorsDetector <map index> <game data folder>");
    if (ParseUInt(args[0]) is not uint32 mapIndex)
        return Fail("The input string '" + args[0] + "' was not in a correct format.");

    var gameData = GameData.Create(LoadPreference.PreferExtracted, false);
    if (gameData.Load(args[1]) is error loadError)
        return Fail(loadError.Message);

    var created = MapManager.Create(gameData);
    if (created is error managerError)
        return Fail(managerError.Message);
    if (created is not MapManager mapManager)
        return 1;
    var found = mapManager.GetMap(mapIndex);
    if (found is error mapError)
        return Fail(mapError.Message);
    if (found is not Optional<Map> optional)
        return 1;
    if (optional is not Map map)
        return Fail($"There is no map {mapIndex}.");
    var loaded = mapManager.GetLabdataForMap(map);
    if (loaded is error labError)
        return Fail(labError.Message);
    if (loaded is not Labdata lab)
        return 1;

    // the texture indices that use each color (walls as they are, objects plus 1000), in the order they are found
    // (dictionaries as ordered sets, like the HashSet of .NET)
    var colorIndices = Dictionary<int, Dictionary<uint32, bool>>.Create();

    for (var g = 0; g < lab.WallGraphics.Count(); g += 1)
        AddColors(colorIndices, lab.WallGraphics[g], lab.Walls[g].TextureIndex);
    for (var g = 0; g < lab.ObjectGraphics.Count(); g += 1)
        AddColors(colorIndices, lab.ObjectGraphics[g], 1000 + lab.ObjectInfos[g].TextureIndex);

    var colors = colorIndices.Keys();
    var sorted = List<int>.Create();
    foreach (var color in colors)
        sorted.Add(color);
    sorted.Sort();

    foreach (var color in sorted)
    {
        foreach (var textureIndex in colorIndices[color].Keys())
        {
            string kind = textureIndex < 1000 ? "wall" : "object";
            Console.WriteLine($"Color {color.ToString("D2")} (used in {kind} texture {(textureIndex % 1000).ToString("D3")})");
        }
    }

    if (colorIndices.Count() == 16)
        Console.WriteLine("All colors used.");
    else
    {
        Console.WriteLine("Not all colors used.");

        for (var i = 0; i < 16; i += 1)
        {
            if (!colorIndices.ContainsKey(i))
                Console.WriteLine($"Color {i.ToString("D2")} not used.");
        }
    }

    return 0;
}

void AddColors(Dictionary<int, Dictionary<uint32, bool>> colorIndices, Graphic graphic, uint32 textureIndex)
{
    foreach (var pixel in graphic.Data)
    {
        if (colorIndices.TryGet(pixel) is not Dictionary<uint32, bool> set)
        {
            var created = Dictionary<uint32, bool>.Create();
            colorIndices[pixel] = created;
            created[textureIndex] = true;
        }
        else
            set[textureIndex] = true;
    }
}
