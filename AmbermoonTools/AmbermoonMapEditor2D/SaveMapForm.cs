using System;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class SaveMapForm : Form
    {
        public SaveMapForm()
        {
            InitializeComponent();
        }

        public bool Compress => checkBoxCompress.Checked;

        private void buttonSaveToGameData_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.Yes;
        }

        private void buttonSaveToExternalFile_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.No;
        }
    }
}
