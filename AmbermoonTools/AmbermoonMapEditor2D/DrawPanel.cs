namespace System.Windows.Forms
{
    class DrawPanel : Panel
    {
        public DrawPanel()
        {
            SetStyle(ControlStyles.UserPaint | ControlStyles.AllPaintingInWmPaint | ControlStyles.OptimizedDoubleBuffer, true);
        }
    }
}
