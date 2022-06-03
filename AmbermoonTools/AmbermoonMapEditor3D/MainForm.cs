using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

namespace AmbermoonMapEditor3D
{
    public partial class MainForm : Form
    {
        readonly GameData gameData;
        readonly MapManager mapManager;
        readonly List<Texture> wallTextures = new List<Texture>();
        readonly List<Texture> objectInfoTextures = new List<Texture>();
        readonly List<Texture> objectTextures = new List<Texture>();
        readonly Bitmap floorTexture;
        readonly Dictionary<uint, Graphic> palettes;
        static readonly GraphicReader graphicReader = new GraphicReader();
        static readonly GraphicInfo PaletteGraphicInfo = new GraphicInfo
        {
            Alpha = false,
            GraphicFormat = GraphicFormat.XRGB16,
            Width = 32,
            Height = 1
        };
        int lastTexturePanelHeight = 0;
        readonly Dictionary<int, System.Windows.Forms.Timer> animationTimers = new Dictionary<int, System.Windows.Forms.Timer>();

        class Texture : ITexturedObject
        {
            private Bitmap texture;
            private int currentFrame;

            public Texture(uint index, Bitmap texture, int width, int height, int numFrames = 1)
            {
                if (numFrames == 0)
                    numFrames = 1;

                Index = index;
                Width = width / numFrames;
                Height = height;
                currentFrame = 0;
                this.texture = texture;
                NumFrames = numFrames;
            }

            public uint Index { get; }

            public int Width { get; }

            public int Height { get; }

            public int CurrentFrame
            {
                get => currentFrame;
                set
                {
                    if (currentFrame != value)
                    {
                        currentFrame = value;
                        FrameChanged?.Invoke();
                    }
                }
            }

            public int NumFrames { get; set; }

            Bitmap ITexturedObject.Texture => texture;

            public event Action FrameChanged;
        }

        public MainForm()
        {
            var dialog = new FolderBrowserDialog();

            dialog.AutoUpgradeEnabled = true;
            dialog.Description = "Where is your Ambermoon data folder (i.e. Amberfiles)?";
            dialog.ShowNewFolderButton = false;
            dialog.UseDescriptionForTitle = true;

            if (dialog.ShowDialog(this) == DialogResult.OK)
            {
                gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false);
                gameData.Load(dialog.SelectedPath);

                bool CheckFile(string file, string name)
                {
                    if (!gameData.Files.ContainsKey(file))
                    {
                        MessageBox.Show($"No {name} ({file}) could be found at the given path.", $"Error loading {name}", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        Close();
                        return false;
                    }

                    return true;
                }

                if (!CheckFile("2Wall3D.amb", "walls") || !CheckFile("3Wall3D.amb", "walls"))
                    return;

                if (!CheckFile("2Overlay3D.amb", "walls") || !CheckFile("3Overlay3D.amb", "overlays"))
                    return;

                if (!CheckFile("2Object3D.amb", "walls") || !CheckFile("3Object3D.amb", "objects"))
                    return;

                if (!CheckFile("Floors.amb", "floors"))
                    return;

                if (!CheckFile("2Lab_data.amb", "lab data"))
                    return;

                if (!CheckFile("Palettes.amb", "palettes"))
                    return;

                palettes = gameData.Files["Palettes.amb"].Files.ToDictionary(f => (uint)f.Key, f => ReadPalette(f.Value));
            }
            else
            {
                Close();
                return;
            }

            Map map;
            var openMapForm = new OpenMapForm(gameData, mapManager);
            if (openMapForm.ShowDialog(this) == DialogResult.OK)
            {
                mapManager = openMapForm.MapManager;
                map = openMapForm.Map;
            }
            else
            {
                Close();
                return;
            }

            var labdata = mapManager.GetLabdataForMap(map);
            var palette = palettes[map.PaletteIndex];

            for (int i = 0; i < labdata.Walls.Count; ++i)
            {
                var graphic = labdata.WallGraphics[i];
                var texture = LoadImage(graphic, palette, labdata.Walls[i].Flags.HasFlag(Tileset.TileFlags.Transparency));
                wallTextures.Add(new Texture((uint)i, texture, 128, 80));
            }

            for (int i = 0; i < labdata.ObjectInfos.Count; ++i)
            {
                var graphic = labdata.ObjectGraphics[i];
                var texture = LoadImage(graphic, palette, labdata.ObjectInfos[i].Flags.HasFlag(Tileset.TileFlags.Transparency));
                var textureInfo = new Texture((uint)i, texture, graphic.Width, graphic.Height, (int)labdata.ObjectInfos[i].NumAnimationFrames);
                objectInfoTextures.Add(textureInfo);
                int index = i;

                if (textureInfo.NumFrames > 1)
                {
                    var timer = new System.Windows.Forms.Timer();
                    timer.Tag = true; // direction
                    timer.Interval = 200;
                    timer.Tick += (object sender, EventArgs _) =>
                    {
                        if (labdata.ObjectInfos[index].Flags.HasFlag(Tileset.TileFlags.AlternateAnimation))
                        {
                            var timer = sender as System.Windows.Forms.Timer;
                            bool forward = (bool)timer.Tag;

                            if (forward)
                            {
                                if (++textureInfo.CurrentFrame == textureInfo.NumFrames - 1)
                                {
                                    timer.Tag = false;
                                }
                            }
                            else
                            {
                                if (--textureInfo.CurrentFrame == 0)
                                {
                                    timer.Tag = true;
                                }
                            }
                        }
                        else
                        {
                            textureInfo.CurrentFrame = (textureInfo.CurrentFrame + 1) % textureInfo.NumFrames;
                        }
                    };
                    timer.Start();
                    animationTimers.Add(i, timer);
                }
            }

            foreach (var obj in labdata.Objects)
            {
                objectTextures.Add(objectInfoTextures[labdata.ObjectInfos.IndexOf(obj.SubObjects[0].Object)]);
            }

            panelTextures = new TexturePanel(wallTextures.Cast<ITexturedObject>().ToList(), objectTextures.Cast<ITexturedObject>().ToList());
            Controls.Add(panelTextures);

            InitializeComponent();
        }

