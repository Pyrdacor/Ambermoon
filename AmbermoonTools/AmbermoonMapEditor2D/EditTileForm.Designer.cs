
namespace AmbermoonMapEditor2D
{
    partial class EditTileForm
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
            this.components = new System.ComponentModel.Container();
            this.panelImage = new System.Windows.Forms.DrawPanel();
            this.numericUpDownImageIndex = new System.Windows.Forms.NumericUpDown();
            this.trackBarFrames = new System.Windows.Forms.TrackBar();
            this.checkBoxAlternate = new System.Windows.Forms.CheckBox();
            this.labelFrames = new System.Windows.Forms.Label();
            this.timerAnimation = new System.Windows.Forms.Timer(this.components);
            this.checkBoxBlockSight = new System.Windows.Forms.CheckBox();
            this.checkBoxFloor = new System.Windows.Forms.CheckBox();
            this.checkBoxBackgroundFlags = new System.Windows.Forms.CheckBox();
            this.checkBoxHidePlayer = new System.Windows.Forms.CheckBox();
            this.groupBoxAllowMovement = new System.Windows.Forms.GroupBox();
            this.checkBoxAllowSwim = new System.Windows.Forms.CheckBox();
            this.checkBoxAllowUnused5 = new System.Windows.Forms.CheckBox();
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
            this.checkBoxBlockAllMovement = new System.Windows.Forms.CheckBox();
            this.buttonApply = new System.Windows.Forms.Button();
            this.buttonCancel = new System.Windows.Forms.Button();
            this.comboBoxSitSleep = new System.Windows.Forms.ComboBox();
            this.numericUpDownCombatBackground = new System.Windows.Forms.NumericUpDown();
            this.labelCombatBackground = new System.Windows.Forms.Label();
            this.buttonShowCombatBackground = new System.Windows.Forms.Button();
            this.radioButtonNormal = new System.Windows.Forms.RadioButton();
            this.radioButtonBackground = new System.Windows.Forms.RadioButton();
            this.radioButtonForeground = new System.Windows.Forms.RadioButton();
            this.labelDraw = new System.Windows.Forms.Label();
            this.drawPanelColor = new System.Windows.Forms.DrawPanel();
            this.label1 = new System.Windows.Forms.Label();
            this.contextMenuImage = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.toolStripMenuItemExportImage = new System.Windows.Forms.ToolStripMenuItem();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownImageIndex)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarFrames)).BeginInit();
            this.groupBoxAllowMovement.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownCombatBackground)).BeginInit();
            this.contextMenuImage.SuspendLayout();
            this.SuspendLayout();
            // 
            // panelImage
            // 
            this.panelImage.BackColor = System.Drawing.Color.Black;
            this.panelImage.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.panelImage.ContextMenuStrip = this.contextMenuImage;
            this.panelImage.Location = new System.Drawing.Point(14, 16);
            this.panelImage.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.panelImage.Name = "panelImage";
            this.panelImage.Size = new System.Drawing.Size(41, 47);
            this.panelImage.TabIndex = 0;
            this.panelImage.Paint += new System.Windows.Forms.PaintEventHandler(this.panelImage_Paint);
            // 
            // numericUpDownImageIndex
            // 
            this.numericUpDownImageIndex.Location = new System.Drawing.Point(62, 16);
            this.numericUpDownImageIndex.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.numericUpDownImageIndex.Maximum = new decimal(new int[] {
            2500,
            0,
            0,
            0});
            this.numericUpDownImageIndex.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDownImageIndex.Name = "numericUpDownImageIndex";
            this.numericUpDownImageIndex.Size = new System.Drawing.Size(50, 27);
            this.numericUpDownImageIndex.TabIndex = 1;
            this.numericUpDownImageIndex.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.numericUpDownImageIndex.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDownImageIndex.ValueChanged += new System.EventHandler(this.numericUpDownImageIndex_ValueChanged);
            // 
            // trackBarFrames
            // 
            this.trackBarFrames.Location = new System.Drawing.Point(14, 92);
            this.trackBarFrames.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.trackBarFrames.Maximum = 16;
            this.trackBarFrames.Minimum = 1;
            this.trackBarFrames.Name = "trackBarFrames";
            this.trackBarFrames.Size = new System.Drawing.Size(159, 56);
            this.trackBarFrames.TabIndex = 2;
            this.trackBarFrames.Value = 1;
            this.trackBarFrames.ValueChanged += new System.EventHandler(this.trackBarFrames_ValueChanged);
            // 
            // checkBoxAlternate
            // 
            this.checkBoxAlternate.AutoSize = true;
            this.checkBoxAlternate.Location = new System.Drawing.Point(86, 71);
            this.checkBoxAlternate.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAlternate.Name = "checkBoxAlternate";
            this.checkBoxAlternate.Size = new System.Drawing.Size(92, 24);
            this.checkBoxAlternate.TabIndex = 3;
            this.checkBoxAlternate.Text = "Alternate";
            this.checkBoxAlternate.UseVisualStyleBackColor = true;
            // 
            // labelFrames
            // 
            this.labelFrames.AutoSize = true;
            this.labelFrames.Location = new System.Drawing.Point(14, 72);
            this.labelFrames.Name = "labelFrames";
            this.labelFrames.Size = new System.Drawing.Size(71, 20);
            this.labelFrames.TabIndex = 4;
            this.labelFrames.Text = "Frames: 1";
            // 
            // timerAnimation
            // 
            this.timerAnimation.Interval = 166;
            this.timerAnimation.Tick += new System.EventHandler(this.timerAnimation_Tick);
            // 
            // checkBoxBlockSight
            // 
            this.checkBoxBlockSight.AutoSize = true;
            this.checkBoxBlockSight.Location = new System.Drawing.Point(314, 11);
            this.checkBoxBlockSight.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxBlockSight.Name = "checkBoxBlockSight";
            this.checkBoxBlockSight.Size = new System.Drawing.Size(105, 24);
            this.checkBoxBlockSight.TabIndex = 5;
            this.checkBoxBlockSight.Text = "Block Sight";
            this.checkBoxBlockSight.UseVisualStyleBackColor = true;
            // 
            // checkBoxFloor
            // 
            this.checkBoxFloor.AutoSize = true;
            this.checkBoxFloor.Location = new System.Drawing.Point(377, 112);
            this.checkBoxFloor.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxFloor.Name = "checkBoxFloor";
            this.checkBoxFloor.Size = new System.Drawing.Size(86, 24);
            this.checkBoxFloor.TabIndex = 7;
            this.checkBoxFloor.Text = "Is Floor?";
            this.checkBoxFloor.UseVisualStyleBackColor = true;
            // 
            // checkBoxBackgroundFlags
            // 
            this.checkBoxBackgroundFlags.AutoSize = true;
            this.checkBoxBackgroundFlags.Location = new System.Drawing.Point(183, 112);
            this.checkBoxBackgroundFlags.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxBackgroundFlags.Name = "checkBoxBackgroundFlags";
            this.checkBoxBackgroundFlags.Size = new System.Drawing.Size(204, 24);
            this.checkBoxBackgroundFlags.TabIndex = 8;
            this.checkBoxBackgroundFlags.Text = "Use Background Tile Flags";
            this.checkBoxBackgroundFlags.UseVisualStyleBackColor = true;
            // 
            // checkBoxHidePlayer
            // 
            this.checkBoxHidePlayer.AutoSize = true;
            this.checkBoxHidePlayer.Location = new System.Drawing.Point(314, 44);
            this.checkBoxHidePlayer.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxHidePlayer.Name = "checkBoxHidePlayer";
            this.checkBoxHidePlayer.Size = new System.Drawing.Size(107, 24);
            this.checkBoxHidePlayer.TabIndex = 10;
            this.checkBoxHidePlayer.Text = "Hide Player";
            this.checkBoxHidePlayer.UseVisualStyleBackColor = true;
            // 
            // groupBoxAllowMovement
            // 
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowSwim);
            this.groupBoxAllowMovement.Controls.Add(this.checkBoxAllowUnused5);
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
            this.groupBoxAllowMovement.Location = new System.Drawing.Point(473, 11);
            this.groupBoxAllowMovement.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBoxAllowMovement.Name = "groupBoxAllowMovement";
            this.groupBoxAllowMovement.Padding = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.groupBoxAllowMovement.Size = new System.Drawing.Size(318, 165);
            this.groupBoxAllowMovement.TabIndex = 11;
            this.groupBoxAllowMovement.TabStop = false;
            this.groupBoxAllowMovement.Text = "Allow Movement";
            // 
            // checkBoxAllowSwim
            // 
            this.checkBoxAllowSwim.AutoSize = true;
            this.checkBoxAllowSwim.Location = new System.Drawing.Point(77, 129);
            this.checkBoxAllowSwim.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowSwim.Name = "checkBoxAllowSwim";
            this.checkBoxAllowSwim.Size = new System.Drawing.Size(67, 24);
            this.checkBoxAllowSwim.TabIndex = 28;
            this.checkBoxAllowSwim.Text = "Swim";
            this.checkBoxAllowSwim.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused5
            // 
            this.checkBoxAllowUnused5.AutoSize = true;
            this.checkBoxAllowUnused5.Location = new System.Drawing.Point(237, 129);
            this.checkBoxAllowUnused5.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowUnused5.Name = "checkBoxAllowUnused5";
            this.checkBoxAllowUnused5.Size = new System.Drawing.Size(80, 24);
            this.checkBoxAllowUnused5.TabIndex = 27;
            this.checkBoxAllowUnused5.Text = "Unused";
            this.checkBoxAllowUnused5.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused4
            // 
            this.checkBoxAllowUnused4.AutoSize = true;
            this.checkBoxAllowUnused4.Location = new System.Drawing.Point(237, 96);
            this.checkBoxAllowUnused4.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowUnused4.Name = "checkBoxAllowUnused4";
            this.checkBoxAllowUnused4.Size = new System.Drawing.Size(80, 24);
            this.checkBoxAllowUnused4.TabIndex = 26;
            this.checkBoxAllowUnused4.Text = "Unused";
            this.checkBoxAllowUnused4.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused3
            // 
            this.checkBoxAllowUnused3.AutoSize = true;
            this.checkBoxAllowUnused3.Location = new System.Drawing.Point(237, 63);
            this.checkBoxAllowUnused3.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowUnused3.Name = "checkBoxAllowUnused3";
            this.checkBoxAllowUnused3.Size = new System.Drawing.Size(80, 24);
            this.checkBoxAllowUnused3.TabIndex = 25;
            this.checkBoxAllowUnused3.Text = "Unused";
            this.checkBoxAllowUnused3.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused2
            // 
            this.checkBoxAllowUnused2.AutoSize = true;
            this.checkBoxAllowUnused2.Location = new System.Drawing.Point(237, 31);
            this.checkBoxAllowUnused2.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowUnused2.Name = "checkBoxAllowUnused2";
            this.checkBoxAllowUnused2.Size = new System.Drawing.Size(80, 24);
            this.checkBoxAllowUnused2.TabIndex = 24;
            this.checkBoxAllowUnused2.Text = "Unused";
            this.checkBoxAllowUnused2.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowUnused1
            // 
            this.checkBoxAllowUnused1.AutoSize = true;
            this.checkBoxAllowUnused1.Location = new System.Drawing.Point(154, 129);
            this.checkBoxAllowUnused1.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowUnused1.Name = "checkBoxAllowUnused1";
            this.checkBoxAllowUnused1.Size = new System.Drawing.Size(80, 24);
            this.checkBoxAllowUnused1.TabIndex = 23;
            this.checkBoxAllowUnused1.Text = "Unused";
            this.checkBoxAllowUnused1.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowSandShip
            // 
            this.checkBoxAllowSandShip.AutoSize = true;
            this.checkBoxAllowSandShip.Location = new System.Drawing.Point(154, 96);
            this.checkBoxAllowSandShip.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowSandShip.Name = "checkBoxAllowSandShip";
            this.checkBoxAllowSandShip.Size = new System.Drawing.Size(74, 24);
            this.checkBoxAllowSandShip.TabIndex = 22;
            this.checkBoxAllowSandShip.Text = "S-Ship";
            this.checkBoxAllowSandShip.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowSandLizard
            // 
            this.checkBoxAllowSandLizard.AutoSize = true;
            this.checkBoxAllowSandLizard.Location = new System.Drawing.Point(154, 63);
            this.checkBoxAllowSandLizard.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowSandLizard.Name = "checkBoxAllowSandLizard";
            this.checkBoxAllowSandLizard.Size = new System.Drawing.Size(71, 24);
            this.checkBoxAllowSandLizard.TabIndex = 21;
            this.checkBoxAllowSandLizard.Text = "Lizard";
            this.checkBoxAllowSandLizard.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowBroom
            // 
            this.checkBoxAllowBroom.AutoSize = true;
            this.checkBoxAllowBroom.Location = new System.Drawing.Point(154, 31);
            this.checkBoxAllowBroom.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowBroom.Name = "checkBoxAllowBroom";
            this.checkBoxAllowBroom.Size = new System.Drawing.Size(76, 24);
            this.checkBoxAllowBroom.TabIndex = 20;
            this.checkBoxAllowBroom.Text = "Broom";
            this.checkBoxAllowBroom.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowFly
            // 
            this.checkBoxAllowFly.AutoSize = true;
            this.checkBoxAllowFly.Location = new System.Drawing.Point(77, 96);
            this.checkBoxAllowFly.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowFly.Name = "checkBoxAllowFly";
            this.checkBoxAllowFly.Size = new System.Drawing.Size(49, 24);
            this.checkBoxAllowFly.TabIndex = 19;
            this.checkBoxAllowFly.Text = "Fly";
            this.checkBoxAllowFly.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowEagle
            // 
            this.checkBoxAllowEagle.AutoSize = true;
            this.checkBoxAllowEagle.Location = new System.Drawing.Point(77, 63);
            this.checkBoxAllowEagle.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowEagle.Name = "checkBoxAllowEagle";
            this.checkBoxAllowEagle.Size = new System.Drawing.Size(68, 24);
            this.checkBoxAllowEagle.TabIndex = 18;
            this.checkBoxAllowEagle.Text = "Eagle";
            this.checkBoxAllowEagle.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowMagicDisc
            // 
            this.checkBoxAllowMagicDisc.AutoSize = true;
            this.checkBoxAllowMagicDisc.Location = new System.Drawing.Point(77, 31);
            this.checkBoxAllowMagicDisc.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowMagicDisc.Name = "checkBoxAllowMagicDisc";
            this.checkBoxAllowMagicDisc.Size = new System.Drawing.Size(59, 24);
            this.checkBoxAllowMagicDisc.TabIndex = 17;
            this.checkBoxAllowMagicDisc.Text = "Disc";
            this.checkBoxAllowMagicDisc.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowShip
            // 
            this.checkBoxAllowShip.AutoSize = true;
            this.checkBoxAllowShip.Location = new System.Drawing.Point(10, 129);
            this.checkBoxAllowShip.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowShip.Name = "checkBoxAllowShip";
            this.checkBoxAllowShip.Size = new System.Drawing.Size(60, 24);
            this.checkBoxAllowShip.TabIndex = 16;
            this.checkBoxAllowShip.Text = "Ship";
            this.checkBoxAllowShip.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowRaft
            // 
            this.checkBoxAllowRaft.AutoSize = true;
            this.checkBoxAllowRaft.Location = new System.Drawing.Point(10, 96);
            this.checkBoxAllowRaft.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowRaft.Name = "checkBoxAllowRaft";
            this.checkBoxAllowRaft.Size = new System.Drawing.Size(58, 24);
            this.checkBoxAllowRaft.TabIndex = 15;
            this.checkBoxAllowRaft.Text = "Raft";
            this.checkBoxAllowRaft.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowHorse
            // 
            this.checkBoxAllowHorse.AutoSize = true;
            this.checkBoxAllowHorse.Location = new System.Drawing.Point(10, 63);
            this.checkBoxAllowHorse.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowHorse.Name = "checkBoxAllowHorse";
            this.checkBoxAllowHorse.Size = new System.Drawing.Size(70, 24);
            this.checkBoxAllowHorse.TabIndex = 14;
            this.checkBoxAllowHorse.Text = "Horse";
            this.checkBoxAllowHorse.UseVisualStyleBackColor = true;
            // 
            // checkBoxAllowWalk
            // 
            this.checkBoxAllowWalk.AutoSize = true;
            this.checkBoxAllowWalk.Location = new System.Drawing.Point(10, 31);
            this.checkBoxAllowWalk.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxAllowWalk.Name = "checkBoxAllowWalk";
            this.checkBoxAllowWalk.Size = new System.Drawing.Size(63, 24);
            this.checkBoxAllowWalk.TabIndex = 13;
            this.checkBoxAllowWalk.Text = "Walk";
            this.checkBoxAllowWalk.UseVisualStyleBackColor = true;
            // 
            // checkBoxBlockAllMovement
            // 
            this.checkBoxBlockAllMovement.AutoSize = true;
            this.checkBoxBlockAllMovement.Location = new System.Drawing.Point(314, 79);
            this.checkBoxBlockAllMovement.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.checkBoxBlockAllMovement.Name = "checkBoxBlockAllMovement";
            this.checkBoxBlockAllMovement.Size = new System.Drawing.Size(164, 24);
            this.checkBoxBlockAllMovement.TabIndex = 12;
            this.checkBoxBlockAllMovement.Text = "Block All Movement";
            this.checkBoxBlockAllMovement.UseVisualStyleBackColor = true;
            this.checkBoxBlockAllMovement.CheckedChanged += new System.EventHandler(this.checkBoxBlockAllMovement_CheckedChanged);
            // 
            // buttonApply
            // 
            this.buttonApply.Location = new System.Drawing.Point(14, 144);
            this.buttonApply.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.buttonApply.Name = "buttonApply";
            this.buttonApply.Size = new System.Drawing.Size(78, 33);
            this.buttonApply.TabIndex = 13;
            this.buttonApply.Text = "Apply";
            this.buttonApply.UseVisualStyleBackColor = true;
            this.buttonApply.Click += new System.EventHandler(this.buttonApply_Click);
            // 
            // buttonCancel
            // 
            this.buttonCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.buttonCancel.Location = new System.Drawing.Point(95, 144);
            this.buttonCancel.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.buttonCancel.Name = "buttonCancel";
            this.buttonCancel.Size = new System.Drawing.Size(78, 33);
            this.buttonCancel.TabIndex = 14;
            this.buttonCancel.Text = "Cancel";
            this.buttonCancel.UseVisualStyleBackColor = true;
            // 
            // comboBoxSitSleep
            // 
            this.comboBoxSitSleep.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxSitSleep.FormattingEnabled = true;
            this.comboBoxSitSleep.Items.AddRange(new object[] {
            "Normal",
            "SitLookUp",
            "SitLookRight",
            "SitLookDown",
            "SitLookLeft",
            "Sleep"});
            this.comboBoxSitSleep.Location = new System.Drawing.Point(183, 145);
            this.comboBoxSitSleep.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.comboBoxSitSleep.Name = "comboBoxSitSleep";
            this.comboBoxSitSleep.Size = new System.Drawing.Size(114, 28);
            this.comboBoxSitSleep.TabIndex = 15;
            // 
            // numericUpDownCombatBackground
            // 
            this.numericUpDownCombatBackground.Hexadecimal = true;
            this.numericUpDownCombatBackground.Location = new System.Drawing.Point(383, 144);
            this.numericUpDownCombatBackground.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.numericUpDownCombatBackground.Maximum = new decimal(new int[] {
            15,
            0,
            0,
            0});
            this.numericUpDownCombatBackground.Name = "numericUpDownCombatBackground";
            this.numericUpDownCombatBackground.Size = new System.Drawing.Size(34, 27);
            this.numericUpDownCombatBackground.TabIndex = 16;
            this.numericUpDownCombatBackground.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            this.numericUpDownCombatBackground.ValueChanged += new System.EventHandler(this.numericUpDownCombatBackground_ValueChanged);
            // 
            // labelCombatBackground
            // 
            this.labelCombatBackground.AutoSize = true;
            this.labelCombatBackground.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.labelCombatBackground.Location = new System.Drawing.Point(302, 151);
            this.labelCombatBackground.Name = "labelCombatBackground";
            this.labelCombatBackground.Size = new System.Drawing.Size(87, 20);
            this.labelCombatBackground.TabIndex = 17;
            this.labelCombatBackground.Text = "Combat Bg:";
            // 
            // buttonShowCombatBackground
            // 
            this.buttonShowCombatBackground.Location = new System.Drawing.Point(418, 143);
            this.buttonShowCombatBackground.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.buttonShowCombatBackground.Name = "buttonShowCombatBackground";
            this.buttonShowCombatBackground.Size = new System.Drawing.Size(53, 33);
            this.buttonShowCombatBackground.TabIndex = 18;
            this.buttonShowCombatBackground.Text = "Show";
            this.buttonShowCombatBackground.UseVisualStyleBackColor = true;
            this.buttonShowCombatBackground.Click += new System.EventHandler(this.buttonShowCombatBackground_Click);
            // 
            // radioButtonNormal
            // 
            this.radioButtonNormal.AutoSize = true;
            this.radioButtonNormal.Checked = true;
            this.radioButtonNormal.Location = new System.Drawing.Point(183, 9);
            this.radioButtonNormal.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radioButtonNormal.Name = "radioButtonNormal";
            this.radioButtonNormal.Size = new System.Drawing.Size(80, 24);
            this.radioButtonNormal.TabIndex = 19;
            this.radioButtonNormal.TabStop = true;
            this.radioButtonNormal.Text = "Normal";
            this.radioButtonNormal.UseVisualStyleBackColor = true;
            // 
            // radioButtonBackground
            // 
            this.radioButtonBackground.AutoSize = true;
            this.radioButtonBackground.Location = new System.Drawing.Point(183, 43);
            this.radioButtonBackground.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radioButtonBackground.Name = "radioButtonBackground";
            this.radioButtonBackground.Size = new System.Drawing.Size(109, 24);
            this.radioButtonBackground.TabIndex = 20;
            this.radioButtonBackground.Text = "Background";
            this.radioButtonBackground.UseVisualStyleBackColor = true;
            // 
            // radioButtonForeground
            // 
            this.radioButtonForeground.AutoSize = true;
            this.radioButtonForeground.Location = new System.Drawing.Point(183, 77);
            this.radioButtonForeground.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.radioButtonForeground.Name = "radioButtonForeground";
            this.radioButtonForeground.Size = new System.Drawing.Size(107, 24);
            this.radioButtonForeground.TabIndex = 21;
            this.radioButtonForeground.Text = "Foreground";
            this.radioButtonForeground.UseVisualStyleBackColor = true;
            // 
            // labelDraw
            // 
            this.labelDraw.AutoSize = true;
            this.labelDraw.Location = new System.Drawing.Point(137, 11);
            this.labelDraw.Name = "labelDraw";
            this.labelDraw.Size = new System.Drawing.Size(47, 20);
            this.labelDraw.TabIndex = 22;
            this.labelDraw.Text = "Draw:";
            // 
            // drawPanelColor
            // 
            this.drawPanelColor.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
            this.drawPanelColor.Location = new System.Drawing.Point(141, 40);
            this.drawPanelColor.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.drawPanelColor.Name = "drawPanelColor";
            this.drawPanelColor.Size = new System.Drawing.Size(27, 31);
            this.drawPanelColor.TabIndex = 23;
            this.drawPanelColor.Click += new System.EventHandler(this.drawPanelColor_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(58, 48);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(88, 20);
            this.label1.TabIndex = 24;
            this.label1.Text = "Minimap ->";
            // 
            // contextMenuImage
            // 
            this.contextMenuImage.ImageScalingSize = new System.Drawing.Size(20, 20);
            this.contextMenuImage.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemExportImage});
            this.contextMenuImage.Name = "contextMenuImage";
            this.contextMenuImage.Size = new System.Drawing.Size(135, 28);
            // 
            // toolStripMenuItemExportImage
            // 
            this.toolStripMenuItemExportImage.Name = "toolStripMenuItemExportImage";
            this.toolStripMenuItemExportImage.Size = new System.Drawing.Size(134, 24);
            this.toolStripMenuItemExportImage.Text = "Export ...";
            this.toolStripMenuItemExportImage.Click += new System.EventHandler(this.toolStripMenuItemExportImage_Click);
            // 
            // EditTileForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(798, 188);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.drawPanelColor);
            this.Controls.Add(this.labelDraw);
            this.Controls.Add(this.radioButtonForeground);
            this.Controls.Add(this.radioButtonBackground);
            this.Controls.Add(this.radioButtonNormal);
            this.Controls.Add(this.buttonShowCombatBackground);
            this.Controls.Add(this.labelCombatBackground);
            this.Controls.Add(this.numericUpDownCombatBackground);
            this.Controls.Add(this.comboBoxSitSleep);
            this.Controls.Add(this.buttonCancel);
            this.Controls.Add(this.buttonApply);
            this.Controls.Add(this.checkBoxBlockAllMovement);
            this.Controls.Add(this.groupBoxAllowMovement);
            this.Controls.Add(this.checkBoxHidePlayer);
            this.Controls.Add(this.checkBoxBackgroundFlags);
            this.Controls.Add(this.checkBoxFloor);
            this.Controls.Add(this.checkBoxBlockSight);
            this.Controls.Add(this.labelFrames);
            this.Controls.Add(this.checkBoxAlternate);
            this.Controls.Add(this.trackBarFrames);
            this.Controls.Add(this.numericUpDownImageIndex);
            this.Controls.Add(this.panelImage);
            this.Margin = new System.Windows.Forms.Padding(3, 4, 3, 4);
            this.Name = "EditTileForm";
            this.Text = "Edit Tile";
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.EditTileForm_FormClosed);
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownImageIndex)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.trackBarFrames)).EndInit();
            this.groupBoxAllowMovement.ResumeLayout(false);
            this.groupBoxAllowMovement.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownCombatBackground)).EndInit();
            this.contextMenuImage.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DrawPanel panelImage;
        private System.Windows.Forms.NumericUpDown numericUpDownImageIndex;
        private System.Windows.Forms.TrackBar trackBarFrames;
        private System.Windows.Forms.CheckBox checkBoxAlternate;
        private System.Windows.Forms.Label labelFrames;
        private System.Windows.Forms.Timer timerAnimation;
        private System.Windows.Forms.CheckBox checkBoxBlockSight;
        private System.Windows.Forms.CheckBox checkBoxFloor;
        private System.Windows.Forms.CheckBox checkBoxBackgroundFlags;
        private System.Windows.Forms.CheckBox checkBoxHidePlayer;
        private System.Windows.Forms.GroupBox groupBoxAllowMovement;
        private System.Windows.Forms.CheckBox checkBoxAllowRaft;
        private System.Windows.Forms.CheckBox checkBoxAllowHorse;
        private System.Windows.Forms.CheckBox checkBoxAllowWalk;
        private System.Windows.Forms.CheckBox checkBoxBlockAllMovement;
        private System.Windows.Forms.CheckBox checkBoxAllowMagicDisc;
        private System.Windows.Forms.CheckBox checkBoxAllowShip;
        private System.Windows.Forms.CheckBox checkBoxAllowEagle;
        private System.Windows.Forms.CheckBox checkBoxAllowFly;
        private System.Windows.Forms.CheckBox checkBoxAllowBroom;
        private System.Windows.Forms.Button buttonApply;
        private System.Windows.Forms.Button buttonCancel;
        private System.Windows.Forms.CheckBox checkBoxAllowSandLizard;
        private System.Windows.Forms.CheckBox checkBoxAllowSandShip;
        private System.Windows.Forms.CheckBox checkBoxAllowUnused1;
        private System.Windows.Forms.CheckBox checkBoxAllowUnused5;
        private System.Windows.Forms.CheckBox checkBoxAllowUnused4;
        private System.Windows.Forms.CheckBox checkBoxAllowUnused3;
        private System.Windows.Forms.CheckBox checkBoxAllowUnused2;
        private System.Windows.Forms.CheckBox checkBoxAllowSwim;
        private System.Windows.Forms.ComboBox comboBoxSitSleep;
        private System.Windows.Forms.NumericUpDown numericUpDownCombatBackground;
        private System.Windows.Forms.Label labelCombatBackground;
        private System.Windows.Forms.Button buttonShowCombatBackground;
        private System.Windows.Forms.RadioButton radioButtonNormal;
        private System.Windows.Forms.RadioButton radioButtonBackground;
        private System.Windows.Forms.RadioButton radioButtonForeground;
        private System.Windows.Forms.Label labelDraw;
        private System.Windows.Forms.DrawPanel drawPanelColor;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ContextMenuStrip contextMenuImage;
        private System.Windows.Forms.ToolStripMenuItem toolStripMenuItemExportImage;
    }
}