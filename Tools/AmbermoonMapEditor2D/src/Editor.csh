// The state of the editor: the game data, the map that is edited, the tools, and the history for undo and redo.

using System;
using System.Ui;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

enum Tool : int32
{
    Brush,
    Blocks2x2,
    Blocks3x2,
    Blocks3x3,
    Fill,
    Eraser,
    ColorPicker,
    EventChanger,
    EventRepeater,
    PositionPicker
}

enum Layer : int32
{
    Back,
    Front
}

/// What can be undone: the parts of the map that the editor changes (the tiles are copies).
struct Snapshot
{
    MapTile[] Tiles;
    int Width;
    int Height;
    MapFlags Flags;
    uint32 MusicIndex;
    uint32 TilesetIndex;
    uint32 PaletteIndex;
    uint32 NPCGfxIndex;
    World World;
    Optional<CharacterReference>[] Characters;
    string Name;
}

const int HistorySize = 128;

struct Editor
{
    // ---- game data ----
    string GameDataPath;
    bool GameDataLoaded;
    GameData GameData;
    MapManager Maps;
    TileGraphics Graphics;
    /// The 2D maps of the game data (index and name) for the open dialog.
    List<uint32> MapIndices;
    List<string> MapNames;
    List<string> SongNames;

    // ---- the map ----
    bool MapLoaded;
    Map Map;
    /// The original data of the map (null for a new map): parts the reader does not keep are taken from it.
    uint8[] OriginalMapData;
    /// The container the map belongs to (1, 2 or 3 for 1Map_data.amb ...).
    int MapFile;
    bool CharactersChanged;
    /// The tilesets that were edited (saved to Icon_data.amb with the map).
    List<uint32> ChangedTilesets;

    // ---- history ----
    List<Snapshot> Undo;
    List<Snapshot> Redo;
    int ChangeCounter;
    int SavedAtChange;

    // ---- tools and view ----
    Tool Tool;
    Layer Layer;
    int SelectedTile;          // 1-based tile index of the tileset (0: none)
    int LastEventId;
    bool ShowBack;
    bool ShowFront;
    bool ShowGrid;
    bool ShowEvents;
    bool ShowCharacters;
    bool[] ShowCollision;      // per travel type: tiles that do not allow it are marked
    bool MarkUnused;
    bool Animate;
    int Zoom;                  // 1 to 4: 16 to 64 pixels per tile
    int TilesetZoom;
    int HoverX;
    int HoverY;                // the tile under the mouse (-1: none)
    int HoverTile;             // the tile of the tileset under the mouse (0: none)
    double Time;
    int SelectedCharacter;
    bool Painting;             // a stroke of the brush is going on (one undo step)

    // ---- dialogs ----
    bool ShowOpenGameData;
    bool ShowOpenMap;
    bool ShowNewMap;
    bool ShowSaveFile;
    bool ShowEditTile;
    bool ShowEventSelect;
    bool ShowResize;
    bool ShowUnsaved;
    bool ShowMessage;
    bool ShowOpenFile;
    string Message;
    int PendingAction;         // what to do after the unsaved changes dialog: 1 open map, 2 new map, 3 quit, 4 open game data
    string FilePath;
    int DialogIndex;
    int DialogType;            // new map: 0 indoor, 1 world map, 2 dungeon
    int DialogWorld;
    int DialogWidth;
    int DialogHeight;
    int DialogSelection;
    TilesetTile EditTile;
    int EditTileIndex;
    int EventTileX;
    int EventTileY;
    bool Quit;
    string Status;

    static Editor Create()
    {
        var showCollision = new bool[16];
        return Editor
        {
            GameDataPath = "",
            MapIndices = List<uint32>.Create(),
            MapNames = List<string>.Create(),
            SongNames = List<string>.Create(),
            ChangedTilesets = List<uint32>.Create(),
            Undo = List<Snapshot>.Create(),
            Redo = List<Snapshot>.Create(),
            SelectedTile = 1,
            ShowBack = true,
            ShowFront = true,
            ShowCollision = showCollision,
            Animate = true,
            Zoom = 2,
            TilesetZoom = 2,
            HoverX = -1,
            HoverY = -1,
            SelectedCharacter = -1,
            FilePath = "",
            Message = "",
            Status = "",
            DialogWidth = 50,
            DialogHeight = 50
        };
    }

