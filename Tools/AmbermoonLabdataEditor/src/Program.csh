//! AmbermoonLabdataEditor: shows and edits the walls, objects and object data of a labyrinth data file (a port of
//! AmbermoonTools/AmbermoonLabdataEditor).
//!
//!   AmbermoonLabdataEditor <labdataFilePath> <gameDataPath>
namespace AmbermoonLabdataEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

// the flags that walls and objects may have, with their names (in this order)
const ReadOnlySlice<uint32> WallFlagValues = [0x01, 0x02, 0x08, 0x10, 0x80, 0x100, 0x200, 0x400];
const ReadOnlySlice<string> WallFlagNames =
[
    "Alternate Animation", "Block Sight", "Transparency", "Random Animation Start", "Block All Movement",
    "Allow Player Move", "Allow Monster 1 Move", "Allow Monster 2 Move"
];
const ReadOnlySlice<uint32> ObjectFlagValues = [0x01, 0x02, 0x08, 0x10, 0x80, 0x100, 0x200, 0x400];
const ReadOnlySlice<string> ObjectFlagNames =
[
    "Alternate Animation", "Block Sight", "Floor / Ceiling", "Random Animation Start", "Block All Movement",
    "Allow Player Move", "Allow Monster 1 Move", "Allow Monster 2 Move"
];

// the labyrinth data being edited and its file
Labdata Lab = Labdata.Create();
string LabdataPath = "";

int Main(string[] args)
{
    if (args.Length != 2)
    {
        Console.WriteLine("Usage: AmbermoonLabdataEditor <labdataFilePath> <gameDataPath>");
        Console.WriteLine();
        Console.WriteLine("labdataFilePath: Path to the extracted single labdata file.");
        Console.WriteLine("gameDataPath:    Path to Ambermoon data (Amberfiles folder).");
        Console.WriteLine();
        return 0;
    }

    var gameData = GameData.Create(LoadPreference.PreferExtracted, false);
    if (gameData.Load(args[1]) is error loadError)
    {
        Console.WriteLine(loadError.Message);
        return 1;
    }

    LabdataPath = args[0];
    if (File.ReadAllBytes(LabdataPath) is not uint8[] bytes)
    {
        Console.WriteLine($"Could not find file '{Path.GetFullPath(LabdataPath)}'.");
        return 1;
    }
    var reader = DataReader.FromData(bytes);
    // (the original also reads the graphics: it fails when a texture is missing)
    var read = LabdataReader.ReadLabdata(ref reader, gameData);
    if (read is error readError)
    {
        Console.WriteLine(readError.Message);
        return 1;
    }
    if (read is not Labdata labdata)
        return 1;
    Lab = labdata;

    PrintHelp(false);

    while (true)
    {
        Console.Write("Enter command: ");
        string command = ToLowerNet(ReadLineOrExit());

        switch (command)
        {
            case "help":
            case "h":
                PrintHelp(true);
                break;
            case "add":
            case "a":
                Add();
                break;
            case "edit":
            case "e":
                Edit();
                break;
            case "delete":
            case "x":
                Delete();
                break;
            case "save":
            case "s":
                Save();
                break;
            case "quit":
            case "q":
                Console.WriteLine();
                return 0;
            case "walls":
            case "w":
                PrintWalls(false);
                break;
            case "objects":
            case "o":
                PrintObjects(false);
                break;
            case "data":
            case "d":
                PrintObjectInfos(false);
                break;
            case "info":
            case "i":
                PrintObjects(true);
                PrintObjectInfos(true);
                PrintWalls(true);
                break;
            default:
                if (!IsWhiteSpaceOnlyNet(command))
                {
                    Console.WriteLine();
                    Console.WriteLine("Error: Invalid command. Enter 'help' to see a list of commands.");
                    Console.WriteLine();
                }
                break;
        }
    }
}

// a line of input; the original fails at the end of the input, this ends the program
string ReadLineOrExit()
{
    if (Console.ReadLine() is string line)
        return line;
    Environment.Exit(0);
    return "";
}

