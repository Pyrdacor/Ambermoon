namespace AmbermoonUIEventEditor
{
    partial class EventEditForm
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
            labelType = new Label();
            comboBoxTypes = new ComboBox();
            SuspendLayout();
            // 
            // labelType
            // 
            labelType.AutoSize = true;
            labelType.Location = new Point(12, 9);
            labelType.Name = "labelType";
            labelType.Size = new Size(43, 20);
            labelType.TabIndex = 0;
            labelType.Text = "Type:";
            // 
            // comboBoxTypes
            // 
            comboBoxTypes.DropDownStyle = ComboBoxStyle.DropDownList;
            comboBoxTypes.FormattingEnabled = true;
            comboBoxTypes.Location = new Point(61, 6);
            comboBoxTypes.Name = "comboBoxTypes";
            comboBoxTypes.Size = new Size(318, 28);
            comboBoxTypes.TabIndex = 1;
            // 
            // EventEditForm
            // 
            AutoScaleDimensions = new SizeF(8F, 20F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(397, 39);
            Controls.Add(comboBoxTypes);
            Controls.Add(labelType);
            Name = "EventEditForm";
            Text = "EventEditForm";
            FormClosing += EventEditForm_FormClosing;
            Load += EventEditForm_Load;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label labelType;
        private ComboBox comboBoxTypes;
    }
}