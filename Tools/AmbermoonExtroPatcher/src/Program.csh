//! AmbermoonExtroPatcher: writes the texts of a translation, its translators and its fonts into the extro (a port of
//! AmbermoonTools/AmbermoonExtroPatcher).
//!
//!   AmbermoonExtroPatcher <extro_path> <text_path> <output_path> <font_file> [enc] [click_text] [tr1_name] [...]
//!   AmbermoonExtroPatcher <config_file>
//!
//! The extro texts are grouped by sections which are divided by clicks:
//!
//! 1. Destruction of the temple of brotherhood
//! 2. End of brotherhood Tarbos and peace with Moranians
//! 3. Travel to Kire's moon and rescue of the dwarves
//! 4. Valdyn leaves (no yellow teleporter stone)
//! 5. Valdyn leaves (with yellow teleporter stone)
//! 6. End texts and credits
//!
//! There are 3 sequences: 1 2 3 4 6, 1 2 3 5 6 and 1 2 3 6.
namespace AmbermoonExtroPatcher;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Text.Patching;

/// The configuration (the config file or the arguments).
struct Config
{
    Optional<string> ExtroPath;
    Optional<string> TextPath;
    Optional<string> OutputPath;
    Optional<string> FontFile;
    Optional<int> CodePage;
    Optional<string> Encoding;
    Optional<string> ClickText;
    List<string> Translators;

    /// The configuration of a JSON file (the properties as System.Text.Json reads them: by their exact names, others
    /// are ignored).
    /// @error the file is no valid JSON or a property has the wrong type (the original ends with an exception).
    static Error<Config> Load(string filePath)
    {
        var config = Config { Translators = List<string>.Create() };
        if (ReadAllTextNet(filePath) is not string json)
            return error($"Could not find file '{Path.GetFullPath(filePath)}'.");
        var parsed = Json.Parse(json);
        if (parsed is error parseError)
            return error(parseError.Message);
        if (parsed is not JsonValue root)
            return config;
        if (root.IsNull())
            return config;
        if (!root.IsObject())
            return error("The JSON value could not be converted to AmbermoonExtroPatcher.Config.");

        foreach (var key in root.Keys())
        {
            var value = root.Get(key);
            switch (key)
            {
                case "extro_path": config.ExtroPath = try _String(value, key); break;
                case "text_path": config.TextPath = try _String(value, key); break;
                case "output_path": config.OutputPath = try _String(value, key); break;
                case "font_file": config.FontFile = try _String(value, key); break;
                case "encoding": config.Encoding = try _String(value, key); break;
                case "click_text": config.ClickText = try _String(value, key); break;
                case "codepage":
                    if (value.IsNull())
                        config.CodePage = null;
                    else if (value.IsNumber() && value.AsNumber() == Math.Floor(value.AsNumber()) &&
                             value.AsNumber() >= -2147483648.0 && value.AsNumber() <= 2147483647.0)
                        config.CodePage = value.AsInt();
                    else
                        return error($"The JSON value could not be converted to System.Nullable`1[System.Int32]. Path: $.{key}");
                    break;
                case "translators":
                    if (!value.IsArray())
                        return error($"The JSON value could not be converted to System.Collections.Generic.List`1[System.String]. Path: $.{key}");
                    config.Translators = List<string>.Create();
                    foreach (var item in value.Items())
                    {
                        if (!item.IsString())
                            return error($"The JSON value could not be converted to System.String. Path: $.{key}");
                        config.Translators.Add(item.AsString());
                    }
                    break;
                default:
                    break;
            }
        }

        return config;
    }

    static Error<Optional<string>> _String(JsonValue value, string key)
    {
        if (value.IsNull())
            return (Optional<string>)null;
        if (!value.IsString())
            return error($"The JSON value could not be converted to System.String. Path: $.{key}");
        return (Optional<string>)value.AsString();
    }
}

