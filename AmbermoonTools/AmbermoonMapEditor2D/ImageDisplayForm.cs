using System.Drawing;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class ImageDisplayForm : Form
    {
        Bitmap image = null;

        public ImageDisplayForm()
        {
            InitializeComponent();
        }

        internal void SetImage(Bitmap image, Size size)
        {
            // TODO: needed?
            //int dx = Width - drawPanelImage.Bounds.Width;
            //int dy = Height - drawPanelImage.Bounds.Height;

            drawPanelImage.ClientSize = size;

            ClientSize = drawPanelImage.Bounds.Size;

            // TODO: needed?
            //drawPanelImage.Refresh();
        }

        private void drawPanelImage_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.Clear(drawPanelImage.BackColor);

            if (image != null)
                e.Graphics.DrawImage(image, drawPanelImage.ClientRectangle);
        }
    }
}
