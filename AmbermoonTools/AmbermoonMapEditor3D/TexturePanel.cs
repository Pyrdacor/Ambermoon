namespace AmbermoonMapEditor3D
{
    internal partial class TexturePanel : UserControl
    {
        private TexturePicker texturePickerWalls = new TexturePicker();
        private TexturePicker texturePickerObjects = new TexturePicker();
        int lastTexturePickerWallsHeight = 0;
        int lastTexturePickerObjectsHeight = 0;

        public TexturePanel(List<ITexturedObject> walls, List<ITexturedObject> objects)
        {
            InitializeComponent();

            texturePickerWalls.TexturedObjects = walls;
            texturePickerWalls.Dock = DockStyle.Fill;
            texturePickerWalls.Location = new Point(3, 3);
            texturePickerWalls.Size = new Size(726, 116);
            texturePickerWalls.TabIndex = 0;
            texturePickerWalls.SizeChanged += TexturePickerWalls_SizeChanged;

            texturePickerObjects.TexturedObjects = objects;
            texturePickerObjects.Dock = DockStyle.Fill;
            texturePickerObjects.Location = new Point(3, 3);
            texturePickerObjects.Size = new Size(726, 116);
            texturePickerObjects.TabIndex = 0;
            texturePickerObjects.SizeChanged += TexturePickerObjects_SizeChanged;
        }

        private void TexturePickerObjects_SizeChanged(object sender, EventArgs e)
        {
            ResizeFit(ref lastTexturePickerObjectsHeight);
        }

        private void TexturePickerWalls_SizeChanged(object sender, EventArgs e)
        {
            ResizeFit(ref lastTexturePickerWallsHeight);
        }

        private void TexturePanel_Load(object sender, EventArgs e)
        {
            tabPageWalls.Controls.Add(texturePickerWalls);
            tabPageObjects.Controls.Add(texturePickerObjects);

            lastTexturePickerWallsHeight = texturePickerWalls.Height;
            lastTexturePickerObjectsHeight = texturePickerObjects.Height;
        }

        private void TexturePanel_TabIndexChanged(object sender, EventArgs e)
        {
            int lastHeight = tabControl1.SelectedIndex == 0 ? lastTexturePickerWallsHeight : lastTexturePickerObjectsHeight;

            ResizeFit(ref lastHeight);

            if (tabControl1.SelectedIndex == 0)
                lastTexturePickerWallsHeight = lastHeight;
            else
                lastTexturePickerObjectsHeight = lastHeight;
        }

        void ResizeFit(ref int lastHeight)
        {
            if (lastHeight == 0 || tabControl1?.SelectedTab?.Controls == null || tabControl1.SelectedTab.Controls.Count == 0)
                return;

            int height = tabControl1.SelectedTab.Controls[0].Height;
            int diff = height - lastHeight;
            lastHeight = height;

            Height += diff;
            MinimumSize = new Size(0, Height);
        }
    }
}
