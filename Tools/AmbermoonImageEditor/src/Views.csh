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
        case Tool.Picker: return "Picker";
        default: return "Select";
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
        case Tool.Picker: return "Takes the color of a pixel. Left: primary, right: secondary (I)";
        default: return "A rectangle; dragging inside it moves the pixels. Ctrl+C/X/V, Del, Ctrl+A, Esc (S)";
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
            ui.Separator();
            if (ui.MenuItem("Cut", "Ctrl+X"))
                Cut(ref editor);
            if (ui.MenuItem("Copy", "Ctrl+C"))
                Copy(ref editor);
            if (editor.HasClipboard && ui.MenuItem("Paste", "Ctrl+V"))
                Paste(ref editor);
            if (ui.MenuItem("Delete", "Del"))
                DeleteSelection(ref editor);
            ui.Separator();
            if (ui.MenuItem("Select all", "Ctrl+A"))
                SelectAll(ref editor);
            if (editor.HasSelection && ui.MenuItem("Select nothing", "Esc"))
                Deselect(ref editor);
        }
        using (ui.Menu("Image"))
        {
            if (ui.MenuItem("Normalize colors..."))
            {
                editor.DialogBpp = editor.Picture.NeededBpp() > 0 ? editor.Picture.NeededBpp() : 5;
                editor.ShowNormalize = true;
            }
            ui.Separator();
            // the selection, or else each frame
            if (ui.MenuItem("Mirror left/right", "H"))
                _Transform(ref editor, Transform.FlipHorizontal);
            if (ui.MenuItem("Mirror top/bottom", "V"))
                _Transform(ref editor, Transform.FlipVertical);
            if (ui.MenuItem("Rotate right", "R"))
                _Transform(ref editor, Transform.RotateClockwise);
            if (ui.MenuItem("Rotate left", "Shift+R"))
                _Transform(ref editor, Transform.RotateCounterclockwise);
            if (editor.HasSelection && ui.MenuItem("Crop to the selection"))
                CropToSelection(ref editor);
            if (ui.MenuItem("Resize..."))
            {
                editor.ResizeWidth = editor.Picture.FrameWidth();
                editor.ResizeHeight = editor.Picture.Height;
                editor.ShowResize = true;
            }
            ui.Separator();
            if (ui.MenuItem("Zoom 1x", "1")) editor.Zoom = 1;
            if (ui.MenuItem("Zoom 2x", "2")) editor.Zoom = 2;
            if (ui.MenuItem("Zoom 4x", "4")) editor.Zoom = 4;
            if (ui.MenuItem("Zoom 8x", "8")) editor.Zoom = 8;
            if (ui.MenuItem("Zoom 16x")) editor.Zoom = 16;
            if (ui.MenuItem("Zoom 32x")) editor.Zoom = 32;
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

void _Transform(ref Editor editor, Transform transform)
{
    if (TransformPicture(ref editor, transform) is error e)
        ShowError(ref editor, e.Message);
}

string _Folder(string path)
{
    return path.Length == 0 ? "" : Path.GetDirectory(path);
}

void DrawToolbar(Ui ui, ref Editor editor)
{
    using (ui.Row())
    {
        foreach (var tool in [Tool.Pencil, Tool.Brush, Tool.Fill, Tool.Eraser, Tool.Picker, Tool.Select])
        {
            string label = editor.Tool == tool ? $"[{ToolName(tool)}]" : ToolName(tool);
            if (ui.Button(label + "##tool" + ((int)tool).ToString()))
                editor.Tool = tool;
            ui.Tooltip(ToolHelp(tool));
        }
        if (editor.Tool == Tool.Select)
        {
            if (ui.Checkbox("Transparent", ref editor.PasteTransparent))
                editor.FloatChanged = true;
            ui.Tooltip("Transparent pixels of a pasted or moved part leave the picture below as it is");
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
        ui.Radio("16x", ref editor.Zoom, 16);
        ui.Radio("32x", ref editor.Zoom, 32);
    }
}

/// The picture (or only its current frame): the tools with the mouse, frames, grid, the selection and a floating part.
void DrawCanvas(Ui ui, ref Editor editor, int height)
{
    // other tools than Select place a floating part and forget the selection
    if (editor.Tool != Tool.Select && (editor.Floating || editor.HasSelection))
        Deselect(ref editor);
    var picture = editor.Picture;
    int zoom = editor.Zoom;
    int fw = picture.FrameWidth();
    bool single = editor.SingleFrame && picture.Frames > 1;
    // the columns that are shown
    int left = single ? editor.CurrentFrame * fw : 0;
    int width = single ? fw : picture.Width;
    using (ui.ScrollArea("canvas", 0, height))
    {
        var area = ui.Area("picture", width * zoom, picture.Height * zoom);
        var input = ui.Input();
        bool held = ui.Held();
        bool rightHeld = ui.RightHeld();
        bool clicked = ui.Clicked();
        bool rightClicked = ui.RightClicked();
        editor.HoverX = -1;
        editor.HoverY = -1;
        // the pixel under the mouse (also outside of the picture while a rectangle or a part is dragged)
        int mx = left + _Floor((int64)(input.MouseX - area.X) * width, Math.Max(1, area.Width));
        int my = _Floor((int64)(input.MouseY - area.Y) * picture.Height, Math.Max(1, area.Height));
        if (ui.Hovered() || held || rightHeld || clicked || rightClicked)
        {
            if (mx >= left && mx < left + width && my >= 0 && my < picture.Height)
            {
                editor.HoverX = mx;
                editor.HoverY = my;
            }
            ui.SetCursor(Cursor.Crosshair);
        }
        if (ui.Hovered() && input.Ctrl && input.Wheel != 0)
            editor.Zoom = input.Wheel > 0 ? Math.Min(32, editor.Zoom * 2) : Math.Max(1, editor.Zoom / 2);
        // the tools only change the frame that is shown
        editor.Picture.ClipLeft = left;
        editor.Picture.ClipRight = left + width;
        if (editor.Tool == Tool.Select)
            _UseSelect(ref editor, input, held, clicked, mx, my, left, width);
        else
            _UseTool(ref editor, input, held, rightHeld, clicked, rightClicked);
        editor.Picture.ClipLeft = 0;
        editor.Picture.ClipRight = int.MaxValue;
        picture = editor.Picture;

        var canvas = ui.Canvas();
        canvas.DrawImage(editor.CurrentView(), Rect.Create(left, 0, width, picture.Height), area);
        var clip = canvas.Clip.Intersect(area);
        if (editor.ShowGrid && zoom >= 4)
        {
            var gridColor = Color.FromArgb(0x50, 0, 0, 0);
            for (var x = 1; x < width; x += 1)
            {
                int sx = area.X + x * area.Width / width;
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
        if (!single && picture.Frames > 1)
        {
            for (var f = 1; f < picture.Frames; f += 1)
            {
                int sx = area.X + f * fw * area.Width / width;
                canvas.FillRect(Rect.Create(sx, area.Y, 1, area.Height), Color.FromRgb(255, 80, 200));
            }
        }
        // the floating part and the rectangle of the selection
        if (editor.Floating)
        {
            var image = _FloatImage(ref editor);
            var target = _ScreenRect(area, left, width, picture.Height, editor.FloatX, editor.FloatY, editor.FloatPic.Width, editor.FloatPic.Height);
            canvas.DrawImage(image, Rect.Create(0, 0, image.Width, image.Height), target);
        }
        if (editor.HasSelection || editor.Floating)
        {
            var r = editor.Floating
                ? _ScreenRect(area, left, width, picture.Height, editor.FloatX, editor.FloatY, editor.FloatPic.Width, editor.FloatPic.Height)
                : _ScreenRect(area, left, width, picture.Height, editor.SelX, editor.SelY, editor.SelW, editor.SelH);
            canvas.StrokeRect(Rect.Create(r.X - 1, r.Y - 1, r.Width + 2, r.Height + 2), 1, Color.Black());
            canvas.StrokeRect(r, 1, Color.White());
        }
        // the pixels the tool would change
        if (editor.HoverX >= 0 && editor.Tool != Tool.Select)
        {
            int size = _ToolSize(ref editor);
            int start = -(size - 1) / 2;
            int x0 = Math.Max(left, editor.HoverX + start);
            int y0 = Math.Max(0, editor.HoverY + start);
            int x1 = Math.Min(left + width, editor.HoverX + start + size);
            int y1 = Math.Min(picture.Height, editor.HoverY + start + size);
            var marker = _ScreenRect(area, left, width, picture.Height, x0, y0, x1 - x0, y1 - y0);
            canvas.StrokeRect(marker, 1, Color.FromRgb(255, 230, 0));
        }
    }
}

// floor division (negative values round down: the mouse left of or above the picture)
int _Floor(int64 a, int b)
{
    int64 q = a / b;
    if (a % b != 0 && (a < 0) != (b < 0))
        q -= 1;
    return (int)q;
}

// a rectangle of pixels of the picture on the screen
Rect _ScreenRect(Rect area, int left, int width, int height, int x, int y, int w, int h)
{
    int x0 = area.X + (int)((int64)(x - left) * area.Width / width);
    int y0 = area.Y + (int)((int64)y * area.Height / height);
    int x1 = area.X + (int)((int64)(x + w - left) * area.Width / width);
    int y1 = area.Y + (int)((int64)(y + h) * area.Height / height);
    return Rect.Create(x0, y0, x1 - x0, y1 - y0);
}

// the image of the floating part (transparent pixels as a checkerboard, or left out for a transparent paste)
Image _FloatImage(ref Editor editor)
{
    if (!editor.FloatChanged && editor.FloatView.Width == editor.FloatPic.Width && editor.FloatView.Height == editor.FloatPic.Height)
        return editor.FloatView;
    editor.FloatView = Image.Create(editor.FloatPic.Width, editor.FloatPic.Height);
    editor.FloatPic.RenderInto(editor.FloatView);
    if (!editor.PasteTransparent)
        CheckerBehind(editor.FloatView);
    editor.FloatView.Changed();
    editor.FloatChanged = false;
    return editor.FloatView;
}

// the Select tool: a press in the floating part (or the selection) drags it, elsewhere starts a new rectangle
void _UseSelect(ref Editor editor, UiInput input, bool held, bool clicked, int mx, int my, int left, int width)
{
    bool pressed = input.MousePressed && (held || clicked);
    var picture = editor.Picture;
    if (pressed && editor.HoverX >= 0)
    {
        bool inFloat = editor.Floating && mx >= editor.FloatX && my >= editor.FloatY &&
                       mx < editor.FloatX + editor.FloatPic.Width && my < editor.FloatY + editor.FloatPic.Height;
        bool inSelection = !editor.Floating && editor.HasSelection && mx >= editor.SelX && my >= editor.SelY &&
                           mx < editor.SelX + editor.SelW && my < editor.SelY + editor.SelH;
        if (inSelection)
        {
            LiftSelection(ref editor);
            inFloat = true;
        }
        if (inFloat)
        {
            editor.Moving = true;
            editor.MoveOffsetX = mx - editor.FloatX;
            editor.MoveOffsetY = my - editor.FloatY;
        }
        else
        {
            Deselect(ref editor);
            editor.Selecting = true;
            editor.SelStartX = mx;
            editor.SelStartY = my;
            editor.HasSelection = true;
            editor.SelX = mx;
            editor.SelY = my;
            editor.SelW = 1;
            editor.SelH = 1;
        }
    }
    else if (held && editor.Moving)
    {
        editor.FloatX = mx - editor.MoveOffsetX;
        editor.FloatY = my - editor.MoveOffsetY;
        editor.SelX = editor.FloatX;
        editor.SelY = editor.FloatY;
    }
    else if (held && editor.Selecting)
    {
        // the rectangle from where it began to the pixel under the mouse, inside of what is shown
        int x0 = Math.Max(left, Math.Min(editor.SelStartX, mx));
        int y0 = Math.Max(0, Math.Min(editor.SelStartY, my));
        int x1 = Math.Min(left + width - 1, Math.Max(editor.SelStartX, mx));
        int y1 = Math.Min(picture.Height - 1, Math.Max(editor.SelStartY, my));
        editor.SelX = x0;
        editor.SelY = y0;
        editor.SelW = Math.Max(1, x1 - x0 + 1);
        editor.SelH = Math.Max(1, y1 - y0 + 1);
    }
    if (!held)
    {
        editor.Moving = false;
        editor.Selecting = false;
    }
}

void _UseTool(ref Editor editor, UiInput input, bool held, bool rightHeld, bool clicked, bool rightClicked)
{
    int x = editor.HoverX;
    int y = editor.HoverY;
    // a press, also one that is released in the same frame (a quick click while frames are slow: in the browser, on
    // the Amiga)
    bool left = input.MousePressed && (held || clicked);
    bool right = input.RightPressed && (rightHeld || rightClicked);
    bool pressed = left || right;
    bool secondary = right && !left;
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
        default:
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

        DrawFramesPanel(ui, ref editor);

        using (ui.Panel("Picture"))
        {
            ui.Label($"{picture.Width} x {picture.Height} pixels");
            if (editor.Kind == FileKind.Amiga)
            {
                var format = editor.Format;
                ui.Label($"Amiga graphic, {_Bpp(ref editor)} BPP{(format.Slices ? ", 8 pixel slices" : "")}");
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
        if (editor.Picture.Frames > 1)
            text += $" | frame {editor.HoverX / editor.Picture.FrameWidth() + 1}";
    }
    if (editor.HasSelection || editor.Floating)
        text += $" | selection {(editor.Floating ? editor.FloatX : editor.SelX)}, {(editor.Floating ? editor.FloatY : editor.SelY)} {(editor.Floating ? editor.FloatPic.Width : editor.SelW)} x {(editor.Floating ? editor.FloatPic.Height : editor.SelH)}";
    return text;
}
