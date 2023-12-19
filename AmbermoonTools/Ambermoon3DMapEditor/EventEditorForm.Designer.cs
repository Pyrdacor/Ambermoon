namespace Ambermoon3DMapEditor
{
    partial class EventEditorForm
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
            eventEditorControl1 = new AmbermoonUIEventEditor.EventEditorControl();
            SuspendLayout();
            // 
            // eventEditorControl1
            // 
            eventEditorControl1.Dock = DockStyle.Fill;
            eventEditorControl1.Location = new Point(0, 0);
            eventEditorControl1.Name = "eventEditorControl1";
            eventEditorControl1.Size = new Size(800, 450);
            eventEditorControl1.TabIndex = 0;
            // 
            // EventEditorForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(eventEditorControl1);
            Name = "EventEditorForm";
            Text = "EventEditorForm";
            ResumeLayout(false);
        }

        #endregion

        private AmbermoonUIEventEditor.EventEditorControl eventEditorControl1;
    }
}