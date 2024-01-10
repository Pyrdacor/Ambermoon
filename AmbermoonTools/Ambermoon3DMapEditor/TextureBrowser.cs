namespace Ambermoon3DMapEditor
{
    public partial class TextureBrowser : Form
    {
        public TextureBrowser(Dictionary<uint, Bitmap> textures, uint selectedIndex)
        {
            InitializeComponent();

            this.textures = textures;
            SelectedIndex = selectedIndex;

            panelTextures.Height = 168 + SystemInformation.HorizontalScrollBarHeight;
            panelTextures.AutoScrollMinSize = new Size(textures.Count * 8 + textures.Sum(t => t.Value.Width * 2), textures.Max(t => t.Value.Height * 2) + 8);
        }

        private readonly Dictionary<uint, Bitmap> textures;
        public uint SelectedIndex { get; set; } = 0;

        private void buttonAddTexture_Click(object sender, EventArgs e)
        {
            // TODO
        }

        private void buttonClose_Click(object sender, EventArgs e)
        {
            Close();
        }

        private void panelTextures_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None;
            e.Graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;

            int x = 4;

            foreach (var texture in textures.OrderBy(t => t.Key))
            {
                int y = (panelTextures.AutoScrollMinSize.Height - texture.Value.Height * 2) / 2;

                e.Graphics.DrawImage(texture.Value, x + panelTextures.AutoScrollPosition.X, y + panelTextures.AutoScrollPosition.Y, texture.Value.Width * 2, texture.Value.Height * 2);

                if (texture.Key == SelectedIndex)
                {
                    using var selectPen1 = new Pen(Color.Black, 1);
                    using var selectPen2 = new Pen(Color.Yellow, 1);
                    var area = new Rectangle(x + panelTextures.AutoScrollPosition.X - 2, y + panelTextures.AutoScrollPosition.Y - 2, texture.Value.Width * 2 + 4, texture.Value.Height * 2 + 4);
                    e.Graphics.DrawRectangle(selectPen1, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen2, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen2, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen1, area);
                }

                x += texture.Value.Width * 2 + 8;
            }
        }

        private void panelTextures_MouseDown(object sender, MouseEventArgs e)
        {
            int x = panelTextures.AutoScrollPosition.X;

            foreach (var texture in textures.OrderBy(t => t.Key))
            {
                if (e.X < x + texture.Value.Width * 2 + 8)
                {
                    if (SelectedIndex != texture.Key)
                    {
                        SelectedIndex = texture.Key;
                        Refresh();
                    }
                    return;
                }

                x += texture.Value.Width * 2 + 8;
            }
        }

        private void panelTextures_Scroll(object sender, ScrollEventArgs e)
        {
            Refresh();
        }

        private void TextureBrowser_Load(object sender, EventArgs e)
        {
            int scrollX = 0;

            foreach (var texture in textures.OrderBy(t => t.Key).TakeWhile(t => t.Key < SelectedIndex))
                scrollX += texture.Value.Width * 2 + 8;

            panelTextures.AutoScrollPosition = new Point(scrollX, -panelTextures.AutoScrollPosition.Y);
        }
    }
}
