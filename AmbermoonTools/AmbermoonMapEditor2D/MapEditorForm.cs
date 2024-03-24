using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using Color = System.Drawing.Color;

namespace AmbermoonMapEditor2D
{
    public partial class MapEditorForm : Form
    {
        private AmbermoonMapCharEditor.PositionEditorForm positionEditor = null;

		public MapEditorForm()
        {
            InitializeComponent();

            title = Text;
        }

        private void MapEditorForm_Load(object sender, EventArgs e)
        {
            configuration = Configuration.Load(Configuration.FilePath);

            BringToFront();

            if (OpenMap())
            {
                history.UndoGotFilled += () => toolStripMenuItemEditUndo.Enabled = true;
                history.UndoGotEmpty += () => toolStripMenuItemEditUndo.Enabled = false;
                history.RedoGotFilled += () => toolStripMenuItemEditRedo.Enabled = true;
                history.RedoGotEmpty += () => toolStripMenuItemEditRedo.Enabled = false;

                graphicProvider = new GraphicProvider2D(combatBackgrounds, gameData, imageCache, tilesets);
                graphicProvider.PaletteIndex = map.PaletteIndex;
                mapCharEditorControl.Init(map, gameData, graphicProvider, SaveImage);
                mapCharEditorControl.SelectionChanged += MapCharEditorControl_SelectionChanged;
                mapCharEditorControl.CurrentCharacterChanged += MapCharEditorControl_CurrentCharacterChanged;
                mapCharEditorControl.DirtyChanged += MapCharEditorControl_DirtyChanged;

                selectedMapCharacter = mapCharEditorControl.Count == 0 ? -1 : 0;
                UpdateMapCharacterButtons();
            }
            else
            {
                Close();
            }
        }

        private void MapCharEditorControl_DirtyChanged()
        {
            if (mapCharEditorControl.Dirty)
                MarkAsDirty();
        }

        void SaveImage(IWin32Window parent, Action<string> saveAction)
        {
            var dialog = new SaveDialog(configuration, Configuration.ImagePathName, "Save image", "png");

            dialog.Filter = "Portable Network Graphic (*.png)|*.png";

            if (dialog.ShowDialog(parent) == DialogResult.OK)
                saveAction?.Invoke(dialog.FileName);
        }

