using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

namespace Ambermoon3DMapEditor
{
    internal partial class AssetForm : Form
    {
        public AssetForm(List<Bitmap> wallTextures, List<List<Bitmap>> objectTextures,
            List<Labdata.WallData> walls, List<Labdata.Object> objects, Palette palette,
            Dictionary<uint, Bitmap> allWallTextures, Dictionary<uint, Bitmap> allObjectTextures, Dictionary<uint, Bitmap> allOverlayTextures)
        {
            InitializeComponent();

            this.wallTextures = wallTextures;
            this.objectTextures = objectTextures;
            this.walls = walls;
            this.objects = objects;
            this.palette = palette;
            this.allWallTextures = allWallTextures;
            this.allObjectTextures = allObjectTextures;
            this.allOverlayTextures = allOverlayTextures;
        }

        private readonly List<Bitmap> wallTextures;
        private readonly List<List<Bitmap>> objectTextures;
        private readonly List<Labdata.WallData> walls;
        private readonly List<Labdata.Object> objects;
        private readonly Dictionary<uint, Bitmap> allWallTextures;
        private readonly Dictionary<uint, Bitmap> allObjectTextures;
        private readonly Dictionary<uint, Bitmap> allOverlayTextures;
        private readonly Palette palette;
        private bool ignoreTravelStateChange = false;

        private delegate void ActionRef<T>(ref T item);

        private void UpdateWall(ActionRef<Labdata.WallData> wallUpdater)
        {
            int selectedIndex = comboBoxWalls.SelectedIndex;

            if (selectedIndex == -1)
                return;

            var wall = walls[selectedIndex];
            wallUpdater(ref wall);
            walls[selectedIndex] = wall;
        }

        private void UpdateWallFlag(Tileset.TileFlags flag, bool set)
        {
            UpdateWall((ref Labdata.WallData wall) =>
            {
                if (set)
                    wall.Flags |= flag;
                else
                    wall.Flags &= ~flag;
            });
        }

        private void buttonTextures_Click(object sender, EventArgs e)
        {
            int selectedIndex = comboBoxWalls.SelectedIndex;

            if (selectedIndex != -1)
                selectedIndex = (int)walls[selectedIndex].TextureIndex;
            else
                selectedIndex = 0;

            var textureBrowser = new TextureBrowser(allWallTextures, (uint)selectedIndex);

            /*if (*/
            textureBrowser.ShowDialog(this)/* == DialogResult.OK)*/;
            {
                UpdateWall((ref Labdata.WallData wall) => wall.TextureIndex = textureBrowser.SelectedIndex);
                wallTextures[comboBoxWalls.SelectedIndex] = allWallTextures[textureBrowser.SelectedIndex];
                panelWallTexture.Refresh();
            }
        }

        private void buttonOverlays_Click(object sender, EventArgs e)
        {

        }

        private void buttonAddWall_Click(object sender, EventArgs e)
        {

        }

        private void buttonDeleteWall_Click(object sender, EventArgs e)
        {

        }

        private void buttonDuplicateWall_Click(object sender, EventArgs e)
        {

        }

        private void comboBoxWalls_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedIndex = comboBoxWalls.SelectedIndex;
            var wall = walls[selectedIndex];

            comboBoxWallAutomapType.SelectedIndex = (int)wall.AutomapType;
            checkBoxWallBlockAll.Checked = wall.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement);
            checkBoxWallBlockSight.Checked = wall.Flags.HasFlag(Tileset.TileFlags.BlockSight);
            checkBoxWallTransparency.Checked = wall.Flags.HasFlag(Tileset.TileFlags.Transparency);

            if (!checkBoxWallBlockAll.Checked)
            {
                int mask = 1 << (comboBoxWallTravelClass.SelectedIndex + 8);
                comboBoxWallTravelStates.SelectedIndex = ((int)wall.Flags & mask) != 0 ? 1 : 0;
            }
            else
            {
                comboBoxWallTravelClass_SelectedIndexChanged(comboBoxWallTravelClass, EventArgs.Empty);
            }

