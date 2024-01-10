namespace Ambermoon3DMapEditor
{
    internal partial class ColorPickerForm : Form
    {
        public ColorPickerForm(Palette palette, int colorCount, int colorOffset, Color? selectedColor)
        {
            InitializeComponent();

            int colorWidth = 24;
            int colorHeight = 24;
            int gap = 8;
            rows = colorCount <= 16 ? (colorCount + 7) / 8 : (colorCount + 15) / 16;
            columns = colorCount <= 16 ? 8 : 16;

            Color = selectedColor ?? palette.Colors[colorOffset];
            ClientSize = new Size(columns * (colorWidth + gap), rows * (colorHeight + gap) + ClientSize.Height - buttonOK.Location.Y);

            for (int y = 0; y < rows; y++)
            {
                for (int x = 0; x < columns; x++)
                {
                    var colorPanel = new Panel();
                    colorPanel.BackColor = palette.Colors[x + y * columns];
                    colorPanel.BorderStyle = BorderStyle.Fixed3D;
                    colorPanel.DoubleClick += (sender, args) => PickColor((sender as Panel)!.BackColor);
                    colorPanel.Click += (sender, args) => SelectColor((sender as Panel)!.BackColor);
                    colorPanel.Location = new Point(gap / 2 + x * (colorWidth + gap), gap / 2 + y * (colorHeight + gap));
                    colorPanel.Size = new Size(colorWidth, colorHeight);
                    colorPanel.Visible = true;
                    Controls.Add(colorPanel);
                }
            }
        }

        private readonly int columns;
        private readonly int rows;

        public Color Color { get; private set; }

        private void PickColor(Color color)
        {
            Color = color;
            DialogResult = DialogResult.OK;
        }

        private void SelectColor(Color color)
        {
            Color = color;
            Refresh();
        }

        private void ColorPickerForm_Load(object sender, EventArgs e)
        {

        }

        private void ColorPickerForm_Paint(object sender, PaintEventArgs e)
        {
            var colorPanel = Controls.OfType<Panel>().FirstOrDefault(p => p.BackColor == Color);

            if (colorPanel != null)
            {
                using var outerMarkerPen = new Pen(Color.Red, 1);
                using var innerMarkerPen = new Pen(Color.Black, 1);
                var area = colorPanel.Bounds;
                area.Offset(-1, -1);
                area.Inflate(1, 1);
                e.Graphics.DrawRectangle(innerMarkerPen, area);
                area.Inflate(1, 1);
                e.Graphics.DrawRectangle(outerMarkerPen, area);
            }
        }
    }
}
