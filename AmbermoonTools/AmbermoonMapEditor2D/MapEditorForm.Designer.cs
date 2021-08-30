
namespace AmbermoonMapEditor2D
{
    partial class MapEditorForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.panelMap = new System.Windows.Forms.Panel();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.groupBoxTileset = new System.Windows.Forms.GroupBox();
            this.comboBoxTilesets = new System.Windows.Forms.ComboBox();
            this.buttonAddTileset = new System.Windows.Forms.Button();
            this.panelTileset = new System.Windows.Forms.Panel();
            this.groupBoxProperties = new System.Windows.Forms.GroupBox();
            this.comboBoxWorld = new System.Windows.Forms.ComboBox();
            this.labelSizeCross = new System.Windows.Forms.Label();
            this.numericUpDownHeight = new System.Windows.Forms.NumericUpDown();
            this.labelSize = new System.Windows.Forms.Label();
            this.numericUpDownWidth = new System.Windows.Forms.NumericUpDown();
            this.buttonResize = new System.Windows.Forms.Button();
            this.buttonToggleMusic = new System.Windows.Forms.Button();
            this.comboBoxMusic = new System.Windows.Forms.ComboBox();
            this.labelMusic = new System.Windows.Forms.Label();
            this.checkBoxWorldSurface = new System.Windows.Forms.CheckBox();
            this.checkBoxMagic = new System.Windows.Forms.CheckBox();
            this.buttonIndoorDefaults = new System.Windows.Forms.Button();
            this.buttonWorldMapDefaults = new System.Windows.Forms.Button();
            this.checkBoxTravelGraphics = new System.Windows.Forms.CheckBox();
            this.checkBoxNoSleepUntilDawn = new System.Windows.Forms.CheckBox();
            this.checkBoxUnknown1 = new System.Windows.Forms.CheckBox();
            this.checkBoxResting = new System.Windows.Forms.CheckBox();
            this.radioButtonDungeon = new System.Windows.Forms.RadioButton();
            this.radioButtonOutdoor = new System.Windows.Forms.RadioButton();
            this.radioButtonIndoor = new System.Windows.Forms.RadioButton();
            this.toolTipIndoor = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipOutdoor = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipDungeon = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipResting = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipNoSleepUntilDawn = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipMagic = new System.Windows.Forms.ToolTip(this.components);
            this.toolTipWorldSurface = new System.Windows.Forms.ToolTip(this.components);
            this.groupBoxCharacters = new System.Windows.Forms.GroupBox();
            this.buttonShowCharacterOnMap = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.pictureBoxCharacterImage = new System.Windows.Forms.PictureBox();
            this.buttonEditCharacter = new System.Windows.Forms.Button();
            this.buttonDeleteCharacter = new System.Windows.Forms.Button();
            this.comboBoxCharacters = new System.Windows.Forms.ComboBox();
            this.groupBoxTileset.SuspendLayout();
            this.groupBoxProperties.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownHeight)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownWidth)).BeginInit();
            this.groupBoxCharacters.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCharacterImage)).BeginInit();
            this.SuspendLayout();
            // 
            // panelMap
            // 
            this.panelMap.AutoScroll = true;
            this.panelMap.BackColor = System.Drawing.Color.Black;
            this.panelMap.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panelMap.Location = new System.Drawing.Point(0, 27);
            this.panelMap.Name = "panelMap";
            this.panelMap.Size = new System.Drawing.Size(804, 484);
            this.panelMap.TabIndex = 0;
            this.panelMap.Paint += new System.Windows.Forms.PaintEventHandler(this.panelMap_Paint);
            // 
            // menuStrip1
            // 
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(1152, 24);
            this.menuStrip1.TabIndex = 1;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // groupBoxTileset
            // 
            this.groupBoxTileset.Controls.Add(this.comboBoxTilesets);
            this.groupBoxTileset.Controls.Add(this.buttonAddTileset);
            this.groupBoxTileset.Controls.Add(this.panelTileset);
            this.groupBoxTileset.Location = new System.Drawing.Point(2, 510);
            this.groupBoxTileset.Name = "groupBoxTileset";
            this.groupBoxTileset.Size = new System.Drawing.Size(802, 200);
            this.groupBoxTileset.TabIndex = 2;
            this.groupBoxTileset.TabStop = false;
            this.groupBoxTileset.Text = "Tileset";
            // 
            // comboBoxTilesets
            // 
            this.comboBoxTilesets.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxTilesets.FormattingEnabled = true;
            this.comboBoxTilesets.Location = new System.Drawing.Point(707, 22);
            this.comboBoxTilesets.Name = "comboBoxTilesets";
            this.comboBoxTilesets.Size = new System.Drawing.Size(89, 23);
            this.comboBoxTilesets.TabIndex = 2;
            // 
            // buttonAddTileset
            // 
            this.buttonAddTileset.Location = new System.Drawing.Point(707, 51);
            this.buttonAddTileset.Name = "buttonAddTileset";
            this.buttonAddTileset.Size = new System.Drawing.Size(89, 23);
            this.buttonAddTileset.TabIndex = 1;
            this.buttonAddTileset.Text = "Add ...";
            this.buttonAddTileset.UseVisualStyleBackColor = true;
            // 
            // panelTileset
            // 
            this.panelTileset.AutoScroll = true;
            this.panelTileset.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panelTileset.Location = new System.Drawing.Point(10, 22);
            this.panelTileset.Name = "panelTileset";
            this.panelTileset.Size = new System.Drawing.Size(691, 168);
            this.panelTileset.TabIndex = 0;
            this.panelTileset.Paint += new System.Windows.Forms.PaintEventHandler(this.panelTileset_Paint);
            // 
            // groupBoxProperties
            // 
            this.groupBoxProperties.Controls.Add(this.comboBoxWorld);
            this.groupBoxProperties.Controls.Add(this.labelSizeCross);
            this.groupBoxProperties.Controls.Add(this.numericUpDownHeight);
            this.groupBoxProperties.Controls.Add(this.labelSize);
            this.groupBoxProperties.Controls.Add(this.numericUpDownWidth);
            this.groupBoxProperties.Controls.Add(this.buttonResize);
            this.groupBoxProperties.Controls.Add(this.buttonToggleMusic);
            this.groupBoxProperties.Controls.Add(this.comboBoxMusic);
            this.groupBoxProperties.Controls.Add(this.labelMusic);
            this.groupBoxProperties.Controls.Add(this.checkBoxWorldSurface);
            this.groupBoxProperties.Controls.Add(this.checkBoxMagic);
            this.groupBoxProperties.Controls.Add(this.buttonIndoorDefaults);
            this.groupBoxProperties.Controls.Add(this.buttonWorldMapDefaults);
            this.groupBoxProperties.Controls.Add(this.checkBoxTravelGraphics);
            this.groupBoxProperties.Controls.Add(this.checkBoxNoSleepUntilDawn);
            this.groupBoxProperties.Controls.Add(this.checkBoxUnknown1);
            this.groupBoxProperties.Controls.Add(this.checkBoxResting);
            this.groupBoxProperties.Controls.Add(this.radioButtonDungeon);
            this.groupBoxProperties.Controls.Add(this.radioButtonOutdoor);
            this.groupBoxProperties.Controls.Add(this.radioButtonIndoor);
            this.groupBoxProperties.Location = new System.Drawing.Point(808, 26);
            this.groupBoxProperties.Name = "groupBoxProperties";
            this.groupBoxProperties.Size = new System.Drawing.Size(338, 224);
            this.groupBoxProperties.TabIndex = 3;
            this.groupBoxProperties.TabStop = false;
            this.groupBoxProperties.Text = "Properties";
            // 
            // comboBoxWorld
            // 
            this.comboBoxWorld.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxWorld.FormattingEnabled = true;
            this.comboBoxWorld.Items.AddRange(new object[] {
            "Lyramion",
            "Forest Moon",
            "Morag"});
            this.comboBoxWorld.Location = new System.Drawing.Point(228, 45);
            this.comboBoxWorld.Name = "comboBoxWorld";
            this.comboBoxWorld.Size = new System.Drawing.Size(104, 23);
            this.comboBoxWorld.TabIndex = 21;
            // 
            // labelSizeCross
            // 
            this.labelSizeCross.AutoSize = true;
            this.labelSizeCross.Location = new System.Drawing.Point(90, 23);
            this.labelSizeCross.Name = "labelSizeCross";
            this.labelSizeCross.Size = new System.Drawing.Size(12, 15);
            this.labelSizeCross.TabIndex = 20;
            this.labelSizeCross.Text = "x";
            // 
            // numericUpDownHeight
            // 
            this.numericUpDownHeight.Enabled = false;
            this.numericUpDownHeight.Location = new System.Drawing.Point(104, 21);
            this.numericUpDownHeight.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numericUpDownHeight.Minimum = new decimal(new int[] {
            9,
            0,
            0,
            0});
            this.numericUpDownHeight.Name = "numericUpDownHeight";
            this.numericUpDownHeight.Size = new System.Drawing.Size(44, 23);
            this.numericUpDownHeight.TabIndex = 19;
            this.numericUpDownHeight.Value = new decimal(new int[] {
            50,
            0,
            0,
            0});
            // 
            // labelSize
            // 
            this.labelSize.AutoSize = true;
            this.labelSize.Location = new System.Drawing.Point(7, 23);
            this.labelSize.Name = "labelSize";
            this.labelSize.Size = new System.Drawing.Size(30, 15);
            this.labelSize.TabIndex = 18;
            this.labelSize.Text = "Size:";
            // 
            // numericUpDownWidth
            // 
            this.numericUpDownWidth.Enabled = false;
            this.numericUpDownWidth.Location = new System.Drawing.Point(43, 20);
            this.numericUpDownWidth.Maximum = new decimal(new int[] {
            200,
            0,
            0,
            0});
            this.numericUpDownWidth.Minimum = new decimal(new int[] {
            11,
            0,
            0,
            0});
            this.numericUpDownWidth.Name = "numericUpDownWidth";
            this.numericUpDownWidth.Size = new System.Drawing.Size(44, 23);
            this.numericUpDownWidth.TabIndex = 17;
            this.numericUpDownWidth.Value = new decimal(new int[] {
            50,
            0,
            0,
            0});
            // 
            // buttonResize
            // 
            this.buttonResize.Location = new System.Drawing.Point(154, 21);
            this.buttonResize.Name = "buttonResize";
            this.buttonResize.Size = new System.Drawing.Size(104, 23);
            this.buttonResize.TabIndex = 16;
            this.buttonResize.Text = "Enable resizing";
            this.buttonResize.UseVisualStyleBackColor = true;
            this.buttonResize.Click += new System.EventHandler(this.buttonResize_Click);
            // 
            // buttonToggleMusic
            // 
            this.buttonToggleMusic.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_play_arrow_black_24;
            this.buttonToggleMusic.Location = new System.Drawing.Point(308, 186);
            this.buttonToggleMusic.Name = "buttonToggleMusic";
            this.buttonToggleMusic.Size = new System.Drawing.Size(24, 24);
            this.buttonToggleMusic.TabIndex = 15;
            this.buttonToggleMusic.UseVisualStyleBackColor = true;
            this.buttonToggleMusic.Click += new System.EventHandler(this.buttonToggleMusic_Click);
            // 
            // comboBoxMusic
            // 
            this.comboBoxMusic.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxMusic.FormattingEnabled = true;
            this.comboBoxMusic.Location = new System.Drawing.Point(55, 187);
            this.comboBoxMusic.Name = "comboBoxMusic";
            this.comboBoxMusic.Size = new System.Drawing.Size(250, 23);
            this.comboBoxMusic.TabIndex = 14;
            this.comboBoxMusic.SelectedIndexChanged += new System.EventHandler(this.comboBoxMusic_SelectedIndexChanged);
            // 
            // labelMusic
            // 
            this.labelMusic.AutoSize = true;
            this.labelMusic.Location = new System.Drawing.Point(7, 190);
            this.labelMusic.Name = "labelMusic";
            this.labelMusic.Size = new System.Drawing.Size(42, 15);
            this.labelMusic.TabIndex = 13;
            this.labelMusic.Text = "Music:";
            // 
            // checkBoxWorldSurface
            // 
            this.checkBoxWorldSurface.AutoSize = true;
            this.checkBoxWorldSurface.Enabled = false;
            this.checkBoxWorldSurface.Location = new System.Drawing.Point(7, 71);
            this.checkBoxWorldSurface.Name = "checkBoxWorldSurface";
            this.checkBoxWorldSurface.Size = new System.Drawing.Size(85, 19);
            this.checkBoxWorldSurface.TabIndex = 12;
            this.checkBoxWorldSurface.Text = "World Map";
            this.checkBoxWorldSurface.UseVisualStyleBackColor = true;
            this.checkBoxWorldSurface.CheckedChanged += new System.EventHandler(this.checkBoxWorldSurface_CheckedChanged);
            // 
            // checkBoxMagic
            // 
            this.checkBoxMagic.AutoSize = true;
            this.checkBoxMagic.Checked = true;
            this.checkBoxMagic.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBoxMagic.Location = new System.Drawing.Point(7, 121);
            this.checkBoxMagic.Name = "checkBoxMagic";
            this.checkBoxMagic.Size = new System.Drawing.Size(92, 19);
            this.checkBoxMagic.TabIndex = 11;
            this.checkBoxMagic.Text = "Allow Magic";
            this.checkBoxMagic.UseVisualStyleBackColor = true;
            // 
            // buttonIndoorDefaults
            // 
            this.buttonIndoorDefaults.Location = new System.Drawing.Point(172, 145);
            this.buttonIndoorDefaults.Name = "buttonIndoorDefaults";
            this.buttonIndoorDefaults.Size = new System.Drawing.Size(160, 23);
            this.buttonIndoorDefaults.TabIndex = 9;
            this.buttonIndoorDefaults.Text = "Use Indoor Defaults";
            this.buttonIndoorDefaults.UseVisualStyleBackColor = true;
            this.buttonIndoorDefaults.Click += new System.EventHandler(this.buttonIndoorDefaults_Click);
            // 
            // buttonWorldMapDefaults
            // 
            this.buttonWorldMapDefaults.Location = new System.Drawing.Point(6, 145);
            this.buttonWorldMapDefaults.Name = "buttonWorldMapDefaults";
            this.buttonWorldMapDefaults.Size = new System.Drawing.Size(160, 23);
            this.buttonWorldMapDefaults.TabIndex = 8;
            this.buttonWorldMapDefaults.Text = "Use World Map Defaults";
            this.buttonWorldMapDefaults.UseVisualStyleBackColor = true;
            this.buttonWorldMapDefaults.Click += new System.EventHandler(this.buttonWorldMapDefaults_Click);
            // 
            // checkBoxTravelGraphics
            // 
            this.checkBoxTravelGraphics.AutoSize = true;
            this.checkBoxTravelGraphics.Enabled = false;
            this.checkBoxTravelGraphics.Location = new System.Drawing.Point(111, 71);
            this.checkBoxTravelGraphics.Name = "checkBoxTravelGraphics";
            this.checkBoxTravelGraphics.Size = new System.Drawing.Size(107, 19);
            this.checkBoxTravelGraphics.TabIndex = 7;
            this.checkBoxTravelGraphics.Text = "Travel Graphics";
            this.checkBoxTravelGraphics.UseVisualStyleBackColor = true;
            // 
            // checkBoxNoSleepUntilDawn
            // 
            this.checkBoxNoSleepUntilDawn.AutoSize = true;
            this.checkBoxNoSleepUntilDawn.Location = new System.Drawing.Point(111, 96);
            this.checkBoxNoSleepUntilDawn.Name = "checkBoxNoSleepUntilDawn";
            this.checkBoxNoSleepUntilDawn.Size = new System.Drawing.Size(134, 19);
            this.checkBoxNoSleepUntilDawn.TabIndex = 6;
            this.checkBoxNoSleepUntilDawn.Text = "No Sleep Until Dawn";
            this.checkBoxNoSleepUntilDawn.UseVisualStyleBackColor = true;
            // 
            // checkBoxUnknown1
            // 
            this.checkBoxUnknown1.AutoSize = true;
            this.checkBoxUnknown1.Enabled = false;
            this.checkBoxUnknown1.Location = new System.Drawing.Point(111, 121);
            this.checkBoxUnknown1.Name = "checkBoxUnknown1";
            this.checkBoxUnknown1.Size = new System.Drawing.Size(77, 19);
            this.checkBoxUnknown1.TabIndex = 5;
            this.checkBoxUnknown1.Text = "Unknown";
            this.checkBoxUnknown1.UseVisualStyleBackColor = true;
            // 
            // checkBoxResting
            // 
            this.checkBoxResting.AutoSize = true;
            this.checkBoxResting.Checked = true;
            this.checkBoxResting.CheckState = System.Windows.Forms.CheckState.Checked;
            this.checkBoxResting.Location = new System.Drawing.Point(7, 96);
            this.checkBoxResting.Name = "checkBoxResting";
            this.checkBoxResting.Size = new System.Drawing.Size(98, 19);
            this.checkBoxResting.TabIndex = 4;
            this.checkBoxResting.Text = "Allow Resting";
            this.checkBoxResting.UseVisualStyleBackColor = true;
            this.checkBoxResting.CheckedChanged += new System.EventHandler(this.checkBoxResting_CheckedChanged);
            // 
            // radioButtonDungeon
            // 
            this.radioButtonDungeon.AutoSize = true;
            this.radioButtonDungeon.Location = new System.Drawing.Point(148, 46);
            this.radioButtonDungeon.Name = "radioButtonDungeon";
            this.radioButtonDungeon.Size = new System.Drawing.Size(74, 19);
            this.radioButtonDungeon.TabIndex = 2;
            this.radioButtonDungeon.Text = "Dungeon";
            this.radioButtonDungeon.UseVisualStyleBackColor = true;
            this.radioButtonDungeon.CheckedChanged += new System.EventHandler(this.radioButtonDungeon_CheckedChanged);
            // 
            // radioButtonOutdoor
            // 
            this.radioButtonOutdoor.AutoSize = true;
            this.radioButtonOutdoor.Location = new System.Drawing.Point(72, 46);
            this.radioButtonOutdoor.Name = "radioButtonOutdoor";
            this.radioButtonOutdoor.Size = new System.Drawing.Size(70, 19);
            this.radioButtonOutdoor.TabIndex = 1;
            this.radioButtonOutdoor.Text = "Outdoor";
            this.radioButtonOutdoor.UseVisualStyleBackColor = true;
            this.radioButtonOutdoor.CheckedChanged += new System.EventHandler(this.radioButtonOutdoor_CheckedChanged);
            // 
            // radioButtonIndoor
            // 
            this.radioButtonIndoor.AutoSize = true;
            this.radioButtonIndoor.Checked = true;
            this.radioButtonIndoor.Location = new System.Drawing.Point(6, 46);
            this.radioButtonIndoor.Name = "radioButtonIndoor";
            this.radioButtonIndoor.Size = new System.Drawing.Size(60, 19);
            this.radioButtonIndoor.TabIndex = 0;
            this.radioButtonIndoor.TabStop = true;
            this.radioButtonIndoor.Text = "Indoor";
            this.radioButtonIndoor.UseVisualStyleBackColor = true;
            this.radioButtonIndoor.CheckedChanged += new System.EventHandler(this.radioButtonIndoor_CheckedChanged);
            // 
            // groupBoxCharacters
            // 
            this.groupBoxCharacters.Controls.Add(this.buttonShowCharacterOnMap);
            this.groupBoxCharacters.Controls.Add(this.label1);
            this.groupBoxCharacters.Controls.Add(this.pictureBoxCharacterImage);
            this.groupBoxCharacters.Controls.Add(this.buttonEditCharacter);
            this.groupBoxCharacters.Controls.Add(this.buttonDeleteCharacter);
            this.groupBoxCharacters.Controls.Add(this.comboBoxCharacters);
            this.groupBoxCharacters.Location = new System.Drawing.Point(808, 256);
            this.groupBoxCharacters.Name = "groupBoxCharacters";
            this.groupBoxCharacters.Size = new System.Drawing.Size(338, 96);
            this.groupBoxCharacters.TabIndex = 4;
            this.groupBoxCharacters.TabStop = false;
            this.groupBoxCharacters.Text = "Monsters && NPCs";
            // 
            // buttonShowCharacterOnMap
            // 
            this.buttonShowCharacterOnMap.Image = global::AmbermoonMapEditor2D.Properties.Resources.round_control_camera_black_24;
            this.buttonShowCharacterOnMap.Location = new System.Drawing.Point(55, 51);
            this.buttonShowCharacterOnMap.Name = "buttonShowCharacterOnMap";
            this.buttonShowCharacterOnMap.Size = new System.Drawing.Size(24, 24);
            this.buttonShowCharacterOnMap.TabIndex = 16;
            this.buttonShowCharacterOnMap.UseVisualStyleBackColor = true;
            this.buttonShowCharacterOnMap.Click += new System.EventHandler(this.buttonShowCharacterOnMap_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(81, 55);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(89, 15);
            this.label1.TabIndex = 4;
            this.label1.Text = "Location: 50, 50";
            // 
            // pictureBoxCharacterImage
            // 
            this.pictureBoxCharacterImage.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.pictureBoxCharacterImage.Location = new System.Drawing.Point(7, 22);
            this.pictureBoxCharacterImage.Name = "pictureBoxCharacterImage";
            this.pictureBoxCharacterImage.Size = new System.Drawing.Size(42, 66);
            this.pictureBoxCharacterImage.TabIndex = 3;
            this.pictureBoxCharacterImage.TabStop = false;
            this.pictureBoxCharacterImage.Click += new System.EventHandler(this.pictureBoxCharacterImage_Click);
            // 
            // buttonEditCharacter
            // 
            this.buttonEditCharacter.Enabled = false;
            this.buttonEditCharacter.Location = new System.Drawing.Point(176, 51);
            this.buttonEditCharacter.Name = "buttonEditCharacter";
            this.buttonEditCharacter.Size = new System.Drawing.Size(75, 23);
            this.buttonEditCharacter.TabIndex = 2;
            this.buttonEditCharacter.Text = "Edit ...";
            this.buttonEditCharacter.UseVisualStyleBackColor = true;
            this.buttonEditCharacter.Click += new System.EventHandler(this.buttonEditCharacter_Click);
            // 
            // buttonDeleteCharacter
            // 
            this.buttonDeleteCharacter.Enabled = false;
            this.buttonDeleteCharacter.Location = new System.Drawing.Point(257, 51);
            this.buttonDeleteCharacter.Name = "buttonDeleteCharacter";
            this.buttonDeleteCharacter.Size = new System.Drawing.Size(75, 23);
            this.buttonDeleteCharacter.TabIndex = 1;
            this.buttonDeleteCharacter.Text = "Delete";
            this.buttonDeleteCharacter.UseVisualStyleBackColor = true;
            this.buttonDeleteCharacter.Click += new System.EventHandler(this.buttonDeleteCharacter_Click);
            // 
            // comboBoxCharacters
            // 
            this.comboBoxCharacters.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxCharacters.FormattingEnabled = true;
            this.comboBoxCharacters.Location = new System.Drawing.Point(55, 22);
            this.comboBoxCharacters.Name = "comboBoxCharacters";
            this.comboBoxCharacters.Size = new System.Drawing.Size(277, 23);
            this.comboBoxCharacters.TabIndex = 0;
            this.comboBoxCharacters.SelectedIndexChanged += new System.EventHandler(this.comboBoxCharacters_SelectedIndexChanged);
            // 
            // MapEditorForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1152, 712);
            this.Controls.Add(this.groupBoxCharacters);
            this.Controls.Add(this.groupBoxProperties);
            this.Controls.Add(this.groupBoxTileset);
            this.Controls.Add(this.panelMap);
            this.Controls.Add(this.menuStrip1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MainMenuStrip = this.menuStrip1;
            this.MaximizeBox = false;
            this.Name = "MapEditorForm";
            this.Text = "Ambermoon Map Editor 2D";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.MapEditorForm_FormClosed);
            this.Load += new System.EventHandler(this.MapEditorForm_Load);
            this.groupBoxTileset.ResumeLayout(false);
            this.groupBoxProperties.ResumeLayout(false);
            this.groupBoxProperties.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownHeight)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownWidth)).EndInit();
            this.groupBoxCharacters.ResumeLayout(false);
            this.groupBoxCharacters.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCharacterImage)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel panelMap;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.GroupBox groupBoxTileset;
        private System.Windows.Forms.Button buttonAddTileset;
        private System.Windows.Forms.Panel panelTileset;
        private System.Windows.Forms.ComboBox comboBoxTilesets;
        private System.Windows.Forms.GroupBox groupBoxProperties;
        private System.Windows.Forms.RadioButton radioButtonOutdoor;
        private System.Windows.Forms.RadioButton radioButtonIndoor;
        private System.Windows.Forms.RadioButton radioButtonDungeon;
        private System.Windows.Forms.ToolTip toolTipIndoor;
        private System.Windows.Forms.ToolTip toolTipOutdoor;
        private System.Windows.Forms.ToolTip toolTipDungeon;
        private System.Windows.Forms.CheckBox checkBoxResting;
        private System.Windows.Forms.CheckBox checkBoxNoSleepUntilDawn;
        private System.Windows.Forms.CheckBox checkBoxUnknown1;
        private System.Windows.Forms.ToolTip toolTipResting;
        private System.Windows.Forms.CheckBox checkBoxTravelGraphics;
        private System.Windows.Forms.ToolTip toolTipNoSleepUntilDawn;
        private System.Windows.Forms.Button buttonIndoorDefaults;
        private System.Windows.Forms.Button buttonWorldMapDefaults;
        private System.Windows.Forms.CheckBox checkBoxMagic;
        private System.Windows.Forms.CheckBox checkBoxWorldSurface;
        private System.Windows.Forms.ToolTip toolTipMagic;
        private System.Windows.Forms.ToolTip toolTipWorldSurface;
        private System.Windows.Forms.ComboBox comboBoxMusic;
        private System.Windows.Forms.Label labelMusic;
        private System.Windows.Forms.Button buttonResize;
        private System.Windows.Forms.Button buttonToggleMusic;
        private System.Windows.Forms.NumericUpDown numericUpDownHeight;
        private System.Windows.Forms.Label labelSize;
        private System.Windows.Forms.NumericUpDown numericUpDownWidth;
        private System.Windows.Forms.Label labelSizeCross;
        private System.Windows.Forms.GroupBox groupBoxCharacters;
        private System.Windows.Forms.ComboBox comboBoxCharacters;
        private System.Windows.Forms.Button buttonDeleteCharacter;
        private System.Windows.Forms.Button buttonEditCharacter;
        private System.Windows.Forms.PictureBox pictureBoxCharacterImage;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button buttonShowCharacterOnMap;
        private System.Windows.Forms.ComboBox comboBoxWorld;
    }
}

