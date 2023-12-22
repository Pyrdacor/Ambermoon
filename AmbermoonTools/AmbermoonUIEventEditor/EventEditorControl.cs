using Ambermoon.Data;
using Ambermoon.Data.Descriptions;

namespace AmbermoonUIEventEditor
{
    public partial class EventEditorControl : UserControl
    {
        public EventEditorControl()
        {
            InitializeComponent();
        }

        private Map? map;
        private IConversationPartner? npc;

        public bool ShowMapEvents
        {
            get => eventBrowser.ShowMapEvents;
            set => eventBrowser.ShowMapEvents = value;
        }
        public bool ShowCharEvents
        {
            get => eventBrowser.ShowCharEvents;
            set => eventBrowser.ShowCharEvents = value;
        }

        public void InitMap(Map map)
        {
            this.map = map;
            eventView.InitMap(map);
        }

        public void InitNPC(IConversationPartner npc)
        {
            this.npc = npc;
            eventView.InitNPC(npc);
        }

        private void eventBrowser_EventDoubleClicked(EventType eventType, EventDescription desc)
        {
            if (!desc.AllowAsFirst && eventView.BlockCount == 0)
            {
                MessageBox.Show(this, "The chosen event can not be inserted as a first block and there are no other blocks available. Place a block of a different event type first.", "Unsupported operation", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            var @event = EventDescriptions.EventFactories[eventType]();
            @event.Type = eventType;

            if (desc.ValueDescriptions.Any(d => !d.Hidden) || (desc.AllowAsFirst && !desc.AllowOnlyAsFirst))
            {
                var newEventForm = new EventEditForm(true, @event, map?.Events ?? new List<Event>());

                if (newEventForm.ShowDialog() == DialogResult.OK)
                {
                    AddEvent(newEventForm.StartNewEventChain);
                }
            }
            else
            {
                AddEvent(desc.AllowOnlyAsFirst);
            }

            void AddEvent(bool startNewEventChain)
            {
                if (!startNewEventChain)
                    eventView.AddBlock(@event, eventView.BlockColumnCount - 1);
                else
                    eventView.AddBlock(@event);

                eventView.ScrollLastBlockIntoView();
            }
        }
    }
}