using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;

namespace Ambermoon3DMapEditor
{
    internal class GraphicCache
    {
        public GraphicCache(Graphic palette, GameData gameData)
        {
            this.palette = palette;
            this.gameData = gameData;
        }

        private readonly Graphic palette;
        private readonly GameData gameData;
        private readonly Dictionary<string, Dictionary<uint, Bitmap>> cachedGraphics = new();
        private static readonly Dictionary<string, Func<int, GraphicInfo>> graphicInfoProviders = new()
        {
            { "Wall3D.amb", _ => TextureGraphicInfos.WallGraphicInfo },
            { "Object3D.amb", GetObjectGraphicInfo },
            { "Overlay3D.amb", GetOverlayGraphicInfo },
        };

        private static GraphicInfo GetObjectGraphicInfo(int index) => TextureGraphicInfos.ObjectGraphicInfos[index - 1];

        private static GraphicInfo GetOverlayGraphicInfo(int index) => TextureGraphicInfos.OverlayGraphicInfos[index - 1];

        private Dictionary<uint, Bitmap> LoadGraphics(Map map, string containerBaseName)
        {
            int index = map!.Index >= 300 && map.Index < 400 ? 3 : 2;
            string containerName = $"{index}{containerBaseName}";

            if (cachedGraphics.TryGetValue(containerName, out var graphics))
                return graphics;

            var graphicInfoProvider = graphicInfoProviders[containerBaseName];

            graphics = gameData.Files[containerName].Files.Where(f => f.Value.Size != 0).ToDictionary(f => (uint)f.Key, f => LoadGraphic(f.Value, graphicInfoProvider(f.Key)));
            cachedGraphics.Add(containerName, graphics);

            return graphics;
        }

        private Bitmap LoadGraphic(IDataReader dataReader, GraphicInfo graphicInfo)
        {
            dataReader.Position = 0;
            var graphic = new Graphic();
            new GraphicReader().ReadGraphic(graphic, dataReader, graphicInfo);
            return GraphicHelper.GraphicToBitmap(graphic, palette, graphicInfo.Alpha);
        }

        public Dictionary<uint, Bitmap> GetWallGraphicsForMap(Map map)
        {
            return LoadGraphics(map, "Wall3D.amb");
        }

        public Dictionary<uint, Bitmap> GetObjectGraphicsForMap(Map map)
        {
            return LoadGraphics(map, "Object3D.amb");
        }

        public Dictionary<uint, Bitmap> GetOverlayGraphicsForMap(Map map)
        {
            return LoadGraphics(map, "Overlay3D.amb");
        }
    }
}
