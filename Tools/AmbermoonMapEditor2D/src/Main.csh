// AmbermoonMapEditor2D: an editor for the 2D maps of Ambermoon (a port of AmbermoonMapEditor2D of
// https://github.com/Pyrdacor/Ambermoon, AmbermoonTools, with System.Ui of CShift).
//
//   AmbermoonMapEditor2D [game data folder [map index]]

using System;
using System.Image;
using System.Ui;
using Ambermoon;
using Ambermoon.Data;

// ---- the configuration: the last folder of the game data ----

string ConfigPath()
{
    string folder = "";
    if (Process.GetEnv("APPDATA") is string appData)
        folder = appData;
    else if (Process.GetEnv("HOME") is string home)
        folder = home;
    return folder.Length == 0 ? ".AmbermoonMapEditor2D.cfg" : Path.Combine(folder, ".AmbermoonMapEditor2D.cfg");
}

string LoadConfig()
{
    if (File.ReadAllText(ConfigPath()) is string text)
        return text.Trim().ToString();
    return "";
}

void SaveConfig(string gameDataPath)
{
    File.WriteAllText(ConfigPath(), gameDataPath);
}

// ---- the window ----

string Title(ref Editor editor)
{
    if (!editor.MapLoaded)
        return "Ambermoon Map Editor 2D";
    string name = editor.Map.Name();
    return $"Ambermoon Map Editor 2D - Map {editor.Map.Index}{(name.Length > 0 ? " " + name : "")}{(editor.Dirty() ? " *" : "")}";
}

void Save(ref Editor editor)
{
    if (!editor.MapLoaded)
        return;
    if (editor.SaveToGameData() is error e)
        ShowError(ref editor, e.Message);
    else
        editor.Status = $"Saved map {editor.Map.Index} to {editor.MapFile}Map_data.amb";
}

void HandleKeys(Ui ui, ref Editor editor)
{
    var input = ui.Input();
    // the shortcuts: the modifiers held at the key press count (a quick Ctrl+S within one frame is not lost)
    var ctrl = KeyModifiers.Ctrl;
    var ctrlShift = KeyModifiers.Ctrl | KeyModifiers.Shift;
    if (input.Pressed(Key.O, ctrl))
        RunAction(ref editor, 1, false);
    if (input.Pressed(Key.N, ctrl))
        RunAction(ref editor, 2, false);
    if (input.Pressed(Key.S, ctrl))
        Save(ref editor);
    if (input.Pressed(Key.S, ctrlShift))
        editor.ShowSaveFile = editor.MapLoaded;
    if (input.Pressed(Key.Z, ctrl) && editor.MapLoaded)
        editor.DoUndo();
    if (input.Pressed(Key.Y, ctrl) && editor.MapLoaded)
        editor.DoRedo();
    // + is Shift with another key on many keyboards
    if (input.Pressed(Key.Plus, ctrl) || input.Pressed(Key.Plus, ctrlShift))
        editor.Zoom = Math.Min(4, editor.Zoom + 1);
    if (input.Pressed(Key.Minus, ctrl))
        editor.Zoom = Math.Max(1, editor.Zoom - 1);
    if (input.Pressed(Key.Q, ctrl))
        RunAction(ref editor, 3, false);
    if (!editor.MapLoaded)
        return;
    // the keys of the tools only without modifiers
    var none = KeyModifiers.None;
    if (input.Pressed(Key.B, none)) editor.Tool = Tool.Brush;
    if (input.Pressed(Key.F, none)) editor.Tool = Tool.Fill;
    if (input.Pressed(Key.E, none)) editor.Tool = Tool.Eraser;
    if (input.Pressed(Key.P, none)) editor.Tool = Tool.ColorPicker;
    if (input.Pressed(Key.G, none)) editor.ShowGrid = !editor.ShowGrid;
    if (input.Pressed(Key.Tab, none)) editor.Layer = Editor.Other(editor.Layer);
}

