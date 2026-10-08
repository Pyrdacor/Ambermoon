//! HexValueChanger: changes bytes at an offset in one file or in many files at once (a port of
//! AmbermoonTools/HexValueChanger).
namespace HexValueChanger;

using System;
using Ambermoon;

// the files and their contents (changed in memory until they are saved)
List<string> FileNames = List<string>.Create();
List<uint8[]> FileData = List<uint8[]>.Create();

int Main(string[] args)
{
    List<string> files;
    if (args.Length == 1)
    {
        files = List<string>.Create();
        files.Add(args[0]);
    }
    else if (args.Length == 2)
    {
        if (!Directory.Exists(args[0]))
            return DirectoryNotFound(args[0]);
        files = FindFiles(args[0], args[1], false);
    }
    else if (args.Length == 3)
    {
        int index = -1;
        for (var i = 0; i < 3 && index == -1; i += 1)
        {
            if (args[i] == "-r")
                index = i;
        }

        if (index == -1)
        {
            Console.WriteLine("Invalid number of arguments.");
            Usage();
            return 1;
        }

        string directory = index == 0 ? args[1] : args[0];
        if (!Directory.Exists(directory))
            return DirectoryNotFound(directory);
        files = FindFiles(directory, index == 2 ? args[1] : args[2], true);
    }
    else
    {
        Console.WriteLine("Invalid number of arguments.");
        Usage();
        return 1;
    }

    foreach (var file in files)
    {
        if (File.ReadAllBytes(file) is not uint8[] data)
        {
            Console.WriteLine($"Could not find file '{Path.GetFullPath(file)}'.");
            return 1;
        }
        FileNames.Add(file);
        FileData.Add(data);
    }

    ProcessFiles();
    return 0;
}

int DirectoryNotFound(string directory)
{
    Console.WriteLine($"Could not find a part of the path '{Path.GetFullPath(directory)}'.");
    return 1;
}

// What a special input stands for.
enum Command : uint8
{
    None,
    Save,
    Quit,
    Abort,
    Commit,
    Keep,
    And,
    Or,
    Xor,
    Invert
}

// The input: a number, a command or neither.
struct Input
{
    Command Command;
    Optional<int> Value;
}

// a line of input; the original reads empty lines at the end of the input forever, this ends the program (without
// saving)
string ReadLine()
{
    if (Console.ReadLine() is string line)
        return line;
    Console.WriteLine();
    Environment.Exit(0);
    return "";
}

// a number: hexadecimal with "0x" or "$" in front, else decimal
Optional<int> ParseNumber(string input)
{
    if (input.StartsWith("0x"))
        return ParseHex(input[2..]);
    if (input.StartsWith("$"))
        return ParseHex(input[1..]);
    return ParseInt(input);
}

Optional<int> ReadInt()
{
    return ParseNumber(ReadLine());
}

// reads a number or one of the commands (as single letters or characters) that are allowed
Input ReadInput(Command[] commands)
{
    string input = ReadLine();
    Command command = Command.None;
    if (input == "s" || input == "S")
        command = Command.Save;
    else if (input == "q" || input == "Q")
        command = Command.Quit;
    else if (input == "x" || input == "X")
        command = Command.Abort;
    else if (input == "c" || input == "C")
        command = Command.Commit;
    else if (input == "")
        command = Command.Keep;
    else if (input == "&")
        command = Command.And;
    else if (input == "|")
        command = Command.Or;
    else if (input == "^")
        command = Command.Xor;
    else if (input == "~")
        command = Command.Invert;

    if (command != Command.None)
    {
        foreach (var allowed in commands)
        {
            if (allowed == command)
                return Input { Command = command };
        }
    }

    return Input { Value = ParseNumber(input) };
}

void Error(string error)
{
    Console.WriteLine();
    Console.WriteLine("Error: " + error);
    Console.WriteLine();
}

void SaveAndExit()
{
    for (var i = 0; i < FileNames.Count(); i += 1)
    {
        if (File.WriteAllBytes(FileNames[i], FileData[i]) is IoError error)
        {
            Console.WriteLine($"Could not write file '{FileNames[i]}'.");
            Environment.Exit(1);
        }
    }
    Environment.Exit(0);
}

void InvalidByte()
{
    Console.WriteLine("Invalid input. Use values in the range 0 to 255.");
    Console.WriteLine("You can also use hex values with 0x12 or $12.");
    Console.WriteLine();
}

// How a new value changes the byte.
enum Operation : uint8
{
    Set,
    Keep,
    And,
    Or,
    Xor,
    Invert
}

struct Change
{
    Operation Operation;
    uint8 Value;
}

