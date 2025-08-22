namespace AmbermoonEditor;

partial class CharacterControl
{
    protected override void InitializeComponent()
    {
        divider = new System.Windows.Forms.Label();
        labelDmgAndDef = new System.Windows.Forms.Label();
        labelGoldAndFood = new System.Windows.Forms.Label();
        labelSLPAndTP = new System.Windows.Forms.Label();
        labelSP = new System.Windows.Forms.Label();
        labelHP = new System.Windows.Forms.Label();
        labelExp = new System.Windows.Forms.Label();
        labelClassAndLevel = new System.Windows.Forms.Label();
        labelAge = new System.Windows.Forms.Label();
        labelGender = new System.Windows.Forms.Label();
        labelRace = new System.Windows.Forms.Label();
        labelName = new System.Windows.Forms.Label();
        pictureBoxPortrait = new System.Windows.Forms.PictureBox();
        panelCharInfo = new System.Windows.Forms.Panel();
        labelCharacter = new System.Windows.Forms.Label();
        comboBoxCharacters = new System.Windows.Forms.ComboBox();
        multiPageControl = new AmbermoonEditor.Controls.MultiPageControl();
        ((System.ComponentModel.ISupportInitialize)pictureBoxPortrait).BeginInit();
        panelCharInfo.SuspendLayout();
        SuspendLayout();
        // 
        // divider
        // 
        divider.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left;
        divider.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
        divider.Location = new System.Drawing.Point(294, 39);
        divider.Name = "divider";
        divider.Size = new System.Drawing.Size(2, 553);
        divider.TabIndex = 7;
        // 
        // labelDmgAndDef
        // 
        labelDmgAndDef.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelDmgAndDef.Font = new System.Drawing.Font("Consolas", 12F);
        labelDmgAndDef.Location = new System.Drawing.Point(3, 254);
        labelDmgAndDef.Name = "labelDmgAndDef";
        labelDmgAndDef.Size = new System.Drawing.Size(282, 24);
        labelDmgAndDef.TabIndex = 12;
        labelDmgAndDef.Text = "<dmg+def>";
        labelDmgAndDef.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // labelGoldAndFood
        // 
        labelGoldAndFood.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelGoldAndFood.Font = new System.Drawing.Font("Consolas", 12F);
        labelGoldAndFood.Location = new System.Drawing.Point(3, 230);
        labelGoldAndFood.Name = "labelGoldAndFood";
        labelGoldAndFood.Size = new System.Drawing.Size(282, 24);
        labelGoldAndFood.TabIndex = 11;
        labelGoldAndFood.Text = "<gold+food>";
        labelGoldAndFood.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // labelSLPAndTP
        // 
        labelSLPAndTP.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelSLPAndTP.Font = new System.Drawing.Font("Consolas", 12F);
        labelSLPAndTP.Location = new System.Drawing.Point(3, 205);
        labelSLPAndTP.Name = "labelSLPAndTP";
        labelSLPAndTP.Size = new System.Drawing.Size(282, 24);
        labelSLPAndTP.TabIndex = 10;
        labelSLPAndTP.Text = "<slp+tp>";
        labelSLPAndTP.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // labelSP
        // 
        labelSP.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelSP.Font = new System.Drawing.Font("Consolas", 12F);
        labelSP.Location = new System.Drawing.Point(3, 181);
        labelSP.Name = "labelSP";
        labelSP.Size = new System.Drawing.Size(282, 24);
        labelSP.TabIndex = 9;
        labelSP.Text = "<sp>";
        labelSP.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // labelHP
        // 
        labelHP.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelHP.Font = new System.Drawing.Font("Consolas", 12F);
        labelHP.Location = new System.Drawing.Point(3, 157);
        labelHP.Name = "labelHP";
        labelHP.Size = new System.Drawing.Size(282, 24);
        labelHP.TabIndex = 8;
        labelHP.Text = "<hp>";
        labelHP.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // labelExp
        // 
        labelExp.AutoSize = true;
        labelExp.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0);
        labelExp.Location = new System.Drawing.Point(138, 103);
        labelExp.Name = "labelExp";
        labelExp.Size = new System.Drawing.Size(54, 19);
        labelExp.TabIndex = 6;
        labelExp.Text = "<exp>";
        // 
        // labelClassAndLevel
        // 
        labelClassAndLevel.AutoSize = true;
        labelClassAndLevel.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0);
        labelClassAndLevel.Location = new System.Drawing.Point(138, 79);
        labelClassAndLevel.Name = "labelClassAndLevel";
        labelClassAndLevel.Size = new System.Drawing.Size(108, 19);
        labelClassAndLevel.TabIndex = 5;
        labelClassAndLevel.Text = "<class+lvl>";
        // 
        // labelAge
        // 
        labelAge.AutoSize = true;
        labelAge.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0);
        labelAge.Location = new System.Drawing.Point(138, 56);
        labelAge.Name = "labelAge";
        labelAge.Size = new System.Drawing.Size(54, 19);
        labelAge.TabIndex = 4;
        labelAge.Text = "<age>";
        // 
        // labelGender
        // 
        labelGender.AutoSize = true;
        labelGender.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0);
        labelGender.Location = new System.Drawing.Point(138, 33);
        labelGender.Name = "labelGender";
        labelGender.Size = new System.Drawing.Size(81, 19);
        labelGender.TabIndex = 3;
        labelGender.Text = "<gender>";
        // 
        // labelRace
        // 
        labelRace.AutoSize = true;
        labelRace.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, 0);
        labelRace.Location = new System.Drawing.Point(138, 9);
        labelRace.Name = "labelRace";
        labelRace.Size = new System.Drawing.Size(63, 19);
        labelRace.TabIndex = 2;
        labelRace.Text = "<race>";
        // 
        // labelName
        // 
        labelName.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        labelName.Font = new System.Drawing.Font("Consolas", 12F, System.Drawing.FontStyle.Bold);
        labelName.Location = new System.Drawing.Point(3, 133);
        labelName.Name = "labelName";
        labelName.Size = new System.Drawing.Size(282, 24);
        labelName.TabIndex = 1;
        labelName.Text = "<name>";
        labelName.TextAlign = System.Drawing.ContentAlignment.TopCenter;
        // 
        // pictureBoxPortrait
        // 
        pictureBoxPortrait.BackColor = System.Drawing.Color.Black;
        pictureBoxPortrait.BorderStyle = System.Windows.Forms.BorderStyle.Fixed3D;
        pictureBoxPortrait.Location = new System.Drawing.Point(3, 3);
        pictureBoxPortrait.Name = "pictureBoxPortrait";
        pictureBoxPortrait.Size = new System.Drawing.Size(128, 127);
        pictureBoxPortrait.TabIndex = 0;
        pictureBoxPortrait.TabStop = false;
        // 
        // panelCharInfo
        // 
        panelCharInfo.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left;
        panelCharInfo.Controls.Add(labelDmgAndDef);
        panelCharInfo.Controls.Add(labelGoldAndFood);
        panelCharInfo.Controls.Add(labelSLPAndTP);
        panelCharInfo.Controls.Add(labelSP);
        panelCharInfo.Controls.Add(labelHP);
        panelCharInfo.Controls.Add(labelExp);
        panelCharInfo.Controls.Add(labelClassAndLevel);
        panelCharInfo.Controls.Add(labelAge);
        panelCharInfo.Controls.Add(labelGender);
        panelCharInfo.Controls.Add(labelRace);
        panelCharInfo.Controls.Add(labelName);
        panelCharInfo.Controls.Add(pictureBoxPortrait);
        panelCharInfo.Location = new System.Drawing.Point(3, 39);
        panelCharInfo.Name = "panelCharInfo";
        panelCharInfo.Size = new System.Drawing.Size(285, 552);
        panelCharInfo.TabIndex = 14;
        // 
        // labelCharacter
        // 
        labelCharacter.AutoSize = true;
        labelCharacter.Location = new System.Drawing.Point(6, 12);
        labelCharacter.Name = "labelCharacter";
        labelCharacter.Size = new System.Drawing.Size(77, 14);
        labelCharacter.TabIndex = 16;
        labelCharacter.Text = "Charakter:";
        // 
        // comboBoxCharacters
        // 
        comboBoxCharacters.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
        comboBoxCharacters.FormattingEnabled = true;
        comboBoxCharacters.Location = new System.Drawing.Point(89, 9);
        comboBoxCharacters.Margin = new System.Windows.Forms.Padding(3, 2, 3, 2);
        comboBoxCharacters.Name = "comboBoxCharacters";
        comboBoxCharacters.Size = new System.Drawing.Size(284, 22);
        comboBoxCharacters.TabIndex = 15;
        comboBoxCharacters.SelectedIndexChanged += ComboBoxCharacters_SelectedIndexChanged;
        // 
        // multiPageControl
        // 
        multiPageControl.Anchor = System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left | System.Windows.Forms.AnchorStyles.Right;
        multiPageControl.Location = new System.Drawing.Point(302, 39);
        multiPageControl.Name = "multiPageControl";
        multiPageControl.Size = new System.Drawing.Size(1212, 552);
        multiPageControl.TabIndex = 17;
        // 
        // CharacterControl
        // 
        AutoScaleDimensions = new System.Drawing.SizeF(7F, 14F);
        Controls.Add(multiPageControl);
        Controls.Add(labelCharacter);
        Controls.Add(comboBoxCharacters);
        Controls.Add(panelCharInfo);
        Controls.Add(divider);
        Font = new System.Drawing.Font("Consolas", 9F);
        Name = "CharacterControl";
        Size = new System.Drawing.Size(1517, 594);
        ((System.ComponentModel.ISupportInitialize)pictureBoxPortrait).EndInit();
        panelCharInfo.ResumeLayout(false);
        panelCharInfo.PerformLayout();
        ResumeLayout(false);
        PerformLayout();

    }
    private System.Windows.Forms.Label divider;
    private System.Windows.Forms.Label labelDmgAndDef;
    private System.Windows.Forms.Label labelGoldAndFood;
    private System.Windows.Forms.Label labelSLPAndTP;
    private System.Windows.Forms.Label labelSP;
    private System.Windows.Forms.Label labelHP;
    private System.Windows.Forms.Label labelName;
    private System.Windows.Forms.Label labelExp;
    private System.Windows.Forms.Label labelClassAndLevel;
    private System.Windows.Forms.Label labelAge;
    private System.Windows.Forms.Label labelGender;
    private System.Windows.Forms.Label labelRace;
    private System.Windows.Forms.PictureBox pictureBoxPortrait;
    private System.Windows.Forms.Panel panelCharInfo;
    private System.Windows.Forms.Label labelCharacter;
    private System.Windows.Forms.ComboBox comboBoxCharacters;
    private Controls.MultiPageControl multiPageControl;
}
