namespace Ambermoon3DMapEditor
{
    partial class TextureBrowser
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
            panelTextures = new RenderPanel();
            buttonAddTexture = new Button();
            buttonClose = new Button();
            SuspendLayout();
            // 
            // panelTextures
            // 
            panelTextures.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            panelTextures.AutoScroll = true;
            panelTextures.Location = new Point(12, 12);
            panelTextures.Name = "panelTextures";
            panelTextures.Size = new Size(776, 168);
            panelTextures.TabIndex = 0;
            panelTextures.Scroll += panelTextures_Scroll;
            panelTextures.Paint += panelTextures_Paint;
            panelTextures.MouseDown += panelTextures_MouseDown;
            // 
            // buttonAddTexture
            // 
            buttonAddTexture.Location = new Point(12, 224);
            buttonAddTexture.Name = "buttonAddTexture";
            buttonAddTexture.Size = new Size(130, 29);
            buttonAddTexture.TabIndex = 1;
            buttonAddTexture.Text = "Add Texture ...";
            buttonAddTexture.UseVisualStyleBackColor = true;
            buttonAddTexture.Click += buttonAddTexture_Click;
            // 
            // buttonClose
            // 
            buttonClose.Location = new Point(658, 224);
            buttonClose.Name = "buttonClose";
            buttonClose.Size = new Size(130, 29);
            buttonClose.TabIndex = 2;
            buttonClose.Text = "Close";
            buttonClose.UseVisualStyleBackColor = true;
            buttonClose.Click += buttonClose_Click;
            // 
            // TextureBrowser
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 265);
            Controls.Add(buttonClose);
            Controls.Add(buttonAddTexture);
            Controls.Add(panelTextures);
            MaximumSize = new Size(10000, 312);
            MinimumSize = new Size(480, 312);
            Name = "TextureBrowser";
            StartPosition = FormStartPosition.CenterParent;
            Text = "Texture Browser";
            Load += TextureBrowser_Load;
            ResumeLayout(false);
        }

        #endregion

        private RenderPanel panelTextures;
        private Button buttonAddTexture;
        private Button buttonClose;
    }
}