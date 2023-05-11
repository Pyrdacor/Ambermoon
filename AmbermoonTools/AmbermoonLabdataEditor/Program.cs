using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System.Globalization;
using WallFlags = Ambermoon.Data.Tileset.TileFlags;
using ObjectFlags = Ambermoon.Data.Tileset.TileFlags;
using Ambermoon.Data.Enumerations;
using AmbermoonLabdataEditor;

Dictionary<WallFlags, string> AllWallFlags = new()
{
    { WallFlags.AlternateAnimation, "Alternate Animation" },
    { WallFlags.BlockSight, "Block Sight" },
    { WallFlags.Transparency, "Transparency" },
    { WallFlags.RandomAnimationStart, "Random Animation Start" },
    { WallFlags.BlockAllMovement, "Block All Movement" },
    { WallFlags.AllowMovementWalk, "Allow Player Move" },
    { WallFlags.AllowMovementMonster, "Allow Monster Move" }  
};

Dictionary<ObjectFlags, string> AllObjectFlags = new()
{
    { ObjectFlags.AlternateAnimation, "Alternate Animation" },
    { ObjectFlags.BlockSight, "Block Sight" },
    { ObjectFlags.Floor, "Floor / Ceiling" },
    { ObjectFlags.RandomAnimationStart, "Random Animation Start" },
    { ObjectFlags.BlockAllMovement, "Block All Movement" },
    { ObjectFlags.AllowMovementWalk, "Allow Player Move" },
    { ObjectFlags.AllowMovementMonster, "Allow Monster Move" }
};

if (args.Length != 2)
{
    Console.WriteLine("Usage: AmbermoonLabdataEditor <labdataFilePath> <gameDataPath>");
    Console.WriteLine();
    Console.WriteLine("labdataFilePath: Path to the extracted single labdata file.");
    Console.WriteLine("gameDataPath:    Path to Ambermoon data (Amberfiles folder).");
    Console.WriteLine();
    return;
}

string GetWallFlagNames(WallFlags flags)
{
    string names = string.Join(" | ", AllWallFlags.Where(flag => flags.HasFlag(flag.Key)).Select(flag => flag.Value));
    return names.Length == 0 ? "None" : names;
}

string GetObjectFlagNames(ObjectFlags flags)
{
    string names = string.Join(" | ", AllObjectFlags.Where(flag => flags.HasFlag(flag.Key)).Select(flag => flag.Value));
    return names.Length == 0 ? "None" : names;
}

var gameData = new GameData(GameData.LoadPreference.PreferExtracted, null, false);
gameData.Load(args[1]);

var dataReader = new DataReader(File.ReadAllBytes(args[0]));
var labdata = Labdata.Load(new LabdataReader(), dataReader, gameData);

PrintHelp(false);

while (true)
{
    Console.Write("Enter command: ");
    string command = Console.ReadLine()!.ToLower();

    switch (command)
    {
        case "help":
        case "h":
            PrintHelp();
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
            Quit();
            break;
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
            PrintLabdata(true);
            break;
        case string s when string.IsNullOrWhiteSpace(s):
            break;
        default:
            InvalidCommand();
            break;
    }
}

static void InvalidCommand()
{
    Console.WriteLine();
    Console.WriteLine("Error: Invalid command. Enter 'help' to see a list of commands.");
    Console.WriteLine();
}

static void PrintHelp(bool header = true)
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

void Quit()
{
    Console.WriteLine();
    // TODO
    Environment.Exit(0);
}

void Save()
{
    Console.WriteLine();

    if (QueryYesNo("Do you really want to overwrite the source file?"))
    {
        var dataWriter = new DataWriter();
        LabdataWriter.WriteLabdata(labdata, dataWriter);

        string backupPath = Path.Combine(Path.GetDirectoryName(args[0])!, Path.GetFileNameWithoutExtension(args[0]) + "_backup", Path.GetExtension(args[0]));

        File.Copy(args[0], backupPath, true);

        using var file = File.Create(args[0]);
        dataWriter.CopyTo(file);

        Console.WriteLine("Labdata was saved at: " + args[0]);
    }
    else
    {
        Console.WriteLine("Aborted.");
    }

    Console.WriteLine();
}

