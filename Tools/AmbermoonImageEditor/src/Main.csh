// AmbermoonImageEditor: a paint program for the graphics of Ambermoon: PNG and BMP files, and the palette graphics of
// the Amiga in bit planes (1, 3, 4 or 5 bits per pixel), with the palette files of the game. Made with System.Ui of
// CShift.
//
//   AmbermoonImageEditor [file]

using System;
using System.Image;
using System.Ui;

string Title(ref Editor editor)
{
    if (!editor.Loaded)
        return "Ambermoon Image Editor";
    string name = editor.FilePath.Length > 0 ? Path.GetFileName(editor.FilePath) : "new picture";
    return $"Ambermoon Image Editor - {name}{(editor.Dirty() ? " *" : "")}";
}

void HandleKeys(Ui ui, ref Editor editor)
{
    var input = ui.Input();
    var ctrl = KeyModifiers.Ctrl;
    if (input.Pressed(Key.N, ctrl))
        RunAction(ref editor, 2, false);
    if (input.Pressed(Key.O, ctrl))
        RunAction(ref editor, 1, false);
    if (input.Pressed(Key.Q, ctrl))
        RunAction(ref editor, 3, false);
    if (!editor.Loaded)
        return;
    if (input.Pressed(Key.S, ctrl))
        SaveOrAsk(ref editor);
    if (input.Pressed(Key.S, KeyModifiers.Ctrl | KeyModifiers.Shift))
        OpenSaveDialog(ref editor);
    if (input.Pressed(Key.Z, ctrl))
        editor.DoUndo();
    if (input.Pressed(Key.Y, ctrl))
        editor.DoRedo();
    // the tools and the zoom only without modifiers
    var none = KeyModifiers.None;
    if (input.Pressed(Key.D, none)) editor.Tool = Tool.Pencil;
    if (input.Pressed(Key.B, none)) editor.Tool = Tool.Brush;
    if (input.Pressed(Key.F, none)) editor.Tool = Tool.Fill;
    if (input.Pressed(Key.E, none)) editor.Tool = Tool.Eraser;
    if (input.Pressed(Key.I, none)) editor.Tool = Tool.Picker;
    if (input.Pressed(Key.G, none)) editor.ShowGrid = !editor.ShowGrid;
    if (input.Pressed(Key.D1, none)) editor.Zoom = 1;
    if (input.Pressed(Key.D2, none)) editor.Zoom = 2;
    if (input.Pressed(Key.D4, none)) editor.Zoom = 4;
    if (input.Pressed(Key.D8, none)) editor.Zoom = 8;
}

bool AnyDialog(ref Editor editor)
{
    return editor.ShowOpen || editor.ShowRaw || editor.ShowSave || editor.ShowNew || editor.ShowNormalize ||
           editor.ShowUnsaved || editor.ShowMessage || editor.ShowPaletteLoad || editor.ShowPaletteSave ||
           editor.ShowContainer || editor.ShowPaletteChoice;
}

/// One frame of the window.
void Draw(Ui ui, ref Editor editor, int windowHeight)
{
    if (!AnyDialog(ref editor))
        HandleKeys(ui, ref editor);
    DrawMenu(ui, ref editor);
    if (!editor.Loaded)
    {
        using (ui.Panel("Ambermoon Image Editor"))
        {
            ui.Text("A paint program for PNG and BMP files and for the palette graphics of the Amiga (1, 3, 4 or 5 bits per pixel in bit planes).");
            using (ui.Row())
            {
                if (ui.Button("New..."))
                    RunAction(ref editor, 2, false);
                if (ui.Button("Open..."))
                    RunAction(ref editor, 1, false);
            }
        }
    }
    else
    {
        DrawToolbar(ui, ref editor);
        using (ui.Row())
        {
            using (ui.Column(0))
            {
                DrawCanvas(ui, ref editor, Math.Max(120, windowHeight - 110));
                ui.Note(editor.Status.Length > 0 ? editor.Status : StatusText(ref editor));
                if (editor.HoverX >= 0)
                    editor.Status = "";
            }
            using (ui.Column(260))
            {
                DrawSideBar(ui, ref editor);
            }
        }
    }

    if (editor.ShowOpen) OpenDialog(ui, ref editor);
    // the palette choice before the container choice: when the container choice opens it, it starts with the next
    // frame (one Enter chooses once)
    if (editor.ShowPaletteChoice) PaletteChoiceDialog(ui, ref editor);
    if (editor.ShowContainer) ContainerDialog(ui, ref editor);
    if (editor.ShowRaw) RawFormatDialog(ui, ref editor);
    if (editor.ShowSave) SaveDialog(ui, ref editor);
    if (editor.ShowNew) NewDialog(ui, ref editor);
    if (editor.ShowNormalize) NormalizeDialog(ui, ref editor);
    PaletteFileDialogs(ui, ref editor);
    if (editor.ShowUnsaved) UnsavedDialog(ui, ref editor);
    if (editor.ShowMessage) MessageDialog(ui, ref editor);
}

