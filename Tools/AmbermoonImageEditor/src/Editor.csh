// The state of the editor: the picture, where it came from, the tools, the history and the dialogs.

using System;
using System.Image;
using Ambermoon.Data.Legacy.Serialization;

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
    int BrushSize;             // 2 to 16
    int EraserSize;            // 1 to 16
    bool FillEverywhere;
    uint32 Primary;            // a palette index, or ARGB for pictures with more than 256 colors
    uint32 Secondary;
    int Zoom;                  // 1, 2, 4, 8, 16 or 32
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
    bool ShowContainer;        // the choice of a file of a container
    bool ShowPaletteChoice;    // the choice of a palette of Palettes.amb
    ChoicePurpose Choice;
    int ChoiceSelection;
    GameFile SourceFile;       // the container a graphic is chosen from
    List<uint32[]> PaletteChoices;
    MonsterGraphic Monster;    // the monster whose palette is chosen
    string Message;
    string DialogPath;
    uint8[] RawData;           // the file that is read as an Amiga graphic
    AmigaFormat DialogFormat;  // the format of the save and new dialogs
    AmigaFormat RawFormat;     // the format of the open dialog: 16 x 16, 5 BPP, 1 frame at first, then the last one
    int RawOffset;             // its palette offset
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
            EraserSize = 1,
            Primary = 1,
            Zoom = 4,
            HoverX = -1,
            HoverY = -1,
            Message = "",
            DialogPath = "",
            RawData = new uint8[0],
            DialogFormat = AmigaFormat.Create(16, 16, 5),
            RawFormat = AmigaFormat.Create(16, 16, 5),
            PreviewKey = "",
            SourceFile = GameFile { Path = "", Files = Dictionary<int, uint8[]>.Create(), Numbers = new int[0] },
            PaletteChoices = List<uint32[]>.Create(),
            Monster = MonsterGraphic { Name = "", Data = new uint8[0], Mapping = new uint8[32] },
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
        // a container of the game: first the choice of its file (a monster of Monster_char.amb: then its palette)
        if (IsContainer(data))
        {
            SourceFile = try ReadGameFile(path, data);
            if (SourceFile.Numbers.Length == 0)
                return error($"'{path}' is an empty container.");
            Choice = IsMonsterFile(path) ? ChoicePurpose.Monster : ChoicePurpose.Graphic;
            ChoiceSelection = 0;
            ShowContainer = true;
            return;
        }
        // an encrypted or compressed single file (e.g. Object_icons): its decoded data
        if (IsEncoded(data))
        {
            var file = try ReadGameFile(path, data);
            if (file.Numbers.Length == 0)
                return error($"'{path}' is empty.");
            PrepareRawDialog(ref this, path, path, file.Files[file.Numbers[0]]);
            return;
        }
        // any other file: the format dialog (with the preset of the name of the file, else the last values)
        PrepareRawDialog(ref this, path, path, data);
        return;
    }

    /// The picture of the monster with the chosen palette.
    /// @error the graphic does not fit its size.
    Error<void> OpenMonster(uint32[] palette)
    {
        var picture = try MonsterPicture(Monster, palette);
        _SetPicture(picture, $"{SourceFile.Path} #{Monster.Name}", FileKind.Amiga);
        Format = AmigaFormat.Create(Monster.MappedWidth, Monster.MappedHeight, 5);
        Format.Frames = Math.Max(1, picture.Width / Math.Max(1, Monster.MappedWidth));
        Format.Preset = 10;
        // the picture has no file of its own: saving asks where
        FilePath = "";
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
        var palettes = try ReadPalettes(path);
        if (palettes.Count() == 1)
        {
            ApplyPalette(palettes[0]);
            return;
        }
        // a container like Palettes.amb: the palette is chosen
        PaletteChoices = palettes;
        Choice = ChoicePurpose.PaletteLoad;
        ChoiceSelection = 0;
        ShowPaletteChoice = true;
        return;
    }

    /// Takes the colors of a palette of 32 colors from the palette offset on.
    void ApplyPalette(uint32[] colors)
    {
        BeginChange();
        for (var i = 0; i < Picture.Palette.Count() && PaletteOffset + i < colors.Length; i += 1)
            Picture.Palette[i] = colors[PaletteOffset + i];
        ViewChanged = true;
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