void DrawMenu(Ui ui, ref Editor editor)
{
    using (ui.MenuBar())
    {
        using (ui.Menu("Map"))
        {
            if (ui.MenuItem("Open game data..."))
                RunAction(ref editor, 4, false);
            if (editor.GameDataLoaded)
            {
                if (ui.MenuItem("Open map...", "Ctrl+O"))
                    RunAction(ref editor, 1, false);
                if (ui.MenuItem("New map...", "Ctrl+N"))
                    RunAction(ref editor, 2, false);
            }
            if (editor.MapLoaded)
            {
                if (ui.MenuItem("Save", "Ctrl+S"))
                    Save(ref editor);
                if (ui.MenuItem("Save to a file...", "Ctrl+Shift+S"))
                {
                    editor.FilePath = Path.Combine(editor.GameDataPath, $"{editor.Map.Index:D3}.map");
                    editor.ShowSaveFile = true;
                }
            }
            if (ui.MenuItem("Quit", "Ctrl+Q"))
                RunAction(ref editor, 3, false);
        }
        if (editor.MapLoaded)
        {
            using (ui.Menu("Edit"))
            {
                if (ui.MenuItem($"Undo ({editor.Undo.Count()})", "Ctrl+Z"))
                    editor.DoUndo();
                if (ui.MenuItem($"Redo ({editor.Redo.Count()})", "Ctrl+Y"))
                    editor.DoRedo();
            }
            using (ui.Menu("View"))
            {
                if (ui.MenuItem("Zoom in", "Ctrl++"))
                    editor.Zoom = Math.Min(4, editor.Zoom + 1);
                if (ui.MenuItem("Zoom out", "Ctrl+-"))
                    editor.Zoom = Math.Max(1, editor.Zoom - 1);
                if (ui.MenuItem(editor.ShowGrid ? "Hide grid" : "Show grid", "G"))
                    editor.ShowGrid = !editor.ShowGrid;
                if (ui.MenuItem(editor.ShowEvents ? "Hide events" : "Show events"))
                    editor.ShowEvents = !editor.ShowEvents;
            }
        }
    }
}

// the context menu of a tile of the tileset
void DrawTileMenu(Ui ui, ref Editor editor, ref TilesetTile copied, ref bool hasCopy)
{
    using (ui.Popup("tilemenu"))
    {
        var tileset = editor.CurrentTileset();
        if (editor.SelectedTile >= 1 && editor.SelectedTile <= tileset.Tiles.Length)
        {
            if (ui.MenuItem($"Edit tile {editor.SelectedTile}..."))
            {
                editor.EditTileIndex = editor.SelectedTile;
                editor.EditTile = tileset.Tiles[editor.SelectedTile - 1];
                editor.ShowEditTile = true;
            }
            if (ui.MenuItem("Copy tile"))
            {
                copied = tileset.Tiles[editor.SelectedTile - 1];
                hasCopy = true;
            }
            if (hasCopy && ui.MenuItem("Paste tile"))
            {
                editor.SetTilesetTile(editor.SelectedTile, copied);
                editor.Graphics.Forget();
            }
        }
    }
}

void Draw(Ui ui, ref Editor editor, int windowHeight, ref TilesetTile copied, ref bool hasCopy)
{
    HandleKeys(ui, ref editor);
    DrawMenu(ui, ref editor);

    if (!editor.MapLoaded)
    {
        ui.Label("Ambermoon Map Editor 2D");
        if (!editor.GameDataLoaded)
        {
            ui.Text("Open the game data first: the folder with the files of the game (Amberfiles).");
            if (ui.Button("Open game data..."))
                RunAction(ref editor, 4, false);
        }
        else
        {
            ui.Text($"Game data: {editor.GameDataPath}");
            using (ui.Row())
            {
                if (ui.Button("Open map..."))
                    RunAction(ref editor, 1, false);
                if (ui.Button("New map..."))
                    RunAction(ref editor, 2, false);
            }
        }
    }
    else
    {
        using (ui.Row())
        {
            using (ui.Column(0))
            {
                DrawToolbar(ui, ref editor);
                int mapHeight = Math.Max(160, windowHeight * 3 / 5 - 60);
                DrawMapView(ui, ref editor, mapHeight);
                ui.Note(editor.Status.Length > 0 ? editor.Status : StatusText(ref editor));
                if (editor.HoverX >= 0 || editor.HoverTile > 0)
                    editor.Status = "";
                // the tileset: as many columns as fit
                var probe = ui.Area(0, 1);
                int columns = Math.Max(4, (int)((double)probe.Width / ui.Scale()) / (TileSize * editor.TilesetZoom) - 1);
                DrawTilesetView(ui, ref editor, columns);
            }
            using (ui.Column(330))
            {
                DrawSideBar(ui, ref editor);
            }
        }
        DrawTileMenu(ui, ref editor, ref copied, ref hasCopy);
    }

    if (editor.ShowOpenGameData) OpenGameDataDialog(ui, ref editor);
    if (editor.ShowOpenMap) OpenMapDialog(ui, ref editor);
    if (editor.ShowNewMap) NewMapDialog(ui, ref editor);
    if (editor.ShowResize) ResizeDialog(ui, ref editor);
    if (editor.ShowEventSelect) EventSelectDialog(ui, ref editor);
    if (editor.ShowEditTile) EditTileDialog(ui, ref editor);
    if (editor.ShowCharacterFlags) CharacterFlagsDialog(ui, ref editor);
    if (editor.ShowSaveFile) SaveFileDialog(ui, ref editor);
    if (editor.ShowUnsaved) UnsavedDialog(ui, ref editor);
    if (editor.ShowMessage) MessageDialog(ui, ref editor);
}

