namespace AmbermoonUIEventEditor
{
    partial class EventBrowserControl
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
            listViewEvents = new ListView();
            labelFilter = new Label();
            textBoxFilter = new TextBox();
            SuspendLayout();
            // 
            // listViewEvents
            // 
            listViewEvents.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            listViewEvents.HeaderStyle = ColumnHeaderStyle.None;
            listViewEvents.Location = new Point(3, 39);
            listViewEvents.Name = "listViewEvents";
            listViewEvents.Size = new Size(457, 739);
            listViewEvents.TabIndex = 0;
            listViewEvents.UseCompatibleStateImageBehavior = false;
            listViewEvents.View = View.Details;
            listViewEvents.ItemActivate += listViewEvents_ItemActivate;
            listViewEvents.ItemDrag += listViewEvents_ItemDrag;
            // 
            // labelFilter
            // 
            labelFilter.AutoSize = true;
            labelFilter.Location = new Point(3, 9);
            labelFilter.Name = "labelFilter";
            labelFilter.Size = new Size(45, 20);
            labelFilter.TabIndex = 1;
            labelFilter.Text = "Filter:";
            // 
            // textBoxFilter
            // 
            textBoxFilter.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            textBoxFilter.Location = new Point(54, 6);
            textBoxFilter.Name = "textBoxFilter";
            textBoxFilter.Size = new Size(406, 27);
            textBoxFilter.TabIndex = 2;
            textBoxFilter.TextChanged += textBoxFilter_TextChanged;
            // 
            // EventBrowserControl
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(textBoxFilter);
            Controls.Add(labelFilter);
            Controls.Add(listViewEvents);
            Name = "EventBrowserControl";
            Size = new Size(463, 781);
            Load += EventBrowserControl_Load;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private ListView listViewEvents;
        private Label labelFilter;
        private TextBox textBoxFilter;
    }
}
