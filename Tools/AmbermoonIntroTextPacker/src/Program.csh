//! AmbermoonIntroTextPacker: packs the intro texts of a translation into Intro_texts.amb (a port of
//! AmbermoonTools/AmbermoonIntroTextPacker).
namespace AmbermoonIntroTextPacker;

using System;
using Ambermoon;
using AmbermoonTextPacks;

void Usage()
{
    Console.WriteLine("Usage: AmbermoonIntroTextPacker.exe [working_dir]");
    Console.WriteLine("       AmbermoonIntroTextPacker.exe --help");
    Console.WriteLine();
    Console.WriteLine("working_dir:      Directory to search for the IntroTexts folder and output directory");
    Console.WriteLine();
    Console.WriteLine("Example: AmbermoonIntroTextPacker.exe C:\\CzechTranslation");
    Console.WriteLine();
    Console.WriteLine("This tool packs the intro texts for Ambermoon into a single file.");
    Console.WriteLine("It expects the intro texts to be organized in directories under a specified path.");
    Console.WriteLine("The directory structure should be as follows:");
    Console.WriteLine("[working_dir]\\IntroTexts\\");
    Console.WriteLine("  000.txt");
    Console.WriteLine("  001.txt");
    Console.WriteLine("  ...");
    Console.WriteLine("  011.txt");
    Console.WriteLine("  012.000.txt");
    Console.WriteLine("  012.001.txt");
    Console.WriteLine("  012.002.txt");
    Console.WriteLine("  013.000.txt");
    Console.WriteLine("  ...");
    Console.WriteLine("  020.001.txt");
    Console.WriteLine("The output file will be written to 'Intro_texts.amb' in the [working_dir].");
    Console.WriteLine();
}

int Main(string[] args)
{
    if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h" || args[0] == "/?"))
    {
        Usage();
        return 0;
    }

    string workingDirectory = args.Length == 0 ? Directory.GetCurrentDirectory() : args[0];
    var path = Path.Combine(workingDirectory, "IntroTexts");

    if (!Directory.Exists(path))
    {
        Console.WriteLine("Error: The specified working directory does not contain the IntroTexts folder.");

        if (args.Length == 0)
        {
            Console.WriteLine();
            Usage();
        }

        return 1;
    }

    var read = ReadIntroTexts(path);
    if (read is error readError)
    {
        Console.WriteLine("Error: " + readError.Message);
        return 1;
    }
    if (read is not IntroTexts texts)
        return 1;

    var output = Path.Combine(workingDirectory, "Intro_texts.amb");
    if (File.WriteAllBytes(output, PackIntroTexts(texts)) is error e)
    {
        Console.WriteLine("Error writing output file: " + e.Message);
        return -1;
    }
    Console.WriteLine("Intro texts packed successfully into 'Intro_texts.amb'.");
    return 0;
}