void PrintHelp(bool header)
{
    if (header)
    {
        Console.WriteLine();
        Console.WriteLine("### Help ###");
    }
    Console.WriteLine();
    Console.WriteLine("h or help: Shows this help.");
    Console.WriteLine("w or walls: Shows all walls and their details.");
    Console.WriteLine("o or objects: Shows all objects and their details.");
    Console.WriteLine("d or data: Shows all object data and its details.");
    Console.WriteLine("i or info: Shows a brief info of all walls, objects and data.");
    Console.WriteLine("q or quit: Exits the application.");
    Console.WriteLine("s or save: Saves the data modifications.");
    Console.WriteLine("a or add: Adds a new wall, object or object data.");
    Console.WriteLine("e or edit: Edits an existing wall, object or object data.");
    Console.WriteLine("x or delete: Deletes an existing wall, object or object data.");
    Console.WriteLine();
}

void Save()
{
    Console.WriteLine();

    if (QueryYesNo("Do you really want to overwrite the source file?"))
    {
        var writer = new DataWriter();
        LabdataReader.WriteLabdata(Lab, ref writer);

        // the original builds the path "<folder>/<name>_backup/<extension>": for a file with an extension that is a
        // folder that does not exist (it fails); this writes "<folder>/<name>_backup<extension>"
        var directory = Path.GetDirectory(LabdataPath);
        var name = Path.GetFileName(LabdataPath);
        var extension = Path.GetExtension(LabdataPath);
        var stem = name[0..name.Length - extension.Length].ToString();
        var backupPath = Path.Combine(directory, stem + "_backup" + extension);

        if (File.Copy(LabdataPath, backupPath, true) is error)
            Console.WriteLine($"Could not write the backup '{backupPath}'.");
        else if (File.WriteAllBytes(LabdataPath, writer.AsSlice()) is error)
            Console.WriteLine($"Could not write file '{LabdataPath}'.");
        else
            Console.WriteLine("Labdata was saved at: " + LabdataPath);
    }
    else
        Console.WriteLine("Aborted.");

    Console.WriteLine();
}

// waits for return before every 10th entry
void Paginate(int i)
{
    if (i != 0 && i % 10 == 0)
    {
        Console.WriteLine("Press return to continue");
        Console.ReadLine();
    }
}

string Hex2(int value)
{
    return value.ToString("x2");
}

string D3(int64 value)
{
    return value.ToString("D3");
}

void PrintWalls(bool brief)
{
    Console.WriteLine();
    Console.WriteLine("### Walls ###");
    Console.WriteLine();

    for (var i = 0; i < Lab.Walls.Count(); i += 1)
    {
        Paginate(i);

        var wall = Lab.Walls[i];
        string wallType = (wall.Flags & TileFlags.BlockAllMovement) != TileFlags.None || (wall.Flags & TileFlags.AllowMovementWalk) == TileFlags.None
            ? "Norm Wall" : "Fake Wall";
        int numOverlays = wall.Overlays == null ? 0 : wall.Overlays.Length;
        Console.WriteLine($"- {D3(i + 1)} [{Hex2(101 + i)}]: {wallType} with texture {D3(wall.TextureIndex)} and {numOverlays} overlays");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {wall.TextureIndex}");
            Console.WriteLine($"       AutomapType: {_AutomapName(wall.AutomapType)}");
            Console.WriteLine($"       ColorIndex: {wall.ColorIndex}");
            Console.WriteLine($"       Flags: {((uint32)wall.Flags).ToString("x8")}");
            for (var f = 0; f < WallFlagValues.Length; f += 1)
            {
                if (((uint32)wall.Flags & WallFlagValues[f]) == WallFlagValues[f])
                    Console.WriteLine($"       - {WallFlagNames[f]}");
            }
            if (numOverlays != 0)
            {
                Console.WriteLine($"       {numOverlays} overlay(s)");

                for (var o = 0; o < numOverlays; o += 1)
                {
                    var overlay = wall.Overlays[o];
                    Console.WriteLine($"       - {o}: Texture {overlay.TextureIndex} ({overlay.TextureWidth}x{overlay.TextureHeight}) at ({overlay.PositionX},{overlay.PositionY}), Blend {(overlay.Blend ? "on" : "off")}");
                }
            }
        }
    }

    Console.WriteLine();
}

