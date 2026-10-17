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
    var result = ui.FileDialog("openfile", "Open a picture (PNG, BMP or an Amiga graphic)", ref editor.DialogPath);
    if (result == UiDialogResult.None)
        return;
    editor.ShowOpen = false;
    if (result == UiDialogResult.Ok && editor.Open(editor.DialogPath) is error e)
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
    var format = editor.DialogFormat;
    string key = $"{format.Width},{format.Height},{format.Bpp},{format.Frames},{format.Slices},{editor.DialogOffset}";
    if (key != editor.PreviewKey)
    {
        editor.PreviewKey = key;
        editor.PreviewError = "";
        if ((int64)format.Width * format.Height * Math.Max(1, format.Frames) > PreviewPixels)
            editor.PreviewError = "Too big for a preview.";
        else if (RawPicture(editor.RawData, format, editor.DialogOffset) is Picture picture)
            editor.Preview = picture.ToCheckedImage();
        else if (RawPicture(editor.RawData, format, editor.DialogOffset) is error e)
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
        FormatFields(ui, ref editor.DialogFormat, false, 0, 0);
        PaletteOffsetField(ui, "rawoffset", editor.DialogFormat.Bpp, ref editor.DialogOffset);
        ui.Tooltip("Which colors of the palette the graphic uses (Ambermoon: 4 BPP often from 16, 3 BPP from 24)");
        var format = editor.DialogFormat;
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
                if (editor.OpenRaw(format, editor.DialogOffset) is error e)
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
    if (editor.FilePath.Length == 0)
    {
        OpenSaveDialog(ref editor);
        return;
    }
    if (editor.Save() is error e)
        ShowError(ref editor, e.Message);
    else
        editor.Status = $"Saved {editor.FilePath}";
}

void OpenSaveDialog(ref Editor editor)
{
    editor.DialogKind = (int)editor.Kind;
    editor.DialogFormat = editor.Format;
    editor.DialogPath = editor.FilePath.Length > 0 ? editor.FilePath : "picture";
    editor.ShowSave = true;
}

void SaveDialog(Ui ui, ref Editor editor)
{
    using (ui.Modal("save", "Save the picture"))
    {
        using (ui.Row())
        {
            ui.Label("File");
            ui.TextBox("savepath", ref editor.DialogPath);
            if (ui.Button("Browse..."))
                editor.ShowBrowse = true;
        }
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
            if (ui.Button("Save") && problem.Length == 0)
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
            if (ui.Button("Cancel") || ui.Input().Pressed(Key.Escape))
            {
                editor.ShowSave = false;
                editor.PendingAction = 0;
            }
        }
    }
    if (editor.ShowBrowse)
    {
        var result = ui.FileDialog("savebrowse", "Save as", ref editor.DialogPath);
        if (result != UiDialogResult.None)
            editor.ShowBrowse = false;
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
        var result = ui.FileDialog("palload", "Load a palette (32 colors of 16 bits, like Palettes.amb)", ref editor.DialogPath);
        if (result != UiDialogResult.None)
            editor.ShowPaletteLoad = false;
        if (result == UiDialogResult.Ok && editor.LoadPalette(editor.DialogPath) is error e)
            ShowError(ref editor, e.Message);
    }
    if (editor.ShowPaletteSave)
    {
        var result = ui.FileDialog("palsave", "Save the palette (32 colors of 16 bits)", ref editor.DialogPath);
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
