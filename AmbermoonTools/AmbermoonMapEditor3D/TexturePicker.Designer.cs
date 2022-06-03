namespace AmbermoonMapEditor3D
{
    partial class TexturePicker
    {
        /// <summary> 
        /// Erforderliche Designervariable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Verwendete Ressourcen bereinigen.
        /// </summary>
        /// <param name="disposing">True, wenn verwaltete Ressourcen gelöscht werden sollen; andernfalls False.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Vom Komponenten-Designer generierter Code

        /// <summary> 
        /// Erforderliche Methode für die Designerunterstützung. 
        /// Der Inhalt der Methode darf nicht mit dem Code-Editor geändert werden.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.buttonLeft = new System.Windows.Forms.Button();
            this.buttonRight = new System.Windows.Forms.Button();
            this.timerScroll = new System.Windows.Forms.Timer(this.components);
            this.timerScrollInit = new System.Windows.Forms.Timer(this.components);
            this.SuspendLayout();
            // 
            // buttonLeft
            // 
            this.buttonLeft.Dock = System.Windows.Forms.DockStyle.Left;
            this.buttonLeft.Location = new System.Drawing.Point(0, 0);
            this.buttonLeft.Name = "buttonLeft";
            this.buttonLeft.Size = new System.Drawing.Size(32, 80);
            this.buttonLeft.TabIndex = 0;
            this.buttonLeft.Text = "<";
            this.buttonLeft.UseVisualStyleBackColor = true;
            this.buttonLeft.Click += new System.EventHandler(this.buttonLeft_Click);
            this.buttonLeft.MouseDown += new System.Windows.Forms.MouseEventHandler(this.buttonLeft_MouseDown);
            this.buttonLeft.MouseUp += new System.Windows.Forms.MouseEventHandler(this.buttonLeft_MouseUp);
            // 
            // buttonRight
            // 
            this.buttonRight.Dock = System.Windows.Forms.DockStyle.Right;
            this.buttonRight.Location = new System.Drawing.Point(672, 0);
            this.buttonRight.Name = "buttonRight";
            this.buttonRight.Size = new System.Drawing.Size(32, 80);
            this.buttonRight.TabIndex = 1;
            this.buttonRight.Text = ">";
            this.buttonRight.UseVisualStyleBackColor = true;
            this.buttonRight.Click += new System.EventHandler(this.buttonRight_Click);
            this.buttonRight.MouseDown += new System.Windows.Forms.MouseEventHandler(this.buttonRight_MouseDown);
            this.buttonRight.MouseUp += new System.Windows.Forms.MouseEventHandler(this.buttonRight_MouseUp);
            // 
            // timerScroll
            // 
            this.timerScroll.Enabled = true;
            this.timerScroll.Tick += new System.EventHandler(this.timerScroll_Tick);
            // 
            // timerScrollInit
            // 
            this.timerScrollInit.Interval = 1000;
            this.timerScrollInit.Tick += new System.EventHandler(this.timerScrollInit_Tick);
            // 
            // TexturePicker
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.Black;
            this.Controls.Add(this.buttonRight);
            this.Controls.Add(this.buttonLeft);
            this.Name = "TexturePicker";
            this.Size = new System.Drawing.Size(704, 80);
            this.Load += new System.EventHandler(this.TexturePicker_Load);
            this.Paint += new System.Windows.Forms.PaintEventHandler(this.TexturePicker_Paint);
            this.MouseClick += new System.Windows.Forms.MouseEventHandler(this.TexturePicker_MouseClick);
            this.MouseUp += new System.Windows.Forms.MouseEventHandler(this.TexturePicker_MouseUp);
            this.Resize += new System.EventHandler(this.TexturePicker_Resize);
            this.ResumeLayout(false);

        }

        #endregion

        private Button buttonLeft;
        private Button buttonRight;
        private System.Windows.Forms.Timer timerScroll;
        private System.Windows.Forms.Timer timerScrollInit;
    }
}
