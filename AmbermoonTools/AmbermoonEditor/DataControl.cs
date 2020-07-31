using Ambermoon.Data.Legacy;
using System.Windows.Forms;

namespace AmbermoonEditor
{
    public partial class DataControl : UserControl
    {
        public GameData GameData { get; set; }

        public DataControl()
        {
            InitializeComponent();
        }
    }
}
