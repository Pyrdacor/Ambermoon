using System.Windows.Forms;

namespace AmbermoonEditor;

partial class MapTextControl
{
    private System.Windows.Forms.ComboBox comboBoxMaps;
    private System.Windows.Forms.Label labelMap;
    private System.Windows.Forms.TextBox textBoxName;
    private System.Windows.Forms.GroupBox groupBoxTexts;
    private System.Windows.Forms.ComboBox comboBoxTexts;
    private System.Windows.Forms.Button buttonRemove;
    private System.Windows.Forms.Button buttonAdd;
    private System.Windows.Forms.TextBox textBoxText;
    private System.Windows.Forms.Label labelName;

    protected override void InitializeComponent()
    {
        comboBoxMaps = new ComboBox();
        labelMap = new Label();
        labelName = new Label();
        textBoxName = new TextBox();
        groupBoxTexts = new GroupBox();
        textBoxText = new TextBox();
        buttonRemove = new Button();
        buttonAdd = new Button();
        comboBoxTexts = new ComboBox();
        groupBoxTexts.SuspendLayout();
        SuspendLayout();
        // 
        // comboBoxMaps
        // 
        comboBoxMaps.DropDownStyle = ComboBoxStyle.DropDownList;
        comboBoxMaps.FormattingEnabled = true;
        comboBoxMaps.Location = new System.Drawing.Point(54, 6);
        comboBoxMaps.Margin = new Padding(3, 2, 3, 2);
        comboBoxMaps.Name = "comboBoxMaps";
        comboBoxMaps.Size = new System.Drawing.Size(270, 22);
        comboBoxMaps.TabIndex = 0;
        comboBoxMaps.SelectedIndexChanged += ComboBoxMaps_SelectedIndexChanged;
        // 
        // labelMap
        // 
        labelMap.AutoSize = true;
        labelMap.Location = new System.Drawing.Point(12, 9);
        labelMap.Name = "labelMap";
        labelMap.Size = new System.Drawing.Size(35, 14);
        labelMap.TabIndex = 1;
        labelMap.Text = "Map:";
        // 
        // labelName
        // 
        labelName.AutoSize = true;
        labelName.Location = new System.Drawing.Point(333, 9);
        labelName.Name = "labelName";
        labelName.Size = new System.Drawing.Size(70, 14);
        labelName.TabIndex = 2;
        labelName.Text = "Map name:";
        // 
        // textBoxName
        // 
        textBoxName.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        textBoxName.Location = new System.Drawing.Point(406, 6);
        textBoxName.Margin = new Padding(3, 2, 3, 2);
        textBoxName.Name = "textBoxName";
        textBoxName.Size = new System.Drawing.Size(384, 22);
        textBoxName.TabIndex = 3;
        // 
        // groupBoxTexts
        // 
        groupBoxTexts.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
        groupBoxTexts.Controls.Add(textBoxText);
        groupBoxTexts.Controls.Add(buttonRemove);
        groupBoxTexts.Controls.Add(buttonAdd);
        groupBoxTexts.Controls.Add(comboBoxTexts);
        groupBoxTexts.Location = new System.Drawing.Point(12, 32);
        groupBoxTexts.Margin = new Padding(3, 2, 3, 2);
        groupBoxTexts.Name = "groupBoxTexts";
        groupBoxTexts.Padding = new Padding(3, 2, 3, 2);
        groupBoxTexts.Size = new System.Drawing.Size(778, 360);
        groupBoxTexts.TabIndex = 4;
        groupBoxTexts.TabStop = false;
        groupBoxTexts.Text = "Texts";
        // 
        // textBoxText
        // 
        textBoxText.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
        textBoxText.Location = new System.Drawing.Point(15, 46);
        textBoxText.Margin = new Padding(3, 2, 3, 2);
        textBoxText.Multiline = true;
        textBoxText.Name = "textBoxText";
        textBoxText.Size = new System.Drawing.Size(749, 302);
        textBoxText.TabIndex = 5;
        // 
        // buttonRemove
        // 
        buttonRemove.Location = new System.Drawing.Point(184, 19);
        buttonRemove.Margin = new Padding(3, 2, 3, 2);
        buttonRemove.Name = "buttonRemove";
        buttonRemove.Size = new System.Drawing.Size(82, 22);
        buttonRemove.TabIndex = 1;
        buttonRemove.Text = "Remove";
        buttonRemove.UseVisualStyleBackColor = true;
        buttonRemove.Click += ButtonRemove_Click;
        // 
        // buttonAdd
        // 
        buttonAdd.Location = new System.Drawing.Point(96, 19);
        buttonAdd.Margin = new Padding(3, 2, 3, 2);
        buttonAdd.Name = "buttonAdd";
        buttonAdd.Size = new System.Drawing.Size(82, 22);
        buttonAdd.TabIndex = 1;
        buttonAdd.Text = "Add";
        buttonAdd.UseVisualStyleBackColor = true;
        buttonAdd.Click += ButtonAdd_Click;
        // 
        // comboBoxTexts
        // 
        comboBoxTexts.DropDownStyle = ComboBoxStyle.DropDownList;
        comboBoxTexts.FormattingEnabled = true;
        comboBoxTexts.Location = new System.Drawing.Point(15, 20);
        comboBoxTexts.Margin = new Padding(3, 2, 3, 2);
        comboBoxTexts.Name = "comboBoxTexts";
        comboBoxTexts.Size = new System.Drawing.Size(77, 22);
        comboBoxTexts.TabIndex = 0;
        comboBoxTexts.SelectedIndexChanged += ComboBoxTexts_SelectedIndexChanged;
        // 
        // MapTextControl
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(7F, 14F);
        Controls.Add(groupBoxTexts);
        Controls.Add(textBoxName);
        Controls.Add(labelName);
        Controls.Add(labelMap);
        Controls.Add(comboBoxMaps);
        Font = new System.Drawing.Font("Consolas", 9F);
        Name = "MapTextControl";
        Size = new System.Drawing.Size(800, 400);
        Load += MapTextControl_Load;
        groupBoxTexts.ResumeLayout(false);
        groupBoxTexts.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }
}
