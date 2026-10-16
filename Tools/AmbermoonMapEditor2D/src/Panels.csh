// The side bar (tools, layers, view, map properties, events, characters) and the dialogs.

using System;
using System.Image;
using System.Ui;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

string ToolName(Tool tool)
{
    switch (tool)
    {
        case Tool.Brush: return "Brush";
        case Tool.Blocks2x2: return "Block 2x2";
        case Tool.Blocks3x2: return "Block 3x2";
        case Tool.Blocks3x3: return "Block 3x3";
        case Tool.Fill: return "Fill";
        case Tool.Eraser: return "Eraser";
        case Tool.ColorPicker: return "Picker";
        case Tool.EventChanger: return "Event";
        case Tool.EventRepeater: return "Event repeater";
        case Tool.PositionPicker: return "Position";
        default: return "";
    }
}

string ToolHelp(Tool tool)
{
    switch (tool)
    {
        case Tool.Brush: return "Left: paint the layer, right: paint the other layer (B)";
        case Tool.Blocks2x2:
        case Tool.Blocks3x2:
        case Tool.Blocks3x3: return "Left: the selected tile and the ones after it, right: the selected tile in every cell";
        case Tool.Fill: return "Left: replace the tile everywhere, right: fill the connected area (F)";
        case Tool.Eraser: return "Removes the front tile (E)";
        case Tool.ColorPicker: return "Left: take the tile of the layer, right: of the other layer (P)";
        case Tool.EventChanger: return "Left: choose the event of the tile, right: remove it";
        case Tool.EventRepeater: return "Left: give the tile the last chosen event, right: remove it";
        case Tool.PositionPicker: return "Click: the position of the selected character";
        default: return "";
    }
}

void ToolButton(Ui ui, ref Editor editor, Tool tool)
{
    string label = editor.Tool == tool ? $"[{ToolName(tool)}]" : ToolName(tool);
    if (ui.Button(label + "##tool" + ((int)tool).ToString()))
    {
        editor.Tool = tool;
        if (tool == Tool.EventChanger || tool == Tool.EventRepeater)
            editor.ShowEvents = true;
    }
    ui.Tooltip(ToolHelp(tool));
}

void DrawToolbar(Ui ui, ref Editor editor)
{
    using (ui.Row())
    {
        ToolButton(ui, ref editor, Tool.Brush);
        ToolButton(ui, ref editor, Tool.Blocks2x2);
        ToolButton(ui, ref editor, Tool.Blocks3x2);
        ToolButton(ui, ref editor, Tool.Blocks3x3);
        ToolButton(ui, ref editor, Tool.Fill);
        ToolButton(ui, ref editor, Tool.Eraser);
        ToolButton(ui, ref editor, Tool.ColorPicker);
        ToolButton(ui, ref editor, Tool.EventChanger);
        ToolButton(ui, ref editor, Tool.EventRepeater);
    }
}

string StatusText(ref Editor editor)
{
    string text = $"{ToolName(editor.Tool)} | {(editor.Layer == Layer.Back ? "Back layer" : "Front layer")} | Tile {editor.SelectedTile}";
    if (editor.HoverX >= 0)
    {
        var tile = editor.Map.Tiles[editor.HoverX + editor.HoverY * editor.Map.Width];
        text += $" | Map {editor.HoverX + 1}, {editor.HoverY + 1} [Index {editor.HoverX + editor.HoverY * editor.Map.Width}] back {tile.BackTileIndex} front {tile.FrontTileIndex} event {tile.MapEventId:X2}";
    }
    if (editor.HoverTile > 0)
        text += $" | Tileset tile {editor.HoverTile}";
    return text;
}

bool FlagCheckbox(Ui ui, ref Editor editor, string label, MapFlags flag)
{
    bool value = (editor.Map.Flags & flag) != MapFlags.None;
    if (ui.Checkbox(label, ref value))
    {
        editor.BeginChange();
        editor.Map.Flags = value ? editor.Map.Flags | flag : editor.Map.Flags & ~flag;
        return true;
    }
    return false;
}

