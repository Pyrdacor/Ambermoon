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
            eventBrowserControl1 = new EventBrowserControl();
            SuspendLayout();
            // 
            // eventBrowserControl1
            // 
            eventBrowserControl1.Dock = DockStyle.Fill;
            eventBrowserControl1.Location = new Point(0, 0);
            eventBrowserControl1.Name = "eventBrowserControl1";
            eventBrowserControl1.Size = new Size(800, 450);
            eventBrowserControl1.TabIndex = 0;
            // 
            // EventEditorControl
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(eventBrowserControl1);
            Name = "EventEditorControl";
            Size = new Size(800, 450);
            ResumeLayout(false);
        }

        #endregion

        private EventBrowserControl eventBrowserControl1;
    }
}