// Enum.GetName: the name of an automap type, "" if it has none
string _AutomapName(AutomapType type)
{
    return EnumName(type) is string name ? name : "";
}

void PrintObjects(bool brief)
{
    Console.WriteLine();
    Console.WriteLine("### Objects ###");
    Console.WriteLine();

    for (var i = 0; i < Lab.Objects.Count(); i += 1)
    {
        Paginate(i);

        var obj = Lab.Objects[i];
        int count = obj.SubObjects.Count();
        string text = count == 0 ? "Empty object" :
            count == 1 ? $"Texture {D3(obj.SubObjects[0].Object.TextureIndex)}" :
                $"Texture {D3(obj.SubObjects[0].Object.TextureIndex)} and {count - 1} more sub-objects";
        Console.WriteLine($"- {D3(i + 1)} [{Hex2(1 + i)}]: {text}");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {(count == 0 ? 0 : obj.SubObjects[0].Object.TextureIndex)}");
            Console.WriteLine($"       AutomapType: {_AutomapName(obj.AutomapType)}");
            Console.WriteLine($"       ColorIndex: {(count == 0 ? 0 : obj.SubObjects[0].Object.ColorIndex)}");
            Console.WriteLine($"       Flags: {(count == 0 ? 0 : (uint32)obj.SubObjects[0].Object.Flags).ToString("x8")}");
            if (count != 0)
            {
                var flags = (uint32)obj.SubObjects[0].Object.Flags;
                for (var f = 0; f < ObjectFlagValues.Length; f += 1)
                {
                    if ((flags & ObjectFlagValues[f]) == ObjectFlagValues[f])
                        Console.WriteLine($"       - {ObjectFlagNames[f]}");
                }
                Console.WriteLine($"       {count} sub-object(s)");
                for (var s = 0; s < count; s += 1)
                {
                    var subObject = obj.SubObjects[s];
                    Console.WriteLine($"       - {s}: X={subObject.X}, Y={subObject.Y}, Z={subObject.Z}, Index={Lab.IndexOfObjectInfo(subObject.Object) + 1}");
                }
            }
        }
    }

    Console.WriteLine();
}

void PrintObjectInfos(bool brief)
{
    Console.WriteLine();
    Console.WriteLine("### Object Data ###");
    Console.WriteLine();

    for (var i = 0; i < Lab.ObjectInfos.Count(); i += 1)
    {
        Paginate(i);

        var info = Lab.ObjectInfos[i];
        Console.WriteLine($"- {D3(i + 1)} [{Hex2(1 + i)}]: Texture {D3(info.TextureIndex)}");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {info.TextureIndex}");
            Console.WriteLine($"       Frames: {info.NumAnimationFrames}");
            Console.WriteLine($"       TextureWidth: {info.TextureWidth}");
            Console.WriteLine($"       TextureHeight: {info.TextureHeight}");
            Console.WriteLine($"       MappedWidth: {info.MappedTextureWidth}");
            Console.WriteLine($"       MappedHeight: {info.MappedTextureHeight}");
            Console.WriteLine($"       ColorIndex: {info.ColorIndex}");
            Console.WriteLine($"       CombatBackground: {(uint32)info.Flags >> 28}");
            Console.WriteLine($"       Flags: {((uint32)info.Flags).ToString("x8")}");
            for (var f = 0; f < ObjectFlagValues.Length; f += 1)
            {
                if (((uint32)info.Flags & ObjectFlagValues[f]) == ObjectFlagValues[f])
                    Console.WriteLine($"       - {ObjectFlagNames[f]}");
            }
        }
    }

    Console.WriteLine();
}

/// Asks for a number from `minimum` to `maximum`; null if the input is no such number (or the input ended).
Optional<int> QueryInt(string name, int minimum, int maximum)
{
    Console.Write(name + ": ");
    if (Console.ReadLine() is not string input)
        return null;
    if (ParseInt(input) is not int value)
        return null;
    if (value < minimum || value > maximum)
        return null;
    return value;
}

