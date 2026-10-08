//! AmbermoonLabdataExtractor: writes labyrinth data with only the walls and objects that a 3D map uses (a port of
//! AmbermoonTools/AmbermoonLabdataExtractor).
//!
//!   AmbermoonLabdataExtractor <labdata file> <map file> <new labdata file>
namespace AmbermoonLabdataExtractor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;

int Fail(string message)
{
    Console.WriteLine(message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length < 3)
        return Fail("Usage: AmbermoonLabdataExtractor <labdata file> <map file> <new labdata file>");

    if (File.ReadAllBytes(args[0]) is not uint8[] labdataBytes)
        return Fail($"Could not find file '{Path.GetFullPath(args[0])}'.");
    var labdataReader = DataReader.FromData(labdataBytes);
    var labdata = LabdataReader.ReadLabdataWithoutGraphics(ref labdataReader);

    if (File.ReadAllBytes(args[1]) is not uint8[] mapBytes)
        return Fail($"Could not find file '{Path.GetFullPath(args[1])}'.");
    var mapReader = DataReader.FromData(mapBytes);
    var header = Map.Create(0);

    if (MapReader.ReadMapHeader(ref header, ref mapReader) is error headerError)
        return Fail(headerError.Message);

    if (header.Type != MapType.Map3D)
    {
        Console.WriteLine("The given map is not a 3D map.");
        Console.WriteLine();
        return 0;
    }

    var read = MapReader.ReadMap(0, ref mapReader, null);
    if (read is error mapError)
        return Fail(mapError.Message);
    if (read is not Map map)
        return 1;

    var walls = HashSet<uint32>.Create();
    var objects = HashSet<uint32>.Create();

    foreach (var block in map.Blocks)
    {
        if (block.WallIndex != 0)
            walls.Add(block.WallIndex);
        if (block.ObjectIndex != 0)
            objects.Add(block.ObjectIndex);
    }

    foreach (var entry in map.CharacterReferences)
    {
        if (entry is CharacterReference character)
            objects.Add(character.GraphicIndex);
    }

    var newWalls = List<WallData>.Create();
    for (var i = 0; i < labdata.Walls.Count(); i += 1)
    {
        if (walls.Contains(1 + (uint32)i))
            newWalls.Add(labdata.Walls[i]);
    }

    var newObjects = List<LabdataObject>.Create();
    for (var i = 0; i < labdata.Objects.Count(); i += 1)
    {
        if (objects.Contains(1 + (uint32)i))
            newObjects.Add(labdata.Objects[i]);
    }

    labdata.Walls = newWalls;
    labdata.Objects = newObjects;

    var writer = new DataWriter();
    LabdataReader.WriteLabdata(labdata, ref writer);

    if (File.WriteAllBytes(args[2], writer.AsSlice()) is error)
        return Fail($"Could not write file '{args[2]}'.");
    return 0;
}
