using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Drawing;
using System.Linq;
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

            if (OpenMap())
            {
                history.UndoGotFilled += () => toolStripMenuItemEditUndo.Enabled = true;
                history.UndoGotEmpty += () => toolStripMenuItemEditUndo.Enabled = false;
                history.RedoGotFilled += () => toolStripMenuItemEditRedo.Enabled = true;
                history.RedoGotEmpty += () => toolStripMenuItemEditRedo.Enabled = false;
            }
            else
            {
                Close();
            }
        }

        bool OpenMap()
        {
            var openMapForm = new OpenMapForm(gameData, tilesets, mapManager);
            if (openMapForm.ShowDialog(this) == DialogResult.OK)
            {
                BringToFront();
                Refresh();
                gameData = openMapForm.GameData;
                tilesets = openMapForm.Tilesets;
                mapManager = openMapForm.MapManager;
                currentTilesetTiles = tilesets[openMapForm.Map.TilesetOrLabdataIndex].Tiles.Length;
                Initialize();
                InitializeMap(openMapForm.Map);
                history.Clear();
                toolStripMenuItemEditUndo.Enabled = false;
                toolStripMenuItemEditRedo.Enabled = false;
                return true;
            }

            return false;
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

            UpdateMapFlags();
        }

        private void comboBoxMusic_SelectedIndexChanged(object sender, EventArgs e)
        {
            StopMusic();
            map.MusicIndex = (uint)(comboBoxMusic.SelectedIndex + 1);
        }

        private void checkBoxResting_CheckedChanged(object sender, EventArgs e)
        {
            if (!checkBoxResting.Checked)
            {
                checkBoxNoSleepUntilDawn.Checked = false;
            }

            checkBoxNoSleepUntilDawn.Enabled = checkBoxResting.Checked;

            UpdateMapFlags();
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
                using var textBrush = new SolidBrush(Color.White);
                using var textBackground = new SolidBrush(Color.FromArgb(0x40, 0x80, 0x80, 0x80));
                using var font = new Font(FontFamily.GenericMonospace, 8.0f);

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

                        var tile = map.InitialTiles[x, y];
                        var backgroundTile = tile.BackTileIndex == 0 ? null : tile.BackTileIndex >= tileset.Tiles.Length ? null : tileset.Tiles[tile.BackTileIndex - 1];
                        var foregroundTile = tile.FrontTileIndex == 0 ? null : tile.FrontTileIndex >= tileset.Tiles.Length ? null :  tileset.Tiles[tile.FrontTileIndex - 1];
                        var rect = new Rectangle(drawX, drawY, 16, 16);

                        if (toolStripMenuItemShowBackLayer.Checked && backgroundTile != null)
                        {
                            try
                            {
                                uint frame = backgroundTile.NumAnimationFrames <= 1 ? 0 : (uint)(this.frame % (ulong)backgroundTile.NumAnimationFrames);
                                var backgroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, backgroundTile.GraphicIndex + frame - 1, map.PaletteIndex);
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
                                uint frame = foregroundTile.NumAnimationFrames <= 1 ? 0 : (uint)(this.frame % (ulong)foregroundTile.NumAnimationFrames);
                                var foregroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, foregroundTile.GraphicIndex + frame - 1, map.PaletteIndex);
                                e.Graphics.DrawImageUnscaledAndClipped(foregroundImage, rect);
                            }
                            catch
                            {
                                // ignore
                            }
                        }

                        if (showGrid)
                            e.Graphics.DrawRectangle(grid, new Rectangle(drawX, drawY, 15, 15));

                        if (showEvents && tile.MapEventId != 0)
                        {
                            e.Graphics.FillRectangle(textBackground, new Rectangle(drawX + 1, drawY + 1, 13, 13));
                            e.Graphics.DrawString(tile.MapEventId.ToString("x2"), font, textBrush, drawX, drawY);
                        }
                    }
                }

                if (showTileMarker &&hoveredMapTile != -1 && tileMarkerWidth > 0 && tileMarkerHeight > 0)
                {
                    int visibleColumns = panelMap.Width / 16;
                    int visibleRows = panelMap.Height / 16;
                    int hoveredX = hoveredMapTile % visibleColumns;
                    int hoveredY = hoveredMapTile / visibleColumns;

                    if (hoveredX + tileMarkerWidth < visibleColumns &&
                        hoveredY + tileMarkerHeight < visibleRows)
                    {
                        int startX = panelMap.AutoScrollPosition.X % 16 + hoveredX * 16;
                        int startY = panelMap.AutoScrollPosition.Y % 16 + hoveredY * 16;
                        using var marker = new SolidBrush(Color.FromArgb(0x40, 0x77, 0xff, 0x66));
                        using var border = new Pen(Color.FromArgb(0x80, 0xff, 0xff, 0x00), 1);

                        for (int y = 0; y < tileMarkerHeight; ++y)
                        {
                            for (int x = 0; x < tileMarkerWidth; ++x)
                            {
                                e.Graphics.FillRectangle(marker, new Rectangle(startX + x * 16 + 1, startY + y * 16 + 1, 14, 14));
                                e.Graphics.DrawRectangle(border, new Rectangle(startX + x * 16, startY + y * 16, 15, 15));
                            }
                        }
                    }
                }
                // TODO: fill marker
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
                using var selectedBorder = new Pen(Color.Yellow, 2.0f);
                using var errorBrush = new SolidBrush(Color.White);
                using var errorFont = new Font(FontFamily.GenericMonospace, 8.0f);
                using var errorFontBrush = new SolidBrush(Color.Red);
                var tiles = currentLayer == 0 ? tileset.Tiles.Take(256) : tileset.Tiles;

                foreach (var tile in tiles)
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
                            uint frame = tile.NumAnimationFrames <= 1 ? 0 : (uint)(this.frame % (ulong)tile.NumAnimationFrames);
                            var image = imageCache.GetImage(map.TilesetOrLabdataIndex, tile.GraphicIndex + frame - 1, map.PaletteIndex);
                            e.Graphics.DrawImageUnscaledAndClipped(image, rect);
                            e.Graphics.DrawRectangle(border, rect);
                        }
                        catch
                        {
                            e.Graphics.FillRectangle(errorBrush, rect);
                            e.Graphics.DrawString("X", errorFont, errorFontBrush, rect.X + 3, rect.Y);
                            // ignore, there are many unused tiles without valid graphic indices, just skip them and mark them as unused/invalid
                        }
                    }

                    if (++x == TilesetTilesPerRow)
                    {
                        x = 0;
                        ++y;
                    }
                }

                if (selectedTilesetTile > tiles.Count())
                    selectedTilesetTile = 0;

                int selectedColumn = selectedTilesetTile % TilesetTilesPerRow;
                int selectedRow = selectedTilesetTile / TilesetTilesPerRow;
                e.Graphics.DrawRectangle(selectedBorder, new Rectangle(panelTileset.AutoScrollPosition.X + selectedColumn * 16,
                    panelTileset.AutoScrollPosition.Y + selectedRow * 16, 16, 16));

                if (showTileMarker && hoveredTilesetTile != -1)
                {
                    int visibleColumns = panelTileset.Width / 16;
                    int visibleRows = panelTileset.Height / 16;
                    int hoveredX = hoveredTilesetTile % visibleColumns;
                    int hoveredY = hoveredTilesetTile / visibleColumns;

                    int startX = panelTileset.AutoScrollPosition.X % 16 + hoveredX * 16;
                    int startY = panelTileset.AutoScrollPosition.Y % 16 + hoveredY * 16;
                    using var marker = new SolidBrush(Color.FromArgb(0x40, 0x77, 0xff, 0x66));
                    using var markedBorder = new Pen(Color.FromArgb(0x80, 0xff, 0xff, 0x00), 1);

                    e.Graphics.FillRectangle(marker, new Rectangle(startX + 1, startY + 1, 14, 14));
                    e.Graphics.DrawRectangle(markedBorder, new Rectangle(startX, startY, 15, 15));
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
            uint oldTilesetIndex = map.TilesetOrLabdataIndex;
            uint newTilesetIndex = (uint)(1 + comboBoxTilesets.SelectedIndex);

            void UpdateTileset(uint index, bool updateIndex)
            {
                map.TilesetOrLabdataIndex = index;
                currentTilesetTiles = tilesets[map.TilesetOrLabdataIndex].Tiles.Length;
                panelMap.Refresh();
                TilesetChanged();

                if (updateIndex)
                {
                    comboBoxTilesets.SelectedIndexChanged -= comboBoxTilesets_SelectedIndexChanged;
                    comboBoxTilesets.SelectedIndex = (int)index - 1;
                    comboBoxTilesets.SelectedIndexChanged += comboBoxTilesets_SelectedIndexChanged;
                }
            }

            PerformAction($"Change tileset to {newTilesetIndex}", $"Change tileset to {oldTilesetIndex}",
                redo => UpdateTileset(newTilesetIndex, redo), () => UpdateTileset(oldTilesetIndex, true));
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
            currentLayer = 0;
            toolStripStatusLabelLayer.Text = LayerName[0];
            UpdateTileset();
        }

        private void toolStripMenuItemFrontLayer_Click(object sender, EventArgs e)
        {
            toolStripMenuItemBackLayer.Checked = !toolStripMenuItemFrontLayer.Checked;
            currentLayer = 1;
            toolStripStatusLabelLayer.Text = LayerName[1];
            UpdateTileset();
        }

        void UpdateTileset()
        {
            currentTilesetTiles = currentLayer == 0 ? Math.Min(256, tilesets[map.TilesetOrLabdataIndex].Tiles.Length)
                : tilesets[map.TilesetOrLabdataIndex].Tiles.Length;
            TilesetChanged();
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
            SelectTool(blocksTool);
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
            buttonToggleGrid.Image = showGrid ? Properties.Resources.round_grid_on_black_24 : Properties.Resources.round_grid_off_black_24;
            panelMap.Refresh();
        }

        private void panelTileset_MouseDown(object sender, MouseEventArgs e)
        {
            int tx = (e.X - panelTileset.AutoScrollPosition.X) / 16;
            int ty = (e.Y - panelTileset.AutoScrollPosition.Y) / 16;
            int selectedIndex = tx + ty * TilesetTilesPerRow;

            if (selectedIndex < tilesets[map.TilesetOrLabdataIndex].Tiles.Length)
            {
                selectedTilesetTile = selectedIndex;
                panelTileset.Refresh();

                try
                {
                    var tile = tilesets[map.TilesetOrLabdataIndex].Tiles[selectedIndex];
                    toolStripStatusLabelCurrentTile.Image = imageCache.GetImage(map.TilesetOrLabdataIndex, tile.GraphicIndex - 1, map.PaletteIndex);
                }
                catch
                {
                    toolStripStatusLabelCurrentTile.Image = null;
                }
            }
        }

        private void toolStripMenuItemBlocks2x2_Click(object sender, EventArgs e)
        {
            blocksTool = Tool.Blocks2x2;
            buttonToolBlocks.Image = ImageFromTool(blocksTool, true);
            SelectTool(blocksTool);
        }

        private void toolStripMenuItemBlocks3x2_Click(object sender, EventArgs e)
        {
            blocksTool = Tool.Blocks3x2;
            buttonToolBlocks.Image = ImageFromTool(blocksTool, true);
            SelectTool(blocksTool);
        }

        private void toolStripMenuItemBlocks3x3_Click(object sender, EventArgs e)
        {
            blocksTool = Tool.Blocks3x3;
            buttonToolBlocks.Image = ImageFromTool(blocksTool, true);
            SelectTool(blocksTool);
        }

        private void panelMap_MouseMove(object sender, MouseEventArgs e)
        {
            if (!panelMap.ClientRectangle.Contains(e.Location))
            {
                if (hoveredMapTile != -1)
                {
                    toolStripStatusLabelCurrentTile.Visible = false;
                    hoveredMapTile = -1;
                    panelMap.Refresh();
                }
                return;
            }

            int visibleColumns = panelMap.Width / 16;
            int hoveredColumn = (e.X - panelMap.AutoScrollPosition.X % 16) / 16;
            int hoveredRow = (e.Y - panelMap.AutoScrollPosition.Y % 16) / 16;
            int scrolledXTile = -panelMap.AutoScrollPosition.X / 16;
            int scrolledYTile = -panelMap.AutoScrollPosition.Y / 16;
            int newHoveredTile = hoveredColumn + hoveredRow * visibleColumns;

            int x = scrolledXTile + hoveredColumn;
            int y = scrolledYTile + hoveredRow;

            if (x >= map.Width || y >= map.Height)
            {
                if (hoveredMapTile != -1)
                {
                    toolStripStatusLabelCurrentTile.Visible = false;
                    hoveredMapTile = -1;
                    panelMap.Refresh();
                }
                return;
            }

            toolStripStatusLabelCurrentTile.Text = $"{1 + x}, {1 + y} [Index: {x + y * map.Width}]";
            toolStripStatusLabelCurrentTile.Visible = true;

            if (newHoveredTile != hoveredMapTile)
            {
                hoveredMapTile = newHoveredTile;
                panelMap.Refresh();
            }

            if (e.Button == MouseButtons.Left)
                UseTool(x, y, false);
            else if (e.Button == MouseButtons.Right)
                UseTool(x, y, true);
        }

        private void panelMap_MouseLeave(object sender, EventArgs e)
        {
            toolStripStatusLabelCurrentTile.Visible = false;
            hoveredMapTile = -1;
            panelMap.Refresh();
        }

        private void buttonToggleTileMarker_Click(object sender, EventArgs e)
        {
            showTileMarker = !showTileMarker;
            buttonToggleTileMarker.Image = showTileMarker ? Properties.Resources.round_select_all_black_24 : Properties.Resources.round_select_all_black_24_off;
            panelMap.Refresh();
        }

        private void panelTileset_MouseLeave(object sender, EventArgs e)
        {
            toolStripStatusLabelCurrentTilesetTile.Visible = false;
            hoveredTilesetTile = -1;
            panelTileset.Refresh();
        }

        private void panelTileset_MouseMove(object sender, MouseEventArgs e)
        {
            if (!panelTileset.ClientRectangle.Contains(e.Location))
            {
                if (hoveredTilesetTile != -1)
                {
                    toolStripStatusLabelCurrentTilesetTile.Visible = false;
                    hoveredTilesetTile = -1;
                    panelTileset.Refresh();
                }
                return;
            }

            int visibleColumns = panelTileset.Width / 16;
            int hoveredColumn = (e.X - panelTileset.AutoScrollPosition.X % 16) / 16;
            int hoveredRow = (e.Y - panelTileset.AutoScrollPosition.Y % 16) / 16;
            int scrolledXTile = -panelTileset.AutoScrollPosition.X / 16;
            int scrolledYTile = -panelTileset.AutoScrollPosition.Y / 16;
            int newHoveredTile = hoveredColumn + hoveredRow * visibleColumns;

            int x = scrolledXTile + hoveredColumn;
            int y = scrolledYTile + hoveredRow;
            int index = x + y * TilesetTilesPerRow;

            if (index >= (currentLayer == 0 ? 256 : 2500))
            {
                toolStripStatusLabelCurrentTilesetTile.Visible = false;

                if (hoveredTilesetTile != -1)
                {
                    hoveredTilesetTile = -1;
                    panelTileset.Refresh();
                }
            }
            else
            {
                toolStripStatusLabelCurrentTilesetTile.Text = $"{1 + x}, {1 + y} [Index: {index}]";
                toolStripStatusLabelCurrentTilesetTile.Visible = true;

                if (newHoveredTile != hoveredTilesetTile)
                {
                    hoveredTilesetTile = newHoveredTile;
                    panelTileset.Refresh();
                }
            }
        }

        private void comboBoxPalettes_SelectedIndexChanged(object sender, EventArgs e)
        {
            uint oldPaletteIndex = map.PaletteIndex;
            uint newPaletteIndex = (uint)(1 + comboBoxPalettes.SelectedIndex);

            void UpdatePalette(uint index, bool updateIndex)
            {
                map.PaletteIndex = index;
                panelTileset.Refresh();
                panelMap.Refresh();

                if (updateIndex)
                {
                    comboBoxPalettes.SelectedIndexChanged -= comboBoxPalettes_SelectedIndexChanged;
                    comboBoxPalettes.SelectedIndex = (int)index - 1;
                    comboBoxPalettes.SelectedIndexChanged += comboBoxPalettes_SelectedIndexChanged;
                }
            }

            PerformAction($"Change palette to {newPaletteIndex}", $"Change palette to {oldPaletteIndex}",
                redo => UpdatePalette(newPaletteIndex, redo), () => UpdatePalette(oldPaletteIndex, true));
        }

        private void panelMap_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left || e.Button == MouseButtons.Right)
            {
                int hoveredColumn = (e.X - panelMap.AutoScrollPosition.X % 16) / 16;
                int hoveredRow = (e.Y - panelMap.AutoScrollPosition.Y % 16) / 16;
                int scrolledXTile = -panelMap.AutoScrollPosition.X / 16;
                int scrolledYTile = -panelMap.AutoScrollPosition.Y / 16;

                int x = scrolledXTile + hoveredColumn;
                int y = scrolledYTile + hoveredRow;

                UseTool(x, y, e.Button == MouseButtons.Right);
            }
        }

        private void buttonToolRemoveFrontLayer_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.RemoveFrontLayer);
        }

        private void toolStripMenuItemEditUndo_Click(object sender, EventArgs e)
        {
            history.Undo();
        }

        private void toolStripMenuItemEditRedo_Click(object sender, EventArgs e)
        {
            history.Redo();
        }

        private void toolStripMenuItemMapNew_Click(object sender, EventArgs e)
        {
            if (unsavedChanges)
            {
                var result = MessageBox.Show(this, "There are unsaved changes. Do you want to save them now?",
                    "Unsaved changes", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);

                if (result == DialogResult.Cancel)
                    return;

                if (result == DialogResult.Yes)
                {
                    if (!Save())
                    {
                        if (MessageBox.Show(this, "Error saving the map. Do you want to abort and return to your current map?",
                            "Unable to save map", MessageBoxButtons.YesNo, MessageBoxIcon.Error) == DialogResult.Yes)
                            return;
                    }
                }
            }

            OpenMap();            
        }

        private void toolStripMenuItemMapSave_Click(object sender, EventArgs e)
        {
            Save();
        }

        private void toolStripMenuItemMapSaveAs_Click(object sender, EventArgs e)
        {
            SaveAs();
        }

        private void toolStripMenuItemMapQuit_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void MapEditorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (unsavedChanges)
            {
                var result = MessageBox.Show(this, "There are unsaved changes. Do you want to save them now?",
                    "Unsaved changes", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question);

                if (result == DialogResult.Cancel)
                {
                    e.Cancel = true;
                    return;
                }

                if (result == DialogResult.Yes)
                {
                    if (!Save())
                    {
                        if (MessageBox.Show(this, "Error saving the map. Do you want to abort and return to your current map?",
                            "Unable to save map", MessageBoxButtons.YesNo, MessageBoxIcon.Error) == DialogResult.Yes)
                        {
                            e.Cancel = true;
                            return;
                        }
                    }
                }
            }
        }

        private void numericUpDownWidth_ValueChanged(object sender, EventArgs e)
        {
            int oldWidth = map.Width;
            map.Width = (int)numericUpDownWidth.Value;
            var backup = new Map.Tile[map.Width, map.Height];
            var initialBackup = new Map.Tile[map.Width, map.Height];
            for (int y = 0; y < map.Height; ++y)
            {
                for (int x = 0; x < map.Width; ++x)
                {
                    initialBackup[x, y] = x >= oldWidth
                        ? new Map.Tile { BackTileIndex = 1 }
                        : map.InitialTiles[x, y];
                    backup[x, y] = x >= oldWidth
                        ? new Map.Tile { BackTileIndex = 1 }
                        : map.InitialTiles[x, y];
                }
            }
            map.InitialTiles = initialBackup;
            map.InitialTiles = backup;
            MapSizeChanged();
        }

        private void numericUpDownHeight_ValueChanged(object sender, EventArgs e)
        {
            int oldHeight = map.Height;
            map.Height = (int)numericUpDownHeight.Value;
            var backup = new Map.Tile[map.Width, map.Height];
            var initialBackup = new Map.Tile[map.Width, map.Height];
            for (int y = 0; y < map.Height; ++y)
            {
                for (int x = 0; x < map.Width; ++x)
                {
                    initialBackup[x, y] = y >= oldHeight
                        ? new Map.Tile { BackTileIndex = 1 }
                        : map.InitialTiles[x, y];
                    backup[x, y] = y >= oldHeight
                        ? new Map.Tile { BackTileIndex = 1 }
                        : map.InitialTiles[x, y];
                }
            }
            map.InitialTiles = initialBackup;
            map.InitialTiles = backup;
            MapSizeChanged();
        }

        private void buttonToggleEvents_Click(object sender, EventArgs e)
        {
            showEvents = !showEvents;
            buttonToggleEvents.Image = showEvents ? Properties.Resources.round_vpn_key_black_24 : Properties.Resources.round_vpn_key_black_24_off;
            panelMap.Refresh();
        }

        private void panelMap_MouseDoubleClick(object sender, MouseEventArgs e)
        {
            int hoveredColumn = (e.X - panelMap.AutoScrollPosition.X % 16) / 16;
            int hoveredRow = (e.Y - panelMap.AutoScrollPosition.Y % 16) / 16;
            int scrolledXTile = -panelMap.AutoScrollPosition.X / 16;
            int scrolledYTile = -panelMap.AutoScrollPosition.Y / 16;

            int x = scrolledXTile + hoveredColumn;
            int y = scrolledYTile + hoveredRow;

            var eventIdSelector = new EventIdSelectionForm(map, map.InitialTiles[x, y].MapEventId);

            if (eventIdSelector.ShowDialog() == DialogResult.OK)
            {
                uint newId = eventIdSelector.EventId;

                if (map.InitialTiles[x, y].MapEventId != newId)
                {
                    map.InitialTiles[x, y].MapEventId = newId;
                    panelMap.Refresh();
                }
            }
        }

        private void checkBoxTravelGraphics_CheckedChanged(object sender, EventArgs e)
        {
            UpdateMapFlags();
        }

        private void checkBoxMagic_CheckedChanged(object sender, EventArgs e)
        {
            UpdateMapFlags();
        }

        private void checkBoxNoSleepUntilDawn_CheckedChanged(object sender, EventArgs e)
        {
            UpdateMapFlags();
        }

        private void checkBoxUnknown1_CheckedChanged(object sender, EventArgs e)
        {
            UpdateMapFlags();
        }

        private void buttonEditTile_Click(object sender, EventArgs e)
        {
            var tileset = tilesets[map.TilesetOrLabdataIndex];
            var form = new EditTileForm(tileset.Tiles[selectedTilesetTile], tileset, imageCache, map.PaletteIndex, combatBackgrounds);

            if (form.ShowDialog() == DialogResult.OK)
            {
                tileset.Tiles[selectedTilesetTile].Fill(form.Tile);
                panelTileset.Refresh();
            }
        }

        private void timerAnimation_Tick(object sender, EventArgs e)
        {
            if (mapLoading)
                return;

            ++frame;
            panelTileset.Refresh();
            panelMap.Refresh();
        }

        private void buttonExportTileset_Click(object sender, EventArgs e)
        {
            var dialog = new SaveFileDialog();

            dialog.AddExtension = false;
            dialog.AutoUpgradeEnabled = true;
            dialog.CheckFileExists = false;
            dialog.CheckPathExists = false;
            dialog.CreatePrompt = false;
            dialog.Filter = "All files (*.*)|*.*";
            dialog.OverwritePrompt = true;
            dialog.RestoreDirectory = true;
            dialog.Title = "Save tileset";

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];
                var dataWriter = new DataWriter();
                TilesetWriter.WriteTileset(tileset, dataWriter);
                System.IO.File.WriteAllBytes(dialog.FileName, dataWriter.ToArray());
            }
        }

        private void buttonAddTileset_Click(object sender, EventArgs e)
        {
            // TODO: we also have to add a new icon file
            /*uint index = 1 + (uint)tilesets.Count;

            var tileset = new Tileset()
            {
                Index = index,
                Tiles = new Tileset.Tile[2500]
            };

            for (int i = 0; i < 2500; ++i)
                tileset.Tiles[i] = new Tileset.Tile();

            tilesets.Add(index, tileset);

            comboBoxTilesets.SelectedIndex = (int)index - 1;*/
        }
    }
}
