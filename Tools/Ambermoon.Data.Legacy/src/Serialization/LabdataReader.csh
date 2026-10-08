namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;

/// Reads and writes the data of labyrinths (2Lab_data.amb, 3Lab_data.amb).
struct LabdataReader
{
    /// Reads the labyrinth data without its graphics.
    static Labdata ReadLabdataWithoutGraphics(ref DataReader reader)
    {
        var labdata = Labdata.Create();
        labdata.WallHeight = reader.ReadWord();
        labdata.Flags = reader.ReadWord();
        labdata.CombatBackground = labdata.Flags & 0x0f;
        labdata.CeilingColorIndex = reader.ReadByte();
        labdata.FloorColorIndex = reader.ReadByte();
        // Note: The ceiling texture index can be 0 in which case a sky is used. If the texture index (ceiling and also
        // floor) is 0, the color index is used to draw instead.
        labdata.CeilingTextureIndex = reader.ReadByte();
        labdata.FloorTextureIndex = reader.ReadByte();

        int numObjects = reader.ReadWord();
        var automapTypes = new uint16[numObjects];
        // 8 sub entries per object (a map object can consist of up to 8 sub objects): x, y, z and the object info
        var subEntries = new int16[numObjects * 8 * 4];

        for (var i = 0; i < numObjects; i += 1)
        {
            automapTypes[i] = reader.ReadWord();
            for (var n = 0; n < 8 * 4; n += 1)
                subEntries[i * 32 + n] = (int16)reader.ReadWord();
        }

        int numObjectInfos = reader.ReadWord();

        for (var i = 0; i < numObjectInfos; i += 1)
        {
            var flags = (TileFlags)reader.ReadDword();
            labdata.ObjectInfos.Add(ObjectInfo
            {
                Flags = flags,
                TextureIndex = reader.ReadWord(),
                NumAnimationFrames = reader.ReadByte(),
                ColorIndex = reader.ReadByte(),
                TextureWidth = reader.ReadByte(),
                TextureHeight = reader.ReadByte(),
                MappedTextureWidth = reader.ReadWord(),
                MappedTextureHeight = reader.ReadWord()
            });
        }

        for (var i = 0; i < numObjects; i += 1)
        {
            var subObjects = List<ObjectPosition>.Create(8);

            for (var n = 0; n < 8; n += 1)
            {
                int at = i * 32 + n * 4;
                int infoIndex = (uint16)subEntries[at + 3];
                if (infoIndex != 0 && infoIndex <= labdata.ObjectInfos.Count())
                {
                    subObjects.Add(ObjectPosition
                    {
                        X = subEntries[at],
                        Y = subEntries[at + 1],
                        Z = subEntries[at + 2],
                        Object = labdata.ObjectInfos[infoIndex - 1]
                    });
                }
            }

            labdata.Objects.Add(LabdataObject { AutomapType = (AutomapType)automapTypes[i], SubObjects = subObjects });
        }

        int numWalls = reader.ReadWord();

        for (var i = 0; i < numWalls; i += 1)
        {
            var flags = (TileFlags)reader.ReadDword();
            var wall = WallData
            {
                Flags = flags,
                TextureIndex = reader.ReadByte(),
                AutomapType = (AutomapType)reader.ReadByte(),
                ColorIndex = reader.ReadByte()
            };
            int numOverlays = reader.ReadByte();
            if (numOverlays != 0)
            {
                wall.Overlays = new OverlayData[numOverlays];

                for (var o = 0; o < numOverlays; o += 1)
                {
                    var blend = reader.ReadByte() != 0;
                    wall.Overlays[o] = OverlayData
                    {
                        Blend = blend,
                        TextureIndex = reader.ReadByte(),
                        PositionX = reader.ReadByte(),
                        PositionY = reader.ReadByte(),
                        TextureWidth = reader.ReadByte(),
                        TextureHeight = reader.ReadByte()
                    };
                }
            }
            labdata.Walls.Add(wall);
        }

        return labdata;
    }

