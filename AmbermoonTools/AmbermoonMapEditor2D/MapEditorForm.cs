using System;
using System.Drawing;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class MapEditorForm : Form
    {
        public MapEditorForm()
        {
            InitializeComponent();
        }

        private void MapEditorForm_Load(object sender, EventArgs e)
        {
            BringToFront();
            var openMapForm = new OpenMapForm(gameData, tilesets);

            if (openMapForm.ShowDialog(this) == DialogResult.OK)
            {
                BringToFront();
                Refresh();
                gameData = openMapForm.GameData;
                tilesets = openMapForm.Tilesets;
                Initialize();
                InitializeMap(openMapForm.Map);
            }
            else
            {
                Close();
            }
        }

        private void buttonWorldMapDefaults_Click(object sender, EventArgs e)
        {
            if (numericUpDownWidth.Value != 50 || numericUpDownHeight.Value != 50)
            {
                if (!AskYesNo("Changing to world map, forces the map size to be changed to 50x50. Do you want to proceed?"))
                    return;

                numericUpDownWidth.Value = 50;
                numericUpDownHeight.Value = 50;
                MapSizeChanged();
            }

            radioButtonOutdoor.Checked = true;
            checkBoxWorldSurface.Checked = true;
            checkBoxResting.Checked = true;
            checkBoxNoSleepUntilDawn.Checked = false;
            checkBoxMagic.Checked = true;
        }

        private void buttonIndoorDefaults_Click(object sender, EventArgs e)
        {
            radioButtonIndoor.Checked = true;
            checkBoxWorldSurface.Checked = false;
            checkBoxResting.Checked = false;
            checkBoxMagic.Checked = true;
        }

        private void buttonResize_Click(object sender, EventArgs e)
        {
            if (numericUpDownWidth.Enabled)
            {
                buttonResize.Text = "Enable resizing";
                numericUpDownWidth.Enabled = false;
                numericUpDownHeight.Enabled = false;
            }
            else
            {
                buttonResize.Text = "Disable resizing";
                numericUpDownWidth.Enabled = true;
                numericUpDownHeight.Enabled = true;
            }
        }

        private void buttonToggleMusic_Click(object sender, EventArgs e)
        {
            ToggleMusic();
        }

        private void checkBoxWorldSurface_CheckedChanged(object sender, EventArgs e)
        {
            if (checkBoxWorldSurface.Checked && (numericUpDownWidth.Value != 50 || numericUpDownHeight.Value != 50))
            {
                if (AskYesNo("Changing to world map, forces the map size to be changed to 50x50. Do you want to proceed?"))
                {
                    numericUpDownWidth.Value = 50;
                    numericUpDownHeight.Value = 50;
                    MapSizeChanged();
                }
            }

            buttonResize.Enabled = !checkBoxWorldSurface.Checked;

            if (checkBoxWorldSurface.Checked)
            {
                numericUpDownWidth.Enabled = false;
                numericUpDownHeight.Enabled = false;
                buttonResize.Text = "Enable resizing";
            }

            checkBoxUnknown1.Checked = checkBoxTravelGraphics.Checked = checkBoxWorldSurface.Checked;
            groupBoxCharacters.Enabled = !checkBoxWorldSurface.Checked;
        }

        private void comboBoxMusic_SelectedIndexChanged(object sender, EventArgs e)
        {
            StopMusic();
            // TODO
        }

        private void checkBoxResting_CheckedChanged(object sender, EventArgs e)
        {
            if (!checkBoxResting.Checked)
            {
                checkBoxNoSleepUntilDawn.Checked = false;
            }

            checkBoxNoSleepUntilDawn.Enabled = checkBoxResting.Checked;
        }

        private void radioButtonIndoor_CheckedChanged(object sender, EventArgs e)
        {
            if (radioButtonIndoor.Checked)
                MapTypeChanged();
        }

        private void radioButtonOutdoor_CheckedChanged(object sender, EventArgs e)
        {
            if (radioButtonOutdoor.Checked)
                MapTypeChanged();
        }

        private void radioButtonDungeon_CheckedChanged(object sender, EventArgs e)
        {
            if (radioButtonDungeon.Checked)
                MapTypeChanged();
        }

        private void buttonShowCharacterOnMap_Click(object sender, EventArgs e)
        {

        }

        private void buttonEditCharacter_Click(object sender, EventArgs e)
        {

        }

        private void buttonDeleteCharacter_Click(object sender, EventArgs e)
        {

        }

        private void pictureBoxCharacterImage_Click(object sender, EventArgs e)
        {

        }

        private void comboBoxCharacters_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void panelMap_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.Clear(panelMap.BackColor);

            if (map != null)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];
                using var grid = new Pen(Color.Black, 1.0f);

                for (int y = 0; y < MapHeight; ++y)
                {
                    int drawY = panelMap.AutoScrollPosition.Y + y * 16;

                    if (drawY + 16 <= 0)
                        continue;

                    if (drawY >= panelMap.Height)
                        break;

                    for (int x = 0; x < MapWidth; ++x)
                    {
                        int drawX = panelMap.AutoScrollPosition.X + x * 16;

                        if (drawX + 16 <= 0)
                            continue;

                        if (drawX >= panelMap.Width)
                            break;

                        var tile = map.Tiles[x, y];
                        var backgroundTile = tile.BackTileIndex == 0 ? null : tile.BackTileIndex >= tileset.Tiles.Length ? null : tileset.Tiles[tile.BackTileIndex - 1];
                        var foregroundTile = tile.FrontTileIndex == 0 ? null : tile.FrontTileIndex >= tileset.Tiles.Length ? null :  tileset.Tiles[tile.FrontTileIndex - 1];
                        var rect = new Rectangle(drawX, drawY, 16, 16);

                        if (toolStripMenuItemShowBackLayer.Checked && backgroundTile != null)
                        {
                            try
                            {
                                var backgroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, backgroundTile.GraphicIndex - 1, map.PaletteIndex);
                                e.Graphics.DrawImageUnscaledAndClipped(backgroundImage, rect);
                            }
                            catch
                            {
                                // ignore
                            }
                        }

                        if (toolStripMenuItemShowFrontLayer.Checked && foregroundTile != null)
                        {
                            try
                            {
                                var foregroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, foregroundTile.GraphicIndex - 1, map.PaletteIndex);
                                e.Graphics.DrawImageUnscaledAndClipped(foregroundImage, rect);
                            }
                            catch
                            {
                                // ignore
                            }
                        }

                        if (showGrid)
                            e.Graphics.DrawRectangle(grid, rect);
                    }
                }
            }
        }

        private void panelTileset_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.Clear(panelTileset.BackColor);

            if (map != null)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];
                int x = 0;
                int y = 0;
                using var border = new Pen(Color.Black, 1.0f);
                using var errorBrush = new SolidBrush(Color.Red);

                foreach (var tile in tileset.Tiles)
                {
                    int drawY = panelTileset.AutoScrollPosition.Y + y * 16;

                    if (drawY >= panelTileset.Height)
                        break;

                    int drawX = panelTileset.AutoScrollPosition.X + x * 16;

                    if (drawY + 16 > 0 && drawX + 16 > 0 && drawX < panelMap.Width)
                    {
                        var rect = new Rectangle(drawX, drawY, 16, 16);

                        try
                        {
                            var image = imageCache.GetImage(map.TilesetOrLabdataIndex, tile.GraphicIndex - 1, map.PaletteIndex);
                            e.Graphics.DrawImageUnscaledAndClipped(image, rect);
                            e.Graphics.DrawRectangle(border, rect);
                        }
                        catch
                        {
                            e.Graphics.FillRectangle(errorBrush, rect);
                            // ignore, there seem to be invalid tiles/graphic indices, just skip them
                        }
                    }

                    if (++x == TilesetTilesPerRow)
                    {
                        x = 0;
                        ++y;
                    }
                }
            }
        }

        private void MapEditorForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            CleanUp();
        }

        private void panelMap_Scroll(object sender, ScrollEventArgs e)
        {
            panelMap.Refresh();
        }

        private void comboBoxTilesets_SelectedIndexChanged(object sender, EventArgs e)
        {
            map.TilesetOrLabdataIndex = (uint)(1 + comboBoxTilesets.SelectedIndex);
            currentTilesetTiles = tilesets[map.TilesetOrLabdataIndex].Tiles.Length;
            panelMap.Refresh();
            TilesetChanged();
        }

        private void buttonToolLayers_Click(object sender, EventArgs e)
        {
            var point = new Point(buttonToolLayers.Right, buttonToolLayers.Bottom);
            point = PointToScreen(point);
            contextMenuStripLayers.Show(point);
        }

        private void toolStripMenuItemBackLayer_Click(object sender, EventArgs e)
        {
            toolStripMenuItemFrontLayer.Checked = !toolStripMenuItemBackLayer.Checked;
        }

        private void toolStripMenuItemFrontLayer_Click(object sender, EventArgs e)
        {
            toolStripMenuItemBackLayer.Checked = !toolStripMenuItemFrontLayer.Checked;
        }

        private void toolStripMenuItemShowBackLayer_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void toolStripMenuItemShowFrontLayer_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void buttonToolBrush_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.Brush);
        }

        private void buttonToolBlocks_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.Blocks);
        }

        private void buttonToolFill_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.Fill);
        }

        private void buttonToolColorPicker_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.ColorPicker);
        }

        private void buttonToggleGrid_Click(object sender, EventArgs e)
        {
            showGrid = !showGrid;
            buttonToggleGrid.Image = showGrid ? Properties.Resources.round_grid_off_black_24 : Properties.Resources.round_grid_on_black_24;
            panelMap.Refresh();
        }
    }
}
