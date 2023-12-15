using OpenTK.Graphics.OpenGL;
using OpenTK.Mathematics;
using OpenTK.WinForms;

namespace Ambermoon3DMapEditor
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private const float BlockSize = 1.0f;
        private float WallHeight = 2 * BlockSize / 3.0f;
        private int MapWidth = 10;
        private int MapHeight = 10;
        private bool[] PressedKeys = Enumerable.Repeat(false, 256).ToArray();
        private Matrix4 ModelViewMatrix = Matrix4.Identity;
        private float PlayerX = 0.0f;
        private float PlayerY = 0.0f;
        private float PlayerViewAngle = 0.0f;
        private const float MoveSpeed = 0.1f;
        private const float TurnSpeed = 0.1f;

        private void DrawFloor()
        {
            GL.Vertex3(0.0f, 0.0f, -MapHeight * BlockSize);
            GL.Vertex3(MapWidth * BlockSize, 0.0f, -MapHeight * BlockSize);
            GL.Vertex3(MapWidth * BlockSize, 0.0f, 0.0f);
            GL.Vertex3(0.0f, 0.0f, 0.0f);
        }

        private void DrawCeiling()
        {

        }

        private void DrawWall(int x, int y, Color4 color)
        {
            GL.Color4(color);

            float left = x * BlockSize;
            float right = left + BlockSize;
            float far = -(MapHeight - y) * BlockSize;
            float near = far + BlockSize;
            float top = WallHeight;
            float bottom = 0.0f;

            // Front
            GL.Vertex3(left, top, near);
            GL.Vertex3(right, top, near);
            GL.Vertex3(right, bottom, near);
            GL.Vertex3(left, bottom, near);

            // Left
            GL.Vertex3(left, top, far);
            GL.Vertex3(left, top, near);
            GL.Vertex3(left, bottom, near);
            GL.Vertex3(left, bottom, far);

            // Back
            GL.Vertex3(right, top, far);
            GL.Vertex3(left, top, far);
            GL.Vertex3(left, bottom, far);
            GL.Vertex3(right, bottom, far);

            // Right
            GL.Vertex3(right, top, near);
            GL.Vertex3(right, top, far);
            GL.Vertex3(right, bottom, far);
            GL.Vertex3(right, bottom, near);
        }

        private void view3D_Paint(object sender, PaintEventArgs e)
        {
            view3D.MakeCurrent();
            GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);

            GL.Begin(BeginMode.Quads);

            DrawFloor();
            DrawCeiling();

            DrawWall(0, 0, Color4.Red);
            DrawWall(0, 2, Color4.Blue);
            DrawWall(9, 8, Color4.Green);

            GL.End();

            view3D.SwapBuffers();
        }

        private void view3D_Resize(object sender, EventArgs e)
        {
            view3D.MakeCurrent();

            GL.Viewport(0, 0, view3D.ClientSize.Width, view3D.ClientSize.Height);

            UpdateModelView();

            Matrix4 perpective = Matrix4.CreatePerspectiveFieldOfView(MathHelper.PiOver4, 1.6f, 1, 64);

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
                if (PressedKeys[(int)Keys.Q])
                {
                    TurnLeft();
                }
                else if (PressedKeys[(int)Keys.E])
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
            ModelViewMatrix = Matrix4.CreateTranslation(-PlayerX, -0.5f * WallHeight, MapHeight * BlockSize - PlayerY);
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
            GL.Enable(EnableCap.DepthTest);            
            PlayerX = 0.5f * MapWidth;
            PlayerY = 0.5f * MapHeight;
            statusPosition.Text = $"X: {PlayerX:0.0}, Y: {PlayerY:0.0}";
            initTimer.Start();
        }

        private void initTimer_Tick(object sender, EventArgs e)
        {
            view3D_Resize(this, EventArgs.Empty);
            initTimer.Stop();
        }
    }
}