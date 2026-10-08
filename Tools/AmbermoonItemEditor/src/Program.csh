//! AmbermoonItemEditor: shows, adds, edits and removes the items of the game, in an item file (Objects.amb/001) or,
//! before version 1.14, in the executables AM2_CPU and AM2_BLIT (a port of AmbermoonTools/AmbermoonItemEditor).
//!
//!   AmbermoonItemEditor <path>
namespace AmbermoonItemEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

// the items being edited: of the item file or of AM2_CPU (and then also of AM2_BLIT), and the folder they are saved to
ItemList Items1 = ItemList { Items = List<EditorItem>.Create(), Hunks = List<Hunk>.Create() };
ItemList Items2 = ItemList { Items = List<EditorItem>.Create(), Hunks = List<Hunk>.Create() };
bool HasItems2 = false;
string SourcePath = "";
ValueDescription[] Descriptions = ItemValueDescriptions();

int Main(string[] args)
{
    // (the original ends with an exception without an argument)
    if (args.Length == 0)
    {
        ShowHelp();
        return 1;
    }

    if (IsFile(args[0]))
    {
        var items = File.ReadAllBytes(args[0]) is uint8[] bytes ? ItemList.FromItemFile(bytes) : error("");
        if (items is not ItemList itemList)
        {
            Console.WriteLine("Unable to load item data.");
            Console.WriteLine();
            ShowHelp();
            return 0;
        }

        Items1 = itemList;
        SourcePath = Path.GetDirectory(args[0]);
    }
    else
    {
        var gameData = GameData.Create(LoadPreference.ForceExtracted, false);

        if (gameData.Load(args[0]) is error || !gameData.Files.ContainsKey("AM2_CPU") ||
            !gameData.Files.ContainsKey("AM2_BLIT"))
        {
            Console.WriteLine("Unable to load executables.");
            Console.WriteLine();
            ShowHelp();
            return 1;
        }

        // (the original ends with an exception if an executable has no items)
        var exe1 = ItemList.FromExecutable(gameData.Files["AM2_CPU"].Files[1]);
        if (exe1 is error exe1Error)
        {
            Console.WriteLine("Unable to load the items of AM2_CPU: " + exe1Error.Message);
            return 1;
        }
        var exe2 = ItemList.FromExecutable(gameData.Files["AM2_BLIT"].Files[1]);
        if (exe2 is error exe2Error)
        {
            Console.WriteLine("Unable to load the items of AM2_BLIT: " + exe2Error.Message);
            return 1;
        }
        if (exe1 is not ItemList cpuItems)
            return 1;
        if (exe2 is not ItemList blitItems)
            return 1;

        Items1 = cpuItems;
        Items2 = blitItems;
        HasItems2 = true;
        SourcePath = args[0];
    }

    ProcessExecutables();
    return 0;
}

void PrintLine()
{
    Console.WriteLine("*" + "".PadLeft(77, '=') + "*");
}

void PrintHeader(string text, bool addEmptyTrailingLine)
{
    if (text.Length > 75)
        text = text[0..75].ToString();

    Console.WriteLine();
    PrintLine();
    Console.WriteLine("* " + text + "".PadLeft(76 - text.Length, ' ') + "*");
    PrintLine();
    if (addEmptyTrailingLine)
        Console.WriteLine();
}

// a line of input; the original fails at the end of the input of a command (an item file: it shows "Unable to load
// item data." and the help), this ends the program
string ReadLineOrExit()
{
    if (Console.ReadLine() is string line)
        return line;
    Environment.Exit(0);
    return "";
}