List<string> NumberedNames(string prefix, int count)
{
    var names = List<string>.Create(count);
    for (var i = 1; i <= count; i += 1)
        names.Add($"{prefix} {i}");
    return names;
}

/// The side bar: layers, view, properties of the map, events and characters.
void DrawSideBar(Ui ui, ref Editor editor)
{
    using (ui.Scroll("side", 0))
    {
        using (ui.Panel("Layer"))
        {
            int layer = (int)editor.Layer;
            using (ui.Row())
            {
                if (ui.Radio("Back", ref layer, 0) || ui.Radio("Front", ref layer, 1))
                {
                    editor.Layer = (Layer)layer;
                    var tileset = editor.CurrentTileset();
                    if (editor.Layer == Layer.Back && editor.SelectedTile > 256)
                        editor.SelectedTile = 1;
                    if (editor.SelectedTile > tileset.Tiles.Length)
                        editor.SelectedTile = 1;
                }
            }
            ui.Tooltip("The layer that is painted on (Tab switches)");
        }

        using (ui.Panel("View"))
        {
            using (ui.Columns(2))
            {
                ui.Checkbox("Back layer", ref editor.ShowBack);
                ui.Checkbox("Front layer", ref editor.ShowFront);
                ui.Checkbox("Grid", ref editor.ShowGrid);
                ui.Checkbox("Events", ref editor.ShowEvents);
                ui.Checkbox("Characters", ref editor.ShowCharacters);
                ui.Checkbox("Animation", ref editor.Animate);
                ui.Checkbox("Mark unused", ref editor.MarkUnused);
            }
            ui.Note("Mark tiles that block:");
            using (ui.Columns(3))
            {
                ui.Checkbox("Walk", ref editor.ShowCollision[(int)TravelType.Walk]);
                ui.Checkbox("Horse", ref editor.ShowCollision[(int)TravelType.Horse]);
                ui.Checkbox("Raft", ref editor.ShowCollision[(int)TravelType.Raft]);
                ui.Checkbox("Ship", ref editor.ShowCollision[(int)TravelType.Ship]);
                ui.Checkbox("Disc", ref editor.ShowCollision[(int)TravelType.MagicalDisc]);
                ui.Checkbox("Eagle", ref editor.ShowCollision[(int)TravelType.Eagle]);
            }
            using (ui.Row())
            {
                ui.Label("Zoom");
                ui.Slider("zoom", ref editor.Zoom, 1, 4);
            }
            using (ui.Row())
            {
                ui.Label("Tileset zoom");
                ui.Slider("tilesetzoom", ref editor.TilesetZoom, 1, 4);
            }
        }

        DrawMapProperties(ui, ref editor);
        DrawEventList(ui, ref editor);
        DrawCharacterList(ui, ref editor);
    }
}

