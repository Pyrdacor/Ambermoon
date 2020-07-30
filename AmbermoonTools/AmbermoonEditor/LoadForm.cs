using Ambermoon.Data.Legacy;
using LoadPreference = Ambermoon.Data.Legacy.GameData.LoadPreference;
using System;
using System.IO;
using System.Windows.Forms;

namespace AmbermoonEditor
{
    public partial class LoadForm : Form, GameData.ILogger
    {
        public LoadForm()
        {
            InitializeComponent();
        }

        public GameData GameData { get; private set; }

        private void UpdateGameData()
        {
            if (!string.IsNullOrWhiteSpace(textBoxPath.Text))
            {
                ClearLoadInfo();
                labelLoadInfo.Enabled = false;
                textBoxLoadInfo.Enabled = false;
                SetLoadStatus(false);

                string path = textBoxPath.Text;

                try
                {
                    if (!Directory.Exists(path))
                        throw new DirectoryNotFoundException();
                }
                catch
                {
                    AddLoadInfo($"The given directory '{path}' was not found.");
                    return;
                }

                labelLoadInfo.Enabled = true;
                textBoxLoadInfo.Enabled = true;

                try
                {
                    AddLoadInfo($"Reading game data from '{path}' ...");

                    LoadPreference loadPreference = LoadPreference.PreferExtracted;

                    if (radioButtonADF.Checked)
                        loadPreference = LoadPreference.ForceAdf;
                    else if (radioButtonExtracted.Checked)
                        loadPreference = LoadPreference.ForceExtracted;

                    GameData = new GameData(loadPreference, this, false);
                    GameData.Load(path);
                }
                catch (Exception ex)
                {
                    AddLoadInfo("ERROR: " + ex.Message);
                    return;
                }

                SetLoadStatus(true);
            }
        }

        public void Append(string text)
        {
            textBoxLoadInfo.Text += text;
        }

        public void AppendLine(string text)
        {
            AddLoadInfo(text);
        }

        private void ClearLoadInfo()
        {
            textBoxLoadInfo.Text = "";
        }

        private void AddLoadInfo(string text)
        {
            textBoxLoadInfo.AppendText(text + Environment.NewLine);
        }

        private void SetLoadStatus(bool success)
        {
            buttonContinue.Enabled = success;
        }

        private void ButtonBrowse_Click(object sender, EventArgs e)
        {
            var dialog = new FolderBrowserDialog
            {
                SelectedPath = textBoxPath.Text,
                Description = "Select path with game data files",
                ShowNewFolderButton = false,
                UseDescriptionForTitle = true
            };

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                textBoxPath.Text = dialog.SelectedPath;
            }
        }

        private void TextBoxPath_TextChanged(object sender, EventArgs e)
        {
            UpdateGameData();
        }

        private void RadioButtonADF_CheckedChanged(object sender, EventArgs e)
        {
            UpdateGameData();
        }

        private void RadioButtonExtracted_CheckedChanged(object sender, EventArgs e)
        {
            UpdateGameData();
        }

        private void RadioButtonAny_CheckedChanged(object sender, EventArgs e)
        {
            UpdateGameData();
        }

        private void buttonContinue_Click(object sender, EventArgs e)
        {
            DialogResult = DialogResult.OK;
        }
    }
}
