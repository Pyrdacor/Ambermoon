using Ambermoon.Data;

namespace AmbermoonUIEventEditor
{
    public partial class EventEditorControl : UserControl
    {
        public EventEditorControl()
        {
            InitializeComponent();
        }

        private void eventBrowser_EventDoubleClicked(EventType arg1, Ambermoon.Data.Descriptions.EventDescription arg2)
        {
            eventView.AddBlock(new Rectangle(10, 10, 200, 80), new ChestEvent() { });
        }
    }
}