void PrintLabdata(bool brief)
{
    PrintObjects(brief);
    PrintObjectInfos(brief);
    PrintWalls(brief);
}

void PrintWalls(bool brief)
{
    Console.WriteLine();
    Console.WriteLine("### Walls ###");
    Console.WriteLine();

    for (int i = 0; i < labdata.Walls.Count; ++i)
    {
        if (i != 0 && i % 10 == 0)
        {
            Console.WriteLine("Press return to continue");
            Console.ReadLine();
        }

        var wall = labdata.Walls[i];
        string wallType = wall.Flags.HasFlag(Tileset.TileFlags.BlockAllMovement) || !wall.Flags.HasFlag(Tileset.TileFlags.AllowMovementWalk)
            ? "Norm Wall" : "Fake Wall";
        Console.WriteLine($"- {i + 1:000} [{101 + i:x2}]: {wallType} with texture {wall.TextureIndex:000} and {wall.Overlays?.Length ?? 0} overlays");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {wall.TextureIndex}");
            Console.WriteLine($"       AutomapType: {Enum.GetName(wall.AutomapType)}");
            Console.WriteLine($"       ColorIndex: {wall.ColorIndex}");
            Console.WriteLine($"       Flags: {(uint)wall.Flags:x8}");
            foreach (var wallFlag in AllWallFlags)
            {
                if (wall.Flags.HasFlag(wallFlag.Key))
                    Console.WriteLine($"       - {wallFlag.Value}");
            }
            if ((wall.Overlays?.Length ?? 0) != 0)
            {
                Console.WriteLine($"       {wall.Overlays!.Length} overlay(s)");

                for (int o = 0; o < wall.Overlays!.Length; ++o)
                {
                    var overlay = wall.Overlays![o];
                    Console.WriteLine($"       - {o}: Texture {overlay.TextureIndex} ({overlay.TextureWidth}x{overlay.TextureHeight}) at ({overlay.PositionX},{overlay.PositionY}), Blend {(overlay.Blend ? "on" : "off")}");
                }
            }
        }
    }

    Console.WriteLine();
}

