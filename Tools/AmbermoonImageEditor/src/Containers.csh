// The files of the game: containers (AMNC, AMNP, AMBR, AMPC) and single files (JH, LOB) are decoded with the readers
// of Ambermoon.Data.Legacy. A graphic of a container is chosen by its number; the preset comes from the name of the
// file. Palettes can be taken from Palettes.amb, and the monsters of Monster_char.amb are opened with their graphic
// from Monster_gfx.amb (its size, palette mapping and scaling from the monster data).

using System;
using System.Image;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Legacy.Characters;

/// What the file choice of a container and the palette choice are for.
enum ChoicePurpose : int32
{
    Graphic,         // a graphic of a container (then the format dialog)
    Monster,         // a monster of Monster_char.amb (then the palette)
    PaletteLoad,     // a palette of a palette container for the picture
    MonsterPalette   // the palette of the monster graphic
}

/// A file that was decoded: its subfiles by number.
struct GameFile
{
    string Path;
    bool Container;
    Dictionary<int, uint8[]> Files;
    int[] Numbers;
}

/// The monster that is opened: its graphic and how it is shown.
struct MonsterGraphic
{
    string Name;
    uint8[] Data;           // the file of Monster_gfx.amb
    int FrameWidth;         // stored
    int FrameHeight;
    int MappedWidth;        // shown
    int MappedHeight;
    uint8[] Mapping;        // 32 palette indices
}

/// Decodes a file of the game (also a raw file: one subfile).
/// @error the file cannot be read or decoded.
Error<GameFile> ReadGameFile(string path, uint8[] data)
{
    var container = try FileReader.ReadRawFile(Path.GetFileName(path), data);
    var files = Dictionary<int, uint8[]>.Create();
    foreach (var number in container.Numbers())
        files[number] = container.Files[number].ToArray();
    var type = container.FileType;
    bool isContainer = type == FileType.AMNC || type == FileType.AMNP || type == FileType.AMBR || type == FileType.AMPC;
    return GameFile { Path = path, Container = isContainer, Files = files, Numbers = container.Numbers() };
}

/// Whether a file is a container of the game (by its first 4 bytes).
bool IsContainer(uint8[] data)
{
    if (data.Length < 6)
        return false;
    uint32 header = ((uint32)data[0] << 24) | ((uint32)data[1] << 16) | ((uint32)data[2] << 8) | (uint32)data[3];
    var type = (FileType)header;
    return type == FileType.AMNC || type == FileType.AMNP || type == FileType.AMBR || type == FileType.AMPC;
}

/// Whether a file is a single file of the game that is encrypted or compressed (JH, LOB, VOL1).
bool IsEncoded(uint8[] data)
{
    if (data.Length < 4)
        return false;
    uint32 header = ((uint32)data[0] << 24) | ((uint32)data[1] << 16) | ((uint32)data[2] << 8) | (uint32)data[3];
    return (header & 0xffff0000) == (uint32)FileType.JH || header == (uint32)FileType.LOB || header == (uint32)FileType.VOL1;
}

/// The preset of a file of the game by its name, or the name of the folder of an extracted file (0: none known).
int PresetForFile(string path)
{
    string name = path.ToLower();
    if (name.Contains("wall3d")) return 1;
    if (name.Contains("object3d")) return 2;
    if (name.Contains("overlay3d")) return 3;
    if (name.Contains("floors")) return 4;
    if (name.Contains("object_icons")) return 5;
    if (name.Contains("icon_gfx")) return 6;
    if (name.Contains("portraits")) return 8;
    if (name.Contains("pics_80x80")) return 9;
    if (name.Contains("monster_gfx")) return 10;
    return 0;
}

bool IsMonsterFile(string path)
{
    return Path.GetFileName(path).ToLower().StartsWith("monster_char");
}

/// The format dialog for a graphic of a file of the game: the preset of its name is chosen (with as many frames as
/// fit if the preset fixes the size); without one the dialog keeps its last values.
void PrepareRawDialog(ref Editor editor, string path, string presetPath, uint8[] data)
{
    editor.RawData = data;
    editor.DialogPath = path;
    int preset = PresetForFile(presetPath);
    if (preset > 0)
    {
        var format = editor.RawFormat;
        format.Preset = preset;
        format = ApplyPreset(format);
        var chosen = Presets()[preset];
        format.Frames = 1;
        if (chosen.Width > 0 && chosen.Height > 0 && format.FrameSize() > 0)
            format.Frames = Math.Max(1, data.Length / format.FrameSize());
        editor.RawFormat = format;
    }
    editor.PreviewKey = "";
    editor.ShowRaw = true;
}

