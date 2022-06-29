using Ambermoon;
using Ambermoon.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AmbermoonMapEditor2D
{
    using CheckPosition = KeyValuePair<int, int>;

    internal class AreaFiller
    {
        readonly Map map;
        readonly List<CheckPosition> checkedPositions = new List<CheckPosition>();

        public AreaFiller(Map map)
        {
            this.map = map;
        }

        public void Fill(int x, int y, uint newTileIndex, int layer, Dictionary<int, uint> changedTiles)
        {
            var oldTile = map.InitialTiles[x, y];
            uint oldTileIndex = layer == 0 ? oldTile.BackTileIndex : oldTile.FrontTileIndex;

            if (oldTileIndex == newTileIndex)
                return;

            void MarkPositionChecked(int x, int y) => checkedPositions.Add(KeyValuePair.Create(x, y));
            bool PositionChecked(int x, int y) => checkedPositions.Contains(KeyValuePair.Create(x, y));

            MarkPositionChecked(x, y);
            ChangeTile(x, y, oldTile);
            CheckAdjacentTiles(x, y);

            void ChangeTile(int x, int y, Map.Tile tile)
            {
                changedTiles.Add(x + y * map.Width, layer == 0 ? tile.BackTileIndex : tile.FrontTileIndex);
                if (layer == 0)
                    tile.BackTileIndex = newTileIndex;
                else
                    tile.FrontTileIndex = newTileIndex;
            }

            void CheckAdjacentTiles(int x, int y)
            {
                void CheckTile(int x, int y)
                {
                    if (!PositionChecked(x, y))
                    {
                        MarkPositionChecked(x, y);

                        var tile = map.InitialTiles[x, y];

                        if (layer == 0)
                        {
                            if (tile.BackTileIndex == oldTileIndex)
                            {
                                ChangeTile(x, y, tile);
                                CheckAdjacentTiles(x, y);
                            }
                        }
                        else
                        {
                            if (tile.FrontTileIndex == oldTileIndex)
                            {
                                ChangeTile(x, y, tile);
                                CheckAdjacentTiles(x, y);
                            }
                        }
                    }                    
                }

                if (x > 0)
                    CheckTile(x - 1, y);
                if (y > 0)
                    CheckTile(x, y - 1);
                if (x < map.Width - 1)
                    CheckTile(x + 1, y);
                if (y < map.Height - 1)
                    CheckTile(x, y + 1);
            }
        }
    }
}
