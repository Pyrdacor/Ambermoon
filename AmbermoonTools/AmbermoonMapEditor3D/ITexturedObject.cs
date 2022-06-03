namespace AmbermoonMapEditor3D
{
    internal interface ITexturedObject
    {
        uint Index { get; }
        Bitmap Texture { get; }
        int Width { get; }
        int Height { get; }
        int CurrentFrame { get; }

        event Action FrameChanged;
    }
}
