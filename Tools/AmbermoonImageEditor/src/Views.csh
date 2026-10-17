// The window: the menu, the tools, the picture and the palette.

using System;
using System.Image;
using System.Ui;

string ToolName(Tool tool)
{
    switch (tool)
    {
        case Tool.Pencil: return "Pencil";
        case Tool.Brush: return "Brush";
        case Tool.Fill: return "Fill";
        case Tool.Eraser: return "Eraser";
        default: return "Picker";
    }
}

string ToolHelp(Tool tool)
{
    switch (tool)
    {
        case Tool.Pencil: return "Pixels; dragging draws lines. Left: primary color, right: secondary color (D)";
        case Tool.Brush: return "A square brush of 2x2 to 16x16 pixels (B)";
        case Tool.Fill: return "Fills the area of the color, or the color everywhere (F)";
        case Tool.Eraser: return "Makes pixels transparent, 1x1 to 16x16; dragging erases a line (E)";
        default: return "Takes the color of a pixel. Left: primary, right: secondary (I)";
    }
}

void DrawMenu(Ui ui, ref Editor editor)
{
    using (ui.MenuBar())
    {
        using (ui.Menu("File"))
        {
            if (ui.MenuItem("New...", "Ctrl+N"))
                RunAction(ref editor, 2, false);
            if (ui.MenuItem("Open...", "Ctrl+O"))
                RunAction(ref editor, 1, false);
            if (editor.Loaded)
            {
                if (ui.MenuItem("Save", "Ctrl+S"))
                    SaveOrAsk(ref editor);
                if (ui.MenuItem("Save as...", "Ctrl+Shift+S"))
                    OpenSaveDialog(ref editor);
            }
            if (ui.MenuItem("Quit", "Ctrl+Q"))
                RunAction(ref editor, 3, false);
        }
        if (!editor.Loaded)
            return;
        using (ui.Menu("Edit"))
        {
            if (ui.MenuItem("Undo", "Ctrl+Z"))
                editor.DoUndo();
            if (ui.MenuItem("Redo", "Ctrl+Y"))
                editor.DoRedo();
        }
        using (ui.Menu("Image"))
        {
            if (ui.MenuItem("Normalize colors..."))
            {
                editor.DialogBpp = editor.Picture.NeededBpp() > 0 ? editor.Picture.NeededBpp() : 5;
                editor.ShowNormalize = true;
            }
            if (ui.MenuItem("Zoom 1x", "1")) editor.Zoom = 1;
            if (ui.MenuItem("Zoom 2x", "2")) editor.Zoom = 2;
            if (ui.MenuItem("Zoom 4x", "4")) editor.Zoom = 4;
            if (ui.MenuItem("Zoom 8x", "8")) editor.Zoom = 8;
            if (ui.MenuItem(editor.ShowGrid ? "Hide the grid" : "Show the grid", "G"))
                editor.ShowGrid = !editor.ShowGrid;
        }
        using (ui.Menu("Palette"))
        {
            if (ui.MenuItem("Load palette..."))
            {
                editor.DialogPath = Path.Combine(_Folder(editor.FilePath), "palette");
                editor.ShowPaletteLoad = true;
            }
            if (ui.MenuItem("Save palette..."))
            {
                editor.DialogPath = Path.Combine(_Folder(editor.FilePath), "palette");
                editor.ShowPaletteSave = true;
            }
        }
    }
}

string _Folder(string path)
{
    return path.Length == 0 ? "" : Path.GetDirectory(path);
}

void DrawToolbar(Ui ui, ref Editor editor)
{
    using (ui.Row())
    {
        foreach (var tool in [Tool.Pencil, Tool.Brush, Tool.Fill, Tool.Eraser, Tool.Picker])
        {
            string label = editor.Tool == tool ? $"[{ToolName(tool)}]" : ToolName(tool);
            if (ui.Button(label + "##tool" + ((int)tool).ToString()))
                editor.Tool = tool;
            ui.Tooltip(ToolHelp(tool));
        }
        if (editor.Tool == Tool.Brush)
        {
            ui.Label($"Size {editor.BrushSize}x{editor.BrushSize}");
            using (ui.Column(140))
            {
                ui.Slider("brushsize", ref editor.BrushSize, 2, 16);
            }
        }
        if (editor.Tool == Tool.Eraser)
        {
            ui.Label($"Size {editor.EraserSize}x{editor.EraserSize}");
            using (ui.Column(140))
            {
                ui.Slider("erasersize", ref editor.EraserSize, 1, 16);
            }
        }
        if (editor.Tool == Tool.Fill)
        {
            ui.Checkbox("Replace the color everywhere", ref editor.FillEverywhere);
        }
        ui.Label("Zoom");
        ui.Radio("1x", ref editor.Zoom, 1);
        ui.Radio("2x", ref editor.Zoom, 2);
        ui.Radio("4x", ref editor.Zoom, 4);
        ui.Radio("8x", ref editor.Zoom, 8);
    }
}

