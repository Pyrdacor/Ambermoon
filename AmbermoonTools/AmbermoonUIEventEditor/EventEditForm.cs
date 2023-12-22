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

            // TODO: Event Index, Flags8, Flags16

            if (eventDesc.AllowAsFirst)
            {
                y += 2;
                startNewEventChainCheckBox = new CheckBox();
                startNewEventChainCheckBox.Text = "Start new event chain";
                if (eventDesc.AllowOnlyAsFirst)
                {
                    startNewEventChainCheckBox.Checked = true;
                    startNewEventChainCheckBox.Enabled = false;
                }
                else
                {
                    startNewEventChainCheckBox.Checked = false;
                }
                startNewEventChainCheckBox.Location = new Point(x, y);
                startNewEventChainCheckBox.Width = comboBoxTypes.Bounds.Right - x;
                Controls.Add(startNewEventChainCheckBox);
                y += startNewEventChainCheckBox.Height + 6;
            }

            var okButton = new Button();
            okButton.Text = "OK";
            okButton.DialogResult = DialogResult.OK;
            okButton.Width = 98;
            okButton.Height = 28;
            okButton.Location = new Point(comboBoxTypes.Bounds.Right - okButton.Width * 2 - 4, y);
            Controls.Add(okButton);
            var cancelButton = new Button();
            cancelButton.Text = "Cancel";
            cancelButton.DialogResult = DialogResult.Cancel;
            cancelButton.Width = 98;
            cancelButton.Height = okButton.Height;
            cancelButton.Location = new Point(comboBoxTypes.Bounds.Right - cancelButton.Width, y);
            Controls.Add(cancelButton);

            ClientSize = new System.Drawing.Size(ClientSize.Width, cancelButton.Bottom + 8);
        }

        private readonly CheckBox? startNewEventChainCheckBox = null;
        private readonly bool create;
        private readonly Event @event;
        private readonly int childX = 0;
        private int x = 0;
        private int y = 0;
        public bool StartNewEventChain => startNewEventChainCheckBox?.Checked == true;

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
            input.Minimum = Math.Max(min, valueDescription.MinValue);
            input.Maximum = Math.Min(max, valueDescription.MaxValue);
            input.Value = Util.Limit((int)input.Minimum, defaultValue, (int)input.Maximum);
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
                var label = new Label();
                label.Text = name;
                label.Location = new Point(x, y + 2);
                label.Width = comboBoxTypes.Bounds.Right - 204 - childX;
                Controls.Add(label);
                var dropdown = new ComboBox();
                dropdown.DropDownStyle = ComboBoxStyle.DropDownList;
                dropdown.Items.AddRange(enumDesc.AllowedValueNames.Select((name, index) => $"{Convert.ToInt32(enumDesc.AllowedValues[index])}: {name}").ToArray());
                dropdown.SelectedIndex = enumDesc.AllowedValues.Select(Convert.ToInt32).ToList().IndexOf(Convert.ToInt32(defaultValue));
                dropdown.Location = new Point(label.Bounds.Right + 4, y);
                dropdown.Width = 200;
                dropdown.Tag = valueDescription;
                Controls.Add(dropdown);
                y += dropdown.Height + 4;
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
            }
        }

        private void EventEditForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (DialogResult == DialogResult.OK)
            {
                var eventType = @event.GetType();

                foreach (var checkBox in Controls.OfType<CheckBox>().Where(c => c.Tag is ValueDescription))
                {
                    var desc = (checkBox.Tag as ValueDescription)!;
                    var property = eventType.GetProperty(desc.Name)!;
                    property.SetValue(@event, Convert.ChangeType(checkBox.Checked, property.PropertyType));
                }

                foreach (var input in Controls.OfType<NumericUpDown>().Where(i => i.Tag is ValueDescription))
                {
                    var desc = (input.Tag as ValueDescription)!;
                    var property = eventType.GetProperty(desc.Name)!;
                    object? value = input.Value;
                    if (property.PropertyType.IsEnum)
                        value = System.Enum.Parse(property.PropertyType, value.ToString()!);
                    else if (property.PropertyType.IsGenericType && property.PropertyType.GetGenericTypeDefinition() == typeof(Nullable<>) && property.PropertyType.GetGenericArguments()[0].IsEnum)
                        value = System.Enum.Parse(property.PropertyType.GetGenericArguments()[0], value.ToString()!);
                    else
                        value = Convert.ChangeType(value, property.PropertyType);
                    property.SetValue(@event, value);
                }

                foreach (var dropdown in Controls.OfType<ComboBox>().Where(c => c.Tag is ValueDescription && c.Tag is IEnumValueDescription))
                {
                    var desc = (dropdown.Tag as ValueDescription)!;
                    var enumDesc = (dropdown.Tag as IEnumValueDescription)!;
                    var value = enumDesc.AllowedValues[dropdown.SelectedIndex];
                    var property = eventType.GetProperty(desc.Name)!;
                    property.SetValue(@event, Convert.ChangeType(value, property.PropertyType));
                }

                // TODO: Event Index, Flags8, Flags16
            }
        }
    }
}
