using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;
using NAudio.Wave;
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Color = System.Drawing.Color;
using Cursor = System.Windows.Forms.Cursor;
using Cursors = System.Windows.Forms.Cursors;

namespace AmbermoonMapEditor2D
{
    partial class MapEditorForm
    {
        enum Tool
        {
            Brush,
            Blocks2x2,
            Blocks3x2,
            Blocks3x3,
            Fill,
            ColorPicker,
            RemoveFrontLayer
        }

        static readonly string[] LayerName = new string[2]
        {
            "Back Layer",
            "Front Layer"
        };

        IGameData gameData;
        Dictionary<uint, Tileset> tilesets;
        Dictionary<uint, Bitmap> combatBackgrounds = new Dictionary<uint, Bitmap>(16);
        MapManager mapManager;
        IReadOnlyDictionary<Song, string> songNames;
        ImageCache imageCache;
        Dictionary<Song, WaveStream> musicCache = new Dictionary<Song, WaveStream>();
        IWavePlayer wavePlayer = new WaveOut();
        Panel mapScrollIndicator = new Panel();
        Panel tilesetScrollIndicator = new Panel();
        // Note: Every tileset seems to have exactly 2500 tile slots (but many are unused).
        const int TilesetTilesPerRow = 42;
        int currentTilesetTiles = 0;
        Tool currentTool = Tool.Brush;
        Tool blocksTool = Tool.Blocks2x2;
        bool showGrid = false;
        int selectedTilesetTile = 0;
        Cursor cursorPointer;
        Cursor cursorColorPicker;
        Cursor cursorEraser;
        int tileMarkerWidth = 0;
        int tileMarkerHeight = 0;
        int hoveredMapTile = -1;
        int hoveredTilesetTile = -1;
        bool showTileMarker = true;
        int currentLayer = 0;
        bool initialized = false;
        bool unsavedChanges = false;
        bool saveIntoGameData = false;
        string saveFileName = null;
        bool showEvents = false;
        bool mapLoading = false;
        ulong frame = 0;

        History history = new History();
        Map map;
        int MapWidth => map?.Width ?? (int)numericUpDownWidth.Value;
        int MapHeight => map?.Height ?? (int)numericUpDownHeight.Value;
        Song? playingSong = null;
        Song? lastSong = null;

        [DllImport("user32.dll")]
        public static extern IntPtr LoadCursorFromFile(string filename);