/// The picture: the tools with the mouse, frames and grid.
void DrawCanvas(Ui ui, ref Editor editor, int height)
{
    var picture = editor.Picture;
    int zoom = editor.Zoom;
    using (ui.ScrollArea("canvas", 0, height))
    {
        var area = ui.Area("picture", picture.Width * zoom, picture.Height * zoom);
        var input = ui.Input();
        bool held = ui.Held();
        bool rightHeld = ui.RightHeld();
        editor.HoverX = -1;
        editor.HoverY = -1;
        if (ui.Hovered() || held || rightHeld)
        {
            int px = (int)((int64)(input.MouseX - area.X) * picture.Width / Math.Max(1, area.Width));
            int py = (int)((int64)(input.MouseY - area.Y) * picture.Height / Math.Max(1, area.Height));
            if (input.MouseX >= area.X && input.MouseY >= area.Y && picture.Contains(px, py))
            {
                editor.HoverX = px;
                editor.HoverY = py;
            }
            ui.SetCursor(Cursor.Crosshair);
        }
        if (ui.Hovered() && input.Ctrl && input.Wheel != 0)
            editor.Zoom = input.Wheel > 0 ? Math.Min(8, editor.Zoom * 2) : Math.Max(1, editor.Zoom / 2);
        _UseTool(ref editor, input, held, rightHeld);

        var canvas = ui.Canvas();
        canvas.DrawImage(editor.CurrentView(), Rect.Create(0, 0, picture.Width, picture.Height), area);
        var clip = canvas.Clip.Intersect(area);
        if (editor.ShowGrid && zoom >= 4)
        {
            var gridColor = Color.FromArgb(0x50, 0, 0, 0);
            for (var x = 1; x < picture.Width; x += 1)
            {
                int sx = area.X + x * area.Width / picture.Width;
                if (sx >= clip.X && sx < clip.Right())
                    canvas.FillRect(Rect.Create(sx, clip.Y, 1, clip.Height), gridColor);
            }
            for (var y = 1; y < picture.Height; y += 1)
            {
                int sy = area.Y + y * area.Height / picture.Height;
                if (sy >= clip.Y && sy < clip.Bottom())
                    canvas.FillRect(Rect.Create(clip.X, sy, clip.Width, 1), gridColor);
            }
        }
        // the borders of the frames
        int frames = editor.Kind == FileKind.Amiga ? Math.Max(1, editor.Format.Frames) : 1;
        if (frames > 1 && editor.Format.Width * frames == picture.Width)
        {
            for (var f = 1; f < frames; f += 1)
            {
                int sx = area.X + f * editor.Format.Width * area.Width / picture.Width;
                canvas.FillRect(Rect.Create(sx, area.Y, 1, area.Height), Color.FromRgb(255, 80, 200));
            }
        }
        // the pixels the tool would change
        if (editor.HoverX >= 0)
        {
            int size = _ToolSize(ref editor);
            int start = -(size - 1) / 2;
            int x0 = Math.Max(0, editor.HoverX + start);
            int y0 = Math.Max(0, editor.HoverY + start);
            int x1 = Math.Min(picture.Width, editor.HoverX + start + size);
            int y1 = Math.Min(picture.Height, editor.HoverY + start + size);
            var marker = Rect.Create(area.X + x0 * area.Width / picture.Width, area.Y + y0 * area.Height / picture.Height,
                                     (x1 - x0) * area.Width / picture.Width, (y1 - y0) * area.Height / picture.Height);
            canvas.StrokeRect(marker, 1, Color.FromRgb(255, 230, 0));
        }
    }
}

