// The state of the editor: the picture, where it came from, the tools, the history and the dialogs.

using System;
using System.Image;

enum Tool : int32
{
    Pencil,
    Brush,
    Fill,
    Eraser,
    Picker
}

/// What a picture was read from and is saved as.
enum FileKind : int32
{
    Png,
    Bmp,
    Amiga
}

const int HistorySize = 64;

struct Editor
{
    // ---- the picture ----
    bool Loaded;
    Picture Picture;
    string FilePath;           // "" for a new picture
    FileKind Kind;
    AmigaFormat Format;        // how the Amiga graphic is stored (also the defaults of the dialogs)
    Image View;                // the picture as it is shown (transparent pixels as a checkerboard)
    bool ViewChanged;

    // ---- history ----
    List<Picture> Undo;
    List<Picture> Redo;
    int ChangeCounter;
    int SavedAtChange;

    // ---- tools ----
    Tool Tool;
    int BrushSize;
    bool FillEverywhere;
    uint32 Primary;            // a palette index, or ARGB for pictures with more than 256 colors
    uint32 Secondary;
    int Zoom;                  // 1, 2 or 4
    bool Drawing;
    bool DrawingSecondary;
    int LastX;
    int LastY;
    int HoverX;
    int HoverY;
    bool ShowGrid;
    bool ColorEditing;         // a slider of a color is dragged (one undo step)

    // ---- dialogs ----
    bool ShowOpen;
    bool ShowRaw;
    bool ShowSave;
    bool ShowNew;
    bool ShowNormalize;
    bool ShowUnsaved;
    bool ShowMessage;
    bool ShowPaletteLoad;
    bool ShowPaletteSave;
    bool ShowBrowse;
    string Message;
    string DialogPath;
    uint8[] RawData;           // the file that is read as an Amiga graphic
    AmigaFormat DialogFormat;
    int DialogKind;            // the format of the save dialog (FileKind)
    int DialogBpp;
    int PendingAction;         // after the unsaved changes dialog: 1 open, 2 new, 3 quit
    bool Quit;
    string Status;

    static Editor Create()
    {
        return Editor
        {
            FilePath = "",
            Kind = FileKind.Amiga,
            Format = AmigaFormat.Create(16, 16, 5),
            View = Image.Create(1, 1),
            Undo = List<Picture>.Create(),
            Redo = List<Picture>.Create(),
            BrushSize = 2,
            Primary = 1,
            Zoom = 4,
            HoverX = -1,
            HoverY = -1,
            Message = "",
            DialogPath = "",
            RawData = new uint8[0],
            DialogFormat = AmigaFormat.Create(16, 16, 5),
            DialogBpp = 5,
            Status = ""
        };
    }

    bool Dirty()
    {
        return Loaded && ChangeCounter != SavedAtChange;
    }

    // ---- pictures ----

    void _SetPicture(Picture picture, string path, FileKind kind)
    {
        Picture = picture;
        FilePath = path;
        Kind = kind;
        Loaded = true;
        Undo.Clear();
        Redo.Clear();
        ChangeCounter = 0;
        SavedAtChange = 0;
        Drawing = false;
        _ResetColors();
        View = Image.Create(picture.Width, picture.Height);
        ViewChanged = true;
    }

    void _ResetColors()
    {
        if (Picture.Indexed)
        {
            Primary = Picture.Palette.Count() > 1 ? (uint32)1 : (uint32)0;
            Secondary = 0;
        }
        else
        {
            Primary = 0xff000000u;
            Secondary = 0xffffffffu;
        }
    }

    /// A new Amiga graphic.
    void New(int width, int height, int bpp)
    {
        _SetPicture(Picture.CreateAmiga(width, height, bpp), "", FileKind.Amiga);
        Format = AmigaFormat.Create(width, height, bpp);
    }

    /// Reads a file: a PNG or BMP is opened at once; anything else needs its format (ShowRaw).
    /// @error the file cannot be read or decoded.
    Error<void> Open(string path)
    {
        if (File.ReadAllBytes(path) is not uint8[] data)
            return error($"Could not read '{path}'.");
        bool png = data.Length >= 8 && data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4e && data[3] == 0x47;
        bool bmp = data.Length >= 14 && data[0] == 0x42 && data[1] == 0x4d;
        if (png || bmp)
        {
            if (Image.Decode(data) is not Image image)
                return error($"'{path}' is no valid {(png ? "PNG" : "BMP")} file.");
            _SetPicture(Picture.FromImage(image), path, png ? FileKind.Png : FileKind.Bmp);
            return;
        }
        RawData = data;
        DialogPath = path;
        // the defaults: no preset, 5 bits per pixel, 1 frame (the size of the last graphic)
        DialogFormat = AmigaFormat.Create(Format.Width, Format.Height, 5);
        ShowRaw = true;
        return;
    }

    /// Reads the file of the format dialog as an Amiga graphic.
    /// @error the file is too short for the format.
    Error<void> OpenRaw(AmigaFormat format)
    {
        var indices = try DecodePlanar(RawData, format);
        // the palette of a new graphic of this depth (its size is 1 << bpp)
        var palette = Picture.CreateAmiga(1, 1, format.Bpp).Palette;
        _SetPicture(Picture.FromIndices(format.Width * Math.Max(1, format.Frames), format.Height, indices, palette), DialogPath, FileKind.Amiga);
        Format = format;
        RawData = new uint8[0];
        return;
    }

