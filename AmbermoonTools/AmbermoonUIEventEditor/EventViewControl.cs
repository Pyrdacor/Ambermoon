using Ambermoon.Data;
using Ambermoon.Data.Descriptions;

namespace AmbermoonUIEventEditor
{
    public partial class EventViewControl : Panel
    {
        private class EventBlock
        {
            public EventBlock(Rectangle area, Event @event, List<Event> eventList, List<Event> events)
            {
                Area = area;
                Event = @event;
                this.eventList = eventList;
                this.events = events;
            }

            private static readonly Color ChainStartColor = Color.FromArgb(0xcc, 0x44, 0x33);
            private static readonly Color NormalColor = Color.FromArgb(0x55, 0x77, 0x88);
            private static readonly Color BranchColor = Color.FromArgb(0xaa, 0xaa, 0x44);

            private static Rectangle? draggedBlockRenderArea = null;
            private readonly List<Event> eventList;
            private readonly List<Event> events;

            public static EventBlock? DraggedEventBlock { get; private set; } = null;
            public Rectangle Area { get; private set; }
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
                Area = new Rectangle(new Point(x, y), Area.Size);
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

            public void Render(Control control, PaintEventArgs e)
            {
                bool chainStart = eventList.Contains(Event);
                bool branch = Event.Type == EventType.Condition || Event.Type == EventType.Decision || Event.Type == EventType.Dice100Roll;

                using var fillBrush = new SolidBrush(chainStart ? ChainStartColor : branch ? BranchColor : NormalColor);

                e.Graphics.FillRectangle(fillBrush, Area);
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
        }

        public EventViewControl()
        {
            DoubleBuffered = true;
        }

        private bool blocksNeedRefresh = true;
        private bool draggedBlockNeedsRefresh = false;
        private readonly List<EventBlock> eventBlocks = new();
        private readonly List<Control> drawOverControls = new();
        private readonly List<Event> eventList = new();
        private readonly List<Event> events = new();

        public List<Control> DrawOverControls
        {
            set
            {
                drawOverControls.ForEach(control => control.Paint -= OverDrawControl);

                drawOverControls.Clear();
                drawOverControls.AddRange(value);

                drawOverControls.ForEach(control => control.Paint += OverDrawControl);

                draggedBlockNeedsRefresh = true;
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
            blocksNeedRefresh = true;
            draggedBlockNeedsRefresh = true;
            Refresh();
            eventList.AddRange(map.EventList);
            events.AddRange(map.Events);

            // TODO

            blocksNeedRefresh = true;
            draggedBlockNeedsRefresh = true;
            Refresh();
        }

        public void AddBlock(Rectangle area, Event @event)
        {
            events.Add(@event);
            eventBlocks.Add(new EventBlock(area, @event, eventList, events));
            blocksNeedRefresh = true;
            Refresh();
        }

        private void OverDrawControl(object? sender, PaintEventArgs e)
        {
            if (draggedBlockNeedsRefresh)
                EventBlock.RenderDraggedBlock((sender as Control)!, e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (blocksNeedRefresh)
                eventBlocks.ForEach(eventBlock => eventBlock.Render(this, e));

            if (draggedBlockNeedsRefresh)
                EventBlock.RenderDraggedBlock(this, e);

            blocksNeedRefresh = false;
            draggedBlockNeedsRefresh = false;
        }
    }
}
