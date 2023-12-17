using OpenTK.Mathematics;

namespace Ambermoon3DMapEditor
{
    internal class Palette
    {
        public Palette(Color[] colors)
        {
            Colors = colors;
        }

        public Color[] Colors { get; }

        public Color4 this[int index] => Colors[index];
    }
}
