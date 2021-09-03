using Ambermoon.Data;
using System;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class EventIdSelectionForm : Form
    {
        readonly Map map;
        readonly int initialSelectedIndex;
        bool initialized = false;
        public uint EventId => (uint)comboBoxEvents.SelectedIndex;

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

            comboBoxEvents.Items.Add("00: <none>");

            for (int i = 0; i < map.EventList.Count; ++i)
                comboBoxEvents.Items.Add($"{i + 1:x2}: {map.EventList[i]}");

            if (initialSelectedIndex >= comboBoxEvents.Items.Count)
                MessageBox.Show(null, $"The tile's event {initialSelectedIndex:x2} is no longer existent. It is now automatically set to 00.",
                    "Event missing", MessageBoxButtons.OK, MessageBoxIcon.Warning);

            comboBoxEvents.SelectedIndex = initialSelectedIndex % comboBoxEvents.Items.Count;
            initialized = true;
        }

        private void comboBoxEvents_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (initialized)
                DialogResult = DialogResult.OK;
        }
    }
}
