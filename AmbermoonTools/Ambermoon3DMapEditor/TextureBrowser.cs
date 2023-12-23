namespace Ambermoon3DMapEditor
{
    public partial class TextureBrowser : Form
    {
        public TextureBrowser(List<Bitmap> textures)
        {
            InitializeComponent();

            this.textures = textures;

            panelTextures.Height = 168 + SystemInformation.HorizontalScrollBarHeight;
            panelTextures.AutoScrollMinSize = new Size(textures.Count * 8 + textures.Sum(t => t.Width * 2), textures.Max(t => t.Height * 2) + 8);
        }

        private readonly List<Bitmap> textures;
        public int SelectedIndex { get; set; } = 0;

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

            for (int i = 0; i < textures.Count; i++)
            {
                int y = (panelTextures.AutoScrollMinSize.Height - textures[i].Height * 2) / 2;

                e.Graphics.DrawImage(textures[i], x + panelTextures.AutoScrollPosition.X, y + panelTextures.AutoScrollPosition.Y, textures[i].Width * 2, textures[i].Height * 2);

                if (i == SelectedIndex)
                {
                    using var selectPen1 = new Pen(Color.Black, 1);
                    using var selectPen2 = new Pen(Color.Yellow, 1);
                    var area = new Rectangle(x + panelTextures.AutoScrollPosition.X - 2, y + panelTextures.AutoScrollPosition.Y - 2, textures[i].Width * 2 + 4, textures[i].Height * 2 + 4);
                    e.Graphics.DrawRectangle(selectPen1, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen2, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen2, area);
                    area.Inflate(-1, -1);
                    e.Graphics.DrawRectangle(selectPen1, area);
                }

                x += textures[i].Width * 2 + 8;
            }
        }

        private void panelTextures_MouseDown(object sender, MouseEventArgs e)
        {
            int x = panelTextures.AutoScrollPosition.X;

            for (int i = 0; i < textures.Count; i++)
            {
                if (e.X < x + textures[i].Width * 2 + 8)
                {
                    if (SelectedIndex != i)
                    {
                        SelectedIndex = i;
                        Refresh();
                    }
                    return;
                }

                x += textures[i].Width * 2 + 8;
            }
        }

        private void panelTextures_Scroll(object sender, ScrollEventArgs e)
        {
            Refresh();
        }
    }
}
