
namespace AmbermoonMapEditor3D
{
    partial class OpenMapForm
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
            this.buttonCreateMap = new System.Windows.Forms.Button();
            this.buttonOpenMap = new System.Windows.Forms.Button();
            this.radioButtonIndoor = new System.Windows.Forms.RadioButton();
            this.radioButtonOutdoor = new System.Windows.Forms.RadioButton();
            this.radioButtonDungeon = new System.Windows.Forms.RadioButton();
            this.comboBoxWorld = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // buttonCreateMap
            // 
            this.buttonCreateMap.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.buttonCreateMap.Location = new System.Drawing.Point(12, 12);
            this.buttonCreateMap.Name = "buttonCreateMap";
            this.buttonCreateMap.Size = new System.Drawing.Size(203, 97);
            this.buttonCreateMap.TabIndex = 0;
            this.buttonCreateMap.Text = "Create new map";
            this.buttonCreateMap.UseVisualStyleBackColor = true;
            this.buttonCreateMap.Click += new System.EventHandler(this.buttonCreateMap_Click);
            // 
            // buttonOpenMap
            // 
            this.buttonOpenMap.Font = new System.Drawing.Font("Segoe UI", 14F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point);
            this.buttonOpenMap.Location = new System.Drawing.Point(221, 12);
            this.buttonOpenMap.Name = "buttonOpenMap";
            this.buttonOpenMap.Size = new System.Drawing.Size(203, 97);
            this.buttonOpenMap.TabIndex = 1;
            this.buttonOpenMap.Text = "Open map ...";
            this.buttonOpenMap.UseVisualStyleBackColor = true;
            this.buttonOpenMap.Click += new System.EventHandler(this.buttonOpenMap_Click);
            // 
            // radioButtonIndoor
            // 
            this.radioButtonIndoor.AutoSize = true;
            this.radioButtonIndoor.Checked = true;
            this.radioButtonIndoor.Location = new System.Drawing.Point(19, 115);
            this.radioButtonIndoor.Name = "radioButtonIndoor";
            this.radioButtonIndoor.Size = new System.Drawing.Size(87, 19);
            this.radioButtonIndoor.TabIndex = 2;
            this.radioButtonIndoor.TabStop = true;
            this.radioButtonIndoor.Text = "Indoor map";
            this.radioButtonIndoor.UseVisualStyleBackColor = true;
            // 
            // radioButtonOutdoor
            // 
            this.radioButtonOutdoor.AutoSize = true;
            this.radioButtonOutdoor.Location = new System.Drawing.Point(112, 115);
            this.radioButtonOutdoor.Name = "radioButtonOutdoor";
            this.radioButtonOutdoor.Size = new System.Drawing.Size(97, 19);
            this.radioButtonOutdoor.TabIndex = 3;
            this.radioButtonOutdoor.Text = "Outdoor map";
            this.radioButtonOutdoor.UseVisualStyleBackColor = true;
            // 
            // radioButtonDungeon
            // 
            this.radioButtonDungeon.AutoSize = true;
            this.radioButtonDungeon.Location = new System.Drawing.Point(215, 115);
            this.radioButtonDungeon.Name = "radioButtonDungeon";
            this.radioButtonDungeon.Size = new System.Drawing.Size(74, 19);
            this.radioButtonDungeon.TabIndex = 4;
            this.radioButtonDungeon.Text = "Dungeon";
            this.radioButtonDungeon.UseVisualStyleBackColor = true;
            // 
            // comboBoxWorld
            // 
            this.comboBoxWorld.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxWorld.FormattingEnabled = true;
            this.comboBoxWorld.Items.AddRange(new object[] {
            "Lyramion",
            "Forest Moon",
            "Morag"});
            this.comboBoxWorld.Location = new System.Drawing.Point(295, 114);
            this.comboBoxWorld.Name = "comboBoxWorld";
            this.comboBoxWorld.Size = new System.Drawing.Size(128, 23);
            this.comboBoxWorld.TabIndex = 5;
            // 
            // OpenMapForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(435, 145);
            this.Controls.Add(this.comboBoxWorld);
            this.Controls.Add(this.radioButtonDungeon);
            this.Controls.Add(this.radioButtonOutdoor);
            this.Controls.Add(this.radioButtonIndoor);
            this.Controls.Add(this.buttonOpenMap);
            this.Controls.Add(this.buttonCreateMap);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.Name = "OpenMapForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Ambermoon Map Editor 3D";
            this.Load += new System.EventHandler(this.OpenMapForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonCreateMap;
        private System.Windows.Forms.Button buttonOpenMap;
        private System.Windows.Forms.RadioButton radioButtonIndoor;
        private System.Windows.Forms.RadioButton radioButtonOutdoor;
        private System.Windows.Forms.RadioButton radioButtonDungeon;
        private System.Windows.Forms.ComboBox comboBoxWorld;
    }
}