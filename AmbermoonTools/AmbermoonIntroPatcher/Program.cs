using Ambermoon;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Text.Patching;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;

public static partial class Program
{
    static readonly byte[] MenuEntryYPositions = [0x46, 0x64, 0x82, 0xa0];

    // args[0]: Path to Ambermoon intro executable
    // args[1]: Path to intro texts
    // args[2]: Path for Ambermoon_intro to save
    // args[3]: Font file
    // args[4]: Optional code page of the encoding to write
    public static void Main(string[] args)
    {
        /*if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h" || args[0] == "/?"))
        {
            Usage();
            return 0;
        }*/

        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

        if (args.Length < 4 || args.Length > 5)
        {
            Console.Error.WriteLine("Usage: AmbermoonIntroPatcher <intro_path> <text_path> <output_path> <font_file> [codepage]");
            Environment.Exit(1);
            return;
        }

        var introPath = args[0];

        if (!File.Exists(introPath))
        {
            Console.Error.WriteLine($"Intro file '{introPath}' does not exist.");
            Environment.Exit(1);
            return;
        }

        var textPath = args[1];

        if (!Directory.Exists(textPath))
        {
            Console.Error.WriteLine($"Text directory '{textPath}' does not exist.");
            Environment.Exit(1);
            return;
        }

        var outputPath = args[2];

        Directory.CreateDirectory(Path.GetDirectoryName(outputPath) ?? ".");

        if (File.Exists(outputPath))
        {
            Console.Error.WriteLine($"Output file '{outputPath}' already exists. Do you want to override it? (y/N)");

            if (Console.ReadLine()?.ToLower() != "y")
            {
                Console.WriteLine("Operation cancelled.");
                Environment.Exit(0);
                return;
            }
        }

        var fontFile = args[3];

        if (!File.Exists(fontFile))
        {
            Console.Error.WriteLine($"Font file '{fontFile}' does not exist.");
            Environment.Exit(1);
            return;
        }

        var fileReader = new FileReader();

        var intro = fileReader.ReadFile("Ambermoon_intro", new DataReader(File.ReadAllBytes(introPath)));
        var introHunks = AmigaExecutable.Read(intro.Files[1]);
        var dataHunks = introHunks
            .Where(h => h.Type == AmigaExecutable.HunkType.Data)
            .ToList();
        var textDataHunk = dataHunks[^2]; // second last
        int textDataHunkIndex = introHunks.IndexOf(textDataHunk);

        // We can build it directly
        // The text hunk contains all the texts in a sequence.
        // Each text starts with a byte indicating the length of the text, including the terminating null!
        // All texts are null-terminated.
        // The 4 menu entry texts are encoded together with a single length byte but each text has a null-terminator.
        // At the end there must be a $ff byte and the hunk should be aligned to a long boundary.

        var regex = TextFileRegex();
        var texts = Directory.GetFiles(textPath, "*.txt")
            .Where(f => regex.IsMatch(Path.GetFileName(f)))
            .Select(f => File.ReadAllText(f, Encoding.UTF8).TrimEnd())
            .ToList();

        if (texts.Count != 15)
        {
            Console.Error.WriteLine($"Expected 15 text files of format 000.txt etc in '{textPath}', but found {texts.Count}.");
            Environment.Exit(1);
            return;
        }

        Fonts fonts;

        try
        {
            fonts = new Fonts(new DataReader(File.ReadAllBytes(fontFile)));
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"Failed to read font file '{fontFile}': {ex.Message}");
            Environment.Exit(1);
            return;
        }

        string? encodingName = args.Length > 4 ? args[4] : null;
        Encoding encoding = new AmbermoonEncoding();

        if (int.TryParse(encodingName, out int codePage))
        {
            try
            {
                encoding = Encoding.GetEncoding(codePage);
                Console.WriteLine($"Using encoding: {encoding.WebName} ({encoding.EncodingName}) with codepage {codePage}.");
            }
            catch (ArgumentException)
            {
                Console.Error.WriteLine($"Invalid codepage '{codePage}' specified. Please use a valid codepage number.");
                Environment.Exit(1);
            }
        }
        else if (encodingName != null)
        {
            try
            {
                encoding = Encoding.GetEncoding(encodingName);
                Console.WriteLine($"Using encoding: {encoding.WebName} ({encoding.EncodingName})");
            }
            catch (ArgumentException)
            {
                Console.Error.WriteLine($"Invalid encoding '{encodingName}' specified. Please use a valid encoding name.");
                Environment.Exit(1);
            }
        }

        int MeasureLargeTextWith(string text)
        {
            var bytes = encoding.GetBytes(text);
            var advanceValues = fonts.LargeAdvanceValues;
            int width = 0;

            foreach (byte ch in bytes)
            {
                if (ch == ' ')
                {
                    width += fonts.LargeSpaceAdvance;
                }
                else if (ch > 32)
                {
                    var glyphIndex = fonts.GlyphMapping[ch - 32];

                    if (glyphIndex != 255)
                        width += advanceValues[glyphIndex];
                }
            }

            return width;
        }

        var data = new DataWriter();

        for (int i = 0; i < 15; i++)
        {
            if (texts[i].Length > 254)
            {
                Console.Error.WriteLine($"Text {i:000} exceeds maximum length of 254 characters. Has {texts[i].Length} characters.");
                Environment.Exit(1);
                return;
            }

            if (i == 3) // menu entries
            {
                int length = 8; // 8 position bytes, 4 entries (x, y)

                for (int m = 0; m < 4; m++)
                {
                    var text = texts[i + m];
                    length += text.Length + 1; // +1 for null-terminator
                }

                if (length > 255)
                {
                    Console.Error.WriteLine($"Menu entry texts must not exceed 243 characters in total, but got {length} characters.");
                    Environment.Exit(1);
                    return;
                }

                data.Write((byte)length); // write length of all 4 texts

                for (int m = 0; m < 4; m++)
                {
                    var text = texts[i + m];
                    int width = MeasureLargeTextWith(text);
                    byte x = (byte)((320 - width) / 2); // center text horizontally
                    byte y = MenuEntryYPositions[m];
                    data.Write(x);
                    data.Write(y);
                    data.Write(encoding.GetBytes(text));
                    data.Write((byte)0); // null-terminator
                }

                i += 3; // adjust to fix outer loop
            }
            else
            {
                var text = texts[i];

                if (i < 3)
                {
                    int width = MeasureLargeTextWith(text);
                    byte x = (byte)((320 - width) / 2); // center text horizontally

                    if (i == 2)
                        x += 4; // small offset here

                    data.Write((byte)(text.Length + 2)); // write length of text plus X value
                    data.Write(x);
                }
                else
                {
                    data.Write((byte)(text.Length + 1)); // write length of text
                }

                data.Write(encoding.GetBytes(text));
                data.Write((byte)0); // null-terminator
            }
        }

        data.Write((byte)0xff); // end of text marker

        while (data.Position % 4 != 0)
        {
            data.Write((byte)0xff); // align to long boundary
        }

        introHunks[textDataHunkIndex] = new AmigaExecutable.Hunk(AmigaExecutable.HunkType.Data, textDataHunk.MemoryFlags, data.ToArray());

        Patch.Font(introHunks, fonts);

        var writer = new DataWriter();
        AmigaExecutable.Write(writer, introHunks);
        File.WriteAllBytes(outputPath, writer.ToArray());

        Environment.Exit(0);
    }

    [GeneratedRegex("^[0-9]{3}[.]txt$", RegexOptions.Compiled)]
    private static partial Regex TextFileRegex();
}