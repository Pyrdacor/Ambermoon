using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
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
            ColorPicker
        }

        IGameData gameData;
        Dictionary<uint, Tileset> tilesets;
        IReadOnlyDictionary<Song, string> songNames;
        ImageCache imageCache;
        Dictionary<Song, WaveStream> musicCache = new Dictionary<Song, WaveStream>();
        IWavePlayer wavePlayer = new WaveOut();
        Panel mapScrollIndicator = new Panel();
        Panel tilesetScrollIndicator = new Panel();
        const int TilesetTilesPerRow = 43;
        int currentTilesetTiles = 0;
        Tool currentTool = Tool.Brush;
        Tool blocksTool = Tool.Blocks2x2;
        bool showGrid = false;
        int selectedTilesetTile = 0;
        Cursor cursorPointer;
        Cursor cursorColorPicker;
        int tileMarkerWidth = 0;
        int tileMarkerHeight = 0;
        int hoveredMapTile = -1;
        bool showTileMarker = true;

        Map map;
        int MapWidth => (int)numericUpDownWidth.Value;
        int MapHeight => (int)numericUpDownHeight.Value;
        Song? playingSong = null;
        Song? lastSong = null;

        [DllImport("user32.dll")]
        public static extern IntPtr LoadCursorFromFile(string filename);

        void Initialize()
        {
            cursorPointer = CursorResourceLoader.LoadEmbeddedCursor(Properties.Resources.pointer);
            cursorColorPicker = CursorResourceLoader.LoadEmbeddedCursor(Properties.Resources.color_picker);

            toolTipIndoor.SetToolTip(radioButtonIndoor, "Indoor maps are always fully lighted.");
            toolTipOutdoor.SetToolTip(radioButtonOutdoor, "Outdoor maps are affected by the day-night-cycle.");
            toolTipDungeon.SetToolTip(radioButtonDungeon, "Dungeons are dark. You'll need your own light source.");

            toolTipWorldSurface.SetToolTip(checkBoxWorldSurface, "On world maps the player is drawn smaller (16x16) and you can use and display transportation.");
            toolTipResting.SetToolTip(checkBoxResting, "Enables the rest/camp functionality on the map.");
            toolTipNoSleepUntilDawn.SetToolTip(checkBoxNoSleepUntilDawn, "If set you will always sleep for 8 hours.");
            toolTipMagic.SetToolTip(checkBoxMagic, "Enables the use of spells on the map.");

            toolTipBrush.SetToolTip(buttonToolBrush, "Draws single tiles onto the map.");
            toolTipBlocks.SetToolTip(buttonToolBlocks, "Draws blocks of tiles onto the map.\r\n\r\nUse right click on the button to choose a block size.\r\n\r\nUse with right click to use the same tile multiple times. Otherwise it picks adjacent tiles from the tileset.");
            toolTipFill.SetToolTip(buttonToolFill, "Fills all tiles of the same type with a tile from the tileset.\r\n\r\nUse with right click to limit it to an enclosed area.");
            toolTipColorPicker.SetToolTip(buttonToolColorPicker, "Selects a map tile inside the tileset and locks it in for further drawing.");
            toolTipLayers.SetToolTip(buttonToolLayers, "Opens the layers context menu where you can choose which layer to draw to and which layers to show.");
            toolTipGrid.SetToolTip(buttonToggleGrid, "Toggles the tile grid overlay.");
            toolTipTileMarker.SetToolTip(buttonToggleTileMarker, "Toggles the tile selection marker.");

            if (gameData.Files.TryGetValue("AM2_CPU", out var asmReader))
            {
                var executableData = new ExecutableData(AmigaExecutable.Read(asmReader.Files[1]));
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

            mapScrollIndicator.Size = new System.Drawing.Size(1, 1);
            tilesetScrollIndicator.Size = new System.Drawing.Size(1, 1);
            panelMap.Controls.Add(mapScrollIndicator);
            panelTileset.Controls.Add(tilesetScrollIndicator);
            SelectTool(Tool.Brush, true);
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
            this.map = map;

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

            MapSizeChanged();
            TilesetChanged();
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
            mapScrollIndicator.Location = new System.Drawing.Point(map.Width * 16, map.Height * 16);
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
        }

        void TilesetChanged()
        {
            panelTileset.Refresh();
            tilesetScrollIndicator.Location = new System.Drawing.Point((currentTilesetTiles % TilesetTilesPerRow) * 16, (currentTilesetTiles / TilesetTilesPerRow) * 16);
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
    }
}
