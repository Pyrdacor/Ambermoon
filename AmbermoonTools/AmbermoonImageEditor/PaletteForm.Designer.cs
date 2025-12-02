namespace AmbermoonImageEditor
{
    partial class PaletteForm
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
            panelPalette = new Panel();
            SuspendLayout();
            // 
            // panelPalette
            // 
            panelPalette.BackColor = Color.Black;
            panelPalette.Location = new Point(0, 0);
            panelPalette.Name = "panelPalette";
            panelPalette.Size = new Size(256, 128);
            panelPalette.TabIndex = 0;
            panelPalette.Click += PanelPalette_Click;
            panelPalette.Paint += PanelPalette_Paint;
            panelPalette.MouseDown += PanelPalette_MouseDown;
            // 
            // PaletteForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            AutoSize = true;
            AutoSizeMode = AutoSizeMode.GrowAndShrink;
            ClientSize = new Size(256, 128);
            Controls.Add(panelPalette);
            FormBorderStyle = FormBorderStyle.FixedToolWindow;
            MaximizeBox = false;
            MinimizeBox = false;
            Name = "PaletteForm";
            ShowIcon = false;
            ShowInTaskbar = false;
            SizeGripStyle = SizeGripStyle.Hide;
            StartPosition = FormStartPosition.Manual;
            Text = "Palette";
            FormClosing += PaletteForm_FormClosing;
            ResumeLayout(false);

        }

        #endregion

        private Panel panelPalette;
    }
}