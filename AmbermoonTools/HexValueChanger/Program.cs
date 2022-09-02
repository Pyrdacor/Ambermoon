using System.Globalization;

public static class Program
{
    public static void Main(string[] args)
    {
        if (args.Length == 1)
        {
            ProcessFiles(args[0]);
        }
        else if (args.Length == 2)
        {
            ProcessFiles(FindFiles(args[0], args[1]));
        }
        else if (args.Length == 3)
        {
            int index = args.ToList().FindIndex(arg => arg == "-r");

            if (index == -1)
            {
                Console.WriteLine("Invalid number of arguments.");
                Usage();
                Environment.Exit(1);
            }
            else
            {
                ProcessFiles(FindFiles(index == 0 ? args[1] : args[0], index == 2 ? args[1] : args[2], true));
            }
        }
        else
        {
            Console.WriteLine("Invalid number of arguments.");
            Usage();
            Environment.Exit(1);
        }
    }

    static string[] FindFiles(string directory, string filePattern, bool recursive = false)
    {
        return Directory.GetFiles(directory, filePattern, recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly);
    }

    static int? ReadInt(Dictionary<string, Func<int>>? customInputHandlers = null)
    {
        string input = Console.ReadLine() ?? "";

        if (customInputHandlers?.TryGetValue(input, out var handler) == true)
            return handler();

        int value;

        if (input.StartsWith("0x"))
            return int.TryParse(input[2..], NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out value) ? value : null;

        if (input.StartsWith("$"))
            return int.TryParse(input[1..], NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out value) ? value : null;

        return int.TryParse(input, out value) ? value : null;
    }

    static void ProcessFiles(params string[] files)
    {
        void Error(string error)
        {
            Console.WriteLine();
            Console.WriteLine("Error: " + error);
            Console.WriteLine();
        }

        var fileData = files.ToDictionary(f => f, f => File.ReadAllBytes(f));
        bool quit = false;
        bool save = false;

        while (true)
        {
            Console.WriteLine("Change hex values");
            Console.WriteLine("Type s to save all changes back to the files and quit.");
            Console.WriteLine("Type q to quit without saving any changes.");
            Console.WriteLine();

            Console.Write("Offset: ");
            var offset = ReadInt(new Dictionary<string, Func<int>>
            {
                { "s", () => { save = true; return -1; } },
                { "S", () => { save = true; return -1; } },
                { "q", () => { quit = true; return -1; } },
                { "Q", () => { quit = true; return -1; } }
            });

            if (save)
            {
                foreach (var file in fileData)
                {
                    File.WriteAllBytes(file.Key, file.Value);
                }
            }

            if (save || quit)
            {
                Environment.Exit(0);
                return;
            }

            if (offset == null)
            {
                Error("Invalid offset.");
                continue;
            }

            Console.Write("Length: ");
            var length = ReadInt();

            if (length == null)
            {
                Console.WriteLine(" -> Invalid length, assuming 1.");
            }

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

            List<byte> newValues = new();
            HashSet<int> andIndices = new();
            HashSet<int> orIndices = new();
            HashSet<int> xorIndices = new();
            HashSet<int> negIndices = new();

            for (int i = 0; i < length; ++i)
            {
                bool abort = false;
                bool commit = false;
                bool and = false;
                bool or = false;
                bool xor = false;
                bool neg = false;

                Console.Write($"New byte at offset 0x{offset + i:x4}: ");
                var value = ReadInt(new Dictionary<string, Func<int>>
                {
                    { "x", () => { abort = true; return -1; } },                    
                    { "X", () => { abort = true; return -1; } },
                    { "c", () => { commit = true; return -1; } },
                    { "C", () => { commit = true; return -1; } },
                    { "s", () => { save = true; return -1; } },
                    { "S", () => { save = true; return -1; } },
                    { "q", () => { quit = true; return -1; } },
                    { "Q", () => { quit = true; return -1; } },
                    { "&", () => { and = true; Console.Write("Enter mask: "); return ReadInt() ?? -1; } },
                    { "|", () => { or = true; Console.Write("Enter mask: "); return ReadInt() ?? -1; } },
                    { "^", () => { xor = true; Console.Write("Enter mask: "); return ReadInt() ?? -1; } },
                    { "~", () => { neg = true; return -1; } }
                });

                if ((and || or || xor) && value == -1)
                {
                    Console.WriteLine("Invalid input. Use values in the range 0 to 255.");
                    Console.WriteLine("You can also use hex values with 0x12 or $12.");
                    Console.WriteLine();
                    --i;
                    continue;
                }

                if (and) andIndices.Add(i);
                else if (or) orIndices.Add(i);
                else if (xor) xorIndices.Add(i);
                else if (neg) negIndices.Add(i);

                if (save || commit)
                {
                    CommitValues(offset.Value, length.Value, newValues,
                        andIndices, orIndices, xorIndices, negIndices);
                }

                if (commit || abort || save || quit)
                    break;

                if (value == null || value < 0 || value > 255)
                {
                    Console.WriteLine("Invalid input. Use values in the range 0 to 255.");
                    Console.WriteLine("You can also use hex values with 0x12 or $12.");
                    Console.WriteLine();
                    --i;
                }
                else
                {
                    newValues.Add((byte)value.Value);

                    if (i == length - 1)
                    {
                        CommitValues(offset.Value, length.Value, newValues,
                        andIndices, orIndices, xorIndices, negIndices);
                    }
                }
            }

            Console.WriteLine();

            if (save)
            {
                foreach (var file in fileData)
                {
                    File.WriteAllBytes(file.Key, file.Value);
                }
            }

            if (save || quit)
            {
                Environment.Exit(0);
                return;
            }
        }

        void CommitValues(int offset, int length, List<byte> newValues, HashSet<int> andIndices,
            HashSet<int> orIndices, HashSet<int> xorIndices, HashSet<int> negIndices)
        {
            length = Math.Min(length, newValues.Count);

            foreach (var file in fileData)
            {
                for (int i = 0; i < length; ++i)
                {
                    if (andIndices.Contains(i))
                        file.Value[offset + i] &= newValues[i];
                    else if (orIndices.Contains(i))
                        file.Value[offset + i] |= newValues[i];
                    else if (xorIndices.Contains(i))
                        file.Value[offset + i] ^= newValues[i];
                    else if (andIndices.Contains(i))
                        file.Value[offset + i] ^= 0xff;
                    else
                        file.Value[offset + i] = newValues[i];
                }
            }
        }
    }

    static void Usage()
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
}
