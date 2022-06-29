using System;
using System.Drawing;
using System.Windows.Forms;

namespace AmbermoonMapEditor2D
{
    public partial class WorkingForm : Form
    {
        readonly string message;

        public WorkingForm(string message)
        {
            this.message = message;

            InitializeComponent();
        }

        private void WorkingForm_Load(object sender, EventArgs e)
        {
            var dotSize = TextRenderer.MeasureText(".", labelMessage.Font);
            var textSize = TextRenderer.MeasureText(message, labelMessage.Font);
            var sizeDiff = textSize - dotSize;

            Width += sizeDiff.Width;
            Height += sizeDiff.Height;

            labelMessage.Text = message;
        }

        public void Finish()
        {
            Invoke(() => DialogResult = DialogResult.OK);
        }

        private void WorkingForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            e.Cancel = e.CloseReason == CloseReason.UserClosing && DialogResult == DialogResult.Cancel;
        }
    }
}
