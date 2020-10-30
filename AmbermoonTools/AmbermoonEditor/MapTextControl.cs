using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;

namespace AmbermoonEditor
{
    public partial class MapTextControl : DataControl
    {
        class TextEntry
        {
            public string Text { get; set; }
        }

        readonly Dictionary<int, List<TextEntry>> _mapTexts = new Dictionary<int, List<TextEntry>>();
        bool isWorldMap = false;
        int currentTextIndex = 0;

        private System.Windows.Forms.ComboBox comboBoxMaps;
        private System.Windows.Forms.Label labelMap;
        private System.Windows.Forms.TextBox textBoxName;
        private System.Windows.Forms.GroupBox groupBoxTexts;
        private System.Windows.Forms.ComboBox comboBoxTexts;
        private System.Windows.Forms.Button buttonRemove;
        private System.Windows.Forms.Button buttonAdd;
        private System.Windows.Forms.TextBox textBoxText;
        private System.Windows.Forms.Label labelName;

        public MapTextControl()
        {

        }

        protected override void InitializeComponent()
        {
            this.comboBoxMaps = new System.Windows.Forms.ComboBox();
            this.labelMap = new System.Windows.Forms.Label();
            this.labelName = new System.Windows.Forms.Label();
            this.textBoxName = new System.Windows.Forms.TextBox();
            this.groupBoxTexts = new System.Windows.Forms.GroupBox();
            this.textBoxText = new System.Windows.Forms.TextBox();
            this.buttonRemove = new System.Windows.Forms.Button();
            this.buttonAdd = new System.Windows.Forms.Button();
            this.comboBoxTexts = new System.Windows.Forms.ComboBox();
            this.groupBoxTexts.SuspendLayout();
            this.SuspendLayout();
            // 
            // comboBoxMaps
            // 
            this.comboBoxMaps.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxMaps.FormattingEnabled = true;
            this.comboBoxMaps.Location = new System.Drawing.Point(62, 9);
            this.comboBoxMaps.Name = "comboBoxMaps";
            this.comboBoxMaps.Size = new System.Drawing.Size(308, 28);
            this.comboBoxMaps.TabIndex = 0;
            this.comboBoxMaps.SelectedIndexChanged += new System.EventHandler(this.ComboBoxMaps_SelectedIndexChanged);
            // 
            // labelMap
            // 
            this.labelMap.AutoSize = true;
            this.labelMap.Location = new System.Drawing.Point(14, 12);
            this.labelMap.Name = "labelMap";
            this.labelMap.Size = new System.Drawing.Size(42, 20);
            this.labelMap.TabIndex = 1;
            this.labelMap.Text = "Map:";
            // 
            // labelName
            // 
            this.labelName.AutoSize = true;
            this.labelName.Location = new System.Drawing.Point(376, 12);
            this.labelName.Name = "labelName";
            this.labelName.Size = new System.Drawing.Size(83, 20);
            this.labelName.TabIndex = 2;
            this.labelName.Text = "Map name:";
            // 
            // textBoxName
            // 
            this.textBoxName.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.textBoxName.Location = new System.Drawing.Point(465, 10);
            this.textBoxName.Name = "textBoxName";
            this.textBoxName.Size = new System.Drawing.Size(312, 27);
            this.textBoxName.TabIndex = 3;
            // 
            // groupBoxTexts
            // 
            this.groupBoxTexts.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBoxTexts.Controls.Add(this.textBoxText);
            this.groupBoxTexts.Controls.Add(this.buttonRemove);
            this.groupBoxTexts.Controls.Add(this.buttonAdd);
            this.groupBoxTexts.Controls.Add(this.comboBoxTexts);
            this.groupBoxTexts.Location = new System.Drawing.Point(14, 43);
            this.groupBoxTexts.Name = "groupBoxTexts";
            this.groupBoxTexts.Size = new System.Drawing.Size(763, 316);
            this.groupBoxTexts.TabIndex = 4;
            this.groupBoxTexts.TabStop = false;
            this.groupBoxTexts.Text = "Texts";
            // 
            // textBoxText
            // 
            this.textBoxText.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.textBoxText.Location = new System.Drawing.Point(17, 61);
            this.textBoxText.Multiline = true;
            this.textBoxText.Name = "textBoxText";
            this.textBoxText.Size = new System.Drawing.Size(730, 237);
            this.textBoxText.TabIndex = 5;
            // 
            // buttonRemove
            // 
            this.buttonRemove.Location = new System.Drawing.Point(210, 25);
            this.buttonRemove.Name = "buttonRemove";
            this.buttonRemove.Size = new System.Drawing.Size(94, 30);
            this.buttonRemove.TabIndex = 1;
            this.buttonRemove.Text = "Remove";
            this.buttonRemove.UseVisualStyleBackColor = true;
            this.buttonRemove.Click += new System.EventHandler(this.ButtonRemove_Click);
            // 
            // buttonAdd
            // 
            this.buttonAdd.Location = new System.Drawing.Point(110, 25);
            this.buttonAdd.Name = "buttonAdd";
            this.buttonAdd.Size = new System.Drawing.Size(94, 30);
            this.buttonAdd.TabIndex = 1;
            this.buttonAdd.Text = "Add";
            this.buttonAdd.UseVisualStyleBackColor = true;
            this.buttonAdd.Click += new System.EventHandler(this.ButtonAdd_Click);
            // 
            // comboBoxTexts
            // 
            this.comboBoxTexts.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxTexts.FormattingEnabled = true;
            this.comboBoxTexts.Location = new System.Drawing.Point(17, 26);
            this.comboBoxTexts.Name = "comboBoxTexts";
            this.comboBoxTexts.Size = new System.Drawing.Size(87, 28);
            this.comboBoxTexts.TabIndex = 0;
            this.comboBoxTexts.SelectedIndexChanged += new System.EventHandler(this.ComboBoxTexts_SelectedIndexChanged);
            // 
            // MapTextControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoSize = true;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.Controls.Add(this.groupBoxTexts);
            this.Controls.Add(this.textBoxName);
            this.Controls.Add(this.labelName);
            this.Controls.Add(this.labelMap);
            this.Controls.Add(this.comboBoxMaps);
            this.Name = "MapTextControl";
            this.Load += new System.EventHandler(this.MapTextControl_Load);
            this.groupBoxTexts.ResumeLayout(false);
            this.groupBoxTexts.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        static bool IsWorldMap(int mapIndex)
        {
            return mapIndex <= 256 ||
                (mapIndex >= 300 && mapIndex <= 336) ||
                (mapIndex >= 513 && mapIndex <= 528);
        }

        private void MapTextControl_Load(object sender, System.EventArgs e)
        {
            bool[] mapTextsAvailable = new bool[3] { false, false, false };

            for (int i = 1; i <= 3; ++i)
            {
                string containerName = $"{i}Map_texts.amb";

                if (!GameData.Files.ContainsKey(containerName))
                    continue;

                mapTextsAvailable[i - 1] = true;

                var container = GameData.Files[containerName];

                foreach (var file in container.Files)
                {
                    _mapTexts.Add(file.Key, TextReader.ReadTexts(file.Value).Select(t => new TextEntry { Text = t }).ToList());
                }
            }

            if (mapTextsAvailable[0])
            {
                for (int i = 1; i <= 256; ++i)
                    comboBoxMaps.Items.Add(i);
                if (!mapTextsAvailable[1])
                    comboBoxMaps.SelectedIndex = 0;
            }
            if (mapTextsAvailable[1])
            {
                for (int i = 257; i <= 299; ++i)
                    comboBoxMaps.Items.Add(i);
                for (int i = 400; i <= 528; ++i)
                    comboBoxMaps.Items.Add(i);
                comboBoxMaps.SelectedIndex = mapTextsAvailable[0] ? 256 : 0;
            }
            if (mapTextsAvailable[2])
            {
                for (int i = 300; i <= 369; ++i)
                    comboBoxMaps.Items.Add(i);
                if (!mapTextsAvailable[0] && !mapTextsAvailable[1])
                    comboBoxMaps.SelectedIndex = 0;
            }
        }

        int MapIndex => (int)comboBoxMaps.SelectedItem;

        private void ComboBoxMaps_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            if (!_mapTexts.TryGetValue(MapIndex, out var texts))
                texts = new List<TextEntry>();
            isWorldMap = IsWorldMap(MapIndex);

            labelName.Enabled = !isWorldMap;
            textBoxName.Enabled = !isWorldMap;
            textBoxName.Text = isWorldMap || texts.Count == 0 ? "" : texts[0].Text;

            int offset = isWorldMap ? 0 : 1;
            comboBoxTexts.Items.Clear();

            for (int i = offset; i < texts.Count; ++i)
            {
                comboBoxTexts.Items.Add(i.ToString("000"));
            }

            textBoxText.Text = comboBoxTexts.Items.Count == 0 ? "" : texts[offset].Text;
            buttonAdd.Enabled = comboBoxTexts.Items.Count < 0xffff - offset;
            buttonRemove.Enabled = comboBoxTexts.Items.Count != 0;

            if (comboBoxTexts.Items.Count != 0)
            {
                comboBoxTexts.SelectedIndex = 0;
                textBoxText.Enabled = true;
            }
            else
            {
                textBoxText.Text = "";
                textBoxText.Enabled = false;
            }
        }