// --screenshot <png> [file [width height bpp [frames [slices]]]]: draws frames without a window and saves the last one
// (for tests); a file without a PNG or BMP header is read with the given format.
int Screenshot(string[] args)
{
    var editor = Editor.Create();
    if (args.Length > 2 && editor.Open(args[2]) is error e)
    {
        Console.WriteLine(e.Message);
        return 1;
    }
    if (editor.ShowRaw && args.Length > 5 && args[3].ParseInt() is int width && args[4].ParseInt() is int height && args[5].ParseInt() is int bpp)
    {
        var format = AmigaFormat.Create(width, height, bpp);
        if (args.Length > 6 && args[6].ParseInt() is int frames)
            format.Frames = frames;
        format.Slices = args.Length > 7 && args[7] == "slices";
        editor.ShowRaw = false;
        if (editor.OpenRaw(format, 0) is error e2)
        {
            Console.WriteLine(e2.Message);
            return 1;
        }
    }
    var ui = Ui.Create();
    ui.SetTheme(Theme.Dark());
    Image frame = Image.Create(1, 1);
    for (var i = 0; i < 4; i += 1)
    {
        var input = UiInput.Create();
        input.MouseX = -1;
        input.MouseY = -1;
        ui.Begin(input, 1100, 700, 1.0);
        Draw(ui, ref editor, 700);
        frame = ui.End();
    }
    if (frame.Save(args[1]) is error)
    {
        Console.WriteLine("Could not save " + args[1]);
        return 1;
    }
    Console.WriteLine($"{editor.Picture.Width} x {editor.Picture.Height}, {(editor.Picture.Indexed ? $"{editor.Picture.Palette.Count()} colors" : "more than 256 colors")}");
    return 0;
}

/// Whether the frame had input that can change what is shown: then the next frame comes at once, so that the result
/// of a click or key is drawn without waiting for the next input.
bool HadInput(UiInput input)
{
    return input.MousePressed || input.MouseReleased || input.RightPressed || input.RightReleased || input.Keys.Count() > 0;
}

int Main(string[] args)
{
    if (args.Length >= 2 && args[0] == "--screenshot")
        return Screenshot(args);
    var editor = Editor.Create();
    if (args.Length > 0 && editor.Open(args[0]) is error e)
        ShowError(ref editor, e.Message);

    if (Window.Open("Ambermoon Image Editor", 1100, 760) is not Window window)
    {
        Console.WriteLine("The window could not be opened (is there a display?).");
        return 1;
    }
    var ui = Ui.Create();
    ui.SetTheme(Theme.Dark());
    string title = "";
    while (!editor.Quit && window.Update())
    {
        // closing the window asks when there are unsaved changes (like Quit; in the browser the browser asks)
        window.ConfirmClose(editor.Dirty());
        ui.Begin(window);
        if (ui.Input().CloseRequested && !editor.ShowUnsaved)
            RunAction(ref editor, 3, false);
        Draw(ui, ref editor, (int)((double)window.Height() / window.Scale()));
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
