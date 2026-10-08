namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

/// The goto points of a map and the offset of their number in the data of the map.
struct MapGotoPoints
{
    List<GotoPoint> GotoPoints;
    int Offset;
}

/// Reads the maps of 1Map_data.amb, 2Map_data.amb and 3Map_data.amb.
struct MapReader
{
    /// Reads the header of a map (the first 12 bytes).
    /// @error the map type is neither 2D nor 3D, or the header does not end with 0.
    static Error<void> ReadMapHeader(ref Map map, ref DataReader reader)
    {
        map.Flags = (MapFlags)reader.ReadWord();
        map.Type = (MapType)reader.ReadByte();

        if (map.Type != MapType.Map2D && map.Type != MapType.Map3D)
            return error("Invalid map data.");

        map.MusicIndex = reader.ReadByte();
        map.Width = reader.ReadByte();
        map.Height = reader.ReadByte();
        map.TilesetOrLabdataIndex = reader.ReadByte();

        map.NPCGfxIndex = reader.ReadByte();
        map.LabyrinthBackgroundIndex = reader.ReadByte();
        map.PaletteIndex = reader.ReadByte();
        map.World = (World)reader.ReadByte();

        if (reader.ReadByte() != 0) // end of map header
            return error("[Data] Invalid map data");
        return;
    }

    /// Reads a map; 2D maps need their tileset (for the types of the tiles).
    /// @error the data is damaged.
    static Error<Map> ReadMap(uint32 index, ref DataReader reader, Optional<Tileset> tileset)
    {
        return _ReadMap(index, ref reader, tileset, false);
    }

    /// The goto points of a map (its tiles or blocks are skipped: no tileset is needed) and the offset of their
    /// number (a word) in the data (MapReader.ReadGotoPoints and GetGotoPointOffset of the original).
    /// @error the data is damaged.
    static Error<MapGotoPoints> ReadGotoPoints(ref DataReader reader)
    {
        var map = try _ReadMap(0, ref reader, null, true);
        int automapTypes = map.Type == MapType.Map3D ? map.EventList.Count() : 0;
        int offset = reader.Position - 2 - map.GotoPoints.Count() * 20 - automapTypes;
        return MapGotoPoints { GotoPoints = map.GotoPoints, Offset = offset };
    }

    static Error<Map> _ReadMap(uint32 index, ref DataReader reader, Optional<Tileset> tileset, bool skipTiles)
    {
        var map = Map.Create(index);
        reader.Position = 0;
        try ReadMapHeader(ref map, ref reader);

        // Up to 32 character references (10 bytes each -> total 320 bytes)
        for (var i = 0; i < 32; i += 1)
        {
            var characterIndex = reader.ReadByte();
            var collisionClass = reader.ReadByte();
            var typeAndFlags = reader.ReadByte();
            var eventIndex = reader.ReadByte();
            var gfxIndex = reader.ReadWord();
            var tileFlags = reader.ReadDword();

            // Note: Map 258 has 3 characters but one seems to be not used anymore. To avoid problems all further
            // character references are empty after the first empty one.
            if (characterIndex == 0)
            {
                reader.Position += 10 * (31 - i);
                break;
            }

            map.CharacterReferences[i] = CharacterReference
            {
                Index = characterIndex,
                Type = (CharacterType)(typeAndFlags & 0x03),
                CharacterFlags = (CharacterReferenceFlags)(typeAndFlags >> 2),
                CollisionClass = collisionClass,
                EventIndex = eventIndex,
                GraphicIndex = gfxIndex,
                TileFlags = (TileFlags)tileFlags,
                CombatBackgroundIndex = tileFlags >> 28,
                Positions = List<Position>.Create()
            };
        }

        // the tiles or blocks
        int count = map.Width * map.Height;
        if (skipTiles)
            reader.Position += (map.Type == MapType.Map2D ? 4 : 2) * count;
        else if (map.Type == MapType.Map2D)
        {
            if (tileset is not Tileset tiles)
                return error("Missing tileset of the map.");
            map.Tiles = new MapTile[count];
            for (var i = 0; i < count; i += 1)
            {
                var backTileIndex = reader.ReadByte();
                var mapEventId = reader.ReadByte();
                var frontTileIndex = reader.ReadWord();
                var tile = MapTile { BackTileIndex = backTileIndex, FrontTileIndex = frontTileIndex, MapEventId = mapEventId };
                tile.Type = Map.TileTypeFromTile(tile, tiles);
                map.Tiles[i] = tile;
            }
        }
        else
        {
            map.Blocks = new MapBlock[count];
            for (var i = 0; i < count; i += 1)
            {
                var blockDataIndex = reader.ReadByte();
                var mapEventId = reader.ReadByte();
                map.Blocks[i] = MapBlock
                {
                    ObjectIndex = blockDataIndex <= 100 ? blockDataIndex : 0,
                    WallIndex = blockDataIndex != 255 && blockDataIndex > 100 ? (uint32)blockDataIndex - 100 : 0,
                    MapEventId = mapEventId,
                    MapBorder = blockDataIndex == 255
                };
            }
        }

        try EventReader.ReadEvents(ref reader, map.Events, map.EventIds, map.EventList);

        // For each character reference the positions or movement paths are stored here. For random movement there are
        // 2 bytes (x and y). Otherwise there are 288 positions, one for each 5 minutes of the day. A position of 0,0
        // means "not visible on the map".
        foreach (var entry in map.CharacterReferences)
        {
            if (entry is not CharacterReference reference)
                continue;

            if (reference.Type == CharacterType.Monster ||
                (reference.CharacterFlags & (CharacterReferenceFlags.RandomMovement | CharacterReferenceFlags.Stationary)) != CharacterReferenceFlags.None)
            {
                // For monsters, random movement or stationary only the start position is given.
                reference.Positions.Add(_ReadPosition(ref reader));
            }
            else if (reference.HourMovement())
            {
                for (var i = 0; i < 12; i += 1)
                    reference.Positions.Add(_ReadPosition(ref reader));
                for (var i = 12; i < 288; i += 1)
                    reference.Positions.Add(reference.Positions[i % 12]);
            }
            else
            {
                for (var i = 0; i < 288; i += 1)
                    reference.Positions.Add(_ReadPosition(ref reader));
            }
        }

        uint32 gotoPointCount = reader.ReadWord();

        for (uint32 i = 0; i < gotoPointCount; i += 1)
        {
            var x = reader.ReadByte();
            var y = reader.ReadByte();
            var direction = (CharacterDirection)reader.ReadByte();
            var gotoIndex = reader.ReadByte();
            map.GotoPoints.Add(GotoPoint { X = x, Y = y, Direction = direction, Index = gotoIndex, Name = _TrimSpacesAndZeros(reader.ReadString(16)) });
        }

        if (map.Type == MapType.Map3D)
        {
            var types = reader.ReadBytes(map.EventList.Count());
            foreach (var type in types)
                map.EventAutomapTypes.Add((AutomapType)type);
        }

        if (reader.Overrun())
            return error("[Data] Invalid map data");
        return map;
    }

    /// Reads the texts of a map.
    static void ReadMapTexts(ref Map map, DataReader textReader)
    {
        map.Texts = TextReader.ReadTexts(textReader);
    }
}

Position _ReadPosition(ref DataReader reader)
{
    int x = reader.ReadByte();
    int y = reader.ReadByte();
    return Position { X = x, Y = y };
}