        bool OpenMap()
        {
            var openMapForm = new OpenMapForm(configuration, gameDataPath, gameData, tilesets, mapManager);
            if (openMapForm.ShowDialog(this) == DialogResult.OK)
            {
                BringToFront();
                Refresh();
                gameDataPath = openMapForm.GameDataPath;
                gameData = openMapForm.GameData;
                tilesets = openMapForm.Tilesets;
                mapManager = openMapForm.MapManager;
                currentTilesetTiles = tilesets[openMapForm.Map.TilesetOrLabdataIndex].Tiles.Length;
                Initialize();
                InitializeMap(openMapForm.Map?.Clone());
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

            MarkAsDirty();
        }

        private void buttonIndoorDefaults_Click(object sender, EventArgs e)
        {
            radioButtonIndoor.Checked = true;
            checkBoxWorldSurface.Checked = false;
            checkBoxResting.Checked = false;
            checkBoxMagic.Checked = true;

            MarkAsDirty();
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
            MarkAsDirty();
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
                using var blockBrush = new SolidBrush(Color.FromArgb(0x80, 0x20, 0xff, 0x40));
                using var font = new Font(FontFamily.GenericMonospace, 8.0f);
                int tileSize = (trackBarZoom.Maximum - trackBarZoom.Value + 1) * 16;
                int showAllowedTravelTypes = 0;

                if (toolStripMenuShowAllowWalk.Checked)
                    showAllowedTravelTypes |= (1 << (int)TravelType.Walk);
                if (toolStripMenuShowAllowHorse.Checked)
                    showAllowedTravelTypes |= (1 << (int)TravelType.Horse);
                if (toolStripMenuShowAllowDisc.Checked)
                    showAllowedTravelTypes |= (1 << (int)TravelType.MagicalDisc);
                if (toolStripMenuShowAllowRaft.Checked)
                    showAllowedTravelTypes |= (1 << (int)TravelType.Raft);
                if (toolStripMenuShowAllowShip.Checked)
                    showAllowedTravelTypes |= (1 << (int)TravelType.Ship);

                for (int y = 0; y < MapHeight; ++y)
                {
                    int drawY = panelMap.AutoScrollPosition.Y + y * tileSize;

                    if (drawY + tileSize <= 0)
                        continue;

                    if (drawY >= panelMap.Height)
                        break;

                    for (int x = 0; x < MapWidth; ++x)
                    {
                        int drawX = panelMap.AutoScrollPosition.X + x * tileSize;

                        if (drawX + tileSize <= 0)
                            continue;

                        if (drawX >= panelMap.Width)
                            break;

                        var tile = map.InitialTiles[x, y];
                        var backgroundTile = tile.BackTileIndex == 0 ? null : tile.BackTileIndex > tileset.Tiles.Length ? null : tileset.Tiles[tile.BackTileIndex - 1];
                        var foregroundTile = tile.FrontTileIndex == 0 ? null : tile.FrontTileIndex > tileset.Tiles.Length ? null : tileset.Tiles[tile.FrontTileIndex - 1];
                        var rect = new Rectangle(drawX, drawY, tileSize + (tileSize / 16 - 1), tileSize + (tileSize / 16 - 1));

                        if (toolStripMenuItemShowBackLayer.Checked && backgroundTile != null)
                        {
                            try
                            {
                                uint frame = backgroundTile.NumAnimationFrames <= 1 ? 0 : (uint)(this.frame % (ulong)backgroundTile.NumAnimationFrames);
                                var backgroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, backgroundTile.GraphicIndex + frame - 1, map.PaletteIndex);
                                var interpolationMode = e.Graphics.InterpolationMode;
                                e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                                e.Graphics.DrawImage(backgroundImage, rect);
                                e.Graphics.InterpolationMode = interpolationMode;
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
                                var interpolationMode = e.Graphics.InterpolationMode;
                                e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                                e.Graphics.DrawImage(foregroundImage, rect);
                                e.Graphics.InterpolationMode = interpolationMode;
                            }
                            catch
                            {
                                // ignore
                            }
                        }

                        if (showAllowedTravelTypes != 0)
                        {
                            Tileset.Tile blockFlagsTile = foregroundTile == null || foregroundTile.UseBackgroundTileFlags ? backgroundTile : foregroundTile;

                            if ((~blockFlagsTile.AllowedTravelTypes & showAllowedTravelTypes) != showAllowedTravelTypes)
                                e.Graphics.FillRectangle(blockBrush, rect);
                        }

                        if (showGrid)
                            e.Graphics.DrawRectangle(grid, new Rectangle(drawX, drawY, tileSize - 1, tileSize - 1));

                        if (showEvents && tile.MapEventId != 0)
                        {
                            int diff = (tileSize - 16) / 2;
                            e.Graphics.FillRectangle(textBackground, new Rectangle(drawX + 1 + diff, drawY + 1 + diff, 13, 13));
                            e.Graphics.DrawString(tile.MapEventId.ToString("x2"), font, textBrush, drawX, drawY);
                        }
                    }
                }

                if (showTileMarker && hoveredMapTile != -1 && tileMarkerWidth > 0 && tileMarkerHeight > 0)
                {
                    int visibleColumns = panelMap.Width / tileSize;
                    int visibleRows = panelMap.Height / tileSize;
                    int hoveredX = hoveredMapTile % visibleColumns;
                    int hoveredY = hoveredMapTile / visibleColumns;

                    if (hoveredX + tileMarkerWidth <= visibleColumns + 1 &&
                        hoveredY + tileMarkerHeight <= visibleRows + 1)
                    {
                        int startX = panelMap.AutoScrollPosition.X % tileSize + hoveredX * tileSize;
                        int startY = panelMap.AutoScrollPosition.Y % tileSize + hoveredY * tileSize;
                        using var marker = new SolidBrush(Color.FromArgb(0x40, 0x77, 0xff, 0x66));
                        using var border = new Pen(Color.FromArgb(0x80, 0xff, 0xff, 0x00), 1);

                        for (int y = 0; y < tileMarkerHeight; ++y)
                        {
                            for (int x = 0; x < tileMarkerWidth; ++x)
                            {
                                e.Graphics.FillRectangle(marker, new Rectangle(startX + x * tileSize + 1, startY + y * tileSize + 1, tileSize - 2, tileSize - 2));
                                e.Graphics.DrawRectangle(border, new Rectangle(startX + x * tileSize, startY + y * tileSize, tileSize - 1, tileSize - 1));
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
                using var unusedBrush = new SolidBrush(Color.FromArgb(0x80, 0xff, 0x40, 0x20));
                var tiles = currentLayer == 0 ? tileset.Tiles.Take(256) : tileset.Tiles;
                var mapTiles = !checkBoxMarkUnusedTiles.Checked ? null : map.InitialTiles.Cast<Map.Tile>()
                    .SelectMany(tile => new[] { tile.BackTileIndex, tile.FrontTileIndex })
                    .Distinct()
                    .Where(tile => tile != 0)
                    .ToHashSet();
                uint tileIndex = 1;

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

                        if (checkBoxMarkUnusedTiles.Checked && !mapTiles.Contains(tileIndex))
                        {
                            e.Graphics.FillRectangle(unusedBrush, rect);
                        }
                    }

                    if (++x == TilesetTilesPerRow)
                    {
                        x = 0;
                        ++y;
                    }

                    ++tileIndex;
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
            configuration.Save(Configuration.FilePath);
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

        private void toolStripMenuShowAllowWalk_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void toolStripMenuShowAllowHorse_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void toolStripMenuShowAllowDisc_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void toolStripMenuShowAllowRaft_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void toolStripMenuShowAllowShip_Click(object sender, EventArgs e)
        {
            panelMap.Refresh();
        }

        private void buttonToolBrush_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.Brush);
        }

        private void buttonToolEventChanger_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.EventChanger);

            if (!showEvents)
                ToggleEvents();
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

            if (choosingTileSlotForDuplicating)
            {
                choosingTileSlotForDuplicating = false;

                if (e.Button != MouseButtons.Left || selectedIndex >= tilesets[map.TilesetOrLabdataIndex].Tiles.Length)
                    return;

                var tile = tilesets[map.TilesetOrLabdataIndex].Tiles[selectedTilesetTile];
                selectedTilesetTile = selectedIndex;
                tilesets[map.TilesetOrLabdataIndex].Tiles[selectedTilesetTile].Fill(tile);
                panelTileset.Refresh();

                try
                {
                    toolStripStatusLabelCurrentTile.Image = imageCache.GetImage(map.TilesetOrLabdataIndex, tile.GraphicIndex - 1, map.PaletteIndex);
                }
                catch
                {
                    toolStripStatusLabelCurrentTile.Image = null;
                }
            }

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

            int tileSize = (trackBarZoom.Maximum - trackBarZoom.Value + 1) * 16;
            int visibleColumns = panelMap.Width / tileSize;
            int hoveredColumn = (e.X - panelMap.AutoScrollPosition.X % tileSize) / tileSize;
            int hoveredRow = (e.Y - panelMap.AutoScrollPosition.Y % tileSize) / tileSize;
            int scrolledXTile = -panelMap.AutoScrollPosition.X / tileSize;
            int scrolledYTile = -panelMap.AutoScrollPosition.Y / tileSize;
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

            if (index >= (currentLayer == 0 ? Math.Min(256, currentTilesetTiles) : currentTilesetTiles))
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
                toolStripStatusLabelCurrentTilesetTile.Text = $"{1 + x}, {1 + y} [Index: {index + 1}]";
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
                if (graphicProvider != null)
                    graphicProvider.PaletteIndex = index;
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
                int tileSize = (trackBarZoom.Maximum - trackBarZoom.Value + 1) * 16;
                int hoveredColumn = (e.X - panelMap.AutoScrollPosition.X % tileSize) / tileSize;
                int hoveredRow = (e.Y - panelMap.AutoScrollPosition.Y % tileSize) / tileSize;
                int scrolledXTile = -panelMap.AutoScrollPosition.X / tileSize;
                int scrolledYTile = -panelMap.AutoScrollPosition.Y / tileSize;

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

            CheckHistoryUnsavedChanges();
        }