// --screenshot <png> <game data> <map> [x y]: draws frames without a window and saves the last one (for tests); with
// x and y the left mouse button is pressed there in the third frame and released in the fourth.
int Screenshot(string[] args)
{
    var editor = Editor.Create();
    if (editor.LoadGameData(args[2]) is error e)
    {
        Console.WriteLine(e.Message);
        return 1;
    }
    if (args[3].ParseInt() is int index && editor.OpenMap((uint32)index) is error e2)
    {
        Console.WriteLine(e2.Message);
        return 1;
    }
    editor.ShowEvents = true;
    editor.ShowCharacters = true;
    var ui = Ui.Create();
    ui.SetTheme(Theme.Dark());
    var copied = TilesetTile { };
    bool hasCopy = false;
    Image frame = Image.Create(1, 1);
    for (var i = 0; i < 6; i += 1)
    {
        var input = UiInput.Create();
        input.MouseX = -1;
        input.MouseY = -1;
        if (args.Length > 5 && i >= 2 && args[4].ParseInt() is int x && args[5].ParseInt() is int y)
        {
            input.MouseX = x;
            input.MouseY = y;
            input.MousePressed = i == 2;
            input.MouseDown = i == 2;
            input.MouseReleased = i == 3;
        }
        ui.Begin(input, 1280, 800, 1.0);
        Draw(ui, ref editor, 800, ref copied, ref hasCopy);
        frame = ui.End();
    }
    if (frame.Save(args[1]) is error)
    {
        Console.WriteLine("Could not save " + args[1]);
        return 1;
    }
    Console.WriteLine(StatusText(ref editor));
    return 0;
}

bool AnyDialog(ref Editor editor)
{
    return editor.ShowOpenGameData || editor.ShowOpenMap || editor.ShowNewMap || editor.ShowResize || editor.ShowEventSelect ||
           editor.ShowEditTile || editor.ShowCharacterFlags || editor.ShowSaveFile || editor.ShowUnsaved || editor.ShowMessage;
}

/// Whether the frame had input that can change what is shown: then the next frame comes at once, so that the result
/// of a click or key is drawn without waiting for the next input.
bool HadInput(UiInput input)
{
    return input.MousePressed || input.MouseReleased || input.RightPressed || input.RightReleased || input.Keys.Count() > 0;
}

int Main(string[] args)
{
    if (args.Length >= 4 && args[0] == "--screenshot")
        return Screenshot(args);
    var editor = Editor.Create();
    string gameDataPath = args.Length > 0 ? args[0] : LoadConfig();
    if (gameDataPath.Length > 0)
    {
        if (editor.LoadGameData(gameDataPath) is error e)
        {
            if (args.Length > 0)
                ShowError(ref editor, e.Message);
            editor.FilePath = gameDataPath;
        }
        else if (args.Length > 1 && args[1].ParseInt() is int index)
        {
            if (editor.OpenMap((uint32)index) is error e2)
                ShowError(ref editor, e2.Message);
        }
    }

    if (Window.Open("Ambermoon Map Editor 2D", 1280, 800) is not Window window)
    {
        Console.WriteLine("The window could not be opened (is there a display?).");
        return 1;
    }
    var ui = Ui.Create();
    ui.SetTheme(Theme.Dark());
    var copied = TilesetTile { };
    bool hasCopy = false;
    string title = "";
    while (!editor.Quit && window.Update())
    {
        // closing the window asks when there are unsaved changes (like Quit; in the browser the browser asks)
        window.ConfirmClose(editor.Dirty());
        ui.Begin(window);
        editor.Time = ui.Input().Time;
        if (ui.Input().CloseRequested && !editor.ShowUnsaved)
            RunAction(ref editor, 3, false);
        Draw(ui, ref editor, (int)((double)window.Height() / window.Scale()), ref copied, ref hasCopy);
        // animated tiles: the next frame when the animation goes on
        if (editor.Animate && editor.MapLoaded && !AnyDialog(ref editor))
            ui.RequestFrame((int)(FrameSeconds * 1000.0));
        if (HadInput(ui.Input()))
            ui.RequestFrame(0);
        window.Show(ui);
        string newTitle = Title(ref editor);
        if (newTitle != title)
        {
            window.SetTitle(newTitle);
            title = newTitle;
        }
    }
    window.Dispose();
    return 0;
}
