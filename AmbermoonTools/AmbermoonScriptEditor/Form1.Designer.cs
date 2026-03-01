namespace AmbermoonScriptEditor;

partial class Form1
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
        textBoxScript = new TextBox();
        button1 = new Button();
        textBoxMap = new TextBox();
        button2 = new Button();
        textBox1 = new TextBox();
        SuspendLayout();
        // 
        // textBoxScript
        // 
        textBoxScript.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        textBoxScript.Location = new Point(8, 2);
        textBoxScript.Margin = new Padding(2);
        textBoxScript.Name = "textBoxScript";
        textBoxScript.Size = new Size(462, 23);
        textBoxScript.TabIndex = 0;
        textBoxScript.Text = "D:\\Projects\\Ambermoon\\AmbermoonTools\\AmbermoonScriptEditor\\TestScript.txt";
        // 
        // button1
        // 
        button1.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        button1.Location = new Point(473, 0);
        button1.Margin = new Padding(2);
        button1.Name = "button1";
        button1.Size = new Size(78, 25);
        button1.TabIndex = 1;
        button1.Text = "Compile";
        button1.UseVisualStyleBackColor = true;
        button1.Click += button1_Click;
        // 
        // textBoxMap
        // 
        textBoxMap.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
        textBoxMap.Location = new Point(8, 29);
        textBoxMap.Margin = new Padding(2);
        textBoxMap.Name = "textBoxMap";
        textBoxMap.Size = new Size(462, 23);
        textBoxMap.TabIndex = 2;
        textBoxMap.Text = "D:\\Projects\\Ambermoon Advanced\\german\\Amberfiles\\2Map_data\\259";
        // 
        // button2
        // 
        button2.Anchor = AnchorStyles.Top | AnchorStyles.Right;
        button2.Location = new Point(473, 29);
        button2.Margin = new Padding(2);
        button2.Name = "button2";
        button2.Size = new Size(78, 25);
        button2.TabIndex = 3;
        button2.Text = "Load Map";
        button2.UseVisualStyleBackColor = true;
        button2.Click += button2_Click;
        // 
        // textBox1
        // 
        textBox1.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
        textBox1.Enabled = false;
        textBox1.Location = new Point(8, 56);
        textBox1.Margin = new Padding(2);
        textBox1.Multiline = true;
        textBox1.Name = "textBox1";
        textBox1.ScrollBars = ScrollBars.Vertical;
        textBox1.Size = new Size(541, 203);
        textBox1.TabIndex = 4;
        // 
        // Form1
        // 
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(560, 270);
        Controls.Add(textBox1);
        Controls.Add(button2);
        Controls.Add(textBoxMap);
        Controls.Add(button1);
        Controls.Add(textBoxScript);
        Margin = new Padding(2);
        Name = "Form1";
        Text = "Form1";
        Load += Form1_Load;
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private TextBox textBoxScript;
    private Button button1;
    private TextBox textBoxMap;
    private Button button2;
    private TextBox textBox1;
}
