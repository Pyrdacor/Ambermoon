using Ambermoon.Data;
using Ambermoon.Data.Descriptions;

namespace AmbermoonUIEventEditor
{
    public partial class EventBrowserControl : UserControl
    {
        public EventBrowserControl()
        {
            InitializeComponent();

            listViewEvents.Groups.AddRange
            (
                new ListViewGroup[]
                {
                    new ListViewGroup("Map Events") { CollapsedState = ListViewGroupCollapsedState.Expanded },
                    new ListViewGroup("Character Events") { CollapsedState = ListViewGroupCollapsedState.Expanded },
                }
            );

            var mapEvents = EventDescriptions.Events.Where(e => e.Value.AllowMaps).Select(e => new EventListItem(e.Key, e.Value, listViewEvents.Groups[0]));
            var charEvents = EventDescriptions.Events.Where(e => e.Value.AllowNPCs).Select(e => new EventListItem(e.Key, e.Value, listViewEvents.Groups[1]));

            unfilteredItems = Enumerable.Concat(mapEvents, charEvents).ToArray();
        }

        private readonly EventListItem[] unfilteredItems;
        public event Action<EventType, EventDescription>? EventDoubleClicked;
        public event Action<EventType, EventDescription>? EventDragged;

        public void ApplyFilter(string filter)
        {
            listViewEvents.Items.Clear();

            foreach (EventListItem item in unfilteredItems)
            {
                if (filter == "" || item.ToString().Contains(filter, StringComparison.InvariantCultureIgnoreCase))
                {
                    listViewEvents.Items.Add(item);
                    item.Group = (ListViewGroup)item.Tag;
                }
            }
        }

        private class EventListItem : ListViewItem
        {
            public EventListItem(EventType eventType, EventDescription eventDescription, ListViewGroup group)
                : base(eventType.ToString())
            {
                EventType = eventType;
                EventDescription = eventDescription;
                Tag = group;
                Group = group;
            }

            public EventType EventType { get; }
            public EventDescription EventDescription { get; }
        }

        private void EventBrowserControl_Load(object sender, EventArgs e)
        {
            var column = listViewEvents.Columns.Add("Events");
            column.Width = listViewEvents.ClientSize.Width;
            listViewEvents.SizeChanged += (_, _) => column.Width = listViewEvents.ClientSize.Width;
            listViewEvents.HideSelection = true;
            listViewEvents.FullRowSelect = true;
            listViewEvents.Cursor = Cursors.Hand;
            listViewEvents.Items.AddRange(unfilteredItems);
        }

        private void listViewEvents_ItemActivate(object sender, EventArgs e)
        {
            var item = listViewEvents.FocusedItem as EventListItem;
            EventDoubleClicked?.Invoke(item!.EventType, item.EventDescription);
        }

        private void listViewEvents_ItemDrag(object sender, ItemDragEventArgs e)
        {
            if (e.Button == MouseButtons.Left && e.Item != null)
            {
                var item = e.Item as EventListItem;
                EventDragged?.Invoke(item!.EventType, item.EventDescription);
            }
        }

        private void textBoxFilter_TextChanged(object sender, EventArgs e)
        {
            ApplyFilter(textBoxFilter.Text);
        }
    }
}
