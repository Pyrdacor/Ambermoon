using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using System;
using System.Drawing;
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

            tabControlMain.SelectedIndex = 0;
        }

        private void InitializeData(GameData gameData)
        {
            InitializeTabPage(TabPageOverview, new OverviewControl(), gameData);
            InitializeTabPage(TabPageItems, new ItemControl(), gameData);
            InitializeTabPage(TabPageMapTexts, new MapTextControl(), gameData);
            InitializeTabPage(TabPagePartyMembers, new PartyMemberControl(), gameData);
            InitializeTabPage(TabPageMonsters, new MonsterControl(), gameData);
            InitializeTabPage(TabPageNPCs, new NPCControl(), gameData);

            tabControlMain.SelectedIndex = 0;
        }

        private void InitializeTabPage(TabPage page, DataControl mainControl, GameData gameData)
        {
            mainControl.GameData = gameData;
            mainControl.Dock = DockStyle.Fill;
            page.Controls.Add(mainControl);           
        }

        private void TabControlMain_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}
