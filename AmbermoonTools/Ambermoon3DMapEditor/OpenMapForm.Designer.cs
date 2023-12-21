namespace Ambermoon3DMapEditor
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
            labelFilter = new Label();
            textBoxFilter = new TextBox();
            listViewMaps = new ListView();
            columnHeaderIndex = new ColumnHeader();
            columnHeaderName = new ColumnHeader();
            SuspendLayout();
            // 
            // labelFilter
            // 
            labelFilter.AutoSize = true;
            labelFilter.Location = new Point(12, 9);
            labelFilter.Name = "labelFilter";
            labelFilter.Size = new Size(45, 20);
            labelFilter.TabIndex = 0;
            labelFilter.Text = "Filter:";
            // 
            // textBoxFilter
            // 
            textBoxFilter.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            textBoxFilter.Location = new Point(63, 6);
            textBoxFilter.Name = "textBoxFilter";
            textBoxFilter.Size = new Size(591, 27);
            textBoxFilter.TabIndex = 1;
            textBoxFilter.TextChanged += textBoxFilter_TextChanged;
            // 
            // listViewMaps
            // 
            listViewMaps.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            listViewMaps.Columns.AddRange(new ColumnHeader[] { columnHeaderIndex, columnHeaderName });
            listViewMaps.Location = new Point(12, 39);
            listViewMaps.Name = "listViewMaps";
            listViewMaps.Size = new Size(642, 141);
            listViewMaps.TabIndex = 2;
            listViewMaps.UseCompatibleStateImageBehavior = false;
            listViewMaps.View = View.Details;
            listViewMaps.ItemActivate += listViewMaps_ItemActivate;
            // 
            // columnHeaderIndex
            // 
            columnHeaderIndex.Text = "Index";
            // 
            // columnHeaderName
            // 
            columnHeaderName.Text = "Name";
            // 
            // OpenMapForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(666, 192);
            Controls.Add(listViewMaps);
            Controls.Add(textBoxFilter);
            Controls.Add(labelFilter);
            MinimumSize = new Size(320, 200);
            Name = "OpenMapForm";
            Text = "Open Map";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label labelFilter;
        private TextBox textBoxFilter;
        private ListView listViewMaps;
        private ColumnHeader columnHeaderIndex;
        private ColumnHeader columnHeaderName;
    }
}