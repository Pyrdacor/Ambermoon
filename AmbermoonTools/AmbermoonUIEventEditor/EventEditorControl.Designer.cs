namespace AmbermoonUIEventEditor
{
    partial class EventEditorControl
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
            this.eventBrowser = new AmbermoonUIEventEditor.EventBrowserControl();
            this.eventView = new AmbermoonUIEventEditor.EventViewControl();
            this.SuspendLayout();
            // 
            // eventBrowser
            // 
            this.eventBrowser.Dock = System.Windows.Forms.DockStyle.Left;
            this.eventBrowser.Location = new System.Drawing.Point(0, 0);
            this.eventBrowser.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.eventBrowser.Name = "eventBrowser";
            this.eventBrowser.Size = new System.Drawing.Size(161, 338);
            this.eventBrowser.TabIndex = 0;
            this.eventBrowser.EventDoubleClicked += new System.Action<Ambermoon.Data.EventType, Ambermoon.Data.Descriptions.EventDescription>(this.eventBrowser_EventDoubleClicked);
            // 
            // eventView
            // 
            this.eventView.Dock = System.Windows.Forms.DockStyle.Fill;
            this.eventView.Location = new System.Drawing.Point(161, 0);
            this.eventView.Name = "eventView";
            this.eventView.Size = new System.Drawing.Size(539, 338);
            this.eventView.TabIndex = 1;
            // 
            // EventEditorControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.eventView);
            this.Controls.Add(this.eventBrowser);
            this.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
            this.Name = "EventEditorControl";
            this.Size = new System.Drawing.Size(700, 338);
            this.ResumeLayout(false);

        }

        #endregion

        private EventBrowserControl eventBrowser;
        private EventViewControl eventView;
    }
}