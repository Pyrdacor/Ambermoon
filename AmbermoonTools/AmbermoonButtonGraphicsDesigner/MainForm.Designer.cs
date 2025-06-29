namespace AmbermoonButtonGraphicsDesigner;

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
        labelDropTarget = new Label();
        SuspendLayout();
        // 
        // labelDropTarget
        // 
        labelDropTarget.AllowDrop = true;
        labelDropTarget.AutoSize = true;
        labelDropTarget.Font = new Font("Segoe UI", 9F, FontStyle.Bold);
        labelDropTarget.Location = new Point(306, 210);
        labelDropTarget.Name = "labelDropTarget";
        labelDropTarget.Size = new Size(203, 15);
        labelDropTarget.TabIndex = 0;
        labelDropTarget.Text = "Drop the file Button_graphics here.";
        labelDropTarget.TextAlign = ContentAlignment.MiddleCenter;
        labelDropTarget.DragDrop += MainForm_DragDrop;
        labelDropTarget.DragEnter += MainForm_DragEnter;
        // 
        // MainForm
        // 
        AllowDrop = true;
        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(800, 450);
        Controls.Add(labelDropTarget);
        Name = "MainForm";
        Text = "Button Graphics Designer";
        DragDrop += MainForm_DragDrop;
        DragEnter += MainForm_DragEnter;
        ResumeLayout(false);
        PerformLayout();
    }

    #endregion

    private Label labelDropTarget;
}