void ProcessExecutables()
{
    PrintHeader("Items", true);
    Items1.PrintItems();

    while (true)
    {
        PrintHeader("Choose command:", false);
        Console.WriteLine("A: Add item");
        Console.WriteLine("E: Edit item");
        Console.WriteLine("R: Remove item");
        Console.WriteLine("S: Save items");
        Console.WriteLine("I: Show items");
        Console.WriteLine("P: List item properties");
        Console.WriteLine("F: Find item id");
        Console.WriteLine("H: Show help");
        Console.WriteLine("Q: Quit");
        PrintLine();
        Console.Write("> ");
        string input = ToLowerNet(ReadLineOrExit());

        PrintLine();

        switch (input)
        {
            case "a":
            case "add":
            case "add item":
            case "additem":
                AddItem();
                break;
            case "e":
            case "edit":
            case "edit item":
            case "edititem":
                EditItem(false, null);
                break;
            case "r":
            case "remove":
            case "remove item":
            case "removeitem":
            case "delete":
            case "delete item":
            case "deleteitem":
                RemoveItem();
                break;
            case "s":
            case "save":
            case "save items":
            case "saveitems":
                Save();
                break;
            case "q":
            case "quit":
            case "exit":
                return;
            case "h":
            case "help":
                ShowHelp();
                break;
            case "i":
            case "items":
                PrintHeader("Items", true);
                Items1.PrintItems();
                break;
            case "p":
            case "props":
            case "properties":
            case "item properties":
            case "list item properties":
                ShowItem();
                break;
            case "f":
            case "find":
            case "find item":
            case "finditem":
            case "find item id":
            case "finditemid":
                FindItem();
                break;
            default:
                Console.WriteLine();
                Console.WriteLine("Invalid command.");
                Console.WriteLine();
                break;
        }
    }
}

void ShowHelp()
{
    Console.WriteLine();
    Console.WriteLine("Usage: AmbermoonItemEditor <path>");
    Console.WriteLine();
    Console.WriteLine(" <path>  Either the extracted item data file like Objects.amb/001 or the game data");
    Console.WriteLine("         directory like my/path/Amberfiles.");
    Console.WriteLine();
    Console.WriteLine("Note: If a game data directory is given, the item data is read from the main executables");
    Console.WriteLine("      AM2_CPU or AM2_BLIT. This is the old way (Ambermoon english 1.13/german 1.12 and below).");
    Console.WriteLine();
    Console.WriteLine("      For new versions the item data file should be used instead. First extract Objects.amb");
    Console.WriteLine("      to some folder and use the extracted single sub-file 001 as an input for this tool.");
    Console.WriteLine("      You can use this command for extraction AmbermoonPack UNPACK Objects.amb Objects");
    Console.WriteLine("      Later you can pack this file again with: AmbermoonPack JH+LOB Objects/001 Objects.amb 0xd2e7.");
    Console.WriteLine();
}

void AddItem()
{
    PrintHeader("Add item", true);

    Items1.AddItem();
    if (HasItems2)
        Items2.AddItem();

    EditItem(true, Items1.ItemCount() - 1);
}

// `int.TryParse` of a line of input (hex: hexadecimal digits); null if it is no number or the input ended
Optional<int> ReadInt(bool hex)
{
    if (Console.ReadLine() is not string line)
        return null;
    return hex ? ParseHex(line) : ParseInt(line);
}

// a choice from the options; the default for no number or one that is no option
int ReadOption(string text, int defaultOption, ReadOnlySlice<string> options)
{
    for (var i = 0; i < options.Length; i += 1)
        Console.WriteLine(i == defaultOption ? $"[{i}]: {options[i]}" : $"{i}: {options[i]}");

    Console.Write(text + " ");
    if (ReadInt(false) is not int option)
        return defaultOption;
    if (option < 0 || option >= options.Length)
        return defaultOption;
    return option;
}

// a value of an enum: the number of an option or flags in hex (the default if none is given)
Optional<int> ReadEnum(string text, Optional<int> defaultOption, ValueDescription description)
{
    var options = description.AllowedValues();

    for (var i = 0; i < options.Length; i += 1)
    {
        string name = EnumValueText(description, options[i]);
        if (description.Flags)
            Console.WriteLine($"0x{((uint32)options[i]).ToString("x8")}: {name}");
        else
            Console.WriteLine($"{i}: {name}");
    }

    Console.Write(text + " ");
    if (description.Flags)
        Console.Write("0x");
    var option = ReadInt(description.Flags);

    if (option is int number && !description.Flags && (number < 0 || number >= options.Length))
        return defaultOption;

    return option != null ? option : defaultOption;
}

// the text of an enum value (Enum.ToString)
string EnumValueText(ValueDescription description, int64 value)
{
    return description.EnumType.Text(description.EnumType.FromNumber(value));
}

// the 60 bytes of an item
uint8[] ItemData(Item item)
{
    var writer = new DataWriter();
    ItemWriter.WriteItem(item, ref writer);
    return writer.ToArray();
}

