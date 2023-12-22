using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using System.Drawing.Drawing2D;
using static Ambermoon.Data.Map;

namespace AmbermoonUIEventEditor
{
    public partial class EventViewControl : Panel
    {
        
        private class DropRequestResult
        {
            public bool Allow { get; set; }
            public int X { get; set; }
            public int Y { get; set; }
            public int SmallX { get; set; }
            public int SmallY { get; set; }
        }

        private class EventBlock
        {
            static EventBlock()
            {
                DraggedEventBlockChanged += (_, block) =>
                {
                    draggedBlockRenderArea = null;
                    relativeDragPosition = null;
                };
                DraggedEventBlockPositionChanged += (block, x, y) =>
                {
                    relativeDragPosition ??= new Point(x - block.Area.X, y - block.Area.Y);
                    draggedBlockRenderArea = new Rectangle(x - relativeDragPosition.Value.X, y - relativeDragPosition.Value.Y, block.UnzoomedArea.Width, block.UnzoomedArea.Height);
                };
            }

            public EventBlock(EventViewControl parent, Rectangle area, Point smallPosition, Event @event, List<Event> eventList, List<Event> events)
            {
                this.area = area;
                this.smallPosition = smallPosition;
                Event = @event;
                this.parent = parent;
                this.eventList = eventList;
                this.events = events;
            }

            private static readonly Color ChainStartColor = Color.FromArgb(0xcc, 0x44, 0x33);
            private static readonly Color NormalColor = Color.FromArgb(0x55, 0x77, 0x88);
            private static readonly Color BranchColor = Color.FromArgb(0xaa, 0xaa, 0x44);
            private static readonly Color ChainStartBranchColor = Color.FromArgb(0xcc, 0x66, 0x00);

            private static Point? relativeDragPosition = null;
            private static Rectangle? draggedBlockRenderArea = null; // Note: x and y must not be zoomed but width and height
            private static string? activeToolTipTitle = null; 
            private static string? activeToolTip = null;
            private readonly EventViewControl parent;
            private Rectangle area;
            private Point smallPosition;
            private readonly List<Event> eventList;
            private readonly List<Event> events;

            public static EventBlock? DraggedEventBlock { get; private set; } = null;
            public static Point? DraggedEventBlockLocation => draggedBlockRenderArea?.Location;
            public Rectangle Area => Zoom(UnzoomedArea, true);
            public Rectangle UnzoomedArea => new(area.X + parent.AutoScrollPosition.X, area.Y + parent.AutoScrollPosition.Y, area.Width, area.Height);
            public EventType EventType => Event.Type;
            public Event Event { get; }
            private EventDescription EventDescription => EventDescriptions.Events[EventType];
            public int? PreviewOffset { get; set; } = null;
            public static Point? DropTargetPosition { get; set; } = null;

            public static event Action<EventBlock?, EventBlock?>? DraggedEventBlockChanged;
            public static event Action<EventBlock, int, int>? DraggedEventBlockPositionChanged;
            public static event Func<EventBlock, int, int, DropRequestResult>? DraggedEventBlockDropRequested;
            public static event Action? RedrawRequested;

            private int Zoom(int y)
            {
                int zoomLevel = parent.ZoomLevel;

                if (zoomLevel < DefaultZoomLevel)
                {
                    while (zoomLevel++ < DefaultZoomLevel)
                    {
                        y >>= 1;
                    }
                }
                else if (zoomLevel > DefaultZoomLevel)
                {
                    while (zoomLevel-- > DefaultZoomLevel)
                    {
                        y <<= 1;
                    }
                }

                return y;
            }

