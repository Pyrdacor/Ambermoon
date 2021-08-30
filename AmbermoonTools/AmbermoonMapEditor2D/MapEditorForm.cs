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
            if (map != null)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];

                for (int y = 0; y < MapHeight; ++y)
                {
                    for (int x = 0; x < MapWidth; ++x)
                    {
                        var tile = map.Tiles[x, y];
                        var backgroundTile = tile.BackTileIndex == 0 ? null : tileset.Tiles[tile.BackTileIndex - 1];
                        var foregroundTile = tile.FrontTileIndex == 0 ? null : tileset.Tiles[tile.FrontTileIndex - 1];

                        if (backgroundTile != null)
                        {
                            var backgroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, backgroundTile.GraphicIndex - 1, map.PaletteIndex);
                            e.Graphics.DrawImageUnscaledAndClipped(backgroundImage, new Rectangle(x * 16, y * 16, 16, 16));
                        }

                        if (foregroundTile != null)
                        {
                            var foregroundImage = imageCache.GetImage(map.TilesetOrLabdataIndex, foregroundTile.GraphicIndex - 1, map.PaletteIndex);
                            e.Graphics.DrawImageUnscaledAndClipped(foregroundImage, new Rectangle(x * 16, y * 16, 16, 16));
                        }
                    }
                }
            }
        }

        private void panelTileset_Paint(object sender, PaintEventArgs e)
        {
            const int tilesPerRow = 43;

            if (map != null)
            {
                var tileset = tilesets[map.TilesetOrLabdataIndex];
                int x = 0;
                int y = 0;

                using var border = new Pen(Color.Black, 1.0f);

                foreach (var tile in tileset.Tiles)
                {
                    var rect = new Rectangle(x * 16, y * 16, 16, 16);
                    try
                    {
                        var image = imageCache.GetImage(map.TilesetOrLabdataIndex, tile.GraphicIndex - 1, map.PaletteIndex);
                        e.Graphics.DrawImageUnscaledAndClipped(image, rect);
                        e.Graphics.DrawRectangle(border, rect);
                    }
                    catch
                    {
                        // ignore, there seem to be invalid tiles/graphic indices, just skip them
                    }

                    if (++x == tilesPerRow)
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
    }
}
