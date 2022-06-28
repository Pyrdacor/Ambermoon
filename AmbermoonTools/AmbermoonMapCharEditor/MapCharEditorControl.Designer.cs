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
            this.buttonMore = new System.Windows.Forms.Button();
            this.checkBoxOnlyMoveWhenSeePlayer = new System.Windows.Forms.CheckBox();
            this.checkBoxStationary = new System.Windows.Forms.CheckBox();
            this.checkBoxTextPopup = new System.Windows.Forms.CheckBox();
            this.checkBoxUseTileset = new System.Windows.Forms.CheckBox();
            this.checkBoxRandomMovement = new System.Windows.Forms.CheckBox();
            this.buttonAdd = new System.Windows.Forms.Button();
            this.buttonRemove = new System.Windows.Forms.Button();
            this.groupBoxCharProperties.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBoxCharProperties
            // 
            this.groupBoxCharProperties.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBoxCharProperties.Controls.Add(this.buttonMore);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxOnlyMoveWhenSeePlayer);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxStationary);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxTextPopup);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxUseTileset);
            this.groupBoxCharProperties.Controls.Add(this.checkBoxRandomMovement);
            this.groupBoxCharProperties.Location = new System.Drawing.Point(3, 135);
            this.groupBoxCharProperties.Name = "groupBoxCharProperties";
            this.groupBoxCharProperties.Size = new System.Drawing.Size(243, 96);
            this.groupBoxCharProperties.TabIndex = 2;
            this.groupBoxCharProperties.TabStop = false;
            this.groupBoxCharProperties.Text = "Properties";
            // 
            // buttonMore
            // 
            this.buttonMore.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonMore.Location = new System.Drawing.Point(180, 67);
            this.buttonMore.Name = "buttonMore";
            this.buttonMore.Size = new System.Drawing.Size(62, 26);
            this.buttonMore.TabIndex = 5;
            this.buttonMore.Text = "More ...";
            this.buttonMore.UseVisualStyleBackColor = true;
            this.buttonMore.Click += new System.EventHandler(this.buttonMore_Click);
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
            this.buttonAdd.Location = new System.Drawing.Point(91, 121);
            this.buttonAdd.Name = "buttonAdd";
            this.buttonAdd.Size = new System.Drawing.Size(75, 22);
            this.buttonAdd.TabIndex = 4;
            this.buttonAdd.Text = "Add";
            this.buttonAdd.UseVisualStyleBackColor = true;
            this.buttonAdd.Click += new System.EventHandler(this.buttonAdd_Click);
            // 
            // buttonRemove
            // 
            this.buttonRemove.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonRemove.Location = new System.Drawing.Point(170, 121);
            this.buttonRemove.Name = "buttonRemove";
            this.buttonRemove.Size = new System.Drawing.Size(75, 22);
            this.buttonRemove.TabIndex = 3;
            this.buttonRemove.Text = "Remove";
            this.buttonRemove.UseVisualStyleBackColor = true;
            this.buttonRemove.Click += new System.EventHandler(this.buttonRemove_Click);
            // 
            // MapCharEditorControl
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.Controls.Add(this.buttonAdd);
            this.Controls.Add(this.buttonRemove);
            this.Controls.Add(this.groupBoxCharProperties);
            this.Name = "MapCharEditorControl";
            this.Size = new System.Drawing.Size(249, 234);
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
        private Button buttonMore;
    }
}