Optional<AutomapType> QueryAutomapType(string name)
{
    Console.WriteLine("Automap Types:");
    Console.WriteLine("  0: None           1: Wall           2: Riddlemouth");
    Console.WriteLine("  3: Teleporter     4: Spinner        5: Trap");
    Console.WriteLine("  6: Trapdoor       7: Special        8: Monster");
    Console.WriteLine("  9: Door Closed   10: Door Open     11: Merchant");
    Console.WriteLine(" 12: Tavern        13: Chest Closed  14: Exit");
    Console.WriteLine(" 15: Chest Open    16: Pile          17: Person");
    Console.WriteLine(" 18: Goto Point    19: Char Dependent (Person/Monster)");

    if (QueryInt(name, 0, 19) is not int value)
        return null;
    return value == 19 ? AutomapType.Invalid : (AutomapType)value;
}

/// Asks for flags (hexadecimal, "0x" in front optional) of the allowed ones; null if the input is no such flags.
Optional<TileFlags> QueryFlags(string name, ReadOnlySlice<uint32> values, ReadOnlySlice<string> names)
{
    Console.WriteLine("Flags:");
    Console.WriteLine(" 0x00000000: None");
    for (var f = 0; f < values.Length; f += 1)
        Console.WriteLine($" 0x{values[f].ToString("x8")}: {names[f]}");

    Console.Write(name + ": ");
    if (Console.ReadLine() is not string line)
        return null;
    StringSlice input = line;
    if (ToLowerNet(input).StartsWith("0x"))
        input = input[2..];

    if (ParseHex(input) is not int parsed)
        return null;
    uint32 value = (uint32)parsed;
    uint32 test = value;
    foreach (var allowed in values)
        test &= ~allowed;
    if (test != 0)
        return null;
    return (TileFlags)value;
}

bool QueryYesNo(string question)
{
    Console.WriteLine(question);
    Console.WriteLine("1: Yes");
    Console.WriteLine("0: No");
    Console.Write("Answer: ");

    string answer = ToLowerNet(ReadLineOrExit());

    return answer == "1" || answer == "y" || answer == "yes" || answer == "true";
}

void PrintDivider()
{
    Console.WriteLine("".PadLeft(80, '#'));
}

void Error()
{
    Console.WriteLine("Invalid input. Aborting.");
}

// the combat background of the labyrinth in the upper 4 bits of flags
TileFlags WithCombatBackground(TileFlags flags)
{
    return (TileFlags)((uint32)flags | (Lab.CombatBackground << 28));
}

TileFlags AddCombatBackground(TileFlags flags, int combatBackground)
{
    return (TileFlags)((uint32)flags | ((uint32)combatBackground << 28));
}

string ReadChoice()
{
    Console.Write("Enter: ");
    if (Console.ReadLine() is string line)
        return line;
    return "";
}

void Add()
{
    Console.WriteLine();
    Console.WriteLine("What should be added:");
    Console.WriteLine("0: Wall");
    Console.WriteLine("1: Object");
    Console.WriteLine("2: Object data");
    var option = ReadChoice();

    if (option == "0")
        AddWall();
    else if (option == "1")
        AddObject();
    else if (option == "2")
        AddObjectInfo();
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();
}