            buttonLeftWall.Enabled = comboBoxWalls.Items.Count != 0 && selectedIndex > 0;
            buttonRightWall.Enabled = comboBoxWalls.Items.Count != 0 && selectedIndex < comboBoxWalls.Items.Count - 1;
            panelWallTexture.Refresh();
            panelWallColor.Refresh();
        }

        private void checkBoxWallTransparency_CheckedChanged(object sender, EventArgs e)
        {
            UpdateWallFlag(Tileset.TileFlags.Transparency, checkBoxWallTransparency.Checked);
            panelWallTexture.Refresh();
        }

        private void AssetForm_Load(object sender, EventArgs e)
        {
            comboBoxWallAutomapType.Items.AddRange(Enum.GetNames(typeof(AutomapType)));
            comboBoxWallAutomapType.SelectedIndex = 0;

            comboBoxWallTravelClass.Items.Add("Player");
            comboBoxWallTravelClass.Items.AddRange(Enumerable.Range(1, 14).Select(i => $"Monsters {i}").ToArray());
            comboBoxWallTravelClass.SelectedIndex = 0;

            comboBoxWallTravelStates.SelectedIndex = 0;

            checkBoxWallBlockAll.Checked = true;

            comboBoxWalls.Items.AddRange(walls.Select((_, i) => $"Wall {i}").ToArray());
            comboBoxWalls.SelectedIndex = 0;
        }

        private void comboBoxWallTravelClass_SelectedIndexChanged(object sender, EventArgs e)
        {
            int selectedIndex = comboBoxWalls.SelectedIndex;

            if (selectedIndex == -1)
                return;

            var wall = walls[selectedIndex];
            int mask = 1 << (comboBoxWallTravelClass.SelectedIndex + 8);
            ignoreTravelStateChange = true;
            comboBoxWallTravelStates.SelectedIndex = ((int)wall.Flags & mask) != 0 ? 1 : 0;
            ignoreTravelStateChange = false;
        }

        private void comboBoxWallTravelStates_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ignoreTravelStateChange)
                return;

            UpdateWall((ref Labdata.WallData wall) =>
            {
                uint mask = 1u << (comboBoxWallTravelClass.SelectedIndex + 8);

                if (comboBoxWallTravelStates.SelectedIndex == 1)
                    wall.Flags = (Tileset.TileFlags)((uint)wall.Flags | mask);
                else
                    wall.Flags = (Tileset.TileFlags)((uint)wall.Flags & ~mask);
            });
        }

        private void checkBoxBlockAll_CheckedChanged(object sender, EventArgs e)
        {
            comboBoxWallTravelClass.Enabled = !checkBoxWallBlockAll.Checked;
            comboBoxWallTravelStates.Enabled = !checkBoxWallBlockAll.Checked;
            UpdateWallFlag(Tileset.TileFlags.BlockAllMovement, checkBoxWallBlockAll.Checked);
        }

        private void panelWallTexture_Paint(object sender, PaintEventArgs e)
        {
            using var image = (Bitmap)wallTextures[comboBoxWalls.SelectedIndex].Clone();
            if (checkBoxWallTransparency.Checked)
                image.MakeTransparent(palette.Colors[0]);
            e.Graphics.DrawImage(image, 0, 0, image.Width * 2, image.Height * 2);
        }

        private void panelWallColor_Paint(object sender, PaintEventArgs e)
        {
            using var colorBrush = new SolidBrush(palette.Colors[walls[comboBoxWalls.SelectedIndex].ColorIndex]);
            e.Graphics.FillRectangle(colorBrush, panelWallColor.ClientRectangle);
        }

        private void panelWallColor_Click(object sender, EventArgs e)
        {
            var colorPicker = new ColorPickerForm(palette, 16, 0, palette.Colors[walls[comboBoxWalls.SelectedIndex].ColorIndex]);

            if (colorPicker.ShowDialog() == DialogResult.OK)
            {
                UpdateWall((ref Labdata.WallData wall) => wall.ColorIndex = (byte)palette.Colors.ToList().IndexOf(colorPicker!.Color));
                panelWallColor.Refresh();
            }
        }

        private void buttonLeftWall_Click(object sender, EventArgs e)
        {
            comboBoxWalls.SelectedIndex--;
        }

        private void buttonRightWall_Click(object sender, EventArgs e)
        {
            comboBoxWalls.SelectedIndex++;
        }

        private void checkBoxWallBlockSight_CheckedChanged(object sender, EventArgs e)
        {
            UpdateWallFlag(Tileset.TileFlags.BlockSight, checkBoxWallBlockSight.Checked);
        }

        private void comboBoxWallAutomapType_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateWall((ref Labdata.WallData wall) => wall.AutomapType = (AutomapType)comboBoxWallAutomapType.SelectedIndex);
        }
    }
}
