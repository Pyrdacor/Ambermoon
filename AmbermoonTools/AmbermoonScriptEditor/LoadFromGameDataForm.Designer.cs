namespace AmbermoonScriptEditor;

partial class LoadFromGameDataForm
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
        comboBoxType = new ComboBox();
        labelItem = new Label();
        comboBoxItems = new ComboBox();
        buttonLoad = new Button();
        buttonCancel = new Button();
        SuspendLayout();
        // 
        // labelType
        // 
        labelType.AutoSize = true;
        labelType.Location = new Point(12, 9);
        labelType.Name = "labelType";
        labelType.Size = new Size(62, 15);
        labelType.TabIndex = 0;
        labelType.Text = "Data Type:";
        // 
        // comboBoxType
        // 
        comboBoxType.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        comboBoxType.DropDownStyle = ComboBoxStyle.DropDownList;
        comboBoxType.FormattingEnabled = true;
        comboBoxType.Items.AddRange(new object[] { "Map", "NPC", "Player" });
        comboBoxType.Location = new Point(80, 6);
        comboBoxType.Name = "comboBoxType";
        comboBoxType.Size = new Size(303, 23);
        comboBoxType.TabIndex = 1;
        comboBoxType.SelectedIndexChanged += ComboBoxType_SelectedIndexChanged;
        // 
        // labelItem
        // 
        labelItem.AutoSize = true;
        labelItem.Location = new Point(12, 42);
        labelItem.Name = "labelItem";
        labelItem.Size = new Size(34, 15);
        labelItem.TabIndex = 2;
        labelItem.Text = "Item:";
        // 
        // comboBoxItems
        // 
        comboBoxItems.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        comboBoxItems.DropDownStyle = ComboBoxStyle.DropDownList;
        comboBoxItems.FormattingEnabled = true;
        comboBoxItems.Location = new Point(80, 39);
        comboBoxItems.Name = "comboBoxItems";
        comboBoxItems.Size = new Size(303, 23);
        comboBoxItems.TabIndex = 3;
        // 
        // buttonLoad
        // 
        buttonLoad.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
        buttonLoad.Location = new Point(227, 68);
        buttonLoad.Name = "buttonLoad";
        buttonLoad.Size = new Size(75, 23);
        buttonLoad.TabIndex = 4;
        buttonLoad.Text = "&Load";
        buttonLoad.UseVisualStyleBackColor = true;
        buttonLoad.Click += ButtonLoad_Click;
        // 
        // buttonCancel
        // 
        buttonCancel.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
        buttonCancel.DialogResult = DialogResult.Cancel;
        buttonCancel.Location = new Point(308, 68);
        buttonCancel.Name = "buttonCancel";
        buttonCancel.Size = new Size(75, 23);
        buttonCancel.TabIndex = 5;
        buttonCancel.Text = "&Cancel";
        buttonCancel.UseVisualStyleBackColor = true;
        // 
        // LoadFromGameDataForm
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(395, 98);
        Controls.Add(buttonCancel);
        Controls.Add(buttonLoad);
        Controls.Add(comboBoxItems);
        Controls.Add(labelItem);
        Controls.Add(comboBoxType);
        Controls.Add(labelType);
        MinimumSize = new Size(411, 137);
        Name = "LoadFromGameDataForm";
        Text = "Load from game data";
        Load += LoadFromGameDataForm_Load;
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private Label labelType;
    private ComboBox comboBoxType;
    private Label labelItem;
    private ComboBox comboBoxItems;
    private Button buttonLoad;
    private Button buttonCancel;
}