namespace Ambermoon.Data;

using System;
using Ambermoon;
using Ambermoon.Data.Enumerations;

/// The flags of a map.
/// [Flags]
enum MapFlags : int32
{
    None = 0,
    /// Always at full light.
    Indoor = 1 << 0,
    /// Light level is given by the daytime.
    Outdoor = 1 << 1,
    /// Only own light sources will grant light.
    Dungeon = 1 << 2,
    /// If set the map is available and the map has to be explored. It also allows map-related spells. All Morag
    /// temples omit this.
    Automapper = 1 << 3,
    CanRest = 1 << 4,
    /// Unknown. All world maps use that in Ambermoon.
    Unknown1 = 1 << 5,
    /// All towns have this and the ruin tower. Only considered for 3D maps.
    Sky = 1 << 6,
    /// If active sleep time is always 8 hours.
    NoSleepUntilDawn = 1 << 7,
    /// Allow stationary graphics (travel type images) and therefore transports. Is set for all world maps.
    StationaryGraphics = 1 << 8,
    /// Unknown. Never used in Ambermoon.
    Unknown2 = 1 << 9,
    /// If set the map doesn't use map text 0 as the title but uses the world name instead.
    WorldSurface = 1 << 10,
    /// It just disables the spell book if not set but you still can use scrolls or items.
    CanUseMagic = 1 << 11,
    /// Won't use travel music if StationaryGraphics is set
    NoTravelMusic = 1 << 12,
    /// Forbids the use of "Word of marking" and "Word of returning"
    NoMarkOrReturn = 1 << 13,
    /// Forbids the use of eagle and broom
    NoEagleOrBroom = 1 << 14,
    /// Only used internal by the new game data, do not use in original!
    SharedMapData = 1 << 15,
    /// Display player smaller. Only all world maps have this set. Only considered for 2D maps.
    SmallPlayer = StationaryGraphics
}

/// What a tile of a 2D map is for the player.
enum MapTileType : int32
{
    Normal,
    ChairUp,
    ChairRight,
    ChairDown,
    ChairLeft,
    Bed,
    Invisible,
    Water
}

/// A tile of a 2D map.
struct MapTile
{
    /// Back layer in 2D maps
    uint32 BackTileIndex;
    /// Front layer in 2D maps
    uint32 FrontTileIndex;
    uint32 MapEventId;
    MapTileType Type;

    bool AllowMovement(Tileset tileset, TravelType travelType)
    {
        if (travelType != TravelType.Swim && Type > MapTileType.Normal && Type < MapTileType.Invisible)
            return true;
        return tileset.AllowMovement(BackTileIndex, FrontTileIndex, travelType);
    }
}

/// A block of a 3D map.
struct MapBlock
{
    uint32 ObjectIndex;
    uint32 WallIndex;
    uint32 MapEventId;
    /// This block is not drawn at all.
    bool MapBorder;
}

/// The flags of a character on a map (Map.CharacterReference.Flags).
/// [Flags]
enum CharacterReferenceFlags : int32
{
    None = 0,
    RandomMovement = 0x01,
    UseTileset = 0x02,
    TextPopup = 0x04,
    NPCTalksToYou = 0x08,
    HourMovement = 0x10,
    /// new in Ambermoon Advanced
    Stationary = 0x20,
    /// new in Ambermoon Advanced
    MoveOnlyWhenSeePlayer = 0x20
}

/// A character on a map: party member, NPC, monster (group) or map text.
struct CharacterReference
{
    CharacterType Type;
    CharacterReferenceFlags CharacterFlags;
    /// Equals travel type.
    int CollisionClass;
    /// of party member, npc, monster or map text
    uint32 Index;
    /// Upper 4 bits of this contains the combat background index.
    TileFlags TileFlags;
    uint32 EventIndex;
    /// An object index inside the labdata for 3D maps, a tile index inside the tileset for 2D maps if flag UseTileset
    /// is set, an NPC graphic index for 2D maps if flag UseTileset is not set and it's an NPC.
    uint32 GraphicIndex;
    uint32 CombatBackgroundIndex;
    /// The positions: one (monsters, random movement, stationary) or one for each 5 minutes of the day (288).
    List<Position> Positions;

    bool OnlyMoveWhenSeePlayer()
    {
        return Type == CharacterType.Monster && (CharacterFlags & CharacterReferenceFlags.MoveOnlyWhenSeePlayer) != CharacterReferenceFlags.None;
    }

