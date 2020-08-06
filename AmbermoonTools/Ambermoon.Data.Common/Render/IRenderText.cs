namespace Ambermoon.Data.Render
{
    public interface IRenderText
    {
        void DrawText(string text, int x, int y);
        void DrawText(string text, Rect rect, TextAlign textAlign = TextAlign.Left);
    }
}
