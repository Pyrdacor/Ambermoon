using System;
using System.Drawing;
using System.Windows.Forms;
using AmbermoonEditor.Extensions;

namespace AmbermoonEditor.Controls;

file record Page(string Title, Control Control)
{
    public override string ToString() => Title;
}

public partial class MultiPageControl : UserControl
{
    private Point prevButtonLocation = Point.Empty;
    private Point nextButtonLocation = Point.Empty;
    private Point pageListLocation = Point.Empty;
    private Point contentPanelLocation = Point.Empty;

    public MultiPageControl()
    {
        InitializeComponent();
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        HidePageControls();
    }

    private void HidePageControls()
    {
        if (!buttonPrev.Visible)
            return;

        prevButtonLocation = buttonPrev.Location;
        nextButtonLocation = buttonNext.Location;
        pageListLocation = comboBoxPages.Location;
        contentPanelLocation = panelContent.Location;

        buttonPrev.Visible = false;
        buttonNext.Visible = false;
        comboBoxPages.Visible = false;
        panelContent.AdjustUpLeft(prevButtonLocation);
    }

    private void ShowPageControls()
    {
        if (buttonPrev.Visible)
            return;

        panelContent.AdjustUpLeft(contentPanelLocation);

        buttonPrev.Visible = true;
        buttonNext.Visible = true;
        comboBoxPages.Visible = true;

        buttonPrev.Location = prevButtonLocation;
        buttonNext.Location = nextButtonLocation;
        comboBoxPages.Location = pageListLocation;
    }

    public void AddPage(string title, Control control)
    {
        comboBoxPages.Items.Add(new Page(title, control));

        if (comboBoxPages.Items.Count == 1)
        {
            comboBoxPages.SelectedIndex = 0;
        }
        else if (comboBoxPages.Items.Count > 1)
        {
            ShowPageControls();
        }

        buttonPrev.Enabled = buttonNext.Enabled = comboBoxPages.Items.Count > 1;
    }

    private void ComboBoxPages_SelectedIndexChanged(object sender, System.EventArgs e)
    {
        if (comboBoxPages.SelectedItem is Page page)
        {
            panelContent.Controls.Clear();
            panelContent.Controls.Add(page.Control);
            page.Control.Dock = DockStyle.Fill;
        }
    }

    private void ButtonPrev_Click(object sender, System.EventArgs e)
    {
        if (comboBoxPages.SelectedIndex > 0)
        {
            comboBoxPages.SelectedIndex--;
        }
        else
        {
            comboBoxPages.SelectedIndex = comboBoxPages.Items.Count - 1;
        }
    }

    private void ButtonNext_Click(object sender, System.EventArgs e)
    {
        if (comboBoxPages.SelectedIndex < comboBoxPages.Items.Count - 1)
        {
            comboBoxPages.SelectedIndex++;
        }
        else
        {
            comboBoxPages.SelectedIndex = 0;
        }
    }
}