/// The labels of the files of a container: number and size (monsters with their names).
List<string> ContainerLabels(GameFile file)
{
    var labels = List<string>.Create();
    bool monsters = IsMonsterFile(file.Path);
    foreach (var number in file.Numbers)
    {
        var data = file.Files[number];
        string label = $"{number:D3}  ({data.Length} bytes)";
        if (monsters && data.Length >= 0x112 + 16)
            label = $"{number:D3}  {_CharacterName(data)}";
        labels.Add(label);
    }
    return labels;
}

string _CharacterName(uint8[] data)
{
    var reader = DataReader.FromData(data);
    reader.Position = 0x112;
    string text = reader.ReadString(16);
    int end = 0;
    while (end < text.Length && text[end] != 0)
        end += 1;
    while (end > 0 && text[end - 1] == ' ')
        end -= 1;
    return text[0..end].ToString();
}

/// The file of a container that was chosen.
/// @error a monster or its graphic cannot be read.
Error<void> ChooseContainerFile(ref Editor editor, int number)
{
    var file = editor.SourceFile;
    if (file.Files.TryGet(number) is not uint8[] data)
        return error($"The container has no file {number}.");
    if (editor.Choice == ChoicePurpose.Monster)
    {
        // the graphics and the palettes: next to Monster_char.amb, or chosen by the user when they are not there
        string graphicsPath = _Neighbour(editor.MonsterGfxPath, file.Path, "Monster_gfx.amb");
        string palettesPath = _Neighbour(editor.PalettesPath, file.Path, "Palettes.amb");
        if (graphicsPath.Length == 0 || palettesPath.Length == 0)
        {
            editor.LocateName = graphicsPath.Length == 0 ? "Monster_gfx.amb" : "Palettes.amb";
            editor.LocateNumber = number;
            editor.DialogPath = Path.Combine(_FolderOf(file.Path), editor.LocateName);
            editor.ShowLocate = true;
            return;
        }
        editor.Monster = try ReadMonsterGraphic(graphicsPath, number, data);
        editor.PaletteChoices = try ReadPalettes(palettesPath);
        editor.Choice = ChoicePurpose.MonsterPalette;
        editor.ChoiceSelection = 0;
        editor.ShowPaletteChoice = true;
        return;
    }
    PrepareRawDialog(ref editor, $"{file.Path} #{number}", file.Path, data);
    return;
}

// a file that a container needs: the one the user chose, else the file of that name next to the container (the case of
// the name does not matter); "" if there is none
string _Neighbour(string chosen, string container, string name)
{
    if (chosen.Length > 0 && File.Exists(chosen))
        return chosen;
    string folder = _FolderOf(container);
    string exact = Path.Combine(folder, name);
    if (File.Exists(exact))
        return exact;
    foreach (var entry in Directory.GetEntries(folder))
    {
        if (entry.ToLower() == name.ToLower())
            return Path.Combine(folder, entry);
    }
    return "";
}

string _FolderOf(string path)
{
    string folder = Path.GetDirectory(path);
    return folder.Length == 0 ? "." : folder;
}

/// A monster of Monster_char.amb with its graphic of Monster_gfx.amb.
/// @error the monster data is damaged, or Monster_gfx.amb or the graphic is missing.
Error<MonsterGraphic> ReadMonsterGraphic(string graphicsPath, int number, uint8[] data)
{
    var reader = DataReader.FromData(data);
    var monster = try MonsterReader.ReadMonster((uint32)number, ref reader, null);
    if (File.ReadAllBytes(graphicsPath) is not uint8[] graphicsData)
        return error($"Could not read '{graphicsPath}' (the graphics of the monsters).");
    var graphics = try ReadGameFile(graphicsPath, graphicsData);
    int graphicIndex = (int)monster.Character.CombatGraphicIndex;
    if (graphics.Files.TryGet(graphicIndex) is not uint8[] graphic)
        return error($"Monster_gfx.amb has no graphic {graphicIndex}.");
    if (monster.FrameWidth == 0 || monster.FrameHeight == 0)
        return error("The monster has no size of its frames.");
    return MonsterGraphic
    {
        Name = monster.Character.Name,
        Data = graphic,
        FrameWidth = (int)monster.FrameWidth,
        FrameHeight = (int)monster.FrameHeight,
        MappedWidth = monster.MappedFrameWidth == 0 ? (int)monster.FrameWidth : (int)monster.MappedFrameWidth,
        MappedHeight = monster.MappedFrameHeight == 0 ? (int)monster.FrameHeight : (int)monster.MappedFrameHeight,
        Mapping = monster.MonsterPalette
    };
}