    bool Dirty()
    {
        return MapLoaded && (ChangeCounter != SavedAtChange || ChangedTilesets.Count() > 0);
    }

    // ---- game data ----

    /// Loads the game data of a folder (the folder Amberfiles of an installation, or a folder with the files).
    /// @error files are missing.
    Error<void> LoadGameData(string path)
    {
        var gameData = GameData.Create(LoadPreference.PreferExtracted, false);
        try gameData.Load(path);
        foreach (var name in ["Icon_data.amb", "1Icon_gfx.amb", "Palettes.amb", "1Map_data.amb"])
        {
            if (!gameData.Files.ContainsKey(name))
                return error($"The file {name} was not found in '{path}'.");
        }
        Maps = try MapManager.Create(gameData);
        GameData = gameData;
        GameDataPath = path;
        GameDataLoaded = true;
        Graphics = TileGraphics.Create(gameData);
        MapLoaded = false;
        _ListMaps();
        _ListSongs();
        return;
    }

    void _ListMaps()
    {
        MapIndices.Clear();
        MapNames.Clear();
        foreach (var index in Maps.MapIndices())
        {
            if (Maps.GetMap(index) is not Optional<Map> found)
                continue;
            if (found is not Map map)
                continue;
            if (map.Type != MapType.Map2D)
                continue;
            MapIndices.Add(index);
            string name = map.Name();
            MapNames.Add(name.Length == 0 ? $"{index:D3}" : $"{index:D3} {name}");
        }
    }

    void _ListSongs()
    {
        SongNames.Clear();
        for (var i = 0; i < 64; i += 1)
        {
            string name = EnumText((Song)(uint8)i, false);
            if (name.Length == 0 || (i > 0 && name == i.ToString()))
                break;
            SongNames.Add($"{i}: {name}");
        }
    }

    Tileset CurrentTileset()
    {
        if (Maps.Tilesets.TryGet(Map.TilesetOrLabdataIndex) is Tileset tileset)
            return tileset;
        return Tileset { Index = Map.TilesetOrLabdataIndex, Tiles = new TilesetTile[0] };
    }

    // ---- maps ----

    /// Opens a 2D map of the game data.
    /// @error the map is missing or no 2D map.
    Error<void> OpenMap(uint32 index)
    {
        if (try Maps.GetMap(index) is not Map map)
            return error($"There is no map {index}.");
        if (map.Type != MapType.Map2D)
            return error($"Map {index} is no 2D map.");
        int file = 0;
        uint8[] original = new uint8[0];
        for (var f = 1; f <= 3 && file == 0; f += 1)
        {
            if (GameData.Files.TryGet($"{f}Map_data.amb") is FileContainer container && container.Files.TryGet((int)index) is DataReader reader && reader.Size() > 0)
            {
                file = f;
                original = reader.ToArray();
            }
        }
        _SetMap(map, file);
        OriginalMapData = original;
        return;
    }

    /// Makes a new 2D map (type 0 indoor, 1 world map, 2 dungeon).
    void NewMap(uint32 index, int type, World world, int width, int height)
    {
        var map = Map.Create(index);
        map.Type = MapType.Map2D;
        map.World = world;
        map.Width = type == 1 ? 50 : width;
        map.Height = type == 1 ? 50 : height;
        map.TilesetOrLabdataIndex = 1;
        map.PaletteIndex = 1;
        if (type == 0)
        {
            map.Flags = MapFlags.Indoor | MapFlags.CanUseMagic;
            map.MusicIndex = (uint32)Song.DontLookBach;
            map.NPCGfxIndex = 1 + (uint32)world % 2;
        }
        else if (type == 1)
        {
            map.Flags = MapFlags.Outdoor | MapFlags.WorldSurface | MapFlags.StationaryGraphics | MapFlags.Unknown1 | MapFlags.CanRest | MapFlags.CanUseMagic;
            map.MusicIndex = (uint32)Song.PloddingAlong;
            map.NPCGfxIndex = 0;
        }
        else
        {
            map.Flags = MapFlags.Dungeon | MapFlags.CanRest | MapFlags.NoSleepUntilDawn | MapFlags.CanUseMagic;
            map.MusicIndex = (uint32)Song.SapphireFireballsOfPureLove;
            map.NPCGfxIndex = 1 + (uint32)world % 2;
        }
        map.Tiles = new MapTile[map.Width * map.Height];
        for (var i = 0; i < map.Tiles.Length; i += 1)
            map.Tiles[i] = MapTile { BackTileIndex = 1 };
        _SetMap(map, index <= 256 ? 1 : index >= 300 && index < 400 ? 3 : 2);
        OriginalMapData = new uint8[0];
        ChangeCounter = 1; // a new map is not saved yet
    }

