//! AmbermoonIntroPatcher: writes the texts of a translation and its fonts into the intro (a port of
//! AmbermoonTools/AmbermoonIntroPatcher).
//!
//!   AmbermoonIntroPatcher <intro_path> <text_path> <output_path> <font_file> [codepage]
//!
//! intro_path: the intro to patch (its last data hunk a placeholder for the fonts), text_path: the folder with the 15
//! texts 000.txt to 014.txt, font_file: the fonts (small and large), codepage: a code page or the name of an encoding
//! (default: the encoding of the game).
namespace AmbermoonIntroPatcher;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Text.Patching;

const ReadOnlySlice<uint8> MenuEntryYPositions = [0x46, 0x64, 0x82, 0xa0];

int Fail(string message)
{
    Console.WriteErrorLine(message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length < 4 || args.Length > 5)
        return Fail("Usage: AmbermoonIntroPatcher <intro_path> <text_path> <output_path> <font_file> [codepage]");

    var introPath = args[0];
    if (!IsFile(introPath))
        return Fail($"Intro file '{introPath}' does not exist.");

    var textPath = args[1];
    if (!Directory.Exists(textPath))
        return Fail($"Text directory '{textPath}' does not exist.");

    var outputPath = args[2];
    // (the original fails for an output file without a folder)
    var outputDirectory = Path.GetDirectory(outputPath);
    Directory.Create(outputDirectory.Length == 0 ? "." : outputDirectory);

    if (IsFile(outputPath))
    {
        Console.WriteErrorLine($"Output file '{outputPath}' already exists. Do you want to override it? (y/N)");

        string answer = Console.ReadLine() is string line ? line : "";
        if (ToLowerNet(answer) != "y")
        {
            Console.WriteLine("Operation cancelled.");
            return 0;
        }
    }

    var fontFile = args[3];
    if (!IsFile(fontFile))
        return Fail($"Font file '{fontFile}' does not exist.");

    if (File.ReadAllBytes(introPath) is not uint8[] introData)
        return Fail($"Intro file '{introPath}' does not exist.");
    var introContainer = FileReader.ReadFile("Ambermoon_intro", DataReader.FromData(introData));
    if (introContainer is error introError)
        return Fail(introError.Message);
    if (introContainer is not FileContainer intro)
        return 1;
    var hunksRead = AmigaExecutable.Read(intro.Files[1]);
    if (hunksRead is error hunksError)
        return Fail(hunksError.Message);
    if (hunksRead is not List<Hunk> introHunks)
        return 1;

    // the second last data hunk has the texts
    var dataHunkIndices = List<int>.Create();
    for (var i = 0; i < introHunks.Count(); i += 1)
    {
        if (introHunks[i].Type == HunkType.Data)
            dataHunkIndices.Add(i);
    }
    if (dataHunkIndices.Count() < 2)
        return Fail("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
    int textDataHunkIndex = dataHunkIndices[dataHunkIndices.Count() - 2];

    // The text hunk contains all the texts in a sequence. Each text starts with a byte indicating the length of the
    // text, including the terminating null. All texts are null-terminated. The 4 menu entry texts are encoded together
    // with a single length byte but each text has a null-terminator. At the end there must be a $ff byte and the hunk
    // should be aligned to a long boundary.

    // (in the order of their names; the original takes the order of the file system, which is that order on Windows)
    var texts = List<string>.Create();
    foreach (var file in FindFiles(textPath, "*.txt", false))
    {
        if (IsTextFileName(Path.GetFileName(file)))
            texts.Add(TrimEndNet(ReadAllTextNet(file) is string text ? text : "").ToString());
    }

    if (texts.Count() != 15)
        return Fail($"Expected 15 text files of format 000.txt etc in '{textPath}', but found {texts.Count()}.");

    if (File.ReadAllBytes(fontFile) is not uint8[] fontData)
        return Fail($"Font file '{fontFile}' does not exist.");
    var fontReader = DataReader.FromData(fontData);
    var fontsRead = Fonts.Read(ref fontReader);
    if (fontsRead is error fontError)
        return Fail($"Failed to read font file '{fontFile}': {fontError.Message}");
    if (fontsRead is not Fonts fonts)
        return 1;

    var encoding = TextPatchEncoding.Game();

    if (args.Length > 4)
    {
        var encodingName = args[4];
        if (ParseInt(encodingName) is int codePage)
        {
            // (the original also knows the other code pages of .NET)
            if (TextPatchEncoding.FromCodePage(codePage) is not TextPatchEncoding byCodePage)
                return Fail($"Invalid codepage '{codePage}' specified. Please use a valid codepage number.");
            encoding = byCodePage;
            Console.WriteLine($"Using encoding: {encoding.WebName} ({encoding.EncodingName}) with codepage {codePage}.");
        }
        else
        {
            if (TextPatchEncoding.FromName(encodingName) is not TextPatchEncoding byName)
                return Fail($"Invalid encoding '{encodingName}' specified. Please use a valid encoding name.");
            encoding = byName;
            Console.WriteLine($"Using encoding: {encoding.WebName} ({encoding.EncodingName})");
        }
    }

    var data = new DataWriter();

    for (var i = 0; i < 15; i += 1)
    {
        int length = LengthNet(texts[i]);
        if (length > 254)
            return Fail($"Text {i.ToString().PadLeft(3, '0')} exceeds maximum length of 254 characters. Has {length} characters.");

        if (i == 3) // menu entries
        {
            int totalLength = 8; // 8 position bytes, 4 entries (x, y)

            for (var m = 0; m < 4; m += 1)
                totalLength += LengthNet(texts[i + m]) + 1; // +1 for null-terminator

            if (totalLength > 255)
                return Fail($"Menu entry texts must not exceed 243 characters in total, but got {totalLength} characters.");

            data.WriteByte((uint8)totalLength); // write length of all 4 texts

            for (var m = 0; m < 4; m += 1)
            {
                var text = texts[i + m];
                var width = try_or_fail(MeasureLargeTextWidth(text, fonts, encoding));
                data.WriteByte((uint8)(((320 - width) / 2) & 0xff)); // center text horizontally
                data.WriteByte(MenuEntryYPositions[m]);
                data.WriteBytes(encoding.GetBytes(text));
                data.WriteByte(0); // null-terminator
            }

            i += 3; // adjust to fix outer loop
        }
        else
        {
            var text = texts[i];

            if (i < 3)
            {
                var width = try_or_fail(MeasureLargeTextWidth(text, fonts, encoding));
                int x = ((320 - width) / 2) & 0xff; // center text horizontally

                if (i == 2)
                    x = (x + 4) & 0xff; // small offset here

                data.WriteByte((uint8)((length + 2) & 0xff)); // write length of text plus X value
                data.WriteByte((uint8)x);
            }
            else
            {
                data.WriteByte((uint8)((length + 1) & 0xff)); // write length of text
            }

            data.WriteBytes(encoding.GetBytes(text));
            data.WriteByte(0); // null-terminator
        }
    }

    data.WriteByte(0xff); // end of text marker

    while (data.Position() % 4 != 0)
        data.WriteByte(0xff); // align to long boundary

    var textDataHunk = introHunks[textDataHunkIndex];
    var newTextHunk = Hunk.Create(HunkType.Data, textDataHunk.MemoryFlags, data.ToArray());
    if (newTextHunk is not Hunk newHunk)
        return 1;
    introHunks[textDataHunkIndex] = newHunk;

    if (Patch.Fonts(introHunks, fonts) is error patchError)
        return Fail(patchError.Message);

    var writer = new DataWriter();
    if (AmigaExecutable.Write(ref writer, introHunks) is error writeError)
        return Fail(writeError.Message);
    if (File.WriteAllBytes(outputPath, writer.AsSlice()) is error)
        return Fail($"Could not write file '{outputPath}'.");

    return 0;
}

// the value of a result; ends the program with its message if it is an error (the original ends with an exception)
int try_or_fail(Error<int> result)
{
    if (result is error e)
    {
        Console.WriteErrorLine(e.Message);
        Environment.Exit(1);
    }
    return result is int value ? value : 0;
}

// the name of a text file: 3 digits and ".txt" (the regular expression ^[0-9]{3}[.]txt$ of the original)
bool IsTextFileName(StringSlice name)
{
    var n = name.Length == 8 && name[7] == '\n' ? name[0..7] : name;
    if (n.Length != 7 || n[3] != '.' || n[4] != 't' || n[5] != 'x' || n[6] != 't')
        return false;
    for (var i = 0; i < 3; i += 1)
    {
        if (n[i] < '0' || n[i] > '9')
            return false;
    }
    return true;
}

// the width of a text in the large font
Error<int> MeasureLargeTextWidth(string text, Fonts fonts, TextPatchEncoding encoding)
{
    int width = 0;

    foreach (var ch in encoding.GetBytes(text))
    {
        if (ch == ' ')
            width += fonts.LargeSpaceAdvance;
        else if (ch > 32)
        {
            if (ch - 32 >= fonts.GlyphMapping.Length)
                return error("Index was outside the bounds of the array.");
            int glyphIndex = fonts.GlyphMapping[ch - 32];

            if (glyphIndex != 255)
            {
                if (glyphIndex >= fonts.LargeAdvanceValues.Length)
                    return error("Index was outside the bounds of the array.");
                width += fonts.LargeAdvanceValues[glyphIndex];
            }
        }
    }

    return width;
}