void AddWall()
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Adding wall {D3(1 + Lab.Walls.Count())} [{Hex2(101 + Lab.Walls.Count())}]");
    Console.WriteLine();

    var wall = WallData { };

    if (QueryInt("TextureIndex", 1, 255) is not int textureIndex)
    {
        Error();
        return;
    }
    wall.TextureIndex = (uint32)textureIndex;
    if (QueryAutomapType("AutomapType") is not AutomapType automapType)
    {
        Error();
        return;
    }
    wall.AutomapType = automapType;
    if (QueryInt("ColorIndex", 0, 31) is not int colorIndex)
    {
        Error();
        return;
    }
    wall.ColorIndex = (uint8)colorIndex;
    if (QueryFlags("Flags", WallFlagValues, WallFlagNames) is not TileFlags flags)
    {
        Error();
        return;
    }
    wall.Flags = WithCombatBackground(flags);
    if ((wall.Flags & TileFlags.BlockAllMovement) == TileFlags.None)
    {
        if (QueryInt("CombatBackground", 0, 15) is int combatBackground)
            wall.Flags = AddCombatBackground(wall.Flags, combatBackground);
    }

    var overlays = List<OverlayData>.Create();
    while (overlays.Count() < 255)
    {
        if (!QueryYesNo("Do you want to add an overlay?"))
            break;

        QueryOverlay(overlays, -1);
    }

    if (overlays.Count() != 0)
        wall.Overlays = overlays.ToArray();
    Lab.Walls.Add(wall);
}

// asks for the values of a new overlay (added if all are valid) or of an overlay to edit (invalid values keep the old
// ones)
void QueryOverlay(List<OverlayData> overlays, int editIndex)
{
    bool editing = editIndex != -1;
    var overlay = editing ? overlays[editIndex] : OverlayData { };
    var old = overlay;

    if (QueryInt(editing ? $"Blending ({(old.Blend ? "True" : "False")})" : "Blending", 0, 1) is int blend)
        overlay.Blend = blend != 0;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"TextureIndex ({old.TextureIndex})" : "TextureIndex", 1, 255) is int textureIndex)
        overlay.TextureIndex = (uint32)textureIndex;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"PositionX ({old.PositionX})" : "PositionX", 0, 255) is int x)
        overlay.PositionX = (uint32)x;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"PositionY ({old.PositionY})" : "PositionY", 0, 255) is int y)
        overlay.PositionY = (uint32)y;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"TextureWidth ({old.TextureWidth})" : "TextureWidth", 1, 255) is int width)
        overlay.TextureWidth = (uint32)width;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"TextureHeight ({old.TextureHeight})" : "TextureHeight", 1, 255) is int height)
        overlay.TextureHeight = (uint32)height;
    else if (!editing)
    {
        Error();
        return;
    }

    if (editing)
        overlays[editIndex] = overlay;
    else
        overlays.Add(overlay);
}

void AddObject()
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Adding object {D3(1 + Lab.Objects.Count())} [{Hex2(1 + Lab.Objects.Count())}]");
    Console.WriteLine();

    var obj = LabdataObject { };

    if (QueryAutomapType("AutomapType") is not AutomapType automapType)
    {
        Error();
        return;
    }
    obj.AutomapType = automapType;
    var subObjects = List<ObjectPosition>.Create();
    for (var i = 0; i < 8; i += 1)
    {
        QuerySubObject(subObjects, -1);

        if (i != 7)
        {
            if (!QueryYesNo("Do you want to add a sub-object?"))
                break;
        }
    }

    obj.SubObjects = subObjects;
    Lab.Objects.Add(obj);
}

// asks for the values of a new sub-object (added if all are valid) or of one to edit (invalid values keep the old ones)
void QuerySubObject(List<ObjectPosition> subObjects, int editIndex)
{
    bool editing = editIndex != -1;
    var subObject = editing ? subObjects[editIndex] : ObjectPosition { };
    var old = subObject;

    if (QueryInt(editing ? $"X ({old.X})" : "X", -32768, 32767) is int x)
        subObject.X = (int16)x;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"Y ({old.Y})" : "Y", -32768, 32767) is int y)
        subObject.Y = (int16)y;
    else if (!editing)
    {
        Error();
        return;
    }
    if (QueryInt(editing ? $"Z ({old.Z})" : "Z", -32768, 32767) is int z)
        subObject.Z = (int16)z;
    else if (!editing)
    {
        Error();
        return;
    }
    string name = editing ? $"Object Data Index ({1 + Lab.IndexOfObjectInfo(old.Object)})" : "Object Data Index";
    if (QueryInt(name, 1, Lab.ObjectInfos.Count()) is int index)
        subObject.Object = Lab.ObjectInfos[index - 1];
    else if (!editing)
    {
        Error();
        return;
    }

    if (editing)
        subObjects[editIndex] = subObject;
    else
        subObjects.Add(subObject);
}

