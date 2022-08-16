using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class OpenMapForm : Form
    {
        public OpenMapForm(string gameDataPath, ILegacyGameData gameData, Dictionary<uint, Tileset> tilesets, MapManager mapManager)
        {
            GameDataPath = gameDataPath;
            GameData = gameData;
            Tilesets = tilesets;
            MapManager = mapManager;
            InitializeComponent();
        }

        internal string GameDataPath { get; private set; }
        internal ILegacyGameData GameData { get; private set; }
        internal Dictionary<uint, Tileset> Tilesets { get; private set; }
        internal Map Map { get; private set; }
        internal MapManager MapManager { get; private set; }

        ILegacyGameData LoadGameData()
        {
            var dialog = new FolderBrowserDialog();

            dialog.AutoUpgradeEnabled = true;
            dialog.Description = "Where is your Ambermoon data folder (i.e. Amberfiles)?";
            dialog.ShowNewFolderButton = false;
            dialog.UseDescriptionForTitle = true;

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                string gameDataPath = dialog.SelectedPath;
                var gameData = new GameData(Ambermoon.Data.Legacy.GameData.LoadPreference.PreferExtracted, null, false);
                gameData.Load(dialog.SelectedPath);

                bool CheckFile(string file, string name)
                {
                    if (!gameData.Files.ContainsKey(file))
                    {
                        MessageBox.Show($"No {name} ({file}) could be found at the given path.", $"Error loading {name}", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        DialogResult = DialogResult.Cancel;
                        return false;
                    }

                    return true;
                }

                if (!CheckFile("Icon_data.amb", "tilesets"))
                    return null;

                if (!CheckFile("1Icon_gfx.amb", "tile graphics"))
                    return null;

                if (!CheckFile("2Icon_gfx.amb", "tile graphics"))
                    return null;

                if (!CheckFile("3Icon_gfx.amb", "tile graphics"))
                    return null;

                if (!CheckFile("Palettes.amb", "palettes"))
                    return null;

                BringToFront();

                GameDataPath = gameDataPath;

                return gameData;
            }
            else
            {
                DialogResult = DialogResult.Cancel;
                return null;
            }
        }

        private void buttonCreateMap_Click(object sender, EventArgs e)
        {
            if (!AskForMapIndex(out var mapIndex, null))
                return;

            if (MapManager.Maps.Any(m => m.Index == mapIndex))
            {
                MessageBox.Show(this, $"Map {mapIndex} already exists.", "Map already exists", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            Map = new Map();

            const int initialWidth = 50;
            const int initialHeight = 50;

            Map.Type = MapType.Map2D;
            Map.Width = initialWidth;
            Map.Height = initialHeight;
            Map.InitialTiles = new Map.Tile[initialWidth, initialHeight];
            Map.Tiles = new Map.Tile[initialWidth, initialHeight];
            Map.TilesetOrLabdataIndex = 1;
            Map.PaletteIndex = 1;
            Map.World = (World)comboBoxWorld.SelectedIndex;

            for (int y = 0; y < initialHeight; ++y)
            {
                for (int x = 0; x < initialWidth; ++x)
                {
                    Map.InitialTiles[x, y] = new Map.Tile
                    {
                        BackTileIndex = 1
                    };
                    Map.Tiles[x, y] = new Map.Tile
                    {
                        BackTileIndex = 1
                    };
                }
            }

            if (radioButtonIndoor.Checked)
            {
                Map.Flags = MapFlags.Indoor | MapFlags.CanUseMagic;
                Map.MusicIndex = (uint)Song.DontLookBach;
                Map.NPCGfxIndex = 1 + (uint)comboBoxWorld.SelectedIndex % 2;
            }
            else if (radioButtonWorldMap.Checked)
            {
                Map.Flags = MapFlags.Outdoor | MapFlags.WorldSurface |  MapFlags.StationaryGraphics | MapFlags.Unknown1 | MapFlags.CanRest | MapFlags.CanUseMagic;
                Map.MusicIndex = (uint)Song.PloddingAlong;
                Map.NPCGfxIndex = 0;
            }
            else // Dungeon
            {
                Map.Flags = MapFlags.Dungeon | MapFlags.CanRest | MapFlags.NoSleepUntilDawn | MapFlags.CanUseMagic;
                Map.MusicIndex = (uint)Song.SapphireFireballsOfPureLove;
                Map.NPCGfxIndex = 1 + (uint)comboBoxWorld.SelectedIndex % 2;
            }

            DialogResult = DialogResult.OK;
        }

        private void buttonOpenMap_Click(object sender, EventArgs e)
        {
            Map = null;

            if (MessageBox.Show(this, "Do you want to load the map from the already loaded game data?", "Where to load the map from?", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                if (!AskForMapIndex(out var mapIndex, MapManager.Maps.Where(map => map.Type == MapType.Map2D).OrderBy(map => map.Index).ToDictionary(map => map.Index, map => map.Name)))
                    return;
                
                Map = MapManager.GetMap(mapIndex);

                if (Map == null)
                    MessageBox.Show(this, $"Map {mapIndex} does not exist.", "Map not found", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
            {
                var dialog = new OpenFileDialog();

                dialog.AddExtension = false;
                dialog.AutoUpgradeEnabled = true;
                dialog.CheckFileExists = true;
                dialog.CheckPathExists = true;
                dialog.Filter = "All files (*.*)|*.*";
                dialog.Multiselect = false;
                dialog.RestoreDirectory = true;
                dialog.Title = "Open Ambermoon map";

                if (dialog.ShowDialog() == DialogResult.OK)
                    Map = LoadFromFile(dialog.FileName);
            }

            if (Map != null)
            {
                if (Map.Type == MapType.Map3D)
                {
                    Map = null;
                    MessageBox.Show(this, "The chosen map is 3D and cannot be loaded with this editor.", "Wrong map type", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                else
                    DialogResult = DialogResult.OK;
            }
        }

        Map LoadFromFile(string filename)
        {
            var reader = new DataReader(File.ReadAllBytes(filename));

            var header = reader.PeekDword();

            uint mapIndex = 0;
            var filenameMatch = Regex.Match(Path.GetFileName(filename), "^([0-9]+)($|\\.).*");

            if (filenameMatch.Success)
            {
                mapIndex = uint.Parse(filenameMatch.Groups[1].Value);

                if (mapIndex != 0 && MessageBox.Show(this, $"Map index was automatically guessed as {mapIndex}. Is that correct?",
                    "Map index suggestion", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.No)
                    mapIndex = 0;
            }

            // AMNP, AMBR, AMNC, AMPC
            if (header == 0x414D4E50 || header == 0x414D4252 ||
                header == 0x414d4e43 || header == 0x414d5043)
            {
                var container = new FileReader().ReadRawFile(Path.GetFileName(filename), reader.ReadToEnd());

                if (mapIndex == 0 && !AskForMapIndex(out mapIndex, container.Files.Keys.ToDictionary(k => (uint)k, _ => (string)null)))
                    return null;

                if (!container.Files.ContainsKey((int)mapIndex))
                {
                    MessageBox.Show(this, $"Map {mapIndex} does not exist.", "Map not found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return null;
                }

                if (!AskForMapTexts(mapIndex, out var textDataReader, out var texts))
                    texts = null;

                if (textDataReader != null)
                    return Map.Load(mapIndex, new MapReader(), container.Files[(int)mapIndex], textDataReader, Tilesets);
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), container.Files[(int)mapIndex], Tilesets);
                    map.Texts.Clear();
                    if (texts != null)
                        map.Texts.AddRange(texts);
                    return map;
                }
            }
            // LOB, VOL1 or JH
            else if (header == 0x014c4f42 || header == 0x564f4c31 || (header & 0xffff0000) == 0x4a480000)
            {
                var container = new FileReader().ReadRawFile(Path.GetFileName(filename), reader.ReadToEnd());

                if (mapIndex == 0 && !AskForMapIndex(out mapIndex))
                    return null;

                if (!AskForMapTexts(mapIndex, out var textDataReader, out var texts))
                    texts = null;

                if (textDataReader != null)
                    return Map.Load(mapIndex, new MapReader(), container.Files[1], textDataReader, Tilesets);
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), container.Files[1], Tilesets);
                    map.Texts.Clear();
                    if (texts != null)
                        map.Texts.AddRange(texts);
                    return map;
                }
            }
            else // Raw map file
            {
                if (mapIndex == 0 && !AskForMapIndex(out mapIndex))
                    return null;

                if (!AskForMapTexts(mapIndex, out var textDataReader, out var texts))
                    texts = null;

                if (textDataReader != null)
                    return Map.Load(mapIndex, new MapReader(), reader, textDataReader, Tilesets);
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), reader, Tilesets);
                    map.Texts.Clear();
                    if (texts != null)
                        map.Texts.AddRange(texts);
                    return map;
                }
            }

            bool AskForMapTexts(uint mapIndex, out IDataReader textDataReader, out List<string> texts)
            {
                textDataReader = null;
                texts = null;
                var map = MapManager.GetMap(mapIndex);

                if (map != null)
                {
                    if (MessageBox.Show(this, "Do you want to load the map texts from the already loaded game data?", "Where to load the map texts from?", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                    {
                        texts = map.Texts;
                        return true;
                    }
                }

                var dialog = new OpenFileDialog();

                dialog.AddExtension = false;
                dialog.AutoUpgradeEnabled = true;
                dialog.CheckFileExists = true;
                dialog.CheckPathExists = true;
                dialog.Filter = "All files (*.*)|*.*";
                dialog.Multiselect = false;
                dialog.RestoreDirectory = true;
                dialog.Title = "Open Ambermoon map texts";

                if (dialog.ShowDialog() == DialogResult.OK)
                {
                    textDataReader = GetTextDataReader(new DataReader(File.ReadAllBytes(dialog.FileName)), mapIndex);

                    if (textDataReader != null)
                        return true;
                }

                textDataReader = null;
                return false;
            }
        }

        IDataReader GetTextDataReader(IDataReader reader, uint mapIndex)
        {
            var header = reader.PeekDword();

            // AMNP, AMBR, AMNC, AMPC
            if (header == 0x414D4E50 || header == 0x414D4252 ||
                header == 0x414d4e43 || header == 0x414d5043)
            {
                var container = new FileReader().ReadRawFile("", reader.ReadToEnd());

                if (!container.Files.TryGetValue((int)mapIndex, out var textReader))
                {
                    MessageBox.Show(this, $"Texts for map {mapIndex} do not exist.", "Map texts not found", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return null;
                }

                return textReader;
            }
            // LOB, VOL1 or JH
            else if (header == 0x014c4f42 || header == 0x564f4c31 || (header & 0xffff0000) == 0x4a480000)
            {
                var container = new FileReader().ReadRawFile("", reader.ReadToEnd());
                return container.Files[1];
            }
            else // Raw file
            {
                return reader;
            }
        }

        bool AskForMapIndex(out uint mapIndex, Dictionary<uint, string> mapIndices = null)
        {
            var mapIndexForm = new MapIndexForm(mapIndices);

            if (mapIndexForm.ShowDialog(this) == DialogResult.OK)
            {
                Refresh();
                mapIndex = mapIndexForm.MapIndex;
                return true;
            }

            Refresh();
            mapIndex = 0;
            return false;
        }

        private void OpenMapForm_Load(object sender, EventArgs e)
        {
            comboBoxWorld.SelectedIndex = 0;
            BringToFront();

            if (GameData == null)
                GameData = LoadGameData();

            if (GameData != null)
            {
                if (MapManager == null)
                    MapManager = new MapManager(GameData, new MapReader(), new TilesetReader(), new LabdataReader());

                if (Tilesets == null)
                {
                    Tilesets = new Dictionary<uint, Tileset>();
                    var tilesetReader = new TilesetReader();
                    foreach (var tilesetFile in GameData.Files["Icon_data.amb"].Files)
                    {
                        var tileset = Tileset.Load(tilesetReader, tilesetFile.Value);
                        Tilesets.Add((uint)tilesetFile.Key, tileset);
                        tileset.Index = (uint)tilesetFile.Key;
                    }
                }
            }

            BringToFront();
        }
    }
}
