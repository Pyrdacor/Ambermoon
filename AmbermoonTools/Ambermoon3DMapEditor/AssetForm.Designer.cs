namespace Ambermoon3DMapEditor
{
    partial class AssetForm
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
            groupBox1 = new GroupBox();
            buttonLeftWall = new Button();
            buttonRightWall = new Button();
            comboBoxWallTravelStates = new ComboBox();
            checkBoxWallBlockAll = new CheckBox();
            comboBoxWallTravelClass = new ComboBox();
            groupBoxOverlay = new GroupBox();
            checkBoxWallTransparency = new CheckBox();
            checkBoxWallBlockSight = new CheckBox();
            panelWallColor = new RenderPanel();
            labelWallColor = new Label();
            labelWallAutomapType = new Label();
            comboBoxWallAutomapType = new ComboBox();
            buttonOverlays = new Button();
            buttonDuplicateWall = new Button();
            buttonDeleteWall = new Button();
            buttonAddWall = new Button();
            comboBoxWalls = new ComboBox();
            panelWallTexture = new RenderPanel();
            buttonTextures = new Button();
            groupBox1.SuspendLayout();
            SuspendLayout();
            // 
            // groupBox1
            // 
            groupBox1.Controls.Add(buttonLeftWall);
            groupBox1.Controls.Add(buttonRightWall);
            groupBox1.Controls.Add(comboBoxWallTravelStates);
            groupBox1.Controls.Add(checkBoxWallBlockAll);
            groupBox1.Controls.Add(comboBoxWallTravelClass);
            groupBox1.Controls.Add(groupBoxOverlay);
            groupBox1.Controls.Add(checkBoxWallTransparency);
            groupBox1.Controls.Add(checkBoxWallBlockSight);
            groupBox1.Controls.Add(panelWallColor);
            groupBox1.Controls.Add(labelWallColor);
            groupBox1.Controls.Add(labelWallAutomapType);
            groupBox1.Controls.Add(comboBoxWallAutomapType);
            groupBox1.Controls.Add(buttonOverlays);
            groupBox1.Controls.Add(buttonDuplicateWall);
            groupBox1.Controls.Add(buttonDeleteWall);
            groupBox1.Controls.Add(buttonAddWall);
            groupBox1.Controls.Add(comboBoxWalls);
            groupBox1.Controls.Add(panelWallTexture);
            groupBox1.Controls.Add(buttonTextures);
            groupBox1.Location = new Point(12, 12);
            groupBox1.Name = "groupBox1";
            groupBox1.Size = new Size(807, 236);
            groupBox1.TabIndex = 0;
            groupBox1.TabStop = false;
            groupBox1.Text = "Walls";
            // 
            // buttonLeftWall
            // 
            buttonLeftWall.Enabled = false;
            buttonLeftWall.Location = new Point(0, 84);
            buttonLeftWall.Name = "buttonLeftWall";
            buttonLeftWall.Size = new Size(18, 48);
            buttonLeftWall.TabIndex = 18;
            buttonLeftWall.Text = "<";
            buttonLeftWall.UseVisualStyleBackColor = true;
            buttonLeftWall.Click += buttonLeftWall_Click;
            // 
            // buttonRightWall
            // 
            buttonRightWall.Enabled = false;
            buttonRightWall.Location = new Point(272, 84);
            buttonRightWall.Name = "buttonRightWall";
            buttonRightWall.Size = new Size(18, 48);
            buttonRightWall.TabIndex = 17;
            buttonRightWall.Text = ">";
            buttonRightWall.UseVisualStyleBackColor = true;
            buttonRightWall.Click += buttonRightWall_Click;
            // 
            // comboBoxWallTravelStates
            // 
            comboBoxWallTravelStates.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxWallTravelStates.FormattingEnabled = true;
            comboBoxWallTravelStates.Items.AddRange(new object[] { "Deny", "Allow" });
            comboBoxWallTravelStates.Location = new Point(453, 192);
            comboBoxWallTravelStates.Name = "comboBoxWallTravelStates";
            comboBoxWallTravelStates.Size = new Size(104, 28);
            comboBoxWallTravelStates.TabIndex = 16;
            comboBoxWallTravelStates.SelectedIndexChanged += comboBoxWallTravelStates_SelectedIndexChanged;
            // 
            // checkBoxWallBlockAll
            // 
            checkBoxWallBlockAll.AutoSize = true;
            checkBoxWallBlockAll.Location = new Point(453, 162);
            checkBoxWallBlockAll.Name = "checkBoxWallBlockAll";
            checkBoxWallBlockAll.Size = new Size(89, 24);
            checkBoxWallBlockAll.TabIndex = 15;
            checkBoxWallBlockAll.Text = "Block All";
            checkBoxWallBlockAll.UseVisualStyleBackColor = true;
            checkBoxWallBlockAll.CheckedChanged += checkBoxBlockAll_CheckedChanged;
            // 
            // comboBoxWallTravelClass
            // 
            comboBoxWallTravelClass.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxWallTravelClass.FormattingEnabled = true;
            comboBoxWallTravelClass.Location = new Point(296, 193);
            comboBoxWallTravelClass.Name = "comboBoxWallTravelClass";
            comboBoxWallTravelClass.Size = new Size(151, 28);
            comboBoxWallTravelClass.TabIndex = 14;
            comboBoxWallTravelClass.SelectedIndexChanged += comboBoxWallTravelClass_SelectedIndexChanged;
            // 
            // groupBoxOverlay
            // 
            groupBoxOverlay.Enabled = false;
            groupBoxOverlay.Location = new Point(563, 17);
            groupBoxOverlay.Name = "groupBoxOverlay";
            groupBoxOverlay.Size = new Size(238, 213);
            groupBoxOverlay.TabIndex = 13;
            groupBoxOverlay.TabStop = false;
            groupBoxOverlay.Text = "Overlay";
            // 
            // checkBoxWallTransparency
            // 
            checkBoxWallTransparency.AutoSize = true;
            checkBoxWallTransparency.Location = new Point(298, 162);
            checkBoxWallTransparency.Name = "checkBoxWallTransparency";
            checkBoxWallTransparency.Size = new Size(117, 24);
            checkBoxWallTransparency.TabIndex = 12;
            checkBoxWallTransparency.Text = "Transparency";
            checkBoxWallTransparency.UseVisualStyleBackColor = true;
            checkBoxWallTransparency.CheckedChanged += checkBoxWallTransparency_CheckedChanged;
            // 
            // checkBoxWallBlockSight
            // 
            checkBoxWallBlockSight.AutoSize = true;
            checkBoxWallBlockSight.Location = new Point(452, 121);
            checkBoxWallBlockSight.Name = "checkBoxWallBlockSight";
            checkBoxWallBlockSight.Size = new Size(105, 24);
            checkBoxWallBlockSight.TabIndex = 11;
            checkBoxWallBlockSight.Text = "Block Sight";
            checkBoxWallBlockSight.UseVisualStyleBackColor = true;
            checkBoxWallBlockSight.CheckedChanged += checkBoxWallBlockSight_CheckedChanged;
            // 
            // panelWallColor
            // 
            panelWallColor.BorderStyle = BorderStyle.Fixed3D;
            panelWallColor.Location = new Point(411, 119);
            panelWallColor.Name = "panelWallColor";
            panelWallColor.Size = new Size(28, 28);
            panelWallColor.TabIndex = 10;
            panelWallColor.Click += panelWallColor_Click;
            panelWallColor.Paint += panelWallColor_Paint;
            // 
            // labelWallColor
            // 
            labelWallColor.AutoSize = true;
            labelWallColor.Location = new Point(294, 122);
            labelWallColor.Name = "labelWallColor";
            labelWallColor.Size = new Size(111, 20);
            labelWallColor.TabIndex = 9;
            labelWallColor.Text = "Minimap Color:";
            // 
            // labelWallAutomapType
            // 
            labelWallAutomapType.AutoSize = true;
            labelWallAutomapType.Location = new Point(296, 83);
            labelWallAutomapType.Name = "labelWallAutomapType";
            labelWallAutomapType.Size = new Size(109, 20);
            labelWallAutomapType.TabIndex = 8;
            labelWallAutomapType.Text = "Automap Type:";
            // 
            // comboBoxWallAutomapType
            // 
            comboBoxWallAutomapType.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxWallAutomapType.FormattingEnabled = true;
            comboBoxWallAutomapType.Location = new Point(411, 80);
            comboBoxWallAutomapType.Name = "comboBoxWallAutomapType";
            comboBoxWallAutomapType.Size = new Size(146, 28);
            comboBoxWallAutomapType.TabIndex = 7;
            comboBoxWallAutomapType.SelectedIndexChanged += comboBoxWallAutomapType_SelectedIndexChanged;
            // 
            // buttonOverlays
            // 
            buttonOverlays.Location = new Point(153, 192);
            buttonOverlays.Name = "buttonOverlays";
            buttonOverlays.Size = new Size(119, 29);
            buttonOverlays.TabIndex = 6;
            buttonOverlays.Text = "Overlays ...";
            buttonOverlays.UseVisualStyleBackColor = true;
            buttonOverlays.Click += buttonOverlays_Click;
            // 
            // buttonDuplicateWall
            // 
            buttonDuplicateWall.Enabled = false;
            buttonDuplicateWall.Location = new Point(521, 26);
            buttonDuplicateWall.Name = "buttonDuplicateWall";
            buttonDuplicateWall.Size = new Size(36, 29);
            buttonDuplicateWall.TabIndex = 5;
            buttonDuplicateWall.Text = "x2";
            buttonDuplicateWall.UseVisualStyleBackColor = true;
            buttonDuplicateWall.Click += buttonDuplicateWall_Click;
            // 
            // buttonDeleteWall
            // 
            buttonDeleteWall.Enabled = false;
            buttonDeleteWall.Location = new Point(487, 26);
            buttonDeleteWall.Name = "buttonDeleteWall";
            buttonDeleteWall.Size = new Size(28, 29);
            buttonDeleteWall.TabIndex = 4;
            buttonDeleteWall.Text = "-";
            buttonDeleteWall.UseVisualStyleBackColor = true;
            buttonDeleteWall.Click += buttonDeleteWall_Click;
            // 
            // buttonAddWall
            // 
            buttonAddWall.Location = new Point(453, 26);
            buttonAddWall.Name = "buttonAddWall";
            buttonAddWall.Size = new Size(28, 29);
            buttonAddWall.TabIndex = 3;
            buttonAddWall.Text = "+";
            buttonAddWall.UseVisualStyleBackColor = true;
            buttonAddWall.Click += buttonAddWall_Click;
            // 
            // comboBoxWalls
            // 
            comboBoxWalls.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxWalls.FormattingEnabled = true;
            comboBoxWalls.Location = new Point(277, 26);
            comboBoxWalls.Name = "comboBoxWalls";
            comboBoxWalls.Size = new Size(170, 28);
            comboBoxWalls.TabIndex = 2;
            comboBoxWalls.SelectedIndexChanged += comboBoxWalls_SelectedIndexChanged;
            // 
            // panelWallTexture
            // 
            panelWallTexture.BackColor = Color.Magenta;
            panelWallTexture.BorderStyle = BorderStyle.Fixed3D;
            panelWallTexture.Location = new Point(18, 26);
            panelWallTexture.Name = "panelWallTexture";
            panelWallTexture.Size = new Size(256, 160);
            panelWallTexture.TabIndex = 1;
            panelWallTexture.Paint += panelWallTexture_Paint;
            // 
            // buttonTextures
            // 
            buttonTextures.Location = new Point(16, 192);
            buttonTextures.Name = "buttonTextures";
            buttonTextures.Size = new Size(119, 29);
            buttonTextures.TabIndex = 0;
            buttonTextures.Text = "Textures ...";
            buttonTextures.UseVisualStyleBackColor = true;
            buttonTextures.Click += buttonTextures_Click;
            // 
            // AssetForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(831, 450);
            Controls.Add(groupBox1);
            MinimumSize = new Size(320, 320);
            Name = "AssetForm";
            StartPosition = FormStartPosition.CenterParent;
            Text = "Assets";
            Load += AssetForm_Load;
            groupBox1.ResumeLayout(false);
            groupBox1.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private GroupBox groupBox1;
        private Button buttonTextures;
        private RenderPanel panelWallTexture;
        private Button buttonAddWall;
        private ComboBox comboBoxWalls;
        private Button buttonDeleteWall;
        private Button buttonDuplicateWall;
        private Button buttonOverlays;
        private Label labelWallAutomapType;
        private ComboBox comboBoxWallAutomapType;
        private Label labelWallColor;
        private RenderPanel panelWallColor;
        private CheckBox checkBoxWallBlockSight;
        private CheckBox checkBoxWallTransparency;
        private GroupBox groupBoxOverlay;
        private ComboBox comboBoxWallTravelClass;
        private CheckBox checkBoxWallBlockAll;
        private ComboBox comboBoxWallTravelStates;
        private Button buttonRightWall;
        private Button buttonLeftWall;
    }
}