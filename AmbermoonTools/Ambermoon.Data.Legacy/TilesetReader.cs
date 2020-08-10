namespace Ambermoon.Data.Legacy
{
    public class TilesetReader : ITilesetReader
    {
        public void ReadTileset(Tileset tileset, IDataReader dataReader)
        {
            int numTiles = dataReader.ReadWord();
            tileset.Tiles = new Tileset.Tile[numTiles];

            for (int i = 0; i < numTiles; ++i)
            {
                var tileFlags = dataReader.ReadWord();

                tileset.Tiles[i] = new Tileset.Tile();
                tileset.Tiles[i].Unknown1 = dataReader.ReadWord(); // Unknown
                tileset.Tiles[i].GraphicIndex = dataReader.ReadWord();
                tileset.Tiles[i].NumAnimationFrames = dataReader.ReadByte();
                tileset.Tiles[i].Unknown2 = dataReader.ReadByte(); // Unknown
                tileset.Tiles[i].Flags = tileFlags; // TODO: REMOVE later

                ParseTileFlags(tileset.Tiles[i], tileFlags);
            }
        }

        void ParseTileFlags(Tileset.Tile tile, ushort flags)
        {
            // Bit 0: Allow movement (0 means block movement)
            //        Note: This is only used in indoor maps or for outdoor
            //              obstacles that can only be passed by eagle.
            //              But sometimes this isn't right so maybe I'm wrong here.
            // Bit 7-9: Sit/sleep value
            //  0 -> no sitting nor sleeping
            //  1 -> sit and look up
            //  2 -> sit and look right
            //  3 -> sit and look down
            //  4 -> sit and look left
            //  5 -> sleep (always face down)
            // Bit 10: Player invisible (doors, behind towers/walls, etc)

            tile.BlockMovement = (flags & 0x01) == 0;
            var sitSleepValue = (flags >> 7) & 0x07;
            tile.SitDirection = (sitSleepValue == 0 || sitSleepValue > 4) ? (CharacterDirection?)null : (CharacterDirection)(sitSleepValue - 1);
            tile.Sleep = sitSleepValue == 5;
            tile.Invisible = (flags & 0x0400) != 0;
        }
    }
}
