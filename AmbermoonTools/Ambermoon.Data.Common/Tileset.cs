namespace Ambermoon.Data
{
    public class Tileset
    {
        public class Tile
        {
            public uint GraphicIndex { get; set; }
            public int NumAnimationFrames { get; set; }
            public bool BlockMovement { get; set; }
            public CharacterDirection? SitDirection { get; set; }
            public bool Sleep { get; set; }
            public bool Invisible { get; set; } // player is invisible while standing on that tile
            public byte Unknown2 { get; set; } // TODO: What is this? Remove if unused later.
            public ulong Flags { get; set; } // TODO: REMOVE later
        }

        public uint Index { get; set; }
        public Tile[] Tiles { get; set; }

        private Tileset()
        {

        }

        public static Tileset Load(ITilesetReader tilesetReader, IDataReader dataReader)
        {
            var tileset = new Tileset();

            tilesetReader.ReadTileset(tileset, dataReader);

            return tileset;
        }
    }
}
