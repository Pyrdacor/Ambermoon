using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using OpenTK.Graphics.OpenGL;
using OpenTK.Mathematics;
using System.Drawing;
using Color = System.Drawing.Color;

namespace Ambermoon3DMapEditor
{
    public partial class MainForm : Form
    {
        #region Constants
        private const float BlockSize = 1.0f;
        private const float PlayerSize = 0.6f * BlockSize;
        private const float RefWallHeight = 341.0f * BlockSize / 512.0f;
        private const float TurnSpeed = 0.1f;
        private readonly Color AutomapBackgroundColor = Color.FromArgb(0xAA, 0x77, 0x44);
        private readonly Color AutomapLineColor = Color.FromArgb(0x66, 0x33, 0x00);
        #endregion

        #region Inline Properties
        private Matrix4 PerspectiveMatrix => Matrix4.CreatePerspectiveFieldOfView(0.26f * MathHelper.Pi, 341.0f / (labdata?.WallHeight ?? 400), 0.1f, 40.0f * BlockSize);
        private float WallHeight => (labdata?.WallHeight ?? 400) * BlockSize / 512.0f;
        private float MoveSpeed => settings3D.SpeedBoost.CurrentValue ? 0.15f * BlockSize : 0.075f * BlockSize;
        private int TileSize2D => settings2D.ZoomLevel.CurrentValue * 16;
        private Direction CurrentDirection
        {
            get
            {
                const float segment = MathHelper.Pi / 8;

                return playerViewAngle switch
                {
                    >= segment and < 3 * segment => Direction.UpRight,
                    >= 3 * segment and < 5 * segment => Direction.Right,
                    >= 5 * segment and < 7 * segment => Direction.DownRight,
                    >= 7 * segment and < 9 * segment => Direction.Down,
                    >= 9 * segment and < 11 * segment => Direction.DownLeft,
                    >= 11 * segment and < 13 * segment => Direction.Left,
                    >= 13 * segment and < 15 * segment => Direction.UpLeft,
                    _ => Direction.Up
                };
            }
        }
        #endregion

        #region Settings
        private Settings settings => settingsControl1.Settings;
        private Settings._Settings3DView settings3D => settings.Settings3DView;
        private Settings._Settings2DView settings2D => settings.Settings2DView;
        private Settings._SettingsMisc settingsMisc => settings.SettingsMisc;
        #endregion

        #region 3D Player / Camera
        private Matrix4 modelViewMatrix = Matrix4.Identity;
        private float playerX = 0.0f;
        private float playerY = 0.0f;
        private float playerViewAngle = 0.0f;
        #endregion

        #region Data, Map, Lab
        private readonly GameData gameData;
        private Labdata? labdata;
        private byte[] blocks = new byte[10 * 10];
        private uint paletteIndex = 1;
        private int mapWidth = 10;
        private int mapHeight = 10;
        private List<Texture>? wallTextures = null;
        private TextureAtlas? wallTextureAtlas = null;
        private TextureAtlas? transparentWallTextureAtlas = null;
        private TextureAtlas? floorTextureAtlas = null;
        private TextureAtlas? ceilingTextureAtlas = null;
        private List<Texture>? objectTextures = null;
        private TextureAtlas? objectTextureAtlas = null;
        private readonly Dictionary<uint, Palette> palettes = new();
        private readonly Bitmap[][] automapGraphics;
        private Bitmap[] wallGraphics = Array.Empty<Bitmap>();
        private Bitmap[] transparentWallGraphics = Array.Empty<Bitmap>();
        private Bitmap[][] objectGraphics = Array.Empty<Bitmap[]>();
        #endregion

        #region State
        private readonly bool[] pressedKeys = Enumerable.Repeat(false, 256).ToArray();
        private bool initialized = false;
        private int animationFrame = 0;
        #endregion

        #region UI
        private Bitmap mapView2D = new(1, 1);
        #endregion

