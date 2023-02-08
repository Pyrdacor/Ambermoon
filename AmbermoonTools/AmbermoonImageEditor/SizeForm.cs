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

        public SizeForm()
        {
            InitializeComponent();
        }

        public int ImageWidth => (int)numericUpDown1.Value;
        public int ImageHeight => (int)numericUpDown2.Value;
        public GraphicFormat Format => (comboBox1.SelectedItem as FormatEntry)!.GraphicFormat;

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
        }
    }
}
