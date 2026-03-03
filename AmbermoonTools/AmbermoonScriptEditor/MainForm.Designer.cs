namespace AmbermoonScriptEditor;

partial class MainForm
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    ///  Clean up any resources being used.
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
    ///  Required method for Designer support - do not modify
    ///  the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
        textBoxScriptFile = new TextBox();
        buttonCompile = new Button();
        textBoxScript = new TextBox();
        menuMain = new MenuStrip();
        fileToolStripMenuItem = new ToolStripMenuItem();
        newToolStripMenuItem = new ToolStripMenuItem();
        fromGameDataToolStripMenuItem = new ToolStripMenuItem();
        saveToolStripMenuItem = new ToolStripMenuItem();
        saveasToolStripMenuItem = new ToolStripMenuItem();
        openToolStripMenuItem = new ToolStripMenuItem();
        toolStripSeparator1 = new ToolStripSeparator();
        toolStripSeparator2 = new ToolStripSeparator();
        quitToolStripMenuItem = new ToolStripMenuItem();
        menuMain.SuspendLayout();
        SuspendLayout();
        // 
        // textBoxScriptFile
        // 
        textBoxScriptFile.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        textBoxScriptFile.Location = new Point(8, 28);
        textBoxScriptFile.Margin = new Padding(2);
        textBoxScriptFile.Name = "textBoxScriptFile";
        textBoxScriptFile.Size = new Size(462, 23);
        textBoxScriptFile.TabIndex = 0;
        textBoxScriptFile.Text = "D:\\Projects\\Ambermoon\\AmbermoonTools\\AmbermoonScriptEditor\\TestScript.txt";
        // 
        // buttonCompile
        // 
        buttonCompile.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        buttonCompile.Location = new Point(474, 28);
        buttonCompile.Margin = new Padding(2);
        buttonCompile.Name = "buttonCompile";
        buttonCompile.Size = new Size(75, 25);
        buttonCompile.TabIndex = 1;
        buttonCompile.Text = "Compile";
        buttonCompile.UseVisualStyleBackColor = true;
        buttonCompile.Click += ButtonCompile_Click;
        // 
        // textBoxScript
        // 
        textBoxScript.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
        textBoxScript.Enabled = false;
        textBoxScript.Location = new Point(8, 87);
        textBoxScript.Margin = new Padding(2);
        textBoxScript.Multiline = true;
        textBoxScript.Name = "textBoxScript";
        textBoxScript.ScrollBars = ScrollBars.Vertical;
        textBoxScript.Size = new Size(541, 172);
        textBoxScript.TabIndex = 4;
        // 
        // menuMain
        // 
        menuMain.Items.AddRange(new ToolStripItem[] { fileToolStripMenuItem });
        menuMain.Location = new Point(0, 0);
        menuMain.Name = "menuMain";
        menuMain.Size = new Size(560, 24);
        menuMain.TabIndex = 5;
        menuMain.Text = "menuStrip1";
        // 
        // fileToolStripMenuItem
        // 
        fileToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { newToolStripMenuItem, openToolStripMenuItem, fromGameDataToolStripMenuItem, toolStripSeparator1, saveToolStripMenuItem, saveasToolStripMenuItem, toolStripSeparator2, quitToolStripMenuItem });
        fileToolStripMenuItem.Name = "fileToolStripMenuItem";
        fileToolStripMenuItem.Size = new Size(37, 20);
        fileToolStripMenuItem.Text = "&File";
        // 
        // newToolStripMenuItem
        // 
        newToolStripMenuItem.Name = "newToolStripMenuItem";
        newToolStripMenuItem.ShortcutKeys = Keys.Control | Keys.N;
        newToolStripMenuItem.Size = new Size(216, 22);
        newToolStripMenuItem.Text = "&New";
        newToolStripMenuItem.Click += NewToolStripMenuItem_Click;
        // 
        // fromGameDataToolStripMenuItem
        // 
        fromGameDataToolStripMenuItem.Name = "fromGameDataToolStripMenuItem";
        fromGameDataToolStripMenuItem.ShortcutKeys = Keys.Control | Keys.O;
        fromGameDataToolStripMenuItem.Size = new Size(216, 22);
        fromGameDataToolStripMenuItem.Text = "From &game data ...";
        fromGameDataToolStripMenuItem.Click += LoadFromGameDataToolStripMenuItem_Click;
        // 
        // saveToolStripMenuItem
        // 
        saveToolStripMenuItem.Enabled = false;
        saveToolStripMenuItem.Name = "saveToolStripMenuItem";
        saveToolStripMenuItem.ShortcutKeys = Keys.Control | Keys.S;
        saveToolStripMenuItem.Size = new Size(216, 22);
        saveToolStripMenuItem.Text = "&Save";
        // 
        // saveasToolStripMenuItem
        // 
        saveasToolStripMenuItem.Name = "saveasToolStripMenuItem";
        saveasToolStripMenuItem.ShortcutKeys = Keys.Control | Keys.Shift | Keys.S;
        saveasToolStripMenuItem.Size = new Size(216, 22);
        saveasToolStripMenuItem.Text = "Save &as ...";
        // 
        // openToolStripMenuItem
        // 
        openToolStripMenuItem.Name = "openToolStripMenuItem";
        openToolStripMenuItem.Size = new Size(216, 22);
        openToolStripMenuItem.Text = "&Open ...";
        // 
        // toolStripSeparator1
        // 
        toolStripSeparator1.Name = "toolStripSeparator1";
        toolStripSeparator1.Size = new Size(213, 6);
        // 
        // toolStripSeparator2
        // 
        toolStripSeparator2.Name = "toolStripSeparator2";
        toolStripSeparator2.Size = new Size(213, 6);
        // 
        // quitToolStripMenuItem
        // 
        quitToolStripMenuItem.Name = "quitToolStripMenuItem";
        quitToolStripMenuItem.ShortcutKeys = Keys.Alt | Keys.F4;
        quitToolStripMenuItem.Size = new Size(216, 22);
        quitToolStripMenuItem.Text = "&Quit";
        quitToolStripMenuItem.Click += QuitToolStripMenuItem_Click;
        // 
        // MainForm
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(560, 270);
        Controls.Add(textBoxScript);
        Controls.Add(buttonCompile);
        Controls.Add(textBoxScriptFile);
        Controls.Add(menuMain);
        Icon = (Icon)resources.GetObject("$this.Icon");
        MainMenuStrip = menuMain;
        Margin = new Padding(2);
        Name = "MainForm";
        Text = "Ambermoon Script Editor";
        Load += MainForm_Load;
        menuMain.ResumeLayout(false);
        menuMain.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private TextBox textBoxScriptFile;
    private Button buttonCompile;
    private TextBox textBoxScript;
    private MenuStrip menuMain;
    private ToolStripMenuItem fileToolStripMenuItem;
    private ToolStripMenuItem newToolStripMenuItem;
    private ToolStripMenuItem fromGameDataToolStripMenuItem;
    private ToolStripMenuItem saveToolStripMenuItem;
    private ToolStripMenuItem saveasToolStripMenuItem;
    private ToolStripMenuItem openToolStripMenuItem;
    private ToolStripSeparator toolStripSeparator1;
    private ToolStripSeparator toolStripSeparator2;
    private ToolStripMenuItem quitToolStripMenuItem;
}
