﻿namespace AmbermoonMapCharEditor
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
			groupBoxCharProperties = new GroupBox();
			buttonMore = new Button();
			checkBoxOnlyMoveWhenSeePlayer = new CheckBox();
			checkBoxStationary = new CheckBox();
			checkBoxTextPopup = new CheckBox();
			checkBoxUseTileset = new CheckBox();
			checkBoxRandomMovement = new CheckBox();
			buttonAdd = new Button();
			buttonRemove = new Button();
			panel1 = new Panel();
			groupBoxCharProperties.SuspendLayout();
			SuspendLayout();
			// 
			// groupBoxCharProperties
			// 
			groupBoxCharProperties.Anchor = AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
			groupBoxCharProperties.Controls.Add(buttonMore);
			groupBoxCharProperties.Controls.Add(checkBoxOnlyMoveWhenSeePlayer);
			groupBoxCharProperties.Controls.Add(checkBoxStationary);
			groupBoxCharProperties.Controls.Add(checkBoxTextPopup);
			groupBoxCharProperties.Controls.Add(checkBoxUseTileset);
			groupBoxCharProperties.Controls.Add(checkBoxRandomMovement);
			groupBoxCharProperties.Location = new Point(3, 127);
			groupBoxCharProperties.Name = "groupBoxCharProperties";
			groupBoxCharProperties.Size = new Size(472, 104);
			groupBoxCharProperties.TabIndex = 2;
			groupBoxCharProperties.TabStop = false;
			groupBoxCharProperties.Text = "Properties";
			// 
			// buttonMore
			// 
			buttonMore.Anchor = AnchorStyles.Top | AnchorStyles.Right;
			buttonMore.Location = new Point(391, 71);
			buttonMore.Name = "buttonMore";
			buttonMore.Size = new Size(75, 27);
			buttonMore.TabIndex = 5;
			buttonMore.Text = "More ...";
			buttonMore.UseVisualStyleBackColor = true;
			buttonMore.Click += buttonMore_Click;
			// 
			// checkBoxOnlyMoveWhenSeePlayer
			// 
			checkBoxOnlyMoveWhenSeePlayer.AutoSize = true;
			checkBoxOnlyMoveWhenSeePlayer.Location = new Point(6, 72);
			checkBoxOnlyMoveWhenSeePlayer.Name = "checkBoxOnlyMoveWhenSeePlayer";
			checkBoxOnlyMoveWhenSeePlayer.Size = new Size(174, 19);
			checkBoxOnlyMoveWhenSeePlayer.TabIndex = 9;
			checkBoxOnlyMoveWhenSeePlayer.Text = "Only Move When See Player";
			checkBoxOnlyMoveWhenSeePlayer.UseVisualStyleBackColor = true;
			checkBoxOnlyMoveWhenSeePlayer.CheckedChanged += checkBoxOnlyMoveWhenSeePlayer_CheckedChanged;
			// 
			// checkBoxStationary
			// 
			checkBoxStationary.AutoSize = true;
			checkBoxStationary.Location = new Point(174, 47);
			checkBoxStationary.Name = "checkBoxStationary";
			checkBoxStationary.Size = new Size(79, 19);
			checkBoxStationary.TabIndex = 8;
			checkBoxStationary.Text = "Stationary";
			checkBoxStationary.UseVisualStyleBackColor = true;
			checkBoxStationary.CheckedChanged += checkBoxStationary_CheckedChanged;
			// 
			// checkBoxTextPopup
			// 
			checkBoxTextPopup.AutoSize = true;
			checkBoxTextPopup.Location = new Point(6, 47);
			checkBoxTextPopup.Name = "checkBoxTextPopup";
			checkBoxTextPopup.Size = new Size(85, 19);
			checkBoxTextPopup.TabIndex = 7;
			checkBoxTextPopup.Text = "Text Popup";
			checkBoxTextPopup.UseVisualStyleBackColor = true;
			checkBoxTextPopup.CheckedChanged += checkBoxTextPopup_CheckedChanged;
			// 
			// checkBoxUseTileset
			// 
			checkBoxUseTileset.AutoSize = true;
			checkBoxUseTileset.Location = new Point(174, 22);
			checkBoxUseTileset.Name = "checkBoxUseTileset";
			checkBoxUseTileset.Size = new Size(81, 19);
			checkBoxUseTileset.TabIndex = 6;
			checkBoxUseTileset.Text = "Use Tileset";
			checkBoxUseTileset.UseVisualStyleBackColor = true;
			checkBoxUseTileset.CheckedChanged += checkBoxUseTileset_CheckedChanged;
			// 
			// checkBoxRandomMovement
			// 
			checkBoxRandomMovement.AutoSize = true;
			checkBoxRandomMovement.Location = new Point(6, 22);
			checkBoxRandomMovement.Name = "checkBoxRandomMovement";
			checkBoxRandomMovement.Size = new Size(132, 19);
			checkBoxRandomMovement.TabIndex = 5;
			checkBoxRandomMovement.Text = "Random Movement";
			checkBoxRandomMovement.UseVisualStyleBackColor = true;
			checkBoxRandomMovement.CheckedChanged += checkBoxRandomMovement_CheckedChanged;
			// 
			// buttonAdd
			// 
			buttonAdd.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
			buttonAdd.Location = new Point(318, 102);
			buttonAdd.Name = "buttonAdd";
			buttonAdd.Size = new Size(75, 29);
			buttonAdd.TabIndex = 4;
			buttonAdd.Text = "Add";
			buttonAdd.UseVisualStyleBackColor = true;
			buttonAdd.Click += buttonAdd_Click;
			// 
			// buttonRemove
			// 
			buttonRemove.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
			buttonRemove.Location = new Point(399, 102);
			buttonRemove.Name = "buttonRemove";
			buttonRemove.Size = new Size(75, 29);
			buttonRemove.TabIndex = 3;
			buttonRemove.Text = "Remove";
			buttonRemove.UseVisualStyleBackColor = true;
			buttonRemove.Click += buttonRemove_Click;
			// 
			// panel1
			// 
			panel1.Dock = DockStyle.Fill;
			panel1.Location = new Point(0, 0);
			panel1.Name = "panel1";
			panel1.Size = new Size(478, 234);
			panel1.TabIndex = 5;
			// 
			// MapCharEditorControl
			// 
			AutoScaleMode = AutoScaleMode.None;
			AutoSize = true;			
			panel1.Controls.Add(buttonAdd);
			panel1.Controls.Add(buttonRemove);
			panel1.Controls.Add(groupBoxCharProperties);
			Controls.Add(panel1);
			Name = "MapCharEditorControl";
			Size = new Size(478, 234);
			groupBoxCharProperties.ResumeLayout(false);
			groupBoxCharProperties.PerformLayout();
			ResumeLayout(false);
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
		private Panel panel1;
	}
}