using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Globalization;
using System.IO;
using ValueType = Ambermoon.Data.Descriptions.ValueType;

namespace AmbermoonItemEditor
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var gameData = new GameData(GameData.LoadPreference.ForceExtracted, null, false);

            try
            {
                gameData.Load(args[0]);

                if (!gameData.Files.ContainsKey("AM2_CPU") || !gameData.Files.ContainsKey("AM2_BLIT"))
                    throw new Exception();
            }
            catch
            {
                Console.WriteLine("Unable to load executables.");
                Environment.Exit(1);
                return;
            }

            var exe1 = new Executable(gameData.Files["AM2_CPU"].Files[1]);
            var exe2 = new Executable(gameData.Files["AM2_BLIT"].Files[1]);

            ProcessExecutables(args[0], exe1, exe2);
        }

        static void PrintLine()
        {
            Console.WriteLine("*" + new string('=', 77) + "*");
        }

        static void PrintHeader(string text, bool addEmptyTrailingLine = true)
        {
            text = text.Substring(0, Math.Min(text.Length, 75));

            Console.WriteLine();
            PrintLine();
            Console.WriteLine("* " + text + new string(' ', 76 - text.Length) + "*");
            PrintLine();
            if (addEmptyTrailingLine)
                Console.WriteLine();
        }

        static void ProcessExecutables(string sourcePath, Executable exe1, Executable exe2)
        {
            PrintHeader("Items");
            exe1.PrintItems();

            while (true)
            {
                PrintHeader("Choose command:", false);
                Console.WriteLine("A: Add item");
                Console.WriteLine("E: Edit item");
                Console.WriteLine("R: Remove item");
                Console.WriteLine("S: Save items");
                Console.WriteLine("I: Show items");
                Console.WriteLine("H: Show help");
                Console.WriteLine("Q: Quit");
                PrintLine();
                Console.Write("> ");
                string input = Console.ReadLine().ToLower();

                PrintLine();

                switch (input)
                {
                    case "a":
                    case "add":
                    case "add item":
                    case "additem":
                        AddItem(exe1, exe2);
                        break;
                    case "e":
                    case "edit":
                    case "edit item":
                    case "edititem":
                        EditItem(exe1, exe2);
                        break;
                    case "r":
                    case "remove":
                    case "remove item":
                    case "removeitem":
                    case "delete":
                    case "delete item":
                    case "deleteitem":
                        RemoveItem(exe1, exe2);
                        break;
                    case "s":
                    case "save":
                    case "save items":
                    case "saveitems":
                        Save(sourcePath, exe1, exe2);
                        break;
                    case "q":
                    case "quit":
                    case "exit":
                        Environment.Exit(0);
                        return;
                    case "h":
                    case "help":
                        ShowHelp();
                        break;
                    case "i":
                    case "items":
                        PrintHeader("Items");
                        exe1.PrintItems();
                        break;
                    default:
                        Console.WriteLine();
                        Console.WriteLine("Invalid command.");
                        Console.WriteLine();
                        ShowHelp();
                        break;
                }
            }
        }

        static void ShowHelp()
        {
            // TODO
        }

        static void AddItem(Executable exe1, Executable exe2)
        {
            PrintHeader("Add item");

            exe1.AddItem();
            exe2.AddItem();

            EditItem(exe1, exe2, true, exe1.ItemCount - 1);
        }

        static int? ReadInt(bool hex = false)
        {
            if (hex)
                return int.TryParse(Console.ReadLine(), NumberStyles.AllowHexSpecifier, null, out int hexValue) ? hexValue : (int?)null;

            return int.TryParse(Console.ReadLine(), out int value) ? value : (int?)null;
        }

        static int? ReadOption(string text, int? defaultOption, params string[] options)
        {
            for (int i = 0; i < options.Length; ++i)
                Console.WriteLine(i == defaultOption ? $"[{i}]: {options[i]}" : $"{i}: {options[i]}");

            Console.Write(text + " ");
            var option = ReadInt();

            if (option != null && option < 0 || option >= options.Length)
                return defaultOption;

            return option ?? defaultOption;
        }

        static int? ReadEnum(string text, int? defaultOption, bool flags, params object[] options)
        {
            if (flags)
            {
                for (int i = 0; i < options.Length; ++i)
                    Console.WriteLine($"0x{(uint)Convert.ChangeType(options[i], typeof(uint)):x8}: {options[i]}");
            }
            else
            {
                for (int i = 0; i < options.Length; ++i)
                    Console.WriteLine($"{i}: {options[i]}");
            }

            Console.Write(text + " ");
            if (flags)
                Console.Write("0x");
            var option = ReadInt(flags);

            if (option != null && !flags && (option < 0 || option >= options.Length))
                return defaultOption;

            return option ?? defaultOption;
        }

        static void EditItem(Executable exe1, Executable exe2, bool adding = false, int? id = null)
        {
            if (!adding)
            {
                exe1.PrintItems();

                PrintHeader("Edit item");

                Console.Write("Enter item index: ");
                id = ReadInt();

                if (id != null)
                    --id;
            }

            if (id == null || id < 0 || id >= exe1.ItemCount)
            {
                Console.WriteLine();
                Console.WriteLine("Invalid item index");
                Console.WriteLine();
                return;
            }

            exe1.UpdateItem(id.Value, item =>
            {
                var writer = new DataWriter();
                ItemWriter.WriteItem(item, writer);
                var data = writer.ToArray();
                int dataIndex = 0;

                void Write(ValueDescription valueDescription, ushort value)
                {
                    if (valueDescription.Type == ValueType.Word ||
                        valueDescription.Type == ValueType.Flag16 ||
                        valueDescription.Type == ValueType.EventIndex)
                        WriteWord(value);
                    else if (valueDescription.Type == ValueType.SByte)
                        data[dataIndex++] = unchecked((byte)(sbyte)value);
                    else
                        data[dataIndex++] = (byte)(value & 0xff);
                }

                int Read(ValueDescription valueDescription)
                {
                    if (valueDescription.Type == ValueType.Word ||
                        valueDescription.Type == ValueType.Flag16 ||
                        valueDescription.Type == ValueType.EventIndex)
                        return ReadWord();
                    else if (valueDescription.Type == ValueType.SByte)
                        return unchecked((sbyte)data[dataIndex]);
                    else
                        return data[dataIndex];
                }

                void WriteWord(ushort value)
                {
                    data[dataIndex++] = (byte)((value >> 8) & 0xff);
                    data[dataIndex++] = (byte)(value & 0xff);
                }
                
                ushort ReadWord()
                {
                    return (ushort)(((ushort)data[dataIndex] << 8) | data[dataIndex + 1]);
                }

                foreach (var value in ItemDescription.ValueDescriptions)
                {
                    if (value.Required)
                    {
                        int? currentValue = adding ? (int?)null : Read(value);
                        string currentValueSuffix = currentValue == null ? "" : $" ({ currentValue})";
                        int? input;

                        if (value is IEnumValueDescription enumValueDescription)
                        {
                            input = ReadEnum($"> {value.Name}{currentValueSuffix}:", currentValue, enumValueDescription.Flags, enumValueDescription.AllowedValues);
                        }
                        else
                        {
                            Console.Write($"> {value.Name}{currentValueSuffix}: ");
                            input = ReadInt(value.ShowAsHex) ?? currentValue;
                        }

                        if (input == null)
                        {
                            Console.WriteLine("No value given. Aborting.");
                            Console.WriteLine();
                            return item;
                        }
                        else if (!value.Check(value.Type == ValueType.SByte ? unchecked((ushort)(byte)(sbyte)input.Value) : (ushort)input.Value))
                        {
                            Console.WriteLine("Invalid value given. Aborting.");
                            Console.WriteLine();
                            return item;
                        }

                        Write(value, (ushort)input.Value);
                    }
                    else
                    {
                        int? currentValue = adding ? value.DefaultValue : Read(value);
                        string currentValueSuffix = $" ({ currentValue})";
                        int? input;

                        if (value is IEnumValueDescription enumValueDescription)
                        {
                            input = ReadEnum($"> {value.Name}{currentValueSuffix}:", currentValue, enumValueDescription.Flags, enumValueDescription.AllowedValues);
                        }
                        else
                        {
                            Console.Write($"> {value.Name}{currentValueSuffix}: ");
                            input = ReadInt(value.ShowAsHex) ?? currentValue;
                        }

                        if (input < 0 || input > 0xffff || !value.Check((ushort)input))
                        {
                            Console.WriteLine($"Invalid value given. Using default: {value.DefaultValueText}");
                            input = value.DefaultValue;
                        }

                        Write(value, (ushort)input);
                    }
                }

                string currentName = adding ? null : item.Name;
                string currentNameSuffix = currentName == null ? "" : $" ({currentName})";
                Console.Write($"> Name{currentNameSuffix}: ");
                string name = Console.ReadLine();

                if (string.IsNullOrWhiteSpace(name))
                {
                    name = currentName;

                    if (string.IsNullOrWhiteSpace(name))
                    {
                        Console.WriteLine("Invalid name entered. Aborting.");
                        return item;
                    }
                }

                name = name.Substring(0, Math.Min(19, name.Length));
                var nameBytes = new AmbermoonEncoding().GetBytes(name);
                Array.Copy(nameBytes, 0, data, 40, nameBytes.Length);
                int remaining = 20 - nameBytes.Length;

                for (int i = 0; i < remaining; ++i)
                    data[59 - i] = 0;

                var itemReader = new ItemReader();
                item = new Ambermoon.Data.Item();
                itemReader.ReadItem(item, new DataReader(data));

                exe2.UpdateItem(id.Value, _ => item);

                return item;
            });
        }

        static void RemoveItem(Executable exe1, Executable exe2)
        {
            exe1.PrintItems();

            PrintHeader("Remove item");

            Console.Write("Enter item index: ");
            var id = ReadInt();

            if (id == null)
            {
                Console.WriteLine();
                Console.WriteLine("Invalid item index");
                Console.WriteLine();
                return;
            }

            exe1.RemoveItem(id.Value);
            exe2.RemoveItem(id.Value);

            Console.WriteLine();
        }

        static void Save(string sourcePath, Executable exe1, Executable exe2)
        {
            PrintHeader("Save items");

            int option = ReadOption("Where to save it?", 0, "Back to loaded data", "To custom path") ?? 0;

            if (option == 0)
            {
                var temp1 = Path.GetTempFileName();
                var temp2 = Path.GetTempFileName();
                {
                    using var am2_cpu = File.Create(temp1);
                    using var am2_blit = File.Create(temp2);
                    exe1.Save(am2_cpu);
                    exe2.Save(am2_blit);
                }
                File.Move(temp1, Path.Combine(sourcePath, "AM2_CPU"), true);
                File.Move(temp2, Path.Combine(sourcePath, "AM2_BLIT"), true);
            }
            else
            {
                // TODO
            }
        }
    }
}
