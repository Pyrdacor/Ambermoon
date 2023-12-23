namespace Ambermoon3DMapEditor
{
    public partial class AssetForm : Form
    {
        public AssetForm(List<Bitmap> wallTextures, List<List<Bitmap>> objectTextures)
        {
            InitializeComponent();

            this.wallTextures = wallTextures;
            this.objectTextures = objectTextures;
        }

        private readonly List<Bitmap> wallTextures;
        private readonly List<List<Bitmap>> objectTextures;

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
            buttonLeftWall.Enabled = comboBoxWalls.Items.Count != 0 && comboBoxWalls.SelectedIndex > 0;
            buttonRightWall.Enabled = comboBoxWalls.Items.Count != 0 && comboBoxWalls.SelectedIndex < comboBoxWalls.Items.Count - 1;
            panelWallTexture.Refresh();
        }

        private void checkBoxWallTransparency_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void AssetForm_Load(object sender, EventArgs e)
        {
            comboBoxWalls.Items.AddRange(wallTextures.Select((_, i) => $"Wall {i}").ToArray());
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
