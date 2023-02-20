using System.Resources;

namespace AmbermoonImageEditor
{
    public partial class PaletteForm : Form
    {
        private Color[] palette = Array.Empty<Color>();
        private int selectedColorIndex = 0;
        private int selectMinIndex = 0;
        private int selectMaxIndex = 15;
        private readonly Bitmap imageUnavailable;

        public event Action<Color>? SelectedColorChanged;

        public PaletteForm()
        {
            InitializeComponent();

            var resources = new ResourceManager(typeof(PaletteForm));
            imageUnavailable = (Bitmap)resources.GetObject("unavailable")!;
        }

        public void SetPaletteColors(Color[] palette)
        {
            ArgumentNullException.ThrowIfNull(palette);

            if (palette.Length != 32)
                throw new ArgumentException("Palettes must have a size of exactly 32 colors.");

            this.palette = palette;
        }

        public void SelectColor(int index)
        {
            if (index >= 0 && index < 32 && index >= selectMinIndex && index <= selectMaxIndex)
            {
                if (selectedColorIndex != index)
                {
                    selectedColorIndex = index;
                    panelPalette.Refresh();
                }
                SelectedColorChanged?.Invoke(palette[index]);
            }
        }

        public void RestrictColorSelection(int minIndex, int maxIndex)
        {
            if (selectMinIndex != minIndex || selectMaxIndex != maxIndex)
            {
                selectMinIndex = minIndex;
                selectMaxIndex = maxIndex;

                if (selectedColorIndex < selectMinIndex)
                    SelectColor(selectMinIndex);
                else if (selectedColorIndex > selectMaxIndex)
                    SelectColor(selectMaxIndex);
                else
                    panelPalette.Refresh();
            }
        }

        private void panelPalette_Paint(object sender, PaintEventArgs e)
        {
            if (palette.Length != 32)
                return;

            for (int y = 0; y < 4; ++y)
            {
                for (int x = 0; x < 8; ++x)
                {
                    int index = y * 8 + x;
                    using var brush = new SolidBrush(palette[index]);
                    var area = new Rectangle(x * 32, y * 32, 32, 32);
                    e.Graphics.FillRectangle(brush, area);

                    if (index < selectMinIndex || index > selectMaxIndex)
                        e.Graphics.DrawImage(imageUnavailable, area);
                }
            }

            using var borderPen1 = new Pen(Color.Red, 2.0f);
            int column = selectedColorIndex % 8;
            int row = selectedColorIndex / 8;
            e.Graphics.DrawRectangle(borderPen1, column * 32 + 1, row * 32 + 1, 30, 30);
            using var borderPen2 = new Pen(Color.Yellow, 1.0f);
            borderPen2.DashStyle = System.Drawing.Drawing2D.DashStyle.Dash;
            e.Graphics.DrawRectangle(borderPen2, column * 32 + 3, row * 32 + 3, 26, 26);
        }

        private void panelPalette_Click(object sender, EventArgs e)
        {
            
        }

        private void panelPalette_MouseDown(object sender, MouseEventArgs e)
        {
            int column = e.X / 32;
            int row = e.Y / 32;

            SelectColor(column + row * 8);
        }
    }
}
