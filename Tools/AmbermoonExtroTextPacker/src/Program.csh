//! AmbermoonExtroTextPacker: packs the extro texts of a translation into Extro_texts.amb (a port of
//! AmbermoonTools/AmbermoonExtroTextPacker).
namespace AmbermoonExtroTextPacker;

using System;
using Ambermoon;
using AmbermoonTextPacks;

void Usage()
{
    Console.WriteLine("Usage: AmbermoonExtroTextPacker.exe [working_dir] [click_text] [translator1_name] [...]");
    Console.WriteLine("       AmbermoonExtroTextPacker.exe --help");
    Console.WriteLine();
    Console.WriteLine("working_dir:      Directory to search for the ExtroTextGroups folder and output directory");
    Console.WriteLine("click_text:       Text to be used for the click text (default: <CLICK>)");
    Console.WriteLine("translator1_name: Name of the first translator (default: keep original)");
    Console.WriteLine("                  You can specify more translators if needed.");
    Console.WriteLine("Ensure quotes around click text and translator names if they contain spaces!");
    Console.WriteLine();
    Console.WriteLine("Example: AmbermoonExtroTextPacker.exe C:\\CzechTranslation \"<CLICK>\" \"DANIEL ZIMA\"");
    Console.WriteLine();
    Console.WriteLine("This tool packs the extro texts for Ambermoon into a single file.");
    Console.WriteLine("It expects the extro text groups to be organized in directories under a specified path.");
    Console.WriteLine("The directory structure should be as follows:");
    Console.WriteLine("[working_dir]\\ExtroTextGroups\\");
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
    Console.WriteLine("The output file will be written to 'Extro_texts.amb' in the [working_dir].");
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
    string clickText = args.Length < 2 ? "<CLICK>" : args[1];
    ReadOnlySlice<string> translatorNames = args.Length < 3 ? new string[0] : args[2..];

    var path = Path.Combine(workingDirectory, "ExtroTextGroups");

    if (!Directory.Exists(path))
    {
        Console.WriteLine("Error: The specified working directory does not contain the ExtroTextGroups folder.");

        if (args.Length == 0)
        {
            Console.WriteLine();
            Usage();
        }

        return 1;
    }

    var read = ReadExtroTexts(path);
    if (read is error readError)
    {
        Console.WriteLine("Error: " + readError.Message);
        return 1;
    }
    if (read is not ExtroTexts texts)
        return 1;

    var output = Path.Combine(workingDirectory, "Extro_texts.amb");
    if (File.WriteAllBytes(output, PackExtroTexts(texts, translatorNames, clickText)) is error e)
    {
        Console.WriteLine("Error writing output file: " + e.Message);
        return -1;
    }
    Console.WriteLine("Extro texts packed successfully into 'Extro_texts.amb'.");
    return 0;
}
