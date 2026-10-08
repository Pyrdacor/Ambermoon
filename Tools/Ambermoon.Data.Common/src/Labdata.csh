namespace Ambermoon.Data;

using System;
using Ambermoon.Data.Enumerations;

/// The texture and flags of a 3D object.
struct ObjectInfo
{
    TileFlags Flags;
    uint32 TextureIndex;
    uint32 NumAnimationFrames;
    /// not 100% sure
    uint8 ColorIndex;
    uint32 TextureWidth;
    uint32 TextureHeight;
    uint32 MappedTextureWidth;
    uint32 MappedTextureHeight;

    /// Equal values (the original finds object infos by their value).
    bool Equals(ObjectInfo other)
    {
        return Flags == other.Flags && TextureIndex == other.TextureIndex && NumAnimationFrames == other.NumAnimationFrames &&
               ColorIndex == other.ColorIndex && TextureWidth == other.TextureWidth && TextureHeight == other.TextureHeight &&
               MappedTextureWidth == other.MappedTextureWidth && MappedTextureHeight == other.MappedTextureHeight;
    }
}

/// A sub object of a 3D object and where it is.
struct ObjectPosition
{
    int16 X;
    int16 Y;
    int16 Z;
    ObjectInfo Object;
}

/// A 3D object: up to 8 sub objects (Labdata.Object).
struct LabdataObject
{
    AutomapType AutomapType;
    List<ObjectPosition> SubObjects;
}

/// An overlay of a 3D wall.
struct OverlayData
{
    bool Blend;
    uint32 TextureIndex;
    uint32 PositionX;
    uint32 PositionY;
    uint32 TextureWidth;
    uint32 TextureHeight;
}

/// A 3D wall.
struct WallData
{
    TileFlags Flags;
    uint32 TextureIndex;
    AutomapType AutomapType;
    uint8 ColorIndex;
    /// null: none
    OverlayData[] Overlays;
}

/// The data of a labyrinth (3D map): objects, walls, floor and ceiling.
struct Labdata
{
    /// The floor dimension (tile width/height) is 512. The reference wall height is 341 (which is 2/3 of 512).
    uint32 WallHeight;
    /// There are 16 combat background sets.
    uint32 CombatBackground;
    uint16 Flags;
    uint8 CeilingColorIndex;
    uint8 FloorColorIndex;
    uint8 CeilingTextureIndex;
    uint8 FloorTextureIndex;
    List<LabdataObject> Objects;
    List<ObjectInfo> ObjectInfos;
    List<WallData> Walls;
    List<Graphic> ObjectGraphics;
    /// They include optional overlays.
    List<Graphic> WallGraphics;
    Optional<Graphic> FloorGraphic;
    Optional<Graphic> CeilingGraphic;

    static Labdata Create()
    {
        return Labdata
        {
            Objects = List<LabdataObject>.Create(),
            ObjectInfos = List<ObjectInfo>.Create(),
            Walls = List<WallData>.Create(),
            ObjectGraphics = List<Graphic>.Create(),
            WallGraphics = List<Graphic>.Create()
        };
    }

    /// The index of the first object info with the value of `info`; -1 if there is none.
    int IndexOfObjectInfo(ObjectInfo info)
    {
        for (var i = 0; i < ObjectInfos.Count(); i += 1)
        {
            if (ObjectInfos[i].Equals(info))
                return i;
        }
        return -1;
    }
}
