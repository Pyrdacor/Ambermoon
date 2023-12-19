using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;

namespace AmbermoonLabdataExtractor
{
    internal class Program
    {
        static void Main(string[] args)
        {
            // args[0]: Labdata file
            // args[1]: Map file
            // args[2]: New labdata file

            var labdataReader = new LabdataReader();
            var labdata = new Labdata();
            labdataReader.ReadLabdataWithoutGraphics(labdata, new DataReader(File.ReadAllBytes(args[0])));

            var mapDataReader = new DataReader(File.ReadAllBytes(args[1]));
            var map = new Map();

            MapReader.ReadMapHeader(map, mapDataReader);

            if (map.Type != MapType.Map3D)
            {
                Console.WriteLine("The given map is not a 3D map.");
                Console.WriteLine();
                return;
            }

            var mapReader = new MapReader();
            mapDataReader.Position = 0;
            mapReader.ReadMap(map, mapDataReader, new());

            var blocks = map.Blocks.OfType<Map.Block>();

            var walls = new HashSet<uint>(blocks.Select(block => block.WallIndex).Distinct().Where(i => i != 0));
            var objects = new HashSet<uint>(blocks.Select(block => block.ObjectIndex).Distinct().Where(i => i != 0));

            foreach (var character in map.CharacterReferences)
            {
                if (character != null && !objects.Contains(character.GraphicIndex))
                    objects.Add(character.GraphicIndex);
            }

            var newWalls = labdata.Walls.Where((_, index) => walls.Contains(1u + (uint)index)).ToList();
            var newObjects = labdata.Objects.Where((_, index) => objects.Contains(1u + (uint)index)).ToList();

            labdata.Walls.Clear();
            labdata.Objects.Clear();
            labdata.Walls.AddRange(newWalls);
            labdata.Objects.AddRange(newObjects);

            var dataWriter = new DataWriter();
            LabdataWriter.WriteLabdata(labdata, dataWriter);

            File.WriteAllBytes(args[2], dataWriter.ToArray());
        }
    }
}