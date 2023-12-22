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

        public void InitMap(Map map)
        {
            this.map = map;
            eventView.InitMap(map);
        }

        private void eventBrowser_EventDoubleClicked(EventType eventType, EventDescription desc)
        {
            var @event = EventDescriptions.EventFactories[eventType]();
            @event.Type = eventType;
            var newEventForm = new EventEditForm(true, @event, map?.Events ?? new List<Event>());

            if (newEventForm.ShowDialog() == DialogResult.OK)
            {
                eventView.AddBlock(@event);
            }            
        }
    }
}