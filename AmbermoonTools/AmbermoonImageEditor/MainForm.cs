using System.Drawing.Drawing2D;
using System.Runtime.InteropServices;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using static System.Windows.Forms.DataFormats;

namespace AmbermoonImageEditor
{
    public partial class MainForm : Form
    {
        private bool cropping = false;
        private Point? cropFirstPoint = null;
        private Graphic? image = null;
        private GraphicFormat? format = null;
        private Graphic? palette = null;
        private Bitmap? bitmap = null;
        private int zoomFactor = 8;

        public MainForm()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var ofd = new OpenFileDialog
            {
                AddExtension = false,
                CheckFileExists = true,
                CheckPathExists = true,
                Filter = "All files (*.*)|*.*",
                FilterIndex = 0,
                Multiselect = false,
                Title = "Open Ambermoon image"
            };

            if (ofd.ShowDialog(this) == DialogResult.OK) 
            {
                var file = ofd.FileName;

                ofd.FileName = null;
                ofd.Title = "Open Ambermoon palette";

                if (ofd.ShowDialog(this) == DialogResult.OK)
                {
                    var sizeForm = new SizeForm();

                    if (sizeForm.ShowDialog() == DialogResult.OK)
                    {
                        int w = sizeForm.ImageWidth;
                        int h = sizeForm.ImageHeight;
                        var graphicInfo = new GraphicInfo
                        {
                            Width = w,
                            Height = h,
                            GraphicFormat = sizeForm.Format
                        };
                        var imageData = new DataReader(File.ReadAllBytes(file));

                        if (w == 0 || h == 0 || (w * h * graphicInfo.BitsPerPixel + 7) / 8 != imageData.Size)
                        {
                            MessageBox.Show("The given image size was invalid.");
                            return;
                        }

                        var graphicReader = new GraphicReader();
                        var paletteInfo = new GraphicInfo
                        {
                            Width = 32,
                            Height = 1,
                            GraphicFormat = GraphicFormat.XRGB16
                        };
                        format = graphicInfo.GraphicFormat;
                        image = new Graphic();
                        graphicReader.ReadGraphic(image, imageData, graphicInfo);
                        palette = new Graphic();
                        graphicReader.ReadGraphic(palette, new DataReader(File.ReadAllBytes(ofd.FileName)), paletteInfo);
                        saveToolStripMenuItem.Enabled = true;

                        UpdateImage();
                    }
                }
            }
        }

        private void UpdateImage()
        {
            var bitmap = new Bitmap(image!.Width, image.Height);
            var data = bitmap.LockBits(new Rectangle(Point.Empty, bitmap.Size), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb);

            var bytes = image.ToPixelData(palette);

            Marshal.Copy(bytes, 0, data.Scan0, bytes.Length);

            bitmap.UnlockBits(data);

            this.bitmap = bitmap;
            imagePanel.Size = new(bitmap.Width * zoomFactor, bitmap.Height * zoomFactor);
            panel1.Size = imagePanel.Size + new Size(20, 24);

            if (panel1.Width < 200)
                panel1.Width = 200;

            imagePanel.Refresh();
        }

        private void cropToolStripMenuItem_Click(object sender, EventArgs e)
        {
            cropping = !cropping;
            cropFirstPoint = null;
        }

        private void imagePanel_MouseMove(object sender, MouseEventArgs e)
        {
            if (cropping && cropFirstPoint is not null)
            {
                imagePanel.Refresh();
            }

            var pos = imagePanel.PointToClient(MousePosition);
            pos = SnapToPixelGrid(pos.X, pos.Y);

            bool showCoords = image is not null;

            if (showCoords)
            {
                toolStripStatusLabelX.Text = (pos.X / zoomFactor).ToString();
                toolStripStatusLabelY.Text = (pos.Y / zoomFactor).ToString();
            }

            toolStripStatusLabel1.Visible = showCoords;
            toolStripStatusLabelX.Visible = showCoords;
            toolStripStatusLabel2.Visible = showCoords;
            toolStripStatusLabelY.Visible = showCoords;

            bool showArea = image is not null && cropping && cropFirstPoint is not null;

            if (showArea)
            {
                var rect = SnapToPixelGrid(cropFirstPoint!.Value.X, cropFirstPoint.Value.Y, pos.X, pos.Y);
                toolStripStatusLabelWidth.Text = (rect.Width / zoomFactor).ToString();
                toolStripStatusLabelHeight.Text = (rect.Height / zoomFactor).ToString();
            }

            toolStripStatusLabel4.Visible = showArea;
            toolStripStatusLabelWidth.Visible = showArea;
            toolStripStatusLabel6.Visible = showArea;
            toolStripStatusLabelHeight.Visible = showArea;

            toolStripStatusLabel3.Visible = showCoords && showArea;
        }