    void _SetMap(Map map, int file)
    {
        map.Tiles = map.Tiles.Clone();
        map.CharacterReferences = map.CharacterReferences.Clone();
        Map = map;
        MapFile = file;
        MapLoaded = true;
        CharactersChanged = false;
        ChangedTilesets.Clear();
        Undo.Clear();
        Redo.Clear();
        ChangeCounter = 0;
        SavedAtChange = 0;
        HoverX = -1;
        HoverY = -1;
        SelectedCharacter = -1;
        Painting = false;
    }

    /// The data of the map as it is stored. Parts the reader does not keep are taken from the original data when they
    /// did not change: the 320 bytes of the character references (unused references can hold data).
    /// @error the map cannot be written.
    Error<uint8[]> MapData()
    {
        var writer = new DataWriter();
        try MapWriter.WriteMap(Map, ref writer);
        var data = writer.ToArray();
        if (!CharactersChanged && OriginalMapData != null && OriginalMapData.Length >= 332 && data.Length >= 332)
            Array.Copy(OriginalMapData, 12, data, 12, 320);
        return data;
    }

    /// Saves the map (and the changed tilesets) into the game data.
    /// @error a file cannot be written.
    Error<void> SaveToGameData()
    {
        var data = try MapData();
        int index = (int)Map.Index;
        try ReplaceSubfile(Path.Combine(GameDataPath, $"{MapFile}Map_data.amb"), index, data);
        // the game loads the texts of every map: the container of the texts must have a file for it (empty or not)
        var textsPath = Path.Combine(GameDataPath, $"{MapFile}Map_texts.amb");
        if (File.Exists(textsPath))
            try EnsureSubfileCount(textsPath, index);
        foreach (var tileset in ChangedTilesets)
        {
            if (Maps.Tilesets.TryGet(tileset) is Tileset changed)
                try ReplaceSubfile(Path.Combine(GameDataPath, "Icon_data.amb"), (int)tileset, WriteTileset(changed));
        }
        ChangedTilesets.Clear();
        OriginalMapData = data;
        CharactersChanged = false;
        SavedAtChange = ChangeCounter;
        // the game data on disk changed: read it again for the list of maps
        var reloaded = GameData.Create(LoadPreference.PreferExtracted, false);
        if (reloaded.Load(GameDataPath) is not error)
        {
            GameData = reloaded;
            var tilesets = Maps.Tilesets;
            if (MapManager.Create(reloaded) is MapManager maps)
            {
                Maps = maps;
                Maps.Tilesets = tilesets;
            }
            _ListMaps();
        }
        return;
    }

    /// Saves the data of the map into a file of its own.
    /// @error the file cannot be written.
    Error<void> SaveToFile(string path)
    {
        var data = try MapData();
        if (File.WriteAllBytes(path, data) is error)
            return error($"Could not write '{path}'.");
        return;
    }

    // ---- history ----

    Snapshot TakeSnapshot()
    {
        return Snapshot
        {
            Tiles = Map.Tiles.Clone(),
            Width = Map.Width,
            Height = Map.Height,
            Flags = Map.Flags,
            MusicIndex = Map.MusicIndex,
            TilesetIndex = Map.TilesetOrLabdataIndex,
            PaletteIndex = Map.PaletteIndex,
            NPCGfxIndex = Map.NPCGfxIndex,
            World = Map.World,
            Characters = _CloneCharacters(Map.CharacterReferences)
        };
    }

    static Optional<CharacterReference>[] _CloneCharacters(Optional<CharacterReference>[] characters)
    {
        var copy = new Optional<CharacterReference>[characters.Length];
        for (var i = 0; i < characters.Length; i += 1)
        {
            if (characters[i] is CharacterReference reference)
            {
                var positions = List<Position>.Create();
                foreach (var position in reference.Positions)
                    positions.Add(position);
                reference.Positions = positions;
                copy[i] = reference;
            }
        }
        return copy;
    }