/// The picture of a monster graphic: 5 bits per pixel, as many frames as the file has, every color through the
/// palette mapping of the monster, each frame scaled to the shown size, with the colors of a palette.
/// @error the graphic is too small for one frame.
Error<Picture> MonsterPicture(MonsterGraphic monster, uint32[] palette)
{
    var format = AmigaFormat.Create(monster.FrameWidth, monster.FrameHeight, 5);
    int frames = monster.Data.Length / format.FrameSize();
    if (frames == 0)
        return error($"The graphic has {monster.Data.Length} bytes, one frame of {monster.FrameWidth} x {monster.FrameHeight} needs {format.FrameSize()}.");
    format.Frames = frames;
    var stored = try DecodePlanar(monster.Data, format);
    int storedWidth = monster.FrameWidth * frames;
    int width = monster.MappedWidth * frames;
    int height = monster.MappedHeight;
    var indices = new uint8[width * height];
    for (var f = 0; f < frames; f += 1)
    {
        for (var y = 0; y < height; y += 1)
        {
            int sy = y * monster.FrameHeight / height;
            for (var x = 0; x < monster.MappedWidth; x += 1)
            {
                int sx = f * monster.FrameWidth + x * monster.FrameWidth / monster.MappedWidth;
                int index = (int)stored[sx + sy * storedWidth];
                // color 0 stays transparent
                indices[f * monster.MappedWidth + x + y * width] = index == 0 ? (uint8)0 : (uint8)((int)monster.Mapping[index & 0x1f] & 0x1f);
            }
        }
    }
    var colors = List<uint32>.Create();
    for (var i = 0; i < PaletteFileColors; i += 1)
        colors.Add(i < palette.Length ? palette[i] : 0xff000000u);
    return Picture.FromIndices(width, height, indices, colors);
}

/// The palettes of a palette file: a container like Palettes.amb (each file 32 colors), or one palette file.
/// @error the file cannot be read or has no palette.
Error<List<uint32[]>> ReadPalettes(string path)
{
    if (File.ReadAllBytes(path) is not uint8[] data)
        return error($"Could not read '{path}'.");
    var palettes = List<uint32[]>.Create();
    bool png = data.Length >= 8 && data[0] == 0x89 && data[1] == 0x50 && data[2] == 0x4e && data[3] == 0x47;
    bool bmp = data.Length >= 14 && data[0] == 0x42 && data[1] == 0x4d;
    if (png || bmp)
    {
        // a picture: each pixel is a color (row by row), the first 32, black for the rest
        if (Image.Decode(data) is not Image image)
            return error($"'{Path.GetFileName(path)}' is no valid {(png ? "PNG" : "BMP")} file.");
        var colors = new uint32[PaletteFileColors];
        for (var i = 0; i < PaletteFileColors; i += 1)
            colors[i] = i < image.Pixels.Length ? image.Pixels[i] | 0xff000000u : 0xff000000u;
        palettes.Add(colors);
        return palettes;
    }
    if (data.Length == 2 * PaletteFileColors && !IsContainer(data) && !IsEncoded(data))
    {
        palettes.Add(try ReadPaletteFile(data));
        return palettes;
    }
    var file = try ReadGameFile(path, data);
    foreach (var number in file.Numbers)
    {
        var colors = file.Files[number];
        if (colors.Length >= 2 * PaletteFileColors)
        {
            var exact = new uint8[2 * PaletteFileColors];
            Array.Copy(colors, 0, exact, 0, exact.Length);
            palettes.Add(try ReadPaletteFile(exact));
        }
    }
    if (palettes.Count() == 0)
        return error($"'{Path.GetFileName(path)}' has no palette (32 colors of 16 bits).");
    return palettes;
}
