
namespace AmbermoonMapEditor2D
{
    partial class ImageDisplayForm
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
            this.drawPanelImage = new System.Windows.Forms.DrawPanel();
            this.SuspendLayout();
            // 
            // drawPanelImage
            // 
            this.drawPanelImage.BackColor = System.Drawing.Color.Black;
            this.drawPanelImage.Dock = System.Windows.Forms.DockStyle.Fill;
            this.drawPanelImage.Location = new System.Drawing.Point(0, 0);
            this.drawPanelImage.Name = "drawPanelImage";
            this.drawPanelImage.Size = new System.Drawing.Size(344, 220);
            this.drawPanelImage.TabIndex = 0;
            this.drawPanelImage.Paint += new System.Windows.Forms.PaintEventHandler(this.drawPanelImage_Paint);
            // 
            // ImageDisplayForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(344, 220);
            this.Controls.Add(this.drawPanelImage);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedToolWindow;
            this.MaximizeBox = false;
            this.Name = "ImageDisplayForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Show Image";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.DrawPanel drawPanelImage;
    }
}