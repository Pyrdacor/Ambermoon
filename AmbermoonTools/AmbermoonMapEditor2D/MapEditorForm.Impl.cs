using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    partial class MapEditorForm
    {
        IGameData gameData;
        Dictionary<uint, Tileset> tilesets;
        IReadOnlyDictionary<Song, string> songNames;
        ImageCache imageCache;

        Map map;
        int MapWidth => (int)numericUpDownWidth.Value;
        int MapHeight => (int)numericUpDownHeight.Value;
        bool musicPlaying = false;

        void Initialize()
        {
            toolTipIndoor.SetToolTip(radioButtonIndoor, "Indoor maps are always fully lighted.");
            toolTipOutdoor.SetToolTip(radioButtonOutdoor, "Outdoor maps are affected by the day-night-cycle.");
            toolTipDungeon.SetToolTip(radioButtonDungeon, "Dungeons are dark. You'll need your own light source.");

            toolTipWorldSurface.SetToolTip(checkBoxWorldSurface, "On world maps the player is drawn smaller (16x16) and you can use and display transportation.");
            toolTipResting.SetToolTip(checkBoxResting, "Enables the rest/camp functionality on the map.");
            toolTipNoSleepUntilDawn.SetToolTip(checkBoxNoSleepUntilDawn, "If set you will always sleep for 8 hours.");
            toolTipMagic.SetToolTip(checkBoxMagic, "Enables the use of spells on the map.");

            if (gameData.Files.TryGetValue("AM2_CPU", out var asmReader))
            {
                var executableData = new ExecutableData(AmigaExecutable.Read(asmReader.Files[1]));
                songNames = executableData.SongNames.Entries;
            }
            else
            {
                songNames = Enum.GetValues<Song>().Skip(1).Take(32).ToDictionary(song => song, song => song.ToString());
            }

            foreach (var song in songNames)
            {
                comboBoxMusic.Items.Add(song.Value);
            }

            imageCache = new ImageCache(gameData);
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
            comboBoxMusic.SelectedIndex = map.MusicIndex == 0 ? 0 : (int)map.MusicIndex - 1;
        }

        void ToggleMusic()
        {
            if (musicPlaying)
                StopMusic();
            else
                StartMusic();
        }

        void StartMusic()
        {
            musicPlaying = true;
            // TODO
        }

        void StopMusic()
        {
            musicPlaying = false;
            // TODO
        }

        bool AskYesNo(string question)
        {
            return MessageBox.Show(this, question, "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes;
        }

        void MapSizeChanged()
        {

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

        void FillMusicList()
        {

        }

        void FillCharacters()
        {

        }
    }
}
