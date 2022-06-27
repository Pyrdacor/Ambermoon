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
            this.comboBoxType = new System.Windows.Forms.ComboBox();
            this.comboBoxCharacter = new System.Windows.Forms.ComboBox();
            this.SuspendLayout();
            // 
            // comboBoxType
            // 
            this.comboBoxType.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxType.FormattingEnabled = true;
            this.comboBoxType.Location = new System.Drawing.Point(3, 3);
            this.comboBoxType.Name = "comboBoxType";
            this.comboBoxType.Size = new System.Drawing.Size(121, 23);
            this.comboBoxType.TabIndex = 0;
            this.comboBoxType.SelectedIndexChanged += new System.EventHandler(this.comboBoxType_SelectedIndexChanged);
            this.comboBoxType.Click += new System.EventHandler(this.comboBoxType_Click);
            // 
            // comboBoxCharacter
            // 
            this.comboBoxCharacter.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.comboBoxCharacter.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxCharacter.FormattingEnabled = true;
            this.comboBoxCharacter.Location = new System.Drawing.Point(127, 3);
            this.comboBoxCharacter.Name = "comboBoxCharacter";
            this.comboBoxCharacter.Size = new System.Drawing.Size(203, 23);
            this.comboBoxCharacter.TabIndex = 1;
            this.comboBoxCharacter.SelectedIndexChanged += new System.EventHandler(this.comboBoxCharacter_SelectedIndexChanged);
            this.comboBoxCharacter.Click += new System.EventHandler(this.comboBoxCharacter_Click);
            // 
            // CharacterRow
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.comboBoxCharacter);
            this.Controls.Add(this.comboBoxType);
            this.Name = "CharacterRow";
            this.Size = new System.Drawing.Size(333, 31);
            this.Click += new System.EventHandler(this.CharacterRow_Click);
            this.ResumeLayout(false);

        }

        #endregion

        private ComboBox comboBoxType;
        private ComboBox comboBoxCharacter;
    }
}
