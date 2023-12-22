using Ambermoon.Data;
using Ambermoon.Data.Descriptions;

namespace AmbermoonUIEventEditor
{
    public partial class EventBrowserControl : UserControl
    {
        public EventBrowserControl()
        {
            InitializeComponent();
        }

        private EventListItem[] unfilteredItems = Array.Empty<EventListItem>();
        public bool ShowMapEvents { get; set; } = true;
        public bool ShowCharEvents { get; set; } = true;
        public event Action<EventType, EventDescription>? EventDoubleClicked;
        public event Action<EventType, EventDescription>? EventDragged;

        public void ApplyFilter(string filter)
        {
            listViewEvents.Items.Clear();

            foreach (EventListItem item in unfilteredItems)
            {
                if (filter == "" || item.Text.Contains(filter, StringComparison.InvariantCultureIgnoreCase))
                {
                    listViewEvents.Items.Add(item);
                    item.Group = (ListViewGroup?)item.Tag;
                }
            }
        }

        private class EventListItem : ListViewItem
        {
            public EventListItem(EventType eventType, EventDescription eventDescription, ListViewGroup? group)
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
            if (ShowMapEvents && ShowCharEvents)
            {
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
            else if (ShowMapEvents)
            {
                unfilteredItems = EventDescriptions.Events.Where(e => e.Value.AllowMaps).Select(e => new EventListItem(e.Key, e.Value, null)).ToArray();
            }
            else if (ShowCharEvents)
            {
                unfilteredItems = EventDescriptions.Events.Where(e => e.Value.AllowNPCs).Select(e => new EventListItem(e.Key, e.Value, null)).ToArray();
            }
            else
            {
                throw new InvalidOperationException("At least one of the event categories must be shown: Map or character events.");
            }

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
