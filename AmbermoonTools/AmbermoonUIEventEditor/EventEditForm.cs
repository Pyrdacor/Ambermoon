using System.ComponentModel;
using System.Data;
using System.Windows.Forms;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy.Serialization;

namespace AmbermoonUIEventEditor
{
    public partial class EventEditForm : Form
    {
        private const int GroupBoxChildOffset = 18;
        private const int GroupBoxHeightAdded = GroupBoxChildOffset + 4;

        public EventEditForm(bool create, Event @event, List<Event> events)
        {
            this.create = create;
            this.@event = @event;
            this.events = events;
            childX = labelType.Location.X;
            container = this;

            InitializeComponent();
            InitializeEventControls();
        }

        private CheckBox? startNewEventChainCheckBox = null;
        private readonly bool create;
        private readonly Event @event;
        private readonly List<Event> events;
        private readonly int childX = 0;
        private int x = 0;
        private int y = 0;
        private Control container;
        public bool StartNewEventChain => startNewEventChainCheckBox?.Checked == true;

        private void InitializeEventControls()
        {
            Controls.Clear();

            y = create ? comboBoxTypes.Location.Y : ClientSize.Height;
            x = labelType.Location.X;
            container = this;

            var eventDesc = EventDescriptions.Events[@event.Type];
            var shownValues = eventDesc.ValueDescriptions.Where(d => !d.Hidden);

            var boolValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Bool);
            var intValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Byte ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.SByte ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Word ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.TenBits ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.TwelveBits);
            var enumValues = shownValues.Where(d => d.Type == Ambermoon.Data.Descriptions.ValueType.Enum ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Flag8 ||
                d.Type == Ambermoon.Data.Descriptions.ValueType.Flag16);

            foreach (var boolValue in boolValues)
            {
                var control = AddBoolControl(boolValue.Name, boolValue.DefaultValue != 0, boolValue);

                if (!create)
                    this.FillPropertyControl(control);
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
                    Ambermoon.Data.Descriptions.ValueType.TenBits => Tuple.Create<int, int>(ushort.MinValue, 1023),
                    Ambermoon.Data.Descriptions.ValueType.TwelveBits => Tuple.Create<int, int>(ushort.MinValue, 4095),
                    _ => throw new NotSupportedException("Unsupported integer value type.")
                };
                var control = AddIntControl(intValue.Name, minMax.Item1, minMax.Item2, intValue.DefaultValue, intValue);

