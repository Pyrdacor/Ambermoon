// The dialogs: opening and saving files, the format of Amiga graphics, a new picture, normalizing the colors, palette
// files, unsaved changes and messages.

using System;
using System.Image;
using System.Ui;

void ShowError(ref Editor editor, string text)
{
    editor.Message = text;
    editor.ShowMessage = true;
}

void MessageDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("message", "Ambermoon Image Editor"))
    {
        ui.Text(editor.Message);
        if (ui.Button("OK") || ui.Input().Pressed(Key.Enter) || ui.Input().Pressed(Key.Escape))
            editor.ShowMessage = false;
    }
}

/// Opens a file, a new picture or quits; asks first if there are unsaved changes.
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
            editor.DialogPath = editor.FilePath;
            editor.ShowOpen = true;
            break;
        case 2:
            editor.DialogFormat = editor.Format;
            editor.DialogFormat.Frames = 1;
            editor.ShowNew = true;
            break;
        case 3:
            editor.Quit = true;
            break;
        default:
            break;
    }
}

void UnsavedDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("unsaved", "Unsaved changes"))
    {
        ui.Text("The picture has changes that are not saved.");
        using (ui.Row())
        {
            int action = 0;
            if (ui.Button("Save"))
            {
                if (editor.FilePath.Length == 0)
                {
                    editor.ShowUnsaved = false;
                    OpenSaveDialog(ref editor);
                }
                else if (editor.Save() is error e)
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

// ---- files ----

void OpenDialog(Ui ui, ref Editor editor)
{
    // several files can be chosen: in the browser the files a container needs come along (Monster_char.amb with
    // Monster_gfx.amb and Palettes.amb); the picture is the one that is not only such a neighbour
    var result = ui.FileDialog("openfile", "Open a picture (PNG, BMP or an Amiga graphic)", ref editor.DialogPath, FileDialogMode.OpenMany);
    if (result == UiDialogResult.None)
        return;
    editor.ShowOpen = false;
    if (result != UiDialogResult.Ok)
        return;
    string path = editor.DialogPath;
    foreach (var chosen in ui.FileDialogPaths("openfile"))
    {
        string name = Path.GetFileName(chosen).ToLower();
        if (name != "monster_gfx.amb" && name != "palettes.amb")
        {
            path = chosen;
            break;
        }
    }
    if (editor.Open(path) is error e)
        ShowError(ref editor, e.Message);
}

/// The fields of the format of an Amiga graphic: the preset, the size (unless `fixedSize`: the size of the picture
/// that is saved), the bits per pixel, the frames and the 8 pixel slices.
void FormatFields(Ui ui, ref AmigaFormat format, bool fixedSize, int totalWidth, int height)
{
    var presets = Presets();
    int preset = Math.Max(0, Math.Min(format.Preset, presets.Count() - 1));
    using (ui.Row())
    {
        ui.Label("Format");
        if (ui.ComboBox("preset", ref preset, PresetNames()))
            format.Preset = preset;
    }
    format = ApplyPreset(format);
    var chosen = presets[format.Preset];

    format.Frames = Math.Max(1, format.Frames);
    if (fixedSize)
    {
        // the size comes from the picture: the frames divide its width
        format.Width = totalWidth / format.Frames;
        format.Height = height;
        ui.Label($"Size {format.Width} x {format.Height}{(format.Frames > 1 ? $" ({format.Frames} frames)" : "")}");
    }
    else
    {
        using (ui.Row())
        {
            ui.Label("Width");
            using (ui.Column(80))
            {
                if (chosen.Width > 0)
                    ui.Label(format.Width.ToString());
                else
                    ui.IntBox("fwidth", ref format.Width, 1, 4096);
            }
            ui.Label("Height");
            using (ui.Column(80))
            {
                if (chosen.Height > 0)
                    ui.Label(format.Height.ToString());
                else
                    ui.IntBox("fheight", ref format.Height, 1, 4096);
            }
        }
    }

    using (ui.Row())
    {
        ui.Label("Bits per pixel");
        if (chosen.Bpp > 0)
            ui.Label(BppNames()[BppIndex(format.Bpp)]);
        else
        {
            int bppIndex = BppIndex(format.Bpp);
            if (ui.ComboBox("fbpp", ref bppIndex, BppNames()))
                format.Bpp = AllowedBpp()[bppIndex];
        }
    }
    using (ui.Row())
    {
        ui.Label("Frames");
        using (ui.Column(80))
        {
            ui.IntBox("fframes", ref format.Frames, 1, 999);
        }
    }
    if (format.SlicesAllowed())
    {
        if (chosen.Bpp > 0)
            ui.Label(format.Slices ? "1 byte per row (8 pixel slices)" : "Rows of whole planes");
        else
            ui.Checkbox("1 byte per row (8 pixel slices)", ref format.Slices);
        ui.Tooltip("The planes for each 8 pixels of a row one after the other (the 3D textures of Ambermoon)");
    }
    else
        format.Slices = false;
}

/// The palette offset: 0, or 0 / 16 for 4 bits per pixel, 0 / 16 / 24 for 3 bits; fixed to 0 for the others.
void PaletteOffsetField(Ui ui, string id, int bpp, ref int offset)
{
    var offsets = PaletteOffsets(bpp);
    if (!offsets.Contains(offset))
        offset = 0;
    using (ui.Row())
    {
        ui.Label("Palette offset");
        if (offsets.Count() == 1)
        {
            ui.Label("0");
            return;
        }
        var names = List<string>.Create();
        int selected = 0;
        for (var i = 0; i < offsets.Count(); i += 1)
        {
            names.Add(offsets[i].ToString());
            if (offsets[i] == offset)
                selected = i;
        }
        using (ui.Column(90))
        {
            if (ui.ComboBox(id, ref selected, names))
                offset = offsets[selected];
        }
    }
}

const int PreviewWidth = 360;
const int PreviewHeight = 180;
const int PreviewPixels = 4000000;

// the preview of the format dialog (made again when the format changes), or why there is none
void _RawPreview(Ui ui, ref Editor editor)
{
    var format = editor.RawFormat;
    string key = $"{format.Width},{format.Height},{format.Bpp},{format.Frames},{format.Slices},{editor.RawOffset}";
    if (key != editor.PreviewKey)
    {
        editor.PreviewKey = key;
        editor.PreviewError = "";
        if ((int64)format.Width * format.Height * Math.Max(1, format.Frames) > PreviewPixels)
            editor.PreviewError = "Too big for a preview.";
        else if (RawPicture(editor.RawData, format, editor.RawOffset) is Picture picture)
            editor.Preview = picture.ToCheckedImage();
        else if (RawPicture(editor.RawData, format, editor.RawOffset) is error e)
            editor.PreviewError = e.Message;
    }
    if (editor.PreviewError.Length > 0)
    {
        // the reason in the place of the preview
        using (ui.Panel("No preview"))
        {
            ui.Text(editor.PreviewError);
        }
        return;
    }
    // the whole picture, as large as fits (at most 4 times)
    var image = editor.Preview;
    double scale = Math.Min(4.0, Math.Min((double)PreviewWidth / (double)image.Width, (double)PreviewHeight / (double)image.Height));
    int w = Math.Max(1, (int)((double)image.Width * scale));
    int h = Math.Max(1, (int)((double)image.Height * scale));
    var area = ui.Area(PreviewWidth, h);
    ui.FillRect(area, Color.FromRgb(20, 20, 20));
    ui.DrawImage(image, Rect.Create(0, 0, image.Width, image.Height), Rect.Create(area.X, area.Y, (int)((double)w * ui.Scale()), area.Height));
}

/// The format of a file without a PNG or BMP header.
void RawFormatDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("rawformat", "The format of the graphic"))
    {
        ui.Text($"'{Path.GetFileName(editor.DialogPath)}' is no PNG or BMP file. As an Amiga graphic, it needs:");
        FormatFields(ui, ref editor.RawFormat, false, 0, 0);
        PaletteOffsetField(ui, "rawoffset", editor.RawFormat.Bpp, ref editor.RawOffset);
        ui.Tooltip("Which colors of the palette the graphic uses (Ambermoon: 4 BPP often from 16, 3 BPP from 24)");
        var format = editor.RawFormat;
        int size = editor.RawData.Length;
        int needed = format.DataSize();
        if (needed > size)
            ui.Note($"This needs {needed} bytes, the file has only {size}.");
        else if (needed < size)
        {
            int frames = format.FrameSize() > 0 ? size / format.FrameSize() : 0;
            ui.Note($"This needs {needed} of the {size} bytes of the file{(frames > format.Frames ? $" ({frames} frames would fit)" : "")}.");
        }
        else
            ui.Note($"This is the size of the file: {size} bytes.");
        _RawPreview(ui, ref editor);
        using (ui.Row())
        {
            if (ui.Button("Open") && needed <= size && editor.PreviewError.Length == 0)
            {
                if (editor.OpenRaw(format, editor.RawOffset) is error e)
                    ShowError(ref editor, e.Message);
                editor.ShowRaw = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
            {
                editor.RawData = new uint8[0];
                editor.ShowRaw = false;
            }
        }
    }
}

/// Saves without asking if the picture has a file, else opens the save dialog.
void SaveOrAsk(ref Editor editor)
{
    if (!editor.Loaded)
        return;
    // a new picture, a file of a container ("2Wall3D.amb #10"), or one that was opened in the browser (its file is in
    // the memory of the page): save as
    if (editor.FilePath.Length == 0 || editor.FilePath.Contains(" #") || editor.FilePath.StartsWith(BrowserFiles))
    {
        OpenSaveDialog(ref editor);
        return;
    }
    if (editor.Save() is error e)
        ShowError(ref editor, e.Message);
    else
        editor.Status = $"Saved {editor.FilePath}";
}

/// Where the browser puts the files the user opens (CShift 0.37): they are only in the memory of the page.
const string BrowserFiles = "/home/web_user/files/";

void OpenSaveDialog(ref Editor editor)
{
    CommitFloat(ref editor);
    editor.DialogKind = (int)editor.Kind;
    editor.DialogFormat = editor.Format;
    editor.DialogFormat.Frames = editor.Picture.Frames;
    string name = editor.FilePath.Length > 0 && !editor.FilePath.Contains(" #") ? editor.FilePath : Path.Combine(_Folder(editor.FilePath), "picture");
    editor.DialogPath = _WithExtension(name, editor.Kind);
    editor.ShowSave = true;
}

void SaveDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("save", "Save the picture"))
    {
        var kinds = List<string>.Create();
        kinds.Add("PNG");
        kinds.Add("BMP");
        kinds.Add("Amiga graphic");
        using (ui.Row())
        {
            ui.Label("Save as");
            if (ui.ComboBox("savekind", ref editor.DialogKind, kinds))
                editor.DialogPath = _WithExtension(editor.DialogPath, (FileKind)editor.DialogKind);
        }
        var picture = editor.Picture;
        string problem = "";
        if ((FileKind)editor.DialogKind == FileKind.Amiga)
        {
            FormatFields(ui, ref editor.DialogFormat, true, picture.Width, picture.Height);
            var format = editor.DialogFormat;
            var preset = Presets()[format.Preset];
            int needed = picture.NeededBpp();
            if (needed == 0)
                problem = "The picture has more than 32 colors: normalize the colors first (Image > Normalize colors).";
            else if (needed > format.Bpp)
                problem = $"The picture uses colors up to {(1 << needed) - 1}; {format.Bpp} BPP stores only 0 to {(1 << format.Bpp) - 1}. Normalize the colors to {format.Bpp} BPP first.";
            else if (format.Width * format.Frames != picture.Width)
                problem = $"{picture.Width} pixels cannot be divided into {format.Frames} frames.";
            else if ((preset.Width > 0 && preset.Width != format.Width) || (preset.Height > 0 && preset.Height != format.Height))
                problem = $"The format '{preset.Name}' is {preset.Width} x {preset.Height} pixels (per frame).";
            if (problem.Length > 0)
                ui.Note(problem);
            else
                ui.Note($"{format.DataSize()} bytes");
        }
        using (ui.Row())
        {
            // the file is chosen with the file dialog for saving (in the browser: a name, and the file is downloaded)
            if (ui.Button("Save...") && problem.Length == 0)
                editor.ShowBrowse = true;
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
            {
                editor.ShowSave = false;
                editor.PendingAction = 0;
            }
        }
    }
    if (editor.ShowBrowse)
    {
        var result = ui.FileDialog("savebrowse", "Save as", ref editor.DialogPath, FileDialogMode.Save);
        if (result != UiDialogResult.None)
            editor.ShowBrowse = false;
        if (result == UiDialogResult.Ok)
        {
            if (editor.SaveAs(editor.DialogPath, (FileKind)editor.DialogKind, editor.DialogFormat) is error e)
                ShowError(ref editor, e.Message);
            else
            {
                editor.ShowSave = false;
                editor.Status = $"Saved {editor.DialogPath}";
                if (editor.PendingAction != 0 && !editor.ShowUnsaved)
                {
                    int action = editor.PendingAction;
                    editor.PendingAction = 0;
                    RunAction(ref editor, action, true);
                }
            }
        }
    }
}

