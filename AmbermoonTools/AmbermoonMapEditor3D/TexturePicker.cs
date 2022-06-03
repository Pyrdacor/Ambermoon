namespace AmbermoonMapEditor3D
{
    internal partial class TexturePicker : UserControl
    {
        public List<ITexturedObject> TexturedObjects { get; set; }
        int scrollOffset = 0;
        int maxScrollOffset = 0;
        public int SelectedIndex { get; private set; } = 0;
        public event Action SelectedIndexChanged;
        bool scrollingLeft = false;
        bool scrollingRight = false;
        bool initScrollLeft = false;
        bool initScrollRight = false;
        int minTextureSize;

        public TexturePicker()
        {
            this.DoubleBuffered = true;

            InitializeComponent();
        }

        private void TexturePicker_Load(object sender, EventArgs e)
        {
            if (TexturedObjects == null)
                throw new NullReferenceException("TexturedObjects must be set before opening the texture picker.");

            int viewWidth = ClientSize.Width - buttonLeft.Width - buttonRight.Width;
            maxScrollOffset = TexturedObjects.Sum(o => o.Width) - viewWidth;
            minTextureSize = TexturedObjects.Min(o => o.Width);

            Height = Math.Max(32, TexturedObjects.Max(o => o.Height));
            MinimumSize = new Size(0, Height);

            UpdateSize();

            foreach (var obj in TexturedObjects)
                obj.FrameChanged += UpdateView;
        }

        private void UpdateView()
        {
            Refresh();
        }

        private void TexturePicker_Paint(object sender, PaintEventArgs e)
        {
            using (var brush = new SolidBrush(BackColor))
                e.Graphics.FillRectangle(brush, ClientRectangle);

            int x = 0;
            int viewWidth = ClientSize.Width - buttonLeft.Width - buttonRight.Width;
            int viewX = scrollOffset;
            int viewEndX = scrollOffset + viewWidth;
            int index = 0;
            int displayX = buttonLeft.Bounds.Right;

            foreach (var texturedObject in TexturedObjects)
            {
                int endX = x + texturedObject.Width;
                if ((x >= viewX && x < viewEndX) || (endX >= viewX - 1 && endX <= viewEndX))
                {
                    int sourceX = x >= viewX ? 0 : viewX - x;
                    int sourceEndX = endX <= viewEndX ? texturedObject.Width : texturedObject.Width - (endX - viewEndX);
                    sourceX += texturedObject.CurrentFrame * texturedObject.Width;
                    sourceEndX += texturedObject.CurrentFrame * texturedObject.Width;
                    var sourceRect = new Rectangle(sourceX, 0, sourceEndX - sourceX, Math.Min(texturedObject.Height, Height));

                    e.Graphics.DrawImage(texturedObject.Texture, displayX, 0, sourceRect, GraphicsUnit.Pixel);

                    if (SelectedIndex == index)
                    {
                        using (var marker = new Pen(Color.Red, 2.0f))
                            e.Graphics.DrawRectangle(marker, displayX, 0, sourceRect.Width, sourceRect.Height);
                    }

                    displayX += sourceRect.Width;
                }
                else if (x >= viewEndX)
                    break;

                x += texturedObject.Width;
                ++index;
            }
        }

        private void buttonLeft_Click(object sender, EventArgs e)
        {
            ScrollLeft();
        }

        private void buttonRight_Click(object sender, EventArgs e)
        {
            ScrollRight();
        }

        private bool ScrollLeft()
        {
            return ScrollTo(Math.Max(0, scrollOffset - minTextureSize));
        }

        private bool ScrollRight()
        {
            return ScrollTo(Math.Min(maxScrollOffset, scrollOffset + minTextureSize));
        }

        private bool ScrollTo(int offset)
        {
            if (scrollOffset == offset)
                return false;

            scrollOffset = offset;
            UpdateView();
            return true;
        }

        private void UpdateSize()
        {
            int viewWidth = ClientSize.Width - buttonLeft.Width - buttonRight.Width;
            maxScrollOffset = TexturedObjects.Sum(o => o.Width) - viewWidth;
            if (scrollOffset > maxScrollOffset)
                scrollOffset = maxScrollOffset;
            UpdateView();
        }

        private void TexturePicker_Resize(object sender, EventArgs e)
        {
            UpdateSize();
        }

        private void TexturePicker_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.X < buttonLeft.Bounds.Right || e.X >= buttonRight.Bounds.Left)
                return;

            int x = 0;
            int index = 0;

            foreach (var texturedObject in TexturedObjects)
            {
                int displayX = buttonLeft.Bounds.Right + x - scrollOffset;
                int endDisplayX = displayX + texturedObject.Width;

                if (e.X >= displayX && e.X < endDisplayX)
                {
                    if (SelectedIndex != index)
                    {
                        SelectedIndex = index;
                        UpdateView();
                        SelectedIndexChanged?.Invoke();
                    }
                    break;
                }

                x += texturedObject.Width;
                ++index;
            }
        }

        private void buttonLeft_MouseDown(object sender, MouseEventArgs e)
        {
            initScrollLeft = true;
            initScrollRight = false;
            timerScrollInit.Stop();
            timerScrollInit.Start();
        }

        private void buttonLeft_MouseUp(object sender, MouseEventArgs e)
        {
            scrollingLeft = false;
            scrollingRight = false;
            initScrollLeft = false;
            initScrollRight = false;
            timerScrollInit.Stop();
        }

        private void buttonRight_MouseDown(object sender, MouseEventArgs e)
        {
            initScrollLeft = false;
            initScrollRight = true;
            timerScrollInit.Stop();
            timerScrollInit.Start();
        }

        private void buttonRight_MouseUp(object sender, MouseEventArgs e)
        {
            scrollingLeft = false;
            scrollingRight = false;
            initScrollLeft = false;
            initScrollRight = false;
            timerScrollInit.Stop();
        }

        private void timerScroll_Tick(object sender, EventArgs e)
        {
            if (scrollingLeft)
            {
                if (!ScrollLeft())
                    scrollingLeft = false;
            }
            else if (scrollingRight)
            {
                if (!ScrollRight())
                    scrollingRight = false;
            }
        }

        private void timerScrollInit_Tick(object sender, EventArgs e)
        {
            scrollingLeft = initScrollLeft;
            scrollingRight = initScrollRight;
            timerScrollInit.Stop();
            initScrollLeft = false;
            initScrollRight = false;
        }

        private void TexturePicker_MouseUp(object sender, MouseEventArgs e)
        {
            scrollingLeft = false;
            scrollingRight = false;
            initScrollLeft = false;
            initScrollRight = false;
            timerScrollInit.Stop();
        }
    }
}
