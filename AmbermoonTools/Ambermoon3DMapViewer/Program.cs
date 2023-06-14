using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.IO;

namespace Ambermoon3DMapViewer
{
    class Program
    {
        static void Main(string[] args)
        {
            var mapReader = new MapReader();
            var dataReader = new DataReader(File.ReadAllBytes(args[0]));
            Map map;

            try
            {
                map = Map.Load(0, mapReader, dataReader, null, null);
            }
            catch
            {
                Console.WriteLine("Error loading map. Maybe it is no 3D map?");
                Console.WriteLine();
                Environment.Exit(1);
                return;
            }

            var gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false);
            gameData.Load(args[1]);

            var mapManager = new MapManager(gameData, new MapReader(), new TilesetReader(), new LabdataReader(), true);

            ProcessMap(map, mapManager.GetLabdataForMap(map));
        }

        static void ShowMap(Map map, Labdata labdata)
        {
            char PrintFromAutomapType(AutomapType automapType)
            {
                switch (automapType)
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

            string header = "   ";
            for (int i = 0; i < map.Width; ++i)
                header += (i % 10).ToString();
            Console.WriteLine(header);
            Console.WriteLine();

            for (int y = 0; y < map.Height; ++y)
            {
                Console.Write(y % 10);
                Console.Write("  ");

                for (int x = 0; x < map.Width; ++x)
                {
                    var block = map.Blocks[x, y];
                    char print;

                    if (block.MapBorder)
                        print = '*';
                    else if (block.ObjectIndex != 0)
                    {
                        var obj = labdata.Objects[(int)block.ObjectIndex - 1];

                        if (block.MapEventId != 0 && map.EventAutomapTypes[(int)block.MapEventId - 1] != AutomapType.None)
                            print = PrintFromAutomapType(map.EventAutomapTypes[(int)block.MapEventId - 1]);
                        else if (obj.AutomapType == AutomapType.None)
                            print = '.';
                        else
                            print = PrintFromAutomapType(obj.AutomapType);
                    }
                    else if (block.WallIndex != 0)
                    {
                        var wall = labdata.Walls[(int)block.WallIndex - 1];

                        if (block.MapEventId != 0 && map.EventAutomapTypes[(int)block.MapEventId - 1] != AutomapType.None)
                            print = PrintFromAutomapType(map.EventAutomapTypes[(int)block.MapEventId - 1]);
                        else if (wall.AutomapType == AutomapType.None)
                            print = '#';
                        else
                            print = PrintFromAutomapType(wall.AutomapType);
                    }
                    else
                        print = ' ';

                    Console.Write(print);
                }

                Console.Write("  ");
                Console.Write(y % 10);

                Console.WriteLine();
            }

            Console.WriteLine();
            Console.WriteLine(header);
            Console.WriteLine();
        }

        static void ProcessMap(Map map, Labdata labdata)
        {
            ShowMap(map, labdata);

            while (true)
            {
                Console.WriteLine("Show info for which block?");
                Console.Write("X: ");
                int x = int.Parse(Console.ReadLine());
                Console.Write("Y: ");
                int y = int.Parse(Console.ReadLine());

                var block = map.Blocks[x, y];

                if (block.MapBorder)
                    Console.WriteLine("Map border");
                else if (block.WallIndex != 0)
                {
                    Console.WriteLine($"Wall {block.WallIndex}");
                    var wall = labdata.Walls[(int)block.WallIndex - 1];
                    Console.WriteLine($" Texture Index: {wall.TextureIndex}");
                    Console.WriteLine($" Automap Type: {wall.AutomapType}");
                    Console.WriteLine($" Flags: {(uint)wall.Flags:x8}");
                    if (wall.Overlays != null && wall.Overlays.Length != 0)
                    {
                        Console.WriteLine($" {wall.Overlays.Length} overlay(s)");
                        foreach (var overlay in wall.Overlays)
                        {
                            Console.WriteLine($"  Texture Index: {overlay.TextureIndex}");
                        }
                    }
                }
                else if (block.ObjectIndex != 0)
                {
                    // TODO
                    Console.WriteLine($"Object {block.ObjectIndex}");
                    var obj = labdata.Objects[(int)block.ObjectIndex - 1];
                    Console.WriteLine($" Automap Type: {obj.AutomapType}");
                }
                else
                    Console.WriteLine("Empty block");

                Console.WriteLine();
            }
        }
    }
}
