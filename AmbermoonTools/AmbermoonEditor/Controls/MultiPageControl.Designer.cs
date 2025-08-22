namespace AmbermoonEditor.Controls;

partial class MultiPageControl
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

    #region Component Designer generated code

    /// <summary> 
    /// Required method for Designer support - do not modify 
    /// the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        comboBoxPages = new System.Windows.Forms.ComboBox();
        buttonPrev = new System.Windows.Forms.Button();
        buttonNext = new System.Windows.Forms.Button();
        panelContent = new System.Windows.Forms.Panel();
        SuspendLayout();
        // 
        // comboBoxPages
        // 
        comboBoxPages.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        comboBoxPages.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        comboBoxPages.FormattingEnabled = true;
        comboBoxPages.Location = new System.Drawing.Point(165, 3);
        comboBoxPages.Name = "comboBoxPages";
        comboBoxPages.Size = new System.Drawing.Size(662, 23);
        comboBoxPages.TabIndex = 0;
        comboBoxPages.SelectedIndexChanged += ComboBoxPages_SelectedIndexChanged;
        // 
        // buttonPrev
        // 
        buttonPrev.Enabled = false;
        buttonPrev.Location = new System.Drawing.Point(3, 2);
        buttonPrev.Name = "buttonPrev";
        buttonPrev.Size = new System.Drawing.Size(75, 23);
        buttonPrev.TabIndex = 1;
        buttonPrev.Text = "<";
        buttonPrev.UseVisualStyleBackColor = true;
        buttonPrev.Click += ButtonPrev_Click;
        // 
        // buttonNext
        // 
        buttonNext.Enabled = false;
        buttonNext.Location = new System.Drawing.Point(84, 3);
        buttonNext.Name = "buttonNext";
        buttonNext.Size = new System.Drawing.Size(75, 23);
        buttonNext.TabIndex = 2;
        buttonNext.Text = ">";
        buttonNext.UseVisualStyleBackColor = true;
        buttonNext.Click += ButtonNext_Click;
        // 
        // panelContent
        // 
        panelContent.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        panelContent.Location = new System.Drawing.Point(3, 31);
        panelContent.Name = "panelContent";
        panelContent.Size = new System.Drawing.Size(824, 437);
        panelContent.TabIndex = 3;
        // 
        // MultiPageControl
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
        AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        Controls.Add(panelContent);
        Controls.Add(buttonNext);
        Controls.Add(buttonPrev);
        Controls.Add(comboBoxPages);
        Name = "MultiPageControl";
        Size = new System.Drawing.Size(830, 471);
        ResumeLayout(false);
    }

    #endregion

    private System.Windows.Forms.ComboBox comboBoxPages;
    private System.Windows.Forms.Button buttonPrev;
    private System.Windows.Forms.Button buttonNext;
    private System.Windows.Forms.Panel panelContent;
}