void DrawMapProperties(Ui ui, ref Editor editor)
{
    using (ui.Panel($"Map {editor.Map.Index}"))
    {
        using (ui.Row())
        {
            ui.Label($"Size {editor.Map.Width} x {editor.Map.Height}");
            bool world = (editor.Map.Flags & MapFlags.WorldSurface) != MapFlags.None;
            if (!world && ui.Button("Resize..."))
            {
                editor.DialogWidth = editor.Map.Width;
                editor.DialogHeight = editor.Map.Height;
                editor.ShowResize = true;
            }
        }

        // the type of the map: indoor, outdoor or dungeon
        int type = (editor.Map.Flags & MapFlags.Indoor) != MapFlags.None ? 0 : (editor.Map.Flags & MapFlags.Outdoor) != MapFlags.None ? 1 : 2;
        using (ui.Row())
        {
            if (ui.Radio("Indoor", ref type, 0) || ui.Radio("Outdoor", ref type, 1) || ui.Radio("Dungeon", ref type, 2))
            {
                editor.BeginChange();
                var flags = editor.Map.Flags & ~(MapFlags.Indoor | MapFlags.Outdoor | MapFlags.Dungeon);
                editor.Map.Flags = flags | (type == 0 ? MapFlags.Indoor : type == 1 ? MapFlags.Outdoor : MapFlags.Dungeon);
            }
        }

        var worlds = List<string>.Create();
        worlds.Add("Lyramion");
        worlds.Add("Forest Moon");
        worlds.Add("Morag");
        int world = (int)editor.Map.World % 3;
        using (ui.Row())
        {
            ui.Label("World");
            if (ui.ComboBox("world", ref world, worlds))
            {
                editor.BeginChange();
                editor.Map.World = (World)(uint8)world;
            }
        }

        int tileset = (int)editor.Map.TilesetOrLabdataIndex - 1;
        var tilesetNames = NumberedNames("Tileset", editor.Maps.Tilesets.Count());
        using (ui.Row())
        {
            ui.Label("Tiles");
            if (ui.ComboBox("tilesetcombo", ref tileset, tilesetNames))
            {
                editor.BeginChange();
                editor.Map.TilesetOrLabdataIndex = (uint32)(tileset + 1);
            }
        }
        int palette = (int)editor.Map.PaletteIndex - 1;
        var paletteNames = NumberedNames("Palette", editor.Graphics.Palettes.Count());
        using (ui.Row())
        {
            ui.Label("Colors");
            if (ui.ComboBox("palettecombo", ref palette, paletteNames))
            {
                editor.BeginChange();
                editor.Map.PaletteIndex = (uint32)(palette + 1);
            }
        }
        int song = Math.Max(0, Math.Min((int)editor.Map.MusicIndex, editor.SongNames.Count() - 1));
        using (ui.Row())
        {
            ui.Label("Music");
            if (editor.SongNames.Count() > 0 && ui.ComboBox("music", ref song, editor.SongNames))
            {
                editor.BeginChange();
                editor.Map.MusicIndex = (uint32)song;
            }
        }
        int npcGfx = (int)editor.Map.NPCGfxIndex;
        using (ui.Row())
        {
            ui.Label("NPC graphics");
            if (ui.IntBox("npcgfx", ref npcGfx, 0, 2))
            {
                editor.BeginChange();
                editor.Map.NPCGfxIndex = (uint32)npcGfx;
            }
        }
        ui.Tooltip("Which file of NPC_gfx.amb the characters use (0: none, world maps)");

        using (ui.Columns(2))
        {
            FlagCheckbox(ui, ref editor, "World map", MapFlags.WorldSurface);
            FlagCheckbox(ui, ref editor, "Travel graphics", MapFlags.StationaryGraphics);
            FlagCheckbox(ui, ref editor, "Allow resting", MapFlags.CanRest);
            FlagCheckbox(ui, ref editor, "No sleep until dawn", MapFlags.NoSleepUntilDawn);
            FlagCheckbox(ui, ref editor, "Allow magic", MapFlags.CanUseMagic);
            FlagCheckbox(ui, ref editor, "Automapper", MapFlags.Automapper);
            FlagCheckbox(ui, ref editor, "Sky", MapFlags.Sky);
            FlagCheckbox(ui, ref editor, "No travel music", MapFlags.NoTravelMusic);
            FlagCheckbox(ui, ref editor, "No mark/return", MapFlags.NoMarkOrReturn);
            FlagCheckbox(ui, ref editor, "No eagle/broom", MapFlags.NoEagleOrBroom);
            FlagCheckbox(ui, ref editor, "Unknown 1", MapFlags.Unknown1);
            FlagCheckbox(ui, ref editor, "Unknown 2", MapFlags.Unknown2);
        }
    }
}

void DrawEventList(Ui ui, ref Editor editor)
{
    using (ui.Panel($"Events ({editor.Map.EventList.Count()})"))
    {
        using (ui.Scroll("events", 140))
        {
            for (var i = 0; i < editor.Map.EventList.Count(); i += 1)
            {
                var e = editor.Map.Events.Get(editor.Map.EventList[i]);
                using (ui.Id(i))
                {
                    if (ui.ListItem($"{i + 1:X2}: {e.ToString()}", editor.LastEventId == i + 1))
                    {
                        editor.LastEventId = i + 1;
                        editor.Tool = Tool.EventRepeater;
                        editor.ShowEvents = true;
                    }
                    ui.Tooltip("Click: paint this event with the event repeater");
                }
            }
        }
    }
}