void AddObjectInfo()
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Adding object data {D3(1 + Lab.ObjectInfos.Count())} [{Hex2(1 + Lab.ObjectInfos.Count())}]");
    Console.WriteLine();

    var info = ObjectInfo { };

    if (QueryInt("TextureIndex", 1, 65535) is not int textureIndex)
    {
        Error();
        return;
    }
    info.TextureIndex = (uint32)textureIndex;
    if (QueryInt("TextureWidth", 1, 255) is not int width)
    {
        Error();
        return;
    }
    info.TextureWidth = (uint32)width;
    if (QueryInt("TextureHeight", 1, 255) is not int height)
    {
        Error();
        return;
    }
    info.TextureHeight = (uint32)height;
    if (QueryInt("MappedWidth", 1, 65535) is not int mappedWidth)
    {
        Error();
        return;
    }
    info.MappedTextureWidth = (uint32)mappedWidth;
    if (QueryInt("MappedHeight", 1, 65535) is not int mappedHeight)
    {
        Error();
        return;
    }
    info.MappedTextureHeight = (uint32)mappedHeight;
    if (QueryInt("Frames", 1, 255) is not int frames)
    {
        Error();
        return;
    }
    info.NumAnimationFrames = (uint32)frames;
    if (QueryInt("ColorIndex", 0, 31) is not int colorIndex)
    {
        Error();
        return;
    }
    info.ColorIndex = (uint8)colorIndex;
    if (QueryFlags("Flags", ObjectFlagValues, ObjectFlagNames) is not TileFlags flags)
    {
        Error();
        return;
    }
    info.Flags = flags;
    if (QueryInt("CombatBackground", 0, 15) is not int combatBackground)
    {
        Error();
        return;
    }
    info.Flags = AddCombatBackground(info.Flags, combatBackground);

    Lab.ObjectInfos.Add(info);
}

// asks for the index of an entry; null if it is no index of the entries
Optional<int> QueryIndex(int count)
{
    Console.WriteLine();
    Console.WriteLine("Which index to edit?");
    Console.Write("Index: ");
    var choice = Console.ReadLine();
    Console.WriteLine();

    if (choice is not string text)
    {
        Console.WriteLine("Invalid index. Aborting.");
        return null;
    }
    int index = ParseInt(text) is int number ? number : 0;
    if (index < 1 || index > count)
    {
        Console.WriteLine("Invalid index. Aborting.");
        return null;
    }
    return index;
}

void Edit()
{
    Console.WriteLine();
    Console.WriteLine("What should be edited:");
    Console.WriteLine("0: Wall");
    Console.WriteLine("1: Object");
    Console.WriteLine("2: Object data");
    var option = ReadChoice();

    if (option == "0")
    {
        PrintWalls(true);
        if (QueryIndex(Lab.Walls.Count()) is int index)
            EditWall(index);
    }
    else if (option == "1")
    {
        PrintObjects(true);
        if (QueryIndex(Lab.Objects.Count()) is int index)
            EditObject(index);
    }
    else if (option == "2")
    {
        PrintObjectInfos(true);
        if (QueryIndex(Lab.ObjectInfos.Count()) is int index)
            EditObjectInfo(index);
    }
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();
}

// the names of the allowed flags that are set, separated by " | " ("None" if none is)
string FlagNames(TileFlags flags, ReadOnlySlice<uint32> values, ReadOnlySlice<string> names)
{
    var text = StringBuilder.Create();
    for (var f = 0; f < values.Length; f += 1)
    {
        if (((uint32)flags & values[f]) == values[f])
        {
            if (text.Length() != 0)
                text.Append(" | ");
            text.Append(names[f]);
        }
    }
    return text.Length() == 0 ? "None" : text.ToString();
}

