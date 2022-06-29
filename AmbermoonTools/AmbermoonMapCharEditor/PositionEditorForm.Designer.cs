namespace AmbermoonMapCharEditor
{
    partial class PositionEditorForm
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
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.ColumnTime = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ColumnX = new AmbermoonMapCharEditor.NumericUpDownColumn();
            this.ColumnY = new AmbermoonMapCharEditor.NumericUpDownColumn();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ClipboardCopyMode = System.Windows.Forms.DataGridViewClipboardCopyMode.EnableWithoutHeaderText;
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.ColumnTime,
            this.ColumnX,
            this.ColumnY});
            this.dataGridView1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.dataGridView1.Location = new System.Drawing.Point(0, 0);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowTemplate.Height = 25;
            this.dataGridView1.Size = new System.Drawing.Size(221, 304);
            this.dataGridView1.TabIndex = 0;
            // 
            // ColumnTime
            // 
            this.ColumnTime.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.ColumnTime.HeaderText = "Time";
            this.ColumnTime.Name = "ColumnTime";
            this.ColumnTime.ReadOnly = true;
            this.ColumnTime.SortMode = System.Windows.Forms.DataGridViewColumnSortMode.NotSortable;
            this.ColumnTime.Width = 40;
            // 
            // ColumnX
            // 
            this.ColumnX.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.ColumnX.HeaderText = "X";
            this.ColumnX.MaxValue = ((uint)(0u));
            this.ColumnX.MinimumWidth = 50;
            this.ColumnX.MinValue = ((uint)(0u));
            this.ColumnX.Name = "ColumnX";
            this.ColumnX.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.ColumnX.Width = 50;
            // 
            // ColumnY
            // 
            this.ColumnY.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.AllCells;
            this.ColumnY.HeaderText = "Y";
            this.ColumnY.MaxValue = ((uint)(0u));
            this.ColumnY.MinimumWidth = 50;
            this.ColumnY.MinValue = ((uint)(0u));
            this.ColumnY.Name = "ColumnY";
            this.ColumnY.Resizable = System.Windows.Forms.DataGridViewTriState.True;
            this.ColumnY.Width = 50;
            // 
            // PositionEditorForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(221, 304);
            this.Controls.Add(this.dataGridView1);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.SizableToolWindow;
            this.MinimumSize = new System.Drawing.Size(200, 140);
            this.Name = "PositionEditorForm";
            this.Text = "Character positions";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.PositionEditorForm_FormClosing);
            this.Load += new System.EventHandler(this.PositionEditorForm_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private DataGridView dataGridView1;
        private DataGridViewTextBoxColumn ColumnTime;
        private NumericUpDownColumn ColumnX;
        private NumericUpDownColumn ColumnY;
    }
}