    void _Restore(Snapshot snapshot)
    {
        Map.Tiles = snapshot.Tiles.Clone();
        Map.Width = snapshot.Width;
        Map.Height = snapshot.Height;
        Map.Flags = snapshot.Flags;
        Map.MusicIndex = snapshot.MusicIndex;
        Map.TilesetOrLabdataIndex = snapshot.TilesetIndex;
        Map.PaletteIndex = snapshot.PaletteIndex;
        Map.NPCGfxIndex = snapshot.NPCGfxIndex;
        Map.World = snapshot.World;
        Map.CharacterReferences = _CloneCharacters(snapshot.Characters);
    }

    /// Remembers the state before a change (one undo step) and counts the change.
    void BeginChange()
    {
        Undo.Add(TakeSnapshot());
        if (Undo.Count() > HistorySize)
            Undo.RemoveAt(0);
        Redo.Clear();
        ChangeCounter += 1;
    }

    void DoUndo()
    {
        if (Undo.Count() == 0)
            return;
        Redo.Add(TakeSnapshot());
        var snapshot = Undo[Undo.Count() - 1];
        Undo.RemoveAt(Undo.Count() - 1);
        _Restore(snapshot);
        ChangeCounter -= 1;
        CharactersChanged = true;
    }

    void DoRedo()
    {
        if (Redo.Count() == 0)
            return;
        Undo.Add(TakeSnapshot());
        var snapshot = Redo[Redo.Count() - 1];
        Redo.RemoveAt(Redo.Count() - 1);
        _Restore(snapshot);
        ChangeCounter += 1;
        CharactersChanged = true;
    }

    // ---- tiles ----

    bool InMap(int x, int y)
    {
        return x >= 0 && y >= 0 && x < Map.Width && y < Map.Height;
    }

    uint32 GetLayer(int x, int y, Layer layer)
    {
        var tile = Map.Tiles[x + y * Map.Width];
        return layer == Layer.Back ? tile.BackTileIndex : tile.FrontTileIndex;
    }

    void SetLayer(int x, int y, Layer layer, uint32 value)
    {
        int i = x + y * Map.Width;
        var tile = Map.Tiles[i];
        if (layer == Layer.Back)
            tile.BackTileIndex = value;
        else
            tile.FrontTileIndex = value;
        Map.Tiles[i] = tile;
    }

    void SetEvent(int x, int y, uint32 eventId)
    {
        int i = x + y * Map.Width;
        var tile = Map.Tiles[i];
        tile.MapEventId = eventId;
        Map.Tiles[i] = tile;
    }

    static Layer Other(Layer layer)
    {
        return layer == Layer.Back ? Layer.Front : Layer.Back;
    }

    /// The tiles a tool covers at a tile (width and height; 0 for tools without a footprint).
    int FootprintWidth()
    {
        switch (Tool)
        {
            case Tool.Blocks2x2: return 2;
            case Tool.Blocks3x2: return 3;
            case Tool.Blocks3x3: return 3;
            case Tool.Fill: return 0;
            default: return 1;
        }
    }

    int FootprintHeight()
    {
        switch (Tool)
        {
            case Tool.Blocks2x2: return 2;
            case Tool.Blocks3x2: return 2;
            case Tool.Blocks3x3: return 3;
            case Tool.Fill: return 0;
            default: return 1;
        }
    }

    /// Uses the tool at a tile while the mouse button is held (left: primary, right: secondary). The undo step is begun
    /// by the caller when the button goes down.
    void Paint(int x, int y, bool secondary)
    {
        if (!InMap(x, y))
            return;
        switch (Tool)
        {
            case Tool.Brush:
                SetLayer(x, y, secondary ? Other(Layer) : Layer, (uint32)SelectedTile);
                break;
            case Tool.Blocks2x2:
            case Tool.Blocks3x2:
            case Tool.Blocks3x3:
            {
                int w = FootprintWidth();
                int h = FootprintHeight();
                int tile = SelectedTile;
                for (var by = 0; by < h; by += 1)
                {
                    for (var bx = 0; bx < w; bx += 1)
                    {
                        if (InMap(x + bx, y + by))
                            SetLayer(x + bx, y + by, Layer, (uint32)(secondary ? SelectedTile : tile));
                        tile += 1;
                    }
                }
                break;
            }
            case Tool.Eraser:
                SetLayer(x, y, Layer.Front, 0);
                break;
            case Tool.EventRepeater:
                SetEvent(x, y, secondary ? (uint32)0 : (uint32)LastEventId);
                break;
            case Tool.EventChanger:
                if (secondary)
                    SetEvent(x, y, 0);
                break;
            default:
                break;
        }
    }