    /// Reads the labyrinth data with its graphics (from Floors.amb and the 3D texture files of the game data).
    /// @error the data is too short (an empty file of a labyrinth that does not exist), a texture is missing or an
    /// overlay is outside of its wall.
    static Error<Labdata> ReadLabdata(ref DataReader reader, GameData gameData)
    {
        var labdata = ReadLabdataWithoutGraphics(ref reader);
        if (reader.Overrun())
            return error("The labyrinth data is incomplete.");
        var floors = gameData.Files.TryGet("Floors.amb");

        if (labdata.FloorTextureIndex != 0)
            labdata.FloorGraphic = try _ReadTexture(floors, labdata.FloorTextureIndex, 64, 64, false, false);
        if (labdata.CeilingTextureIndex != 0)
            labdata.CeilingGraphic = try _ReadTexture(floors, labdata.CeilingTextureIndex, 64, 64, false, false);

        // the textures of 2Object3D.amb, where missing or empty those of 3Object3D.amb (the original merges them into
        // the files of the game data, this into a copy)
        var objectTextures = try MergedTextures(gameData, "Object3D.amb");

        foreach (var info in labdata.ObjectInfos)
        {
            var file = try _TextureFile(objectTextures, info.TextureIndex);
            file.Position = 0;
            if (info.NumAnimationFrames == 1)
                labdata.ObjectGraphics.Add(try _ReadGraphic(ref file, info.TextureWidth, info.TextureHeight, true, true));
            else
            {
                // the frames one after the other
                var compound = Graphic.Create((int)(info.NumAnimationFrames * info.TextureWidth), (int)info.TextureHeight, 0);
                for (uint32 i = 0; i < info.NumAnimationFrames; i += 1)
                {
                    var frame = try _ReadGraphic(ref file, info.TextureWidth, info.TextureHeight, true, true);
                    try compound.AddOverlay(i * info.TextureWidth, 0, frame, false);
                }
                labdata.ObjectGraphics.Add(compound);
            }
        }

        var wallTextures = try MergedTextures(gameData, "Wall3D.amb");
        var overlayTextures = try MergedTextures(gameData, "Overlay3D.amb");

        foreach (var wall in labdata.Walls)
        {
            var file = try _TextureFile(wallTextures, wall.TextureIndex);
            file.Position = 0;
            var graphic = try _ReadGraphic(ref file, 128, 80, (wall.Flags & TileFlags.Transparency) != TileFlags.None, true);

            if (wall.Overlays != null)
            {
                foreach (var overlay in wall.Overlays)
                {
                    var overlayFile = try _TextureFile(overlayTextures, overlay.TextureIndex);
                    overlayFile.Position = 0;
                    var overlayGraphic = try _ReadGraphic(ref overlayFile, overlay.TextureWidth, overlay.TextureHeight, true, true);
                    try graphic.AddOverlay(overlay.PositionX, overlay.PositionY, overlayGraphic, overlay.Blend);
                }
            }

            labdata.WallGraphics.Add(graphic);
        }

        return labdata;
    }

    /// The files of 2<name> where missing or empty replaced by those of 3<name> (the textures of the labyrinths).
    /// @error one of the files is missing.
    static Error<Dictionary<int, DataReader>> MergedTextures(GameData gameData, string name)
    {
        if (gameData.Files.TryGet("2" + name) is not FileContainer second)
            return error($"The given key '2{name}' was not present in the dictionary.");
        if (gameData.Files.TryGet("3" + name) is not FileContainer third)
            return error($"The given key '3{name}' was not present in the dictionary.");
        var merged = Dictionary<int, DataReader>.Create();
        foreach (var entry in second.Files.Entries())
            merged[entry.Key] = entry.Value;
        foreach (var entry in third.Files.Entries())
        {
            if (merged.TryGet(entry.Key) is not DataReader existing)
                merged[entry.Key] = entry.Value;
            else if (existing.Size() == 0)
                merged[entry.Key] = entry.Value;
        }
        return merged;
    }