// the index of an item entered as its number (from 1 on); null if it is none
Optional<int> ReadItemIndex()
{
    Console.Write("Enter item index: ");
    if (ReadInt(false) is not int number)
        return null;
    if (number < 1 || number > Items1.ItemCount())
        return null;
    return number - 1;
}

void PrintInvalidItemIndex()
{
    Console.WriteLine();
    Console.WriteLine("Invalid item index");
    Console.WriteLine();
}

void FindItem()
{
    Console.WriteLine();
    Console.Write("Enter (partial) item name: ");
    string name = Console.ReadLine() is string line ? line : "";

    Console.WriteLine();

    var matchingItems = Items1.FindItems(name);

    if (matchingItems.Count() == 0)
        Console.WriteLine("No matching items found.");
    else
    {
        foreach (var item in matchingItems)
            Console.WriteLine($" {FormatIndex(item.Item.Index)}: {item.Item.Name}");
    }

    Console.WriteLine();
}

bool OnlySingleBitSet(int64 value)
{
    return value != 0 && (value & (value - 1)) == 0;
}

void ShowItem()
{
    Items1.PrintItems();

    PrintHeader("List item properties", true);

    if (ReadItemIndex() is not int index)
    {
        PrintInvalidItemIndex();
        return;
    }

    var item = Items1.Items[index].Item;
    var data = ItemData(item);
    int dataIndex = 0;

    Console.WriteLine();
    Console.WriteLine("[Item: " + item.Name + "]");

    foreach (var value in Descriptions)
    {
        int currentValue = value.Read(data, ref dataIndex);

        if (value.Kind == DescriptionKind.Enum)
        {
            Console.Write($"- {value.Name}:");
            var values = List<string>.Create(16);
            var options = value.AllowedValues();

            if (value.Flags)
            {
                foreach (var option in options)
                {
                    if (OnlySingleBitSet(option) && (currentValue & option) != 0)
                        values.Add(EnumValueText(value, option));
                }
            }
            else if (currentValue >= 0 && currentValue < options.Length)
            {
                // (for items the values of the enums are a sequence without gaps)
                values.Add(EnumValueText(value, options[currentValue]));
            }

            if (values.Count() == 0)
                values.Add(value.DefaultValueText());

            if (values.Count() == 1)
                Console.WriteLine(" " + values[0]);
            else
            {
                Console.WriteLine();
                foreach (var v in values)
                    Console.WriteLine("  | " + v);
            }
        }
        else
        {
            Console.WriteLine($"- {value.Name}: {currentValue}");
        }
    }

    Console.WriteLine();
}

void EditItem(bool adding, Optional<int> id)
{
    if (!adding)
    {
        Items1.PrintItems();

        PrintHeader("Edit item", true);

        id = ReadItemIndex();
    }

    if (id is not int index)
    {
        PrintInvalidItemIndex();
        return;
    }
    if (index < 0 || index >= Items1.ItemCount())
    {
        PrintInvalidItemIndex();
        return;
    }

    Items1.SetItem(index, EditedItem(Items1.Items[index], adding, index));
}

