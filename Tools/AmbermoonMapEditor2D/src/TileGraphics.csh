// The graphics of the tiles: the palettes of Palettes.amb and the 16x16 tile graphics of 1Icon_gfx.amb, 2Icon_gfx.amb
// and 3Icon_gfx.amb, put side by side into one image per tileset and palette (an atlas of 64 graphics per row), and the
// 16x32 graphics of the NPCs (NPC_gfx.amb) in the same way.

using System;
using System.Image;
using System.Ui;
using Ambermoon;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

const int TileSize = 16;
const int AtlasColumns = 64;
const int TileGraphicSize = 160; // 16x16 pixels, 5 bit planes, the planes of each row one after another
const int NPCGraphicSize = 320;  // 16x32 pixels in the same format

struct TileGraphics
{
    /// The palettes (palette 1 is index 0): 32 colors as ARGB, color 0 is transparent.
    List<uint32[]> Palettes;
    /// The graphics data per tileset (number of the tileset -> the data of its Icon_gfx file).
    Dictionary<uint32, uint8[]> GraphicData;
    /// The graphics of the NPCs per file of NPC_gfx.amb: the data of the file and where the first frame of each
    /// graphic starts.
    Dictionary<uint32, uint8[]> NPCData;
    Dictionary<uint32, List<int>> NPCOffsets;
    /// The atlases made so far: (tileset << 8 | palette) -> image, NPC graphics with 0x10000 added.
    Dictionary<uint32, Image> _atlases;

    static TileGraphics Create(GameData gameData)
    {
        var graphics = TileGraphics
        {
            Palettes = List<uint32[]>.Create(),
            GraphicData = Dictionary<uint32, uint8[]>.Create(),
            NPCData = Dictionary<uint32, uint8[]>.Create(),
            NPCOffsets = Dictionary<uint32, List<int>>.Create(),
            _atlases = Dictionary<uint32, Image>.Create()
        };
        if (gameData.Files.TryGet("Palettes.amb") is FileContainer palettes)
        {
            foreach (var number in palettes.Numbers())
            {
                var data = palettes.Files[number].ToArray();
                var colors = new uint32[32];
                for (var i = 0; i < 32 && 2 * i + 1 < data.Length; i += 1)
                {
                    int color = ((int)data[2 * i] << 8) | (int)data[2 * i + 1];
                    uint32 r = (uint32)((color >> 8) & 0xf) * 17;
                    uint32 g = (uint32)((color >> 4) & 0xf) * 17;
                    uint32 b = (uint32)(color & 0xf) * 17;
                    colors[i] = i == 0 ? (uint32)0 : 0xff000000 | (r << 16) | (g << 8) | b;
                }
                graphics.Palettes.Add(colors);
            }
        }
        for (var f = 1; f <= 3; f += 1)
        {
            if (gameData.Files.TryGet($"{f}Icon_gfx.amb") is not FileContainer container)
                continue;
            foreach (var number in container.Numbers())
            {
                var data = container.Files[number].ToArray();
                if (data.Length > 0 && !graphics.GraphicData.ContainsKey((uint32)number))
                    graphics.GraphicData[(uint32)number] = data;
            }
        }
        // NPC_gfx.amb: per graphic the number of its frames (a byte, then aligned to a word) and the frames
        if (gameData.Files.TryGet("NPC_gfx.amb") is FileContainer npcs)
        {
            foreach (var number in npcs.Numbers())
            {
                var data = npcs.Files[number].ToArray();
                var offsets = List<int>.Create();
                int position = 0;
                while (position < data.Length)
                {
                    int frames = (int)data[position];
                    if (frames == 0)
                        break;
                    position += 2;
                    if (position + NPCGraphicSize > data.Length)
                        break;
                    offsets.Add(position);
                    position += frames * NPCGraphicSize;
                }
                graphics.NPCData[(uint32)number] = data;
                graphics.NPCOffsets[(uint32)number] = offsets;
            }
        }
        return graphics;
    }

    /// The number of NPC graphics of a file of NPC_gfx.amb.
    int NPCGraphicCount(uint32 file)
    {
        if (NPCOffsets.TryGet(file) is List<int> offsets)
            return offsets.Count();
        return 0;
    }

