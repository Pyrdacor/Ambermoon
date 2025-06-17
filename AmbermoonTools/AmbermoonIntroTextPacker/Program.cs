using System.Text;
using Ambermoon.Data.Legacy.Serialization;

namespace AmbermoonIntroTextPacker;

internal class Program
{
    static void Usage()
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

    static int Main(string[] args)
    {
        if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h" || args[0] == "/?"))
        {
            Usage();
            return 0;
        }

        var nonCommandTexts = new List<string>();
        var commandTexts = new List<string[]>();
        var currentCommandTexts = new List<string>();
        string workingDirectory = args.Length == 0 ? Environment.CurrentDirectory : args[0];

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

        foreach (var file in Directory.GetFiles(path).OrderBy(f => int.Parse(Path.GetFileName(f)[0..3])).ThenBy(f =>
        {
            var fname = Path.GetFileNameWithoutExtension(f);
            if (fname.Contains('.'))
                return int.Parse(fname[4..7]);
            return 0;
        }))
        {
            var fname = Path.GetFileNameWithoutExtension(file);
            string text = File.ReadAllText(file, Encoding.UTF8);

            if (fname.Contains('.'))
            {
                if (int.Parse(fname[4..7]) == 0) // New command
                {
                    if (currentCommandTexts.Count != 0)
                    {
                        commandTexts.Add(currentCommandTexts.ToArray());
                        currentCommandTexts.Clear();
                    }
                }

                currentCommandTexts.Add(text);
            }
            else
            {
                nonCommandTexts.Add(text);
            }
        }

        if (currentCommandTexts.Count != 0)
        {
            commandTexts.Add(currentCommandTexts.ToArray());
            currentCommandTexts.Clear();
        }

        var dataWriter = new DataWriter();

        dataWriter.Write((byte)nonCommandTexts.Count);
        foreach (var nonCommandText in nonCommandTexts)
            dataWriter.WriteNullTerminated(nonCommandText, Encoding.UTF8);

        dataWriter.Write((byte)commandTexts.Count);
        foreach (var commandText in commandTexts)
        {
            dataWriter.Write((byte)commandText.Length);
            foreach (var commandTextEntry in commandText)
                dataWriter.WriteNullTerminated(commandTextEntry, Encoding.UTF8);
        }

        try
        {
            File.WriteAllBytes(Path.Combine(workingDirectory, "Intro_texts.amb"), dataWriter.ToArray());
            Console.WriteLine("Intro texts packed successfully into 'Intro_texts.amb'.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error writing output file: " + ex.Message);
            return -1;

        }
    }
}