void Usage()
{
    Console.WriteLine("Usage: AmbermoonExtroPatcher.exe <extro_path> <text_path> <output_path> <font_file> [enc] [click_text] [tr1_name] [...]");
    Console.WriteLine("       AmbermoonExtroPatcher.exe <config_file>");
    Console.WriteLine("       AmbermoonExtroPatcher.exe --help");
    Console.WriteLine();
    Console.WriteLine("config_file:      Configuration file (see 'example-config.json')");
    Console.WriteLine("extro_path:       Path to the extro template which should be patched");
    Console.WriteLine("text_path:        Directory which contains the text directories and files");
    Console.WriteLine("output_path:      Path where the patched extro will be stored");
    Console.WriteLine("font_file:        Path to the font file");
    Console.WriteLine("enc:              Encoding name or codepage number");
    Console.WriteLine("click_text:       Text to be used for the click text (default: <CLICK>)");
    Console.WriteLine("tr1_name:         Name of the first translator (default: keep original)");
    Console.WriteLine("                  You can specify more translators if needed.");
    Console.WriteLine("Ensure quotes around click text and translator names if they contain spaces!");
    Console.WriteLine();
    Console.WriteLine("Example: AmbermoonExtroPatcher.exe C:\\CzechTranslation\\Ambermoon_extro_translation_base C:\\CzechTranslation\\texts");
    Console.WriteLine("                                   C:\\CzechTranslation\\Ambermoon_extro C:\\CzechTranslation\\CzechFont 852");
    Console.WriteLine("                                   <CLICK> \"DANIEL ZIMA\"");
    Console.WriteLine();
    Console.WriteLine("This tool patches the fonts and texts into the extro template and creates a working Ambermoon extro.");
    Console.WriteLine();
    Console.WriteLine("It expects the extro text groups to be organized in directories under a specified path.");
    Console.WriteLine("The directory structure should be as follows:");
    Console.WriteLine("<text_path>\\");
    Console.WriteLine("  000\\");
    Console.WriteLine("    000\\");
    Console.WriteLine("      000.txt");
    Console.WriteLine("      ...");
    Console.WriteLine("    ...");
    Console.WriteLine("  001\\");
    Console.WriteLine("    ...");
    Console.WriteLine("  002\\");
    Console.WriteLine("    ...");
    Console.WriteLine("  003\\");
    Console.WriteLine("    ...");
    Console.WriteLine("  004\\");
    Console.WriteLine("    ...");
    Console.WriteLine("  005\\");
    Console.WriteLine("    ...");
    Console.WriteLine();
}

int ErrorWithUsage(string message)
{
    Console.WriteErrorLine(message);
    Console.WriteErrorLine("");
    Usage();
    return 1;
}

// an error where the original ends with an exception
int Failure(string message)
{
    Console.WriteErrorLine(message);
    return 1;
}

int CheckPathNullOrNonExistent(string name, Optional<string> path, bool directory)
{
    if (path is not string value)
        return ErrorWithUsage($"{name} was not given.");
    if (IsWhiteSpaceOnlyNet(value))
        return ErrorWithUsage($"{name} was not given.");

    if (!directory && !IsFile(value))
        return ErrorWithUsage($"{name} '{value}' does not exist.");

    if (directory && !Directory.Exists(value))
        return ErrorWithUsage($"{name} '{value}' does not exist.");

    return 0;
}

int Main(string[] args)
{
    if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h" || args[0] == "/?"))
    {
        Usage();
        return 0;
    }

    if (args.Length != 1 && args.Length < 4)
    {
        Usage();
        return 1;
    }

    var config = Config { Translators = List<string>.Create() };

    if (args.Length == 1)
    {
        if (!IsFile(args[0]))
            return ErrorWithUsage($"Config file '{args[0]}' does not exist.");

        var loaded = Config.Load(args[0]);
        if (loaded is error loadError)
            return Failure(loadError.Message);
        if (loaded is Config loadedConfig)
            config = loadedConfig;
    }
    else
    {
        config.ExtroPath = args[0];
        config.TextPath = args[1];
        config.OutputPath = args[2];
        config.FontFile = args[3];
        config.ClickText = args.Length >= 6 ? args[5] : "<CLICK>";
        for (var i = 6; i < args.Length; i += 1)
            config.Translators.Add(args[i]);

        if (args.Length >= 5)
        {
            if (ParseInt(args[4]) is int codePage)
                config.CodePage = codePage;
            else if (args[4].Length != 0)
                config.Encoding = args[4];
        }
    }

    int result = CheckPathNullOrNonExistent("Extro path", config.ExtroPath, false);
    if (result != 0)
        return result;

    result = CheckPathNullOrNonExistent("Font file", config.FontFile, false);
    if (result != 0)
        return result;

    result = CheckPathNullOrNonExistent("Text path", config.TextPath, true);
    if (result != 0)
        return result;

    string outputPath = config.OutputPath is string output ? output : "";
    if (IsWhiteSpaceOnlyNet(outputPath))
        return ErrorWithUsage("Output path was not given.");

    if (Directory.Exists(outputPath))
        outputPath = Path.Combine(outputPath, "Ambermoon_extro");

    if (IsFile(outputPath))
    {
        Console.WriteErrorLine($"Output file '{outputPath}' already exists. Do you want to override it? (y/N)");
        string input = Console.ReadLine() is string line ? line : "";

        if (ToLowerNet(input) != "y")
        {
            Console.WriteErrorLine("Aborting.");
            return 0;
        }
    }
    else
    {
        // (the original fails for an output file without a folder)
        var outputDirectory = Path.GetDirectory(outputPath);
        Directory.Create(outputDirectory.Length == 0 ? "." : outputDirectory);
    }

    string clickText = config.ClickText is string click ? click : "<CLICK>";

    var extroPath = config.ExtroPath is string extroFile ? extroFile : "";
    var textPath = config.TextPath is string texts ? texts : "";
    var fontFile = config.FontFile is string fonts ? fonts : "";

    var patched = PatchExtro(extroPath, textPath, outputPath, fontFile, config, clickText);
    if (patched is error e)
        return Failure(e.Message);
    return patched is int code ? code : 1;
}