void ProcessFiles()
{
    while (true)
    {
        Console.WriteLine("Change hex values");
        Console.WriteLine("Type s to save all changes back to the files and quit.");
        Console.WriteLine("Type q to quit without saving any changes.");
        Console.WriteLine();

        Console.Write("Offset: ");
        var offsetInput = ReadInput([Command.Save, Command.Quit]);

        if (offsetInput.Command == Command.Save)
            SaveAndExit();
        if (offsetInput.Command == Command.Quit)
            Environment.Exit(0);

        if (offsetInput.Value is not int offset)
        {
            Error("Invalid offset.");
            continue;
        }

        Console.Write("Length: ");
        int length = 1;

        if (ReadInt() is int l)
            length = l;
        else
            Console.WriteLine(" -> Invalid length, assuming 1.");

        Console.WriteLine("Now enter the new hex values.");
        Console.WriteLine("Just hit enter to keep the source value.");
        Console.WriteLine("Type & to AND the byte with a value.");
        Console.WriteLine("Type | to OR the byte with a value.");
        Console.WriteLine("Type ^ to XOR the byte with a value.");
        Console.WriteLine("Type ~ to binary invert the byte.");
        Console.WriteLine("Type x to abort the whole change.");
        Console.WriteLine("Type c to leave all following values as is but commit the changed values.");
        Console.WriteLine("Type s to save all changes back to the files and quit.");
        Console.WriteLine("Type q to quit without saving any changes.");
        Console.WriteLine();

        var changes = List<Change>.Create();
        var commands = [Command.Abort, Command.Commit, Command.Save, Command.Quit, Command.Keep, Command.And, Command.Or,
                        Command.Xor, Command.Invert];
        bool save = false;
        bool quit = false;

        for (var i = 0; i < length; i += 1)
        {
            Console.Write($"New byte at offset 0x{((int)((int64)offset + i)).ToString("x4")}: ");
            var input = ReadInput(commands);
            var operation = Operation.Set;
            Optional<int> value = input.Value;

            switch (input.Command)
            {
                case Command.And:
                case Command.Or:
                case Command.Xor:
                    operation = input.Command == Command.And ? Operation.And
                        : input.Command == Command.Or ? Operation.Or : Operation.Xor;
                    Console.Write("Enter mask: ");
                    value = ReadInt();
                    break;
                case Command.Invert:
                    operation = Operation.Invert;
                    value = 0xff;
                    break;
                case Command.Keep:
                    operation = Operation.Keep;
                    value = 0;
                    break;
                default:
                    break;
            }

            if (input.Command == Command.Save || input.Command == Command.Commit)
                CommitValues(offset, changes);

            if (input.Command == Command.Save)
                save = true;
            if (input.Command == Command.Quit)
                quit = true;
            if (input.Command == Command.Commit || input.Command == Command.Abort || save || quit)
                break;

            int v = value is int number ? number : -1;
            if (v < 0 || v > 255)
            {
                InvalidByte();
                i -= 1;
                continue;
            }

            changes.Add(Change { Operation = operation, Value = (uint8)v });

            if (i == length - 1)
                CommitValues(offset, changes);
        }

        Console.WriteLine();

        if (save)
            SaveAndExit();
        if (quit)
            Environment.Exit(0);
    }
}

void CommitValues(int offset, List<Change> changes)
{
    for (var f = 0; f < FileData.Count(); f += 1)
    {
        var data = FileData[f];
        for (var i = 0; i < changes.Count(); i += 1)
        {
            int64 at = (int64)offset + i;
            if (at < 0 || at >= data.Length)
            {
                Console.WriteLine($"Offset 0x{((int)at).ToString("x4")} is outside of the file '{FileNames[f]}', it stays as it is there.");
                continue;
            }
            var change = changes[i];
            if (change.Operation == Operation.Keep)
                continue;
            switch (change.Operation)
            {
                case Operation.And:
                    data[(int)at] &= change.Value;
                    break;
                case Operation.Or:
                    data[(int)at] |= change.Value;
                    break;
                case Operation.Xor:
                case Operation.Invert:
                    data[(int)at] ^= change.Value;
                    break;
                default:
                    data[(int)at] = change.Value;
                    break;
            }
        }
    }
}

void Usage()
{
    Console.WriteLine();
    Console.WriteLine("Usage: HexChanger <filename>");
    Console.WriteLine("       HexChanger [-r] <directory> <filepattern>");
    Console.WriteLine();
    Console.WriteLine("File patterns can be *.txt etc.");
    Console.WriteLine("Use * for all files.");
    Console.WriteLine();
    Console.WriteLine("The optional -r switch will recursively search for files.");
    Console.WriteLine();
}