    /// Saves the picture: as PNG, BMP, or as an Amiga graphic in `format`.
    /// @error the picture does not fit into the format, or the file cannot be written.
    Error<void> SaveAs(string path, FileKind kind, AmigaFormat format)
    {
        if (kind == FileKind.Amiga)
        {
            if (!Picture.Indexed)
                return error("The picture has more than 256 colors: normalize the colors first (Image > Normalize colors).");
            var data = try EncodePlanar(Picture.Indices, Picture.Width, format);
            if (File.WriteAllBytes(path, data) is error)
                return error($"Could not write '{path}'.");
            Format = format;
        }
        else
        {
            var image = Picture.ToImage();
            if (image.Save(path, kind == FileKind.Png ? ImageFormat.Png : ImageFormat.Bmp) is error)
                return error($"Could not write '{path}'.");
        }
        FilePath = path;
        Kind = kind;
        SavedAtChange = ChangeCounter;
        return;
    }

    /// Saves the picture to its file in its format.
    Error<void> Save()
    {
        return SaveAs(FilePath, Kind, Format);
    }

    /// Reduces the colors to an Amiga graphic of `bpp` bits per pixel.
    void NormalizeColors(int bpp)
    {
        BeginChange();
        Picture = Normalize(Picture, bpp);
        Format.Bpp = bpp;
        if (!Format.SlicesAllowed())
            Format.Slices = false;
        _ResetColors();
        ViewChanged = true;
    }

    // ---- palette files ----

    /// Takes the colors of a palette file (as many as the palette of the picture has, at most 32).
    /// @error the file cannot be read, or the picture has no palette.
    Error<void> LoadPalette(string path)
    {
        if (!Picture.Indexed)
            return error("The picture has more than 256 colors and no palette.");
        if (File.ReadAllBytes(path) is not uint8[] data)
            return error($"Could not read '{path}'.");
        var colors = try ReadPaletteFile(data);
        BeginChange();
        for (var i = 0; i < Picture.Palette.Count() && i < colors.Length; i += 1)
            Picture.Palette[i] = colors[i];
        ViewChanged = true;
        return;
    }

    /// Saves the colors as a palette file (always 32 colors: the first 32 of the palette, black for missing ones).
    /// @error the file cannot be written, or the picture has no palette.
    Error<void> SavePalette(string path)
    {
        if (!Picture.Indexed)
            return error("The picture has more than 256 colors and no palette.");
        if (File.WriteAllBytes(path, WritePaletteFile(Picture.Palette)) is error)
            return error($"Could not write '{path}'.");
        return;
    }

    // ---- history ----

    /// Remembers the picture before a change (one undo step).
    void BeginChange()
    {
        Undo.Add(Picture.Clone());
        if (Undo.Count() > HistorySize)
            Undo.RemoveAt(0);
        Redo.Clear();
        ChangeCounter += 1;
        ViewChanged = true;
    }

    void DoUndo()
    {
        if (Undo.Count() == 0)
            return;
        Redo.Add(Picture.Clone());
        Picture = Undo[Undo.Count() - 1];
        Undo.RemoveAt(Undo.Count() - 1);
        ChangeCounter -= 1;
        _AfterHistory();
    }

    void DoRedo()
    {
        if (Redo.Count() == 0)
            return;
        Undo.Add(Picture.Clone());
        Picture = Redo[Redo.Count() - 1];
        Redo.RemoveAt(Redo.Count() - 1);
        ChangeCounter += 1;
        _AfterHistory();
    }

    void _AfterHistory()
    {
        if (View.Width != Picture.Width || View.Height != Picture.Height)
            View = Image.Create(Picture.Width, Picture.Height);
        if (Picture.Indexed && ((int)Primary >= Picture.Palette.Count() || (int)Secondary >= Picture.Palette.Count()))
            _ResetColors();
        ViewChanged = true;
    }

    // ---- the view ----

    /// The picture as it is shown: transparent pixels over a checkerboard.
    Image CurrentView()
    {
        if (!ViewChanged)
            return View;
        Picture.RenderInto(View);
        for (var y = 0; y < View.Height; y += 1)
        {
            for (var x = 0; x < View.Width; x += 1)
            {
                int i = x + y * View.Width;
                uint32 color = View.Pixels[i];
                uint32 alpha = color >> 24;
                if (alpha == 255)
                    continue;
                uint32 back = (((x >> 2) + (y >> 2)) & 1) == 0 ? (uint32)0x9c : (uint32)0x6c;
                uint32 r = (((color >> 16) & 0xff) * alpha + back * (255 - alpha)) / 255;
                uint32 g = (((color >> 8) & 0xff) * alpha + back * (255 - alpha)) / 255;
                uint32 b = ((color & 0xff) * alpha + back * (255 - alpha)) / 255;
                View.Pixels[i] = 0xff000000u | (r << 16) | (g << 8) | b;
            }
        }
        View.Changed();
        ViewChanged = false;
        return View;
    }

    /// The color a tool paints with (primary or secondary), as the picture stores it.
    uint32 PaintValue(bool secondary)
    {
        return secondary ? Secondary : Primary;
    }

    /// A color as it is shown (a palette index or ARGB).
    uint32 ShownColor(uint32 value)
    {
        return Picture.Indexed ? Picture.IndexColor((int)value) : value;
    }
}
