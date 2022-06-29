namespace AmbermoonMapEditor2D
{
    partial class SaveMapForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(SaveMapForm));
            this.buttonSaveToGameData = new System.Windows.Forms.Button();
            this.buttonSaveToExternalFile = new System.Windows.Forms.Button();
            this.checkBoxCompress = new System.Windows.Forms.CheckBox();
            this.SuspendLayout();
            // 
            // buttonSaveToGameData
            // 
            this.buttonSaveToGameData.Location = new System.Drawing.Point(12, 12);
            this.buttonSaveToGameData.Name = "buttonSaveToGameData";
            this.buttonSaveToGameData.Size = new System.Drawing.Size(103, 63);
            this.buttonSaveToGameData.TabIndex = 0;
            this.buttonSaveToGameData.Text = "Save back to game data";
            this.buttonSaveToGameData.UseVisualStyleBackColor = true;
            this.buttonSaveToGameData.Click += new System.EventHandler(this.buttonSaveToGameData_Click);
            // 
            // buttonSaveToExternalFile
            // 
            this.buttonSaveToExternalFile.Location = new System.Drawing.Point(121, 12);
            this.buttonSaveToExternalFile.Name = "buttonSaveToExternalFile";
            this.buttonSaveToExternalFile.Size = new System.Drawing.Size(103, 63);
            this.buttonSaveToExternalFile.TabIndex = 1;
            this.buttonSaveToExternalFile.Text = "Save to external map file";
            this.buttonSaveToExternalFile.UseVisualStyleBackColor = true;
            this.buttonSaveToExternalFile.Click += new System.EventHandler(this.buttonSaveToExternalFile_Click);
            // 
            // checkBoxCompress
            // 
            this.checkBoxCompress.AutoSize = true;
            this.checkBoxCompress.Location = new System.Drawing.Point(12, 81);
            this.checkBoxCompress.Name = "checkBoxCompress";
            this.checkBoxCompress.Size = new System.Drawing.Size(191, 19);
            this.checkBoxCompress.TabIndex = 2;
            this.checkBoxCompress.Text = "Compress game data container";
            this.checkBoxCompress.UseVisualStyleBackColor = true;
            // 
            // SaveMapForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(237, 106);
            this.Controls.Add(this.checkBoxCompress);
            this.Controls.Add(this.buttonSaveToExternalFile);
            this.Controls.Add(this.buttonSaveToGameData);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MaximizeBox = false;
            this.Name = "SaveMapForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Save map";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button buttonSaveToGameData;
        private System.Windows.Forms.Button buttonSaveToExternalFile;
        private System.Windows.Forms.CheckBox checkBoxCompress;
    }
}