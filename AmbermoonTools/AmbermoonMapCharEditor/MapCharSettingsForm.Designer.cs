namespace AmbermoonMapCharEditor
{
    partial class MapCharSettingsForm
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.pictureBoxGraphic = new System.Windows.Forms.ExtendedPictureBox();
            this.checkBoxAlternateAnimation = new System.Windows.Forms.CheckBox();
            this.labelCombatBackground = new System.Windows.Forms.Label();
            this.numericUpDownCombatBackground = new System.Windows.Forms.NumericUpDown();
            this.pictureBoxCombatBackground = new System.Windows.Forms.PictureBox();
            this.numericUpDownGraphic = new System.Windows.Forms.NumericUpDown();
            this.groupBoxAllowMovement = new System.Windows.Forms.GroupBox();
            this.checkBoxAllowSwim = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowUnused4 = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowUnused3 = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowUnused2 = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowUnused1 = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowSandShip = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowSandLizard = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowBroom = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowFly = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowEagle = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowMagicDisc = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowShip = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowRaft = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowHorse = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowWalk = new System.Windows.Forms.CheckBox();
            this.labelDraw = new System.Windows.Forms.Label();
            this.radioButtonForeground = new System.Windows.Forms.RadioButton();
            this.radioButtonBackground = new System.Windows.Forms.RadioButton();
            this.radioButtonNormal = new System.Windows.Forms.RadioButton();
            this.checkBoxBlockAllMovement = new System.Windows.Forms.CheckBox();
            this.checkBoxHidePlayer = new System.Windows.Forms.CheckBox();
            this.checkBoxBackgroundFlags = new System.Windows.Forms.CheckBox();
            this.checkBoxFloor = new System.Windows.Forms.CheckBox();
            this.checkBoxBlockSight = new System.Windows.Forms.CheckBox();
            this.buttonCancel = new System.Windows.Forms.Button();
            this.buttonApply = new System.Windows.Forms.Button();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxGraphic)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownCombatBackground)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCombatBackground)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownGraphic)).BeginInit();
            this.groupBoxAllowMovement.SuspendLayout();
            this.SuspendLayout();
            // 
            // pictureBoxGraphic
            // 
            this.pictureBoxGraphic.BackColor = System.Drawing.Color.Black;
            this.pictureBoxGraphic.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.pictureBoxGraphic.Location = new System.Drawing.Point(12, 12);
            this.pictureBoxGraphic.Name = "pictureBoxGraphic";
            this.pictureBoxGraphic.Size = new System.Drawing.Size(68, 68);
            this.pictureBoxGraphic.TabIndex = 0;
            this.pictureBoxGraphic.TabStop = false;
            this.pictureBoxGraphic.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            this.pictureBoxGraphic.SizeMode = PictureBoxSizeMode.Zoom;
            // 
            // checkBoxAlternateAnimation
            // 
            this.checkBoxAlternateAnimation.AutoSize = true;
            this.checkBoxAlternateAnimation.Location = new System.Drawing.Point(236, 113);
            this.checkBoxAlternateAnimation.Name = "checkBoxAlternateAnimation";
            this.checkBoxAlternateAnimation.Size = new System.Drawing.Size(133, 19);
            this.checkBoxAlternateAnimation.TabIndex = 2;
            this.checkBoxAlternateAnimation.Text = "Alternate Animation";
            this.checkBoxAlternateAnimation.UseVisualStyleBackColor = true;
            // 
            // labelCombatBackground
            // 
            this.labelCombatBackground.AutoSize = true;
            this.labelCombatBackground.Enabled = false;
            this.labelCombatBackground.Location = new System.Drawing.Point(12, 119);
            this.labelCombatBackground.Name = "labelCombatBackground";
            this.labelCombatBackground.Size = new System.Drawing.Size(120, 15);
            this.labelCombatBackground.TabIndex = 3;
            this.labelCombatBackground.Text = "Combat Background:";
            // 
            // numericUpDownCombatBackground
            // 
            this.numericUpDownCombatBackground.Enabled = false;
            this.numericUpDownCombatBackground.Location = new System.Drawing.Point(138, 116);
            this.numericUpDownCombatBackground.Maximum = new decimal(new int[] {
            15,
            0,
            0,
            0});
            this.numericUpDownCombatBackground.Name = "numericUpDownCombatBackground";
            this.numericUpDownCombatBackground.Size = new System.Drawing.Size(38, 23);
            this.numericUpDownCombatBackground.TabIndex = 4;
            this.numericUpDownCombatBackground.ValueChanged += new System.EventHandler(this.numericUpDownCombatBackground_ValueChanged);
            // 
            // pictureBoxCombatBackground
            // 
            this.pictureBoxCombatBackground.BackColor = System.Drawing.Color.Black;
            this.pictureBoxCombatBackground.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.pictureBoxCombatBackground.Enabled = false;
            this.pictureBoxCombatBackground.Location = new System.Drawing.Point(12, 141);
            this.pictureBoxCombatBackground.Name = "pictureBoxCombatBackground";
            this.pictureBoxCombatBackground.Size = new System.Drawing.Size(324, 99);
            this.pictureBoxCombatBackground.TabIndex = 5;
            this.pictureBoxCombatBackground.TabStop = false;
            // 
            // numericUpDownGraphic
            // 
            this.numericUpDownGraphic.Location = new System.Drawing.Point(12, 83);
            this.numericUpDownGraphic.Name = "numericUpDownGraphic";
            this.numericUpDownGraphic.Size = new System.Drawing.Size(68, 23);
            this.numericUpDownGraphic.TabIndex = 6;
            this.numericUpDownGraphic.ValueChanged += new System.EventHandler(this.numericUpDownGraphic_ValueChanged);
            // 
            // groupBoxAllowMovement
            // 
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowSwim);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowUnused4);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowUnused3);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowUnused2);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowUnused1);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowSandShip);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowSandLizard);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowBroom);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowFly);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowEagle);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowMagicDisc);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowShip);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowRaft);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowHorse);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowWalk);
            this.groupBoxAllowMovement.Location = new System.Drawing.Point(375, 10);
            this.groupBoxAllowMovement.Name = "groupBoxAllowMovement";
            this.groupBoxAllowMovement.Size = new System.Drawing.Size(278, 124);
            this.groupBoxAllowMovement.TabIndex = 12;
            this.groupBoxAllowMovement.TabStop = false;
            this.groupBoxAllowMovement.Text = "Allow Movement";
            // 
            // checkBoxAllowSwim
            // 
            this.checkBoxAllowSwim.AutoSize = true;
            this.checkBoxAllowSwim.Location = new System.Drawing.Point(67, 97);
            this.checkBoxAllowSwim.Name = "checkBoxAllowSwim";
            this.checkBoxAllowSwim.Size = new System.Drawing.Size(55, 19);
            this.checkBoxAllowSwim.TabIndex = 28;
            this.checkBoxAllowSwim.Text = "Swim";
            this.checkBoxAllowSwim.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused4
            // 
            this.checkBoxAllowUnused4.AutoSize = true;
            this.checkBoxAllowUnused4.Location = new System.Drawing.Point(207, 72);
            this.checkBoxAllowUnused4.Name = "checkBoxAllowUnused4";
            this.checkBoxAllowUnused4.Size = new System.Drawing.Size(66, 19);
            this.checkBoxAllowUnused4.TabIndex = 26;
            this.checkBoxAllowUnused4.Text = "Unused";
            this.checkBoxAllowUnused4.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused3
            // 
            this.checkBoxAllowUnused3.AutoSize = true;
            this.checkBoxAllowUnused3.Location = new System.Drawing.Point(207, 47);
            this.checkBoxAllowUnused3.Name = "checkBoxAllowUnused3";
            this.checkBoxAllowUnused3.Size = new System.Drawing.Size(66, 19);
            this.checkBoxAllowUnused3.TabIndex = 25;
            this.checkBoxAllowUnused3.Text = "Unused";
            this.checkBoxAllowUnused3.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused2
            // 
            this.checkBoxAllowUnused2.AutoSize = true;
            this.checkBoxAllowUnused2.Location = new System.Drawing.Point(207, 23);
            this.checkBoxAllowUnused2.Name = "checkBoxAllowUnused2";
            this.checkBoxAllowUnused2.Size = new System.Drawing.Size(66, 19);
            this.checkBoxAllowUnused2.TabIndex = 24;
            this.checkBoxAllowUnused2.Text = "Unused";
            this.checkBoxAllowUnused2.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused1
            // 
            this.checkBoxAllowUnused1.AutoSize = true;
            this.checkBoxAllowUnused1.Location = new System.Drawing.Point(135, 97);
            this.checkBoxAllowUnused1.Name = "checkBoxAllowUnused1";
            this.checkBoxAllowUnused1.Size = new System.Drawing.Size(66, 19);
            this.checkBoxAllowUnused1.TabIndex = 23;
            this.checkBoxAllowUnused1.Text = "Unused";
            this.checkBoxAllowUnused1.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowSandShip
            // 
            this.checkBoxAllowSandShip.AutoSize = true;
            this.checkBoxAllowSandShip.Location = new System.Drawing.Point(135, 72);
            this.checkBoxAllowSandShip.Name = "checkBoxAllowSandShip";
            this.checkBoxAllowSandShip.Size = new System.Drawing.Size(60, 19);
            this.checkBoxAllowSandShip.TabIndex = 22;
            this.checkBoxAllowSandShip.Text = "S-Ship";
            this.checkBoxAllowSandShip.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowSandLizard
            // 
            this.checkBoxAllowSandLizard.AutoSize = true;
            this.checkBoxAllowSandLizard.Location = new System.Drawing.Point(135, 47);
            this.checkBoxAllowSandLizard.Name = "checkBoxAllowSandLizard";
            this.checkBoxAllowSandLizard.Size = new System.Drawing.Size(57, 19);
            this.checkBoxAllowSandLizard.TabIndex = 21;
            this.checkBoxAllowSandLizard.Text = "Lizard";
            this.checkBoxAllowSandLizard.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowBroom
            // 
            this.checkBoxAllowBroom.AutoSize = true;
            this.checkBoxAllowBroom.Location = new System.Drawing.Point(135, 23);
            this.checkBoxAllowBroom.Name = "checkBoxAllowBroom";
            this.checkBoxAllowBroom.Size = new System.Drawing.Size(62, 19);
            this.checkBoxAllowBroom.TabIndex = 20;
            this.checkBoxAllowBroom.Text = "Broom";
            this.checkBoxAllowBroom.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowFly
            // 
            this.checkBoxAllowFly.AutoSize = true;
            this.checkBoxAllowFly.Location = new System.Drawing.Point(67, 72);
            this.checkBoxAllowFly.Name = "checkBoxAllowFly";
            this.checkBoxAllowFly.Size = new System.Drawing.Size(41, 19);
            this.checkBoxAllowFly.TabIndex = 19;
            this.checkBoxAllowFly.Text = "Fly";
            this.checkBoxAllowFly.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowEagle
            // 
            this.checkBoxAllowEagle.AutoSize = true;
            this.checkBoxAllowEagle.Location = new System.Drawing.Point(67, 47);
            this.checkBoxAllowEagle.Name = "checkBoxAllowEagle";
            this.checkBoxAllowEagle.Size = new System.Drawing.Size(54, 19);
            this.checkBoxAllowEagle.TabIndex = 18;
            this.checkBoxAllowEagle.Text = "Eagle";
            this.checkBoxAllowEagle.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowMagicDisc
            // 
            this.checkBoxAllowMagicDisc.AutoSize = true;
            this.checkBoxAllowMagicDisc.Location = new System.Drawing.Point(67, 23);
            this.checkBoxAllowMagicDisc.Name = "checkBoxAllowMagicDisc";
            this.checkBoxAllowMagicDisc.Size = new System.Drawing.Size(48, 19);
            this.checkBoxAllowMagicDisc.TabIndex = 17;
            this.checkBoxAllowMagicDisc.Text = "Disc";
            this.checkBoxAllowMagicDisc.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowShip
            // 
            this.checkBoxAllowShip.AutoSize = true;
            this.checkBoxAllowShip.Location = new System.Drawing.Point(9, 97);
            this.checkBoxAllowShip.Name = "checkBoxAllowShip";
            this.checkBoxAllowShip.Size = new System.Drawing.Size(49, 19);
            this.checkBoxAllowShip.TabIndex = 16;
            this.checkBoxAllowShip.Text = "Ship";
            this.checkBoxAllowShip.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowRaft
            // 
            this.checkBoxAllowRaft.AutoSize = true;
            this.checkBoxAllowRaft.Location = new System.Drawing.Point(9, 72);
            this.checkBoxAllowRaft.Name = "checkBoxAllowRaft";
            this.checkBoxAllowRaft.Size = new System.Drawing.Size(47, 19);
            this.checkBoxAllowRaft.TabIndex = 15;
            this.checkBoxAllowRaft.Text = "Raft";
            this.checkBoxAllowRaft.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowHorse
            // 
            this.checkBoxAllowHorse.AutoSize = true;
            this.checkBoxAllowHorse.Location = new System.Drawing.Point(9, 47);
            this.checkBoxAllowHorse.Name = "checkBoxAllowHorse";
            this.checkBoxAllowHorse.Size = new System.Drawing.Size(57, 19);
            this.checkBoxAllowHorse.TabIndex = 14;
            this.checkBoxAllowHorse.Text = "Horse";
            this.checkBoxAllowHorse.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowWalk
            // 
            this.checkBoxAllowWalk.AutoSize = true;
            this.checkBoxAllowWalk.Location = new System.Drawing.Point(9, 23);
            this.checkBoxAllowWalk.Name = "checkBoxAllowWalk";
            this.checkBoxAllowWalk.Size = new System.Drawing.Size(52, 19);
            this.checkBoxAllowWalk.TabIndex = 13;
            this.checkBoxAllowWalk.Text = "Walk";
            this.checkBoxAllowWalk.UseVisualStyleBackColor = true;
            // 
            // labelDraw
            // 
            this.labelDraw.AutoSize = true;
            this.labelDraw.Location = new System.Drawing.Point(81, 12);
            this.labelDraw.Name = "labelDraw";
            this.labelDraw.Size = new System.Drawing.Size(37, 15);
            this.labelDraw.TabIndex = 31;
            this.labelDraw.Text = "Draw:";
            // 
            // radioButtonForeground
            // 
            this.radioButtonForeground.AutoSize = true;
            this.radioButtonForeground.Location = new System.Drawing.Point(121, 62);
            this.radioButtonForeground.Name = "radioButtonForeground";
            this.radioButtonForeground.Size = new System.Drawing.Size(87, 19);
            this.radioButtonForeground.TabIndex = 30;
            this.radioButtonForeground.Text = "Foreground";
            this.radioButtonForeground.UseVisualStyleBackColor = true;
            // 
            // radioButtonBackground
            // 
            this.radioButtonBackground.AutoSize = true;
            this.radioButtonBackground.Location = new System.Drawing.Point(121, 36);
            this.radioButtonBackground.Name = "radioButtonBackground";
            this.radioButtonBackground.Size = new System.Drawing.Size(89, 19);
            this.radioButtonBackground.TabIndex = 29;
            this.radioButtonBackground.Text = "Background";
            this.radioButtonBackground.UseVisualStyleBackColor = true;
            // 
            // radioButtonNormal
            // 
            this.radioButtonNormal.AutoSize = true;
            this.radioButtonNormal.Checked = true;
            this.radioButtonNormal.Location = new System.Drawing.Point(121, 11);
            this.radioButtonNormal.Name = "radioButtonNormal";
            this.radioButtonNormal.Size = new System.Drawing.Size(65, 19);
            this.radioButtonNormal.TabIndex = 28;
            this.radioButtonNormal.TabStop = true;
            this.radioButtonNormal.Text = "Normal";
            this.radioButtonNormal.UseVisualStyleBackColor = true;
            // 
            // checkBoxBlockAllMovement
            // 
            this.checkBoxBlockAllMovement.AutoSize = true;
            this.checkBoxBlockAllMovement.Location = new System.Drawing.Point(236, 63);
            this.checkBoxBlockAllMovement.Name = "checkBoxBlockAllMovement";
            this.checkBoxBlockAllMovement.Size = new System.Drawing.Size(133, 19);
            this.checkBoxBlockAllMovement.TabIndex = 27;
            this.checkBoxBlockAllMovement.Text = "Block All Movement";
            this.checkBoxBlockAllMovement.UseVisualStyleBackColor = true;
            this.checkBoxBlockAllMovement.CheckedChanged += new System.EventHandler(this.checkBoxBlockAllMovement_CheckedChanged);
            // 
            // checkBoxHidePlayer
            // 
            this.checkBoxHidePlayer.AutoSize = true;
            this.checkBoxHidePlayer.Location = new System.Drawing.Point(236, 37);
            this.checkBoxHidePlayer.Name = "checkBoxHidePlayer";
            this.checkBoxHidePlayer.Size = new System.Drawing.Size(86, 19);
            this.checkBoxHidePlayer.TabIndex = 26;
            this.checkBoxHidePlayer.Text = "Hide Player";
            this.checkBoxHidePlayer.UseVisualStyleBackColor = true;
            // 
            // checkBoxBackgroundFlags
            // 
            this.checkBoxBackgroundFlags.AutoSize = true;
            this.checkBoxBackgroundFlags.Location = new System.Drawing.Point(121, 88);
            this.checkBoxBackgroundFlags.Name = "checkBoxBackgroundFlags";
            this.checkBoxBackgroundFlags.Size = new System.Drawing.Size(164, 19);
            this.checkBoxBackgroundFlags.TabIndex = 25;
            this.checkBoxBackgroundFlags.Text = "Use Background Tile Flags";
            this.checkBoxBackgroundFlags.UseVisualStyleBackColor = true;
            // 
            // checkBoxFloor
            // 
            this.checkBoxFloor.AutoSize = true;
            this.checkBoxFloor.Location = new System.Drawing.Point(291, 88);
            this.checkBoxFloor.Name = "checkBoxFloor";
            this.checkBoxFloor.Size = new System.Drawing.Size(64, 19);
            this.checkBoxFloor.TabIndex = 24;
            this.checkBoxFloor.Text = "Is Floor";
            this.checkBoxFloor.UseVisualStyleBackColor = true;
            // 
            // checkBoxBlockSight
            // 
            this.checkBoxBlockSight.AutoSize = true;
            this.checkBoxBlockSight.Location = new System.Drawing.Point(236, 12);
            this.checkBoxBlockSight.Name = "checkBoxBlockSight";
            this.checkBoxBlockSight.Size = new System.Drawing.Size(85, 19);
            this.checkBoxBlockSight.TabIndex = 23;
            this.checkBoxBlockSight.Text = "Block Sight";
            this.checkBoxBlockSight.UseVisualStyleBackColor = true;
            // 
            // buttonCancel
            // 
            this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonCancel.Location = new System.Drawing.Point(578, 217);
            this.buttonCancel.Name = "buttonCancel";
            this.buttonCancel.Size = new System.Drawing.Size(75, 23);
            this.buttonCancel.TabIndex = 32;
            this.buttonCancel.Text = "Cancel";
            this.buttonCancel.UseVisualStyleBackColor = true;
            // 
            // buttonApply
            // 
            this.buttonApply.Location = new System.Drawing.Point(497, 217);
            this.buttonApply.Name = "buttonApply";
            this.buttonApply.Size = new System.Drawing.Size(75, 23);
            this.buttonApply.TabIndex = 33;
            this.buttonApply.Text = "Apply";
            this.buttonApply.UseVisualStyleBackColor = true;
            this.buttonApply.Click += new System.EventHandler(this.buttonApply_Click);
            // 
            // MapCharSettingsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(665, 248);
            this.Controls.Add(this.buttonApply);
            this.Controls.Add(this.buttonCancel);
            this.Controls.Add(this.labelDraw);
            this.Controls.Add(this.radioButtonForeground);
            this.Controls.Add(this.radioButtonBackground);
            this.Controls.Add(this.radioButtonNormal);
            this.Controls.Add(this.checkBoxBlockAllMovement);
            this.Controls.Add(this.checkBoxHidePlayer);
            this.Controls.Add(this.checkBoxBackgroundFlags);
            this.Controls.Add(this.checkBoxFloor);
            this.Controls.Add(this.checkBoxBlockSight);
            this.Controls.Add(this.groupBoxAllowMovement);
            this.Controls.Add(this.numericUpDownGraphic);
            this.Controls.Add(this.pictureBoxCombatBackground);
            this.Controls.Add(this.numericUpDownCombatBackground);
            this.Controls.Add(this.labelCombatBackground);
            this.Controls.Add(this.checkBoxAlternateAnimation);
            this.Controls.Add(this.pictureBoxGraphic);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.MaximizeBox = false;
            this.Name = "MapCharSettingsForm";
            this.Text = "Character settings";
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxGraphic)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownCombatBackground)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBoxCombatBackground)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownGraphic)).EndInit();
            this.groupBoxAllowMovement.ResumeLayout(false);
            this.groupBoxAllowMovement.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private ExtendedPictureBox pictureBoxGraphic;
        private CheckBox checkBoxAlternateAnimation;
        private Label labelCombatBackground;
        private NumericUpDown numericUpDownCombatBackground;
        private PictureBox pictureBoxCombatBackground;
        private NumericUpDown numericUpDownGraphic;
        private GroupBox groupBoxAllowMovement;
        private CheckBox checkBoxAllowSwim;
        private CheckBox checkBoxAllowUnused4;
        private CheckBox checkBoxAllowUnused3;
        private CheckBox checkBoxAllowUnused2;
        private CheckBox checkBoxAllowUnused1;
        private CheckBox checkBoxAllowSandShip;
        private CheckBox checkBoxAllowSandLizard;
        private CheckBox checkBoxAllowBroom;
        private CheckBox checkBoxAllowFly;
        private CheckBox checkBoxAllowEagle;
        private CheckBox checkBoxAllowMagicDisc;
        private CheckBox checkBoxAllowShip;
        private CheckBox checkBoxAllowRaft;
        private CheckBox checkBoxAllowHorse;
        private CheckBox checkBoxAllowWalk;
        private Label labelDraw;
        private RadioButton radioButtonForeground;
        private RadioButton radioButtonBackground;
        private RadioButton radioButtonNormal;
        private CheckBox checkBoxBlockAllMovement;
        private CheckBox checkBoxHidePlayer;
        private CheckBox checkBoxBackgroundFlags;
        private CheckBox checkBoxFloor;
        private CheckBox checkBoxBlockSight;
        private Button buttonCancel;
        private Button buttonApply;
    }
}