namespace Ambermoon.Data.Legacy;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;

/// The maps and tilesets of the game. Maps are read when they are needed (the original reads all maps and the
/// labyrinth data with their graphics when the game data is loaded).
///
/// Map 1-256: 1Map_data.amb; map 300-369: 2Map_data.amb; map 257-299, 400-455, 513-528: 3Map_data.amb.
struct MapManager
{
    GameData GameData;
    Dictionary<uint32, Tileset> Tilesets;
    Dictionary<uint32, Map> _maps;
    Dictionary<uint32, Labdata> _labdata;

    /// The map manager of loaded game data (with its tilesets).
    /// @error Icon_data.amb is missing.
    static Error<MapManager> Create(GameData gameData)
    {
        var tilesets = Dictionary<uint32, Tileset>.Create();
        if (gameData.Files.TryGet("Icon_data.amb") is not FileContainer icons)
            return error("The given key 'Icon_data.amb' was not present in the dictionary.");
        foreach (var number in icons.Numbers())
        {
            var reader = icons.Files[number];
            tilesets[(uint32)number] = TilesetReader.ReadTileset(ref reader, (uint32)number);
        }
        return MapManager
        {
            GameData = gameData,
            Tilesets = tilesets,
            _maps = Dictionary<uint32, Map>.Create(),
            _labdata = Dictionary<uint32, Labdata>.Create()
        };
    }

    /// The map of an index; null if there is no such map.
    /// @error the map is damaged.
    Error<Optional<Map>> GetMap(uint32 index)
    {
        if (_maps.TryGet(index) is Map known)
            return known;

        for (var i = 1; i <= 3; i += 1)
        {
            if (GameData.Files.TryGet($"{i}Map_data.amb") is not FileContainer container)
                continue;
            if (container.Files.TryGet((int)index) is not DataReader reader)
                continue;
            if (reader.Size() == 0)
                continue;

            Optional<Tileset> tileset = null;
            reader.Position = 0;
            // the tileset is the 7th byte of the header (only needed for 2D maps)
            if (reader.Size() > 6 && Tilesets.TryGet(reader[6]) is Tileset found)
                tileset = found;
            var map = try MapReader.ReadMap(index, ref reader, tileset);

            if (GameData.Files.TryGet($"{i}Map_texts.amb") is FileContainer texts && texts.Files.TryGet((int)index) is DataReader textReader)
                MapReader.ReadMapTexts(ref map, textReader);

            _maps[index] = map;
            return map;
        }

        return null;
    }

    /// The indices of all maps, ascending.
    List<uint32> MapIndices()
    {
        var indices = List<uint32>.Create();
        for (var i = 1; i <= 3; i += 1)
        {
            if (GameData.Files.TryGet($"{i}Map_data.amb") is not FileContainer container)
                continue;
            foreach (var number in container.Numbers())
            {
                if (container.Files[number].Size() != 0)
                    indices.Add((uint32)number);
            }
        }
        indices.Sort();
        return indices;
    }

    /// The tileset of a 2D map.
    Optional<Tileset> GetTilesetForMap(Map map)
    {
        return Tilesets.TryGet(map.TilesetOrLabdataIndex);
    }

    /// The labyrinth data of a 3D map, with its graphics (2Lab_data.amb; 3Lab_data.amb contains the same).
    /// @error there is no such labyrinth data or it is damaged.
    Error<Labdata> GetLabdataForMap(Map map)
    {
        uint32 index = map.TilesetOrLabdataIndex;
        if (_labdata.TryGet(index) is Labdata known)
            return known;
        if (GameData.Files.TryGet("2Lab_data.amb") is not FileContainer container)
            return error("The given key '2Lab_data.amb' was not present in the dictionary.");
        if (container.Files.TryGet((int)index) is not DataReader reader)
            return error($"The given key '{index}' was not present in the dictionary.");
        if (reader.Size() == 0)
            return error($"The given key '{index}' was not present in the dictionary.");
        reader.Position = 0;
        var labdata = try LabdataReader.ReadLabdata(ref reader, GameData);
        _labdata[index] = labdata;
        return labdata;
    }
}