/// The commands of the actions of the extro.
enum OutroCommand : uint8
{
    PrintTextAndScroll,
    WaitForClick,
    ChangePicture
}

/// An action of the extro: a text (or an empty line) and the scrolling after it, a wait for a click or another picture.
struct OutroAction
{
    OutroCommand Command;
    bool LargeText;
    int ScrollAmount;
    int TextDisplayX;
    Optional<int> TextIndex;
    Optional<uint32> ImageOffset;
}

/// The encoding of the texts of the configuration.
Error<TextPatchEncoding> ConfigEncoding(Config config)
{
    if (config.Encoding is string name && !IsWhiteSpaceOnlyNet(name))
    {
        // (the original also knows the other encodings of .NET)
        if (TextPatchEncoding.FromName(name) is TextPatchEncoding byName)
            return byName;
        return error($"'{name}' is not a supported encoding name.");
    }
    if (config.CodePage is int codePage)
    {
        if (TextPatchEncoding.FromCodePage(codePage) is TextPatchEncoding byCodePage)
            return byCodePage;
        return error($"No data is available for encoding {codePage}.");
    }
    return TextPatchEncoding.Game();
}

// the number of the first 3 characters of a name (`int.Parse(name[0..3])` of the original)
Optional<int> NamePrefixNumber(StringSlice name)
{
    if (name.Length < 3)
        return null;
    return ParseInt(name[0..3]);
}

// the folders or files sorted by the numbers of the first 3 characters of their names (stable: by name for the same
// number)
Error<List<string>> SortByNamePrefix(List<string> paths)
{
    var numbers = List<int>.Create(paths.Count());
    foreach (var path in paths)
    {
        var name = Path.GetFileName(path);
        if (NamePrefixNumber(name) is not int number)
            return error($"The input string '{name}' was not in a correct format.");
        numbers.Add(number);
    }

    var sorted = List<string>.Create(paths.Count());
    var sortedNumbers = List<int>.Create(paths.Count());
    for (var i = 0; i < paths.Count(); i += 1)
    {
        int j = sorted.Count();
        while (j > 0 && sortedNumbers[j - 1] > numbers[i])
            j -= 1;
        sorted.Insert(j, paths[i]);
        sortedNumbers.Insert(j, numbers[i]);
    }
    return sorted;
}

