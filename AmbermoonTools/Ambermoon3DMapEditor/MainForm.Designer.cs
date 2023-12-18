namespace Ambermoon3DMapEditor
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            splitContainer1 = new SplitContainer();
            view2D = new RenderPanel();
            view3D = new OpenTK.WinForms.GLControl();
            keyInputTimer = new System.Windows.Forms.Timer(components);
            statusStrip1 = new StatusStrip();
            statusPosition = new ToolStripStatusLabel();
            initTimer = new System.Windows.Forms.Timer(components);
            settingsControl1 = new SettingsControl();
            ((System.ComponentModel.ISupportInitialize)splitContainer1).BeginInit();
            splitContainer1.Panel1.SuspendLayout();
            splitContainer1.Panel2.SuspendLayout();
            splitContainer1.SuspendLayout();
            statusStrip1.SuspendLayout();
            SuspendLayout();
            // 
            // splitContainer1
            // 
            splitContainer1.Dock = DockStyle.Fill;
            splitContainer1.Location = new Point(0, 0);
            splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            splitContainer1.Panel1.Controls.Add(view2D);
            // 
            // splitContainer1.Panel2
            // 
            splitContainer1.Panel2.Controls.Add(view3D);
            splitContainer1.Size = new Size(800, 450);
            splitContainer1.SplitterDistance = 391;
            splitContainer1.TabIndex = 0;
            // 
            // view2D
            // 
            view2D.AutoScroll = true;
            view2D.BackColor = Color.White;
            view2D.Dock = DockStyle.Fill;
            view2D.Location = new Point(0, 0);
            view2D.Name = "view2D";
            view2D.Size = new Size(391, 450);
            view2D.TabIndex = 1;
            view2D.Paint += view2D_Paint;
            // 
            // view3D
            // 
            view3D.API = OpenTK.Windowing.Common.ContextAPI.OpenGL;
            view3D.APIVersion = new Version(3, 3, 0, 0);
            view3D.Dock = DockStyle.Fill;
            view3D.Flags = OpenTK.Windowing.Common.ContextFlags.Default;
            view3D.IsEventDriven = true;
            view3D.Location = new Point(0, 0);
            view3D.Name = "view3D";
            view3D.Profile = OpenTK.Windowing.Common.ContextProfile.Compatability;
            view3D.Size = new Size(405, 450);
            view3D.TabIndex = 0;
            view3D.Text = "glControl1";
            view3D.Paint += view3D_Paint;
            view3D.KeyDown += MainForm_KeyDown;
            view3D.KeyUp += MainForm_KeyUp;
            view3D.Resize += view3D_Resize;
            // 
            // keyInputTimer
            // 
            keyInputTimer.Enabled = true;
            keyInputTimer.Interval = 20;
            keyInputTimer.Tick += keyInputTimer_Tick;
            // 
            // statusStrip1
            // 
            statusStrip1.ImageScalingSize = new Size(20, 20);
            statusStrip1.Items.AddRange(new ToolStripItem[] { statusPosition });
            statusStrip1.Location = new Point(0, 424);
            statusStrip1.Name = "statusStrip1";
            statusStrip1.Size = new Size(800, 26);
            statusStrip1.TabIndex = 1;
            statusStrip1.Text = "statusStrip1";
            // 
            // statusPosition
            // 
            statusPosition.Name = "statusPosition";
            statusPosition.Size = new Size(29, 20);
            statusPosition.Text = "X,Y";
            // 
            // initTimer
            // 
            initTimer.Tick += initTimer_Tick;
            // 
            // settingsControl1
            // 
            settingsControl1.Dock = DockStyle.Bottom;
            settingsControl1.Location = new Point(0, 208);
            settingsControl1.Name = "settingsControl1";
            settingsControl1.Size = new Size(800, 216);
            settingsControl1.TabIndex = 2;
            // 
            // MainForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(settingsControl1);
            Controls.Add(statusStrip1);
            Controls.Add(splitContainer1);
            KeyPreview = true;
            MinimumSize = new Size(640, 480);
            Name = "MainForm";
            Text = "Ambermoon Map Editor 3D";
            FormClosed += MainForm_FormClosed;
            Load += MainForm_Load;
            KeyDown += MainForm_KeyDown;
            KeyUp += MainForm_KeyUp;
            splitContainer1.Panel1.ResumeLayout(false);
            splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainer1).EndInit();
            splitContainer1.ResumeLayout(false);
            statusStrip1.ResumeLayout(false);
            statusStrip1.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private SplitContainer splitContainer1;
        private OpenTK.WinForms.GLControl view3D;
        private RenderPanel view2D;
        private System.Windows.Forms.Timer keyInputTimer;
        private StatusStrip statusStrip1;
        private ToolStripStatusLabel statusPosition;
        private System.Windows.Forms.Timer initTimer;
        private SettingsControl settingsControl1;
    }
}