void PrintObjects(bool brief)
{
    Console.WriteLine();
    Console.WriteLine("### Objects ###");
    Console.WriteLine();

    for (int i = 0; i < labdata.Objects.Count; ++i)
    {
        if (i != 0 && i % 10 == 0)
        {
            Console.WriteLine("Press return to continue");
            Console.ReadLine();
        }

        var obj = labdata.Objects[i];
        string text = obj.SubObjects.Count == 0 ? "Empty object" :
            obj.SubObjects.Count == 1 ? $"Texture {obj.SubObjects[0].Object.TextureIndex:000}" :
                $"Texture {obj.SubObjects[0].Object.TextureIndex:000} and {obj.SubObjects.Count - 1} more sub-objects";
        Console.WriteLine($"- {i + 1:000} [{1 + i:x2}]: {text}");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {(obj.SubObjects.Count == 0 ? 0 : obj.SubObjects[0].Object.TextureIndex)}");
            Console.WriteLine($"       AutomapType: {Enum.GetName(obj.AutomapType)}");
            Console.WriteLine($"       ColorIndex: {(obj.SubObjects.Count == 0 ? 0 : obj.SubObjects[0].Object.ColorIndex)}");
            Console.WriteLine($"       Flags: {(obj.SubObjects.Count == 0 ? 0 : (uint)obj.SubObjects[0].Object.Flags):x8}");
            if (obj.SubObjects.Count != 0)
            {
                foreach (var objectFlag in AllObjectFlags)
                {
                    if (obj.SubObjects[0].Object.Flags.HasFlag(objectFlag.Key))
                        Console.WriteLine($"       - {objectFlag.Value}");
                }
                Console.WriteLine($"       {obj.SubObjects.Count} sub-object(s)");
                for (int s = 0; s < obj.SubObjects.Count; ++s)
                {
                    var subObject = obj.SubObjects[s];
                    Console.WriteLine($"       - {s}: X={subObject.X}, Y={subObject.Y}, Z={subObject.Z}, Index={labdata.ObjectInfos.IndexOf(subObject.Object) + 1}");
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

    for (int i = 0; i < labdata.ObjectInfos.Count; ++i)
    {
        if (i != 0 && i % 10 == 0)
        {
            Console.WriteLine("Press return to continue");
            Console.ReadLine();
        }

        var objectInfo = labdata.ObjectInfos[i];
        Console.WriteLine($"- {i + 1:000} [{1 + i:x2}]: Texture {objectInfo.TextureIndex:000}");
        if (!brief)
        {
            Console.WriteLine($"       TextureIndex: {objectInfo.TextureIndex}");
            Console.WriteLine($"       Frames: {objectInfo.NumAnimationFrames}");
            Console.WriteLine($"       TextureWidth: {objectInfo.TextureWidth}");
            Console.WriteLine($"       TextureHeight: {objectInfo.TextureHeight}");
            Console.WriteLine($"       MappedWidth: {objectInfo.MappedTextureWidth}");
            Console.WriteLine($"       MappedHeight: {objectInfo.MappedTextureHeight}");
            Console.WriteLine($"       ColorIndex: {objectInfo.ColorIndex}");
            Console.WriteLine($"       CombatBackground: {(uint)objectInfo.Flags >> 28}");
            Console.WriteLine($"       Flags: {(uint)objectInfo.Flags:x8}");
            foreach (var objectFlag in AllObjectFlags)
            {
                if (objectInfo.Flags.HasFlag(objectFlag.Key))
                    Console.WriteLine($"       - {objectFlag.Value}");
            }
        }
    }

    Console.WriteLine();
}

bool QueryProperty<T>(Reference<T> target, string name, Action<Reference<T>, string> assign) where T : struct
{
    Console.Write(name + ": ");
    string input = Console.ReadLine()!;
    try
    {
        assign?.Invoke(target, input);
        return true;
    }
    catch
    {
        return false;
    }
}

bool QueryInt<T>(Reference<T> target, string name, Func<T, int, T> assign, int minimum = int.MinValue, int maximum = int.MaxValue) where T : struct
{
    return QueryProperty(target, name, (t, input) =>
    {
        if (!int.TryParse(input, out int value))
            throw new FormatException();

        if (value < minimum || value > maximum)
            throw new ArgumentOutOfRangeException();

        target.Value = assign?.Invoke(target.Value, value) ?? target.Value;
    });
}

bool QueryAutomapType<T>(Reference<T> target, string name, Func<T, AutomapType, T> assign) where T : struct
{
    Console.WriteLine("Automap Types:");
    Console.WriteLine("  0: None           1: Wall           2: Riddlemouth");
    Console.WriteLine("  3: Teleporter     4: Spinner        5: Trap");
    Console.WriteLine("  6: Trapdoor       7: Special        8: Monster");
    Console.WriteLine("  9: Door Closed   10: Door Open     11: Merchant");
    Console.WriteLine(" 12: Tavern        13: Chest Closed  14: Exit");
    Console.WriteLine(" 15: Chest Open    16: Pile          17: Person");
    Console.WriteLine(" 18: Goto Point    19: Char Dependent (Person/Monster)");

    return QueryInt(target, name, (t, i) =>
        assign?.Invoke(target.Value, i == 19 ? AutomapType.Invalid : (AutomapType)i)?? target.Value, 0, 19);
}

bool QueryFlags<T>(Reference<T> target, string name, Func<T, Tileset.TileFlags, T> assign, Dictionary<Tileset.TileFlags, string> allowedFlags) where T : struct
{
    Console.WriteLine("Flags:");
    Console.WriteLine(" 0x00000000: None");
    foreach (var allowedFlag in allowedFlags)
    {
        Console.WriteLine($" 0x{(uint)allowedFlag.Key:x8}: {allowedFlag.Value}");
    }

    return QueryProperty(target, name, (t, input) =>
    {
        if (input.ToLower().StartsWith("0x"))
            input = input[2..];

        if (!uint.TryParse(input, NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out uint value))
            throw new FormatException();

        uint test = value;

        foreach (var allowedFlag in allowedFlags)
            test &= ~(uint)allowedFlag.Key;

        if (test != 0)
            throw new ArgumentException();

        target.Value = assign?.Invoke(target.Value, (Tileset.TileFlags)value) ?? target.Value;
    });
}

static bool QueryYesNo(string question)
{
    Console.WriteLine(question);
    Console.WriteLine("1: Yes");
    Console.WriteLine("0: No");
    Console.Write("Answer: ");

    string answer = Console.ReadLine()!.ToLower();

    return answer == "1" || answer == "y" || answer == "yes" || answer == "true";
}

static void PrintDivider()
{
    Console.WriteLine(new string('#', 80));
}

void Add()
{
    Console.WriteLine();
    Console.WriteLine("What should be added:");
    Console.WriteLine("0: Wall");
    Console.WriteLine("1: Object");
    Console.WriteLine("2: Object data");
    Console.Write("Enter: ");
    var option = Console.ReadLine();

    if (option == "0")
        AddWall();
    else if (option == "1")
        AddObject();
    else if (option == "2")
        AddObjectInfo();
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();

    void Error() => Console.WriteLine("Invalid input. Aborting.");

    void AddWall()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Adding wall {1+labdata.Walls.Count:000} [{101+labdata.Walls.Count:x2}]");
        Console.WriteLine();

        var wall = new Reference<Labdata.WallData>();

        if (!QueryInt(wall, "TextureIndex", (wall, textureIndex) => { wall.TextureIndex = (uint)textureIndex; return wall; }, 1, 255))
        {
            Error();
            return;
        }
        if (!QueryAutomapType(wall, "AutomapType", (wall, automapType) => { wall.AutomapType = automapType; return wall; }))
        {
            Error();
            return;
        }
        if (!QueryInt(wall, "ColorIndex", (wall, colorIndex) => { wall.ColorIndex = (byte)colorIndex; return wall; }, 0, 31))
        {
            Error();
            return;
        }
        if (!QueryFlags(wall, "Flags", (wall, flags) => { wall.Flags = flags | (Tileset.TileFlags)(labdata.CombatBackground << 28); return wall; }, AllWallFlags))
        {
            Error();
            return;
        }
        var overlays = new List<Labdata.OverlayData>();
        while (overlays.Count < 255)
        {
            if (!QueryYesNo("Do you want to add an overlay?"))
                break;

            AddOverlay();
        }

        if (overlays.Count != 0)
        {
            var wallCopy = wall.Value;
            wallCopy.Overlays = overlays.ToArray();
            labdata.Walls.Add(wallCopy);
        }
        else
            labdata.Walls.Add(wall.Value);

        void AddOverlay()
        {
            var overlay = new Reference<Labdata.OverlayData>();

            if (!QueryInt(overlay, "Blending", (overlay, blend) => { overlay.Blend = blend != 0; return overlay; }, 0, 1))
            {
                Error();
                return;
            }
            if (!QueryInt(overlay, "TextureIndex", (overlay, textureIndex) => { overlay.TextureIndex = (uint)textureIndex; return overlay; }, 1, 255))
            {
                Error();
                return;
            }
            if (!QueryInt(overlay, "PositionX", (overlay, x) => { overlay.PositionX = (uint)x; return overlay; }, 0, 255))
            {
                Error();
                return;
            }
            if (!QueryInt(overlay, "PositionY", (overlay, y) => { overlay.PositionY = (uint)y; return overlay; }, 0, 255))
            {
                Error();
                return;
            }
            if (!QueryInt(overlay, "TextureWidth", (overlay, textureWidth) => { overlay.TextureWidth = (uint)textureWidth; return overlay; }, 1, 255))
            {
                Error();
                return;
            }
            if (!QueryInt(overlay, "TextureHeight", (overlay, textureHeight) => { overlay.TextureHeight = (uint)textureHeight; return overlay; }, 1, 255))
            {
                Error();
                return;
            }

            overlays.Add(overlay.Value);
        }
    }

    void AddObject()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Adding object {1 + labdata.Objects.Count:000} [{1 + labdata.Objects.Count:x2}]");
        Console.WriteLine();

        var obj = new Reference<Labdata.Object>();

        if (!QueryAutomapType(obj, "AutomapType", (obj, automapType) => { obj.AutomapType = automapType; return obj; }))
        {
            Error();
            return;
        }
        var subObjects = new List<Labdata.ObjectPosition>();
        for (int i = 0; i < 8; ++i)
        {
            AddSubObject();

            if (i != 7)
            {
                if (!QueryYesNo("Do you want to add a sub-object?"))
                    break;
            }
        }

        var newObject = obj.Value;
        newObject.SubObjects = new List<Labdata.ObjectPosition>(subObjects);

        labdata.Objects.Add(newObject);

        void AddSubObject()
        {
            var subObject = new Reference<Labdata.ObjectPosition>();

            if (!QueryInt(subObject, "X", (subObject, x) => { subObject.X = (short)x; return subObject; }, short.MinValue, short.MaxValue))
            {
                Error();
                return;
            }
            if (!QueryInt(subObject, "Y", (subObject, y) => { subObject.Y = (short)y; return subObject; }, short.MinValue, short.MaxValue))
            {
                Error();
                return;
            }
            if (!QueryInt(subObject, "Z", (subObject, z) => { subObject.Z = (short)z; return subObject; }, short.MinValue, short.MaxValue))
            {
                Error();
                return;
            }
            if (!QueryInt(subObject, "Object Data Index", (subObject, index) => { subObject.Object = labdata.ObjectInfos[index - 1]; return subObject; }, 1, labdata.ObjectInfos.Count))
            {
                Error();
                return;
            }

            subObjects.Add(subObject.Value);
        }
    }

    void AddObjectInfo()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Adding object data {1 + labdata.ObjectInfos.Count:000} [{1 + labdata.ObjectInfos.Count:x2}]");
        Console.WriteLine();

        var objectInfo = new Reference<Labdata.ObjectInfo>();

        if (!QueryInt(objectInfo, "TextureIndex", (objectInfo, textureIndex) => { objectInfo.TextureIndex = (uint)textureIndex; return objectInfo; }, 1, 65535))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "TextureWidth", (objectInfo, textureWidth) => { objectInfo.TextureWidth = (uint)textureWidth; return objectInfo; }, 1, 255))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "TextureHeight", (objectInfo, textureHeight) => { objectInfo.TextureHeight = (uint)textureHeight; return objectInfo; }, 1, 255))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "MappedWidth", (objectInfo, mappedWidth) => { objectInfo.MappedTextureWidth = (uint)mappedWidth; return objectInfo; }, 1, 65535))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "MappedHeight", (objectInfo, mappedHeight) => { objectInfo.MappedTextureHeight = (uint)mappedHeight; return objectInfo; }, 1, 65535))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "Frames", (objectInfo, frames) => { objectInfo.NumAnimationFrames = (uint)frames; return objectInfo; }, 1, 255))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "ColorIndex", (objectInfo, colorIndex) => { objectInfo.ColorIndex = (byte)colorIndex; return objectInfo; }, 0, 31))
        {
            Error();
            return;
        }
        if (!QueryFlags(objectInfo, "Flags", (objectInfo, flags) => { objectInfo.Flags = flags; return objectInfo; }, AllObjectFlags))
        {
            Error();
            return;
        }
        if (!QueryInt(objectInfo, "CombatBackground", (objectInfo, combatBackground) => { objectInfo.Flags = (Tileset.TileFlags)((uint)objectInfo.Flags | ((uint)combatBackground << 28)); return objectInfo; }, 0, 15))
        {
            Error();
            return;
        }

        labdata.ObjectInfos.Add(objectInfo.Value);
    }
}