            private Rectangle Zoom(Rectangle defaultZoomArea, bool useSmallPosition = false)
            {
                int zoomLevel = parent.ZoomLevel;

                if (zoomLevel < DefaultZoomLevel)
                {
                    if (useSmallPosition)
                    {
                        defaultZoomArea.X = smallPosition.X;
                        defaultZoomArea.Y = smallPosition.Y;
                    }

                    defaultZoomArea.Height = BlockTitleLineHeight * 3;

                    while (zoomLevel++ < DefaultZoomLevel)
                    {
                        defaultZoomArea.X >>= 1;
                        defaultZoomArea.Y >>= 1;
                        defaultZoomArea.Width >>= 1;
                        defaultZoomArea.Height >>= 1;
                    }
                }
                else if (zoomLevel > DefaultZoomLevel)
                {
                    while (zoomLevel-- > DefaultZoomLevel)
                    {
                        defaultZoomArea.X <<= 1;
                        defaultZoomArea.Y <<= 1;
                        defaultZoomArea.Width <<= 1;
                        defaultZoomArea.Height <<= 1;
                    }
                }

                return defaultZoomArea;
            }

            private bool HandleMouseUp()
            {
                if (DraggedEventBlock == this)
                {
                    var dropLocation = draggedBlockRenderArea!.Value.Location;
                    DraggedEventBlock = null;
                    DraggedEventBlockChanged?.Invoke(this, null);

                    var dropResult = DraggedEventBlockDropRequested?.Invoke(this, dropLocation.X, dropLocation.Y);

                    if (dropResult?.Allow == true)
                    {
                        MoveTo(dropResult.X, dropResult.Y, dropResult.SmallX, dropResult.SmallY);
                        RedrawRequested?.Invoke();
                    }

                    return true;
                }

                return false;
            }

            // Note: Those coordinates are unzoomed
            public void MoveTo(int x, int y, int smallX, int smallY)
            {
                area = new Rectangle(new Point(x, y), Area.Size);
                smallPosition = new Point(smallX, smallY);
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
                var area = Area;

                if (DraggedEventBlock == this && draggedBlockRenderArea != null)
                {
                    var placeholderArea = area;
                    int inflateAmount = -Zoom(4);
                    int offsetAmount = parent.ZoomLevel / 2;
                    placeholderArea.Inflate(inflateAmount, inflateAmount);
                    placeholderArea.Offset(offsetAmount, offsetAmount);
                    if (PreviewOffset != null)
                        placeholderArea.Offset(0, Zoom(PreviewOffset.Value));
                    using var redBrush = new SolidBrush(Color.FromArgb(128, Color.Red));
                    using var redPen = new Pen(Color.Red, 2);
                    using var path = RoundedRectPath(placeholderArea, 6);
                    e.Graphics.FillPath(redBrush, path);
                    e.Graphics.DrawPath(redPen, path);

                    int x = draggedBlockRenderArea.Value.X;
                    int y = draggedBlockRenderArea.Value.Y;
                    area = Zoom(draggedBlockRenderArea.Value, true);
                    area.X = x;
                    area.Y = y;

                    if (DropTargetPosition != null)
                    {
                        placeholderArea = Zoom(new Rectangle(DropTargetPosition.Value, UnzoomedArea.Size));
                        placeholderArea.Inflate(inflateAmount, inflateAmount);
                        placeholderArea.Offset(offsetAmount, offsetAmount);
                        using var greenBrush = new SolidBrush(Color.FromArgb(128, Color.ForestGreen));
                        using var greenPen = new Pen(Color.ForestGreen, 2);
                        using var targetPath = RoundedRectPath(placeholderArea, 6);
                        e.Graphics.FillPath(greenBrush, targetPath);
                        e.Graphics.DrawPath(greenPen, targetPath);
                    }
                }
                else if (PreviewOffset != null)
                {
                    area.Y += Zoom(PreviewOffset.Value);
                }

                bool chainStart = eventList.Contains(Event);
                bool branch = Event.Type == EventType.Condition || Event.Type == EventType.Decision || Event.Type == EventType.Dice100Roll;

                var color = chainStart ? (branch ? ChainStartBranchColor : ChainStartColor) : branch ? BranchColor : NormalColor;

                DrawEventBlock(e.Graphics, area, color, (byte)(DraggedEventBlock == this ? 192 : 255));                
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

                var titleFont = titleFonts![parent.ZoomLevel - MinZoomLevel];
                
                if (parent.ZoomLevel >= 3)
                {
                    DrawText(graphics, titleFont!, new Rectangle(area.X + 2, area.Y + 3, area.Width - 4, BlockTitleLineHeight - 6), EventType.ToString(), true);

                    using var linePen = new Pen(Color.Black, 1);
                    graphics.DrawLine(linePen, new Point(area.X, area.Y + BlockTitleLineHeight - 3), new Point(area.Right - 1, area.Y + BlockTitleLineHeight - 3));

                    int line = 0;
                    var font = fonts![parent.ZoomLevel - MinZoomLevel];

                    foreach (var valueDesc in GetValueLines())
                        DrawText(graphics, font!, new Rectangle(area.X + 2, area.Y + BlockTitleLineHeight + (line++) * BlockLineHeight + 1, area.Width - 4, BlockLineHeight - 2), valueDesc);
                }
                else
                {
                    DrawText(graphics, titleFont!, area, EventType.ToString(), true);
                }
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
                using GraphicsPath path = RoundedRectPath(area, 6);

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
            titleFonts ??= Enumerable.Range(MinZoomLevel, 1 + MaxZoomLevel - MinZoomLevel).Select(level => new Font(new FontFamily("Segoe UI"), 7 + (level - 1) * 2, FontStyle.Bold)).ToList();
            fonts ??= Enumerable.Range(MinZoomLevel, 1 + MaxZoomLevel - MinZoomLevel).Select(level => new Font(new FontFamily("Segoe UI"), 5 + (level - 1) * 2)).ToList();

            EventBlock.DraggedEventBlockChanged += (old, @new) =>
            {
                if (old != null && @new == null)
                {
                    eventBlocks.ForEach(b => b.PreviewOffset = null);
                    Refresh();
                }
            };
            EventBlock.DraggedEventBlockPositionChanged += DraggedEventBlockPositionChanged;
            EventBlock.DraggedEventBlockDropRequested += CheckEventBlockDrop;
            EventBlock.RedrawRequested += Refresh;
        }