        void Initialize()
        {
            if (initialized)
                return;

            initialized = true;

            cursorPointer = CursorResourceLoader.LoadEmbeddedCursor(Properties.Resources.pointer);
            cursorColorPicker = CursorResourceLoader.LoadEmbeddedCursor(Properties.Resources.color_picker);
            cursorEraser = CursorResourceLoader.LoadEmbeddedCursor(Properties.Resources.eraser);

            toolTipIndoor.SetToolTip(radioButtonIndoor, "Indoor maps are always fully lighted.");
            toolTipOutdoor.SetToolTip(radioButtonOutdoor, "Outdoor maps are affected by the day-night-cycle.");
            toolTipDungeon.SetToolTip(radioButtonDungeon, "Dungeons are dark. You'll need your own light source.");

            toolTipWorldSurface.SetToolTip(checkBoxWorldSurface, "On world maps the player is drawn smaller (16x16) and you can use and display transportation.");
            toolTipResting.SetToolTip(checkBoxResting, "Enables the rest/camp functionality on the map.");
            toolTipNoSleepUntilDawn.SetToolTip(checkBoxNoSleepUntilDawn, "If set you will always sleep for 8 hours.");
            toolTipMagic.SetToolTip(checkBoxMagic, "Enables the use of spells on the map.");

            toolTipBrush.SetToolTip(buttonToolBrush, "Draws single tiles onto the map.\r\n\r\nUse with right click to draw to the non-selected layer.");
            toolTipBlocks.SetToolTip(buttonToolBlocks, "Draws blocks of tiles onto the map.\r\n\r\nUse right click on the button to choose a block size.\r\n\r\nUse with right click to use the same tile multiple times. Otherwise it picks adjacent tiles from the tileset.");
            toolTipFill.SetToolTip(buttonToolFill, "Fills all tiles of the same type with a tile from the tileset.\r\n\r\nUse with right click to limit it to an enclosed area.");
            toolTipColorPicker.SetToolTip(buttonToolColorPicker, "Selects a map tile inside the tileset and locks it in for further drawing.\r\n\r\nUse with right click to pick from the non-selected layer instead.");
            toolTipColorPicker.SetToolTip(buttonToolRemoveFrontLayer, "Removes the front layer tile.");
            toolTipLayers.SetToolTip(buttonToolLayers, "Opens the layers context menu where you can choose which layer to draw to and which layers to show.");
            toolTipGrid.SetToolTip(buttonToggleGrid, "Toggles the tile grid overlay.");
            toolTipTileMarker.SetToolTip(buttonToggleTileMarker, "Toggles the tile selection marker.");

            if (gameData.Files.TryGetValue("AM2_CPU", out var asmReader))
            {
                var stream = asmReader.Files[1];
                stream.Position = 0;
                var executableData = new ExecutableData(AmigaExecutable.Read(stream));
                songNames = executableData.SongNames.Entries;
            }
            else
            {
                songNames = Ambermoon.Enum.GetValues<Song>().Skip(1).Take(32).ToDictionary(song => song, song => song.ToString());
            }

            foreach (var song in songNames)
                comboBoxMusic.Items.Add(song.Value);

            // TODO: what if we add one later?
            for (int i = 1; i <= 8; ++i)
                comboBoxTilesets.Items.Add($"Tileset {i}");

            imageCache = new ImageCache(gameData);

            for (int i = 1; i <= imageCache.PaletteCount; ++i)
                comboBoxPalettes.Items.Add($"Palette {i}");

            // TODO: ensure this file
            var combatBackgroundImageFiles = gameData.Files["Combat_background.amb"].Files;
            var combatGraphicInfo = new GraphicInfo
            {
                Alpha = false,
                GraphicFormat = GraphicFormat.Palette5Bit,
                Width = 320,
                Height = 95
            };
            for (int i = 0; i < 16; ++i)
            {
                var combatBackgroundInfo = CombatBackgrounds.Info2D[i];
                var reader = combatBackgroundImageFiles[(int)combatBackgroundInfo.GraphicIndex];
                reader.Position = 0;
                combatBackgrounds.Add((uint)i, imageCache.LoadImage(reader, combatBackgroundInfo.Palettes[0], combatGraphicInfo));
            }

            mapScrollIndicator.Size = new Size(1, 1);
            tilesetScrollIndicator.Size = new Size(1, 1);
            panelMap.Controls.Add(mapScrollIndicator);
            panelTileset.Controls.Add(tilesetScrollIndicator);
            SelectTool(Tool.Brush, true);
            panelTileset.Cursor = CursorFromTool(Tool.Brush);
            timerAnimation.Interval = Globals.TimePerFrame;
        }

        void CleanUp()
        {
            playingSong = null;
            wavePlayer?.Stop();
            wavePlayer?.Dispose();
            wavePlayer = null;
            musicCache.Clear();
        }

        void InitializeMap(Map map)
        {
            timerAnimation.Stop();
            unsavedChanges = false;
            history.Clear();
            this.map = map;
            mapLoading = true;

            numericUpDownWidth.Value = map.Width;
            numericUpDownHeight.Value = map.Height;

            if (map.Flags.HasFlag(MapFlags.Indoor))
                radioButtonIndoor.Checked = true;
            else if (map.Flags.HasFlag(MapFlags.Outdoor))
                radioButtonOutdoor.Checked = true;
            else if (map.Flags.HasFlag(MapFlags.Dungeon))
                radioButtonDungeon.Checked = true;

            checkBoxMagic.Checked = map.Flags.HasFlag(MapFlags.CanUseMagic);
            checkBoxNoSleepUntilDawn.Checked = map.Flags.HasFlag(MapFlags.NoSleepUntilDawn);
            checkBoxResting.Checked = map.Flags.HasFlag(MapFlags.CanRest);
            checkBoxUnknown1.Checked = map.Flags.HasFlag(MapFlags.Unknown1);
            checkBoxTravelGraphics.Checked = map.Flags.HasFlag(MapFlags.StationaryGraphics);
            checkBoxWorldSurface.Checked = map.Flags.HasFlag(MapFlags.WorldSurface);
            comboBoxWorld.SelectedIndex = (int)map.World % 3;
            comboBoxMusic.SelectedIndex = map.MusicIndex == 0 ? (int)Song.PloddingAlong - 1 : (int)map.MusicIndex - 1;
            comboBoxTilesets.SelectedIndex = map.TilesetOrLabdataIndex == 0 ? 0 : (int)map.TilesetOrLabdataIndex - 1;
            comboBoxPalettes.SelectedIndex = map.PaletteIndex == 0 ? 0 : (int)map.PaletteIndex - 1;

            listViewEvents.Items.Clear();
            int index = 1;
            foreach (var @event in map.EventList)
            {
                var item = listViewEvents.Items.Add(index++.ToString("x2"));
                item.SubItems.Add(@event.ToString());
            }

            MapSizeChanged();
            TilesetChanged();
            timerAnimation.Start();

            mapLoading = false;
        }

