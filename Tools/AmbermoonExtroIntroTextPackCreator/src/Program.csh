//! AmbermoonExtroIntroTextPackCreator: makes Intro_texts.amb and Extro_texts.amb of a language from the texts in the
//! Ambermoon repository (a port of AmbermoonTools/AmbermoonExtroIntroTextPackCreator).
//!
//! The original copies the texts into a temporary folder in the layout of the packers, builds the two packers with
//! `dotnet publish` and runs them. This port reads the texts and packs them directly (AmbermoonTextPacks), with the
//! same result.
namespace AmbermoonExtroIntroTextPackCreator;

using System;
using Ambermoon;
using AmbermoonTextPacks;

void Usage()
{
    Console.WriteLine("AmbermoonExtroIntroTextPackCreator <language_name> <version> <outdir>");
}

// "X.XX" with X a digit, the first not 0 (the regex "^([1-9])[.]([0-9]{2})$" of the original; '$' also matches
// before a line break at the end)
bool IsVersion(StringSlice version)
{
    if (version.Length == 5 && version[4] == '\n')
        version = version[0..4];
    return version.Length == 4 && version[0] >= '1' && version[0] <= '9' && version[1] == '.' &&
           Char.IsDigit(version[2]) && Char.IsDigit(version[3]);
}

// the texts that the intro shows on their own, by their index: names of places, or the index of the source text
const ReadOnlySlice<string> StaticTexts = ["GEMSTONE", "ILLIEN", "SNAKESIGN", "", "TWINLAKE", "LYRAMION", "", "", "", "", "", ""];
const ReadOnlySlice<int> SourceIndices = [-1, -1, -1, 0, -1, -1, 1, 2, 3, 4, 5, 6];
// the number of texts of the commands 12 to 20: the source text and names
const ReadOnlySlice<int> GroupTextCounts = [3, 2, 2, 3, 3, 2, 2, 2, 2];
const ReadOnlySlice<string> Names =
[
    "KARSTEN KOEPER",
    "ERIK SIMON",
    "JURIE HORNEMAN",
    "MICHAEL BITTNER",
    "THORSTEN MUTSCHALL",
    "MONIKA KRAWINKEL",
    "HENK NIEBORG",
    "ERIK SIMON",
    "MATTHIAS STEINWACHS",
    "",
    "",
    ""
];

Error<string> ReadSourceText(string introTextPath, int index)
{
    var path = Path.Combine(introTextPath, index.ToString("D3") + ".txt");
    if (ReadAllTextNet(path) is string text)
        return text;
    return error($"Could not find file '{path}'.");
}

// The source texts are made for the intro patcher; the text packer also needs the static texts (names of towns and
// developers) that the patcher no longer uses.
Error<IntroTexts> MakeIntroTexts(string introTextPath)
{
    var texts = IntroTexts.Create();

    for (var i = 0; i < 12; i += 1)
    {
        if (SourceIndices[i] < 0)
            texts.Texts.Add(StaticTexts[i]);
        else
            texts.Texts.Add(try ReadSourceText(introTextPath, SourceIndices[i]));
    }

    int nameIndex = 0;
    int sourceIndex = 7;
    bool hold = true; // source index 10 is used twice

    for (var i = 12; i <= 20; i += 1)
    {
        var command = List<string>.Create();
        command.Add(try ReadSourceText(introTextPath, sourceIndex));
        sourceIndex += 1;

        if (sourceIndex == 11 && hold) // was 10
        {
            hold = false;
            sourceIndex -= 1;
        }

        for (var t = 1; t < GroupTextCounts[i - 12]; t += 1)
        {
            command.Add(Names[nameIndex]);
            nameIndex += 1;
        }

        texts.CommandTexts.Add(command);
    }

    return texts;
}

int Fail(string message)
{
    Console.WriteErrorLine("Error: " + message);
    return 1;
}

int Main(string[] args)
{
    if (args.Length != 3 || args[0].Length == 0)
    {
        Usage();
        return 1;
    }

    // the language in the form "English", "German", ...
    var language = args[0].ToLower();
    language = language[0..1].ToUpper() + language[1..];

    var version = args[1].ToLower();

    if (!IsVersion(version))
    {
        Console.WriteErrorLine($"Version '{version}' does not match the expected format 'X.XX' (e.g., '1.00').");
        Console.WriteErrorLine("");
        Usage();
        return 1;
    }

    var solutionDirectory = Directory.GetCurrentDirectory();
    var languageSourcePath = Path.Combine(Path.Combine(Path.Combine(solutionDirectory, "Disks"), "Bugfixing"), language);
    var languageTranslationSourcePath = Path.Combine(Path.Combine(solutionDirectory, "Translations"), language);

    var clickTextFile = Path.Combine(languageTranslationSourcePath, "click-text.txt");
    string clickText = "<CLICK>";
    if (IsFile(clickTextFile))
    {
        if (ReadAllTextNet(clickTextFile) is not string text)
            return Fail($"Could not read file '{clickTextFile}'.");
        clickText = TrimNet(text).ToString();
    }

    var translators = List<string>.Create();
    var translatorsFile = Path.Combine(languageTranslationSourcePath, "translators.txt");
    if (IsFile(translatorsFile))
    {
        if (ReadAllTextNet(translatorsFile) is not string text)
            return Fail($"Could not read file '{translatorsFile}'.");
        foreach (var line in SplitLinesNet(text))
        {
            var name = TrimNet(line);
            if (!name.StartsWith("#") && !IsWhiteSpaceOnlyNet(name))
                translators.Add(name.ToString());
        }
    }

    var introTextPath = Path.Combine(languageSourcePath, "IntroTexts");
    var extroTextPath = Path.Combine(languageSourcePath, "ExtroTexts");

    foreach (var path in [introTextPath, extroTextPath])
    {
        if (!Directory.Exists(path))
            return Fail($"Source directory '{path}' does not exist.");
    }

    Console.WriteLine($"Reading the intro texts from '{introTextPath}'");
    var introTexts = MakeIntroTexts(introTextPath);
    if (introTexts is error introError)
        return Fail(introError.Message);
    if (introTexts is not IntroTexts intro)
        return 1;

    Console.WriteLine($"Reading the extro texts from '{extroTextPath}'");
    var extroTexts = ReadExtroTexts(extroTextPath);
    if (extroTexts is error extroError)
        return Fail(extroError.Message);
    if (extroTexts is not ExtroTexts extro)
        return 1;

    var outputDirectory = args[2];

    if (!Directory.Create(outputDirectory))
        return Fail($"Could not create the directory '{outputDirectory}'.");

    var introFile = Path.Combine(outputDirectory, "Intro_texts.amb");
    if (File.WriteAllBytes(introFile, PackIntroTexts(intro)) is error e1)
        return Fail(e1.Message);
    Console.WriteLine($"Intro texts packed successfully into '{introFile}'.");

    var extroFile = Path.Combine(outputDirectory, "Extro_texts.amb");
    if (File.WriteAllBytes(extroFile, PackExtroTexts(extro, translators.ToArray(), clickText)) is error e2)
        return Fail(e2.Message);
    Console.WriteLine($"Extro texts packed successfully into '{extroFile}'.");

    return 0;
}
