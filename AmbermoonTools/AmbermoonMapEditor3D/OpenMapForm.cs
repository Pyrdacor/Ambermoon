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

namespace AmbermoonMapEditor3D
{
    public partial class OpenMapForm : Form
    {
        public OpenMapForm(IGameData gameData, MapManager mapManager)
        {
            GameData = gameData;
            MapManager = mapManager;
            InitializeComponent();
        }

        internal IGameData GameData { get; private set; }
        internal Map Map { get; private set; }
        internal MapManager MapManager { get; private set; }

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

            const int initialWidth = 20;
            const int initialHeight = 20;

            Map.Type = MapType.Map3D;
            Map.Width = initialWidth;
            Map.Height = initialHeight;
            Map.InitialBlocks = new Map.Block[initialWidth, initialHeight];
            Map.TilesetOrLabdataIndex = 1;
            Map.PaletteIndex = 6;
            Map.World = (World)comboBoxWorld.SelectedIndex;

            for (int y = 0; y < initialHeight; ++y)
            {
                for (int x = 0; x < initialWidth; ++x)
                {
                    var block = Map.InitialBlocks[x, y] = new Map.Block();

                    if (x == 0 || x == initialWidth - 1 || y == 0 || y == initialHeight - 1)
                        block.MapBorder = true;
                    else if (x == 1 || x == initialWidth - 2 || y == 1 || y == initialHeight - 2)
                        block.WallIndex = 1;
                    else
                        block.WallIndex = 0;
                }
            }

            if (radioButtonIndoor.Checked)
            {
                Map.Flags = MapFlags.Indoor | MapFlags.CanUseMagic | MapFlags.Automapper;
                Map.MusicIndex = (uint)Song.TheAumRemainsTheSame;
            }
            else if (radioButtonOutdoor.Checked)
            {
                Map.Flags = MapFlags.Outdoor | MapFlags.CanRest | MapFlags.CanUseMagic | MapFlags.Automapper | MapFlags.Sky;
                Map.MusicIndex = (uint)Song.Capital;
                Map.LabyrinthBackgroundIndex = (uint)Map.World;
            }
            else // Dungeon
            {
                Map.Flags = MapFlags.Dungeon | MapFlags.CanRest | MapFlags.NoSleepUntilDawn | MapFlags.CanUseMagic | MapFlags.Automapper;
                Map.MusicIndex = (uint)Song.DragonChaseInCreepyDungeon;
            }

            DialogResult = DialogResult.OK;
        }

        private void buttonOpenMap_Click(object sender, EventArgs e)
        {
            Map = null;

            if (MessageBox.Show(this, "Do you want to load the map from the already loaded game data?", "Where to load the map from?", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                if (!AskForMapIndex(out var mapIndex, MapManager.Maps.Where(map => map.Type == MapType.Map3D).OrderBy(map => map.Index).ToDictionary(map => map.Index, map => map.Name)))
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
                if (Map.Type == MapType.Map2D)
                {
                    Map = null;
                    MessageBox.Show(this, "The chosen map is 2D and cannot be loaded with this editor.", "Wrong map type", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
                var container = new FileReader().ReadFile(Path.GetFileName(filename), reader);

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
                    return Map.Load(mapIndex, new MapReader(), container.Files[(int)mapIndex], textDataReader, new Dictionary<uint, Tileset>());
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), container.Files[(int)mapIndex], new Dictionary<uint, Tileset>());
                    map.Texts.Clear();
                    if (texts != null)
                        map.Texts.AddRange(texts);
                    return map;
                }
            }
            // LOB, VOL1 or JH
            else if (header == 0x014c4f42 || header == 0x564f4c31 || (header & 0xffff0000) == 0x4a480000)
            {
                var container = new FileReader().ReadFile(Path.GetFileName(filename), reader);

                if (mapIndex == 0 && !AskForMapIndex(out mapIndex))
                    return null;

                if (!AskForMapTexts(mapIndex, out var textDataReader, out var texts))
                    texts = null;

                if (textDataReader != null)
                    return Map.Load(mapIndex, new MapReader(), container.Files[1], textDataReader, new Dictionary<uint, Tileset>());
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), container.Files[1], new Dictionary<uint, Tileset>());
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
                    return Map.Load(mapIndex, new MapReader(), reader, textDataReader, new Dictionary<uint, Tileset>());
                else
                {
                    var map = Map.LoadWithoutTexts(mapIndex, new MapReader(), reader, new Dictionary<uint, Tileset>());
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
                var container = new FileReader().ReadFile("", reader);

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
                var container = new FileReader().ReadFile("", reader);
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

            if (GameData != null)
            {
                if (MapManager == null)
                    MapManager = new MapManager(GameData as ILegacyGameData, new MapReader(), new TilesetReader(), new LabdataReader(), true);
            }

            BringToFront();
        }
    }
}