        private void PanelTextures_SizeChanged(object sender, EventArgs e)
        {
            int sizeDiff = panelTextures.Height - lastTexturePanelHeight;
            Height += sizeDiff;
            panelTextures.Dock = DockStyle.Bottom;
        }

        Bitmap LoadImage(Graphic graphic, Graphic palette, bool transparency)
        {
            var bitmap = new Bitmap(graphic.Width, graphic.Height);
            var imageData = bitmap.LockBits(new Rectangle(0, 0, bitmap.Width, bitmap.Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            var pixelData = GetPixelData(graphic, palette, transparency);
            Marshal.Copy(pixelData, 0, imageData.Scan0, pixelData.Length);
            bitmap.UnlockBits(imageData);

            return bitmap;
        }

        byte[] GetPixelData(Graphic graphic, Graphic palette, bool transparency)
        {
            int w = graphic.Width;
            int h = graphic.Height;
            byte[] pixelData = new byte[w * h * 4];

            for (int y = 0; y < h; ++y)
            {
                for (int x = 0; x < w; ++x)
                {
                    int index = x + y * w;
                    int dIndex = index << 2;
                    index = graphic.Data[index] << 2;

                    if (transparency && index == 0)
                    {
                        pixelData[dIndex + 0] = 0;
                        pixelData[dIndex + 1] = 0;
                        pixelData[dIndex + 2] = 0;
                        pixelData[dIndex + 3] = 0;
                    }
                    else
                    {
                        pixelData[dIndex + 2] = palette.Data[index];
                        pixelData[dIndex + 1] = palette.Data[index + 1];
                        pixelData[dIndex + 0] = palette.Data[index + 2];
                        pixelData[dIndex + 3] = palette.Data[index + 3];
                    }
                }
            }

            return pixelData;
        }

        static Graphic ReadPalette(IDataReader dataReader)
        {
            var graphic = new Graphic();
            graphicReader.ReadGraphic(graphic, dataReader, PaletteGraphicInfo);
            return graphic;
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            panelTextures.Dock = DockStyle.Bottom;
            lastTexturePanelHeight = panelTextures.Height;
            panelTextures.SizeChanged += PanelTextures_SizeChanged;
        }
    }
}