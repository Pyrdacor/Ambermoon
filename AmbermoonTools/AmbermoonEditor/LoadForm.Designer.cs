namespace AmbermoonEditor
{
    partial class LoadForm
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
            groupBoxLoad = new System.Windows.Forms.GroupBox();
            buttonContinue = new System.Windows.Forms.Button();
            labelLoadInfo = new System.Windows.Forms.Label();
            textBoxLoadInfo = new System.Windows.Forms.TextBox();
            buttonBrowse = new System.Windows.Forms.Button();
            labelPath = new System.Windows.Forms.Label();
            textBoxPath = new System.Windows.Forms.TextBox();
            radioButtonExtracted = new System.Windows.Forms.RadioButton();
            radioButtonADF = new System.Windows.Forms.RadioButton();
            labelHeadline = new System.Windows.Forms.Label();
            groupBoxLoad.SuspendLayout();
            SuspendLayout();
            // 
            // groupBoxLoad
            // 
            groupBoxLoad.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
            groupBoxLoad.Controls.Add(buttonContinue);
            groupBoxLoad.Controls.Add(labelLoadInfo);
            groupBoxLoad.Controls.Add(textBoxLoadInfo);
            groupBoxLoad.Controls.Add(buttonBrowse);
            groupBoxLoad.Controls.Add(labelPath);
            groupBoxLoad.Controls.Add(textBoxPath);
            groupBoxLoad.Controls.Add(radioButtonExtracted);
            groupBoxLoad.Controls.Add(radioButtonADF);
            groupBoxLoad.Location = new System.Drawing.Point(10, 60);
            groupBoxLoad.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            groupBoxLoad.Name = "groupBoxLoad";
            groupBoxLoad.Padding = new System.Windows.Forms.Padding(3, 2, 3, 2);
            groupBoxLoad.Size = new System.Drawing.Size(603, 331);
            groupBoxLoad.TabIndex = 0;
            groupBoxLoad.TabStop = false;
            groupBoxLoad.Text = "Load game data";
            // 
            // buttonContinue
            // 
            buttonContinue.Anchor = System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
            buttonContinue.BackColor = System.Drawing.SystemColors.Control;
            buttonContinue.Enabled = false;
            buttonContinue.Font = new System.Drawing.Font("Consolas", 10F, System.Drawing.FontStyle.Bold);
            buttonContinue.Location = new System.Drawing.Point(18, 301);
            buttonContinue.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            buttonContinue.Name = "buttonContinue";
            buttonContinue.Size = new System.Drawing.Size(570, 26);
            buttonContinue.TabIndex = 6;
            buttonContinue.Text = "> Continue <";
            buttonContinue.UseVisualStyleBackColor = false;
            buttonContinue.Click += ButtonContinue_Click;
            // 
            // labelLoadInfo
            // 
            labelLoadInfo.AutoSize = true;
            labelLoadInfo.Enabled = false;
            labelLoadInfo.Location = new System.Drawing.Point(18, 80);
            labelLoadInfo.Name = "labelLoadInfo";
            labelLoadInfo.Size = new System.Drawing.Size(99, 15);
            labelLoadInfo.TabIndex = 5;
            labelLoadInfo.Text = "Load information";
            // 
            // textBoxLoadInfo
            // 
            textBoxLoadInfo.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
            textBoxLoadInfo.BackColor = System.Drawing.SystemColors.Info;
            textBoxLoadInfo.Enabled = false;
            textBoxLoadInfo.Location = new System.Drawing.Point(18, 98);
            textBoxLoadInfo.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            textBoxLoadInfo.Multiline = true;
            textBoxLoadInfo.Name = "textBoxLoadInfo";
            textBoxLoadInfo.ReadOnly = true;
            textBoxLoadInfo.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            textBoxLoadInfo.Size = new System.Drawing.Size(570, 199);
            textBoxLoadInfo.TabIndex = 4;
            // 
            // buttonBrowse
            // 
            buttonBrowse.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right;
            buttonBrowse.Location = new System.Drawing.Point(499, 47);
            buttonBrowse.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            buttonBrowse.Name = "buttonBrowse";
            buttonBrowse.Size = new System.Drawing.Size(88, 22);
            buttonBrowse.TabIndex = 3;
            buttonBrowse.Text = "Browse ...";
            buttonBrowse.UseVisualStyleBackColor = true;
            buttonBrowse.Click += ButtonBrowse_Click;
            // 
            // labelPath
            // 
            labelPath.AutoSize = true;
            labelPath.Location = new System.Drawing.Point(18, 50);
            labelPath.Name = "labelPath";
            labelPath.Size = new System.Drawing.Size(34, 15);
            labelPath.TabIndex = 2;
            labelPath.Text = "Path:";
            // 
            // textBoxPath
            // 
            textBoxPath.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
            textBoxPath.Location = new System.Drawing.Point(58, 46);
            textBoxPath.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            textBoxPath.Name = "textBoxPath";
            textBoxPath.Size = new System.Drawing.Size(436, 23);
            textBoxPath.TabIndex = 1;
            textBoxPath.TextChanged += TextBoxPath_TextChanged;
            // 
            // radioButtonExtracted
            // 
            radioButtonExtracted.AutoSize = true;
            radioButtonExtracted.Checked = true;
            radioButtonExtracted.Location = new System.Drawing.Point(134, 24);
            radioButtonExtracted.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            radioButtonExtracted.Name = "radioButtonExtracted";
            radioButtonExtracted.Size = new System.Drawing.Size(230, 19);
            radioButtonExtracted.TabIndex = 0;
            radioButtonExtracted.TabStop = true;
            radioButtonExtracted.Text = "From extracted files (Amberfiles folder)";
            radioButtonExtracted.UseVisualStyleBackColor = true;
            radioButtonExtracted.CheckedChanged += RadioButtonExtracted_CheckedChanged;
            // 
            // radioButtonADF
            // 
            radioButtonADF.AutoSize = true;
            radioButtonADF.Location = new System.Drawing.Point(18, 24);
            radioButtonADF.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            radioButtonADF.Name = "radioButtonADF";
            radioButtonADF.Size = new System.Drawing.Size(102, 19);
            radioButtonADF.TabIndex = 0;
            radioButtonADF.Text = "From ADF files";
            radioButtonADF.UseVisualStyleBackColor = true;
            radioButtonADF.CheckedChanged += RadioButtonADF_CheckedChanged;
            // 
            // labelHeadline
            // 
            labelHeadline.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
            labelHeadline.Font = new System.Drawing.Font("Consolas", 9F, System.Drawing.FontStyle.Bold);
            labelHeadline.Location = new System.Drawing.Point(10, 15);
            labelHeadline.Name = "labelHeadline";
            labelHeadline.Size = new System.Drawing.Size(602, 30);
            labelHeadline.TabIndex = 6;
            labelHeadline.Text = "Welcome to the Ambermoon Editor!\r\nPick a data source: Directory with ADF files or the extracted files (Amberfiles).";
            // 
            // LoadForm
            // 
            AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            ClientSize = new System.Drawing.Size(624, 401);
            Controls.Add(labelHeadline);
            Controls.Add(groupBoxLoad);
            Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            MinimumSize = new System.Drawing.Size(640, 320);
            Name = "LoadForm";
            Text = "Ambermoon Editor";
            groupBoxLoad.ResumeLayout(false);
            groupBoxLoad.PerformLayout();
            ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.GroupBox groupBoxLoad;
        private System.Windows.Forms.RadioButton radioButtonExtracted;
        private System.Windows.Forms.RadioButton radioButtonADF;
        private System.Windows.Forms.Button buttonBrowse;
        private System.Windows.Forms.Label labelPath;
        private System.Windows.Forms.TextBox textBoxPath;
        private System.Windows.Forms.Label labelLoadInfo;
        private System.Windows.Forms.TextBox textBoxLoadInfo;
        private System.Windows.Forms.Label labelHeadline;
        private System.Windows.Forms.Button buttonContinue;
    }
}