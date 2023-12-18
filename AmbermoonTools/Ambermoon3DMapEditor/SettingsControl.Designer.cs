namespace Ambermoon3DMapEditor
{
    partial class SettingsControl
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
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

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            tabControlSettings = new TabControl();
            tabPage3DView = new TabPage();
            checkBoxNoObjectClip = new CheckBox();
            checkBoxNoWallClip = new CheckBox();
            checkBoxSpeedBoost = new CheckBox();
            checkBoxNoClip = new CheckBox();
            checkBoxShowObjectTextures = new CheckBox();
            checkBoxShowWallTextures = new CheckBox();
            checkBoxShowObjects = new CheckBox();
            checkBoxShowWalls = new CheckBox();
            checkBoxShowCeiling = new CheckBox();
            checkBoxShowFloor = new CheckBox();
            checkBoxShowCeilingTexture = new CheckBox();
            checkBoxShowFloorTexture = new CheckBox();
            tabPage2DView = new TabPage();
            groupBox1 = new GroupBox();
            sliderZoomLevel = new Slider();
            groupBoxDisplayType = new GroupBox();
            radioButtonDungeonMap = new RadioButton();
            radioButtonMiniatureMap = new RadioButton();
            tabPageMisc = new TabPage();
            tabControlSettings.SuspendLayout();
            tabPage3DView.SuspendLayout();
            tabPage2DView.SuspendLayout();
            groupBox1.SuspendLayout();
            groupBoxDisplayType.SuspendLayout();
            SuspendLayout();
            // 
            // tabControlSettings
            // 
            tabControlSettings.Controls.Add(tabPage3DView);
            tabControlSettings.Controls.Add(tabPage2DView);
            tabControlSettings.Controls.Add(tabPageMisc);
            tabControlSettings.Dock = DockStyle.Fill;
            tabControlSettings.Location = new Point(0, 0);
            tabControlSettings.Name = "tabControlSettings";
            tabControlSettings.SelectedIndex = 0;
            tabControlSettings.Size = new Size(819, 172);
            tabControlSettings.TabIndex = 0;
            // 
            // tabPage3DView
            // 
            tabPage3DView.Controls.Add(checkBoxNoObjectClip);
            tabPage3DView.Controls.Add(checkBoxNoWallClip);
            tabPage3DView.Controls.Add(checkBoxSpeedBoost);
            tabPage3DView.Controls.Add(checkBoxNoClip);
            tabPage3DView.Controls.Add(checkBoxShowObjectTextures);
            tabPage3DView.Controls.Add(checkBoxShowWallTextures);
            tabPage3DView.Controls.Add(checkBoxShowObjects);
            tabPage3DView.Controls.Add(checkBoxShowWalls);
            tabPage3DView.Controls.Add(checkBoxShowCeiling);
            tabPage3DView.Controls.Add(checkBoxShowFloor);
            tabPage3DView.Controls.Add(checkBoxShowCeilingTexture);
            tabPage3DView.Controls.Add(checkBoxShowFloorTexture);
            tabPage3DView.Location = new Point(4, 29);
            tabPage3DView.Name = "tabPage3DView";
            tabPage3DView.Padding = new Padding(3);
            tabPage3DView.Size = new Size(811, 139);
            tabPage3DView.TabIndex = 0;
            tabPage3DView.Text = "3D View";
            tabPage3DView.UseVisualStyleBackColor = true;
            // 
            // checkBoxNoObjectClip
            // 
            checkBoxNoObjectClip.AutoSize = true;
            checkBoxNoObjectClip.Checked = true;
            checkBoxNoObjectClip.CheckState = CheckState.Checked;
            checkBoxNoObjectClip.Location = new Point(344, 105);
            checkBoxNoObjectClip.Name = "checkBoxNoObjectClip";
            checkBoxNoObjectClip.Size = new Size(129, 24);
            checkBoxNoObjectClip.TabIndex = 11;
            checkBoxNoObjectClip.Text = "No Object Clip";
            checkBoxNoObjectClip.UseVisualStyleBackColor = true;
            checkBoxNoObjectClip.CheckedChanged += checkBoxNoObjectClip_CheckedChanged;
            // 
            // checkBoxNoWallClip
            // 
            checkBoxNoWallClip.AutoSize = true;
            checkBoxNoWallClip.Checked = true;
            checkBoxNoWallClip.CheckState = CheckState.Checked;
            checkBoxNoWallClip.Location = new Point(344, 75);
            checkBoxNoWallClip.Name = "checkBoxNoWallClip";
            checkBoxNoWallClip.Size = new Size(114, 24);
            checkBoxNoWallClip.TabIndex = 10;
            checkBoxNoWallClip.Text = "No Wall Clip";
            checkBoxNoWallClip.UseVisualStyleBackColor = true;
            checkBoxNoWallClip.CheckedChanged += checkBoxNoWallClip_CheckedChanged;
            // 
            // checkBoxSpeedBoost
            // 
            checkBoxSpeedBoost.AutoSize = true;
            checkBoxSpeedBoost.Checked = true;
            checkBoxSpeedBoost.CheckState = CheckState.Checked;
            checkBoxSpeedBoost.Location = new Point(344, 45);
            checkBoxSpeedBoost.Name = "checkBoxSpeedBoost";
            checkBoxSpeedBoost.Size = new Size(115, 24);
            checkBoxSpeedBoost.TabIndex = 9;
            checkBoxSpeedBoost.Text = "Speed Boost";
            checkBoxSpeedBoost.UseVisualStyleBackColor = true;
            // 
            // checkBoxNoClip
            // 
            checkBoxNoClip.AutoSize = true;
            checkBoxNoClip.Location = new Point(344, 15);
            checkBoxNoClip.Name = "checkBoxNoClip";
            checkBoxNoClip.Size = new Size(81, 24);
            checkBoxNoClip.TabIndex = 8;
            checkBoxNoClip.Text = "No Clip";
            checkBoxNoClip.ThreeState = true;
            checkBoxNoClip.UseVisualStyleBackColor = true;
            checkBoxNoClip.CheckedChanged += checkBoxNoClip_CheckedChanged;
            checkBoxNoClip.CheckStateChanged += checkBoxNoClip_CheckStateChanged;
            // 
            // checkBoxShowObjectTextures
            // 
            checkBoxShowObjectTextures.AutoSize = true;
            checkBoxShowObjectTextures.Checked = true;
            checkBoxShowObjectTextures.CheckState = CheckState.Checked;
            checkBoxShowObjectTextures.Location = new Point(161, 105);
            checkBoxShowObjectTextures.Name = "checkBoxShowObjectTextures";
            checkBoxShowObjectTextures.Size = new Size(173, 24);
            checkBoxShowObjectTextures.TabIndex = 7;
            checkBoxShowObjectTextures.Text = "Show Object Textures";
            checkBoxShowObjectTextures.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowWallTextures
            // 
            checkBoxShowWallTextures.AutoSize = true;
            checkBoxShowWallTextures.Checked = true;
            checkBoxShowWallTextures.CheckState = CheckState.Checked;
            checkBoxShowWallTextures.Location = new Point(161, 75);
            checkBoxShowWallTextures.Name = "checkBoxShowWallTextures";
            checkBoxShowWallTextures.Size = new Size(158, 24);
            checkBoxShowWallTextures.TabIndex = 6;
            checkBoxShowWallTextures.Text = "Show Wall Textures";
            checkBoxShowWallTextures.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowObjects
            // 
            checkBoxShowObjects.AutoSize = true;
            checkBoxShowObjects.Checked = true;
            checkBoxShowObjects.CheckState = CheckState.Checked;
            checkBoxShowObjects.Location = new Point(161, 45);
            checkBoxShowObjects.Name = "checkBoxShowObjects";
            checkBoxShowObjects.Size = new Size(121, 24);
            checkBoxShowObjects.TabIndex = 5;
            checkBoxShowObjects.Text = "Show Objects";
            checkBoxShowObjects.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowWalls
            // 
            checkBoxShowWalls.AutoSize = true;
            checkBoxShowWalls.Checked = true;
            checkBoxShowWalls.CheckState = CheckState.Checked;
            checkBoxShowWalls.Location = new Point(161, 15);
            checkBoxShowWalls.Name = "checkBoxShowWalls";
            checkBoxShowWalls.Size = new Size(106, 24);
            checkBoxShowWalls.TabIndex = 4;
            checkBoxShowWalls.Text = "Show Walls";
            checkBoxShowWalls.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowCeiling
            // 
            checkBoxShowCeiling.AutoSize = true;
            checkBoxShowCeiling.Checked = true;
            checkBoxShowCeiling.CheckState = CheckState.Checked;
            checkBoxShowCeiling.Location = new Point(15, 45);
            checkBoxShowCeiling.Name = "checkBoxShowCeiling";
            checkBoxShowCeiling.Size = new Size(117, 24);
            checkBoxShowCeiling.TabIndex = 3;
            checkBoxShowCeiling.Text = "Show Ceiling";
            checkBoxShowCeiling.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowFloor
            // 
            checkBoxShowFloor.AutoSize = true;
            checkBoxShowFloor.Checked = true;
            checkBoxShowFloor.CheckState = CheckState.Checked;
            checkBoxShowFloor.Location = new Point(15, 15);
            checkBoxShowFloor.Name = "checkBoxShowFloor";
            checkBoxShowFloor.Size = new Size(105, 24);
            checkBoxShowFloor.TabIndex = 2;
            checkBoxShowFloor.Text = "Show Floor";
            checkBoxShowFloor.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowCeilingTexture
            // 
            checkBoxShowCeilingTexture.AutoSize = true;
            checkBoxShowCeilingTexture.Checked = true;
            checkBoxShowCeilingTexture.CheckState = CheckState.Checked;
            checkBoxShowCeilingTexture.Location = new Point(15, 105);
            checkBoxShowCeilingTexture.Name = "checkBoxShowCeilingTexture";
            checkBoxShowCeilingTexture.Size = new Size(129, 24);
            checkBoxShowCeilingTexture.TabIndex = 1;
            checkBoxShowCeilingTexture.Text = "Ceiling Texture";
            checkBoxShowCeilingTexture.UseVisualStyleBackColor = true;
            // 
            // checkBoxShowFloorTexture
            // 
            checkBoxShowFloorTexture.AutoSize = true;
            checkBoxShowFloorTexture.Checked = true;
            checkBoxShowFloorTexture.CheckState = CheckState.Checked;
            checkBoxShowFloorTexture.Location = new Point(15, 75);
            checkBoxShowFloorTexture.Name = "checkBoxShowFloorTexture";
            checkBoxShowFloorTexture.Size = new Size(117, 24);
            checkBoxShowFloorTexture.TabIndex = 0;
            checkBoxShowFloorTexture.Text = "Floor Texture";
            checkBoxShowFloorTexture.UseVisualStyleBackColor = true;
            // 
            // tabPage2DView
            // 
            tabPage2DView.Controls.Add(groupBox1);
            tabPage2DView.Controls.Add(groupBoxDisplayType);
            tabPage2DView.Location = new Point(4, 29);
            tabPage2DView.Name = "tabPage2DView";
            tabPage2DView.Padding = new Padding(3);
            tabPage2DView.Size = new Size(811, 139);
            tabPage2DView.TabIndex = 1;
            tabPage2DView.Text = "2D View";
            tabPage2DView.UseVisualStyleBackColor = true;
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(sliderZoomLevel);
            groupBox1.Location = new Point(292, 15);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(274, 94);
            groupBox1.TabIndex = 8;
            groupBox1.TabStop = false;
            groupBox1.Text = "Zoom Level";
            // 
            // sliderZoomLevel
            // 
            sliderZoomLevel.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            sliderZoomLevel.Location = new Point(6, 26);
            sliderZoomLevel.Maximum = 4;
            sliderZoomLevel.Minimum = 1;
            sliderZoomLevel.Name = "sliderZoomLevel";
            sliderZoomLevel.Size = new Size(262, 56);
            sliderZoomLevel.TabIndex = 9;
            sliderZoomLevel.Value = 1;
            // 
            // groupBoxDisplayType
            // 
            groupBoxDisplayType.Controls.Add(radioButtonDungeonMap);
            groupBoxDisplayType.Controls.Add(radioButtonMiniatureMap);
            groupBoxDisplayType.Location = new Point(12, 15);
            groupBoxDisplayType.Name = "groupBoxDisplayType";
            groupBoxDisplayType.Size = new Size(274, 63);
            groupBoxDisplayType.TabIndex = 7;
            groupBoxDisplayType.TabStop = false;
            groupBoxDisplayType.Text = "Display Type";
            // 
            // radioButtonDungeonMap
            // 
            radioButtonDungeonMap.AutoSize = true;
            radioButtonDungeonMap.Location = new Point(143, 26);
            radioButtonDungeonMap.Name = "radioButtonDungeonMap";
            radioButtonDungeonMap.Size = new Size(125, 24);
            radioButtonDungeonMap.TabIndex = 1;
            radioButtonDungeonMap.TabStop = true;
            radioButtonDungeonMap.Text = "Dungeon Map";
            radioButtonDungeonMap.UseVisualStyleBackColor = true;
            // 
            // radioButtonMiniatureMap
            // 
            radioButtonMiniatureMap.AutoSize = true;
            radioButtonMiniatureMap.Checked = true;
            radioButtonMiniatureMap.Location = new Point(10, 26);
            radioButtonMiniatureMap.Name = "radioButtonMiniatureMap";
            radioButtonMiniatureMap.Size = new Size(127, 24);
            radioButtonMiniatureMap.TabIndex = 0;
            radioButtonMiniatureMap.TabStop = true;
            radioButtonMiniatureMap.Text = "Miniature Map";
            radioButtonMiniatureMap.UseVisualStyleBackColor = true;
            // 
            // tabPageMisc
            // 
            tabPageMisc.Location = new Point(4, 29);
            tabPageMisc.Name = "tabPageMisc";
            tabPageMisc.Size = new Size(811, 139);
            tabPageMisc.TabIndex = 2;
            tabPageMisc.Text = "Misc";
            tabPageMisc.UseVisualStyleBackColor = true;
            // 
            // SettingsControl
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(tabControlSettings);
            MaximumSize = new Size(8000, 172);
            MinimumSize = new Size(0, 172);
            Name = "SettingsControl";
            Size = new Size(819, 172);
            Load += SettingsControl_Load;
            tabControlSettings.ResumeLayout(false);
            tabPage3DView.ResumeLayout(false);
            tabPage3DView.PerformLayout();
            tabPage2DView.ResumeLayout(false);
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            groupBoxDisplayType.ResumeLayout(false);
            groupBoxDisplayType.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private TabControl tabControlSettings;
        private TabPage tabPage3DView;
        private TabPage tabPage2DView;
        private TabPage tabPageMisc;
        private CheckBox checkBoxShowFloorTexture;
        private CheckBox checkBoxShowCeilingTexture;
        private CheckBox checkBoxShowCeiling;
        private CheckBox checkBoxShowFloor;
        private CheckBox checkBoxShowObjects;
        private CheckBox checkBoxShowWalls;
        private GroupBox groupBoxDisplayType;
        private RadioButton radioButtonDungeonMap;
        private RadioButton radioButtonMiniatureMap;
        private CheckBox checkBoxShowObjectTextures;
        private CheckBox checkBoxShowWallTextures;
        private CheckBox checkBoxSpeedBoost;
        private CheckBox checkBoxNoClip;
        private CheckBox checkBoxNoObjectClip;
        private CheckBox checkBoxNoWallClip;
        private Slider sliderZoomLevel;
        private GroupBox groupBox1;
    }
}