string _WithExtension(string path, FileKind kind)
{
    string lower = path.ToLower();
    string stem = lower.EndsWith(".png") || lower.EndsWith(".bmp") ? path[0..(path.Length - 4)].ToString() : path;
    if (kind == FileKind.Png)
        return stem + ".png";
    if (kind == FileKind.Bmp)
        return stem + ".bmp";
    return stem;
}

void NewDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("new", "New Amiga graphic"))
    {
        var format = editor.DialogFormat;
        using (ui.Row())
        {
            ui.Label("Width");
            using (ui.Column(80)) { ui.IntBox("nwidth", ref format.Width, 1, 4096); }
            ui.Label("Height");
            using (ui.Column(80)) { ui.IntBox("nheight", ref format.Height, 1, 4096); }
        }
        int bppIndex = BppIndex(format.Bpp);
        using (ui.Row())
        {
            ui.Label("Bits per pixel");
            if (ui.ComboBox("nbpp", ref bppIndex, BppNames()))
                format.Bpp = AllowedBpp()[bppIndex];
        }
        ui.Note($"The palette has {1 << format.Bpp} colors; color 0 is transparent.");
        editor.DialogFormat = format;
        using (ui.Row())
        {
            if (ui.Button("Create"))
            {
                editor.New(format.Width, format.Height, format.Bpp);
                editor.ShowNew = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowNew = false;
        }
    }
}

void NormalizeDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("normalize", "Normalize the colors"))
    {
        ui.Text("Makes the picture an Amiga graphic: color 0 becomes transparent (for the transparent pixels), the other colors are reduced to 12 bits (4 per channel) and to as many as fit, and every pixel gets the nearest of them.");
        int bppIndex = BppIndex(editor.DialogBpp);
        using (ui.Row())
        {
            ui.Label("Bits per pixel");
            if (ui.ComboBox("normbpp", ref bppIndex, BppNames()))
                editor.DialogBpp = AllowedBpp()[bppIndex];
        }
        using (ui.Row())
        {
            if (ui.Button("Normalize"))
            {
                editor.NormalizeColors(editor.DialogBpp);
                editor.ShowNormalize = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowNormalize = false;
        }
    }
}

void PaletteFileDialogs(Ui ui, ref Editor editor)
{
    if (editor.ShowPaletteLoad)
    {
        var result = ui.FileDialog("palload", "Load a palette (32 colors of 16 bits, a palette of Palettes.amb, or a PNG/BMP: each pixel a color)", ref editor.DialogPath);
        if (result != UiDialogResult.None)
            editor.ShowPaletteLoad = false;
        if (result == UiDialogResult.Ok && editor.LoadPalette(editor.DialogPath) is error e)
            ShowError(ref editor, e.Message);
    }
    if (editor.ShowPaletteSave)
    {
        var result = ui.FileDialog("palsave", "Save the palette (32 colors of 16 bits)", ref editor.DialogPath, FileDialogMode.Save);
        if (result != UiDialogResult.None)
            editor.ShowPaletteSave = false;
        if (result == UiDialogResult.Ok)
        {
            if (editor.SavePalette(editor.DialogPath) is error e)
                ShowError(ref editor, e.Message);
            else
                editor.Status = $"Saved the palette to {editor.DialogPath}";
        }
    }
}