        void ToggleMusic()
        {
            if (playingSong != null)
                StopMusic();
            else
                StartMusic();
        }

        void StartMusic()
        {
            playingSong = (Song)(comboBoxMusic.SelectedIndex + 1);
            var waveStream = LoadSong(playingSong.Value);
            if (playingSong != lastSong)
                waveStream.Position = 0;
            wavePlayer.Init(waveStream);
            wavePlayer.Play();
            buttonToggleMusic.Image = Properties.Resources.round_stop_black_24;
        }

        void StopMusic()
        {
            lastSong = playingSong;
            playingSong = null;
            wavePlayer.Stop();
            buttonToggleMusic.Image = Properties.Resources.round_play_arrow_black_24;
        }

        WaveStream LoadSong(Song song)
        {
            if (musicCache.TryGetValue(song, out var waveStream))
                return waveStream;

            var sonicArrangerFile = new SonicArranger.SonicArrangerFile(gameData.Files["Music.amb"].Files[(int)song] as DataReader);
            var sonicArrangerSong = new SonicArranger.Stream(sonicArrangerFile, 0, 44100, SonicArranger.Stream.ChannelMode.Mono);
            var stream = new System.IO.MemoryStream();
            sonicArrangerSong.WriteUnsignedTo(stream);
            stream.Position = 0;
            waveStream = new RawSourceWaveStream(stream, WaveFormat.CreateCustomFormat(WaveFormatEncoding.Pcm, 44100, 1, 44100, 1, 8));
            musicCache.Add(song, waveStream);

            return waveStream;
        }