        private const int BlockWidth = 180;
        private const int BlockTitleLineHeight = 24;
        private const int BlockLineHeight = 16;
        private const int BlockFooterHeight = 4;
        private const int HorizontalBlockGap = 8;
        private const int VerticalBlockGap = 4;
        private const int MinZoomLevel = 1;
        private const int MaxZoomLevel = 4;
        private const int DefaultZoomLevel = 3;
        private readonly List<EventBlock> eventBlocks = new();
        private readonly List<List<EventBlock>> eventBlockColumns = new();
        private readonly List<Control> drawOverControls = new();
        private readonly List<Event> eventList = new();
        private readonly List<Event> events = new();
        private static List<Font>? titleFonts;
        private static List<Font>? fonts;
        private Rectangle? dropIndicatorArea = null;

        public int ZoomLevel { get; private set; } = DefaultZoomLevel;
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

        protected override void Dispose(bool disposing)
        {
            base.Dispose(disposing);

            titleFonts?.ForEach(font => font.Dispose());
            fonts?.ForEach(font => font.Dispose());
        }


        public void InitMap(Map map)
        {
            eventList.Clear();
            events.Clear();
            eventBlocks.Clear();
            eventBlockColumns.Clear();
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

            int x = HorizontalBlockGap + column * (HorizontalBlockGap + BlockWidth);
            int smallY = eventBlockColumns[column].Count == 0 ? VerticalBlockGap : VerticalBlockGap + eventBlockColumns[column].Count * (VerticalBlockGap + BlockTitleLineHeight * 3);
            int y = eventBlockColumns[column].Count == 0 ? VerticalBlockGap : eventBlockColumns[column][^1].UnzoomedArea.Bottom + VerticalBlockGap;

            if (addEvent)
                events.Add(@event);
            var eventBlock = new EventBlock(this, new Rectangle(x, y, BlockWidth, height), new Point(x, smallY), @event, eventList, events);
            eventBlocks.Add(eventBlock);
            eventBlockColumns[column].Add(eventBlock);
            if (redraw)
                Refresh();

            AutoScrollMinSize = new Size((eventBlockColumns.Count + 1) * (HorizontalBlockGap + BlockWidth), eventBlockColumns.Where(c => c.Count > 0).Max(c => c[^1].Area.Bottom));
        }

