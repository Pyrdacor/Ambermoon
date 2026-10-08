namespace Ambermoon.Data;

using System;
using Ambermoon;
using Ambermoon.Data.Enumerations;

/// The flags of tiles, 3D walls and objects and map characters (Tileset.TileFlags).
/// [Flags]
enum TileFlags : uint32
{
    None = 0,
    /// Animations will go back and forth instead of loop cyclic
    WaveAnimation = 0x00000001,
    BlockSight = 0x00000002,
    Background = 0x00000004,
    /// Only for 3D objects; for 3D walls this is Transparency
    Floor = 0x00000008,
    /// Only randomly trigger the animation from time to time
    RandomAnimationStart = 0x00000010,
    UseBackgroundTileFlags = 0x00000020,
    BringToFront = 0x00000040,
    BlockAllMovement = 0x00000080,
    /// On non-world maps this and the below AllowMovement values are just arbitrary collision classes which can be used
    /// by 3D chars (the player always has this first class on non-world maps).
    AllowMovementWalk = 0x00000100,
    AllowMovementHorse = 0x00000200,
    AllowMovementRaft = 0x00000400,
    AllowMovementShip = 0x00000800,
    AllowMovementMagicalDisc = 0x00001000,
    AllowMovementEagle = 0x00002000,
    AllowMovementFly = 0x00004000,
    AllowMovementSwim = 0x00008000,
    AllowMovementWitchBroom = 0x00010000,
    AllowMovementSandLizard = 0x00020000,
    AllowMovementSandShip = 0x00040000,
    AllowMovementWasp = 0x00080000,
    AllowMovementUnused13 = 0x00100000,
    AllowMovementUnused14 = 0x00200000,
    AllowMovementUnused15 = 0x00400000,
    /// Also No3DAnimation for 3D objects
    PlayerInvisible = 0x04000000,
    /// Auto-poisoning (you can dodge the trap with LUK but there will be no popup). It only poisons while the animation
    /// is active.
    AutoPoison = 0x08000000,
    /// Only for 3D walls
    Transparency = Floor,
    AllowMovementMonster = AllowMovementHorse,
    /// Only for 3D objects
    No3DAnimation = PlayerInvisible
}

/// A tile of a tileset.
struct TilesetTile
{
    TileFlags Flags;
    uint32 GraphicIndex;
    int NumAnimationFrames;
    uint8 ColorIndex;

    /// The travel types (bits) that may move on the tile.
    uint16 AllowedTravelTypes()
    {
        return (uint16)(((uint32)Flags >> 8) & 0xfff);
    }

    /// The direction to sit in (null: no seat).
    Optional<CharacterDirection> SitDirection()
    {
        var value = ((uint32)Flags >> 23) & 0x07;
        if (value == 0 || value > 4)
            return null;
        return (CharacterDirection)(value - 1);
    }

    bool Sleep()
    {
        return (((uint32)Flags >> 23) & 0x07) == 5;
    }

    uint32 CombatBackgroundIndex()
    {
        return (uint32)Flags >> 28;
    }

    /// The player is invisible on the tile.
    bool CharacterInvisible()
    {
        return (Flags & TileFlags.PlayerInvisible) != TileFlags.None;
    }

    bool UseBackgroundTileFlags()
    {
        return (Flags & TileFlags.UseBackgroundTileFlags) != TileFlags.None;
    }

    bool AllowMovement(TravelType travelType)
    {
        return (Flags & TileFlags.BlockAllMovement) == TileFlags.None && (AllowedTravelTypes() & (1 << (int)travelType)) != 0;
    }
}

/// The tiles of 2D maps.
struct Tileset
{
    uint32 Index;
    TilesetTile[] Tiles;

    bool AllowMovement(uint32 backgroundTile, uint32 foregroundTile, TravelType travelType)
    {
        if (foregroundTile == 0)
            return GetTile(backgroundTile).AllowMovement(travelType);
        if (backgroundTile == 0)
            return GetTile(foregroundTile).AllowMovement(travelType);
        var foreground = GetTile(foregroundTile);
        return foreground.UseBackgroundTileFlags() ? GetTile(backgroundTile).AllowMovement(travelType)
                                                   : foreground.AllowMovement(travelType);
    }

    /// The tile of a 1-based index (an empty tile for indices outside of the tileset).
    TilesetTile GetTile(uint32 index)
    {
        if (index == 0 || index > (uint32)Tiles.Length)
            return TilesetTile { };
        return Tiles[(int)index - 1];
    }
}