        bool AskYesNo(string question)
        {
            return MessageBox.Show(this, question, "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes;
        }

        void MapSizeChanged()
        {
            mapScrollIndicator.Location = new Point(map.Width * 16, map.Height * 16);

            int visibleColumns = panelMap.Width / 16;
            int visibleRows = panelMap.Height / 16;

            panelMap.HorizontalScroll.Visible = false;
            panelMap.VerticalScroll.Visible = false;

            if (map.Width <= visibleColumns)
            {
                panelMap.HorizontalScroll.Enabled = false;
            }
            else
            {
                panelMap.HorizontalScroll.Maximum = mapScrollIndicator.Location.X;
                panelMap.HorizontalScroll.Enabled = true;
            }

            if (map.Height <= visibleRows)
            {
                panelMap.VerticalScroll.Enabled = false;
            }
            else
            {
                panelMap.VerticalScroll.Maximum = mapScrollIndicator.Location.Y;
                panelMap.VerticalScroll.Enabled = true;
            }

            panelMap.HorizontalScroll.Visible = true;
            panelMap.VerticalScroll.Visible = true;

            panelMap.Refresh();
        }

        void UpdateMapFlags()
        {
            if (mapLoading)
                return;

            map.Flags &= MapFlags.Unknown2; // keep this unknown flag if present

            if (radioButtonIndoor.Checked)
                map.Flags |= MapFlags.Indoor;
            else if (radioButtonOutdoor.Checked)
                map.Flags |= MapFlags.Outdoor;
            else if (radioButtonDungeon.Checked)
                map.Flags |= MapFlags.Dungeon;

            if (checkBoxMagic.Checked)
                map.Flags |= MapFlags.CanUseMagic;
            if (checkBoxResting.Checked)
                map.Flags |= MapFlags.CanRest;
            if (checkBoxUnknown1.Checked)
                map.Flags |= MapFlags.Unknown1;
            if (checkBoxTravelGraphics.Checked)
                map.Flags |= MapFlags.StationaryGraphics;
            if (checkBoxNoSleepUntilDawn.Checked)
                map.Flags |= MapFlags.NoSleepUntilDawn;
            if (checkBoxWorldSurface.Checked)
                map.Flags |= MapFlags.WorldSurface;
        }

        void MapTypeChanged()
        {
            if (radioButtonIndoor.Checked || radioButtonDungeon.Checked)
            {
                checkBoxWorldSurface.Checked = false;
                checkBoxWorldSurface.Enabled = false;
            }
            else
            {
                checkBoxWorldSurface.Enabled = true;
            }

            UpdateMapFlags();
        }

        void TilesetChanged()
        {
            panelTileset.Refresh();
            tilesetScrollIndicator.Location = new Point(TilesetTilesPerRow * 16, ((currentTilesetTiles + TilesetTilesPerRow - 1) / TilesetTilesPerRow) * 16);
        }

        Bitmap ImageFromTool(Tool tool, bool withArrowIfAvailable)
        {
            switch (tool)
            {
                case Tool.Brush:
                    return Properties.Resources.round_brush_black_24;
                case Tool.Blocks2x2:
                    return withArrowIfAvailable
                        ? Properties.Resources.round_grid_view_black_24_with_arrow
                        : Properties.Resources.round_grid_view_black_24;
                case Tool.Blocks3x2:
                    return withArrowIfAvailable
                        ? Properties.Resources.round_view_module_black_24_with_arrow
                        : Properties.Resources.round_view_module_black_24;
                case Tool.Blocks3x3:
                    return withArrowIfAvailable
                        ? Properties.Resources.round_apps_black_24_with_arrow
                        : Properties.Resources.round_apps_black_24;
                case Tool.Fill:
                    return Properties.Resources.round_format_color_fill_black_24;
                case Tool.ColorPicker:
                    return Properties.Resources.round_colorize_black_24;
                case Tool.RemoveFrontLayer:
                    return Properties.Resources.round_layers_clear_black_24;
                default:
                    return null;
            }            
        }

        Button ButtonFromTool(Tool tool)
        {
            switch (tool)
            {
                case Tool.Brush:
                    return buttonToolBrush;
                case Tool.Blocks2x2:
                case Tool.Blocks3x2:
                case Tool.Blocks3x3:
                    return buttonToolBlocks;
                case Tool.Fill:
                    return buttonToolFill;
                case Tool.ColorPicker:
                    return buttonToolColorPicker;
                case Tool.RemoveFrontLayer:
                    return buttonToolRemoveFrontLayer;
                default:
                    return null;
            }
        }

        Cursor CursorFromTool(Tool tool)
        {
            switch (tool)
            {
                case Tool.Brush:
                    return cursorPointer;
                case Tool.Blocks2x2:
                case Tool.Blocks3x2:
                case Tool.Blocks3x3:
                    return cursorPointer;
                case Tool.Fill:
                    return cursorPointer;
                case Tool.ColorPicker:
                    return cursorColorPicker;
                case Tool.RemoveFrontLayer:
                    return cursorEraser;
                default:
                    return null;
            }
        }

        int TileMarkerWidthFromTool(Tool tool)
        {
            switch (tool)
            {
                case Tool.Brush:
                    return 1;
                case Tool.Blocks2x2:
                    return 2;
                case Tool.Blocks3x2:
                case Tool.Blocks3x3:
                    return 3;
                case Tool.Fill:
                    return -1;
                case Tool.ColorPicker:
                    return 1;
                case Tool.RemoveFrontLayer:
                    return 1;
                default:
                    return 0;
            }
        }

        int TileMarkerHeightFromTool(Tool tool)
        {
            switch (tool)
            {
                case Tool.Brush:
                    return 1;
                case Tool.Blocks2x2:
                case Tool.Blocks3x2:
                    return 2;                
                case Tool.Blocks3x3:
                    return 3;
                case Tool.Fill:
                    return -1;
                case Tool.ColorPicker:
                    return 1;
                case Tool.RemoveFrontLayer:
                    return 1;
                default:
                    return 0;
            }
        }

        void SelectTool(Tool tool, bool force = false)
        {
            if (!force && currentTool == tool)
                return;

            var button = ButtonFromTool(currentTool);

            if (button != null)
                SetButtonActive(button, false);

            currentTool = tool;
            toolStripStatusLabelTool.Image = ImageFromTool(tool, false);
            button = ButtonFromTool(currentTool);
            var cursor = CursorFromTool(currentTool);
            tileMarkerWidth = TileMarkerWidthFromTool(currentTool);
            tileMarkerHeight = TileMarkerHeightFromTool(currentTool);
            panelMap.Refresh();

            if (button != null)
                SetButtonActive(button, true);

            panelMap.Cursor = cursor == null ? Cursors.Arrow : cursor;
        }

        void SetButtonActive(Button button, bool active)
        {
            button.UseVisualStyleBackColor = false;
            button.BackColor = Color.FromArgb(0x30, active ? Color.Lime : SystemColors.Control);
        }

        void FillCharacters()
        {

        }

        void UseTool(int x, int y, bool secondaryFunction)
        {
            switch (currentTool)
            {
                case Tool.Brush:
                    SetTiles(x, y, 1, 1, secondaryFunction ? 1 - currentLayer : currentLayer);
                    break;
                case Tool.Blocks2x2:
                    SetTiles(x, y, 2, 2, currentLayer, secondaryFunction);
                    break;
                case Tool.Blocks3x2:
                    SetTiles(x, y, 3, 2, currentLayer, secondaryFunction);
                    break;
                case Tool.Blocks3x3:
                    SetTiles(x, y, 3, 3, currentLayer, secondaryFunction);
                    break;
                case Tool.ColorPicker:
                    PickTile(x, y, secondaryFunction ? 1 - currentLayer : currentLayer);
                    break;
                case Tool.Fill:
                    FillTiles(x, y, secondaryFunction);
                    break;
                case Tool.RemoveFrontLayer:
                    RemoveFrontTile(x, y);
                    break;
            }
        }

        void PerformAction(string displayName, string undoDisplayName, Action<bool> doAction, Action undoAction)
        {
            history.DoAction(new History.DefaultAction(displayName, undoDisplayName, doAction, undoAction));
        }

        void SetTiles(int x, int y, int w, int h, int layer, bool useSameTile = false)
        {
            if (w < 1)
                w = 1;
            if (h < 1)
                h = 1;
            if (layer < 0)
                layer = 0;
            else if (layer > 1)
                layer = 1;

            var currentTiles = new List<uint>(9);
            bool hasChange = false;
            int tile = 1 + selectedTilesetTile;
            int checkTile = tile;
            for (int ty = 0; ty < h; ++ty)
            {
                int totalY = y + ty;

                if (totalY >= map.Height)
                    break;

                for (int tx = 0; tx < w; ++tx)
                {
                    int totalX = x + tx;

                    if (totalX >= map.Width)
                        continue;

                    var mapTile = map.InitialTiles[totalX, totalY];
                    uint tileIndex = layer == 0 ? mapTile.BackTileIndex : mapTile.FrontTileIndex;
                    currentTiles.Add(tileIndex);

                    if (tileIndex != checkTile)
                        hasChange = true;

                    if (!useSameTile)
                        ++checkTile;
                }
            }

            if (!hasChange)
                return;

            string doText = w == 1 && h == 1
                ? $"Change tile at {x},{y} on {LayerName[layer]} to tile {tile}"
                : useSameTile
                    ? $"Change tiles from {x},{y} to {x + w - 1},{y + h - 1} on {LayerName[layer]} to tile {tile}"
                    : $"Change tiles from {x},{y} to {x + w - 1},{y + h - 1} on {LayerName[layer]} to tiles {tile} to {tile + (w-1)*(h-1)}";
            bool sameUndoTile = currentTiles.GroupBy(t => t).Count() == 1;
            string undoText = w == 1 && h == 1
                ? $"Change tile at {x},{y} on {LayerName[layer]} to tile {(currentTiles[0] == 0 ? "empty" : (currentTiles[0] - 1).ToString())}"
                : sameUndoTile
                    ? $"Change tiles from {x},{y} to {x + w - 1},{y + h - 1} on {LayerName[layer]} to tile {(currentTiles[0] == 0 ? "empty" : (currentTiles[0] - 1).ToString())}"
                    : $"Change tiles from {x},{y} to {x + w - 1},{y + h - 1} on {LayerName[layer]} to tiles [{string.Join(",", currentTiles.Select(t => t == 0 ? "empty" : (t - 1).ToString()))}]";

            PerformAction(doText, undoText,
                _ =>
                {
                    for (int ty = 0; ty < h; ++ty)
                    {
                        int totalY = y + ty;

                        if (totalY >= map.Height)
                            break;

                        for (int tx = 0; tx < w; ++tx)
                        {
                            int totalX = x + tx;

                            if (totalX >= map.Width)
                                continue;

                            var mapTile = map.InitialTiles[totalX, totalY];

                            if (layer == 0)
                                mapTile.BackTileIndex = (uint)tile;
                            else
                                mapTile.FrontTileIndex = (uint)tile;

                            if (!useSameTile)
                                ++tile;
                        }
                    }

                    panelMap.Refresh();
                },
                () =>
                {
                    int listIndex = 0;
                    for (int ty = 0; ty < h; ++ty)
                    {
                        int totalY = y + ty;

                        if (totalY >= map.Height)
                            break;

                        for (int tx = 0; tx < w; ++tx)
                        {
                            int totalX = x + tx;

                            if (totalX >= map.Width)
                                continue;

                            var mapTile = map.InitialTiles[totalX, totalY];

                            if (layer == 0)
                                mapTile.BackTileIndex = currentTiles[listIndex++];
                            else
                                mapTile.FrontTileIndex = currentTiles[listIndex++];
                        }
                    }

                    panelMap.Refresh();
                }
            );
        }

        void FillTiles(int x, int y, bool areaOnly)
        {
            // TODO
            NotImplemented();
        }

        void PickTile(int x, int y, int layer)
        {
            var tile = map.InitialTiles[x, y];
            uint tileIndex = layer == 0 ? tile.BackTileIndex : tile.FrontTileIndex;

            if (tileIndex == 0)
                SelectTool(Tool.RemoveFrontLayer);
            else
            {
                selectedTilesetTile = (int)tileIndex - 1;
                panelTileset.Refresh();
                SelectTool(Tool.Brush);
            }
        }

        void RemoveFrontTile(int x, int y)
        {
            if (map.InitialTiles[x, y].FrontTileIndex == 0)
                return;

            uint oldTileIndex = map.InitialTiles[x, y].FrontTileIndex;

            void SetTile(uint tileIndex)
            {
                map.InitialTiles[x, y].FrontTileIndex = tileIndex;
                panelMap.Refresh();
            }

            PerformAction($"Delete front tile at {x},{y}", $"Set front tile at {x},{y} to {oldTileIndex}",
                _ => SetTile(0), () => SetTile(oldTileIndex));
        }

        void NotImplemented() => MessageBox.Show(this, "Not implemented yet", "Not implemented", MessageBoxButtons.OK, MessageBoxIcon.Information);

        bool Save()
        {
            if (saveFileName == null)
                return SaveAs();

            if (saveIntoGameData)
                return SaveToGameData();
            else
                return SaveToFile(saveFileName);
        }

        bool SaveAs()
        {
            if (MessageBox.Show(this, "Do you want to save back to the game data (Yes) or to an external file (No)?",
                "Save target", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No)
            {
                return SaveToFile(null, saveFileName);
            }
            else
            {
                return SaveToGameData();
            }
        }

        bool SaveToFile(string fileName, string suggestedFileName = null)
        {
            if (string.IsNullOrWhiteSpace(fileName))
            {
                var dialog = new SaveFileDialog();
                dialog.AddExtension = false;
                dialog.AutoUpgradeEnabled = true;
                dialog.CheckFileExists = false;
                dialog.CheckPathExists = false;
                dialog.CreatePrompt = false;
                dialog.FileName = suggestedFileName ?? "";
                dialog.Filter = "All files (*.*)|*.*";
                dialog.OverwritePrompt = true;
                dialog.RestoreDirectory = true;
                dialog.Title = "Save map";

                if (dialog.ShowDialog() != DialogResult.OK)
                    return false;

                fileName = dialog.FileName;
            }

            var mapWriter = new MapWriter();
            var dataWriter = new DataWriter();
            mapWriter.WriteMap(map, dataWriter);

            try
            {
                System.IO.File.WriteAllBytes(fileName, dataWriter.ToArray());
                saveFileName = fileName;
                return true;
            }
            catch
            {
                return false;
            }
        }

        bool SaveToGameData()
        {
            // TODO
            NotImplemented();
            return false;
        }
    }
}