    /// The first frames of the NPC graphics of a file in a palette: graphic i is at (i % 64 * 16, i / 64 * 32).
    Image NPCAtlas(uint32 file, uint32 palette)
    {
        uint32 key = 0x10000 + ((file << 8) | (palette & 0xff));
        if (_atlases.TryGet(key) is Image known)
            return known;
        int count = NPCGraphicCount(file);
        int rows = Math.Max(1, (count + AtlasColumns - 1) / AtlasColumns);
        var image = Image.Create(AtlasColumns * TileSize, rows * 2 * TileSize);
        var colors = _Colors(palette);
        if (NPCData.TryGet(file) is uint8[] data && NPCOffsets.TryGet(file) is List<int> offsets)
        {
            for (var g = 0; g < count; g += 1)
                _Decode(data, offsets[g], 2 * TileSize, image, (g % AtlasColumns) * TileSize, (g / AtlasColumns) * 2 * TileSize, colors);
        }
        _atlases[key] = image;
        return image;
    }

    /// The number of graphics of a tileset.
    int GraphicCount(uint32 tileset)
    {
        if (GraphicData.TryGet(tileset) is uint8[] data)
            return data.Length / TileGraphicSize;
        return 0;
    }

    /// The atlas of a tileset in a palette (1-based numbers): graphic i is at (i % 64, i / 64) * 16.
    Image Atlas(uint32 tileset, uint32 palette)
    {
        uint32 key = (tileset << 8) | (palette & 0xff);
        if (_atlases.TryGet(key) is Image known)
            return known;
        int count = GraphicCount(tileset);
        int rows = Math.Max(1, (count + AtlasColumns - 1) / AtlasColumns);
        var image = Image.Create(AtlasColumns * TileSize, rows * TileSize);
        var colors = _Colors(palette);
        if (GraphicData.TryGet(tileset) is uint8[] data)
        {
            for (var g = 0; g < count; g += 1)
                _Decode(data, g * TileGraphicSize, TileSize, image, (g % AtlasColumns) * TileSize, (g / AtlasColumns) * TileSize, colors);
        }
        _atlases[key] = image;
        return image;
    }

    uint32[] _Colors(uint32 palette)
    {
        return palette >= 1 && (int)palette <= Palettes.Count() ? Palettes[(int)palette - 1] : _GrayPalette();
    }

    // a graphic 16 pixels wide with 5 bit planes (the planes of each row one after another) into the image
    static void _Decode(uint8[] data, int offset, int rows, Image image, int baseX, int baseY, uint32[] colors)
    {
        for (var y = 0; y < rows; y += 1)
        {
            for (var x = 0; x < TileSize; x += 1)
            {
                int value = 0;
                int bit = 7 - (x & 7);
                for (var p = 0; p < 5; p += 1)
                {
                    int at = offset + (y * 5 + p) * 2 + (x >> 3);
                    value |= (((int)data[at] >> bit) & 1) << p;
                }
                image.Pixels[(baseY + y) * image.Width + baseX + x] = colors[value];
            }
        }
    }

    /// The color of a palette (1-based) as ARGB, for the minimap colors of the tiles.
    uint32 PaletteColor(uint32 palette, int index)
    {
        if (palette < 1 || (int)palette > Palettes.Count() || index < 0 || index > 31)
            return 0xff000000;
        return Palettes[(int)palette - 1][index] | 0xff000000;
    }

    /// Forgets the atlases (after the graphics of a tile changed).
    void Forget()
    {
        _atlases.Clear();
    }

    static uint32[] _GrayPalette()
    {
        var colors = new uint32[32];
        for (var i = 1; i < 32; i += 1)
        {
            uint32 v = (uint32)(i * 8);
            colors[i] = 0xff000000 | (v << 16) | (v << 8) | v;
        }
        return colors;
    }
}

/// The part of an atlas with a graphic (0-based index).
Rect GraphicRect(int graphic)
{
    return Rect.Create((graphic % AtlasColumns) * TileSize, (graphic / AtlasColumns) * TileSize, TileSize, TileSize);
}

/// The part of the NPC atlas with a graphic (0-based index).
Rect NPCGraphicRect(int graphic)
{
    return Rect.Create((graphic % AtlasColumns) * TileSize, (graphic / AtlasColumns) * 2 * TileSize, TileSize, 2 * TileSize);
}