Error<int> PatchExtro(string extroPath, string textPath, string outputPath, string fontFile, Config config, string clickText)
{
    if (File.ReadAllBytes(extroPath) is not uint8[] extroData)
        return error($"Could not find file '{Path.GetFullPath(extroPath)}'.");
    var extro = try FileReader.ReadFile("Ambermoon_extro", DataReader.FromData(extroData));
    var extroHunks = try AmigaExecutable.Read(extro.Files[1]);

    int dataHunkIndex = -1;
    for (var i = 0; i < extroHunks.Count() && dataHunkIndex < 0; i += 1)
    {
        if (extroHunks[i].Type == HunkType.Data)
            dataHunkIndex = i;
    }
    if (dataHunkIndex < 0)
        return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");

    var dataHunk = DataReader.FromData(extroHunks[dataHunkIndex].Data);
    var actionCache = Dictionary<uint32, List<OutroAction>>.Create();
    var texts = List<string>.Create();
    var extroActions = List<List<OutroAction>>.Create(3);

    // Skip initial palette (all zeros)
    dataHunk.Position += 64;

    var clickTextIndices = List<int>.Create();
    int theEndTextIndex = -1;

    // There are actually 3 extro sequence lists dependent on if Valdyn is in the party and if you found the yellow
    // teleporter sphere.
    for (var i = 0; i < 3; i += 1)
    {
        var sequence = List<OutroAction>.Create();

        while (true)
        {
            uint32 actionListOffset = dataHunk.ReadDword();

            if (actionListOffset == 0 || dataHunk.Overrun())
                break;

            uint32 imageDataOffset = dataHunk.ReadDword();

            sequence.Add(OutroAction { Command = OutroCommand.ChangePicture, ImageOffset = imageDataOffset });

            if (actionCache.TryGet(actionListOffset) is List<OutroAction> cachedActions)
            {
                foreach (var action in cachedActions)
                    sequence.Add(action);
                continue;
            }

            int readPosition = dataHunk.Position;
            dataHunk.Position = (int)actionListOffset;
            var actions = List<OutroAction>.Create();

            while (true)
            {
                uint8 scrollAmount = dataHunk.ReadByte();

                if (scrollAmount == 0xff || dataHunk.Overrun())
                {
                    actions.Add(OutroAction { Command = OutroCommand.WaitForClick });
                    break;
                }

                int textDisplayX = dataHunk.ReadByte();
                bool largeText = dataHunk.ReadByte() != 0;
                string text = dataHunk.ReadNullTerminatedString();
                Optional<int> textIndex = null;

                if (text.Length != 0)
                {
                    textIndex = texts.Count();
                    texts.Add(text);
                }

                actions.Add(OutroAction
                {
                    Command = OutroCommand.PrintTextAndScroll,
                    LargeText = largeText,
                    TextIndex = textIndex,
                    ScrollAmount = scrollAmount + 1,
                    TextDisplayX = textDisplayX
                });

                if (largeText && theEndTextIndex == -1 && text == "T H E   E N D")
                    theEndTextIndex = textIndex is int index ? index : -1;
                else if (!largeText && textIndex is int clickIndex && text == "<CLICK>")
                    clickTextIndices.Add(clickIndex);
            }

            if (dataHunk.Overrun())
                return error("[Data] Invalid extro data.");

            foreach (var action in actions)
                sequence.Add(action);
            actionCache[actionListOffset] = actions;
            dataHunk.Position = readPosition;
        }

        extroActions.Add(sequence);
    }

    int afterListPosition = dataHunk.Position;

    // Process texts
    var extroTexts = new List<List<string>>[6];
    for (var i = 0; i < 6; i += 1)
        extroTexts[i] = List<List<string>>.Create();
    int clickGroupIndex = 0;

    var clickGroupDirectories = List<string>.Create();
    foreach (var directory in GetDirectories(textPath))
    {
        if (NamePrefixNumber(Path.GetFileName(directory)) != null)
            clickGroupDirectories.Add(directory);
        // (the original ends with an exception for names shorter than 3 characters)
    }

    foreach (var clickGroup in try SortByNamePrefix(clickGroupDirectories))
    {
        if (clickGroupIndex >= 6)
            return error("Index was outside the bounds of the array.");
        var clickGroupTexts = extroTexts[clickGroupIndex];
        clickGroupIndex += 1;

        foreach (var group in try SortByNamePrefix(GetDirectories(clickGroup)))
        {
            var groupTexts = List<string>.Create();

            foreach (var file in try SortByNamePrefix(GetFiles(group)))
                groupTexts.Add(TrimEndNet(ReadAllTextNet(file) is string text ? text : "").ToString());

            clickGroupTexts.Add(groupTexts);
        }
    }

    if (File.ReadAllBytes(fontFile) is not uint8[] fontData)
        return error($"Could not find file '{Path.GetFullPath(fontFile)}'.");
    var fontReader = DataReader.FromData(fontData);
    var fonts = try Fonts.Read(ref fontReader);

    var encoding = try ConfigEncoding(config);

    var patching = PatchTexts(extroActions, texts, extroTexts, config.Translators, clickText, fonts, encoding,
                              clickTextIndices, theEndTextIndex);
    if (patching is error patchError)
    {
        // (the original shows the exception with its stack trace)
        Console.WriteLine(patchError.Message);
        return 1;
    }

    dataHunk.Position = 0;
    var newDataHunk = try BuildActionHunk(afterListPosition, extroActions, texts, ref dataHunk, encoding);

    var hunk = extroHunks[dataHunkIndex];
    extroHunks[dataHunkIndex] = try Hunk.Create(HunkType.Data, hunk.MemoryFlags, newDataHunk);

    try Patch.Fonts(extroHunks, fonts);

    var writer = new DataWriter();
    try AmigaExecutable.Write(ref writer, extroHunks);
    if (File.WriteAllBytes(outputPath, writer.AsSlice()) is error)
        return error($"Could not write file '{outputPath}'.");

    return 0;
}