        private void imagePanel_MouseDown(object sender, MouseEventArgs e)
        {
            if (cropping)
            {
                if (cropFirstPoint is null)
                {
                    if (e.Button == MouseButtons.Left)
                    {
                        cropFirstPoint = e.Location;
                        imagePanel.Refresh();
                    }
                }
                else
                {
                    if (e.Button == MouseButtons.Left)
                    {
                        var position = e.Location;

                        if (MessageBox.Show("Do you want to crop the image?", "Crop?", MessageBoxButtons.OKCancel) == DialogResult.OK)
                        {
                            var area = SnapToPixelGrid(cropFirstPoint.Value.X, cropFirstPoint.Value.Y, position.X, position.Y);
                            var imageArea = new Rectangle(area.X / zoomFactor, area.Y / zoomFactor, area.Width / zoomFactor, area.Height / zoomFactor);

                            if (imageArea.Width == 0 || imageArea.Height == 0)
                            {
                                MessageBox.Show("Area was empty. Aborting.");
                                cropping = false;
                                cropFirstPoint = null;
                                imagePanel.Refresh();
                                return;
                            }

                            var newImage = new Graphic
                            {
                                Width = imageArea.Width,
                                Height = imageArea.Height,
                                IndexedGraphic = true,
                                Data = new byte[imageArea.Width * imageArea.Height]
                            };

                            for (int y = 0; y < imageArea.Height; y++)
                            {
                                for (int x = 0; x < imageArea.Width; x++)
                                {
                                    newImage.Data[x + y * imageArea.Width] = image.Data[imageArea.X + x + (imageArea.Y + y) * image.Width];
                                }
                            }

                            image = newImage;
                            cropping = false;
                            cropFirstPoint = null;

                            UpdateImage();
                        }
                        else
                        {
                            cropping = false;
                            cropFirstPoint = null;
                            imagePanel.Refresh();
                        }
                    }
                    else if (e.Button == MouseButtons.Right)
                    {
                        cropFirstPoint = null;
                        imagePanel.Refresh();
                    }
                }
            }
        }

        private int SnapCoord(int coord)
        {
            if (zoomFactor > 1)
            {
                if (coord % zoomFactor < zoomFactor / 2)
                {
                    coord -= coord % zoomFactor;
                }
                else
                {
                    coord += zoomFactor - coord % zoomFactor;
                }
            }

            return coord;
        }

        private Point SnapToPixelGrid(int x, int y)
        {
            return new Point(SnapCoord(x), SnapCoord(y));
        }

        private Rectangle SnapToPixelGrid(int x1, int y1, int x2, int y2)
        {
            int minX = SnapCoord(Math.Min(x1, x2));
            int minY = SnapCoord(Math.Min(y1, y2));
            int maxX = SnapCoord(Math.Max(x1, x2)) + 1;
            int maxY = SnapCoord(Math.Max(y1, y2)) + 1;
     

            return Rectangle.FromLTRB(Math.Max(0, minX), Math.Max(0, minY), Math.Min(imagePanel.Width - 1, maxX), Math.Min(imagePanel.Height - 1, maxY));
        }

        private void imagePanel_Paint(object sender, PaintEventArgs e)
        {
            base.OnPaint(e);

            e.Graphics.InterpolationMode = InterpolationMode.NearestNeighbor;
            e.Graphics.PixelOffsetMode = PixelOffsetMode.Half;
            e.Graphics.Clear(Color.Black);

            if (bitmap is not null)
            {
                e.Graphics.DrawImage(bitmap, imagePanel.ClientRectangle, new Rectangle(0, 0, bitmap.Width, bitmap.Height), GraphicsUnit.Pixel);
            }

            if (cropping && cropFirstPoint is not null)
            {
                using var brush = new SolidBrush(Color.Red);
                var position = SnapToPixelGrid(cropFirstPoint.Value.X, cropFirstPoint.Value.Y);
                e.Graphics.FillEllipse(brush, Rectangle.FromLTRB(Math.Max(0, position.X - 2), Math.Max(0, position.Y - 2),
                    Math.Min(imagePanel.Width - 1, position.X + 2), Math.Min(imagePanel.Height - 1, position.Y + 2)));

                var pos = imagePanel.PointToClient(MousePosition);
                var rect = SnapToPixelGrid(cropFirstPoint.Value.X, cropFirstPoint.Value.Y, pos.X, pos.Y);

                using var pen = new Pen(brush, 1.0f);
                pen.DashStyle = DashStyle.Dash;

                e.Graphics.DrawRectangle(pen, rect);
            }
        }

        private void MainForm_MouseMove(object sender, MouseEventArgs e)
        {
            if (cropping && cropFirstPoint is not null)
            {
                imagePanel.Refresh();
            }

            toolStripStatusLabel1.Visible = false;
            toolStripStatusLabelX.Visible = false;
            toolStripStatusLabel2.Visible = false;
            toolStripStatusLabelY.Visible = false;
            toolStripStatusLabel3.Visible = false;

            bool showArea = image is not null && cropping && cropFirstPoint is not null;

            toolStripStatusLabel4.Visible = showArea;
            toolStripStatusLabelWidth.Visible = showArea;
            toolStripStatusLabel6.Visible = showArea;
            toolStripStatusLabelHeight.Visible = showArea;
        }

        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            var sfd = new SaveFileDialog
            {
                OverwritePrompt = true,
                Title = "Save image"
            };

            if (sfd.ShowDialog() == DialogResult.OK)
            {
                var imageToSave = image!;

                if (format!.Value == GraphicFormat.Texture4Bit && imageToSave.Width % 8 != 0)
                {
                    if (MessageBox.Show("Texture images must have a width which is a multiple of 8. If you proceed empty pixels will be added on the right.", "Texture issue", MessageBoxButtons.OKCancel) != DialogResult.OK)
                    {
                        return;
                    }
                }

                var writer = new DataWriter();
                GraphicWriter.Write(writer, image!, format!.Value);
                File.WriteAllBytes(sfd.FileName, writer.ToArray());
            }
        }
    }
}