        private void DraggedEventBlockPositionChanged(EventBlock eventBlock, int _, int __)
        {
            EventBlock.DropTargetPosition = null;
            eventBlocks.ForEach(b => b.PreviewOffset = null);

            var location = EventBlock.DraggedEventBlockLocation!.Value;
            int x = location.X - AutoScrollPosition.X;
            int y = location.Y - AutoScrollPosition.Y;
            int zoomLevel = ZoomLevel;

            if (zoomLevel < DefaultZoomLevel)
            {
                while (zoomLevel++ < DefaultZoomLevel)
                {
                    x <<= 1;
                    y <<= 1;
                }
            }
            else if (zoomLevel > DefaultZoomLevel)
            {
                while (zoomLevel-- > DefaultZoomLevel)
                {
                    x >>= 1;
                    y >>= 1;
                }
            }

            // Coordinates are now unzoomed so we can just work with default sizes

            x += BlockWidth / 2; // we care about the center of the block
            y += ZoomLevel < 3 ? BlockTitleLineHeight * 3 / 2 : eventBlock.UnzoomedArea.Height / 2;

            int oldColumn = eventBlockColumns.FindIndex(column => column.Contains(eventBlock));
            int columnWidth = BlockWidth + HorizontalBlockGap;
            int columnStartX = HorizontalBlockGap / 2;
            int column = Math.Max(0, (x - columnStartX) / columnWidth);

            if (column == oldColumn)
            {
                if (eventBlockColumns[oldColumn].Count == 1)
                {
                    Refresh();
                    return;
                }

                if (ZoomLevel < 3)
                {
                    int currentRow = eventBlockColumns[oldColumn].IndexOf(eventBlock);
                    int by = VerticalBlockGap + currentRow * (VerticalBlockGap + BlockTitleLineHeight * 3);
                    if (y >= by - VerticalBlockGap / 2 && y < by + BlockTitleLineHeight * 3 + VerticalBlockGap / 2)
                    {
                        Refresh();
                        return;
                    }
                }
                else if (y >= eventBlock.UnzoomedArea.Y - VerticalBlockGap / 2 && y < eventBlock.UnzoomedArea.Bottom + VerticalBlockGap / 2)
                {
                    Refresh();
                    return;
                }
            }

            if (column < eventBlockColumns.Count)
            {
                var previewOffset = (ZoomLevel < 3
                    ? BlockTitleLineHeight * 3
                    : eventBlock.UnzoomedArea.Height)
                    + VerticalBlockGap;
                int row = 0;

                foreach (var block in eventBlockColumns[column])
                {
                    int blockY = ZoomLevel < 3
                        ? VerticalBlockGap + row * (BlockTitleLineHeight * 3 + VerticalBlockGap)
                        : block.UnzoomedArea.Y;
                    int blockHeight = ZoomLevel < 3
                        ? BlockTitleLineHeight * 3
                        : block.UnzoomedArea.Height;

                    if (y >= blockY + blockHeight / 2)
                    {
                        row++;
                    }
                    else
                    {
                        break;
                    }
                }

                bool sameSpot = column == oldColumn &&
                    (
                        (row == 0 && eventBlockColumns[column][0] == eventBlock) ||
                        (row > 0 && eventBlockColumns[column][row - 1] == eventBlock) ||
                        (row > 0 && row < eventBlockColumns[column].Count && eventBlockColumns[column][row] == eventBlock)
                    );

                if (!sameSpot)
                {
                    if (row < eventBlockColumns[column].Count)
                    {
                        for (int i = row; i < eventBlockColumns[column].Count; i++)
                        {
                            eventBlockColumns[column][i].PreviewOffset = previewOffset;
                        }
                    }

                    x = HorizontalBlockGap + column * (BlockWidth + HorizontalBlockGap);
                    y = row == 0 ? VerticalBlockGap : ZoomLevel < 3
                        ? VerticalBlockGap + row * (VerticalBlockGap + BlockTitleLineHeight * 3)
                        : eventBlockColumns[column][row - 1].UnzoomedArea.Bottom + VerticalBlockGap;
                    EventBlock.DropTargetPosition = new Point(x + AutoScrollPosition.X, y + AutoScrollPosition.Y);
                }
            }
            else
            {
                int tx = HorizontalBlockGap + eventBlockColumns.Count * (BlockWidth + HorizontalBlockGap);
                int ty = VerticalBlockGap;
                EventBlock.DropTargetPosition = new Point(tx + AutoScrollPosition.X, ty + AutoScrollPosition.Y);
            }

            Refresh();
        }