void EditWall(int index)
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Editing wall {D3(index)} [{Hex2(100 + index)}]");
    Console.WriteLine();

    var wall = Lab.Walls[index - 1];
    var old = wall;

    if (QueryInt($"TextureIndex ({old.TextureIndex})", 1, 255) is int textureIndex)
        wall.TextureIndex = (uint32)textureIndex;
    if (QueryAutomapType($"AutomapType ({EnumText(old.AutomapType, false)})") is AutomapType automapType)
        wall.AutomapType = automapType;
    if (QueryInt($"ColorIndex ({old.ColorIndex})", 0, 31) is int colorIndex)
        wall.ColorIndex = (uint8)colorIndex;
    if (QueryFlags($"Flags ({FlagNames(old.Flags, WallFlagValues, WallFlagNames)}) [0x{((uint32)old.Flags).ToString("x8")}]", WallFlagValues, WallFlagNames) is TileFlags flags)
        wall.Flags = WithCombatBackground(flags);
    if (QueryInt($"CombatBackground ({(uint32)old.Flags >> 28})", 0, 15) is int combatBackground)
        wall.Flags = AddCombatBackground(wall.Flags, combatBackground);

    var overlays = List<OverlayData>.Create();
    int previousOverlays = wall.Overlays == null ? 0 : wall.Overlays.Length;
    for (var i = 0; i < previousOverlays; i += 1)
        overlays.Add(wall.Overlays[i]);

    while (overlays.Count() < 255)
    {
        if (!QueryYesNo("Do you want to add an overlay?"))
            break;

        QueryOverlay(overlays, -1);
    }

    // edit overlays
    for (var i = 0; i < previousOverlays; i += 1)
    {
        if (!QueryYesNo($"Do you want to edit overlay {i}?"))
        {
            // (as in the original this deletes the last overlay, which may be one added before)
            if (i == previousOverlays - 1 && QueryYesNo($"Do you want to delete overlay {i}?"))
                overlays.RemoveAt(overlays.Count() - 1);

            continue;
        }

        QueryOverlay(overlays, i);
    }

    if (overlays.Count() != 0 || wall.Overlays != null)
        wall.Overlays = overlays.ToArray();

    Lab.Walls[index - 1] = wall;
}

void EditObject(int index)
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Editing object {D3(index)} [{Hex2(index)}]");
    Console.WriteLine();

    var obj = Lab.Objects[index - 1];
    var old = obj;

    if (QueryAutomapType($"AutomapType ({EnumText(old.AutomapType, false)})") is AutomapType automapType)
        obj.AutomapType = automapType;
    var subObjects = List<ObjectPosition>.Create();
    foreach (var subObject in obj.SubObjects)
        subObjects.Add(subObject);
    bool adding = false;
    for (var i = 0; i < 8; i += 1)
    {
        if (!adding && i < subObjects.Count() && subObjects[i].Object.TextureIndex != 0)
        {
            Console.WriteLine($"Editing sub-object {i}");
            QuerySubObject(subObjects, i);
        }
        if (i != 7 && (i >= subObjects.Count() - 1 || subObjects[i + 1].Object.TextureIndex == 0))
        {
            adding = true;

            if (!QueryYesNo("Do you want to add a sub-object?"))
                break;

            QuerySubObject(subObjects, -1);
        }
    }

    obj.SubObjects = subObjects;
    Lab.Objects[index - 1] = obj;
}

