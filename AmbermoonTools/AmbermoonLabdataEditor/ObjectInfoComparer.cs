using Ambermoon.Data;
using System.Diagnostics.CodeAnalysis;

namespace AmbermoonLabdataEditor
{
    internal class ObjectInfoComparer : EqualityComparer<Labdata.ObjectInfo>
    {
        public override bool Equals(Labdata.ObjectInfo x, Labdata.ObjectInfo y)
        {
            return x.TextureIndex == y.TextureIndex &&
                x.MappedTextureWidth == y.MappedTextureWidth &&
                x.MappedTextureHeight == y.MappedTextureHeight &&
                x.TextureWidth == y.TextureWidth &&
                x.TextureHeight == y.TextureHeight &&
                x.ColorIndex == y.ColorIndex &&
                x.Flags == y.Flags &&
                x.NumAnimationFrames == y.NumAnimationFrames;
        }

        public override int GetHashCode([DisallowNull] Labdata.ObjectInfo obj)
        {
            return HashCode.Combine(obj.TextureIndex, obj.MappedTextureWidth, obj.MappedTextureHeight,
                obj.TextureWidth, obj.TextureHeight, obj.ColorIndex, obj.Flags, obj.NumAnimationFrames);
        }
    }
}
