using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using System.Drawing.Drawing2D;

namespace AmbermoonUIEventEditor
{
    public partial class EventViewControl : Panel
    {
        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);

            titleFont?.Dispose();
            font?.Dispose();
        }

        private class EventBlock
        {
            public EventBlock(EventViewControl parent, Rectangle area, Event @event, List<Event> eventList, List<Event> events)
            {
                this.area = area;
                Event = @event;
                this.parent = parent;
                this.eventList = eventList;
                this.events = events;
            }

            private static readonly Color ChainStartColor = Color.FromArgb(0xcc, 0x44, 0x33);
            private static readonly Color NormalColor = Color.FromArgb(0x55, 0x77, 0x88);
            private static readonly Color BranchColor = Color.FromArgb(0xaa, 0xaa, 0x44);

            private static Rectangle? draggedBlockRenderArea = null;
            private static string? activeToolTipTitle = null; 
            private static string? activeToolTip = null;
            private readonly EventViewControl parent;
            private Rectangle area;
            private readonly List<Event> eventList;
            private readonly List<Event> events;

            public static EventBlock? DraggedEventBlock { get; private set; } = null;
            public Rectangle Area => new Rectangle(area.X + parent.AutoScrollPosition.X, area.Y + parent.AutoScrollPosition.Y, area.Width, area.Height);
            public EventType EventType => Event.Type;
            public Event Event { get; }
            private EventDescription EventDescription => EventDescriptions.Events[EventType];

            public static event Action<EventBlock?, EventBlock?>? DraggedEventBlockChanged;
            public static event Action<EventBlock, int, int>? DraggedEventBlockPositionChanged;

            private bool HandleMouseUp()
            {
                if (DraggedEventBlock == this)
                {
                    DraggedEventBlock = null;
                    DraggedEventBlockChanged?.Invoke(this, null);
                    return true;
                }

                return false;
            }

            public void MoveTo(int x, int y)
            {
                area = new Rectangle(new Point(x, y), Area.Size);
            }

            public bool TestMouseDown(int x, int y)
            {
                if (Area.Contains(x, y))
                {
                    if (DraggedEventBlock != this)
                    {
                        var old = DraggedEventBlock;
                        DraggedEventBlock = this;
                        DraggedEventBlockChanged?.Invoke(old, DraggedEventBlock);
                    }
                    DraggedEventBlockPositionChanged?.Invoke(DraggedEventBlock, x, y);
                    return true;
                }

                return false;
            }

            public void MouseUp()
            {
                HandleMouseUp();                
            }

            public bool MouseMoveTo(int x, int y, bool mouseDown)
            {
                if (!mouseDown)
                {
                    if (HandleMouseUp())
                        return true;
                }

                if (DraggedEventBlock == this)
                {
                    DraggedEventBlockPositionChanged?.Invoke(DraggedEventBlock, x, y);
                    return true;
                }

                return false;
            }

            public bool TestHover(int x, int y)
            {
                if (Area.Contains(x, y))
                {
                    activeToolTip = GetTooltipText();
                    activeToolTipTitle = EventType.ToString();
                    return true;
                }

                return false;
            }

            public static void HideTooltips()
            {
                activeToolTip = null;
                activeToolTipTitle = null;
            }

            private string GetTooltipText()
            {
                return string.Join("\r\n", GetValueLines());
            }

            private string[] GetValueLines()
            {
                string GetValue(ValueDescription valueDescription)
                {
                    var value = Event.GetType().GetProperty(valueDescription.Name)?.GetValue(Event);
                    return value != null ? valueDescription.AsString(value) : valueDescription.DefaultValueText;
                }

                return EventDescription.ValueDescriptions.Where(d => !d.Hidden).Select(d =>
                    $"{d.Name}: {GetValue(d)}").ToArray();
            }

            public void Render(Control control, PaintEventArgs e)
            {
                bool chainStart = eventList.Contains(Event);
                bool branch = Event.Type == EventType.Condition || Event.Type == EventType.Decision || Event.Type == EventType.Dice100Roll;

                var color = chainStart ? ChainStartColor : branch ? BranchColor : NormalColor;

                DrawEventBlock(e.Graphics, Area, color, 255);                
            }

            public static void RenderDraggedBlock(Control control, PaintEventArgs e)
            {
                if (DraggedEventBlock == null)
                {
                    if (draggedBlockRenderArea != null)
                    {

                    }
                }
            }

            public static void RenderTooltip(EventViewControl parent, Point position, PaintEventArgs e)
            {
                if (activeToolTip == null)
                    return;

                var font = SystemFonts.SmallCaptionFont;
                using var titleFont = new Font(font!, FontStyle.Bold);
                var textSize = e.Graphics.MeasureString(activeToolTip, font!);
                var titleSize = e.Graphics.MeasureString(activeToolTipTitle, titleFont);

                var area = new RectangleF(position, new SizeF(4 + Math.Max(textSize.Width, titleSize.Width), 4 + textSize.Height + 2 + titleSize.Height));
                var clip = parent.ClientRectangle;

                if (area.Left < clip.Left)
                    area.Offset(clip.Left - area.Left, 0);
                if (area.Top < clip.Top)
                    area.Offset(0, clip.Top - area.Top);
                if (area.Right > clip.Right)
                    area.Offset(clip.Right - area.Right, 0);
                if (area.Bottom > clip.Bottom)
                    area.Offset(0, clip.Bottom - area.Bottom);

                using var backgroundBrush = new SolidBrush(Color.FromArgb(192, Color.LightSteelBlue));

                e.Graphics.FillRectangle(backgroundBrush, area);
                e.Graphics.DrawRectangle(SystemPens.ActiveBorder, area);

                DrawText(e.Graphics, titleFont, new RectangleF(new PointF(area.X + 2, area.Y + 2), new SizeF(area.Width - 4, titleSize.Height)), activeToolTipTitle!, true);
                DrawText(e.Graphics, font!, new RectangleF(new PointF(area.X + 2, area.Y + 4 + titleSize.Height), new SizeF(area.Width - 4, textSize.Height)), activeToolTip);
            }

            private void DrawEventBlock(Graphics graphics, Rectangle area, Color color, byte alpha)
            {
                color = Color.FromArgb(alpha, color);

                FillBlock(graphics, area, color);

                var desc = EventDescription;

                DrawText(graphics, titleFont!, new Rectangle(area.X + 2, area.Y + 3, area.Width - 4, BlockTitleLineHeight - 6), EventType.ToString(), true);

                using var linePen = new Pen(Color.Black, 1);
                graphics.DrawLine(linePen, new Point(area.X, area.Y + BlockTitleLineHeight - 3), new Point(area.Right - 1, area.Y + BlockTitleLineHeight - 3));

                int line = 0;

                foreach (var valueDesc in GetValueLines())
                    DrawText(graphics, font!, new Rectangle(area.X + 2, area.Y + BlockTitleLineHeight + (line++) * BlockLineHeight + 1, area.Width - 4, BlockLineHeight - 2), valueDesc);
            }

            private static void DrawText(Graphics graphics, Font font, RectangleF bounds, string text, bool center = false)
            {
                using var textBrush = new SolidBrush(Color.Black);
                var textSize = graphics.MeasureString(text, font);

                while (textSize.Width > bounds.Width)
                {
                    text = text[0..^4] + "...";
                    textSize = graphics.MeasureString(text, font);
                }

                float x = center ? bounds.X + 0.5f * (bounds.Width - textSize.Width) : bounds.X;
                float y = bounds.Y + 0.5f * (bounds.Height - textSize.Height);
                graphics.DrawString(text, font, textBrush, x, y);
            }

            private static void FillBlock(Graphics graphics, Rectangle area, Color color)
            {
                using var fillBrush = new SolidBrush(color);
                using GraphicsPath path = RoundedRectPath(area, 4);

                graphics.FillPath(fillBrush, path);
            }

            private static GraphicsPath RoundedRectPath(Rectangle bounds, int radius)
            {
                int diameter = radius * 2;
                Size size = new(diameter, diameter);
                Rectangle arc = new(bounds.Location, size);
                GraphicsPath path = new();

                if (radius == 0)
                {
                    path.AddRectangle(bounds);
                    return path;
                }

                // top left arc  
                path.AddArc(arc, 180, 90);

                // top right arc  
                arc.X = bounds.Right - diameter;
                path.AddArc(arc, 270, 90);

                // bottom right arc  
                arc.Y = bounds.Bottom - diameter;
                path.AddArc(arc, 0, 90);

                // bottom left arc 
                arc.X = bounds.Left;
                path.AddArc(arc, 90, 90);

                path.CloseFigure();
                return path;
            }
        }

        public EventViewControl()
        {
            DoubleBuffered = true;
            AutoScroll = true;
            titleFont ??= new Font(new FontFamily("Segoe UI"), 11, FontStyle.Bold);
            font ??= new Font(new FontFamily("Segoe UI"), 9);
        }

        private const int BlockWidth = 180;
        private const int BlockTitleLineHeight = 24;
        private const int BlockLineHeight = 16;
        private const int BlockFooterHeight = 4;
        private const int HorizontalBlockGap = 8;
        private const int VerticalBlockGap = 4;
        private readonly List<EventBlock> eventBlocks = new();
        private readonly List<List<EventBlock>> eventBlockColumns = new();
        private readonly List<Control> drawOverControls = new();
        private readonly List<Event> eventList = new();
        private readonly List<Event> events = new();
        private static Font? titleFont;
        private static Font? font;

        public List<Control> DrawOverControls
        {
            set
            {
                drawOverControls.ForEach(control => control.Paint -= OverDrawControl);

                drawOverControls.Clear();
                drawOverControls.AddRange(value);

                drawOverControls.ForEach(control => control.Paint += OverDrawControl);

                drawOverControls.ForEach(control => control.Refresh());
                Refresh();
            }
        }

        public void InitMap(Map map)
        {
            eventList.Clear();
            events.Clear();
            eventBlocks.Clear();
            EventBlock.DraggedEventBlock?.MouseUp();
            Refresh();
            eventList.AddRange(map.EventList);
            events.AddRange(map.Events);

            int column = 0;

            foreach (var e in map.EventList)
            {
                var @event = e;

                while (@event != null)
                {
                    AddBlock(@event, column, false, false);
                    @event = @event.Next;
                }

                column++;
            }

            Refresh();
        }

        public void AddBlock(Event @event, int column = int.MaxValue, bool redraw = true, bool addEvent = true)
        {
            var eventDescription = EventDescriptions.Events[@event.Type];
            int height = BlockTitleLineHeight + eventDescription.ValueDescriptions.Count(d => !d.Hidden) * BlockLineHeight + BlockFooterHeight;

            if (column >= eventBlockColumns.Count)
            {
                column = eventBlockColumns.Count;
                eventBlockColumns.Add(new());
            }

            int y = eventBlockColumns[column].Count == 0 ? VerticalBlockGap : eventBlockColumns[column][^1].Area.Bottom + VerticalBlockGap;

            if (addEvent)
                events.Add(@event);
            var eventBlock = new EventBlock(this, new Rectangle(column * (HorizontalBlockGap + BlockWidth), y, BlockWidth, height), @event, eventList, events);
            eventBlocks.Add(eventBlock);
            eventBlockColumns[column].Add(eventBlock);
            if (redraw)
                Refresh();

            AutoScrollMinSize = new Size(eventBlockColumns.Count * (HorizontalBlockGap + BlockWidth), eventBlockColumns.Where(c => c.Count > 0).Max(c => c[^1].Area.Bottom));
        }

        private void OverDrawControl(object? sender, PaintEventArgs e)
        {
            EventBlock.RenderDraggedBlock((sender as Control)!, e);
        }

        protected override void OnScroll(ScrollEventArgs e)
        {
            base.OnScroll(e);

            EventBlock.HideTooltips();

            Refresh();
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            e.Graphics.FillRectangle(SystemBrushes.Window, DisplayRectangle);

            eventBlocks.ForEach(eventBlock => eventBlock.Render(this, e));

            var tooltipPos = PointToClient(MousePosition);
            EventBlock.RenderTooltip(this, tooltipPos, e);
            EventBlock.RenderDraggedBlock(this, e);
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);

            EventBlock.HideTooltips();
        }

        protected override void OnMouseHover(EventArgs e)
        {
            base.OnMouseHover(e);

            EventBlock.HideTooltips();

            var mousePos = PointToClient(MousePosition);

            foreach (var eventBlock in eventBlocks)
            {
                if (eventBlock.TestHover(mousePos.X, mousePos.Y))
                {
                    Refresh();
                    break;
                }
            }

            ResetMouseEventArgs();
        }
    }
}
