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
    int PaletteOffset;         // where the colors are in a palette file of 32 colors (0; 4 BPP: 0 or 16; 3 BPP: 0, 16 or 24)
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
    int Zoom;                  // 1, 2, 4 or 8
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
    int DialogOffset;          // the palette offset of the format dialog
    string PreviewKey;         // the format the preview of the format dialog was made for
    Image Preview;
    string PreviewError;
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
            PreviewKey = "",
            Preview = Image.Create(1, 1),
            PreviewError = "",
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
        PaletteOffset = 0;
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
        DialogOffset = 0;
        PreviewKey = "";
        ShowRaw = true;
        return;
    }

    /// Reads the file of the format dialog as an Amiga graphic.
    /// @error the file is too short for the format.
    Error<void> OpenRaw(AmigaFormat format, int paletteOffset)
    {
        var picture = try RawPicture(RawData, format, paletteOffset);
        _SetPicture(picture, DialogPath, FileKind.Amiga);
        Format = format;
        PaletteOffset = PaletteOffsets(format.Bpp).Contains(paletteOffset) ? paletteOffset : 0;
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
        PaletteOffset = 0;
        _ResetColors();
        ViewChanged = true;
    }

    // ---- palette files ----

    /// Takes the colors of a palette file from the palette offset on (as many as the palette of the picture has).
    /// @error the file cannot be read, or the picture has no palette.
    Error<void> LoadPalette(string path)
    {
        if (!Picture.Indexed)
            return error("The picture has more than 256 colors and no palette.");
        if (File.ReadAllBytes(path) is not uint8[] data)
            return error($"Could not read '{path}'.");
        var colors = try ReadPaletteFile(data);
        BeginChange();
        for (var i = 0; i < Picture.Palette.Count() && PaletteOffset + i < colors.Length; i += 1)
            Picture.Palette[i] = colors[PaletteOffset + i];
        ViewChanged = true;
        return;
    }

    /// Saves the colors as a palette file: always 32 colors, those of the picture from the palette offset on, black for
    /// the others.
    /// @error the file cannot be written, or the picture has no palette.
    Error<void> SavePalette(string path)
    {
        if (!Picture.Indexed)
            return error("The picture has more than 256 colors and no palette.");
        if (File.WriteAllBytes(path, WritePaletteFile(Picture.Palette, PaletteOffset)) is error)
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
        CheckerBehind(View);
        View.Changed();
        ViewChanged = false;
        return View;
    }

    /// The bits per pixel the palette offset depends on: those of an Amiga graphic (by the size of its palette), 0 for
    /// other pictures.
    int PaletteBpp()
    {
        if (!Picture.Indexed || !Picture.TransparentZero)
            return 0;
        int count = Picture.Palette.Count();
        return count == 8 ? 3 : count == 16 ? 4 : count == 2 ? 1 : count == 32 ? 5 : 0;
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

/// An Amiga graphic of a file in a format, with the colors of the default palette from the palette offset on.
/// @error the file is too short for the format.
Error<Picture> RawPicture(uint8[] data, AmigaFormat format, int paletteOffset)
{
    var indices = try DecodePlanar(data, format);
    return Picture.FromIndices(format.Width * Math.Max(1, format.Frames), format.Height, indices, AmigaPalette(format.Bpp, paletteOffset));
}