string CharacterText(CharacterReference reference)
{
    string type = reference.Type == CharacterType.Monster ? "Monster group" : reference.Type == CharacterType.NPC ? "NPC" :
                  reference.Type == CharacterType.PartyMember ? "Party member" : "Map object";
    string position = reference.Positions.Count() > 0 ? $"{reference.Positions[0].X}, {reference.Positions[0].Y}" : "-";
    return $"{type} {reference.Index}, graphic {reference.GraphicIndex}, at {position}";
}

void DrawCharacterList(Ui ui, ref Editor editor)
{
    using (ui.Panel("Monsters and NPCs"))
    {
        bool any = false;
        for (var i = 0; i < editor.Map.CharacterReferences.Length; i += 1)
        {
            if (editor.Map.CharacterReferences[i] is not CharacterReference reference)
                continue;
            any = true;
            using (ui.Id(i))
            {
                if (ui.ListItem($"{i + 1}: {CharacterText(reference)}", editor.SelectedCharacter == i))
                    editor.SelectedCharacter = i;
            }
        }
        if (!any)
            ui.Note("none");
        if (editor.SelectedCharacter >= 0)
        {
            if (ui.Button("Place on map"))
            {
                editor.Tool = Tool.PositionPicker;
                editor.ShowCharacters = true;
            }
            ui.Tooltip("The next click on the map sets the (first) position of the character");
        }
    }
}

// ---- dialogs ----

void MessageDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("message", "Ambermoon Map Editor"))
    {
        ui.Text(editor.Message);
        if (ui.Button("OK") || ui.Input().Pressed(Key.Enter) || ui.Input().Pressed(Key.Escape))
            editor.ShowMessage = false;
    }
}

void ShowError(ref Editor editor, string text)
{
    editor.Message = text;
    editor.ShowMessage = true;
}

void OpenGameDataDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("gamedata", "Open game data"))
    {
        ui.Text("The folder with the files of the game (Amberfiles of an installation, or the extracted files):");
        using (ui.Row())
        {
            ui.TextBox("gamedatapath", ref editor.FilePath);
            if (ui.Button("Browse..."))
                editor.ShowOpenFile = true;
        }
        using (ui.Row())
        {
            if (ui.Button("Open") || ui.Submitted("gamedatapath"))
            {
                string path = editor.FilePath.Trim().ToString();
                if (File.Exists(path))
                    path = Path.GetDirectory(path);
                if (editor.LoadGameData(path) is error e)
                    ShowError(ref editor, e.Message);
                else
                {
                    editor.ShowOpenGameData = false;
                    editor.ShowOpenMap = true;
                    SaveConfig(editor.GameDataPath);
                }
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowOpenGameData = false;
        }
    }
    if (editor.ShowOpenFile)
    {
        var result = ui.FileDialog("gamedatafile", "Choose a file of the game data (e.g. Icon_data.amb)", ref editor.FilePath);
        if (result != UiDialogResult.None)
            editor.ShowOpenFile = false;
        if (result == UiDialogResult.Ok)
            editor.FilePath = Path.GetDirectory(editor.FilePath);
    }
}

void OpenMapDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("openmap", "Open map"))
    {
        ui.Note($"The 2D maps of {editor.GameDataPath}");
        using (ui.Scroll("maplist", 300))
        {
            for (var i = 0; i < editor.MapIndices.Count(); i += 1)
            {
                using (ui.Id(i))
                {
                    if (ui.ListItem(editor.MapNames[i], editor.DialogSelection == i))
                        editor.DialogSelection = i;
                }
            }
        }
        using (ui.Row())
        {
            bool open = ui.Button("Open") || ui.Input().Pressed(Key.Enter);
            if (open && editor.DialogSelection >= 0 && editor.DialogSelection < editor.MapIndices.Count())
            {
                if (editor.OpenMap(editor.MapIndices[editor.DialogSelection]) is error e)
                    ShowError(ref editor, e.Message);
                editor.ShowOpenMap = false;
            }
            if (ui.Button("New map..."))
            {
                editor.ShowOpenMap = false;
                editor.DialogIndex = 0;
                editor.ShowNewMap = true;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowOpenMap = false;
        }
    }
}

void NewMapDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("newmap", "New map"))
    {
        using (ui.Row())
        {
            ui.Label("Map index");
            using (ui.Column(100))
            {
                ui.IntBox("newindex", ref editor.DialogIndex, 1, 1023);
            }
        }
        ui.Note("1-256: 1Map_data.amb, 300-399: 3Map_data.amb, others: 2Map_data.amb");
        using (ui.Row())
        {
            ui.Radio("Indoor", ref editor.DialogType, 0);
            ui.Radio("World map", ref editor.DialogType, 1);
            ui.Radio("Dungeon", ref editor.DialogType, 2);
        }
        var worlds = List<string>.Create();
        worlds.Add("Lyramion");
        worlds.Add("Forest Moon");
        worlds.Add("Morag");
        using (ui.Row())
        {
            ui.Label("World");
            ui.ComboBox("newworld", ref editor.DialogWorld, worlds);
        }
        if (editor.DialogType != 1)
        {
            using (ui.Row())
            {
                ui.Label("Size");
                using (ui.Column(80)) { ui.IntBox("newwidth", ref editor.DialogWidth, 11, 200); }
                ui.Label("x");
                using (ui.Column(80)) { ui.IntBox("newheight", ref editor.DialogHeight, 9, 200); }
            }
        }
        bool exists = editor.MapIndices.Contains((uint32)editor.DialogIndex);
        if (exists)
            ui.Note($"Map {editor.DialogIndex} exists already.");
        using (ui.Row())
        {
            if (ui.Button("Create") && editor.DialogIndex > 0 && !exists)
            {
                editor.NewMap((uint32)editor.DialogIndex, editor.DialogType, (World)(uint8)editor.DialogWorld, editor.DialogWidth, editor.DialogHeight);
                editor.ShowNewMap = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowNewMap = false;
        }
    }
}

void ResizeDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("resize", "Resize the map"))
    {
        using (ui.Row())
        {
            ui.Label("Width");
            using (ui.Column(80)) { ui.IntBox("rwidth", ref editor.DialogWidth, 11, 200); }
            ui.Label("Height");
            using (ui.Column(80)) { ui.IntBox("rheight", ref editor.DialogHeight, 9, 200); }
        }
        ui.Note("New tiles get back tile 1; tiles outside of the new size are removed.");
        using (ui.Row())
        {
            if (ui.Button("Resize"))
            {
                editor.Resize(editor.DialogWidth, editor.DialogHeight);
                editor.ShowResize = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowResize = false;
        }
    }
}

void EventSelectDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("eventselect", $"Event of tile {editor.EventTileX + 1}, {editor.EventTileY + 1}"))
    {
        using (ui.Scroll("eventchoices", 300))
        {
            if (ui.ListItem("00: <none>", editor.DialogSelection == 0))
                editor.DialogSelection = 0;
            for (var i = 0; i < editor.Map.EventList.Count(); i += 1)
            {
                var e = editor.Map.Events.Get(editor.Map.EventList[i]);
                using (ui.Id(i))
                {
                    if (ui.ListItem($"{i + 1:X2}: {e.ToString()}", editor.DialogSelection == i + 1))
                        editor.DialogSelection = i + 1;
                }
            }
        }
        using (ui.Row())
        {
            if (ui.Button("OK") || ui.Input().Pressed(Key.Enter))
            {
                editor.BeginChange();
                editor.SetEvent(editor.EventTileX, editor.EventTileY, (uint32)editor.DialogSelection);
                if (editor.DialogSelection > 0)
                    editor.LastEventId = editor.DialogSelection;
                editor.ShowEventSelect = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowEventSelect = false;
        }
    }
}

bool TileFlag(Ui ui, ref TilesetTile tile, string label, TileFlags flag)
{
    bool value = (tile.Flags & flag) != TileFlags.None;
    if (ui.Checkbox(label, ref value))
    {
        tile.Flags = value ? tile.Flags | flag : tile.Flags & ~flag;
        return true;
    }
    return false;
}

void EditTileDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("edittile", $"Tile {editor.EditTileIndex} of tileset {editor.Map.TilesetOrLabdataIndex}"))
    {
        var tile = editor.EditTile;
        using (ui.Row())
        {
            // a preview of the tile at four times its size
            var preview = ui.Area(64, 64);
            var atlas = editor.Graphics.Atlas(editor.Map.TilesetOrLabdataIndex, editor.Map.PaletteIndex);
            int graphic = AnimatedGraphic(tile, AnimationFrame(ref editor));
            ui.FillRect(preview, Color.Black());
            if (graphic >= 0 && graphic < editor.Graphics.GraphicCount(editor.Map.TilesetOrLabdataIndex))
                ui.DrawImage(atlas, GraphicRect(graphic), preview);
            using (ui.Column(0))
            {
                int graphicIndex = (int)tile.GraphicIndex;
                using (ui.Row())
                {
                    ui.Label("Graphic");
                    using (ui.Column(90))
                    {
                        if (ui.IntBox("tgraphic", ref graphicIndex, 0, 4000))
                            tile.GraphicIndex = (uint32)graphicIndex;
                    }
                    ui.Label("Frames");
                    using (ui.Column(70))
                    {
                        ui.IntBox("tframes", ref tile.NumAnimationFrames, 1, 16);
                    }
                }
                int color = (int)tile.ColorIndex;
                using (ui.Row())
                {
                    ui.Label("Minimap color");
                    using (ui.Column(70))
                    {
                        if (ui.IntBox("tcolor", ref color, 0, 31))
                            tile.ColorIndex = (uint8)color;
                    }
                    var swatch = ui.Area(20, 20);
                    ui.FillRect(swatch, Color.FromArgb(editor.Graphics.PaletteColor(editor.Map.PaletteIndex, color)));
                }
            }
        }

        using (ui.Columns(3))
        {
            TileFlag(ui, ref tile, "Block all movement", TileFlags.BlockAllMovement);
            TileFlag(ui, ref tile, "Alternate animation", TileFlags.WaveAnimation);
            TileFlag(ui, ref tile, "Random animation start", TileFlags.RandomAnimationStart);
            TileFlag(ui, ref tile, "Use back tile flags", TileFlags.UseBackgroundTileFlags);
            TileFlag(ui, ref tile, "Block sight", TileFlags.BlockSight);
            TileFlag(ui, ref tile, "Floor", TileFlags.Floor);
            TileFlag(ui, ref tile, "Hide player", TileFlags.PlayerInvisible);
            TileFlag(ui, ref tile, "Auto poison", TileFlags.AutoPoison);
        }
        ui.Note("Allow movement:");
        using (ui.Columns(4))
        {
            TileFlag(ui, ref tile, "Walk", TileFlags.AllowMovementWalk);
            TileFlag(ui, ref tile, "Horse", TileFlags.AllowMovementHorse);
            TileFlag(ui, ref tile, "Raft", TileFlags.AllowMovementRaft);
            TileFlag(ui, ref tile, "Ship", TileFlags.AllowMovementShip);
            TileFlag(ui, ref tile, "Magical disc", TileFlags.AllowMovementMagicalDisc);
            TileFlag(ui, ref tile, "Eagle", TileFlags.AllowMovementEagle);
            TileFlag(ui, ref tile, "Fly", TileFlags.AllowMovementFly);
            TileFlag(ui, ref tile, "Swim", TileFlags.AllowMovementSwim);
            TileFlag(ui, ref tile, "Witch broom", TileFlags.AllowMovementWitchBroom);
            TileFlag(ui, ref tile, "Sand lizard", TileFlags.AllowMovementSandLizard);
            TileFlag(ui, ref tile, "Sand ship", TileFlags.AllowMovementSandShip);
            TileFlag(ui, ref tile, "Wasp", TileFlags.AllowMovementWasp);
        }

        // how the tile is drawn: normal, behind or in front of the characters
        var drawModes = List<string>.Create();
        drawModes.Add("Normal");
        drawModes.Add("Background");
        drawModes.Add("Foreground");
        bool background = (tile.Flags & TileFlags.Background) != TileFlags.None;
        bool front = (tile.Flags & TileFlags.BringToFront) != TileFlags.None;
        int drawMode = background ? (front ? 2 : 1) : 0;
        using (ui.Row())
        {
            ui.Label("Draw mode");
            if (ui.ComboBox("tdraw", ref drawMode, drawModes))
            {
                tile.Flags = tile.Flags & ~(TileFlags.Background | TileFlags.BringToFront);
                if (drawMode >= 1)
                    tile.Flags = tile.Flags | TileFlags.Background;
                if (drawMode == 2)
                    tile.Flags = tile.Flags | TileFlags.BringToFront;
            }
        }

        // sitting and sleeping: bits 23-25
        var sitModes = List<string>.Create();
        sitModes.Add("Normal");
        sitModes.Add("Sit, look up");
        sitModes.Add("Sit, look right");
        sitModes.Add("Sit, look down");
        sitModes.Add("Sit, look left");
        sitModes.Add("Sleep");
        int sit = (int)(((uint32)tile.Flags >> 23) & 7);
        if (sit > 5)
            sit = 0;
        using (ui.Row())
        {
            ui.Label("Sit/sleep");
            if (ui.ComboBox("tsit", ref sit, sitModes))
                tile.Flags = (TileFlags)(((uint32)tile.Flags & ~((uint32)7 << 23)) | ((uint32)sit << 23));
        }
        int combat = (int)((uint32)tile.Flags >> 28);
        using (ui.Row())
        {
            ui.Label("Combat background");
            using (ui.Column(70))
            {
                if (ui.IntBox("tcombat", ref combat, 0, 15))
                    tile.Flags = (TileFlags)(((uint32)tile.Flags & 0x0fffffff) | ((uint32)combat << 28));
            }
        }

        using (ui.Row())
        {
            if (ui.Button("Apply"))
            {
                editor.SetTilesetTile(editor.EditTileIndex, tile);
                editor.Graphics.Forget();
                editor.ShowEditTile = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowEditTile = false;
        }
        ui.Note("Changed tiles are saved to Icon_data.amb with the map.");
        editor.EditTile = tile;
    }
}

void UnsavedDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("unsaved", "Unsaved changes"))
    {
        ui.Text($"Map {editor.Map.Index} has changes that are not saved.");
        using (ui.Row())
        {
            int action = 0;
            if (ui.Button("Save"))
            {
                if (editor.SaveToGameData() is error e)
                    ShowError(ref editor, e.Message);
                else
                    action = editor.PendingAction;
            }
            if (ui.Button("Discard"))
                action = editor.PendingAction;
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowUnsaved = false;
            if (action != 0)
            {
                editor.ShowUnsaved = false;
                RunAction(ref editor, action, true);
            }
        }
    }
}

/// Opens a map, a new map, quits or opens other game data; asks first if there are unsaved changes.
void RunAction(ref Editor editor, int action, bool confirmed)
{
    if (!confirmed && editor.Dirty())
    {
        editor.PendingAction = action;
        editor.ShowUnsaved = true;
        return;
    }
    switch (action)
    {
        case 1:
            editor.DialogSelection = -1;
            editor.ShowOpenMap = true;
            break;
        case 2:
            editor.DialogIndex = 0;
            editor.ShowNewMap = true;
            break;
        case 3:
            editor.Quit = true;
            break;
        case 4:
            editor.FilePath = editor.GameDataPath;
            editor.ShowOpenGameData = true;
            break;
        default:
            break;
    }
}

void SaveFileDialog(Ui ui, ref Editor editor)
{
    var result = ui.FileDialog("savefile", "Save the map data to a file", ref editor.FilePath);
    if (result == UiDialogResult.Ok)
    {
        if (editor.SaveToFile(editor.FilePath) is error e)
            ShowError(ref editor, e.Message);
        else
            editor.Status = $"Saved to {editor.FilePath}";
    }
    if (result != UiDialogResult.None)
        editor.ShowSaveFile = false;
}