void _UseTool(ref Editor editor, UiInput input, bool held, bool rightHeld)
{
    int x = editor.HoverX;
    int y = editor.HoverY;
    bool pressed = (input.MousePressed && held) || (input.RightPressed && rightHeld);
    bool secondary = rightHeld && !held;
    switch (editor.Tool)
    {
        case Tool.Pencil:
        case Tool.Brush:
        case Tool.Eraser:
        {
            if (pressed && x >= 0)
            {
                uint32 value = 0;
                if (!_ToolValue(ref editor, secondary, ref value))
                    break;
                editor.BeginChange();
                editor.Drawing = true;
                editor.DrawingSecondary = secondary;
                editor.LastX = x;
                editor.LastY = y;
                editor.Picture.Dot(x, y, value, _ToolSize(ref editor));
                editor.ViewChanged = true;
            }
            else if (editor.Drawing && (held || rightHeld) && x >= 0 && (x != editor.LastX || y != editor.LastY))
            {
                uint32 value = 0;
                if (_ToolValue(ref editor, editor.DrawingSecondary, ref value))
                {
                    editor.Picture.Line(editor.LastX, editor.LastY, x, y, value, _ToolSize(ref editor));
                    editor.ViewChanged = true;
                }
                editor.LastX = x;
                editor.LastY = y;
            }
            if (!held && !rightHeld)
                editor.Drawing = false;
            break;
        }
        case Tool.Fill:
            if (pressed && x >= 0)
            {
                uint32 value = editor.PaintValue(secondary);
                if (editor.Picture.Get(x, y) == value)
                    break;
                editor.BeginChange();
                if (editor.FillEverywhere)
                    editor.Picture.Replace(x, y, value);
                else
                    editor.Picture.Fill(x, y, value);
                editor.ViewChanged = true;
            }
            break;
        case Tool.Picker:
            if (pressed && x >= 0)
            {
                if (secondary)
                    editor.Secondary = editor.Picture.Get(x, y);
                else
                    editor.Primary = editor.Picture.Get(x, y);
            }
            break;
    }
}

int _ToolSize(ref Editor editor)
{
    if (editor.Tool == Tool.Brush)
        return editor.BrushSize;
    return editor.Tool == Tool.Eraser ? editor.EraserSize : 1;
}

// the value a drawing tool sets; false if the eraser finds no transparent color
bool _ToolValue(ref Editor editor, bool secondary, ref uint32 value)
{
    if (editor.Tool != Tool.Eraser)
    {
        value = editor.PaintValue(secondary);
        return true;
    }
    int64 transparent = editor.Picture.TransparentValue();
    if (transparent < 0)
    {
        editor.Status = "The palette has 256 colors and none of them is transparent.";
        return false;
    }
    value = (uint32)transparent;
    return true;
}

// ---- the palette ----

const int SwatchSize = 26;
const int SwatchColumns = 8;

void _Swatch(Ui ui, Rect r, uint32 argb)
{
    // transparent colors over a checkerboard
    if ((argb >> 24) < 255)
    {
        int half = r.Width / 2;
        ui.FillRect(r, Color.FromRgb(156, 156, 156));
        ui.FillRect(Rect.Create(r.X, r.Y, half, r.Height / 2), Color.FromRgb(108, 108, 108));
        ui.FillRect(Rect.Create(r.X + half, r.Y + r.Height / 2, r.Width - half, r.Height - r.Height / 2), Color.FromRgb(108, 108, 108));
    }
    if ((argb >> 24) > 0)
        ui.FillRect(r, Color.FromArgb(argb));
}

/// The side bar: the two colors, the palette, the selected color, information about the picture.
void DrawSideBar(Ui ui, ref Editor editor)
{
    var picture = editor.Picture;
    using (ui.Scroll("side", 0))
    {
        using (ui.Panel("Colors"))
        {
            using (ui.Row())
            {
                _Swatch(ui, ui.Area(36, 36), editor.ShownColor(editor.Primary));
                ui.Label(picture.Indexed ? $"Left: {editor.Primary}" : "Left");
                _Swatch(ui, ui.Area(36, 36), editor.ShownColor(editor.Secondary));
                ui.Label(picture.Indexed ? $"Right: {editor.Secondary}" : "Right");
            }
            if (ui.Button("Swap"))
            {
                uint32 primary = editor.Primary;
                editor.Primary = editor.Secondary;
                editor.Secondary = primary;
            }
        }

        using (ui.Panel(picture.Indexed ? $"Palette ({picture.Palette.Count()} colors)" : "Palette"))
        {
            if (!picture.Indexed)
            {
                ui.Text("Too many colors (more than 256). Image > Normalize colors makes a palette of 2 to 32 colors.");
            }
            else
            {
                _DrawPaletteGrid(ui, ref editor);
                _DrawColorEditor(ui, ref editor);
                if (picture.TransparentZero)
                    ui.Note("Color 0 is transparent.");
                PaletteOffsetField(ui, "paloffset", editor.PaletteBpp(), ref editor.PaletteOffset);
                ui.Tooltip("Where the colors are in a palette file of 32 colors (for loading and saving palettes)");
            }
        }

        using (ui.Panel("Picture"))
        {
            ui.Label($"{picture.Width} x {picture.Height} pixels");
            if (editor.Kind == FileKind.Amiga)
            {
                var format = editor.Format;
                ui.Label($"Amiga graphic, {_Bpp(ref editor)} BPP{(format.Slices ? ", 8 pixel slices" : "")}");
                if (format.Frames > 1)
                    ui.Label($"{format.Frames} frames of {format.Width} x {format.Height}");
            }
            else
                ui.Label(editor.Kind == FileKind.Png ? "PNG" : "BMP");
            int needed = picture.NeededBpp();
            ui.Note(needed == 0 ? "Too many colors for an Amiga graphic." : $"Fits into {needed} BPP.");
            if (editor.FilePath.Length > 0)
                ui.Note(editor.FilePath);
        }
    }
}

