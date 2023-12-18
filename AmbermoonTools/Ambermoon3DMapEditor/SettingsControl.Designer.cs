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
            checkBoxShowObjects = new CheckBox();
            checkBoxShowWalls = new CheckBox();
            checkBoxShowCeiling = new CheckBox();
            checkBoxShowFloor = new CheckBox();
            checkBoxShowCeilingTexture = new CheckBox();
            checkBoxShowFloorTexture = new CheckBox();
            tabPage2DView = new TabPage();
            tabPageMisc = new TabPage();
            groupBoxDisplayType = new GroupBox();
            radioButtonMiniatureMap = new RadioButton();
            radioButtonDungeonMap = new RadioButton();
            tabControlSettings.SuspendLayout();
            tabPage3DView.SuspendLayout();
            tabPage2DView.SuspendLayout();
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
            tabControlSettings.Size = new Size(819, 173);
            tabControlSettings.TabIndex = 0;
            // 
            // tabPage3DView
            // 
            tabPage3DView.Controls.Add(checkBoxShowObjects);
            tabPage3DView.Controls.Add(checkBoxShowWalls);
            tabPage3DView.Controls.Add(checkBoxShowCeiling);
            tabPage3DView.Controls.Add(checkBoxShowFloor);
            tabPage3DView.Controls.Add(checkBoxShowCeilingTexture);
            tabPage3DView.Controls.Add(checkBoxShowFloorTexture);
            tabPage3DView.Location = new Point(4, 29);
            tabPage3DView.Name = "tabPage3DView";
            tabPage3DView.Padding = new Padding(3);
            tabPage3DView.Size = new Size(811, 140);
            tabPage3DView.TabIndex = 0;
            tabPage3DView.Text = "3D View";
            tabPage3DView.UseVisualStyleBackColor = true;
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
            checkBoxShowCeiling.Location = new Point(15, 105);
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
            checkBoxShowFloor.Location = new Point(15, 75);
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
            checkBoxShowCeilingTexture.Location = new Point(15, 45);
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
            checkBoxShowFloorTexture.Location = new Point(15, 15);
            checkBoxShowFloorTexture.Name = "checkBoxShowFloorTexture";
            checkBoxShowFloorTexture.Size = new Size(117, 24);
            checkBoxShowFloorTexture.TabIndex = 0;
            checkBoxShowFloorTexture.Text = "Floor Texture";
            checkBoxShowFloorTexture.UseVisualStyleBackColor = true;
            // 
            // tabPage2DView
            // 
            tabPage2DView.Controls.Add(groupBoxDisplayType);
            tabPage2DView.Location = new Point(4, 29);
            tabPage2DView.Name = "tabPage2DView";
            tabPage2DView.Padding = new Padding(3);
            tabPage2DView.Size = new Size(811, 140);
            tabPage2DView.TabIndex = 1;
            tabPage2DView.Text = "2D View";
            tabPage2DView.UseVisualStyleBackColor = true;
            // 
            // tabPageMisc
            // 
            tabPageMisc.Location = new Point(4, 29);
            tabPageMisc.Name = "tabPageMisc";
            tabPageMisc.Size = new Size(811, 140);
            tabPageMisc.TabIndex = 2;
            tabPageMisc.Text = "Misc";
            tabPageMisc.UseVisualStyleBackColor = true;
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
            // SettingsControl
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(tabControlSettings);
            Name = "SettingsControl";
            Size = new Size(819, 173);
            tabControlSettings.ResumeLayout(false);
            tabPage3DView.ResumeLayout(false);
            tabPage3DView.PerformLayout();
            tabPage2DView.ResumeLayout(false);
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
    }
}
