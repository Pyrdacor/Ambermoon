using Ambermoon.Data.Legacy;
using System.Windows.Forms;
using System.ComponentModel;

namespace AmbermoonEditor
{
    public partial class DataControl : UserControl
    {
        [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
        public GameData GameData { get; set; }

        public DataControl()
        {
            InitializeComponent();
        }
    }
}