        // Note: dropX and dropY are the upper left coord of the dropped block
        // Note: the result must provide unzoomed coords
        private DropRequestResult CheckEventBlockDrop(EventBlock eventBlock, int dropX, int dropY)
        {
            dropX -= AutoScrollPosition.X;
            dropY -= AutoScrollPosition.Y;

            int zoomLevel = ZoomLevel;

            if (zoomLevel < DefaultZoomLevel)
            {
                while (zoomLevel++ < DefaultZoomLevel)
                {
                    dropX <<= 1;
                    dropY <<= 1;
                }
            }
            else if (zoomLevel > DefaultZoomLevel)
            {
                while (zoomLevel-- > DefaultZoomLevel)
                {
                    dropX >>= 1;
                    dropY >>= 1;
                }
            }

            // Drop coordinates are now unzoomed so we can just work with default sizes

            dropX += BlockWidth / 2; // we care about the center of the block
            dropY += ZoomLevel < 3 ? BlockTitleLineHeight * 3 / 2 : eventBlock.UnzoomedArea.Height / 2;

            int oldColumn = eventBlockColumns.FindIndex(column => column.Contains(eventBlock));
            int columnWidth = BlockWidth + HorizontalBlockGap;
            int columnStartX = HorizontalBlockGap / 2;
            int column = Math.Max(0, (dropX - columnStartX) / columnWidth);

            if (column == oldColumn)
            {
                if (eventBlockColumns[oldColumn].Count == 1)
                    return new DropRequestResult { Allow = false }; // We are already at that place so avoid drop logic

                if (ZoomLevel < 3)
                {
                    int currentRow = eventBlockColumns[oldColumn].IndexOf(eventBlock);
                    int by = VerticalBlockGap + currentRow * (VerticalBlockGap + BlockTitleLineHeight * 3);
                    if (dropY >= by - VerticalBlockGap / 2 && dropY < by + BlockTitleLineHeight * 3 + VerticalBlockGap / 2)
                        return new DropRequestResult { Allow = false }; // We are already at that place so avoid drop logic
                }
                else if (dropY >= eventBlock.UnzoomedArea.Y - VerticalBlockGap / 2 && dropY < eventBlock.UnzoomedArea.Bottom + VerticalBlockGap / 2)
                    return new DropRequestResult { Allow = false }; // We are already at that place so avoid drop logic
            }

            if (column > eventBlockColumns.Count)
                column = eventBlockColumns.Count;

            var description = EventDescriptions.Events[eventBlock.EventType];

            bool chainStart = column == eventBlockColumns.Count || eventBlockColumns[column].Count == 0 ||
                dropY < eventBlockColumns[column][0].UnzoomedArea.Bottom;

            if ((chainStart && !description.AllowAsFirst) || (!chainStart && description.AllowOnlyAsFirst))
                return new DropRequestResult { Allow = false };

            // TODO: Also check if the remaining column events are valid then
            // TODO: AllowSingleItem checking is tricky as we should allow temporary states

            void RearrangeColumn(int column)
            {
                var blocks = new List<EventBlock>(eventBlockColumns[column]);

                eventBlockColumns[column].Clear(); // Will be re-added by AddBlock so we have to remove it here

                foreach (var block in blocks)
                    eventBlocks.Remove(block); // Will be re-added by AddBlock so we have to remove it here

                blocks.ForEach(block => AddBlock(block.Event, column, false, false));
            }

            // There are a few drop scenarios:
            //
            // (1) dropColumn < oldColumn
            // (2) dropColumn = oldColumn
            // (3) dropColumn > oldColumn
            //
            // For (2) only important:
            //
            // (A) dropRow < oldRow
            // (B) dropRow = oldRow
            // (C) dropRow > oldRow
            //
            // Specials:
            //
            // (S) dropColumn = new appended column
            // (X) oldColumn becomes empty

            // Case (2)(B) is handled above. No drop logic is executed for this case.
            // Cases (1)(S) and (2)(S) are not possible.
            // Case (2) is not possible with (X).
            //
            // So we have:
            //
            // (1), (3), (2)(A), (2)(C), (3)(S), (1)(X), (3)(X) and (3)(S)(X)

            int oldRow = eventBlockColumns[oldColumn].IndexOf(eventBlock);
            eventBlockColumns[oldColumn].Remove(eventBlock);            

            #region Adjust old column events
            int eventListIndex = eventList.IndexOf(eventBlock.Event);
            int newEventListIndex = column;

            if (eventListIndex >= 0)
            {
                if (eventBlock.Event.Next != null)
                    eventList[eventListIndex] = eventBlock.Event.Next;
                else
                {
                    eventList.RemoveAt(eventListIndex);

                    if (newEventListIndex > oldColumn)
                        newEventListIndex--;
                }
            }

            if (eventBlockColumns[oldColumn].Count > 0)
            {
                var prev = eventBlockColumns[oldColumn].FirstOrDefault(b => b.Event.Next == eventBlock.Event);

                if (prev != null)
                    prev.Event.Next = eventBlock.Event.Next;
            }

            eventBlock.Event.Next = null;
            #endregion

            int x = HorizontalBlockGap + column * (HorizontalBlockGap + BlockWidth);
            int y;
            int smallY;

            if (column == eventBlockColumns.Count) // (3)(S) or (3)(S)(X)
            {
                eventList.Add(eventBlock.Event);
                eventBlockColumns.Add(new() { eventBlock });
                y = VerticalBlockGap;
                smallY = VerticalBlockGap;
            }
            else
            {
                y = VerticalBlockGap;
                smallY = VerticalBlockGap;
                int row = 0;

                foreach (var block in eventBlockColumns[column])
                {
                    int blockY = ZoomLevel < 3
                        ? VerticalBlockGap + row * (BlockTitleLineHeight * 3 + VerticalBlockGap)
                        : block.UnzoomedArea.Y;
                    int blockHeight = ZoomLevel < 3
                        ? BlockTitleLineHeight * 3
                        : block.UnzoomedArea.Height;

                    // Account for the removed block height if same column and below remove row
                    if (ZoomLevel < 3 && oldColumn == column && row >= oldRow)
                        blockY += BlockTitleLineHeight * 3 + VerticalBlockGap;

                    if (dropY >= blockY + blockHeight / 2)
                    {
                        y = block.UnzoomedArea.Bottom + VerticalBlockGap;
                        smallY += BlockTitleLineHeight * 3 + VerticalBlockGap;
                        row++;
                    }
                    else
                    {
                        break;
                    }
                }

                eventBlockColumns[column].Insert(row, eventBlock);

                if (eventBlockColumns[column].Count > 1 || column != oldColumn)
                {
                    if (row == 0)
                    {
                        eventBlock.Event.Next = eventList[newEventListIndex];
                        eventList[newEventListIndex] = eventBlock.Event;
                    }
                    else
                    {
                        var prev = eventBlockColumns[column][row - 1].Event;
                        eventBlock.Event.Next = prev.Next;
                        prev.Next = eventBlock.Event;
                    }
                }
            }

            if (eventBlockColumns[oldColumn].Count == 0)
            {
                eventBlockColumns.RemoveAt(oldColumn);

                for (int i = oldColumn; i < eventBlockColumns.Count; i++)
                {
                    RearrangeColumn(i);
                }

                if (column < oldColumn && eventBlockColumns[column].Count > 1)
                    RearrangeColumn(column);

                if (column > oldColumn)
                    x -= (BlockWidth + HorizontalBlockGap);
            }
            else
            {
                RearrangeColumn(oldColumn);

                if (column != oldColumn && eventBlockColumns[column].Count > 1)
                    RearrangeColumn(column);
            }

            EventBlock.HideTooltips();

            return new DropRequestResult
            {
                Allow = true,
                X = x,
                Y = y,
                SmallX = x,
                SmallY = smallY
            };
        }