// the item with the values entered (the item as it was if the editing is aborted); the original reads each value from
// one position and writes it to the next (it shows wrong values and ends with an exception for an item that exists),
// this writes it where it was read
EditorItem EditedItem(EditorItem entry, bool adding, int index)
{
    var data = ItemData(entry.Item);
    int dataIndex = 0;

    foreach (var value in Descriptions)
    {
        int valueStart = dataIndex;

        if (value.Required)
        {
            Optional<int> currentValue = null;
            if (!adding)
                currentValue = value.Read(data, ref dataIndex);
            dataIndex = valueStart;
            string currentValueSuffix = currentValue is int current ? $" ({current})" : "";
            Optional<int> input;

            if (value.Kind == DescriptionKind.Enum)
                input = ReadEnum($"> {value.Name}{currentValueSuffix}:", currentValue, value);
            else
            {
                Console.Write($"> {value.Name}{currentValueSuffix}: ");
                input = ReadInt(value.ShowAsHex);
                if (input == null)
                    input = currentValue;
            }

            if (input is not int inputValue)
            {
                Console.WriteLine("No value given. Aborting.");
                Console.WriteLine();
                return entry;
            }
            uint16 checkedValue = value.Type == ValueType.SByte ? (uint16)(inputValue & 0xff) : (uint16)(inputValue & 0xffff);
            if (!value.Check(checkedValue))
            {
                Console.WriteLine("Invalid value given. Aborting.");
                Console.WriteLine();
                return entry;
            }

            value.Write(data, ref dataIndex, (uint16)(inputValue & 0xffff));
        }
        else
        {
            int currentValue = value.DefaultValue;
            if (!adding)
                currentValue = value.Read(data, ref dataIndex);
            dataIndex = valueStart;
            string currentValueSuffix = $" ({currentValue})";
            int input = currentValue;

            if (value.Kind == DescriptionKind.Enum)
            {
                if (ReadEnum($"> {value.Name}{currentValueSuffix}:", currentValue, value) is int option)
                    input = option;
            }
            else
            {
                Console.Write($"> {value.Name}{currentValueSuffix}: ");
                if (ReadInt(value.ShowAsHex) is int number)
                    input = number;
            }

            // (the original takes no negative values: the current value of a negative signed byte becomes the default)
            int minimum = value.Type == ValueType.SByte ? -128 : 0;
            if (input < minimum || input > 0xffff || !value.Check((uint16)(input & 0xffff)))
            {
                Console.WriteLine($"Invalid value given. Using default: {value.DefaultValueText()}");
                input = value.DefaultValue;
            }

            value.Write(data, ref dataIndex, (uint16)(input & 0xffff));
        }
    }

    Optional<string> currentName = null;
    if (!adding && entry.HasName)
        currentName = entry.Item.Name;
    string currentNameSuffix = currentName is string shownName ? $" ({shownName})" : "";
    Console.Write($"> Name{currentNameSuffix}: ");
    string name = Console.ReadLine() is string line ? line : "";

    if (IsWhiteSpaceOnlyNet(name))
    {
        name = currentName is string current ? current : "";
        if (IsWhiteSpaceOnlyNet(name))
        {
            Console.WriteLine("Invalid name entered. Aborting.");
            return entry;
        }
    }

    var nameBytes = AmbermoonEncoding.GetBytes(FirstUtf16Characters(name, 19));
    Array.Copy(nameBytes, 0, data, 40, nameBytes.Length);
    for (var i = 40 + nameBytes.Length; i < 60; i += 1)
        data[i] = 0;

    var reader = DataReader.FromData(data);
    if (ItemReader.ReadItem(0, ref reader) is not Item item)
        return entry;

    var edited = EditorItem { Item = item, HasName = true };
    if (HasItems2)
        Items2.SetItem(index, edited);

    return edited;
}

// the first `count` UTF-16 characters of a text (`Substring(0, count)`; all of it if it is shorter)
string FirstUtf16Characters(string text, int count)
{
    int i = 0;
    while (i < text.Length && count > 0)
    {
        uint8 b = text[i];
        int bytes = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        // (a character outside of the BMP is two UTF-16 characters: it is left out if only one fits)
        if (bytes == 4 && count < 2)
            break;
        count -= bytes == 4 ? 2 : 1;
        i += bytes;
    }
    return text[0..i].ToString();
}

void RemoveItem()
{
    Items1.PrintItems();

    PrintHeader("Remove item", true);

    Console.Write("Enter item index: ");

    if (ReadInt(false) is not int id)
    {
        PrintInvalidItemIndex();
        return;
    }

    Items1.RemoveItem(id);
    if (HasItems2)
        Items2.RemoveItem(id);

    Console.WriteLine();
}

void Save()
{
    PrintHeader("Save items", true);

    if (!Items1.IsExecutable)
    {
        WriteFile(Path.Combine(SourcePath, "001"), Items1.Save());
    }
    else
    {
        int option = ReadOption("Where to save it?", 0, ["Back to loaded data", "To custom path"]);

        if (option == 0)
        {
            var cpu = Items1.Save();
            var blit = Items2.Save();
            WriteFile(Path.Combine(SourcePath, "AM2_CPU"), cpu);
            WriteFile(Path.Combine(SourcePath, "AM2_BLIT"), blit);
        }
        // (the original does nothing for a custom path either)
    }
}

// writes the data to the file (the original ends with an exception if it cannot)
void WriteFile(string path, Error<uint8[]> data)
{
    if (data is error dataError)
        Console.WriteLine($"Unable to save '{path}': {dataError.Message}");
    else if (data is uint8[] bytes && File.WriteAllBytes(path, bytes) is error)
        Console.WriteLine($"Unable to write file '{path}'.");
}
