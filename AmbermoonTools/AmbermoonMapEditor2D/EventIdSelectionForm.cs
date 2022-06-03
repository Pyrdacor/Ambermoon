using Ambermoon.Data;
using System;
using System.Drawing;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class EventIdSelectionForm : Form
    {
        readonly Map map;
        readonly int initialSelectedIndex;
        readonly ToolTip toolTip = new ToolTip();
        bool initialized = false;
        public uint EventId => (uint)comboBoxEvents.SelectedIndex;

        class EventInfo
        {
            readonly string title;
            readonly Event @event;
            public string Description
            {
                get
                {
                    if (@event == null)
                        return "Remove the event";

                    string description = title;
                    var e = @event.Next;

                    while (e != null)
                    {
                        description += Environment.NewLine + "  -> " + e.ToString();
                        e = e.Next;
                    }

                    return description;
                }
            }

            public EventInfo(int index, Event @event)
            {
                this.@event = @event;
                title = @event == null ? "00: <none>" : $"{index + 1:x2}: {@event}";
            }

            public override string ToString() => title;
        }

        public EventIdSelectionForm(Map map, uint eventId)
        {
            InitializeComponent();

            this.map = map;
            initialSelectedIndex = (int)eventId;
        }

        private void EventIdSelectionForm_Load(object sender, EventArgs e)
        {
            if (map.EventList.Count == 0)
            {
                MessageBox.Show(null, "The map does not contain any events.", "No events", MessageBoxButtons.OK, MessageBoxIcon.Information);
                Close();
                return;
            }

            comboBoxEvents.DrawMode = DrawMode.OwnerDrawFixed;
            comboBoxEvents.DrawItem += comboBoxEvents_DrawItem;
            comboBoxEvents.DropDownClosed += comboBoxEvents_DropDownClosed;
            comboBoxEvents.LostFocus += comboBoxEvents_LostFocus;

            comboBoxEvents.Items.Add(new EventInfo(0, null));

            for (int i = 0; i < map.EventList.Count; ++i)
                comboBoxEvents.Items.Add(new EventInfo(i, map.EventList[i]));

            if (initialSelectedIndex >= comboBoxEvents.Items.Count)
                MessageBox.Show(null, $"The tile's event {initialSelectedIndex:x2} is no longer existent. It is now automatically set to 00.",
                    "Event missing", MessageBoxButtons.OK, MessageBoxIcon.Warning);

            comboBoxEvents.SelectedIndex = initialSelectedIndex % comboBoxEvents.Items.Count;
            initialized = true;
        }

        private void comboBoxEvents_LostFocus(object sender, EventArgs e)
        {
            toolTip.Hide(comboBoxEvents);
        }

        private void comboBoxEvents_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (initialized)
                DialogResult = DialogResult.OK;
        }

        private void comboBoxEvents_DropDownClosed(object sender, EventArgs e)
        {
            toolTip.Hide(comboBoxEvents);
        }

        private void comboBoxEvents_DrawItem(object sender, DrawItemEventArgs e)
        {
            if (e.Index < 0)
                return;

            e.DrawBackground();

            string text = comboBoxEvents.Items[e.Index].ToString();
            string toolTipText = (comboBoxEvents.Items[e.Index] as EventInfo).Description;

            using (var brush = new SolidBrush(e.ForeColor))
            {
                e.Graphics.DrawString(text, e.Font, brush, e.Bounds);
            }

            if ((e.State & DrawItemState.Selected) == DrawItemState.Selected && comboBoxEvents.DroppedDown)
            {
                toolTip.Show(toolTipText, comboBoxEvents, e.Bounds.Right, e.Bounds.Bottom);
            }

            e.DrawFocusRectangle();
        }
    }
}
