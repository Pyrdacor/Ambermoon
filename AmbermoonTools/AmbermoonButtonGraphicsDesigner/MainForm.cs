using System.ComponentModel;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using AmbermoonBitmaps;

namespace AmbermoonButtonGraphicsDesigner;

public partial class MainForm : Form
{
    ComponentResourceManager resources = new(typeof(MainForm));
    PaletteColors paletteColors;
    List<Bitmap> images = [];

    public MainForm()
    {
        InitializeComponent();

        var paletteData = (byte[])resources.GetObject("palUI")!;
        paletteColors = new(new Graphic { Data = paletteData, Width = 32, Height = 1, IndexedGraphic = false });
    }

    private void MainForm_DragDrop(object sender, DragEventArgs e)
    {
        var files = (string[])e!.Data!.GetData(DataFormats.FileDrop)!;
        var data = File.ReadAllBytes(files[0]);
        var graphicInfo = new GraphicInfo
        {
            Width = 32,
            Height = 13,
            Alpha = true,
            GraphicFormat = GraphicFormat.Palette3Bit,
            PaletteOffset = 24
        };
        IDataReader dataReader = new DataReader(data);
        var graphicReader = new GraphicReader();
        dataReader = new FileReader().ReadFile("Button_graphics", dataReader).Files[1];

        while (dataReader.Position < dataReader.Size)
        {
            var graphic = new Graphic();
            graphicReader.ReadGraphic(graphic, dataReader, graphicInfo);
            images.Add(Converter.GraphicToBitmap(graphic, paletteColors, null));
        }

        var scrollContainer = new Panel();
        scrollContainer.AutoScroll = true;

        int availableButtonColumns = (this.ClientSize.Width - SystemInformation.VerticalScrollBarWidth) / 32;
        int availableButtonRows = (this.ClientSize.Height - SystemInformation.HorizontalScrollBarHeight) / 13;
        int availableButtonSpace = availableButtonColumns * availableButtonRows;
        scrollContainer.Height = this.ClientSize.Height - SystemInformation.HorizontalScrollBarHeight;

        if (images.Count <= availableButtonSpace)
        {
            scrollContainer.Width = this.ClientSize.Width - SystemInformation.VerticalScrollBarWidth;
        }
        else
        {
            int diff = images.Count - availableButtonSpace;
            int neededWidth = ((diff + availableButtonRows -1) / availableButtonRows) * 32;

            scrollContainer.Width = this.ClientSize.Width + neededWidth - SystemInformation.VerticalScrollBarWidth;
        }

        scrollContainer.Paint += ScrollContainer_Paint;

        this.Controls.Remove(labelDropTarget);
        this.Controls.Add(scrollContainer);

        scrollContainer.Visible = true;
        scrollContainer.Dock = DockStyle.Fill;

        Refresh();
    }

    private void ScrollContainer_Paint(object? sender, PaintEventArgs e)
    {
        var scrollContainer = sender as Panel;
        const int displayWidth = 32 * 4;
        const int displayHeight = 13 * 4;

        int columns = scrollContainer!.Width / displayWidth;
        int column = 0;
        int y = 0;

        for (int i = 0; i < images.Count; i++)
        {
            e.Graphics.DrawImage(images[i], column * displayWidth, y, displayWidth, displayHeight);

            if (++column >= columns)
            {
                column = 0;
                y += displayHeight;
            }
        }
    }

    private void MainForm_DragEnter(object sender, DragEventArgs e)
    {
        if (e?.Data?.GetDataPresent(DataFormats.FileDrop) ?? false)
        {
            // Check if the dragged data is a file
            string[] files = (string[])e!.Data!.GetData(DataFormats.FileDrop)!;

            if (files != null && files.Length == 1 && Path.GetFileName(files[0]).Equals("button_graphics", StringComparison.CurrentCultureIgnoreCase))
            {
                e.Effect = DragDropEffects.Copy;
            }
            else
            {
                e.Effect = DragDropEffects.None;
            }
        }
        else
        {
            e!.Effect = DragDropEffects.None;
        }
    }
}