        public MainForm()
        {
            const string dataPath = @"C:\Users\flavia\Desktop\ambermoon_german_1.19_extracted\Amberfiles";
            gameData = new GameData();
            gameData.Load(dataPath);

            foreach (var paletteGraphic in gameData.GraphicProvider.Palettes)
            {
                palettes.Add((uint)paletteGraphic.Key, PaletteLoader.LoadPalette(paletteGraphic.Value));
            }

            var automapPalette = gameData.GraphicProvider.Palettes[gameData.GraphicProvider.AutomapPaletteIndex];
            automapGraphics = gameData.GraphicProvider.GetGraphics(GraphicType.AutomapGraphics).Select(g =>
                GraphicHelper.GraphicToBitmaps(g, automapPalette, 16, true)).ToArray();

            InitializeComponent();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            view2D.BackColor = AutomapBackgroundColor;
            view3D.MakeCurrent();
            GL.AlphaFunc(AlphaFunction.Greater, 0.0f);
            GL.Enable(EnableCap.DepthTest);
            GL.Enable(EnableCap.Texture2D);
            GL.Enable(EnableCap.CullFace);
            GL.CullFace(CullFaceMode.Front);

            LoadMap(259);

            initialized = true;
            initTimer.Start();

            void Changed2D()
            {
                Draw2DViewToImage();
                Redraw2DView();
            }

            void Changed3D()
            {
                view3D.Refresh();
            }

            settings2D.ShowAsAutomap.Changed += _ => Changed2D();
            settings2D.ZoomLevel.Changed += _ => Changed2D();
            settings2D.ShowBlockingModes.Changed += _ => Changed2D();
            settings2D.ShowBlockingModes.Changed += _ => { if (settings2D.ShowBlockingModes.CurrentValue) Changed2D(); };
            settings2D.ShowPlayer.Changed += _ => Changed2D();

            settings3D.ShowFloor.Changed += _ => Changed3D();
            settings3D.ShowCeiling.Changed += _ => Changed3D();
            settings3D.ShowFloorTexture.Changed += _ => Changed3D();
            settings3D.ShowCeilingTexture.Changed += _ => Changed3D();
            settings3D.ShowWalls.Changed += _ => Changed3D();
            settings3D.ShowObjects.Changed += _ => Changed3D();
            settings3D.ShowWallTextures.Changed += _ => Changed3D();
            settings3D.ShowObjectTextures.Changed += _ => Changed3D();
        }

        private void initTimer_Tick(object sender, EventArgs e)
        {
            view3D_Resize(this, EventArgs.Empty);
            initTimer.Stop();
        }

        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            wallTextureAtlas?.Dispose();
            transparentWallTextureAtlas?.Dispose();
            floorTextureAtlas?.Dispose();
            ceilingTextureAtlas?.Dispose();
            objectTextureAtlas?.Dispose();
        }

        private void LoadMap(uint index)
        {
            var map = gameData.MapManager.GetMap(index);
            labdata = gameData.MapManager.GetLabdataForMap(map);
            paletteIndex = map.PaletteIndex;
            InitLabdata(labdata, map.PaletteIndex);
            mapWidth = map.Width;
            mapHeight = map.Height;
            blocks = new byte[mapWidth * mapHeight];
            bool playerPlaced = false;
            int i = 0;
            for (int y = 0; y < mapHeight; y++)
            {
                for (int x = 0; x < mapWidth; x++)
                {
                    var b = map.Blocks[x, y];
                    var objOrWall = blocks[i++] = (byte)(b.MapBorder ? 255 : b.WallIndex == 0 ? b.ObjectIndex : 100 + b.WallIndex);

                    if (!playerPlaced && objOrWall == 0)
                    {
                        bool dirSet = false;
                        playerX = x + 0.5f * BlockSize;
                        playerY = y + 0.5f * BlockSize;

                        byte right = x < mapWidth - 1 ? blocks[i] : (byte)255;

                        if (right == 0)
                        {
                            playerViewAngle = MathHelper.PiOver2;
                            dirSet = true;
                        }

                        if (!dirSet)
                        {
                            byte left = x > 0 ? blocks[i - 2] : (byte)255;

                            if (left == 0)
                            {
                                playerViewAngle = MathHelper.ThreePiOver2;
                                dirSet = true;
                            }
                        }

                        if (!dirSet)
                        {
                            byte down = y < mapHeight - 1 ? blocks[i + mapWidth - 1] : (byte)255;

                            if (down == 0)
                            {
                                playerViewAngle = MathHelper.Pi;
                                dirSet = true;
                            }
                        }

                        if (!dirSet)
                        {
                            byte up = y > 0 ? blocks[i - mapWidth - 1] : (byte)255;

                            if (up == 0)
                            {
                                playerViewAngle = 0;
                            }
                        }

                        playerPlaced = true;
                    }
                }
            }

            Draw2DViewToImage();
            Redraw2DView();
        }