    /// Writes the labyrinth data (without graphics).
    static void WriteLabdata(Labdata labdata, ref DataWriter writer)
    {
        writer.WriteWord((uint16)labdata.WallHeight);
        writer.WriteWord(labdata.Flags);
        writer.WriteByte(labdata.CeilingColorIndex);
        writer.WriteByte(labdata.FloorColorIndex);
        writer.WriteByte(labdata.CeilingTextureIndex);
        writer.WriteByte(labdata.FloorTextureIndex);

        // Objects
        writer.WriteWord((uint16)labdata.Objects.Count());

        foreach (var obj in labdata.Objects)
        {
            writer.WriteWord((uint16)obj.AutomapType);

            for (var i = 0; i < 8; i += 1)
            {
                if (!obj.SubObjects.IsCreated() || i >= obj.SubObjects.Count())
                {
                    writer.WriteDword(0);
                    writer.WriteDword(0);
                }
                else
                {
                    var subObject = obj.SubObjects[i];
                    writer.WriteWord((uint16)subObject.X);
                    writer.WriteWord((uint16)subObject.Y);
                    writer.WriteWord((uint16)subObject.Z);
                    // as in the original: the first object info with the same values
                    writer.WriteWord((uint16)(1 + labdata.IndexOfObjectInfo(subObject.Object)));
                }
            }
        }

        // Object infos
        writer.WriteWord((uint16)labdata.ObjectInfos.Count());

        foreach (var info in labdata.ObjectInfos)
        {
            writer.WriteDword((uint32)info.Flags);
            writer.WriteWord((uint16)info.TextureIndex);
            writer.WriteByte((uint8)info.NumAnimationFrames);
            writer.WriteByte(info.ColorIndex);
            writer.WriteByte((uint8)info.TextureWidth);
            writer.WriteByte((uint8)info.TextureHeight);
            writer.WriteWord((uint16)info.MappedTextureWidth);
            writer.WriteWord((uint16)info.MappedTextureHeight);
        }

        // Walls
        writer.WriteWord((uint16)labdata.Walls.Count());

        foreach (var wall in labdata.Walls)
        {
            writer.WriteDword((uint32)wall.Flags);
            writer.WriteByte((uint8)wall.TextureIndex);
            writer.WriteByte((uint8)wall.AutomapType);
            writer.WriteByte(wall.ColorIndex);

            int numOverlays = wall.Overlays == null ? 0 : wall.Overlays.Length;
            writer.WriteByte((uint8)numOverlays);

            for (var o = 0; o < numOverlays; o += 1)
            {
                var overlay = wall.Overlays[o];
                writer.WriteByte(overlay.Blend ? (uint8)1 : (uint8)0);
                writer.WriteByte((uint8)overlay.TextureIndex);
                writer.WriteByte((uint8)overlay.PositionX);
                writer.WriteByte((uint8)overlay.PositionY);
                writer.WriteByte((uint8)overlay.TextureWidth);
                writer.WriteByte((uint8)overlay.TextureHeight);
            }
        }
    }
}

// the file of a texture
Error<DataReader> _TextureFile(Dictionary<int, DataReader> files, uint32 index)
{
    if (files.TryGet((int)index) is DataReader file)
        return file;
    return error($"The given key '{index}' was not present in the dictionary.");
}

// a texture of a file of Floors.amb
Error<Graphic> _ReadTexture(Optional<FileContainer> container, uint32 index, uint32 width, uint32 height, bool alpha, bool texture)
{
    if (container is not FileContainer floors)
        return error("The given key 'Floors.amb' was not present in the dictionary.");
    var file = try _TextureFile(floors.Files, index);
    file.Position = 0;
    return _ReadGraphic(ref file, width, height, alpha, texture);
}

// a 4 bit graphic (planar or texture), at the position of the reader
Error<Graphic> _ReadGraphic(ref DataReader reader, uint32 width, uint32 height, bool alpha, bool texture)
{
    var info = GraphicInfo
    {
        Width = (int)width,
        Height = (int)height,
        GraphicFormat = texture ? GraphicFormat.Texture4Bit : GraphicFormat.Palette4Bit,
        PaletteOffset = 0,
        Alpha = alpha
    };
    return GraphicReader.ReadGraphic(ref reader, info);
}
