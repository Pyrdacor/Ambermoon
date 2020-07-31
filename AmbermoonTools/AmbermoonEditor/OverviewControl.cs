namespace AmbermoonEditor
{
    public partial class OverviewControl : DataControl
    {
        private System.Windows.Forms.Label label1;

        public OverviewControl()
        {

        }

        private void InitializeComponent()
        {
            this.label1 = new System.Windows.Forms.Label();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.BackColor = System.Drawing.Color.Red;
            this.label1.Location = new System.Drawing.Point(0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(780, 390);
            this.label1.TabIndex = 0;
            this.label1.Text = "label1";
            // 
            // OverviewControl
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 20F);
            this.Controls.Add(this.label1);
            this.Name = "OverviewControl";
            this.ResumeLayout(false);

        }
    }
}