        private void InitLabdata(Labdata labdata, uint paletteIndex)
        {
            wallTextureAtlas?.Dispose();
            transparentWallTextureAtlas?.Dispose();
            floorTextureAtlas?.Dispose();
            ceilingTextureAtlas?.Dispose();
            objectTextureAtlas?.Dispose();

            wallTextures = TextureLoader.Load(labdata.WallGraphics, out var paletteTextureAtlas);
            wallTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex], false);
            transparentWallTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex], true);
            TextureLoader.Load((new[] { labdata.FloorGraphic }).ToList(), out paletteTextureAtlas);
            floorTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex], false);
            TextureLoader.Load((new[] { labdata.CeilingGraphic }).ToList(), out paletteTextureAtlas);
            ceilingTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex], false);
            objectTextures = TextureLoader.Load(labdata.ObjectGraphics, out paletteTextureAtlas);
            objectTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex], true);

            var palette = gameData.GraphicProvider.Palettes[(int)paletteIndex];
            wallGraphics = labdata.WallGraphics.Select(g => GraphicHelper.GraphicToBitmap(g, palette, false)).ToArray();
            transparentWallGraphics = labdata.WallGraphics.Select(g => GraphicHelper.GraphicToBitmap(g, palette, true)).ToArray();
            objectGraphics = labdata.ObjectGraphics.Select((g, i) => GraphicHelper.GraphicToBitmaps(g, palette, g.Width / (int)labdata.ObjectInfos[i].NumAnimationFrames, true)).ToArray();

            GL.MatrixMode(MatrixMode.Projection);
            var perspective = PerspectiveMatrix;
            GL.LoadMatrix(ref perspective);
        }

        private int GetAutomapGraphicFrames(AutomapType automapType) => automapType switch
        {
            < AutomapType.Riddlemouth => 0,
            < AutomapType.Door => 4,
            AutomapType.GotoPoint => 8,
            AutomapType.Invalid => 0,
            _ => 1
        };

        private void DrawFloor(Color4 color)
        {
            if (settings3D.ShowFloorTexture.CurrentValue)
            {
                GL.Color4(Color4.White);
                floorTextureAtlas?.Bind();
            }
            else
            {
                GL.Color4(color);
                GL.BindTexture(TextureTarget.Texture2D, 0);
            }

            GL.Begin(PrimitiveType.Quads);
            GL.TexCoord2(0.0f, 0.0f);
            GL.Vertex3(0.0f, 0.0f, 0.0f);
            GL.TexCoord2(mapWidth, 0.0f);
            GL.Vertex3(mapWidth * BlockSize, 0.0f, 0.0f);
            GL.TexCoord2(mapWidth, mapHeight);
            GL.Vertex3(mapWidth * BlockSize, 0.0f, mapHeight * BlockSize);
            GL.TexCoord2(0.0f, mapHeight);
            GL.Vertex3(0.0f, 0.0f, mapHeight * BlockSize);
            GL.End();
        }

        private void DrawCeiling(Color4 color)
        {
            if (settings3D.ShowCeilingTexture.CurrentValue)
            {
                GL.Color4(Color4.White);
                ceilingTextureAtlas?.Bind();
            }
            else
            {
                GL.Color4(color);
                GL.BindTexture(TextureTarget.Texture2D, 0);
            }

            GL.Begin(PrimitiveType.Quads);
            GL.TexCoord2(0.0f, 0.0f);
            GL.Vertex3(mapWidth * BlockSize, WallHeight, 0.0f);
            GL.TexCoord2(mapWidth, 0.0f);
            GL.Vertex3(0.0f, WallHeight, 0.0f);
            GL.TexCoord2(mapWidth, mapHeight);
            GL.Vertex3(0.0f, WallHeight, mapHeight * BlockSize);
            GL.TexCoord2(0.0f, mapHeight);
            GL.Vertex3(mapWidth * BlockSize, WallHeight, mapHeight * BlockSize);
            GL.End();
        }

        private void DrawWall(int x, int y, Color4 color, Texture texture, bool transparency,
            bool renderUpFace, bool renderRightFace, bool renderDownFace, bool renderLeftFace)
        {
            if (!settings3D.ShowWallTextures.CurrentValue)
            {
                GL.Color4(color);
                GL.BindTexture(TextureTarget.Texture2D, 0);
            }
            else
            {
                GL.Color4(Color4.White);
                if (transparency)
                    transparentWallTextureAtlas?.Bind();
                else
                    wallTextureAtlas?.Bind();
            }

            float left = x * BlockSize;
            float right = left + BlockSize;
            float far = y * BlockSize;
            float near = far + BlockSize;
            float top = WallHeight;
            float bottom = 0.0f;
            float atlasWidth = wallTextureAtlas?.Width ?? 1.0f;
            float atlasHeight = wallTextureAtlas?.Height ?? 1.0f;

            void UpperLeftUv() => GL.TexCoord2(texture.AtlasX / atlasWidth, texture.AtlasY / atlasHeight);
            void UpperRightUv() => GL.TexCoord2((texture.AtlasX + texture.Width) / atlasWidth, texture.AtlasY / atlasHeight);
            void LowerRightUv() => GL.TexCoord2((texture.AtlasX + texture.Width) / atlasWidth, (texture.AtlasY + texture.Height) / atlasHeight);
            void LowerLeftUv() => GL.TexCoord2(texture.AtlasX / atlasWidth, (texture.AtlasY + texture.Height) / atlasHeight);

            GL.Begin(PrimitiveType.Quads);

            // Front
            if (renderDownFace)
            {
                UpperLeftUv();
                GL.Vertex3(left, top, near);
                UpperRightUv();
                GL.Vertex3(right, top, near);
                LowerRightUv();
                GL.Vertex3(right, bottom, near);
                LowerLeftUv();
                GL.Vertex3(left, bottom, near);
            }

            // Left
            if (renderLeftFace)
            {
                UpperLeftUv();
                GL.Vertex3(left, top, far);
                UpperRightUv();
                GL.Vertex3(left, top, near);
                LowerRightUv();
                GL.Vertex3(left, bottom, near);
                LowerLeftUv();
                GL.Vertex3(left, bottom, far);
            }

            // Back
            if (renderUpFace)
            {
                UpperLeftUv();
                GL.Vertex3(right, top, far);
                UpperRightUv();
                GL.Vertex3(left, top, far);
                LowerRightUv();
                GL.Vertex3(left, bottom, far);
                LowerLeftUv();
                GL.Vertex3(right, bottom, far);
            }

            // Right
            if (renderRightFace)
            {
                UpperLeftUv();
                GL.Vertex3(right, top, near);
                UpperRightUv();
                GL.Vertex3(right, top, far);
                LowerRightUv();
                GL.Vertex3(right, bottom, far);
                LowerLeftUv();
                GL.Vertex3(right, bottom, near);
            }

            GL.End();
        }

        private void DrawSubObject(int x, int y, Labdata.ObjectPosition obj)
        {
            bool floor = obj.Object.Flags.HasFlag(Tileset.TileFlags.Floor);
            float topY;

            if (floor)
            {
                topY = Math.Max(1, Math.Min(340, (int)obj.Z)) * labdata!.WallHeight * BlockSize / (341.0f * 512.0f);
            }
            else
            {
                topY = obj.Z + obj.Object.TextureHeight;
                if (topY + 0.00001f < 341.0f)
                    topY = obj.Z + obj.Object.MappedTextureHeight;
                topY *= labdata!.WallHeight * BlockSize / (341.0f * 512.0f);
            }
            Vector4 position = new((x + obj.X / 512.0f) * BlockSize, topY, (y + obj.Y / 512.0f) * BlockSize, 1.0f);
            var mappedPosition = position * modelViewMatrix;

            int index = labdata!.ObjectInfos.IndexOf(obj.Object);
            var texture = objectTextures![index];
            float textureWidth = obj.Object.TextureWidth;
            float textureHeight = obj.Object.TextureHeight;
            float atlasWidth = objectTextureAtlas!.Width;
            float atlasHeight = objectTextureAtlas!.Height;

            void UpperLeftUv() => GL.TexCoord2(texture.AtlasX / atlasWidth, texture.AtlasY / atlasHeight);
            void UpperRightUv() => GL.TexCoord2((texture.AtlasX + textureWidth) / atlasWidth, texture.AtlasY / atlasHeight);
            void LowerRightUv() => GL.TexCoord2((texture.AtlasX + textureWidth) / atlasWidth, (texture.AtlasY + textureHeight) / atlasHeight);
            void LowerLeftUv() => GL.TexCoord2(texture.AtlasX / atlasWidth, (texture.AtlasY + textureHeight) / atlasHeight);

            GL.Begin(PrimitiveType.Quads);

            if (floor)
            {
                if (obj.Z > 255.0f)
                {
                    float left = mappedPosition.X - 0.5f * obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                    float right = left + obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                    float h = mappedPosition.Y;
                    float near = mappedPosition.Z + 0.5f * obj.Object.MappedTextureHeight / 512.0f;
                    float far = near - obj.Object.MappedTextureHeight / 512.0f;

                    // Bottom
                    UpperLeftUv();
                    GL.Vertex3(left, h, near);
                    UpperRightUv();
                    GL.Vertex3(right, h, near);
                    LowerRightUv();
                    GL.Vertex3(right, h, far);
                    LowerLeftUv();
                    GL.Vertex3(left, h, far);
                }
                else
                {
                    float left = mappedPosition.X - 0.5f * obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                    float right = left + obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                    float h = mappedPosition.Y;
                    float near = mappedPosition.Z + 0.5f * obj.Object.MappedTextureHeight / 512.0f;
                    float far = near - obj.Object.MappedTextureHeight / 512.0f;

                    // Top
                    UpperLeftUv();
                    GL.Vertex3(left, h, far);
                    UpperRightUv();
                    GL.Vertex3(right, h, far);
                    LowerRightUv();
                    GL.Vertex3(right, h, near);
                    LowerLeftUv();
                    GL.Vertex3(left, h, near);
                }
            }
            else
            {
                float left = mappedPosition.X - 0.5f * obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                float right = left + obj.Object.MappedTextureWidth * BlockSize / 512.0f;
                float top = mappedPosition.Y;
                float bottom = top - obj.Object.MappedTextureHeight / 512.0f;
                float z = mappedPosition.Z;

                // Front
                UpperLeftUv();
                GL.Vertex3(left, top, z);
                UpperRightUv();
                GL.Vertex3(right, top, z);
                LowerRightUv();
                GL.Vertex3(right, bottom, z);
                LowerLeftUv();
                GL.Vertex3(left, bottom, z);
            }

            GL.End();
        }

        private void DrawObject(int x, int y, Color4 color, Labdata.Object obj)
        {
            if (!settings3D.ShowObjectTextures.CurrentValue)
            {
                GL.Color4(color);
                GL.BindTexture(TextureTarget.Texture2D, 0);
            }
            else
            {
                GL.Color4(Color4.White);
                objectTextureAtlas?.Bind();
            }

            foreach (var subObject in obj.SubObjects)
                DrawSubObject(x, y, subObject);
        }

        private void DrawWallsAndObjects(List<Labdata.WallData> walls, List<Labdata.Object> objects, Palette palette)
        {
            var transparentWallDrawCalls = new List<Action>();
            var objectDrawCalls = new List<Action>();

            for (int y = 0; y < mapHeight; y++)
            {
                for (int x = 0; x < mapWidth; x++)
                {
                    int blockIndex = x + y * mapWidth;
                    byte index = blocks[blockIndex];

                    if (index == 0 || index == 255)
                        continue;

                    if (index <= 100)
                    {
                        if (settings3D.ShowObjects.CurrentValue)
                        {
                            var obj = objects[index - 1];
                            if (obj.SubObjects.Count > 0)
                            {
                                int ox = x;
                                int oy = y;
                                objectDrawCalls.Add(() => DrawObject(ox, oy, palette[obj.SubObjects[0].Object.ColorIndex], obj));
                            }
                        }
                    }
                    else
                    {
                        if (settings3D.ShowWalls.CurrentValue)
                        {
                            bool IsObjectOrNonBlocking(int blockIndex)
                            {
                                if (blocks[blockIndex] <= 100)
                                    return true;

                                if (blocks[blockIndex] == 255)
                                    return false;

                                var wallFlags = walls[blocks[blockIndex] - 101].Flags;

                                return wallFlags.HasFlag(Tileset.TileFlags.Transparency) || ((uint)wallFlags & 0x180) == 0x100;
                            }

                            bool renderUpFace = y > 0 && IsObjectOrNonBlocking(blockIndex - mapWidth);
                            bool renderRightFace = x < mapWidth - 1 && IsObjectOrNonBlocking(blockIndex + 1);
                            bool renderDownFace = y < mapHeight - 1 && IsObjectOrNonBlocking(blockIndex + mapWidth);
                            bool renderLeftFace = x > 0 && IsObjectOrNonBlocking(blockIndex - 1);
                            var wall = walls[index - 101];
                            if (!wall.Flags.HasFlag(Tileset.TileFlags.Transparency))
                            {
                                DrawWall(x, y, palette[wall.ColorIndex], wallTextures![index - 101], false,
                                    renderUpFace, renderRightFace, renderDownFace, renderLeftFace);
                            }
                            else
                            {
                                int wx = x;
                                int wy = y;
                                transparentWallDrawCalls.Add(() => DrawWall(wx, wy, palette[wall.ColorIndex], wallTextures![index - 101], true,
                                    renderUpFace, renderRightFace, renderDownFace, renderLeftFace));
                            }
                        }
                    }
                }
            }

            if (transparentWallDrawCalls.Count != 0)
            {
                GL.Enable(EnableCap.AlphaTest);
                transparentWallDrawCalls.ForEach(drawCall => drawCall());
                GL.Disable(EnableCap.AlphaTest);
            }

            if (objectDrawCalls.Count != 0)
            {
                GL.Enable(EnableCap.AlphaTest);
                GL.MatrixMode(MatrixMode.Modelview);
                GL.PushMatrix();
                GL.LoadIdentity();
                objectDrawCalls.ForEach(drawCall => drawCall());
                GL.PopMatrix();
                GL.MatrixMode(MatrixMode.Projection);
                GL.Disable(EnableCap.AlphaTest);
            }
        }

        private void view3D_Paint(object sender, PaintEventArgs e)
        {
            view3D.MakeCurrent();
            GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);

            GL.DepthMask(false);
            if (settings3D.ShowFloor.CurrentValue && floorTextureAtlas != null)
                DrawFloor(palettes[paletteIndex][labdata?.FloorColorIndex ?? 0]);
            if (settings3D.ShowCeiling.CurrentValue && ceilingTextureAtlas != null)
                DrawCeiling(palettes[paletteIndex][labdata?.CeilingColorIndex ?? 0]);
            GL.DepthMask(true);

            if (labdata != null)
                DrawWallsAndObjects(labdata.Walls, labdata.Objects, palettes[paletteIndex]);

            view3D.SwapBuffers();
        }

        private void view3D_Resize(object sender, EventArgs e)
        {
            view3D.MakeCurrent();

            GL.Viewport(0, 0, view3D.ClientSize.Width, view3D.ClientSize.Height);

            UpdateModelView();

            var perspective = PerspectiveMatrix;
            GL.LoadMatrix(ref perspective);
        }

        private void MainForm_KeyDown(object sender, KeyEventArgs e)
        {
            pressedKeys[e.KeyValue] = true;
        }

        private void MainForm_KeyUp(object sender, KeyEventArgs e)
        {
            pressedKeys[e.KeyValue] = false;
        }

        private void keyInputTimer_Tick(object sender, EventArgs e)
        {
            if (pressedKeys[(int)Keys.W])
            {
                if (pressedKeys[(int)Keys.Q] || pressedKeys[(int)Keys.A])
                {
                    TurnLeft();
                }
                else if (pressedKeys[(int)Keys.E] || pressedKeys[(int)Keys.D])
                {
                    TurnRight();
                }

                MoveForward();
            }
            else if (pressedKeys[(int)Keys.A])
            {
                MoveLeft();
            }
            else if (pressedKeys[(int)Keys.S])
            {
                if (pressedKeys[(int)Keys.Q] || pressedKeys[(int)Keys.A])
                {
                    TurnLeft();
                }
                else if (pressedKeys[(int)Keys.E] || pressedKeys[(int)Keys.D])
                {
                    TurnRight();
                }

                MoveBackward();
            }
            else if (pressedKeys[(int)Keys.D])
            {
                MoveRight();
            }
            else if (pressedKeys[(int)Keys.Q])
            {
                TurnLeft();
            }
            else if (pressedKeys[(int)Keys.E])
            {
                TurnRight();
            }
        }

        private void UpdateModelView()
        {
            view3D.MakeCurrent();
            GL.MatrixMode(MatrixMode.Modelview);
            modelViewMatrix = Matrix4.CreateTranslation(-playerX, -0.5f * RefWallHeight, -playerY);
            modelViewMatrix = Matrix4.Mult(modelViewMatrix, Matrix4.CreateRotationY(playerViewAngle));
            GL.LoadMatrix(ref modelViewMatrix);
            GL.MatrixMode(MatrixMode.Projection);
            const float segment = MathHelper.Pi / 8;
            string direction = playerViewAngle switch
            {
                >= segment and < 3 * segment => "UpRight",
                >= 3 * segment and < 5 * segment => "Right",
                >= 5 * segment and < 7 * segment => "DownRight",
                >= 7 * segment and < 9 * segment => "Down",
                >= 9 * segment and < 11 * segment => "DownLeft",
                >= 11 * segment and < 13 * segment => "Left",
                >= 13 * segment and < 15 * segment => "UpLeft",
                _ => "Up"
            };
            statusPosition.Text = $"X: {1 + playerX:0.0}, Y: {1 + playerY:0.0}, Dir: {direction}";
            Redraw2DView();
            view3D.Refresh();
        }

        private bool MoveTo(float x, float y, bool testBlocking = true)
        {
            float dx = x - playerX;
            float dy = y - playerY;
            float max = Math.Max(Math.Abs(dx), Math.Abs(dy));
            if (max != 0)
            {
                dx /= max;
                dy /= max;
            }
            bool allowX = true;
            bool allowY = true;

            if (x < 0.5f || x >= mapWidth - 0.5f) allowX = false;
            if (y < 0.5f || y >= mapHeight - 0.5f) allowY = false;

            if ((!settings3D.NoWallClip.CurrentValue || !settings3D.NoObjectClip.CurrentValue) && testBlocking)
            {
                int ix = (int)Math.Floor(x + dx * PlayerSize);
                int iy = (int)Math.Floor(y + dy * PlayerSize);
                int px = (int)Math.Floor(playerX);
                int py = (int)Math.Floor(playerY);
                int indexOnlyX = blocks[ix + py * mapWidth];
                int indexOnlyY = blocks[px + iy * mapWidth];
                float xMod = dx >= 0 ? (x + dx * PlayerSize) % BlockSize : BlockSize - (x + dx * PlayerSize) % BlockSize;
                float yMod = dy >= 0 ? (y + dy * PlayerSize) % BlockSize : BlockSize - (y + dy * PlayerSize) % BlockSize;

                if (allowX && allowY)
                {
                    allowX = TestBlock(indexOnlyX, xMod);
                    allowY = TestBlock(indexOnlyY, yMod);
                }
                else if (allowX)
                {
                    if (!TestBlock(indexOnlyX, xMod))
                        return false;
                }
                else if (allowY)
                {
                    if (!TestBlock(indexOnlyY, yMod))
                        return false;
                }

                bool TestBlock(int index, float distInsideBlock)
                {
                    if (index == 255)
                    {
                        return false;
                    }
                    if (index > 0 && labdata != null)
                    {
                        if (index <= 100)
                        {
                            if (settings3D.NoObjectClip.CurrentValue)
                                return true;

                            var obj = labdata.Objects[index - 1];
                            if (obj.SubObjects.Any(so => so.Object.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement) || !so.Object.Flags.HasFlag(Tileset.TileFlags.AllowMovementWalk)))
                            {
                                // We ease this a bit
                                float d = obj.SubObjects.Max(so => so.Object.MappedTextureWidth / 512.0f) * 0.45f;

                                if (2.0f * distInsideBlock > BlockSize - d)
                                    return false;
                            }
                        }
                        else
                        {
                            if (settings3D.NoWallClip.CurrentValue)
                                return true;

                            var wall = labdata.Walls[index - 101];
                            if (wall.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement) || !wall.Flags.HasFlag(Tileset.TileFlags.AllowMovementWalk))
                                return false;
                        }
                    }

                    return true;
                }
            }

            if (allowX)
                playerX = x;
            if (allowY)
                playerY = y;

            return allowX || allowY;
        }

        private void MoveForward()
        {
            var newX = playerX + (float)(Math.Sin(playerViewAngle) * MoveSpeed);
            var newY = playerY - (float)(Math.Cos(playerViewAngle) * MoveSpeed);
            if (MoveTo(newX, newY))
                UpdateModelView();
        }

        private void MoveBackward()
        {
            var newX = playerX - (float)(Math.Sin(playerViewAngle) * MoveSpeed);
            var newY = playerY + (float)(Math.Cos(playerViewAngle) * MoveSpeed);
            if (MoveTo(newX, newY))
                UpdateModelView();
        }

        private void MoveLeft()
        {
            var newX = playerX - (float)(Math.Cos(playerViewAngle) * MoveSpeed);
            var newY = playerY - (float)(Math.Sin(playerViewAngle) * MoveSpeed);
            if (MoveTo(newX, newY))
                UpdateModelView();
        }

        private void MoveRight()
        {
            var newX = playerX + (float)(Math.Cos(playerViewAngle) * MoveSpeed);
            var newY = playerY + (float)(Math.Sin(playerViewAngle) * MoveSpeed);
            if (MoveTo(newX, newY))
                UpdateModelView();
        }

        private void TurnLeft()
        {
            playerViewAngle -= TurnSpeed;
            if (playerViewAngle < 0.0f)
                playerViewAngle += MathHelper.TwoPi;
            UpdateModelView();
        }

        private void TurnRight()
        {
            playerViewAngle += TurnSpeed;
            if (playerViewAngle >= MathHelper.TwoPi)
                playerViewAngle -= MathHelper.TwoPi;
            UpdateModelView();
        }

        private void Draw2DViewToImage()
        {
            if (labdata == null)
                return;

            mapView2D = new Bitmap(mapWidth * TileSize2D, mapHeight * TileSize2D);
            using var graphics = Graphics.FromImage(mapView2D);
            var palette = palettes[paletteIndex];

            graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
            graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None;
            graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.Half;

            void DrawBlock(int x, int y, Color fill, Color? border, string? text = null)
            {
                var area = new Rectangle(x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);
                using var fillBrush = new SolidBrush(fill);
                graphics.FillRectangle(fillBrush, area);
                if (border != null)
                {
                    using var borderPen = new Pen(border.Value, 2.0f);
                    graphics.DrawRectangle(borderPen, area);
                }
                if (text != null)
                {
                    using var textBrush = new SolidBrush(border ?? Color.Black);
                    graphics.DrawString(text, view2D.Font, textBrush, new Rectangle(new Point(area.X + 2, area.Y - 2), area.Size));
                }
            }

            void DrawBlockingMode(int x, int y, ushort blockedTravelTypes)
            {
                int bit = 1 << settings2D.ShowBlockingModesClass.CurrentValue;
                var area = new Rectangle(x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);

                if ((blockedTravelTypes & bit) != 0)
                {
                    int lineSize = 4;
                    using var borderPen = new Pen(Color.Red, lineSize);
                    graphics.DrawRectangle(borderPen, area);
                    graphics.DrawLine(borderPen, new Point(area.X, area.Y), new Point(area.Right - lineSize, area.Bottom - lineSize));
                    graphics.DrawLine(borderPen, new Point(area.Right - lineSize, area.Y), new Point(area.X, area.Bottom - lineSize));
                }
            }

            for (int y = 0; y < mapHeight; y++)
            {
                for (int x = 0; x < mapWidth; x++)
                {
                    int blockIndex = x + y * mapWidth;
                    byte index = blocks[blockIndex];

                    if (index == 0 || index == 255)
                    {
                        DrawBlock(x, y, AutomapBackgroundColor, index == 0 ? null : AutomapLineColor, index == 0 ? null : "X");

                        if (settings2D.ShowBlockingModes.CurrentValue && index == 255)
                            DrawBlockingMode(x, y, 0xffff);

                        continue;
                    }

                    if (index <= 100)
                    {
                        var obj = labdata.Objects[index - 1];
                        if (settings2D.ShowAsAutomap.CurrentValue)
                        {
                            int numFrames = GetAutomapGraphicFrames(obj.AutomapType);
                            if (numFrames == 0)
                            {
                                DrawBlock(x, y, AutomapBackgroundColor, Color.ForestGreen);
                            }
                            else
                            {
                                int frame = numFrames == 1 ? 0 : animationFrame % numFrames;
                                var frameImage = automapGraphics[26 + (int)obj.AutomapType][frame];
                                graphics.DrawImage(frameImage, x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);
                            }
                        }
                        else
                        {
                            // TODO
                            // Show mini versions of the objects
                            int numFrames = (int)obj.SubObjects[0].Object.NumAnimationFrames;
                            int frame = numFrames <= 1 ? 0 : animationFrame % numFrames;
                            int objIndex = labdata.ObjectInfos.IndexOf(obj.SubObjects[0].Object);
                            graphics.DrawImage(objectGraphics[objIndex][frame], x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);
                        }

                        if (settings2D.ShowBlockingModes.CurrentValue)
                        {
                            if (obj.SubObjects.Any(so => so.Object.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement)))
                                DrawBlockingMode(x, y, 0xffff);
                            else
                            {
                                ushort allowedTravelTypes = obj.SubObjects.Select(so => (ushort)(((int)so.Object.Flags >> 8) & 0x7fff)).Aggregate((a, b) => (ushort)(a & b));
                                DrawBlockingMode(x, y, (ushort)~allowedTravelTypes);
                            }
                        }
                    }
                    else
                    {
                        var wall = labdata.Walls[index - 101];

                        if (settings2D.ShowAsAutomap.CurrentValue)
                        {
                            // TODO
                            DrawBlock(x, y, AutomapBackgroundColor, AutomapLineColor);
                        }
                        else
                        {
                            bool transparent = wall.Flags.HasFlag(Tileset.TileFlags.Transparency);
                            if (transparent)
                                graphics.DrawImage(transparentWallGraphics[index - 101], x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);
                            else
                                graphics.DrawImage(wallGraphics[index - 101], x * TileSize2D, y * TileSize2D, TileSize2D, TileSize2D);
                        }

                        if (settings2D.ShowBlockingModes.CurrentValue)
                        {
                            if (wall.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement))
                                DrawBlockingMode(x, y, 0xffff);
                            else
                                DrawBlockingMode(x, y, (ushort)~(((int)wall.Flags >> 8) & 0x7fff));
                        }


                        // TODO
                        /*if (showWalls)
                        {
                            bool IsObjectOrNonBlocking(int blockIndex)
                            {
                                if (blocks[blockIndex] <= 100)
                                    return true;

                                if (blocks[blockIndex] == 255)
                                    return false;

                                var wallFlags = walls[blocks[blockIndex] - 101].Flags;

                                return wallFlags.HasFlag(Tileset.TileFlags.Transparency) || ((uint)wallFlags & 0x180) == 0x100;
                            }

                            bool renderUpFace = y > 0 && IsObjectOrNonBlocking(blockIndex - mapWidth);
                            bool renderRightFace = x < mapWidth - 1 && IsObjectOrNonBlocking(blockIndex + 1);
                            bool renderDownFace = y < mapHeight - 1 && IsObjectOrNonBlocking(blockIndex + mapWidth);
                            bool renderLeftFace = x > 0 && IsObjectOrNonBlocking(blockIndex - 1);
                            var wall = walls[index - 101];
                            if (!wall.Flags.HasFlag(Tileset.TileFlags.Transparency))
                            {
                                DrawWall(x, y, palette[wall.ColorIndex], wallTextures![index - 101], false,
                                    renderUpFace, renderRightFace, renderDownFace, renderLeftFace);
                            }
                            else
                            {
                                int wx = x;
                                int wy = y;
                                transparentWallDrawCalls.Add(() => DrawWall(wx, wy, palette[wall.ColorIndex], wallTextures![index - 101], true,
                                    renderUpFace, renderRightFace, renderDownFace, renderLeftFace));
                            }
                        }*/
                    }
                }
            }

            if (settings2D.ShowPlayer.CurrentValue)
            {
                // draw lower half
                graphics.DrawImage(automapGraphics[16][0], new Rectangle((int)Math.Floor(playerX) * TileSize2D, (int)Math.Floor(playerY) * TileSize2D, TileSize2D, TileSize2D));

                // draw upper half
                graphics.DrawImage(automapGraphics[18 + (int)CurrentDirection][0], new Rectangle((int)Math.Floor(playerX) * TileSize2D, (int)Math.Floor(playerY) * TileSize2D - TileSize2D, TileSize2D, TileSize2D));
            }
        }

        private void Redraw2DView()
        {
            view2D.AutoScrollMinSize = mapView2D.Size;
            view2D.Refresh();
        }

        private void view2D_Paint(object sender, PaintEventArgs e)
        {
            e.Graphics.DrawImage(mapView2D, view2D.AutoScrollPosition);
        }

        private void animationTimer_Tick(object sender, EventArgs e)
        {
            animationFrame = animationFrame == int.MaxValue ? 0 : animationFrame + 1;

            if (settings3D.ShowObjects.CurrentValue && settings3D.ShowObjectTextures.CurrentValue)
                view3D.Refresh();

            Draw2DViewToImage();
            Redraw2DView();
        }
    }
}