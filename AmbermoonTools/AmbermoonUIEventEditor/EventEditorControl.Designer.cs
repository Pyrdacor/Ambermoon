using System.Windows.Forms;

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
            eventView = new EventViewControl();
            eventBrowser = new EventBrowserControl();
            splitContainer = new SplitContainer();
            ((System.ComponentModel.ISupportInitialize)splitContainer).BeginInit();
            splitContainer.SuspendLayout();
            SuspendLayout();
            // 
            // eventView
            // 
            eventView.AutoScroll = true;
            eventView.Dock = DockStyle.Fill;
            eventView.Location = new Point(173, 0);
            eventView.Name = "eventView";
            eventView.Size = new Size(527, 338);
            eventView.TabIndex = 1;
            eventView.TabStop = true;
            // 
            // eventBrowser
            // 
            eventBrowser.Dock = DockStyle.Left;
            eventBrowser.Location = new Point(0, 0);
            eventBrowser.Margin = new Padding(3, 2, 3, 2);
            eventBrowser.Name = "eventBrowser";
            eventBrowser.ShowCharEvents = true;
            eventBrowser.ShowMapEvents = true;
            eventBrowser.Size = new Size(173, 338);
            eventBrowser.TabIndex = 0;
            eventBrowser.EventDoubleClicked += eventBrowser_EventDoubleClicked;
            // 
            // splitContainer
            // 
            splitContainer.Dock = DockStyle.Fill;
            splitContainer.Location = new Point(0, 0);
            splitContainer.Name = "splitContainer1";
            splitContainer.Size = new Size(700, 338);
            splitContainer.SplitterDistance = 233;
            splitContainer.TabIndex = 0;
            splitContainer.Panel1.Controls.Add(eventBrowser);
            eventBrowser.Dock = DockStyle.Fill;
            splitContainer.Panel2.Controls.Add(eventView);
            eventView.Dock = DockStyle.Fill;
            // 
            // EventEditorControl
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(splitContainer);
            Margin = new Padding(3, 2, 3, 2);
            Name = "EventEditorControl";
            Size = new Size(700, 338);
            ((System.ComponentModel.ISupportInitialize)splitContainer).EndInit();
            splitContainer.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private SplitContainer splitContainer;
        private EventViewControl eventView;
        private EventBrowserControl eventBrowser;
    }
}