// the bits per pixel of an Amiga graphic (from its palette size)
int _Bpp(ref Editor editor)
{
    int count = editor.Picture.Palette.Count();
    foreach (var bpp in AllowedBpp())
    {
        if (count <= (1 << bpp))
            return bpp;
    }
    return 8;
}

void _DrawPaletteGrid(Ui ui, ref Editor editor)
{
    int count = editor.Picture.Palette.Count();
    int rows = (count + SwatchColumns - 1) / SwatchColumns;
    var area = ui.Area("palettegrid", SwatchColumns * SwatchSize, rows * SwatchSize);
    var input = ui.Input();
    int scale = Math.Max(1, area.Width / (SwatchColumns * SwatchSize));
    int size = area.Width / SwatchColumns;
    // a click: left chooses the primary color, right the secondary one
    if ((ui.Clicked() || ui.RightClicked()) && input.MouseX >= area.X && input.MouseY >= area.Y)
    {
        int index = (input.MouseX - area.X) / size + (input.MouseY - area.Y) / size * SwatchColumns;
        if (index >= 0 && index < count)
        {
            if (ui.RightClicked())
                editor.Secondary = (uint32)index;
            else
                editor.Primary = (uint32)index;
        }
    }
    for (var i = 0; i < count; i += 1)
    {
        var r = Rect.Create(area.X + (i % SwatchColumns) * size + 1, area.Y + (i / SwatchColumns) * size + 1, size - 2, size - 2);
        _Swatch(ui, r, editor.Picture.IndexColor(i));
        if (i == (int)editor.Primary || i == (int)editor.Secondary)
        {
            var outline = i == (int)editor.Primary ? Color.White() : Color.FromRgb(255, 200, 0);
            ui.Canvas().StrokeRect(Rect.Create(r.X - 1, r.Y - 1, r.Width + 2, r.Height + 2), 2 * scale, outline);
        }
    }
    ui.Note("Left click: left color, right click: right color");
}

// the color of the left button: its red, green and blue (4 bits each for Amiga graphics, else 8)
void _DrawColorEditor(Ui ui, ref Editor editor)
{
    int index = (int)editor.Primary;
    if (index < 0 || index >= editor.Picture.Palette.Count())
        return;
    uint32 color = editor.Picture.Palette[index];
    bool amiga = editor.Picture.TransparentZero;
    int max = amiga ? 15 : 255;
    int divide = amiga ? 17 : 1;
    int r = (int)((color >> 16) & 0xff) / divide;
    int g = (int)((color >> 8) & 0xff) / divide;
    int b = (int)(color & 0xff) / divide;
    int a = (int)(color >> 24);
    ui.Note($"Color {index}{(amiga ? $" (0x{ToAmigaColor(color):X3})" : $" (#{color & 0xffffff:X6})")}");
    bool changed = false;
    using (ui.Columns(2))
    {
        ui.Label("Red");   changed = ui.Slider("colr", ref r, 0, max) || changed;
        ui.Label("Green"); changed = ui.Slider("colg", ref g, 0, max) || changed;
        ui.Label("Blue");  changed = ui.Slider("colb", ref b, 0, max) || changed;
        if (!amiga)
        {
            ui.Label("Alpha"); changed = ui.Slider("cola", ref a, 0, 255) || changed;
        }
    }
    if (!ui.Input().MouseDown)
        editor.ColorEditing = false;
    if (changed)
    {
        // a drag on a slider is one undo step
        if (!editor.ColorEditing)
            editor.BeginChange();
        editor.ColorEditing = ui.Input().MouseDown;
        uint32 alpha = amiga ? (uint32)255 : (uint32)a;
        editor.Picture.Palette[index] = (alpha << 24) | ((uint32)(r * divide) << 16) | ((uint32)(g * divide) << 8) | (uint32)(b * divide);
        editor.ViewChanged = true;
    }
}

string StatusText(ref Editor editor)
{
    string text = $"{ToolName(editor.Tool)} | Zoom {editor.Zoom}x";
    if (editor.HoverX >= 0)
    {
        uint32 value = editor.Picture.Get(editor.HoverX, editor.HoverY);
        text += $" | {editor.HoverX}, {editor.HoverY}";
        text += editor.Picture.Indexed ? $" | color {value}" : $" | #{value:X8}";
        if (editor.Kind == FileKind.Amiga && editor.Format.Frames > 1 && editor.Format.Width > 0)
            text += $" | frame {editor.HoverX / editor.Format.Width + 1}";
    }
    return text;
}