    /// Fill: the left button replaces the tile everywhere on the map, the right one fills the connected area.
    void Fill(int x, int y, bool connected)
    {
        if (!InMap(x, y))
            return;
        uint32 old = GetLayer(x, y, Layer);
        uint32 value = (uint32)SelectedTile;
        if (old == value)
            return;
        if (!connected)
        {
            for (var ty = 0; ty < Map.Height; ty += 1)
            {
                for (var tx = 0; tx < Map.Width; tx += 1)
                {
                    if (GetLayer(tx, ty, Layer) == old)
                        SetLayer(tx, ty, Layer, value);
                }
            }
            return;
        }
        var stack = List<int>.Create();
        stack.Add(x + y * Map.Width);
        while (stack.Count() > 0)
        {
            int i = stack[stack.Count() - 1];
            stack.RemoveAt(stack.Count() - 1);
            int tx = i % Map.Width;
            int ty = i / Map.Width;
            if (GetLayer(tx, ty, Layer) != old)
                continue;
            SetLayer(tx, ty, Layer, value);
            if (tx > 0) stack.Add(i - 1);
            if (tx < Map.Width - 1) stack.Add(i + 1);
            if (ty > 0) stack.Add(i - Map.Width);
            if (ty < Map.Height - 1) stack.Add(i + Map.Width);
        }
    }

    /// The color picker: takes the tile of the layer (left) or of the other layer (right) and switches to the brush,
    /// to the eraser for an empty front layer.
    void Pick(int x, int y, bool secondary)
    {
        if (!InMap(x, y))
            return;
        var layer = secondary ? Other(Layer) : Layer;
        uint32 tile = GetLayer(x, y, layer);
        if (tile == 0)
        {
            Tool = Tool.Eraser;
            return;
        }
        Layer = layer;
        SelectedTile = (int)tile;
        Tool = Tool.Brush;
    }

    /// Changes the size of the map; new tiles get the back tile 1.
    void Resize(int width, int height)
    {
        if (width == Map.Width && height == Map.Height)
            return;
        BeginChange();
        var tiles = new MapTile[width * height];
        for (var y = 0; y < height; y += 1)
        {
            for (var x = 0; x < width; x += 1)
                tiles[x + y * width] = x < Map.Width && y < Map.Height ? Map.Tiles[x + y * Map.Width] : MapTile { BackTileIndex = 1 };
        }
        Map.Tiles = tiles;
        Map.Width = width;
        Map.Height = height;
    }

    /// Whether a tile of the map blocks a travel type (the front tile decides unless it uses the flags of the back tile).
    bool Blocks(int x, int y, TravelType travelType)
    {
        var tile = Map.Tiles[x + y * Map.Width];
        return !CurrentTileset().AllowMovement(tile.BackTileIndex, tile.FrontTileIndex, travelType);
    }

    /// Whether a tile of the tileset is used on the map (on either layer).
    HashSet<uint32> UsedTiles()
    {
        var used = HashSet<uint32>.Create();
        foreach (var tile in Map.Tiles)
        {
            used.Add(tile.BackTileIndex);
            used.Add(tile.FrontTileIndex);
        }
        return used;
    }

    /// Changes a tile of the tileset (edit tile, duplicate): the tileset is saved with the map.
    void SetTilesetTile(int index, TilesetTile tile)
    {
        if (Maps.Tilesets.TryGet(Map.TilesetOrLabdataIndex) is not Tileset tileset)
            return;
        if (index < 1 || index > tileset.Tiles.Length)
            return;
        tileset.Tiles[index - 1] = tile;
        Maps.Tilesets[Map.TilesetOrLabdataIndex] = tileset;
        if (!ChangedTilesets.Contains(Map.TilesetOrLabdataIndex))
            ChangedTilesets.Add(Map.TilesetOrLabdataIndex);
    }
}
