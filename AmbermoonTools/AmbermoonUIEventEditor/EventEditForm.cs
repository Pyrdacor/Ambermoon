using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using System.Data;

namespace AmbermoonUIEventEditor
{
    public partial class EventEditForm : Form
    {
        public EventEditForm(bool create, Event @event, List<Event> events)
        {
            this.create = create;
            this.@event = @event;

            InitializeComponent();

            y = create ? comboBoxTypes.Location.Y : ClientSize.Height;
            x = childX = labelType.Location.X;

            var eventDesc = EventDescriptions.Events[@event.Type];
            var shownValues = eventDesc.ValueDescriptions.Where(d => !d.Hidden);

            var boolValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Bool);
            var intValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Byte ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.SByte ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Word);
            var enumValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Enum ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Flag8 ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Flag16);

            foreach (var boolValue in boolValues)
            {
                AddBoolControl(boolValue.Name, boolValue.DefaultValue != 0, boolValue);
            }

            if (x != childX)
            {
                x = childX;
                y += Controls.OfType<CheckBox>().Last().Height + 4;
            }

            foreach (var intValue in intValues)
            {
                Tuple<int, int> minMax = intValue.Type switch
                {
                    Ambermoon.Data.Descriptions.ValueType.SByte => Tuple.Create<int, int>(sbyte.MinValue, sbyte.MaxValue),
                    Ambermoon.Data.Descriptions.ValueType.Byte => Tuple.Create<int, int>(byte.MinValue, byte.MaxValue),
                    Ambermoon.Data.Descriptions.ValueType.Word => Tuple.Create<int, int>(ushort.MinValue, ushort.MaxValue),
                    _ => throw new NotSupportedException("Unsupported integer value type.")
                };
                AddIntControl(intValue.Name, minMax.Item1, minMax.Item2, intValue.DefaultValue, intValue);
            }

            foreach (var enumValue in enumValues)
            {
                var enumDesc = (enumValue as IEnumValueDescription)!;
                AddEnumControl(enumValue.Name, enumDesc, enumValue.DefaultValue, enumValue);
            }

            ClientSize = new System.Drawing.Size(ClientSize.Width, Controls.OfType<Control>().Max(c => c.Bounds.Bottom) + 8);
        }

        private readonly bool create;
        private readonly Event @event;
        private int childX = 0;
        private int x = 0;
        private int y = 0;

        private void AddBoolControl(string name, bool defaultValue, ValueDescription valueDescription)
        {
            var checkBox = new CheckBox();
            checkBox.Text = name;
            checkBox.Checked = defaultValue;
            checkBox.Location = new Point(x, y);
            checkBox.Width = (ClientSize.Width - childX * 2) / 2;
            checkBox.Tag = valueDescription;
            Controls.Add(checkBox);

            if (x == childX)
                x += (ClientSize.Width - childX * 2) / 2;
            else
            {
                x = childX;
                y += checkBox.Height + 4;
            }
        }

        private void AddIntControl(string name, int min, int max, int defaultValue, ValueDescription valueDescription)
        {
            var label = new Label();
            label.Text = name;
            label.Location = new Point(x, y + 2);
            label.Width = comboBoxTypes.Bounds.Right - 64 - childX;
            Controls.Add(label);
            var input = new NumericUpDown();
            input.Minimum = min;
            input.Maximum = max;
            input.Value = Util.Limit(min, defaultValue, max);
            input.Location = new Point(label.Bounds.Right + 4, y);
            input.Width = 60;
            input.Tag = valueDescription;
            Controls.Add(input);
            y += input.Height + 4;
        }

        private void AddEnumControl(string name, IEnumValueDescription enumDesc, object defaultValue, ValueDescription valueDescription)
        {
            if (valueDescription.Type == Ambermoon.Data.Descriptions.ValueType.Enum)
            {
                // TODO: Dropdown
            }
            else // Flags
            {
                // foreach AddBoolControl();

                if (x != childX)
                {
                    x = childX;
                    y += Controls.OfType<CheckBox>().Last().Height + 4;
                }
            }
        }

        private void AddEventIndexControl(string name, int? value, ValueDescription valueDescription)
        {

        }

        private void EventEditForm_Load(object sender, EventArgs e)
        {
            Text = (create ? "Create " : "Edit ") + @event.Type.ToString() + " Event";

            if (create)
            {
                labelType.Visible = false;
                comboBoxTypes.Visible = false;

                if (Controls.Count == 2)
                    DialogResult = DialogResult.OK; // no input required
            }
        }
    }
}