        private void toolStripMenuItemEditRedo_Click(object sender, EventArgs e)
        {
            history.Redo();

            CheckHistoryUnsavedChanges();
        }

        void CheckHistoryUnsavedChanges()
        {
            if (unsavedChanges && !unsavedChangesBesideHistory && !history.Dirty)
            {
                unsavedChanges = false;
                Text = title;
            }
            else if (history.Dirty)
            {
                MarkAsDirty(true);
            }
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
                    var saveResult = Save();

                    if (saveResult == SaveResult.Error)
                    {
                        if (MessageBox.Show(this, "Error saving the map. Do you want to abort and return to your current map?",
                            "Unable to save map", MessageBoxButtons.YesNo, MessageBoxIcon.Error) == DialogResult.Yes)
                            return;
                    }
                    else if (saveResult == SaveResult.Cancelled)
                    {
                        return;
                    }
                }
            }

            if (OpenMap())
            {
                saveFileName = null;
                toolStripMenuItemMapSave.Enabled = false;
                graphicProvider.PaletteIndex = map.PaletteIndex;
                mapCharEditorControl.Init(map);
                selectedMapCharacter = mapCharEditorControl.Count == 0 ? -1 : 0;
                UpdateMapCharacterButtons();
            }
        }

        private void toolStripMenuItemMapSave_Click(object sender, EventArgs e)
        {
            Save();
        }

        private void toolStripMenuItemMapSaveAs_Click(object sender, EventArgs e)
        {
            if (SaveAs() == SaveResult.Success && saveFileName != null)
                toolStripMenuItemMapSave.Enabled = true;
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
                    var saveResult = Save();

                    if (saveResult == SaveResult.Error)
                    {
                        if (MessageBox.Show(this, "Error saving the map. Do you want to abort and return to your current map?",
                            "Unable to save map", MessageBoxButtons.YesNo, MessageBoxIcon.Error) == DialogResult.Yes)
                        {
                            e.Cancel = true;
                            return;
                        }
                    }
                    else if (saveResult == SaveResult.Cancelled)
                    {
                        e.Cancel = true;
                        return;
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

        void ToggleEvents()
        {
            showEvents = !showEvents;
            buttonToggleEvents.Image = showEvents ? Properties.Resources.round_vpn_key_black_24 : Properties.Resources.round_vpn_key_black_24_off;
            panelMap.Refresh();
        }

        private void buttonToggleEvents_Click(object sender, EventArgs e)
        {
            ToggleEvents();
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
            var form = new EditTileForm(configuration, tileset.Tiles[selectedTilesetTile], tileset, imageCache, map.PaletteIndex, combatBackgrounds);

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
            var dialog = new SaveDialog(configuration, Configuration.TilesetPathName, "Save tileset");

            dialog.Filter = "All files (*.*)|*.*";

            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];
                var dataWriter = new DataWriter();
                TilesetWriter.WriteTileset(tileset, dataWriter);
                System.IO.File.WriteAllBytes(dialog.FileName, dataWriter.ToArray());
            }
        }

        private void buttonDuplicateTile_Click(object sender, EventArgs e)
        {
            MessageBox.Show("Close this window, then left click on the tile slot where the copy should be placed. Use right click on tileset or Escape key to abort.");

            choosingTileSlotForDuplicating = true;
        }

        /*private void buttonAddTileset_Click(object sender, EventArgs e)
        {
            // TODO: we also have to add a new icon file
            uint index = 1 + (uint)tilesets.Count;

            var tileset = new Tileset()
            {
                Index = index,
                Tiles = new Tileset.Tile[2500]
            };

            for (int i = 0; i < 2500; ++i)
                tileset.Tiles[i] = new Tileset.Tile();

            tilesets.Add(index, tileset);

            comboBoxTilesets.SelectedIndex = (int)index - 1;
        }*/

        private void comboBoxWorld_SelectedIndexChanged(object sender, EventArgs e)
        {
            map.World = (World)comboBoxWorld.SelectedIndex;
            MarkAsDirty();
        }

        private void trackBarZoom_Scroll(object sender, EventArgs e)
        {
            MapSizeChanged();
        }

        private void mapCharEditorControl_Load(object sender, EventArgs e)
        {

        }

        private void buttonPositions_Click(object sender, EventArgs e)
        {
            if (selectedMapCharacter == -1)
                return;

            var character = map.CharacterReferences[selectedMapCharacter];

            if (character == null)
                return;

            positionEditor ??= new AmbermoonMapCharEditor.PositionEditorForm(map, character);

            positionEditor.Show();

            void PositionEditorClosed(object s, EventArgs e)
            {
				positionEditor.FormClosed -= PositionEditorClosed;

				if (positionEditor.Dirty)
					MarkAsDirty();

				positionEditor = null;
			}

            positionEditor.FormClosed += PositionEditorClosed;
        }

        private void buttonPlaceCharacterOnMap_Click(object sender, EventArgs e)
        {
            SelectTool(Tool.PositionPicker);
        }

        private void MapCharEditorControl_SelectionChanged(int index)
        {
            selectedMapCharacter = index;

            UpdateMapCharacterButtons();
        }

        private void MapCharEditorControl_CurrentCharacterChanged()
        {
            UpdateMapCharacterButtons();
        }

        void UpdateMapCharacterButtons()
        {
            if (selectedMapCharacter == -1 || map.CharacterReferences[selectedMapCharacter] == null)
            {
                buttonPositions.Enabled = false;
                buttonPlaceCharacterOnMap.Enabled = false;
                labelCharacterPosition.Visible = false;
            }
            else
            {
                var character = map.CharacterReferences[selectedMapCharacter];
                buttonPositions.Enabled = !character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.RandomMovement) &&
                    (character.Type == CharacterType.Monster || !character.CharacterFlags.HasFlag(Map.CharacterReference.Flags.Stationary));
                buttonPlaceCharacterOnMap.Enabled = !buttonPositions.Enabled;
                labelCharacterPosition.Visible = buttonPlaceCharacterOnMap.Enabled;

                if (buttonPositions.Enabled)
                {
                    if (character.Positions.Count < 288)
                    {
                        int add = 288 - character.Positions.Count;
                        int x = character.Positions.Count == 0 ? 1 : character.Positions[0].X;
                        int y = character.Positions.Count == 0 ? 1 : character.Positions[0].Y;

                        for (int i = 0; i < add; ++i)
                            character.Positions.Add(new Ambermoon.Position(x, y));
                    }
                }
                else
                {
                    if (character.Positions.Count == 0)
                        character.Positions.Add(new Ambermoon.Position(0, 0));
                    else if (character.Positions.Count > 1)
                        character.Positions.RemoveRange(1, character.Positions.Count - 1);

                    var position = character.Positions[0];
                    UpdateMapCharacterPosition(position);
                }
            }
        }

        void UpdateMapCharacterPosition(Ambermoon.Position position)
        {
            labelCharacterPosition.Text = $"Location: {position.X}, {position.Y}";
        }

        private void buttonPlaceCharacterOnMap_EnabledChanged(object sender, EventArgs e)
        {
            if (!buttonPlaceCharacterOnMap.Enabled && currentTool == Tool.PositionPicker)
                SelectTool(Tool.Brush);
        }

        private void MapEditorForm_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
                choosingTileSlotForDuplicating = false;
        }

        private void checkBoxMarkUnusedTiles_CheckedChanged(object sender, EventArgs e)
        {
            panelTileset.Refresh();
        }
    }
}
