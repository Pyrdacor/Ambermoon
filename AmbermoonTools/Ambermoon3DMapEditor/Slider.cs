using System.Drawing.Drawing2D;

namespace System.Windows.Forms
{
    internal class Slider : Panel
    {
        private int value = 0;
        private int minimum = 0;
        private int maximum = 0;
        private int tickFrequency = 1;
        private bool isDragging = false;

        public event Action<int>? ValueChanged;

        public Slider()
        {
            DoubleBuffered = true;
        }

        public int Minimum
        {
            get => minimum;
            set
            {
                if (minimum == value)
                    return;

                minimum = value;

                if (maximum < minimum)
                    maximum = minimum;

                if (Value < minimum)
                    Value = minimum;
                else if (Value > maximum)
                    Value = maximum;

                if (Visible)
                    Refresh();
            }
        }
        public int Maximum
        {
            get => maximum;
            set
            {
                if (maximum == value)
                    return;

                maximum = value;

                if (minimum > maximum)
                    minimum = maximum;

                if (Value > maximum)
                    Value = maximum;
                else if (Value < minimum)
                    Value = minimum;

                if (Visible)
                    Refresh();
            }
        }
        public int TickFrequency
        {
            get => tickFrequency;
            set
            {
                if (tickFrequency == value)
                    return;

                tickFrequency = value;

                if (Visible)
                    Refresh();
            }
        }
        public int Value
        {
            get => value;
            set
            {
                if (value < Minimum)
                    value = Minimum;
                else if (value > Maximum)
                    value = Maximum;

                if (this.value == value)
                    return;

                this.value = value;

                ValueChanged?.Invoke(value);

                if (Visible)
                    Refresh();
            }
        }

        private GraphicsPath CreateSliderPath(int x, int y)
        {
            var sliderPath = new GraphicsPath();
            sliderPath.AddPolygon(new Point[5]
            {
                new Point(x - 8, y),
                new Point(x + 8, y),
                new Point(x + 8, y + 16),
                new Point(x, y + 24),
                new Point(x - 8, y + 16)
            });
            return sliderPath;
        }

        private Dictionary<int, Rectangle> GetValueRects()
        {
            int range = Maximum - Minimum;
            int steps = 1 + range / TickFrequency;
            int displayWidth = Width - 32;
            int valueDistance = displayWidth / (steps - 1);
            var rects = new Dictionary<int, Rectangle>();

            for (int i = 0; i < steps; i++)
            {
                var value = Math.Min(Minimum + i * TickFrequency, Maximum);

                rects.Add(value, new Rectangle(16 + i * valueDistance, 0, 16, 24));
            }

            return rects;
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            var fillBrush = SystemBrushes.Window;
            e.Graphics.FillRectangle(fillBrush, DisplayRectangle);
            using var linePen = new Pen(SystemBrushes.ControlDark, 2);
            using var fontBrush = new SolidBrush(DefaultForeColor);

            var valueRects = GetValueRects();
            int displayWidth = Width - 32;

            e.Graphics.DrawLine(linePen, new Point(16, 24), new Point(16 + displayWidth, 24));

            foreach (var valueRect in valueRects)
            {
                var rect = valueRect.Value;

                if (valueRect.Key == Value)
                {
                    using var sliderPath = CreateSliderPath(rect.X, rect.Y);
                    e.Graphics.FillPath(SystemBrushes.ControlLight, sliderPath);
                    e.Graphics.DrawPath(linePen, sliderPath);
                }

                var position = new Point(rect.X, 24);
                e.Graphics.DrawLine(linePen, new Point(position.X + 1, position.Y), new Point(position.X + 1, position.Y + 6));

                var textPosition = new Point(position.X - 6, position.Y + 6);
                e.Graphics.DrawString($"{valueRect.Key}", DefaultFont, fontBrush, textPosition);
            }
        }

        private void HandleValueHover(Point mousePosition, Action<int> handler)
        {
            int range = Maximum - Minimum;
            int steps = 1 + range / TickFrequency;
            int displayWidth = Width - 32;
            int valueDistance = displayWidth / (steps - 1);

            for (int i = 0; i < steps; i++)
            {
                if (mousePosition.X < 16 + i * valueDistance + valueDistance / 2)
                {
                    handler(Math.Min(Minimum + i * TickFrequency, Maximum));
                    return;
                }
            }

            handler(Maximum);
        }

        protected override void OnMouseClick(MouseEventArgs e)
        {
            HandleValueHover(e.Location, value => Value = value);
        }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);

            if (e.Button == MouseButtons.Left)
                isDragging = true;
        }

        protected override void OnMouseUp(MouseEventArgs e)
        {
            base.OnMouseUp(e);

            isDragging = false;
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);

            isDragging = false;
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);

            if (e.Button != MouseButtons.Left)
                isDragging = false;

            if (isDragging)
            {
                HandleValueHover(e.Location, value => Value = value);
            }
        }
    }
}