// ---- files of containers and palettes of Palettes.amb ----

// Up, Down, Home and End move the choice of a list
void _ListKeys(Ui ui, ref int selection, int count)
{
    var input = ui.Input();
    if (input.Pressed(Key.Down)) selection = Math.Min(count - 1, selection + 1);
    if (input.Pressed(Key.Up)) selection = Math.Max(0, selection - 1);
    if (input.Pressed(Key.Home)) selection = 0;
    if (input.Pressed(Key.End)) selection = count - 1;
}

void ContainerDialog(Ui ui, ref Editor editor)
{
    var file = editor.SourceFile;
    bool monsters = editor.Choice == ChoicePurpose.Monster;
    using (ui.Modal("container", monsters ? "Open a monster" : "Open a file of the container"))
    {
        ui.Text($"'{Path.GetFileName(file.Path)}' has {file.Numbers.Length} files. {(monsters ? "The monster is opened with its graphic of Monster_gfx.amb." : "Which one?")}");
        var labels = ContainerLabels(file);
        _ListKeys(ui, ref editor.ChoiceSelection, labels.Count());
        using (ui.Scroll("containerfiles", 320))
        {
            for (var i = 0; i < labels.Count(); i += 1)
            {
                using (ui.Id(i))
                {
                    if (ui.ListItem(labels[i], editor.ChoiceSelection == i))
                        editor.ChoiceSelection = i;
                }
            }
        }
        using (ui.Row())
        {
            if (ui.Button("Open") || ui.Input().Pressed(Key.Enter))
            {
                editor.ShowContainer = false;
                if (editor.ChoiceSelection >= 0 && editor.ChoiceSelection < file.Numbers.Length &&
                    ChooseContainerFile(ref editor, file.Numbers[editor.ChoiceSelection]) is error e)
                    ShowError(ref editor, e.Message);
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowContainer = false;
        }
    }
}

void PaletteChoiceDialog(Ui ui, ref Editor editor)
{
    bool monster = editor.Choice == ChoicePurpose.MonsterPalette;
    using (ui.Modal("palettechoice", monster ? $"The palette of {editor.Monster.Name}" : "Choose a palette"))
    {
        if (monster)
            ui.Text($"{editor.Monster.FrameWidth} x {editor.Monster.FrameHeight} pixels per frame, shown as {editor.Monster.MappedWidth} x {editor.Monster.MappedHeight}, 5 BPP, with the palette mapping of the monster. Which palette?");
        _ListKeys(ui, ref editor.ChoiceSelection, editor.PaletteChoices.Count());
        using (ui.Scroll("palettes", 320))
        {
            for (var i = 0; i < editor.PaletteChoices.Count(); i += 1)
            {
                using (ui.Id(i))
                {
                    using (ui.Row())
                    {
                        using (ui.Column(110))
                        {
                            if (ui.ListItem($"Palette {i + 1}", editor.ChoiceSelection == i))
                                editor.ChoiceSelection = i;
                        }
                        // the 32 colors
                        var strip = ui.Area(PaletteFileColors * 10, 18);
                        if (ui.Clicked())
                            editor.ChoiceSelection = i;
                        var colors = editor.PaletteChoices[i];
                        int w = strip.Width / PaletteFileColors;
                        for (var c = 0; c < colors.Length && c < PaletteFileColors; c += 1)
                            ui.FillRect(Rect.Create(strip.X + c * w, strip.Y, w, strip.Height), Color.FromArgb(colors[c]));
                    }
                }
            }
        }
        using (ui.Row())
        {
            if (ui.Button("OK") || ui.Input().Pressed(Key.Enter))
            {
                editor.ShowPaletteChoice = false;
                if (editor.ChoiceSelection >= 0 && editor.ChoiceSelection < editor.PaletteChoices.Count())
                {
                    var palette = editor.PaletteChoices[editor.ChoiceSelection];
                    if (monster)
                    {
                        if (editor.OpenMonster(palette) is error e)
                            ShowError(ref editor, e.Message);
                    }
                    else
                        editor.ApplyPalette(palette);
                }
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowPaletteChoice = false;
        }
    }
}

/// The size of the frames: their pixels scaled, or the canvas cut or extended.
void ResizeDialog(Ui ui, ref Editor editor)
{
    var picture = editor.Picture;
    using (ui.Modal("resize", picture.Frames > 1 ? "Resize the frames" : "Resize the picture"))
    {
        ui.Text($"Now {picture.FrameWidth()} x {picture.Height} pixels{(picture.Frames > 1 ? $" per frame ({picture.Frames} frames)" : "")}.");
        using (ui.Row())
        {
            ui.Label("Width");
            using (ui.Column(90)) { ui.IntBox("rwidth", ref editor.ResizeWidth, 1, 4096); }
            ui.Label("Height");
            using (ui.Column(90)) { ui.IntBox("rheight", ref editor.ResizeHeight, 1, 4096); }
        }
        ui.Radio("Scale the pixels", ref editor.ResizeMode, 0);
        ui.Radio("Change the canvas (cut off or add transparent pixels)", ref editor.ResizeMode, 1);
        if (editor.ResizeMode == 1)
            ui.Checkbox("Keep the picture in the middle (else at the top left)", ref editor.ResizeCenter);
        using (ui.Row())
        {
            if (ui.Button("Resize"))
            {
                ResizeFrames(ref editor, editor.ResizeWidth, editor.ResizeHeight, editor.ResizeMode == 0, editor.ResizeCenter);
                editor.ShowResize = false;
            }
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
                editor.ShowResize = false;
        }
    }
}

/// Asks for a file a container needs when it is not next to it (Monster_gfx.amb and Palettes.amb for the monsters of
/// Monster_char.amb; in the browser only the files the user chose are there).
void LocateDialog(Ui ui, ref Editor editor)
{
    string container = Path.GetFileName(editor.SourceFile.Path);
    var result = ui.FileDialog("locate", $"Choose {editor.LocateName} (it is not next to {container})", ref editor.DialogPath);
    if (result == UiDialogResult.None)
        return;
    editor.ShowLocate = false;
    if (result != UiDialogResult.Ok)
        return;
    if (editor.LocateName == "Monster_gfx.amb")
        editor.MonsterGfxPath = editor.DialogPath;
    else
        editor.PalettesPath = editor.DialogPath;
    // go on with the monster (it may ask for the other file next)
    if (ChooseContainerFile(ref editor, editor.LocateNumber) is error e)
        ShowError(ref editor, e.Message);
}
