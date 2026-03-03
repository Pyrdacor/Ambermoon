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
            menuStrip1 = new MenuStrip();
            fileToolStripMenuItem = new ToolStripMenuItem();
            newToolStripMenuItem = new ToolStripMenuItem();
            openToolStripMenuItem = new ToolStripMenuItem();
            saveToolStripMenuItem = new ToolStripMenuItem();
            openPaletteToolStripMenuItem = new ToolStripMenuItem();
            editToolStripMenuItem = new ToolStripMenuItem();
            cropToolStripMenuItem = new ToolStripMenuItem();
            copyToolStripMenuItem = new ToolStripMenuItem();
            pasteToolStripMenuItem = new ToolStripMenuItem();
            copyHexBytesToolStripMenuItem = new ToolStripMenuItem();
            toolStripSeparator2 = new ToolStripSeparator();
            resizeToolStripMenuItem = new ToolStripMenuItem();
            modeToolStripMenuItem = new ToolStripMenuItem();
            bpp3ToolStripMenuItem = new ToolStripMenuItem();
            bpp4ToolStripMenuItem = new ToolStripMenuItem();
            bpp5ToolStripMenuItem = new ToolStripMenuItem();
            toolStripSeparator1 = new ToolStripSeparator();
            paletteOffsetToolStripMenuItem = new ToolStripMenuItem();
            toolStripMenuItemPalOffset0 = new ToolStripMenuItem();
            toolStripMenuItemPalOffset16 = new ToolStripMenuItem();
            toolStripMenuItemPalOffset24 = new ToolStripMenuItem();
            imagePanel = new RenderPanel();
            panel1 = new Panel();
            statusStrip1 = new StatusStrip();
            toolStripStatusLabel1 = new ToolStripStatusLabel();
            toolStripStatusLabelX = new ToolStripStatusLabel();
            toolStripStatusLabel2 = new ToolStripStatusLabel();
            toolStripStatusLabelY = new ToolStripStatusLabel();
            toolStripStatusLabel3 = new ToolStripStatusLabel();
            toolStripStatusLabel4 = new ToolStripStatusLabel();
            toolStripStatusLabelWidth = new ToolStripStatusLabel();
            toolStripStatusLabel6 = new ToolStripStatusLabel();
            toolStripStatusLabelHeight = new ToolStripStatusLabel();
            menuStrip1.SuspendLayout();
            panel1.SuspendLayout();
            statusStrip1.SuspendLayout();
            SuspendLayout();
            // 
            // menuStrip1
            // 
            menuStrip1.Items.AddRange(new ToolStripItem[] { fileToolStripMenuItem, editToolStripMenuItem, modeToolStripMenuItem });
            menuStrip1.Location = new Point(0, 0);
            menuStrip1.Name = "menuStrip1";
            menuStrip1.Size = new Size(209, 24);
            menuStrip1.TabIndex = 0;
            menuStrip1.Text = "menuStrip1";
            // 
            // fileToolStripMenuItem
            // 
            fileToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { newToolStripMenuItem, openToolStripMenuItem, saveToolStripMenuItem, openPaletteToolStripMenuItem });
            fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            fileToolStripMenuItem.Size = new Size(37, 20);
            fileToolStripMenuItem.Text = "File";
            // 
            // newToolStripMenuItem
            // 
            newToolStripMenuItem.Name = "newToolStripMenuItem";
            newToolStripMenuItem.Size = new Size(142, 22);
            newToolStripMenuItem.Text = "New";
            newToolStripMenuItem.Click += NewToolStripMenuItem_Click;
            // 
            // openToolStripMenuItem
            // 
            openToolStripMenuItem.Name = "openToolStripMenuItem";
            openToolStripMenuItem.Size = new Size(142, 22);
            openToolStripMenuItem.Text = "Open";
            openToolStripMenuItem.Click += OpenToolStripMenuItem_Click;
            // 
            // saveToolStripMenuItem
            // 
            saveToolStripMenuItem.Enabled = false;
            saveToolStripMenuItem.Name = "saveToolStripMenuItem";
            saveToolStripMenuItem.Size = new Size(142, 22);
            saveToolStripMenuItem.Text = "Save as";
            saveToolStripMenuItem.Click += SaveToolStripMenuItem_Click;
            // 
            // openPaletteToolStripMenuItem
            // 
            openPaletteToolStripMenuItem.Name = "openPaletteToolStripMenuItem";
            openPaletteToolStripMenuItem.Size = new Size(142, 22);
            openPaletteToolStripMenuItem.Text = "Open Palette";
            openPaletteToolStripMenuItem.Click += OpenPaletteToolStripMenuItem_Click;
            // 
            // editToolStripMenuItem
            // 
            editToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { cropToolStripMenuItem, copyToolStripMenuItem, pasteToolStripMenuItem, copyHexBytesToolStripMenuItem, toolStripSeparator2, resizeToolStripMenuItem });
            editToolStripMenuItem.Name = "editToolStripMenuItem";
            editToolStripMenuItem.Size = new Size(39, 20);
            editToolStripMenuItem.Text = "Edit";
            // 
            // cropToolStripMenuItem
            // 
            cropToolStripMenuItem.Name = "cropToolStripMenuItem";
            cropToolStripMenuItem.Size = new Size(156, 22);
            cropToolStripMenuItem.Text = "Crop";
            cropToolStripMenuItem.Click += cropToolStripMenuItem_Click;
            // 
            // copyToolStripMenuItem
            // 
            copyToolStripMenuItem.Name = "copyToolStripMenuItem";
            copyToolStripMenuItem.Size = new Size(156, 22);
            copyToolStripMenuItem.Text = "Copy";
            copyToolStripMenuItem.Click += copyToolStripMenuItem_Click;
            // 
            // pasteToolStripMenuItem
            // 
            pasteToolStripMenuItem.Name = "pasteToolStripMenuItem";
            pasteToolStripMenuItem.Size = new Size(156, 22);
            pasteToolStripMenuItem.Text = "Paste";
            pasteToolStripMenuItem.Click += pasteToolStripMenuItem_Click;
            // 
            // copyHexBytesToolStripMenuItem
            // 
            copyHexBytesToolStripMenuItem.Name = "copyHexBytesToolStripMenuItem";
            copyHexBytesToolStripMenuItem.Size = new Size(156, 22);
            copyHexBytesToolStripMenuItem.Text = "Copy Hex Bytes";
            copyHexBytesToolStripMenuItem.Click += copyHexBytesToolStripMenuItem_Click;
            // 
            // toolStripSeparator2
            // 
            toolStripSeparator2.Name = "toolStripSeparator2";
            toolStripSeparator2.Size = new Size(153, 6);
            // 
            // resizeToolStripMenuItem
            // 
            resizeToolStripMenuItem.Name = "resizeToolStripMenuItem";
            resizeToolStripMenuItem.Size = new Size(156, 22);
            resizeToolStripMenuItem.Text = "Resize";
            resizeToolStripMenuItem.Click += resizeToolStripMenuItem_Click;
            // 
            // modeToolStripMenuItem
            // 
            modeToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { bpp3ToolStripMenuItem, bpp4ToolStripMenuItem, bpp5ToolStripMenuItem, toolStripSeparator1, paletteOffsetToolStripMenuItem });
            modeToolStripMenuItem.Name = "modeToolStripMenuItem";
            modeToolStripMenuItem.Size = new Size(50, 20);
            modeToolStripMenuItem.Text = "Mode";
            // 
            // bpp3ToolStripMenuItem
            // 
            bpp3ToolStripMenuItem.CheckOnClick = true;
            bpp3ToolStripMenuItem.Name = "bpp3ToolStripMenuItem";
            bpp3ToolStripMenuItem.Size = new Size(145, 22);
            bpp3ToolStripMenuItem.Text = "3 BPP";
            bpp3ToolStripMenuItem.CheckedChanged += bpp3ToolStripMenuItem_CheckedChanged;
            // 
            // bpp4ToolStripMenuItem
            // 
            bpp4ToolStripMenuItem.CheckOnClick = true;
            bpp4ToolStripMenuItem.Name = "bpp4ToolStripMenuItem";
            bpp4ToolStripMenuItem.Size = new Size(145, 22);
            bpp4ToolStripMenuItem.Text = "4 BPP";
            bpp4ToolStripMenuItem.CheckedChanged += bpp4ToolStripMenuItem_CheckedChanged;
            // 
            // bpp5ToolStripMenuItem
            // 
            bpp5ToolStripMenuItem.Checked = true;
            bpp5ToolStripMenuItem.CheckOnClick = true;
            bpp5ToolStripMenuItem.CheckState = CheckState.Checked;
            bpp5ToolStripMenuItem.Name = "bpp5ToolStripMenuItem";
            bpp5ToolStripMenuItem.Size = new Size(145, 22);
            bpp5ToolStripMenuItem.Text = "5 BPP";
            bpp5ToolStripMenuItem.CheckedChanged += bpp5ToolStripMenuItem_CheckedChanged;
            // 
            // toolStripSeparator1
            // 
            toolStripSeparator1.Name = "toolStripSeparator1";
            toolStripSeparator1.Size = new Size(142, 6);
            // 
            // paletteOffsetToolStripMenuItem
            // 
            paletteOffsetToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { toolStripMenuItemPalOffset0, toolStripMenuItemPalOffset16, toolStripMenuItemPalOffset24 });
            paletteOffsetToolStripMenuItem.Name = "paletteOffsetToolStripMenuItem";
            paletteOffsetToolStripMenuItem.Size = new Size(145, 22);
            paletteOffsetToolStripMenuItem.Text = "Palette Offset";
            // 
            // toolStripMenuItemPalOffset0
            // 
            toolStripMenuItemPalOffset0.Checked = true;
            toolStripMenuItemPalOffset0.CheckOnClick = true;
            toolStripMenuItemPalOffset0.CheckState = CheckState.Checked;
            toolStripMenuItemPalOffset0.Name = "toolStripMenuItemPalOffset0";
            toolStripMenuItemPalOffset0.Size = new Size(86, 22);
            toolStripMenuItemPalOffset0.Text = "0";
            toolStripMenuItemPalOffset0.CheckedChanged += toolStripMenuItemPalOffset0_CheckedChanged;
            // 
            // toolStripMenuItemPalOffset16
            // 
            toolStripMenuItemPalOffset16.CheckOnClick = true;
            toolStripMenuItemPalOffset16.Enabled = false;
            toolStripMenuItemPalOffset16.Name = "toolStripMenuItemPalOffset16";
            toolStripMenuItemPalOffset16.Size = new Size(86, 22);
            toolStripMenuItemPalOffset16.Text = "16";
            toolStripMenuItemPalOffset16.CheckedChanged += toolStripMenuItemPalOffset16_CheckedChanged;
            // 
            // toolStripMenuItemPalOffset24
            // 
            toolStripMenuItemPalOffset24.CheckOnClick = true;
            toolStripMenuItemPalOffset24.Enabled = false;
            toolStripMenuItemPalOffset24.Name = "toolStripMenuItemPalOffset24";
            toolStripMenuItemPalOffset24.Size = new Size(86, 22);
            toolStripMenuItemPalOffset24.Text = "24";
            toolStripMenuItemPalOffset24.CheckedChanged += toolStripMenuItemPalOffset24_CheckedChanged;
            // 
            // imagePanel
            // 
            imagePanel.BackColor = Color.Black;
            imagePanel.Location = new Point(12, 27);
            imagePanel.Name = "imagePanel";
            imagePanel.Size = new Size(186, 143);
            imagePanel.TabIndex = 1;
            imagePanel.Paint += imagePanel_Paint;
            imagePanel.MouseDown += imagePanel_MouseDown;
            imagePanel.MouseMove += imagePanel_MouseMove;
            // 
            // panel1
            // 
            panel1.Controls.Add(statusStrip1);
            panel1.Location = new Point(0, 27);
            panel1.Name = "panel1";
            panel1.Size = new Size(209, 176);
            panel1.TabIndex = 2;
            // 
            // statusStrip1
            // 
            statusStrip1.Items.AddRange(new ToolStripItem[] { toolStripStatusLabel1, toolStripStatusLabelX, toolStripStatusLabel2, toolStripStatusLabelY, toolStripStatusLabel3, toolStripStatusLabel4, toolStripStatusLabelWidth, toolStripStatusLabel6, toolStripStatusLabelHeight });
            statusStrip1.Location = new Point(0, 154);
            statusStrip1.Name = "statusStrip1";
            statusStrip1.Size = new Size(209, 22);
            statusStrip1.TabIndex = 0;
            statusStrip1.Text = "statusStrip1";
            // 
            // toolStripStatusLabel1
            // 
            toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            toolStripStatusLabel1.Size = new Size(14, 17);
            toolStripStatusLabel1.Text = "X";
            toolStripStatusLabel1.Visible = false;
            // 
            // toolStripStatusLabelX
            // 
            toolStripStatusLabelX.Name = "toolStripStatusLabelX";
            toolStripStatusLabelX.Size = new Size(13, 17);
            toolStripStatusLabelX.Text = "0";
            toolStripStatusLabelX.Visible = false;
            // 
            // toolStripStatusLabel2
            // 
            toolStripStatusLabel2.Name = "toolStripStatusLabel2";
            toolStripStatusLabel2.Size = new Size(14, 17);
            toolStripStatusLabel2.Text = "Y";
            toolStripStatusLabel2.Visible = false;
            // 
            // toolStripStatusLabelY
            // 
            toolStripStatusLabelY.Name = "toolStripStatusLabelY";
            toolStripStatusLabelY.Size = new Size(13, 17);
            toolStripStatusLabelY.Text = "0";
            toolStripStatusLabelY.Visible = false;
            // 
            // toolStripStatusLabel3
            // 
            toolStripStatusLabel3.Name = "toolStripStatusLabel3";
            toolStripStatusLabel3.Size = new Size(10, 17);
            toolStripStatusLabel3.Text = "|";
            toolStripStatusLabel3.Visible = false;
            // 
            // toolStripStatusLabel4
            // 
            toolStripStatusLabel4.Name = "toolStripStatusLabel4";
            toolStripStatusLabel4.Size = new Size(39, 17);
            toolStripStatusLabel4.Text = "Width";
            toolStripStatusLabel4.Visible = false;
            // 
            // toolStripStatusLabelWidth
            // 
            toolStripStatusLabelWidth.Name = "toolStripStatusLabelWidth";
            toolStripStatusLabelWidth.Size = new Size(13, 17);
            toolStripStatusLabelWidth.Text = "0";
            toolStripStatusLabelWidth.Visible = false;
            // 
            // toolStripStatusLabel6
            // 
            toolStripStatusLabel6.Name = "toolStripStatusLabel6";
            toolStripStatusLabel6.Size = new Size(43, 17);
            toolStripStatusLabel6.Text = "Height";
            toolStripStatusLabel6.Visible = false;
            // 
            // toolStripStatusLabelHeight
            // 
            toolStripStatusLabelHeight.Name = "toolStripStatusLabelHeight";
            toolStripStatusLabelHeight.Size = new Size(13, 17);
            toolStripStatusLabelHeight.Text = "0";
            toolStripStatusLabelHeight.Visible = false;
            // 
            // MainForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            ClientSize = new Size(209, 204);
            Controls.Add(imagePanel);
            Controls.Add(menuStrip1);
            Controls.Add(panel1);
            MainMenuStrip = menuStrip1;
            Name = "MainForm";
            Text = "Form1";
            FormClosing += MainForm_FormClosing;
            Load += MainForm_Load;
            MouseMove += MainForm_MouseMove;
            menuStrip1.ResumeLayout(false);
            menuStrip1.PerformLayout();
            panel1.ResumeLayout(false);
            panel1.PerformLayout();
            statusStrip1.ResumeLayout(false);
            statusStrip1.PerformLayout();
            ResumeLayout(false);
            PerformLayout();

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