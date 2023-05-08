using Ambermoon.Data;

namespace AmbermoonImageEditor
{
    record FormatEntry(string Name, GraphicFormat GraphicFormat, int? DefaultWidth = null, int? defaultHeight = null, bool FixedSize = false)
    {
        public override string ToString() => Name;
    }

    public partial class SizeForm : Form
    {
        static readonly List<FormatEntry> formatEntries = new();

        static SizeForm()
        {
            formatEntries.Add(new("3 BPP", GraphicFormat.Palette3Bit));
            formatEntries.Add(new("4 BPP", GraphicFormat.Palette4Bit));
            formatEntries.Add(new("5 BPP", GraphicFormat.Palette5Bit));
            formatEntries.Add(new("Texture", GraphicFormat.Texture4Bit));
            formatEntries.Add(new("Wall 3D", GraphicFormat.Texture4Bit, 128, 80, true));
            formatEntries.Add(new("Object 3D", GraphicFormat.Texture4Bit));
            formatEntries.Add(new("Overlay 3D", GraphicFormat.Texture4Bit));
            formatEntries.Add(new("Floor/Ceiling", GraphicFormat.Palette4Bit, 64, 64, true));
            formatEntries.Add(new("Item Gfx", GraphicFormat.Palette5Bit, 16, 16, true));
            formatEntries.Add(new("Portrait", GraphicFormat.Palette5Bit, 32, 34, true));
            formatEntries.Add(new("Tile Gfx", GraphicFormat.Palette5Bit, 16, 16, true));
            formatEntries.Add(new("Monster", GraphicFormat.Palette5Bit));
        }

        public SizeForm(bool showFormat)
        {
            InitializeComponent();

            label3.Visible = showFormat;
            comboBox1.Visible = showFormat;
            comboBox2.Visible = showFormat;
        }

        public int ImageWidth => (int)numericUpDown1.Value;
        public int ImageHeight => (int)numericUpDown2.Value;
        public GraphicFormat Format => (comboBox1.SelectedItem as FormatEntry)!.GraphicFormat;
        public byte PaletteOffset => (byte)(comboBox2.SelectedItem is not int offset ? 0 : offset);
        public int Frames => (int)numericUpDown3.Value;

        private void SizeForm_Load(object sender, EventArgs e)
        {
            foreach (var entry in formatEntries)
            {
                comboBox1.Items.Add(entry);
            }

            comboBox1.SelectedIndex = 0;
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            var entry = comboBox1.SelectedItem as FormatEntry;

            if (entry is not null)
            {
                if (entry.DefaultWidth is not null)
                    numericUpDown1.Value = entry.DefaultWidth.Value;
                if (entry.defaultHeight is not null)
                    numericUpDown2.Value = entry.defaultHeight.Value;
                numericUpDown1.Enabled = !entry.FixedSize;
                numericUpDown2.Enabled = !entry.FixedSize;
            }
            else
            {
                numericUpDown1.Enabled = true;
                numericUpDown2.Enabled = true;
            }

            UpdateOffsetValues(entry);
        }

        private void UpdateOffsetValues(FormatEntry? formatEntry)
        {
            int bpp = formatEntry is null ? 5 : formatEntry.GraphicFormat switch
            {
                GraphicFormat.Palette3Bit => 3,
                GraphicFormat.Palette4Bit => 4,
                GraphicFormat.Texture4Bit => 4,
                _ =>  5
            };

            int oldOffset = PaletteOffset;

            if (bpp == 3)
            {
                comboBox2.Items.Clear();
                comboBox2.Items.Add(0);
                comboBox2.Items.Add(16);
                comboBox2.Items.Add(24);
                comboBox2.SelectedIndex = oldOffset switch
                {
                    24 => 2,
                    16 => 1,
                    _ => 0
                };
                comboBox2.Enabled = true;
            }
            else if (bpp == 4)
            {
                comboBox2.Items.Clear();
                comboBox2.Items.Add(0);
                comboBox2.Items.Add(16);
                comboBox2.SelectedIndex = oldOffset == 16 ? 1 : 0;
                comboBox2.Enabled = true;
            }
            else
            {
                comboBox2.Items.Clear();
                comboBox2.Items.Add(0);
                comboBox2.SelectedIndex = 0;
                comboBox2.Enabled = false;
            }
        }
    }
}
