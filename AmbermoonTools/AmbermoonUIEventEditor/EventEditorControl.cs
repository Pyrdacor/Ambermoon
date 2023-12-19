using Ambermoon.Data;

namespace AmbermoonUIEventEditor
{
    public partial class EventEditorControl : UserControl
    {
        public EventEditorControl()
        {
            InitializeComponent();
        }

        public void InitMap(Map map)
        {
            eventView.InitMap(map);
        }

        private void eventBrowser_EventDoubleClicked(EventType arg1, Ambermoon.Data.Descriptions.EventDescription arg2)
        {
            eventView.AddBlock(new TeleportEvent() { Type = EventType.Teleport }, 0);
        }
    }
}