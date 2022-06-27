namespace AmbermoonMapCharEditor
{
    partial class MapCharEditorControl
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
            this.groupBoxCharProperties = new System.Windows.Forms.GroupBox();
            this.checkBoxOnlyMoveWhenSeePlayer = new System.Windows.Forms.CheckBox();
            this.checkBoxStationary = new System.Windows.Forms.CheckBox();
            this.checkBoxTextPopup = new System.Windows.Forms.CheckBox();
            this.checkBoxUseTileset = new System.Windows.Forms.CheckBox();
            this.checkBoxRandomMovement = new System.Windows.Forms.CheckBox();
            this.buttonAdd = new System.Windows.Forms.Button();
            this.buttonRemove = new System.Windows.Forms.Button();
            this.buttonGraphic = new System.Windows.Forms.Button();
            this.labelCollision = new System.Windows.Forms.Label();
            this.comboBoxCollisionClasses = new System.Windows.Forms.ComboBox();
            this.groupBoxCharProperties.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBoxCharProperties
            // 
            this.groupBoxCharProperties.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBoxCharProperties.Controls.Add(this.comboBoxCollisionClasses);
            this.groupBoxCharProperties.Controls.Add(this.labelCollision);
            this.groupBoxCharProperties.Controls.Add(this.buttonGraphic);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxOnlyMoveWhenSeePlayer);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxStationary);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxTextPopup);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxUseTileset);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxRandomMovement);
            this.groupBoxCharProperties.Location = new System.Drawing.Point(3, 138);
            this.groupBoxCharProperties.Name = "groupBoxCharProperties";
            this.groupBoxCharProperties.Size = new System.Drawing.Size(243, 119);
            this.groupBoxCharProperties.TabIndex = 2;
            this.groupBoxCharProperties.TabStop = false;
            this.groupBoxCharProperties.Text = "Properties";
            // 
            // checkBoxOnlyMoveWhenSeePlayer
            // 
            this.checkBoxOnlyMoveWhenSeePlayer.AutoSize = true;
            this.checkBoxOnlyMoveWhenSeePlayer.Location = new System.Drawing.Point(6, 72);
            this.checkBoxOnlyMoveWhenSeePlayer.Name = "checkBoxOnlyMoveWhenSeePlayer";
            this.checkBoxOnlyMoveWhenSeePlayer.Size = new System.Drawing.Size(174, 19);
            this.checkBoxOnlyMoveWhenSeePlayer.TabIndex = 9;
            this.checkBoxOnlyMoveWhenSeePlayer.Text = "Only Move When See Player";
            this.checkBoxOnlyMoveWhenSeePlayer.UseVisualStyleBackColor = true;
            this.checkBoxOnlyMoveWhenSeePlayer.CheckedChanged += new System.EventHandler(this.checkBoxOnlyMoveWhenSeePlayer_CheckedChanged);
            // 
            // checkBoxStationary
            // 
            this.checkBoxStationary.AutoSize = true;
            this.checkBoxStationary.Location = new System.Drawing.Point(144, 47);
            this.checkBoxStationary.Name = "checkBoxStationary";
            this.checkBoxStationary.Size = new System.Drawing.Size(79, 19);
            this.checkBoxStationary.TabIndex = 8;
            this.checkBoxStationary.Text = "Stationary";
            this.checkBoxStationary.UseVisualStyleBackColor = true;
            this.checkBoxStationary.CheckedChanged += new System.EventHandler(this.checkBoxStationary_CheckedChanged);
            // 
            // checkBoxTextPopup
            // 
            this.checkBoxTextPopup.AutoSize = true;
            this.checkBoxTextPopup.Location = new System.Drawing.Point(6, 47);
            this.checkBoxTextPopup.Name = "checkBoxTextPopup";
            this.checkBoxTextPopup.Size = new System.Drawing.Size(86, 19);
            this.checkBoxTextPopup.TabIndex = 7;
            this.checkBoxTextPopup.Text = "Text Popup";
            this.checkBoxTextPopup.UseVisualStyleBackColor = true;
            this.checkBoxTextPopup.CheckedChanged += new System.EventHandler(this.checkBoxTextPopup_CheckedChanged);
            // 
            // checkBoxUseTileset
            // 
            this.checkBoxUseTileset.AutoSize = true;
            this.checkBoxUseTileset.Location = new System.Drawing.Point(144, 22);
            this.checkBoxUseTileset.Name = "checkBoxUseTileset";
            this.checkBoxUseTileset.Size = new System.Drawing.Size(82, 19);
            this.checkBoxUseTileset.TabIndex = 6;
            this.checkBoxUseTileset.Text = "Use Tileset";
            this.checkBoxUseTileset.UseVisualStyleBackColor = true;
            this.checkBoxUseTileset.CheckedChanged += new System.EventHandler(this.checkBoxUseTileset_CheckedChanged);
            // 
            // checkBoxRandomMovement
            // 
            this.checkBoxRandomMovement.AutoSize = true;
            this.checkBoxRandomMovement.Location = new System.Drawing.Point(6, 22);
            this.checkBoxRandomMovement.Name = "checkBoxRandomMovement";
            this.checkBoxRandomMovement.Size = new System.Drawing.Size(132, 19);
            this.checkBoxRandomMovement.TabIndex = 5;
            this.checkBoxRandomMovement.Text = "Random Movement";
            this.checkBoxRandomMovement.UseVisualStyleBackColor = true;
            this.checkBoxRandomMovement.CheckedChanged += new System.EventHandler(this.checkBoxRandomMovement_CheckedChanged);
            // 
            // buttonAdd
            // 
            this.buttonAdd.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonAdd.Location = new System.Drawing.Point(91, 114);
            this.buttonAdd.Name = "buttonAdd";
            this.buttonAdd.Size = new System.Drawing.Size(75, 23);
            this.buttonAdd.TabIndex = 4;
            this.buttonAdd.Text = "Add";
            this.buttonAdd.UseVisualStyleBackColor = true;
            // 
            // buttonRemove
            // 
            this.buttonRemove.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonRemove.Location = new System.Drawing.Point(172, 114);
            this.buttonRemove.Name = "buttonRemove";
            this.buttonRemove.Size = new System.Drawing.Size(75, 23);
            this.buttonRemove.TabIndex = 3;
            this.buttonRemove.Text = "Remove";
            this.buttonRemove.UseVisualStyleBackColor = true;
            // 
            // buttonGraphic
            // 
            this.buttonGraphic.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonGraphic.Location = new System.Drawing.Point(180, 64);
            this.buttonGraphic.Name = "buttonGraphic";
            this.buttonGraphic.Size = new System.Drawing.Size(57, 26);
            this.buttonGraphic.TabIndex = 5;
            this.buttonGraphic.Text = "Gfx";
            this.buttonGraphic.UseVisualStyleBackColor = true;
            // 
            // labelCollision
            // 
            this.labelCollision.AutoSize = true;
            this.labelCollision.Location = new System.Drawing.Point(6, 94);
            this.labelCollision.Name = "labelCollision";
            this.labelCollision.Size = new System.Drawing.Size(56, 15);
            this.labelCollision.TabIndex = 10;
            this.labelCollision.Text = "Collision:";
            // 
            // comboBoxCollisionClasses
            // 
            this.comboBoxCollisionClasses.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxCollisionClasses.FormattingEnabled = true;
            this.comboBoxCollisionClasses.Items.AddRange(new object[] {
            "0: Walk",
            "1: Horse",
            "2: Raft",
            "3: Ship",
            "4: Magical Disc",
            "5: Eagle",
            "6: Fly",
            "7: Swim",
            "8: Witch\'s Broom",
            "9: Sand lizard",
            "10: Sand ship"});
            this.comboBoxCollisionClasses.Location = new System.Drawing.Point(68, 91);
            this.comboBoxCollisionClasses.Name = "comboBoxCollisionClasses";
            this.comboBoxCollisionClasses.Size = new System.Drawing.Size(169, 23);
            this.comboBoxCollisionClasses.TabIndex = 11;
            this.comboBoxCollisionClasses.SelectedIndexChanged += new System.EventHandler(this.comboBoxCollisionClasses_SelectedIndexChanged);
            // 
            // MapCharEditorControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.buttonAdd);
            this.Controls.Add(this.buttonRemove);
            this.Controls.Add(this.groupBoxCharProperties);
            this.Name = "MapCharEditorControl";
            this.Size = new System.Drawing.Size(249, 260);
            this.groupBoxCharProperties.ResumeLayout(false);
            this.groupBoxCharProperties.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion
        private GroupBox groupBoxCharProperties;
        private CheckBox checkBoxRandomMovement;
        private CheckBox checkBoxOnlyMoveWhenSeePlayer;
        private CheckBox checkBoxStationary;
        private CheckBox checkBoxTextPopup;
        private CheckBox checkBoxUseTileset;
        private Button buttonAdd;
        private Button buttonRemove;
        private Button buttonGraphic;
        private ComboBox comboBoxCollisionClasses;
        private Label labelCollision;
    }
}