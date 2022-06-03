namespace AmbermoonMapEditor3D
{
    internal partial class TexturePanel : UserControl
    {
        private TexturePicker texturePickerWalls = new TexturePicker();
        private TexturePicker texturePickerObjects = new TexturePicker();
        int lastTexturePickerWallsHeight = 0;
        int lastTexturePickerObjectsHeight = 0;
        int referenceHeightWalls = 0;
        int referenceHeightObjects = 0;

        public TexturePanel(List<ITexturedObject> walls, List<ITexturedObject> objects)
        {
            InitializeComponent();

            texturePickerWalls.TexturedObjects = walls;
            texturePickerWalls.Dock = DockStyle.Fill;
            texturePickerWalls.Location = new Point(3, 3);
            texturePickerWalls.Size = new Size(726, 80);
            texturePickerWalls.TabIndex = 0;
            texturePickerWalls.SizeChanged += TexturePickerWalls_SizeChanged;

            texturePickerObjects.TexturedObjects = objects;
            texturePickerObjects.Dock = DockStyle.Fill;
            texturePickerObjects.Location = new Point(3, 3);
            texturePickerObjects.Size = new Size(726, 80);
            texturePickerObjects.TabIndex = 0;
            texturePickerObjects.SizeChanged += TexturePickerObjects_SizeChanged;
        }

        private void TexturePickerObjects_SizeChanged(object sender, EventArgs e)
        {
            ResizeFit(ref lastTexturePickerObjectsHeight, referenceHeightObjects);
            referenceHeightObjects = Height;
        }

        private void TexturePickerWalls_SizeChanged(object sender, EventArgs e)
        {
            ResizeFit(ref lastTexturePickerWallsHeight, referenceHeightWalls);
            referenceHeightWalls = Height;
        }

        private void TexturePanel_Load(object sender, EventArgs e)
        {
            tabPageWalls.Controls.Add(texturePickerWalls);
            tabPageObjects.Controls.Add(texturePickerObjects);

            lastTexturePickerWallsHeight = texturePickerWalls.Height;
            lastTexturePickerObjectsHeight = texturePickerObjects.Height;
            referenceHeightWalls = Height;
            referenceHeightObjects = Height;

            texturePickerWalls.Height = 84;
        }

        private void TexturePanel_TabIndexChanged(object sender, EventArgs e)
        {
            int lastHeight = tabControl1.SelectedIndex == 0 ? lastTexturePickerWallsHeight : lastTexturePickerObjectsHeight;
            int referenceHeight = tabControl1.SelectedIndex == 0 ? referenceHeightWalls : referenceHeightObjects;

            ResizeFit(ref lastHeight, referenceHeight);

            if (tabControl1.SelectedIndex == 0)
            {
                lastTexturePickerWallsHeight = lastHeight;
                referenceHeightWalls = Height;
            }
            else
            {
                lastTexturePickerObjectsHeight = lastHeight;
                referenceHeightObjects = Height;
            }
        }

        void ResizeFit(ref int lastHeight, int referenceHeight)
        {
            if (lastHeight == 0 || tabControl1?.SelectedTab?.Controls == null || tabControl1.SelectedTab.Controls.Count == 0)
                return;

            int height = tabControl1.SelectedTab.Controls[0].Height;
            int diff = height - lastHeight;
            lastHeight = height;

            MinimumSize = new Size(0, 0); // important!
            Height = referenceHeight + diff;
            MinimumSize = new Size(0, Height);
        }
    }
}