    bool Stationary()
    {
        return Type != CharacterType.Monster && (CharacterFlags & CharacterReferenceFlags.Stationary) != CharacterReferenceFlags.None;
    }

    bool HourMovement()
    {
        return Type != CharacterType.Monster && (CharacterFlags & CharacterReferenceFlags.HourMovement) != CharacterReferenceFlags.None;
    }

    bool NPCTalksToYou()
    {
        return Type == CharacterType.NPC && (CharacterFlags & CharacterReferenceFlags.TextPopup) == CharacterReferenceFlags.None &&
               (CharacterFlags & CharacterReferenceFlags.NPCTalksToYou) != CharacterReferenceFlags.None;
    }
}

/// A place a map can be traveled to with the map of the goto points.
struct GotoPoint
{
    uint32 X;
    uint32 Y;
    CharacterDirection Direction;
    uint32 Index;
    string Name;
}

/// A map: 2D (tiles) or 3D (blocks), its characters, events, texts and goto points.
struct Map
{
    uint32 Index;
    MapFlags Flags;
    MapType Type;
    uint32 MusicIndex;
    int Width;
    int Height;
    /// Tileset index in 2D, labdata index in 3D
    uint32 TilesetOrLabdataIndex;
    /// This is only used in non-world-surface 2D maps: which of the 2 NPC graphic files of NPC_gfx.amb (0: none).
    uint32 NPCGfxIndex;
    /// For outdoor 3D maps (towns): 0: Not used, 1: Lyramion, 2: Forest Moon, 3: Morag
    uint32 LabyrinthBackgroundIndex;
    uint32 PaletteIndex;
    World World;
    /// The tiles of a 2D map (x + y * Width).
    MapTile[] Tiles;
    /// The blocks of a 3D map (x + y * Width).
    MapBlock[] Blocks;
    /// The events of the map (ids in Events.Store).
    EventStore Events;
    List<int> EventIds;
    /// The events that blocks and tiles refer to (MapEventId - 1).
    List<int> EventList;
    List<string> Texts;
    /// 32 references; the ones after the first empty one are empty.
    Optional<CharacterReference>[] CharacterReferences;
    List<GotoPoint> GotoPoints;
    List<AutomapType> EventAutomapTypes;

    static Map Create(uint32 index)
    {
        return Map
        {
            Index = index,
            Events = EventStore.Create(),
            EventIds = List<int>.Create(),
            EventList = List<int>.Create(),
            Texts = List<string>.Create(),
            CharacterReferences = new Optional<CharacterReference>[32],
            GotoPoints = List<GotoPoint>.Create(),
            EventAutomapTypes = List<AutomapType>.Create()
        };
    }

    /// The name of the map: the world and the index for world maps and the maps 1 to 255, else the first text.
    string Name()
    {
        if (IsWorldMap() || Index < 256)
            return EnumText(World, false) + Index.ToString("D3");
        return Texts.Count() == 0 ? "" : Texts[0];
    }

    /// A text of the map, `fallbackText` if there is no such text.
    string GetText(int index, string fallbackText)
    {
        if (index < 0 || index >= Texts.Count())
            return fallbackText;
        return Texts[index];
    }

    bool IsWorldMap()
    {
        return (Flags & MapFlags.WorldSurface) != MapFlags.None;
    }

    MapTile Tile(int x, int y)
    {
        return Tiles[x + y * Width];
    }

    MapBlock Block(int x, int y)
    {
        return Blocks[x + y * Width];
    }

    /// What a tile is for the player: a bed, a chair, invisible, water or normal.
    static MapTileType TileTypeFromTile(MapTile tile, Tileset tileset)
    {
        var tilesetTile = tileset.GetTile(tile.FrontTileIndex == 0 ? tile.BackTileIndex : tile.FrontTileIndex);

        if (tilesetTile.Sleep())
            return MapTileType.Bed;
        if (tilesetTile.SitDirection() is CharacterDirection direction)
            return (MapTileType)((int)MapTileType.ChairUp + (int)direction);
        if (tilesetTile.CharacterInvisible())
            return MapTileType.Invisible;
        if (tile.AllowMovement(tileset, TravelType.Swim))
            return MapTileType.Water;
        return MapTileType.Normal;
    }
}
