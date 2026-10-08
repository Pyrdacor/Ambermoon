// Reading numbers and options from the console like the original (int.TryParse of .NET: ParseInt, ParseHex).
namespace AmbermoonEventEditor;

using System;
using Ambermoon;

// a line of input; the original fails at the end of the input, this ends the program
string ReadLine()
{
    if (Console.ReadLine() is string line)
        return line;
    Environment.Exit(0);
    return "";
}

// reads a number (hexadecimal with an optional "$" or "0x" in front if hex)
Optional<int> ReadInt(bool hex)
{
    string input = ReadLine().ToLower();
    if (hex)
    {
        if (input.StartsWith("$"))
            input = input[1..].ToString();
        else if (input.StartsWith("0x"))
            input = input[2..].ToString();
        return ParseHex(input);
    }
    return ParseInt(input);
}

Optional<int> ReadInt()
{
    return ReadInt(false);
}

// shows the numbered options and reads one; the default for anything else
int ReadOption(int defaultOption, string[] options)
{
    for (var i = 0; i < options.Length; i += 1)
        Console.WriteLine($"{i}: {options[i]}");

    Console.Write("Enter: ");
    var option = ReadInt();

    if (option is int o && (o < 0 || o >= options.Length))
        return defaultOption;

    return option is int chosen ? chosen : defaultOption;
}
