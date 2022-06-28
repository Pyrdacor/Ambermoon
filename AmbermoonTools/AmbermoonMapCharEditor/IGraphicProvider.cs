namespace AmbermoonMapCharEditor
{
    public interface IGraphicProvider
    {
        Bitmap GetNPCGraphic(uint fileIndex, uint index);
        Bitmap GetTileGraphic(uint tilesetIndex, uint index);
        Bitmap GetCombatBackgroundGraphic(bool mapIs3D, uint index);
        Bitmap GetObject3DGraphic(uint index);
        int GetNPCGraphicCount(uint fileIndex);
        int GetTileGraphicCount(uint tilesetIndex);
        int GetObject3DGraphicCount();
    }
}
