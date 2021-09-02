namespace System.Windows.Forms
{
    class DrawPanel : Panel
    {
        public DrawPanel()
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer, true);
        }


        protected override CreateParams CreateParams
        {
            get
            {
                var cp = base.CreateParams;
                cp.Style |= 0x00200000; // WS_VSCROLL
                return cp;
            }
        }
    }

    class MapDrawPanel : DrawPanel
    {
        protected override CreateParams CreateParams
        {
            get
            {
                var cp = base.CreateParams;
                cp.Style |= 0x00300000; // WS_HSCROLL | WS_VSCROLL
                return cp;
            }
        }
    }
}