        private void OverDrawControl(object? sender, PaintEventArgs e)
        {
            // TODO
            //EventBlock.RenderDraggedBlock((sender as Control)!, e);
            EventBlock.DraggedEventBlock?.Render((sender as Control)!, e);
        }

        protected override void OnScroll(ScrollEventArgs e)
        {
            base.OnScroll(e);

            EventBlock.HideTooltips();

            Refresh();
        }

        protected override void OnMouseWheel(MouseEventArgs e)
        {
            if (EventBlock.DraggedEventBlock != null)
                return;

            if (ModifierKeys.HasFlag(Keys.Control))
            {
                int zoomLevel = Ambermoon.Util.Limit(MinZoomLevel, ZoomLevel + Math.Sign(e.Delta), MaxZoomLevel);
                
                if (zoomLevel != ZoomLevel)
                {
                    ZoomLevel = zoomLevel;
                    Refresh();
                }
            }
            else
            {
                base.OnMouseWheel(e);
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            e.Graphics.FillRectangle(SystemBrushes.Window, DisplayRectangle);

            foreach (var eventBlock in eventBlocks)
            {
                if (eventBlock != EventBlock.DraggedEventBlock)
                    eventBlock.Render(this, e);
            }

            EventBlock.DraggedEventBlock?.Render(this, e);

            var tooltipPos = PointToClient(MousePosition);
            EventBlock.RenderTooltip(this, tooltipPos, e);
        }

        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);