// the actions without the pictures, split after each wait for a click
List<List<OutroAction>> ClickGroupsOf(List<OutroAction> actions)
{
    var clickGroups = List<List<OutroAction>>.Create(5);
    var clickGroup = List<OutroAction>.Create();
    clickGroups.Add(clickGroup);

    foreach (var action in actions)
    {
        if (action.Command == OutroCommand.ChangePicture)
            continue;

        clickGroup.Add(action);

        if (action.Command == OutroCommand.WaitForClick)
        {
            clickGroup = List<OutroAction>.Create();
            clickGroups.Add(clickGroup);
        }
    }

    if (clickGroups[clickGroups.Count() - 1].Count() == 0)
        clickGroups.RemoveAt(clickGroups.Count() - 1);

    return clickGroups;
}

// the action groups 1 to 6 of the three sequences (1 2 3 4 6, 1 2 3 5 6, 1 2 3 6)
Error<List<T>> SixGroups<T>(List<T> first, List<T> second)
{
    if (first.Count() < 5 || second.Count() < 4)
        return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
    var groups = List<T>.Create(6);
    groups.Add(first[0]);
    groups.Add(first[1]);
    groups.Add(first[2]);
    groups.Add(first[3]);
    groups.Add(second[3]);
    groups.Add(first[4]);
    return groups;
}

Error<uint8[]> BuildActionHunk(int afterListPosition, List<List<OutroAction>> outroActions, List<string> texts,
                               ref DataReader dataHunk, TextPatchEncoding encoding)
{
    var output = new DataWriter();
    uint32 actionOffset = (uint32)afterListPosition + 9;

    output.WriteBytes(dataHunk.ReadBytes(64));

    var groups = try SixGroups(ClickGroupsOf(outroActions[0]), ClickGroupsOf(outroActions[1]));
    var textGroupData = List<uint8[]>.Create(6);
    var textGroupOffsets = List<uint32>.Create(6);

    for (var i = 0; i < 6; i += 1)
    {
        var writer = new DataWriter();
        textGroupOffsets.Add(actionOffset);

        foreach (var textAction in groups[i])
        {
            if (textAction.Command == OutroCommand.PrintTextAndScroll)
            {
                writer.WriteByte((uint8)((textAction.ScrollAmount - 1) & 0xff));
                writer.WriteByte((uint8)(textAction.TextDisplayX & 0xff));
                writer.WriteByte(textAction.LargeText ? (uint8)1 : 0);
                if (textAction.TextIndex is int textIndex)
                {
                    writer.WriteBytes(encoding.GetBytes(texts[textIndex]));
                    writer.WriteByte(0);
                }
                else
                    writer.WriteByte(0);
            }
            else
            {
                Console.WriteLine();
            }
        }

        writer.WriteByte(0xff); // wait for click

        actionOffset += (uint32)writer.Size();
        textGroupData.Add(writer.ToArray());
    }

    const ReadOnlySlice<int> sequenceLengths = [5, 5, 4];
    const ReadOnlySlice<int> sequenceGroups = [1, 2, 3, 4, 6, 1, 2, 3, 5, 6, 1, 2, 3, 6];
    int sequenceStart = 0;

    for (var i = 0; i < 3; i += 1)
    {
        for (var s = 0; s < sequenceLengths[i]; s += 1)
        {
            int clickGroupIndex = sequenceGroups[sequenceStart + s] - 1;
            output.WriteDword(textGroupOffsets[clickGroupIndex]);
            dataHunk.Position += 4;
            output.WriteDword(dataHunk.ReadDword());
        }
        sequenceStart += sequenceLengths[i];

        uint32 zero = dataHunk.ReadDword(); // Should be zero

        if (zero != 0)
            return error("Expected 0 pointer.");

        output.WriteDword(zero);
    }

    // Now there should be an intermediate section
    const ReadOnlySlice<uint8> expected = [0x80, 0, 0, 0, 0x80, 0, 0, 0, 0xff];

    for (var i = 0; i < expected.Length; i += 1)
    {
        if (dataHunk.ReadByte() != expected[i])
            return error("Wrong intermediate byte.");

        output.WriteByte(expected[i]);
    }

    foreach (var data in textGroupData)
        output.WriteBytes(data);

    output.WriteByte(0); // end marker

    while (output.Size() % 4 != 0) // align to long boundary
        output.WriteByte(0);

    return output.ToArray();
}
