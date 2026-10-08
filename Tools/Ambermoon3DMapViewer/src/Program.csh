//! Ambermoon3DMapViewer: shows a 3D map as text and information about its blocks (a port of
//! AmbermoonTools/Ambermoon3DMapViewer).
//!
//!   Ambermoon3DMapViewer <map file> <game data folder>
namespace Ambermoon3DMapViewer;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

int Fail(string message)
{
    Console.WriteLine(message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length < 2)
        return Fail("Usage: Ambermoon3DMapViewer <map file> <game data folder>");

    if (File.ReadAllBytes(args[0]) is not uint8[] mapData)
        return Fail($"Could not find file '{Path.GetFullPath(args[0])}'.");
    var reader = DataReader.FromData(mapData);
    // (the original reads a 2D map without a tileset, which fails)
    if (MapReader.ReadMap(0, ref reader, null) is not Map map)
    {
        Console.WriteLine("Error loading map. Maybe it is no 3D map?");
        Console.WriteLine();
        return 1;
    }

    var gameData = GameData.Create(LoadPreference.PreferExtracted, false);
    if (gameData.Load(args[1]) is error loadError)
        return Fail(loadError.Message);
    var created = MapManager.Create(gameData);
    if (created is error managerError)
        return Fail(managerError.Message);
    if (created is not MapManager mapManager)
        return 1;
    var loaded = mapManager.GetLabdataForMap(map);
    if (loaded is error labError)
        return Fail(labError.Message);
    if (loaded is not Labdata labdata)
        return 1;

    ShowMap(map, labdata);
    ProcessMap(map, labdata);
    return 0;
}

char PrintFromAutomapType(AutomapType type)
{
    switch (type)
    {
        case AutomapType.Chest:
        case AutomapType.ChestOpened:
        case AutomapType.Pile:
            return '=';
        case AutomapType.Door:
        case AutomapType.DoorOpen:
        case AutomapType.Tavern:
        case AutomapType.Merchant:
            return 'O';
        case AutomapType.Exit:
            return 'X';
        case AutomapType.GotoPoint:
            return '*';
        case AutomapType.Riddlemouth:
            return 'R';
        case AutomapType.Special:
            return '!';
        case AutomapType.Spinner:
            return '+';
        case AutomapType.Trap:
            return 'x';
        case AutomapType.Trapdoor:
            return 'o';
        case AutomapType.Wall:
            return '#';
        case AutomapType.Teleporter:
            return '%';
        default:
            return ' ';
    }
}

// the automap type of the event of a block (None if it has none)
AutomapType EventAutomapType(Map map, MapBlock block)
{
    if (block.MapEventId == 0 || (int)block.MapEventId > map.EventAutomapTypes.Count())
        return AutomapType.None;
    return map.EventAutomapTypes[(int)block.MapEventId - 1];
}

void ShowMap(Map map, Labdata labdata)
{
    var header = StringBuilder.Create();
    header.Append("   ");
    for (var i = 0; i < map.Width; i += 1)
        header.Append((i % 10).ToString());
    Console.WriteLine(header.ToString());
    Console.WriteLine();

    for (var y = 0; y < map.Height; y += 1)
    {
        var line = StringBuilder.Create();
        line.Append((y % 10).ToString());
        line.Append("  ");

        for (var x = 0; x < map.Width; x += 1)
        {
            var block = map.Block(x, y);
            char print = ' ';

            if (block.MapBorder)
                print = '*';
            else if (block.ObjectIndex != 0)
            {
                var type = EventAutomapType(map, block);
                var objectType = (int)block.ObjectIndex <= labdata.Objects.Count() ? labdata.Objects[(int)block.ObjectIndex - 1].AutomapType : AutomapType.None;
                if (type != AutomapType.None)
                    print = PrintFromAutomapType(type);
                else if (objectType == AutomapType.None)
                    print = '.';
                else
                    print = PrintFromAutomapType(objectType);
            }
            else if (block.WallIndex != 0)
            {
                var type = EventAutomapType(map, block);
                var wallType = (int)block.WallIndex <= labdata.Walls.Count() ? labdata.Walls[(int)block.WallIndex - 1].AutomapType : AutomapType.None;
                if (type != AutomapType.None)
                    print = PrintFromAutomapType(type);
                else if (wallType == AutomapType.None)
                    print = '#';
                else
                    print = PrintFromAutomapType(wallType);
            }

            line.Append(print);
        }

        line.Append("  ");
        line.Append((y % 10).ToString());
        Console.WriteLine(line.ToString());
    }

    Console.WriteLine();
    Console.WriteLine(header.ToString());
    Console.WriteLine();
}

// a number of the input; the original ends with an exception for anything else and at the end of the input, this asks
// again and ends the program at the end of the input
int ReadNumber(string prompt)
{
    while (true)
    {
        Console.Write(prompt);
        if (Console.ReadLine() is not string line)
        {
            Console.WriteLine();
            Environment.Exit(0);
            return 0;
        }
        if (ParseInt(line) is int number)
            return number;
        Console.WriteLine(" -> Invalid number.");
    }
}

void ProcessMap(Map map, Labdata labdata)
{
    while (true)
    {
        Console.WriteLine("Show info for which block?");
        int x = ReadNumber("X: ");
        int y = ReadNumber("Y: ");

        if (x < 0 || y < 0 || x >= map.Width || y >= map.Height)
        {
            Console.WriteLine(" -> The block is outside of the map.");
            Console.WriteLine();
            continue;
        }

        var block = map.Block(x, y);

        if (block.MapBorder)
            Console.WriteLine("Map border");
        else if (block.WallIndex != 0 && (int)block.WallIndex <= labdata.Walls.Count())
        {
            Console.WriteLine($"Wall {block.WallIndex}");
            var wall = labdata.Walls[(int)block.WallIndex - 1];
            Console.WriteLine($" Texture Index: {wall.TextureIndex}");
            Console.WriteLine($" Automap Type: {EnumText(wall.AutomapType, false)}");
            Console.WriteLine($" Flags: {((uint32)wall.Flags).ToString("x8")}");
            if (wall.Overlays != null && wall.Overlays.Length != 0)
            {
                Console.WriteLine($" {wall.Overlays.Length} overlay(s)");
                foreach (var overlay in wall.Overlays)
                    Console.WriteLine($"  Texture Index: {overlay.TextureIndex}");
            }
        }
        else if (block.ObjectIndex != 0 && (int)block.ObjectIndex <= labdata.Objects.Count())
        {
            Console.WriteLine($"Object {block.ObjectIndex}");
            var obj = labdata.Objects[(int)block.ObjectIndex - 1];
            Console.WriteLine($" Automap Type: {EnumText(obj.AutomapType, false)}");
        }
        else
            Console.WriteLine("Empty block");

        Console.WriteLine();
    }
}
