namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data;

/// Reads the tilesets of Icon_data.amb.
struct TilesetReader
{
    static Tileset ReadTileset(ref DataReader reader, uint32 index)
    {
        reader.Position = 0;
        int numTiles = reader.ReadWord();
        var tiles = new TilesetTile[numTiles];

        for (var i = 0; i < numTiles; i += 1)
        {
            var flags = reader.ReadDword();
            tiles[i] = TilesetTile
            {
                GraphicIndex = reader.ReadWord(),
                NumAnimationFrames = reader.ReadByte(),
                ColorIndex = reader.ReadByte(),
                Flags = (TileFlags)flags
            };
        }

        return Tileset { Index = index, Tiles = tiles };
    }
}
