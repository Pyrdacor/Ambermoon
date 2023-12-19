using Ambermoon.Data;

namespace Ambermoon3DMapEditor
{
    public partial class EventEditorForm : Form
    {
        public EventEditorForm()
        {
            InitializeComponent();
        }

        public void InitMap(Map map)
        {
            eventEditor.InitMap(map);
        }
    }
}
