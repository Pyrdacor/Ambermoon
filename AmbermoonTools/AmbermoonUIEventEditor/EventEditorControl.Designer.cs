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
            eventBrowser = new EventBrowserControl();
            eventView = new EventViewControl();
            SuspendLayout();
            // 
            // eventBrowser
            // 
            eventBrowser.Dock = DockStyle.Left;
            eventBrowser.Location = new Point(0, 0);
            eventBrowser.Name = "eventBrowser";
            eventBrowser.Size = new Size(184, 451);
            eventBrowser.TabIndex = 0;
            eventBrowser.EventDoubleClicked += eventBrowser_EventDoubleClicked;
            // 
            // eventView
            // 
            eventView.AutoScroll = true;
            eventView.Dock = DockStyle.Fill;
            eventView.Location = new Point(184, 0);
            eventView.Margin = new Padding(3, 4, 3, 4);
            eventView.Name = "eventView";
            eventView.Size = new Size(616, 451);
            eventView.TabIndex = 1;
            // 
            // EventEditorControl
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(eventView);
            Controls.Add(eventBrowser);
            Name = "EventEditorControl";
            Size = new Size(800, 451);
            ResumeLayout(false);
        }

        #endregion

        private EventBrowserControl eventBrowser;
        private EventViewControl eventView;
    }
}