void EditObjectInfo(int index)
{
    Console.WriteLine();
    PrintDivider();
    Console.WriteLine();
    Console.WriteLine($"Editing object data {D3(index)} [{Hex2(index)}]");
    Console.WriteLine();

    var info = Lab.ObjectInfos[index - 1];
    var old = info;

    if (QueryInt($"TextureIndex ({D3(old.TextureIndex)})", 1, 65535) is int textureIndex)
        info.TextureIndex = (uint32)textureIndex;
    if (QueryInt($"TextureWidth ({old.TextureWidth})", 1, 255) is int width)
        info.TextureWidth = (uint32)width;
    if (QueryInt($"TextureHeight ({old.TextureHeight})", 1, 255) is int height)
        info.TextureHeight = (uint32)height;
    if (QueryInt($"MappedWidth ({old.MappedTextureWidth})", 1, 65535) is int mappedWidth)
        info.MappedTextureWidth = (uint32)mappedWidth;
    if (QueryInt($"MappedHeight ({old.MappedTextureHeight})", 1, 65535) is int mappedHeight)
        info.MappedTextureHeight = (uint32)mappedHeight;
    if (QueryInt($"Frames ({old.NumAnimationFrames})", 1, 255) is int frames)
        info.NumAnimationFrames = (uint32)frames;
    if (QueryInt($"ColorIndex ({old.ColorIndex})", 0, 31) is int colorIndex)
        info.ColorIndex = (uint8)colorIndex;
    if (QueryFlags($"Flags ({FlagNames(old.Flags, ObjectFlagValues, ObjectFlagNames)}) [0x{((uint32)old.Flags).ToString("x8")}]", ObjectFlagValues, ObjectFlagNames) is TileFlags flags)
        info.Flags = flags;
    if (QueryInt($"CombatBackground ({(uint32)old.Flags >> 28})", 0, 15) is int combatBackground)
        info.Flags = AddCombatBackground(info.Flags, combatBackground);

    Lab.ObjectInfos[index - 1] = info;

    // the sub-objects with the old values get the new ones
    foreach (var obj in Lab.Objects)
    {
        for (var i = 0; i < obj.SubObjects.Count(); i += 1)
        {
            if (obj.SubObjects[i].Object.Equals(old))
            {
                var subObject = obj.SubObjects[i];
                subObject.Object = info;
                obj.SubObjects[i] = subObject;
            }
        }
    }
}

void Delete()
{
    Console.WriteLine();
    Console.WriteLine("What should be deleted:");
    Console.WriteLine("0: Wall");
    Console.WriteLine("1: Object");
    Console.WriteLine("2: Object data");
    var option = ReadChoice();

    if (option == "0")
    {
        PrintWalls(true);
        if (QueryDeleteIndex(Lab.Walls.Count()) is int index)
        {
            Lab.Walls.RemoveAt(index - 1);
            Console.WriteLine($"Item with index {index} was deleted.");
        }
    }
    else if (option == "1")
    {
        PrintObjects(true);
        if (QueryDeleteIndex(Lab.Objects.Count()) is int index)
        {
            Lab.Objects.RemoveAt(index - 1);
            Console.WriteLine($"Item with index {index} was deleted.");
        }
    }
    else if (option == "2")
    {
        PrintObjectInfos(true);
        if (QueryDeleteIndex(Lab.ObjectInfos.Count()) is int index)
        {
            var backup = Lab.ObjectInfos[index - 1];
            Lab.ObjectInfos.RemoveAt(index - 1);
            Console.WriteLine($"Item with index {index} was deleted.");

            // the sub-objects with its values are removed, and the objects that have no sub-objects left
            var emptied = List<int>.Create();
            for (var o = 0; o < Lab.Objects.Count(); o += 1)
            {
                var subObjects = Lab.Objects[o].SubObjects;
                for (var i = subObjects.Count() - 1; i >= 0; i -= 1)
                {
                    if (subObjects[i].Object.Equals(backup))
                    {
                        subObjects.RemoveAt(i);
                        if (subObjects.Count() == 0)
                            emptied.Add(o);
                    }
                }
            }
            for (var i = emptied.Count() - 1; i >= 0; i -= 1)
                Lab.Objects.RemoveAt(emptied[i]);
        }
    }
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();
}

Optional<int> QueryDeleteIndex(int count)
{
    Console.WriteLine();
    Console.WriteLine("Which index to delete?");
    Console.Write("Index: ");
    var choice = Console.ReadLine();
    Console.WriteLine();

    if (choice is not string text)
    {
        Console.WriteLine("Invalid index. Aborting.");
        return null;
    }
    int index = ParseInt(text) is int number ? number : 0;
    if (index < 1 || index > count)
    {
        Console.WriteLine("Invalid index. Aborting.");
        return null;
    }
    return index;
}
