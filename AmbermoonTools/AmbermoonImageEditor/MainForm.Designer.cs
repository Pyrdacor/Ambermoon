namespace AmbermoonImageEditor
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
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.fileToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.newToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.openToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.editToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.cropToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.copyToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.pasteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.copyHexBytesToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.resizeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.modeToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.bpp3ToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.bpp4ToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.bpp5ToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.paletteOffsetToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemPalOffset0 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemPalOffset16 = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMenuItemPalOffset24 = new System.Windows.Forms.ToolStripMenuItem();
            this.imagePanel = new System.Windows.Forms.RenderPanel();
            this.panel1 = new System.Windows.Forms.Panel();
            this.statusStrip1 = new System.Windows.Forms.StatusStrip();
            this.toolStripStatusLabel1 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelX = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabel2 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelY = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabel3 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabel4 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelWidth = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabel6 = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripStatusLabelHeight = new System.Windows.Forms.ToolStripStatusLabel();
            this.openPaletteToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.menuStrip1.SuspendLayout();
            this.panel1.SuspendLayout();
            this.statusStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // menuStrip1
            // 
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.fileToolStripMenuItem,
            this.editToolStripMenuItem,
            this.modeToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(0, 0);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(209, 24);
            this.menuStrip1.TabIndex = 0;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            this.fileToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.newToolStripMenuItem,
            this.openToolStripMenuItem,
            this.saveToolStripMenuItem,
            this.openPaletteToolStripMenuItem});
            this.fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            this.fileToolStripMenuItem.Size = new System.Drawing.Size(37, 20);
            this.fileToolStripMenuItem.Text = "File";
            // 
            // newToolStripMenuItem
            // 
            this.newToolStripMenuItem.Name = "newToolStripMenuItem";
            this.newToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.newToolStripMenuItem.Text = "New";
            this.newToolStripMenuItem.Click += new System.EventHandler(this.newToolStripMenuItem_Click);
            // 
            // openToolStripMenuItem
            // 
            this.openToolStripMenuItem.Name = "openToolStripMenuItem";
            this.openToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.openToolStripMenuItem.Text = "Open";
            this.openToolStripMenuItem.Click += new System.EventHandler(this.openToolStripMenuItem_Click);
            // 
            // saveToolStripMenuItem
            // 
            this.saveToolStripMenuItem.Enabled = false;
            this.saveToolStripMenuItem.Name = "saveToolStripMenuItem";
            this.saveToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.saveToolStripMenuItem.Text = "Save as";
            this.saveToolStripMenuItem.Click += new System.EventHandler(this.saveToolStripMenuItem_Click);
            // 
            // editToolStripMenuItem
            // 
            this.editToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.cropToolStripMenuItem,
            this.copyToolStripMenuItem,
            this.pasteToolStripMenuItem,
            this.copyHexBytesToolStripMenuItem,
            this.toolStripSeparator2,
            this.resizeToolStripMenuItem});
            this.editToolStripMenuItem.Name = "editToolStripMenuItem";
            this.editToolStripMenuItem.Size = new System.Drawing.Size(39, 20);
            this.editToolStripMenuItem.Text = "Edit";
            // 
            // cropToolStripMenuItem
            // 
            this.cropToolStripMenuItem.Name = "cropToolStripMenuItem";
            this.cropToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.cropToolStripMenuItem.Text = "Crop";
            this.cropToolStripMenuItem.Click += new System.EventHandler(this.cropToolStripMenuItem_Click);
            // 
            // copyToolStripMenuItem
            // 
            this.copyToolStripMenuItem.Name = "copyToolStripMenuItem";
            this.copyToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.copyToolStripMenuItem.Text = "Copy";
            this.copyToolStripMenuItem.Click += new System.EventHandler(this.copyToolStripMenuItem_Click);
            // 
            // pasteToolStripMenuItem
            // 
            this.pasteToolStripMenuItem.Name = "pasteToolStripMenuItem";
            this.pasteToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.pasteToolStripMenuItem.Text = "Paste";
            this.pasteToolStripMenuItem.Click += new System.EventHandler(this.pasteToolStripMenuItem_Click);
            // 
            // copyHexBytesToolStripMenuItem
            // 
            this.copyHexBytesToolStripMenuItem.Name = "copyHexBytesToolStripMenuItem";
            this.copyHexBytesToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.copyHexBytesToolStripMenuItem.Text = "Copy Hex Bytes";
            this.copyHexBytesToolStripMenuItem.Click += new System.EventHandler(this.copyHexBytesToolStripMenuItem_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(154, 6);
            // 
            // resizeToolStripMenuItem
            // 
            this.resizeToolStripMenuItem.Name = "resizeToolStripMenuItem";
            this.resizeToolStripMenuItem.Size = new System.Drawing.Size(157, 22);
            this.resizeToolStripMenuItem.Text = "Resize";
            this.resizeToolStripMenuItem.Click += new System.EventHandler(this.resizeToolStripMenuItem_Click);
            // 
            // modeToolStripMenuItem
            // 
            this.modeToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.bpp3ToolStripMenuItem,
            this.bpp4ToolStripMenuItem,
            this.bpp5ToolStripMenuItem,
            this.toolStripSeparator1,
            this.paletteOffsetToolStripMenuItem});
            this.modeToolStripMenuItem.Name = "modeToolStripMenuItem";
            this.modeToolStripMenuItem.Size = new System.Drawing.Size(50, 20);
            this.modeToolStripMenuItem.Text = "Mode";
            // 
            // bpp3ToolStripMenuItem
            // 
            this.bpp3ToolStripMenuItem.CheckOnClick = true;
            this.bpp3ToolStripMenuItem.Name = "bpp3ToolStripMenuItem";
            this.bpp3ToolStripMenuItem.Size = new System.Drawing.Size(145, 22);
            this.bpp3ToolStripMenuItem.Text = "3 BPP";
            this.bpp3ToolStripMenuItem.CheckedChanged += new System.EventHandler(this.bpp3ToolStripMenuItem_CheckedChanged);
            // 
            // bpp4ToolStripMenuItem
            // 
            this.bpp4ToolStripMenuItem.CheckOnClick = true;
            this.bpp4ToolStripMenuItem.Name = "bpp4ToolStripMenuItem";
            this.bpp4ToolStripMenuItem.Size = new System.Drawing.Size(145, 22);
            this.bpp4ToolStripMenuItem.Text = "4 BPP";
            this.bpp4ToolStripMenuItem.CheckedChanged += new System.EventHandler(this.bpp4ToolStripMenuItem_CheckedChanged);
            // 
            // bpp5ToolStripMenuItem
            // 
            this.bpp5ToolStripMenuItem.Checked = true;
            this.bpp5ToolStripMenuItem.CheckOnClick = true;
            this.bpp5ToolStripMenuItem.CheckState = System.Windows.Forms.CheckState.Checked;
            this.bpp5ToolStripMenuItem.Name = "bpp5ToolStripMenuItem";
            this.bpp5ToolStripMenuItem.Size = new System.Drawing.Size(145, 22);
            this.bpp5ToolStripMenuItem.Text = "5 BPP";
            this.bpp5ToolStripMenuItem.CheckedChanged += new System.EventHandler(this.bpp5ToolStripMenuItem_CheckedChanged);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(142, 6);
            // 
            // paletteOffsetToolStripMenuItem
            // 
            this.paletteOffsetToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripMenuItemPalOffset0,
            this.toolStripMenuItemPalOffset16,
            this.toolStripMenuItemPalOffset24});
            this.paletteOffsetToolStripMenuItem.Name = "paletteOffsetToolStripMenuItem";
            this.paletteOffsetToolStripMenuItem.Size = new System.Drawing.Size(145, 22);
            this.paletteOffsetToolStripMenuItem.Text = "Palette Offset";
            // 
            // toolStripMenuItemPalOffset0
            // 
            this.toolStripMenuItemPalOffset0.Checked = true;
            this.toolStripMenuItemPalOffset0.CheckOnClick = true;
            this.toolStripMenuItemPalOffset0.CheckState = System.Windows.Forms.CheckState.Checked;
            this.toolStripMenuItemPalOffset0.Name = "toolStripMenuItemPalOffset0";
            this.toolStripMenuItemPalOffset0.Size = new System.Drawing.Size(86, 22);
            this.toolStripMenuItemPalOffset0.Text = "0";
            this.toolStripMenuItemPalOffset0.CheckedChanged += new System.EventHandler(this.toolStripMenuItemPalOffset0_CheckedChanged);
            // 
            // toolStripMenuItemPalOffset16
            // 
            this.toolStripMenuItemPalOffset16.CheckOnClick = true;
            this.toolStripMenuItemPalOffset16.Enabled = false;
            this.toolStripMenuItemPalOffset16.Name = "toolStripMenuItemPalOffset16";
            this.toolStripMenuItemPalOffset16.Size = new System.Drawing.Size(86, 22);
            this.toolStripMenuItemPalOffset16.Text = "16";
            this.toolStripMenuItemPalOffset16.CheckedChanged += new System.EventHandler(this.toolStripMenuItemPalOffset16_CheckedChanged);
            // 
            // toolStripMenuItemPalOffset24
            // 
            this.toolStripMenuItemPalOffset24.CheckOnClick = true;
            this.toolStripMenuItemPalOffset24.Enabled = false;
            this.toolStripMenuItemPalOffset24.Name = "toolStripMenuItemPalOffset24";
            this.toolStripMenuItemPalOffset24.Size = new System.Drawing.Size(86, 22);
            this.toolStripMenuItemPalOffset24.Text = "24";
            this.toolStripMenuItemPalOffset24.CheckedChanged += new System.EventHandler(this.toolStripMenuItemPalOffset24_CheckedChanged);
            // 
            // imagePanel
            // 
            this.imagePanel.BackColor = System.Drawing.Color.Black;
            this.imagePanel.Location = new System.Drawing.Point(12, 27);
            this.imagePanel.Name = "imagePanel";
            this.imagePanel.Size = new System.Drawing.Size(186, 143);
            this.imagePanel.TabIndex = 1;
            this.imagePanel.Paint += new System.Windows.Forms.PaintEventHandler(this.imagePanel_Paint);
            this.imagePanel.MouseDown += new System.Windows.Forms.MouseEventHandler(this.imagePanel_MouseDown);
            this.imagePanel.MouseMove += new System.Windows.Forms.MouseEventHandler(this.imagePanel_MouseMove);
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.statusStrip1);
            this.panel1.Location = new System.Drawing.Point(0, 27);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(209, 176);
            this.panel1.TabIndex = 2;
            // 
            // statusStrip1
            // 
            this.statusStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.toolStripStatusLabel1,
            this.toolStripStatusLabelX,
            this.toolStripStatusLabel2,
            this.toolStripStatusLabelY,
            this.toolStripStatusLabel3,
            this.toolStripStatusLabel4,
            this.toolStripStatusLabelWidth,
            this.toolStripStatusLabel6,
            this.toolStripStatusLabelHeight});
            this.statusStrip1.Location = new System.Drawing.Point(0, 154);
            this.statusStrip1.Name = "statusStrip1";
            this.statusStrip1.Size = new System.Drawing.Size(209, 22);
            this.statusStrip1.TabIndex = 0;
            this.statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            this.toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            this.toolStripStatusLabel1.Size = new System.Drawing.Size(14, 17);
            this.toolStripStatusLabel1.Text = "X";
            this.toolStripStatusLabel1.Visible = false;
            // 
            // toolStripStatusLabelX
            // 
            this.toolStripStatusLabelX.Name = "toolStripStatusLabelX";
            this.toolStripStatusLabelX.Size = new System.Drawing.Size(13, 17);
            this.toolStripStatusLabelX.Text = "0";
            this.toolStripStatusLabelX.Visible = false;
            // 
            // toolStripStatusLabel2
            // 
            this.toolStripStatusLabel2.Name = "toolStripStatusLabel2";
            this.toolStripStatusLabel2.Size = new System.Drawing.Size(14, 17);
            this.toolStripStatusLabel2.Text = "Y";
            this.toolStripStatusLabel2.Visible = false;
            // 
            // toolStripStatusLabelY
            // 
            this.toolStripStatusLabelY.Name = "toolStripStatusLabelY";
            this.toolStripStatusLabelY.Size = new System.Drawing.Size(13, 17);
            this.toolStripStatusLabelY.Text = "0";
            this.toolStripStatusLabelY.Visible = false;
            // 
            // toolStripStatusLabel3
            // 
            this.toolStripStatusLabel3.Name = "toolStripStatusLabel3";
            this.toolStripStatusLabel3.Size = new System.Drawing.Size(10, 17);
            this.toolStripStatusLabel3.Text = "|";
            this.toolStripStatusLabel3.Visible = false;
            // 
            // toolStripStatusLabel4
            // 
            this.toolStripStatusLabel4.Name = "toolStripStatusLabel4";
            this.toolStripStatusLabel4.Size = new System.Drawing.Size(39, 17);
            this.toolStripStatusLabel4.Text = "Width";
            this.toolStripStatusLabel4.Visible = false;
            // 
            // toolStripStatusLabelWidth
            // 
            this.toolStripStatusLabelWidth.Name = "toolStripStatusLabelWidth";
            this.toolStripStatusLabelWidth.Size = new System.Drawing.Size(13, 17);
            this.toolStripStatusLabelWidth.Text = "0";
            this.toolStripStatusLabelWidth.Visible = false;
            // 
            // toolStripStatusLabel6
            // 
            this.toolStripStatusLabel6.Name = "toolStripStatusLabel6";
            this.toolStripStatusLabel6.Size = new System.Drawing.Size(43, 17);
            this.toolStripStatusLabel6.Text = "Height";
            this.toolStripStatusLabel6.Visible = false;
            // 
            // toolStripStatusLabelHeight
            // 
            this.toolStripStatusLabelHeight.Name = "toolStripStatusLabelHeight";
            this.toolStripStatusLabelHeight.Size = new System.Drawing.Size(13, 17);
            this.toolStripStatusLabelHeight.Text = "0";
            this.toolStripStatusLabelHeight.Visible = false;
            // 
            // openPaletteToolStripMenuItem
            // 
            this.openPaletteToolStripMenuItem.Name = "openPaletteToolStripMenuItem";
            this.openPaletteToolStripMenuItem.Size = new System.Drawing.Size(180, 22);
            this.openPaletteToolStripMenuItem.Text = "Open Palette";
            this.openPaletteToolStripMenuItem.Click += new System.EventHandler(this.openPaletteToolStripMenuItem_Click);
            // 
            // MainForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(209, 204);
            this.Controls.Add(this.imagePanel);
            this.Controls.Add(this.menuStrip1);
            this.Controls.Add(this.panel1);
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "MainForm";
            this.Text = "Form1";
            this.Load += new System.EventHandler(this.MainForm_Load);
            this.MouseMove += new System.Windows.Forms.MouseEventHandler(this.MainForm_MouseMove);
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.statusStrip1.ResumeLayout(false);
            this.statusStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private MenuStrip menuStrip1;
        private ToolStripMenuItem fileToolStripMenuItem;
        private ToolStripMenuItem newToolStripMenuItem;
        private ToolStripMenuItem openToolStripMenuItem;
        private RenderPanel imagePanel;
        private ToolStripMenuItem editToolStripMenuItem;
        private ToolStripMenuItem cropToolStripMenuItem;
        private Panel panel1;
        private StatusStrip statusStrip1;
        private ToolStripStatusLabel toolStripStatusLabel1;
        private ToolStripStatusLabel toolStripStatusLabelX;
        private ToolStripStatusLabel toolStripStatusLabel2;
        private ToolStripStatusLabel toolStripStatusLabelY;
        private ToolStripStatusLabel toolStripStatusLabel3;
        private ToolStripStatusLabel toolStripStatusLabel4;
        private ToolStripStatusLabel toolStripStatusLabelWidth;
        private ToolStripStatusLabel toolStripStatusLabel6;
        private ToolStripStatusLabel toolStripStatusLabelHeight;
        private ToolStripMenuItem saveToolStripMenuItem;
        private ToolStripMenuItem modeToolStripMenuItem;
        private ToolStripMenuItem bpp3ToolStripMenuItem;
        private ToolStripMenuItem bpp4ToolStripMenuItem;
        private ToolStripMenuItem bpp5ToolStripMenuItem;
        private ToolStripMenuItem paletteOffsetToolStripMenuItem;
        private ToolStripMenuItem toolStripMenuItemPalOffset0;
        private ToolStripMenuItem toolStripMenuItemPalOffset16;
        private ToolStripMenuItem toolStripMenuItemPalOffset24;
        private ToolStripSeparator toolStripSeparator1;
        private ToolStripMenuItem copyToolStripMenuItem;
        private ToolStripMenuItem pasteToolStripMenuItem;
        private ToolStripMenuItem copyHexBytesToolStripMenuItem;
        private ToolStripSeparator toolStripSeparator2;
        private ToolStripMenuItem resizeToolStripMenuItem;
        private ToolStripMenuItem openPaletteToolStripMenuItem;
    }
}