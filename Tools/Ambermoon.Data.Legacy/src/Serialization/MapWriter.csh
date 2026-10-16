namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

/// Writes the maps of 1Map_data.amb, 2Map_data.amb and 3Map_data.amb (MapWriter of Ambermoon.net): the counterpart of
/// [MapReader], a map that was read is written again byte for byte.
struct MapWriter
{
    /// Writes the header of a map (12 bytes).
    static void WriteMapHeader(Map map, ref DataWriter writer)
    {
        writer.WriteWord((uint16)map.Flags);
        writer.WriteByte((uint8)map.Type);
        writer.WriteByte((uint8)map.MusicIndex);
        writer.WriteByte((uint8)map.Width);
        writer.WriteByte((uint8)map.Height);
        writer.WriteByte((uint8)map.TilesetOrLabdataIndex);
        writer.WriteByte((uint8)map.NPCGfxIndex);
        writer.WriteByte((uint8)map.LabyrinthBackgroundIndex);
        writer.WriteByte((uint8)map.PaletteIndex);
        writer.WriteByte((uint8)map.World);
        writer.WriteByte(0);
    }

    /// Writes a map.
    /// @error a 3D map whose automap types do not match its event list.
    static Error<void> WriteMap(Map map, ref DataWriter writer)
    {
        if (map.Type == MapType.Map3D && map.EventAutomapTypes.Count() != map.EventList.Count())
            return error("For 3D maps the EventAutomapTypes collection size must match the EventList collection size.");

        WriteMapHeader(map, ref writer);

        // Up to 32 character references (10 bytes each -> total 320 bytes)
        for (var i = 0; i < 32; i += 1)
        {
            if (map.CharacterReferences[i] is CharacterReference reference)
            {
                writer.WriteByte((uint8)reference.Index);
                writer.WriteByte((uint8)reference.CollisionClass);
                writer.WriteByte((uint8)((int)reference.Type | ((int)reference.CharacterFlags << 2)));
                writer.WriteByte((uint8)reference.EventIndex);
                writer.WriteWord((uint16)reference.GraphicIndex);
                writer.WriteDword((uint32)reference.TileFlags);
            }
            else
            {
                for (var j = 0; j < 10; j += 1)
                    writer.WriteByte(0);
            }
        }

        int count = map.Width * map.Height;
        if (map.Type == MapType.Map2D)
        {
            for (var i = 0; i < count; i += 1)
            {
                var tile = map.Tiles[i];
                writer.WriteByte((uint8)tile.BackTileIndex);
                writer.WriteByte((uint8)tile.MapEventId);
                writer.WriteWord((uint16)tile.FrontTileIndex);
            }
        }
        else
        {
            for (var i = 0; i < count; i += 1)
            {
                var block = map.Blocks[i];
                uint32 blockDataIndex = block.MapBorder ? (uint32)255
                    : block.ObjectIndex != 0 ? block.ObjectIndex
                    : block.WallIndex != 0 ? 100 + block.WallIndex
                    : 0;
                writer.WriteByte((uint8)blockDataIndex);
                writer.WriteByte((uint8)block.MapEventId);
            }
        }

        EventWriter.WriteEvents(ref writer, map.Events, map.EventIds, map.EventList);

        // For each character reference the positions or movement paths: the start position for monsters, random
        // movement or stationary characters, 12 positions (one per 2 hours) for hour movement, else 288 positions
        // (one per 5 minutes of the day). A position of 0,0 means "not visible on the map".
        foreach (var entry in map.CharacterReferences)
        {
            if (entry is not CharacterReference reference)
                continue;
            if (reference.Index == 0)
                continue;

            int positions = 288;
            if (reference.Type == CharacterType.Monster ||
                (reference.CharacterFlags & (CharacterReferenceFlags.RandomMovement | CharacterReferenceFlags.Stationary)) != CharacterReferenceFlags.None)
                positions = 1;
            else if (reference.HourMovement())
                positions = 12;

            for (var i = 0; i < positions; i += 1)
            {
                writer.WriteByte((uint8)reference.Positions[i].X);
                writer.WriteByte((uint8)reference.Positions[i].Y);
            }
        }

        writer.WriteWord((uint16)map.GotoPoints.Count());
        foreach (var gotoPoint in map.GotoPoints)
        {
            writer.WriteByte((uint8)gotoPoint.X);
            writer.WriteByte((uint8)gotoPoint.Y);
            writer.WriteByte((uint8)gotoPoint.Direction);
            writer.WriteByte((uint8)gotoPoint.Index);
            var name = AmbermoonEncoding.GetBytes(gotoPoint.Name);
            for (var i = 0; i < 16; i += 1)
                writer.WriteByte(i < 15 && i < name.Length ? name[i] : (uint8)0);
        }

        if (map.Type == MapType.Map3D)
        {
            foreach (var automapType in map.EventAutomapTypes)
                writer.WriteByte(automapType == AutomapType.Invalid ? (uint8)0 : (uint8)automapType);
        }

        // the files of the game have an even size
        if (writer.Size() % 2 != 0)
            writer.WriteByte(0);
        return;
    }
}
