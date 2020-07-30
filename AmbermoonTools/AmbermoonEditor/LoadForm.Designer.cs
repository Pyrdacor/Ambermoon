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
            this.groupBoxLoad = new System.Windows.Forms.GroupBox();
            this.buttonContinue = new System.Windows.Forms.Button();
            this.radioButtonAny = new System.Windows.Forms.RadioButton();
            this.labelLoadInfo = new System.Windows.Forms.Label();
            this.textBoxLoadInfo = new System.Windows.Forms.TextBox();
            this.buttonBrowse = new System.Windows.Forms.Button();
            this.labelPath = new System.Windows.Forms.Label();
            this.textBoxPath = new System.Windows.Forms.TextBox();
            this.radioButtonExtracted = new System.Windows.Forms.RadioButton();
            this.radioButtonADF = new System.Windows.Forms.RadioButton();
            this.labelHeadline = new System.Windows.Forms.Label();
            this.groupBoxLoad.SuspendLayout();
            this.SuspendLayout();
            // 
            // groupBoxLoad
            // 
            this.groupBoxLoad.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBoxLoad.Controls.Add(this.buttonContinue);
            this.groupBoxLoad.Controls.Add(this.radioButtonAny);
            this.groupBoxLoad.Controls.Add(this.labelLoadInfo);
            this.groupBoxLoad.Controls.Add(this.textBoxLoadInfo);
            this.groupBoxLoad.Controls.Add(this.buttonBrowse);
            this.groupBoxLoad.Controls.Add(this.labelPath);
            this.groupBoxLoad.Controls.Add(this.textBoxPath);
            this.groupBoxLoad.Controls.Add(this.radioButtonExtracted);
            this.groupBoxLoad.Controls.Add(this.radioButtonADF);
            this.groupBoxLoad.Location = new System.Drawing.Point(12, 54);
            this.groupBoxLoad.Name = "groupBoxLoad";
            this.groupBoxLoad.Size = new System.Drawing.Size(776, 384);
            this.groupBoxLoad.TabIndex = 0;
            this.groupBoxLoad.TabStop = false;
            this.groupBoxLoad.Text = "Load game data";
            // 
            // buttonContinue
            // 
            this.buttonContinue.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonContinue.BackColor = System.Drawing.SystemColors.Control;
            this.buttonContinue.Enabled = false;
            this.buttonContinue.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.buttonContinue.Location = new System.Drawing.Point(20, 349);
            this.buttonContinue.Name = "buttonContinue";
            this.buttonContinue.Size = new System.Drawing.Size(738, 29);
            this.buttonContinue.TabIndex = 6;
            this.buttonContinue.Text = "> Continue <";
            this.buttonContinue.UseVisualStyleBackColor = false;
            this.buttonContinue.Click += new System.EventHandler(this.buttonContinue_Click);
            // 
            // radioButtonAny
            // 
            this.radioButtonAny.AutoSize = true;
            this.radioButtonAny.Location = new System.Drawing.Point(320, 34);
            this.radioButtonAny.Name = "radioButtonAny";
            this.radioButtonAny.Size = new System.Drawing.Size(242, 24);
            this.radioButtonAny.TabIndex = 0;
            this.radioButtonAny.Text = "From any files (prefer extracted)";
            this.radioButtonAny.UseVisualStyleBackColor = true;
            this.radioButtonAny.CheckedChanged += new System.EventHandler(this.RadioButtonAny_CheckedChanged);
            // 
            // labelLoadInfo
            // 
            this.labelLoadInfo.AutoSize = true;
            this.labelLoadInfo.Enabled = false;
            this.labelLoadInfo.Location = new System.Drawing.Point(20, 107);
            this.labelLoadInfo.Name = "labelLoadInfo";
            this.labelLoadInfo.Size = new System.Drawing.Size(124, 20);
            this.labelLoadInfo.TabIndex = 5;
            this.labelLoadInfo.Text = "Load information";
            // 
            // textBoxLoadInfo
            // 
            this.textBoxLoadInfo.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.textBoxLoadInfo.BackColor = System.Drawing.SystemColors.Info;
            this.textBoxLoadInfo.Enabled = false;
            this.textBoxLoadInfo.Location = new System.Drawing.Point(20, 130);
            this.textBoxLoadInfo.Multiline = true;
            this.textBoxLoadInfo.Name = "textBoxLoadInfo";
            this.textBoxLoadInfo.ReadOnly = true;
            this.textBoxLoadInfo.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
            this.textBoxLoadInfo.Size = new System.Drawing.Size(738, 218);
            this.textBoxLoadInfo.TabIndex = 4;
            // 
            // buttonBrowse
            // 
            this.buttonBrowse.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right)));
            this.buttonBrowse.Location = new System.Drawing.Point(657, 63);
            this.buttonBrowse.Name = "buttonBrowse";
            this.buttonBrowse.Size = new System.Drawing.Size(101, 29);
            this.buttonBrowse.TabIndex = 3;
            this.buttonBrowse.Text = "Browse ...";
            this.buttonBrowse.UseVisualStyleBackColor = true;
            this.buttonBrowse.Click += new System.EventHandler(this.ButtonBrowse_Click);
            // 
            // labelPath
            // 
            this.labelPath.AutoSize = true;
            this.labelPath.Location = new System.Drawing.Point(20, 67);
            this.labelPath.Name = "labelPath";
            this.labelPath.Size = new System.Drawing.Size(40, 20);
            this.labelPath.TabIndex = 2;
            this.labelPath.Text = "Path:";
            // 
            // textBoxPath
            // 
            this.textBoxPath.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.textBoxPath.Location = new System.Drawing.Point(66, 64);
            this.textBoxPath.Name = "textBoxPath";
            this.textBoxPath.Size = new System.Drawing.Size(585, 27);
            this.textBoxPath.TabIndex = 1;
            this.textBoxPath.TextChanged += new System.EventHandler(this.TextBoxPath_TextChanged);
            // 
            // radioButtonExtracted
            // 
            this.radioButtonExtracted.AutoSize = true;
            this.radioButtonExtracted.Location = new System.Drawing.Point(153, 34);
            this.radioButtonExtracted.Name = "radioButtonExtracted";
            this.radioButtonExtracted.Size = new System.Drawing.Size(161, 24);
            this.radioButtonExtracted.TabIndex = 0;
            this.radioButtonExtracted.Text = "From extracted files";
            this.radioButtonExtracted.UseVisualStyleBackColor = true;
            this.radioButtonExtracted.CheckedChanged += new System.EventHandler(this.RadioButtonExtracted_CheckedChanged);
            // 
            // radioButtonADF
            // 
            this.radioButtonADF.AutoSize = true;
            this.radioButtonADF.Checked = true;
            this.radioButtonADF.Location = new System.Drawing.Point(20, 34);
            this.radioButtonADF.Name = "radioButtonADF";
            this.radioButtonADF.Size = new System.Drawing.Size(127, 24);
            this.radioButtonADF.TabIndex = 0;
            this.radioButtonADF.TabStop = true;
            this.radioButtonADF.Text = "From ADF files";
            this.radioButtonADF.UseVisualStyleBackColor = true;
            this.radioButtonADF.CheckedChanged += new System.EventHandler(this.RadioButtonADF_CheckedChanged);
            // 
            // labelHeadline
            // 
            this.labelHeadline.AutoSize = true;
            this.labelHeadline.Font = new System.Drawing.Font("Segoe UI", 9F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point);
            this.labelHeadline.Location = new System.Drawing.Point(22, 20);
            this.labelHeadline.Name = "labelHeadline";
            this.labelHeadline.Size = new System.Drawing.Size(724, 20);
            this.labelHeadline.TabIndex = 6;
            this.labelHeadline.Text = "Welcome to Ambermoon Editor. Just pick a data source: directory with ADF files or" +
    " the extracted files.";
            // 
            // LoadForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.labelHeadline);
            this.Controls.Add(this.groupBoxLoad);
            this.MinimumSize = new System.Drawing.Size(810, 460);
            this.Name = "LoadForm";
            this.Text = "Ambermoon Editor";
            this.groupBoxLoad.ResumeLayout(false);
            this.groupBoxLoad.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

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
        private System.Windows.Forms.RadioButton radioButtonAny;
        private System.Windows.Forms.Button buttonContinue;
    }
}