            if (e.Button == MouseButtons.Left)
            {
                foreach (var eventBlock in eventBlocks)
                {
                    if (eventBlock.TestMouseDown(e.X, e.Y))
                    {
                        Refresh();
                        break;
                    }
                }
            }            
        }

        protected override void OnMouseUp(MouseEventArgs e)
        {
            base.OnMouseUp(e);

            if (e.Button == MouseButtons.Left)
            {
                var blocks = new List<EventBlock>(eventBlocks); // we create a copy as the list might be changed by drop handling
                blocks.ForEach(eventBlock => eventBlock.MouseUp());
            }
        }

        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);

            EventBlock.HideTooltips();

            bool mouseDown = e.Button == MouseButtons.Left;

            foreach (var eventBlock in eventBlocks)
            {
                if (eventBlock.MouseMoveTo(e.X, e.Y, mouseDown))
                {
                    Refresh();
                    break;
                }
            }
        }

        protected override void OnMouseHover(EventArgs e)
        {
            base.OnMouseHover(e);

            EventBlock.HideTooltips();

            if (EventBlock.DraggedEventBlock == null)
            {
                var mousePos = PointToClient(MousePosition);

                foreach (var eventBlock in eventBlocks)
                {
                    if (eventBlock.TestHover(mousePos.X, mousePos.Y))
                    {
                        Refresh();
                        break;
                    }
                }
            }

            ResetMouseEventArgs();
        }

        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);

            EventBlock.HideTooltips();
            Refresh();
        }
    }
}