void Edit()
{
    Console.WriteLine();
    Console.WriteLine("What should be edited:");
    Console.WriteLine("0: Wall");
    Console.WriteLine("1: Object");
    Console.WriteLine("2: Object data");
    Console.Write("Enter: ");
    var option = Console.ReadLine();
    int index = -1;

    bool QueryIndex<T>(List<T> list) where T : struct
    {
        Console.WriteLine();
        Console.WriteLine("Which index to edit?");
        Console.Write("Index: ");
        var indexChoice = Console.ReadLine();
        Console.WriteLine();

        if (!int.TryParse(indexChoice, out index) || index < 1 || index > list.Count)
        {
            Console.WriteLine("Invalid index. Aborting.");
            return false;
        }

        return true;
    }

    if (option == "0")
    {
        PrintWalls(true);
        if (QueryIndex(labdata.Walls))
            EditWall();
    }
    else if (option == "1")
    {
        PrintObjects(true);
        if (QueryIndex(labdata.Objects))
            EditObject();
    }
    else if (option == "2")
    {
        PrintObjectInfos(true);
        if (QueryIndex(labdata.ObjectInfos))
            EditObjectInfo();
    }
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();

    void Error() => Console.WriteLine("Invalid input. Aborting.");

    void EditWall()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Editing wall {index:000} [{100 + index:x2}]");
        Console.WriteLine();

        var wall = new Reference<Labdata.WallData>();
        var old = wall.Value = labdata.Walls[index - 1];

        QueryInt(wall, $"TextureIndex ({old.TextureIndex})", (wall, textureIndex) => { wall.TextureIndex = (uint)textureIndex; return wall; }, 1, 255);
        QueryAutomapType(wall, $"AutomapType ({old.AutomapType})", (wall, automapType) => { wall.AutomapType = automapType; return wall; });
        QueryInt(wall, $"ColorIndex ({old.ColorIndex})", (wall, colorIndex) => { wall.ColorIndex = (byte)colorIndex; return wall; }, 0, 31);
        QueryFlags(wall, $"Flags ({GetWallFlagNames(old.Flags)})", (wall, flags) => { wall.Flags = flags | (Tileset.TileFlags)(labdata.CombatBackground << 28); return wall; }, AllWallFlags);
        var overlays = new List<Labdata.OverlayData>(wall.Value.Overlays ?? new Labdata.OverlayData[0]);
        int prevOverlayAmount = wall.Value.Overlays?.Length ?? 0;
        while (overlays.Count < 255)
        {
            if (!QueryYesNo("Do you want to add an overlay?"))
                break;

            AddOverlay();
        }

        // edit overlays
        for (int i = 0; i < prevOverlayAmount; ++i)
        {
            if (!QueryYesNo($"Do you want to edit overlay {i}?"))
            {
                if (i == prevOverlayAmount - 1 && (QueryYesNo($"Do you want to delete overlay {i}?")))
                    overlays.RemoveAt(overlays.Count - 1);

                continue;
            }

            AddOverlay(i);
        }

        if (overlays.Count != 0 || wall.Value.Overlays != null)
        {
            var wallCopy = wall.Value;
            wallCopy.Overlays = overlays.ToArray();
            labdata.Walls[index - 1] = wallCopy;
        }

        void AddOverlay(int editIndex = -1)
        {
            var overlay = new Reference<Labdata.OverlayData>();
            Labdata.OverlayData old = default;

            if (editIndex != -1)
                old = overlay.Value = overlays[editIndex];

            string name = editIndex == -1 ? "Blending" : $"Blending ({old.Blend})";
            if (!QueryInt(overlay, name, (overlay, blend) => { overlay.Blend = blend != 0; return overlay; }, 0, 1))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "TextureIndex" : $"TextureIndex ({old.TextureIndex})";
            if (!QueryInt(overlay, name, (overlay, textureIndex) => { overlay.TextureIndex = (uint)textureIndex; return overlay; }, 1, 255))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "PositionX" : $"PositionX ({old.PositionX})";
            if (!QueryInt(overlay, name, (overlay, x) => { overlay.PositionX = (uint)x; return overlay; }, 0, 255))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "PositionY" : $"PositionY ({old.PositionY})";
            if (!QueryInt(overlay, name, (overlay, y) => { overlay.PositionY = (uint)y; return overlay; }, 0, 255))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "TextureWidth" : $"TextureWidth ({old.TextureWidth})";
            if (!QueryInt(overlay, name, (overlay, textureWidth) => { overlay.TextureWidth = (uint)textureWidth; return overlay; }, 1, 255))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "TextureHeight" : $"TextureHeight ({old.TextureHeight})";
            if (!QueryInt(overlay, name, (overlay, textureHeight) => { overlay.TextureHeight = (uint)textureHeight; return overlay; }, 1, 255))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }

            if (editIndex == -1)
                overlays.Add(overlay.Value);
            else
                overlays[editIndex] = overlay.Value;
        }
    }

    void EditObject()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Editing object {index:000} [{index:x2}]");
        Console.WriteLine();

        var obj = new Reference<Labdata.Object>();
        var old = obj.Value = labdata.Objects[index - 1];

        QueryAutomapType(obj, $"AutomapType ({old.AutomapType})", (obj, automapType) => { obj.AutomapType = automapType; return obj; });
        var subObjects = new List<Labdata.ObjectPosition>(obj.Value.SubObjects);
        bool adding = false;
        for (int i = 0; i < 8; ++i)
        {
            if (!adding && i < subObjects.Count && subObjects[i].Object.TextureIndex != 0)
            {
                Console.WriteLine($"Editing sub-object {i}");
                AddSubObject(i);
            }
            if (i != 7 && (i >= subObjects.Count - 1 || subObjects[i + 1].Object.TextureIndex == 0))
            {
                adding = true;

                if (!QueryYesNo("Do you want to add a sub-object?"))
                    break;
                    
                AddSubObject();
            }
        }

        var editedObject = obj.Value;
        editedObject.SubObjects = new List<Labdata.ObjectPosition>(subObjects);

        labdata.Objects[index - 1] = editedObject;

        void AddSubObject(int editIndex = -1)
        {
            var subObject = new Reference<Labdata.ObjectPosition>();
            Labdata.ObjectPosition old = default;

            if (editIndex != -1)
                old = subObject.Value = subObjects[editIndex];

            string name = editIndex == -1 ? "X" : $"X ({old.X})";
            if (!QueryInt(subObject, name, (subObject, x) => { subObject.X = (short)x; return subObject; }, short.MinValue, short.MaxValue))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "Y" : $"Y ({old.Y})";
            if (!QueryInt(subObject, name, (subObject, y) => { subObject.Y = (short)y; return subObject; }, short.MinValue, short.MaxValue))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "Z" : $"Z ({old.Z})";
            if (!QueryInt(subObject, name, (subObject, z) => { subObject.Z = (short)z; return subObject; }, short.MinValue, short.MaxValue))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }
            name = editIndex == -1 ? "Object Data Index" : $"Object Data Index ({labdata.ObjectInfos.IndexOf(old.Object)})";
            if (!QueryInt(subObject, name, (subObject, index) => { subObject.Object = labdata.ObjectInfos[index - 1]; return subObject; }, 1, labdata.ObjectInfos.Count))
            {
                if (editIndex == -1)
                {
                    Error();
                    return;
                }
            }

            if (editIndex == -1)
                subObjects.Add(subObject.Value);
            else
                subObjects[editIndex] = subObject.Value;
        }
    }

    void EditObjectInfo()
    {
        Console.WriteLine();
        PrintDivider();
        Console.WriteLine();
        Console.WriteLine($"Editing object data {index:000} [{index:x2}]");
        Console.WriteLine();

        var objectInfo = new Reference<Labdata.ObjectInfo>();
        var old = objectInfo.Value = labdata.ObjectInfos[index - 1];

        QueryInt(objectInfo, $"TextureIndex ({old.TextureIndex:000})", (objectInfo, textureIndex) => { objectInfo.TextureIndex = (uint)textureIndex; return objectInfo; }, 1, 65535);
        QueryInt(objectInfo, $"TextureWidth ({old.TextureWidth})", (objectInfo, textureWidth) => { objectInfo.TextureWidth = (uint)textureWidth; return objectInfo; }, 1, 255);
        QueryInt(objectInfo, $"TextureHeight ({old.TextureHeight})", (objectInfo, textureHeight) => { objectInfo.TextureHeight = (uint)textureHeight; return objectInfo; }, 1, 255);
        QueryInt(objectInfo, $"MappedWidth ({old.MappedTextureWidth})", (objectInfo, mappedWidth) => { objectInfo.MappedTextureWidth = (uint)mappedWidth; return objectInfo; }, 1, 65535);
        QueryInt(objectInfo, $"MappedHeight ({old.MappedTextureHeight})", (objectInfo, mappedHeight) => { objectInfo.MappedTextureHeight = (uint)mappedHeight; return objectInfo; }, 1, 65535);
        QueryInt(objectInfo, $"Frames ({old.NumAnimationFrames})", (objectInfo, frames) => { objectInfo.NumAnimationFrames = (uint)frames; return objectInfo; }, 1, 255);
        QueryInt(objectInfo, $"ColorIndex ({old.ColorIndex})", (objectInfo, colorIndex) => { objectInfo.ColorIndex = (byte)colorIndex; return objectInfo; }, 0, 31);
        QueryFlags(objectInfo, $"Flags ({GetObjectFlagNames(old.Flags)})", (objectInfo, flags) => { objectInfo.Flags = flags; return objectInfo; }, AllObjectFlags);
        QueryInt(objectInfo, $"CombatBackground ({(uint)old.Flags >> 28})", (objectInfo, combatBackground) => { objectInfo.Flags = (ObjectFlags)((uint)objectInfo.Flags | ((uint)combatBackground << 28)); return objectInfo; }, 0, 15);

        labdata.ObjectInfos[index - 1] = objectInfo.Value;

        foreach (var obj in labdata.Objects)
        {
            if (obj.SubObjects != null)
            {
                for (int i = 0; i < obj.SubObjects.Count; ++i)
                {
                    if (obj.SubObjects[i].Object.Equals(old))
                    {
                        var subObject = obj.SubObjects[i];
                        subObject.Object = objectInfo.Value;
                        obj.SubObjects[i] = subObject;
                    }
                }
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
    Console.Write("Enter: ");
    var option = Console.ReadLine();

    if (option == "0")
    {
        PrintWalls(true);
        Delete(labdata.Walls);
    }
    else if (option == "1")
    {
        PrintObjects(true);
        Delete(labdata.Objects);
    }
    else if (option == "2")
    {
        PrintObjectInfos(true);
        Delete(labdata.ObjectInfos);
    }
    else
        Console.WriteLine("Invalid choice. Aborting.");

    Console.WriteLine();

    void Delete<T>(List<T> list) where T : struct
    {
        Console.WriteLine();
        Console.WriteLine("Which index to delete?");
        Console.Write("Index: ");
        var indexChoice = Console.ReadLine();
        Console.WriteLine();

        if (!int.TryParse(indexChoice, out int index) || index < 1 || index > list.Count)
        {
            Console.WriteLine("Invalid index. Aborting.");
            return;
        }

        var backup = list[index - 1];
        list.RemoveAt(index - 1);

        Console.WriteLine($"Item with index {index} was deleted.");

        if (typeof(T) == typeof(Labdata.ObjectInfo))
        {
            foreach (var obj in labdata.Objects)
            {
                for (int i = 0; i < 8; ++i)
                {
                    if (i >= obj.SubObjects.Count)
                        break;

                    if (obj.SubObjects[i].Object.Equals((Labdata.ObjectInfo)(object)backup))
                        obj.SubObjects.RemoveAt(i);
                }
            }
        }
    }
}
