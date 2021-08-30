
namespace AmbermoonMapEditor2D
{
    partial class MapIndexForm
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
            this.label1 = new System.Windows.Forms.Label();
            this.numericUpDownMapIndex = new System.Windows.Forms.NumericUpDown();
            this.buttonOK = new System.Windows.Forms.Button();
            this.comboBoxMapIndices = new System.Windows.Forms.ComboBox();
            this.toolTipMapIndex = new System.Windows.Forms.ToolTip(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMapIndex)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(13, 13);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(65, 15);
            this.label1.TabIndex = 0;
            this.label1.Text = "Map index:";
            // 
            // numericUpDownMapIndex
            // 
            this.numericUpDownMapIndex.Location = new System.Drawing.Point(84, 11);
            this.numericUpDownMapIndex.Maximum = new decimal(new int[] {
            1024,
            0,
            0,
            0});
            this.numericUpDownMapIndex.Minimum = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDownMapIndex.Name = "numericUpDownMapIndex";
            this.numericUpDownMapIndex.Size = new System.Drawing.Size(69, 23);
            this.numericUpDownMapIndex.TabIndex = 1;
            this.numericUpDownMapIndex.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            this.numericUpDownMapIndex.Value = new decimal(new int[] {
            1,
            0,
            0,
            0});
            this.numericUpDownMapIndex.ValueChanged += new System.EventHandler(this.numericUpDownMapIndex_ValueChanged);
            // 
            // buttonOK
            // 
            this.buttonOK.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.buttonOK.Location = new System.Drawing.Point(159, 10);
            this.buttonOK.Name = "buttonOK";
            this.buttonOK.Size = new System.Drawing.Size(75, 24);
            this.buttonOK.TabIndex = 2;
            this.buttonOK.Text = "OK";
            this.buttonOK.UseVisualStyleBackColor = true;
            // 
            // comboBoxMapIndices
            // 
            this.comboBoxMapIndices.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxMapIndices.FormattingEnabled = true;
            this.comboBoxMapIndices.Location = new System.Drawing.Point(84, 30);
            this.comboBoxMapIndices.Name = "comboBoxMapIndices";
            this.comboBoxMapIndices.Size = new System.Drawing.Size(69, 23);
            this.comboBoxMapIndices.TabIndex = 3;
            this.comboBoxMapIndices.DrawItem += new System.Windows.Forms.DrawItemEventHandler(this.comboBoxMapIndices_DrawItem);
            this.comboBoxMapIndices.SelectedIndexChanged += new System.EventHandler(this.comboBoxMapIndices_SelectedIndexChanged);
            this.comboBoxMapIndices.DropDownClosed += new System.EventHandler(this.comboBoxMapIndices_DropDownClosed);
            // 
            // MapIndexForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(246, 42);
            this.Controls.Add(this.comboBoxMapIndices);
            this.Controls.Add(this.buttonOK);
            this.Controls.Add(this.numericUpDownMapIndex);
            this.Controls.Add(this.label1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.Name = "MapIndexForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Enter map index";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.MapIndexForm_FormClosing);
            this.Load += new System.EventHandler(this.MapIndexForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.numericUpDownMapIndex)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.NumericUpDown numericUpDownMapIndex;
        private System.Windows.Forms.Button buttonOK;
        private System.Windows.Forms.ComboBox comboBoxMapIndices;
        private System.Windows.Forms.ToolTip toolTipMapIndex;
    }
}