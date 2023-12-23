using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

namespace Ambermoon3DMapEditor
{
    internal partial class AssetForm : Form
    {
        public AssetForm(List<Bitmap> wallTextures, List<List<Bitmap>> objectTextures,
            List<Labdata.WallData> walls, List<Labdata.Object> objects, Palette palette)
        {
            InitializeComponent();

            this.wallTextures = wallTextures;
            this.objectTextures = objectTextures;
            this.walls = walls;
            this.objects = objects;
            this.palette = palette;
        }

        private readonly List<Bitmap> wallTextures;
        private readonly List<List<Bitmap>> objectTextures;
        private readonly List<Labdata.WallData> walls;
        private readonly List<Labdata.Object> objects;
        private readonly Palette palette;

        private void buttonTextures_Click(object sender, EventArgs e)
        {
            new TextureBrowser(wallTextures).ShowDialog(this);
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

            comboBoxWallAutomapType.SelectedIndex = (int)walls[selectedIndex].AutomapType;

            buttonLeftWall.Enabled = comboBoxWalls.Items.Count != 0 && selectedIndex > 0;
            buttonRightWall.Enabled = comboBoxWalls.Items.Count != 0 && selectedIndex < comboBoxWalls.Items.Count - 1;
            panelWallTexture.Refresh();
            panelWallColor.Refresh();
        }

        private void checkBoxWallTransparency_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void AssetForm_Load(object sender, EventArgs e)
        {
            comboBoxWallAutomapType.Items.AddRange(Enum.GetNames(typeof(AutomapType)));
            comboBoxWallAutomapType.SelectedIndex = 0;

            comboBoxWalls.Items.AddRange(walls.Select((_, i) => $"Wall {i}").ToArray());
            comboBoxWalls.SelectedIndex = 0;
        }

        private void comboBoxWallTravelClass_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void comboBoxWallTravelStates_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void checkBoxBlockAll_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void panelWallTexture_Paint(object sender, PaintEventArgs e)
        {
            var image = wallTextures[comboBoxWalls.SelectedIndex];
            e.Graphics.DrawImage(image, 0, 0, image.Width * 2, image.Height * 2);
        }

        private void panelWallColor_Paint(object sender, PaintEventArgs e)
        {
            using var colorBrush = new SolidBrush(palette.Colors[walls[comboBoxWalls.SelectedIndex].ColorIndex]);
            e.Graphics.FillRectangle(colorBrush, panelWallColor.ClientRectangle);
        }

        private void panelWallColor_Click(object sender, EventArgs e)
        {

        }

        private void buttonLeftWall_Click(object sender, EventArgs e)
        {
            comboBoxWalls.SelectedIndex--;
        }

        private void buttonRightWall_Click(object sender, EventArgs e)
        {
            comboBoxWalls.SelectedIndex++;
        }
    }
}