        private void ComboBoxTexts_SelectedIndexChanged(object sender, System.EventArgs e)
        {
            int offset = isWorldMap ? 0 : 1;

            if (!_mapTexts.ContainsKey(MapIndex))
                _mapTexts.Add(MapIndex, new List<TextEntry>());
            else
                _mapTexts[MapIndex][offset + currentTextIndex].Text = textBoxText.Text;

            currentTextIndex = comboBoxTexts.SelectedIndex;

            if (_mapTexts[MapIndex].Count == offset + currentTextIndex)
                _mapTexts[MapIndex].Add(new TextEntry { Text = "<enter text>" });
            textBoxText.Text = _mapTexts[MapIndex][offset + currentTextIndex].Text;
        }

        private void ButtonAdd_Click(object sender, System.EventArgs e)
        {
            int offset = isWorldMap ? 0 : 1;
            comboBoxTexts.Items.Add((offset + comboBoxTexts.Items.Count).ToString("000"));
            comboBoxTexts.SelectedIndex = comboBoxTexts.Items.Count - 1;

            if (comboBoxTexts.Items.Count == 0xffff - offset)
                buttonAdd.Enabled = false;

            textBoxText.Enabled = true;
            buttonRemove.Enabled = true;
        }

        private void ButtonRemove_Click(object sender, System.EventArgs e)
        {
            if (comboBoxTexts.Items.Count != 0)
            {
                int last = Math.Max(0, comboBoxTexts.SelectedIndex - 1);
                comboBoxTexts.Items.RemoveAt(comboBoxTexts.SelectedIndex);
                buttonAdd.Enabled = true;

                if (comboBoxTexts.Items.Count == 0)
                    buttonRemove.Enabled = false;

                if (comboBoxTexts.Items.Count == 0)
                {
                    textBoxText.Text = "";
                    textBoxText.Enabled = false;
                }
                else
                {
                    int offset = isWorldMap ? 0 : 1;

                    for (int i = last + 1; i < comboBoxTexts.Items.Count; ++i)
                        comboBoxTexts.Items[i] = (offset + i).ToString("000");

                    comboBoxTexts.SelectedIndex = last;
                }
            }
        }
    }
}
