using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using OpenTK.Graphics.OpenGL;
using OpenTK.Mathematics;

namespace Ambermoon3DMapEditor
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            const string dataPath = @"C:\Users\flavia\Desktop\ambermoon_german_1.19_extracted\Amberfiles";
            gameData = new GameData();
            gameData.Load(dataPath);

            foreach (var paletteGraphic in gameData.GraphicProvider.Palettes)
            {
                palettes.Add((uint)paletteGraphic.Key, PaletteLoader.LoadPalette(paletteGraphic.Value));
            }

            InitializeComponent();
        }

        GameData gameData;
        uint paletteIndex = 1;
        Labdata? labdata;
        byte[] Blocks = new byte[10 * 10];
        private const float BlockSize = 1.0f;
        private const float RefWallHeight = 2 * BlockSize / (2.0f * 3.0f);
        private float WallHeight => mapWallHeight * 2 * BlockSize / (2.0f * 3.0f * 341.0f);
        private int MapWidth = 10;
        private int MapHeight = 10;
        private bool[] PressedKeys = Enumerable.Repeat(false, 256).ToArray();
        private Matrix4 ModelViewMatrix = Matrix4.Identity;
        private float PlayerX = 0.0f;
        private float PlayerY = 0.0f;
        private float PlayerViewAngle = 0.0f;
        private float MoveSpeed => speedBoost ? 0.1f * BlockSize : 0.05f * BlockSize;
        private const float TurnSpeed = 0.1f;
        private bool speedBoost = false;
        private List<Texture>? wallTextures = null;
        private TextureAtlas? wallTextureAtlas = null;
        private TextureAtlas? floorTextureAtlas = null;
        private TextureAtlas? ceilingTextureAtlas = null;
        private List<Texture>? objectTextures = null;
        private TextureAtlas? objectTextureAtlas = null;
        private readonly Dictionary<uint, Palette> palettes = new();
        private Color4 floorColor = Color4.White;
        private Color4 ceilingColor = Color4.White;
        private uint mapWallHeight = 400;
        private bool showFloorTexture = true;
        private bool showCeilingTexture = true;
        private bool showFloor = true;
        private bool showCeiling = true;
        private bool showWalls = true;
        private bool showObjects = true;
        private bool showWallColors = false;
        private bool showObjectColors = false;
        private bool initialized = false;
        private int animationFrame = 0;

        private void DrawFloor(Color4 color)
        {
            if (showFloorTexture)
                floorTextureAtlas?.Bind();
            else
                GL.BindTexture(TextureTarget.Texture2D, 0);
            GL.Color4(color);

            GL.Begin(PrimitiveType.Quads);
            GL.TexCoord2(0.0f, 0.0f);
            GL.Vertex3(0.0f, 0.0f, -MapHeight * BlockSize);
            GL.TexCoord2(MapWidth, 0.0f);
            GL.Vertex3(MapWidth * BlockSize, 0.0f, -MapHeight * BlockSize);
            GL.TexCoord2(MapWidth, MapHeight);
            GL.Vertex3(MapWidth * BlockSize, 0.0f, 0.0f);
            GL.TexCoord2(0.0f, MapHeight);
            GL.Vertex3(0.0f, 0.0f, 0.0f);
            GL.End();
        }

        private void DrawCeiling(Color4 color)
        {
            if (showCeilingTexture)
                ceilingTextureAtlas?.Bind();
            else
                GL.BindTexture(TextureTarget.Texture2D, 0);
            GL.Color4(color);

            GL.Begin(PrimitiveType.Quads);
            GL.TexCoord2(0.0f, 0.0f);
            GL.Vertex3(0.0f, WallHeight, -MapHeight * BlockSize);
            GL.TexCoord2(MapWidth, 0.0f);
            GL.Vertex3(MapWidth * BlockSize, WallHeight, -MapHeight * BlockSize);
            GL.TexCoord2(MapWidth, MapHeight);
            GL.Vertex3(MapWidth * BlockSize, WallHeight, 0.0f);
            GL.TexCoord2(0.0f, MapHeight);
            GL.Vertex3(0.0f, WallHeight, 0.0f);
            GL.End();
        }

        private void DrawWall(int x, int y, Color4 color, Texture texture)
        {
            if (showWallColors)
            {
                GL.Color4(color);
                GL.BindTexture(TextureTarget.Texture2D, 0);
            }
            else
            {
                GL.Color4(Color4.White);
                wallTextureAtlas?.Bind();                
            }

            float left = x * BlockSize;
            float right = left + BlockSize;
            float far = -(MapHeight - y) * BlockSize;
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
            UpperLeftUv();
            GL.Vertex3(left, top, near);
            UpperRightUv();
            GL.Vertex3(right, top, near);
            LowerRightUv();
            GL.Vertex3(right, bottom, near);
            LowerLeftUv();
            GL.Vertex3(left, bottom, near);

            // Left
            UpperLeftUv();
            GL.Vertex3(left, top, far);
            UpperRightUv();
            GL.Vertex3(left, top, near);
            LowerRightUv();
            GL.Vertex3(left, bottom, near);
            LowerLeftUv();
            GL.Vertex3(left, bottom, far);

            // Back
            UpperLeftUv();
            GL.Vertex3(right, top, far);
            UpperRightUv();
            GL.Vertex3(left, top, far);
            LowerRightUv();
            GL.Vertex3(left, bottom, far);
            LowerLeftUv();
            GL.Vertex3(right, bottom, far);

            // Right
            UpperLeftUv();
            GL.Vertex3(right, top, near);
            UpperRightUv();
            GL.Vertex3(right, top, far);
            LowerRightUv();
            GL.Vertex3(right, bottom, far);
            LowerLeftUv();
            GL.Vertex3(right, bottom, near);

            GL.End();
        }

        private void DrawWallsAndObjects(List<Labdata.WallData> walls, List<Labdata.Object> objects, Palette palette)
        {
            var transparentDrawCalls = new List<Action>();

            for (int y = 0; y < MapHeight; y++)
            {
                for (int x = 0; x < MapWidth; x++)
                {
                    byte index = Blocks[x + (MapHeight - y - 1) * MapWidth];

                    if (index == 0 || index == 255)
                        continue;

                    if (index <= 100)
                    {
                        if (showObjects)
                        {
                            var obj = objects[index];
                            // TODO
                            //transparentDrawCalls.Add(() => DrawObject)
                        }
                    }
                    else
                    {
                        if (showWalls)
                        {
                            var wall = walls[index - 101];
                            if (!wall.Flags.HasFlag(Tileset.TileFlags.Transparency))
                                DrawWall(x, y, palette[wall.ColorIndex], wallTextures![index - 101]);
                            else
                                transparentDrawCalls.Add(() => DrawWall(x, y, palette[wall.ColorIndex], wallTextures![index - 101]));
                        }
                    }
                }
            }

            if (transparentDrawCalls.Count != 0)
            {
                GL.Enable(EnableCap.AlphaTest);
                transparentDrawCalls.ForEach(drawCall => drawCall());
                GL.Disable(EnableCap.AlphaTest);
            }
        }

        private void view3D_Paint(object sender, PaintEventArgs e)
        {
            view3D.MakeCurrent();
            GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);            

            if (showFloor && floorTextureAtlas != null)
                DrawFloor(floorColor);
            if (showCeiling && ceilingTextureAtlas != null)
                DrawCeiling(ceilingColor);

            if (labdata != null)
                DrawWallsAndObjects(labdata.Walls, labdata.Objects, palettes[paletteIndex]);    

            view3D.SwapBuffers();
        }

        private void view3D_Resize(object sender, EventArgs e)
        {
            view3D.MakeCurrent();

            GL.Viewport(0, 0, view3D.ClientSize.Width, view3D.ClientSize.Height);

            UpdateModelView();

            Matrix4 perpective = Matrix4.CreatePerspectiveFieldOfView(0.26f * MathHelper.Pi, 1.6f, 0.1f, 40.0f * BlockSize);

            GL.LoadMatrix(ref perpective);
        }

        private void MainForm_KeyDown(object sender, KeyEventArgs e)
        {
            PressedKeys[e.KeyValue] = true;
        }

        private void MainForm_KeyUp(object sender, KeyEventArgs e)
        {
            PressedKeys[e.KeyValue] = false;
        }

        private void keyInputTimer_Tick(object sender, EventArgs e)
        {
            if (PressedKeys[(int)Keys.W])
            {
                if (PressedKeys[(int)Keys.Q] || PressedKeys[(int)Keys.A])
                {
                    TurnLeft();
                }
                else if (PressedKeys[(int)Keys.E] || PressedKeys[(int)Keys.D])
                {
                    TurnRight();
                }

                MoveForward();
            }
            else if (PressedKeys[(int)Keys.A])
            {
                MoveLeft();
            }
            else if (PressedKeys[(int)Keys.S])
            {
                if (PressedKeys[(int)Keys.Q] || PressedKeys[(int)Keys.A])
                {
                    TurnLeft();
                }
                else if (PressedKeys[(int)Keys.E] || PressedKeys[(int)Keys.D])
                {
                    TurnRight();
                }

                MoveBackward();
            }
            else if (PressedKeys[(int)Keys.D])
            {
                MoveRight();
            }
            else if (PressedKeys[(int)Keys.Q])
            {
                TurnLeft();
            }
            else if (PressedKeys[(int)Keys.E])
            {
                TurnRight();
            }
        }

        private void UpdateModelView()
        {
            view3D.MakeCurrent();
            GL.MatrixMode(MatrixMode.Modelview);
            ModelViewMatrix = Matrix4.CreateTranslation(-PlayerX, -0.5f * RefWallHeight, MapHeight * BlockSize - PlayerY);
            ModelViewMatrix = Matrix4.Mult(ModelViewMatrix, Matrix4.CreateRotationY(PlayerViewAngle));
            GL.LoadMatrix(ref ModelViewMatrix);
            GL.MatrixMode(MatrixMode.Projection);
            const float segment = MathHelper.Pi / 8;
            string direction = PlayerViewAngle switch
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
            statusPosition.Text = $"X: {PlayerX:0.0}, Y: {PlayerY:0.0}, Dir: {direction}";
            Refresh();
        }

        private void MoveForward()
        {
            PlayerX += (float)(Math.Sin(PlayerViewAngle) * MoveSpeed);
            PlayerY -= (float)(Math.Cos(PlayerViewAngle) * MoveSpeed);
            UpdateModelView();
        }

        private void MoveBackward()
        {
            PlayerX -= (float)(Math.Sin(PlayerViewAngle) * MoveSpeed);
            PlayerY += (float)(Math.Cos(PlayerViewAngle) * MoveSpeed);
            UpdateModelView();
        }

        private void MoveLeft()
        {
            PlayerX -= (float)(Math.Cos(PlayerViewAngle) * MoveSpeed);
            PlayerY -= (float)(Math.Sin(PlayerViewAngle) * MoveSpeed);
            UpdateModelView();
        }

        private void MoveRight()
        {
            PlayerX += (float)(Math.Cos(PlayerViewAngle) * MoveSpeed);
            PlayerY += (float)(Math.Sin(PlayerViewAngle) * MoveSpeed);
            UpdateModelView();
        }

        private void TurnLeft()
        {
            PlayerViewAngle -= TurnSpeed;
            if (PlayerViewAngle < 0.0f)
                PlayerViewAngle += MathHelper.TwoPi;
            UpdateModelView();
        }

        private void TurnRight()
        {
            PlayerViewAngle += TurnSpeed;
            if (PlayerViewAngle >= MathHelper.TwoPi)
                PlayerViewAngle -= MathHelper.TwoPi;
            UpdateModelView();
        }

        private void MainForm_Load(object sender, EventArgs e)
        {
            view3D.MakeCurrent();
            GL.Enable(EnableCap.DepthTest);
            GL.Enable(EnableCap.Texture2D);
            PlayerX = 0.5f * MapWidth;
            PlayerY = 0.5f * MapHeight;
            statusPosition.Text = $"X: {PlayerX:0.0}, Y: {PlayerY:0.0}";

            LoadMap(259);

            initialized = true;
            initTimer.Start();
        }

        private void LoadMap(uint index)
        {
            var map = gameData.MapManager.GetMap(index);
            labdata = gameData.MapManager.GetLabdataForMap(map);
            paletteIndex = map.PaletteIndex;
            InitLabdata(labdata, map.PaletteIndex);
            MapWidth = map.Width;
            MapHeight = map.Height;
            Blocks = map.Blocks.OfType<Map.Block>().Select(b => (byte)(b.MapBorder ? 255 : b.WallIndex == 0 ? b.ObjectIndex : 100 + b.WallIndex)).ToArray();
        }

        private void InitLabdata(Labdata labdata, uint paletteIndex)
        {
            wallTextureAtlas?.Dispose();
            floorTextureAtlas?.Dispose();
            ceilingTextureAtlas?.Dispose();
            objectTextureAtlas?.Dispose();

            wallTextures = TextureLoader.Load(labdata.WallGraphics, out var paletteTextureAtlas);
            wallTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex]);
            TextureLoader.Load((new[] { labdata.FloorGraphic }).ToList(), out paletteTextureAtlas);
            floorTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex]);
            TextureLoader.Load((new[] { labdata.CeilingGraphic }).ToList(), out paletteTextureAtlas);
            ceilingTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex]);
            objectTextures = TextureLoader.Load(labdata.ObjectGraphics, out paletteTextureAtlas);
            objectTextureAtlas = paletteTextureAtlas.ToTextureAtlas(palettes[paletteIndex]);
        }

        private void initTimer_Tick(object sender, EventArgs e)
        {
            view3D_Resize(this, EventArgs.Empty);
            initTimer.Stop();
        }

        private void MainForm_FormClosed(object sender, FormClosedEventArgs e)
        {
            wallTextureAtlas?.Dispose();
            floorTextureAtlas?.Dispose();
            ceilingTextureAtlas?.Dispose();
            objectTextureAtlas?.Dispose();
        }
    }
}