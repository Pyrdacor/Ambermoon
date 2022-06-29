using Ambermoon;
using Ambermoon.Data;

namespace AmbermoonMapCharEditor
{
    public partial class PositionEditorForm : Form
    {
        readonly Map map;
        readonly Map.CharacterReference character;

        public PositionEditorForm(Map map, Map.CharacterReference character)
        {
            this.map = map;
            this.character = character;

            InitializeComponent();
        }

        private void PositionEditorForm_Load(object sender, EventArgs e)
        {
            (dataGridView1.Columns[1] as NumericUpDownColumn)!.MinValue = 1;
            (dataGridView1.Columns[1] as NumericUpDownColumn)!.MaxValue = (uint)map.Width;
            (dataGridView1.Columns[2] as NumericUpDownColumn)!.MinValue = 1;
            (dataGridView1.Columns[2] as NumericUpDownColumn)!.MaxValue = (uint)map.Height;

            if (character.Positions.Count < 288)
            {
                int add = 288 - character.Positions.Count;
                int x = character.Positions.Count == 0 ? 1 : character.Positions[0].X;
                int y = character.Positions.Count == 0 ? 1 : character.Positions[0].Y;

                for (int i = 0; i < add; ++i)
                    character.Positions.Add(new Position(x, y));
            }

            for (int i = 0; i < 288; ++i)
            {
                int minutes = i * 5;
                int hour = minutes / 60;
                minutes %= 60;
                var position = character.Positions[i];
                dataGridView1.Rows.Add($"{hour:00}:{minutes:00}", position.X, position.Y);
            }
        }

        private void PositionEditorForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            for (int i = 0; i < 288; ++i)
            {
                var row = dataGridView1.Rows[i];
                var x = Convert.ToUInt32(row.Cells[1].Value);
                var y = Convert.ToUInt32(row.Cells[2].Value);
                character.Positions[i] = new Position((int)x, (int)y);
            }
        }
    }
}
