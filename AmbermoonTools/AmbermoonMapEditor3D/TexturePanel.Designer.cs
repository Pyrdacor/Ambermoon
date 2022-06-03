namespace AmbermoonMapEditor3D
{
    partial class TexturePanel
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
            this.tabControl1 = new System.Windows.Forms.TabControl();
            this.tabPageWalls = new System.Windows.Forms.TabPage();
            this.tabPageObjects = new System.Windows.Forms.TabPage();
            this.tabControl1.SuspendLayout();
            this.SuspendLayout();
            // 
            // tabControl1
            // 
            this.tabControl1.Controls.Add(this.tabPageWalls);
            this.tabControl1.Controls.Add(this.tabPageObjects);
            this.tabControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tabControl1.Location = new System.Drawing.Point(0, 0);
            this.tabControl1.Name = "tabControl1";
            this.tabControl1.SelectedIndex = 0;
            this.tabControl1.Size = new System.Drawing.Size(740, 150);
            this.tabControl1.TabIndex = 0;
            // 
            // tabPageWalls
            // 
            this.tabPageWalls.Location = new System.Drawing.Point(4, 24);
            this.tabPageWalls.Name = "tabPageWalls";
            this.tabPageWalls.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageWalls.Size = new System.Drawing.Size(732, 86);
            this.tabPageWalls.TabIndex = 0;
            this.tabPageWalls.Text = "Walls";
            this.tabPageWalls.UseVisualStyleBackColor = true;
            // 
            // tabPageObjects
            // 
            this.tabPageObjects.Location = new System.Drawing.Point(4, 24);
            this.tabPageObjects.Name = "tabPageObjects";
            this.tabPageObjects.Padding = new System.Windows.Forms.Padding(3);
            this.tabPageObjects.Size = new System.Drawing.Size(732, 86);
            this.tabPageObjects.TabIndex = 1;
            this.tabPageObjects.Text = "Objects";
            this.tabPageObjects.UseVisualStyleBackColor = true;
            // 
            // TexturePanel
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.tabControl1);
            this.Name = "TexturePanel";
            this.Size = new System.Drawing.Size(740, 150);
            this.Load += new System.EventHandler(this.TexturePanel_Load);
            this.TabIndexChanged += new System.EventHandler(this.TexturePanel_TabIndexChanged);
            this.tabControl1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private TabControl tabControl1;
        private TabPage tabPageWalls;
        private TabPage tabPageObjects;
    }
}