                if (!create)
                    this.FillPropertyControl(control);
            }

            foreach (var enumValue in enumValues)
            {
                var enumDesc = (enumValue as IEnumValueDescription)!;
                var control = AddEnumControl(enumValue.Name, enumDesc, enumValue.DefaultValue, enumValue);

                if (!create)
                    this.FillPropertyControl(control);
            }

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

        private CheckBox AddBoolControl(string name, bool defaultValue, ValueDescription valueDescription)
        {
            int right = container != this ? container.Right : ClientSize.Width;
            int displayY = container != this ? y - container.Location.Y + GroupBoxChildOffset : y;

            var checkBox = new CheckBox();
            checkBox.Text = name;
            checkBox.Checked = defaultValue;
            checkBox.Location = new Point(x, displayY);
            checkBox.Width = (right - childX * 2) / 2;
            checkBox.Tag = valueDescription;
            container.Controls.Add(checkBox);

            if (x == childX)
                x += (right - childX * 2) / 2;
            else
            {
                x = childX;
                y += checkBox.Height + 4;
            }

            return checkBox;
        }

        private NumericUpDown AddIntControl(string name, int min, int max, int defaultValue, ValueDescription valueDescription)
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

            return input;
        }

        private Control AddEnumControl(string name, IEnumValueDescription enumDesc, object defaultValue, ValueDescription valueDescription)
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

                return dropdown;
            }
            else // Flags
            {
                y += 2;
                var groupBox = new GroupBox();
                groupBox.Text = name;
                groupBox.Location = new Point(x - 2, y);
                groupBox.Tag = valueDescription;
                groupBox.ClientSize = new System.Drawing.Size(ClientSize.Width - 2 * childX - 4, 0);
                int startY = y;
                container = groupBox;

                int valueIndex = 0;
                var defValue = (ushort)defaultValue;
                foreach (var valueName in enumDesc.AllowedValueNames)
                {
                    var value = Convert.ToUInt16(enumDesc.AllowedValues[valueIndex++]);

                    if (value == 0)
                        continue; // Don't show "None" option

                    AddBoolControl(valueName, (defValue & value) != 0, valueDescription);
                }

                if (x != childX)
                {
                    x = childX;
                    y += Controls.OfType<CheckBox>().Last().Height + 4;
                }

                groupBox.ClientSize = new System.Drawing.Size(groupBox.ClientSize.Width, GroupBoxHeightAdded + y - startY);

                if (groupBox.ClientSize.Height > GroupBoxHeightAdded)
                {
                    Controls.Add(groupBox);
                    groupBox.Visible = true;
                }
                else
                {
                    groupBox.Dispose();
                }

                container = this;

                return groupBox;
            }
        }

        private void EventEditForm_Load(object sender, EventArgs e)
        {
            Text = (create ? "Create " : "Edit ") + @event.Type.ToString() + " Event";

            if (create)
            {
                labelType.Visible = false;
                comboBoxTypes.Visible = false;
            }
            else
            {
                comboBoxTypes.SelectedIndexChanged += EventTypeIndexChanged;
            }
        }

        private void EventTypeIndexChanged(object? sender, EventArgs e)
        {
            if (comboBoxTypes.SelectedIndex == -1)
                return;

            if ((int)@event.Type != comboBoxTypes.SelectedIndex)
            {
                if (MessageBox.Show("You're about to change the event type. All entered data will be lost. Sure about this?", "Potential data loss", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    var newEventType = (EventType)comboBoxTypes.SelectedIndex;
                    var newEvent = EventDescriptions.EventFactories[newEventType]();
                    newEvent.Index = @event.Index;

                    var eventIndex = events.IndexOf(@event);
                    events[eventIndex] = newEvent;

                    this.Hide();

                    new EventEditForm(false, newEvent, events).ShowDialog();

                    this.DialogResult = DialogResult.Abort;
                }
            }
        }

        private void FillPropertyControl(Control control)
        {
            var eventType = @event.GetType();
            var valueDescription = (control.Tag as ValueDescription)!;

            if (control is CheckBox checkBox)
            {
                var property = eventType.GetProperty(valueDescription.Name)!;

                checkBox.Checked = (bool)property.GetValue(@event)!;
            }
            else if (control is NumericUpDown numericUpDown)
            {
                if (valueDescription is TenBitValueDescription tenBitValueDescription)
                {
                    var eventDataWriter = new DataWriter();
                    EventWriter.WriteEventData(eventDataWriter, @event);
                    numericUpDown.Value = tenBitValueDescription.Read(eventDataWriter.ToArray());
                }
                else if (valueDescription is TwelveBitValueDescription twelveBitValueDescription)
                {
                    var eventDataWriter = new DataWriter();
                    EventWriter.WriteEventData(eventDataWriter, @event);
                    numericUpDown.Value = twelveBitValueDescription.Read(eventDataWriter.ToArray());
                }
                else
                {
                    var property = eventType.GetProperty(valueDescription.Name)!;
                    var value = property.GetValue(@event)!;
                    numericUpDown.Value = (decimal)Convert.ChangeType(value, typeof(decimal));
                }
            }
            else if (control is ComboBox dropdown)
            {
                var desc = (dropdown.Tag as ValueDescription)!;
                var enumDesc = (dropdown.Tag as IEnumValueDescription)!;
                var property = eventType.GetProperty(desc.Name)!;
                var value = property.GetValue(@event)!;
                dropdown.SelectedIndex = enumDesc.AllowedValues.ToList().IndexOf(value);
            }
            else if (control is GroupBox groupBox)
            {
                var desc = (groupBox.Tag as ValueDescription)!;
                var enumDesc = (groupBox.Tag as IEnumValueDescription)!;
                var property = eventType.GetProperty(desc.Name)!;
                var value = (ushort)Convert.ChangeType(property.GetValue(@event)!, typeof(ushort));
                var checkBoxes = groupBox.Controls.OfType<CheckBox>().ToList();

                for (int i = 0, j = 0; i < enumDesc.AllowedValues.Length; i++)
                {
                    var v = Convert.ToUInt16(enumDesc.AllowedValues[i]);

                    if (v == 0)
                        continue; // Don't show "None" option

                    checkBoxes[j++].Checked = (value & v) != 0;
                }
            }
            else
            {
                throw new NotSupportedException("Invalid control");
            }
        }

        private void SetProperty<T>(ValueDescription valueDescription, T value)
        {
            var eventType = @event.GetType();
            var property = eventType.GetProperty(valueDescription.Name)!;
            property.SetValue(@event, Convert.ChangeType(value, property.PropertyType));
        }

        private void SetProperty(Control control)
        {
            var eventType = @event.GetType();
            var valueDescription = (control.Tag as ValueDescription)!;

            if (control is CheckBox checkBox)
                SetProperty(valueDescription, checkBox.Checked);
            else if (control is NumericUpDown numericUpDown)
            {
                if (valueDescription is TenBitValueDescription tenBitValueDescription)
                {
                    var eventDataWriter = new DataWriter();
                    EventWriter.WriteEventData(eventDataWriter, @event);
                    byte[] eventData = [(byte)@event.Type, .. eventDataWriter.ToArray()];
                    tenBitValueDescription.Write(eventData, (ushort)Convert.ChangeType(numericUpDown.Value, typeof(ushort)));
                    var updatedEvent = EventReader.ParseEvent(new DataReader(eventData));

                    var property = eventType.GetProperty(tenBitValueDescription.PropertyName)!;
                    property.SetValue(@event, property.GetValue(updatedEvent));
                }
                else if (valueDescription is TwelveBitValueDescription twelveBitValueDescription)
                {
                    var eventDataWriter = new DataWriter();
                    EventWriter.WriteEventData(eventDataWriter, @event);
                    byte[] eventData = [(byte)@event.Type, .. eventDataWriter.ToArray()];
                    twelveBitValueDescription.Write(eventData, (ushort)Convert.ChangeType(numericUpDown.Value, typeof(ushort)));
                    var updatedEvent = EventReader.ParseEvent(new DataReader(eventData));

                    var property = eventType.GetProperty(twelveBitValueDescription.PropertyName)!;
                    property.SetValue(@event, property.GetValue(updatedEvent));
                }
                else
                {
                    var property = eventType.GetProperty(valueDescription.Name)!;
                    object? value = numericUpDown.Value;
                    if (property.PropertyType.IsEnum)
                        value = Enum.Parse(property.PropertyType, value.ToString()!);
                    else if (property.PropertyType.IsGenericType && property.PropertyType.GetGenericTypeDefinition() == typeof(Nullable<>) && property.PropertyType.GetGenericArguments()[0].IsEnum)
                        value = Enum.Parse(property.PropertyType.GetGenericArguments()[0], value.ToString()!);
                    else
                        value = Convert.ChangeType(value, property.PropertyType);
                    property.SetValue(@event, value);
                }
            }

        }

        private void EventEditForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (DialogResult == DialogResult.OK)
            {
                var eventType = @event.GetType();

                foreach (var checkBox in Controls.OfType<CheckBox>().Where(c => c.Tag is ValueDescription))
                {
                    SetProperty(checkBox);
                }

                foreach (var input in Controls.OfType<NumericUpDown>().Where(i => i.Tag is ValueDescription))
                {
                    SetProperty(input);
                }

                foreach (var dropdown in Controls.OfType<ComboBox>().Where(c => c.Tag is ValueDescription && c.Tag is IEnumValueDescription))
                {
                    var desc = (dropdown.Tag as ValueDescription)!;
                    var enumDesc = (dropdown.Tag as IEnumValueDescription)!;
                    var value = enumDesc.AllowedValues[dropdown.SelectedIndex];
                    var property = eventType.GetProperty(desc.Name)!;
                    property.SetValue(@event, Convert.ChangeType(value, property.PropertyType));
                }

                foreach (var groupBox in Controls.OfType<GroupBox>().Where(c => c.Tag is ValueDescription))
                {
                    var desc = (groupBox.Tag as ValueDescription)!;
                    var enumDesc = (groupBox.Tag as IEnumValueDescription)!;
                    var property = eventType.GetProperty(desc.Name)!;
                    ushort value = 0;
                    var checkBoxes = groupBox.Controls.OfType<CheckBox>().ToList();

                    for (int i = 0, j = 0; i < enumDesc.AllowedValues.Length; i++)
                    {
                        var v = Convert.ToUInt16(enumDesc.AllowedValues[i]);

                        if (v == 0)
                            continue; // Don't show "None" option

                        var checkBox = checkBoxes[j++];

                        if (checkBox.Checked)
                        {
                            value |= v;
                        }
                    }

                    object? propValue = value;

                    if (property.PropertyType.IsEnum)
                        propValue = Enum.Parse(property.PropertyType, value.ToString()!);
                    else if (property.PropertyType.IsGenericType && property.PropertyType.GetGenericTypeDefinition() == typeof(Nullable<>) && property.PropertyType.GetGenericArguments()[0].IsEnum)
                        propValue = Enum.Parse(property.PropertyType.GetGenericArguments()[0], value.ToString()!);

                    property.SetValue(@event, propValue);
                }
            }
        }
    }
}
