namespace AmbermoonMapCharEditor
{
    partial class CharacterRow
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
            this.components = new System.ComponentModel.Container();
            this.comboBoxType = new System.Windows.Forms.ComboBox();
            this.comboBoxCharacter = new System.Windows.Forms.ComboBox();
            this.label1 = new System.Windows.Forms.Label();
            this.toolTipCharacter = new System.Windows.Forms.ToolTip(this.components);
            this.SuspendLayout();
            // 
            // comboBoxType
            // 
            this.comboBoxType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxType.FormattingEnabled = true;
            this.comboBoxType.Items.AddRange(new object[] {
            "Partymember",
            "NPC",
            "Monster",
            "Map object"});
            this.comboBoxType.Location = new System.Drawing.Point(11, 2);
            this.comboBoxType.Margin = new System.Windows.Forms.Padding(4);
            this.comboBoxType.Name = "comboBoxType";
            this.comboBoxType.Size = new System.Drawing.Size(135, 29);
            this.comboBoxType.TabIndex = 0;
            this.comboBoxType.SelectedIndexChanged += new System.EventHandler(this.comboBoxType_SelectedIndexChanged);
            // 
            // comboBoxCharacter
            // 
            this.comboBoxCharacter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.comboBoxCharacter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxCharacter.FormattingEnabled = true;
            this.comboBoxCharacter.Location = new System.Drawing.Point(154, 2);
            this.comboBoxCharacter.Margin = new System.Windows.Forms.Padding(4);
            this.comboBoxCharacter.Name = "comboBoxCharacter";
            this.comboBoxCharacter.Size = new System.Drawing.Size(236, 29);
            this.comboBoxCharacter.TabIndex = 1;
            this.comboBoxCharacter.DrawItem += new System.Windows.Forms.DrawItemEventHandler(this.comboBoxCharacter_DrawItem);
            this.comboBoxCharacter.SelectedIndexChanged += new System.EventHandler(this.comboBoxCharacter_SelectedIndexChanged);
            this.comboBoxCharacter.DropDownClosed += new System.EventHandler(this.comboBoxCharacter_DropDownClosed);
            // 
            // label1
            // 
            this.label1.Location = new System.Drawing.Point(0, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(12, 26);
            this.label1.TabIndex = 2;
            this.label1.Text = ":";
            this.label1.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // toolTipCharacter
            // 
            this.toolTipCharacter.AutomaticDelay = 150;
            this.toolTipCharacter.AutoPopDelay = 99999999;
            this.toolTipCharacter.InitialDelay = 150;
            this.toolTipCharacter.ReshowDelay = 30;
            // 
            // CharacterRow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(9F, 21F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.comboBoxType);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.comboBoxCharacter);
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "CharacterRow";
            this.Size = new System.Drawing.Size(392, 32);
            this.Load += new System.EventHandler(this.CharacterRow_Load);
            this.Click += new System.EventHandler(this.CharacterRow_Click);
            this.ResumeLayout(false);

        }

        #endregion

        private ComboBox comboBoxType;
        private ComboBox comboBoxCharacter;
        private Label label1;
        private ToolTip toolTipCharacter;
    }
}
