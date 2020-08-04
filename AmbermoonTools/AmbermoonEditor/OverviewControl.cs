namespace AmbermoonEditor
{
    public partial class OverviewControl : DataControl
    {
        private System.Windows.Forms.TextBox textBox1;

        public OverviewControl()
        {

        }

        protected override void InitializeComponent()
        {
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.SuspendLayout();
            // 
            // textBox1
            // 
            this.textBox1.BackColor = System.Drawing.SystemColors.Control;
            this.textBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textBox1.Location = new System.Drawing.Point(0, 0);
            this.textBox1.Multiline = true;
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(790, 400);
            this.textBox1.TabIndex = 0;
            this.textBox1.Text = "\r\n\r\n\r\nWelcome to Ambermoon Editor.\r\n\r\nThis tool is still work in progress. ;)";
            this.textBox1.TextAlign = System.Windows.Forms.HorizontalAlignment.Center;
            // 
            // OverviewControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.Controls.Add(this.textBox1);
            this.Name = "OverviewControl";
            this.ResumeLayout(false);
            this.PerformLayout();

        }
    }
}
