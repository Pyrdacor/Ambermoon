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
			dataGridPositions = new DataGridView();
			ColumnTime = new DataGridViewTextBoxColumn();
			ColumnX = new NumericUpDownColumn();
			ColumnY = new NumericUpDownColumn();
			((System.ComponentModel.ISupportInitialize)dataGridPositions).BeginInit();
			SuspendLayout();
			// 
			// dataGridView1
			// 
			dataGridPositions.ClipboardCopyMode = DataGridViewClipboardCopyMode.EnableWithoutHeaderText;
			dataGridPositions.ColumnHeadersHeightSizeMode = DataGridViewColumnHeadersHeightSizeMode.AutoSize;
			dataGridPositions.Columns.AddRange(new DataGridViewColumn[] { ColumnTime, ColumnX, ColumnY });
			dataGridPositions.Dock = DockStyle.Fill;
			dataGridPositions.Location = new Point(0, 0);
			dataGridPositions.Name = "dataGridPositions";
			dataGridPositions.RowTemplate.Height = 25;
			dataGridPositions.Size = new Size(221, 304);
			dataGridPositions.TabIndex = 0;
			// 
			// ColumnTime
			// 
			ColumnTime.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
			ColumnTime.HeaderText = "Time";
			ColumnTime.Name = "ColumnTime";
			ColumnTime.ReadOnly = true;
			ColumnTime.SortMode = DataGridViewColumnSortMode.NotSortable;
			ColumnTime.Width = 39;
			// 
			// ColumnX
			// 
			ColumnX.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
			ColumnX.HeaderText = "X";
			ColumnX.MaxValue = 0U;
			ColumnX.MinimumWidth = 50;
			ColumnX.MinValue = 0U;
			ColumnX.Name = "ColumnX";
			ColumnX.Resizable = DataGridViewTriState.True;
			ColumnX.Width = 50;
			// 
			// ColumnY
			// 
			ColumnY.AutoSizeMode = DataGridViewAutoSizeColumnMode.AllCells;
			ColumnY.HeaderText = "Y";
			ColumnY.MaxValue = 0U;
			ColumnY.MinimumWidth = 50;
			ColumnY.MinValue = 0U;
			ColumnY.Name = "ColumnY";
			ColumnY.Resizable = DataGridViewTriState.True;
			ColumnY.Width = 50;
			// 
			// PositionEditorForm
			// 
			AutoScaleDimensions = new SizeF(7F, 15F);
			AutoScaleMode = AutoScaleMode.Font;
			ClientSize = new Size(221, 304);
			Controls.Add(dataGridPositions);
			FormBorderStyle = FormBorderStyle.SizableToolWindow;
			MinimumSize = new Size(200, 140);
			Name = "PositionEditorForm";
			Text = "Character positions";
			FormClosing += PositionEditorForm_FormClosing;
			Load += PositionEditorForm_Load;
			((System.ComponentModel.ISupportInitialize)dataGridPositions).EndInit();
			ResumeLayout(false);
		}

		#endregion

		private DataGridView dataGridPositions;
        private DataGridViewTextBoxColumn ColumnTime;
        private NumericUpDownColumn ColumnX;
        private NumericUpDownColumn ColumnY;
    }
}