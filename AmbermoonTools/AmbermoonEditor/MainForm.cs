using Ambermoon.Data.Legacy;
using System;
using System.Windows.Forms;

namespace AmbermoonEditor
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            var loadForm = new LoadForm();

            if (loadForm.ShowDialog() != DialogResult.OK)
                Close();

            InitializeData(loadForm.GameData);
        }

        private void InitializeData(GameData gameData)
        {
            var overviewControl = new OverviewControl();
            var itemControl = new ItemControl();

            TabPageOverview.Controls.Add(overviewControl);
            TabPageItems.Controls.Add(itemControl);
            // TODO
        }
    }
}
