using System.Text;
using Ambermoon.Data.Legacy.Serialization;

namespace AmbermoonExtroTextPacker;

internal class Program
{
    static void Usage()
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

    static int Main(string[] args)
    {
        if (args.Length == 1 && (args[0] == "--help" || args[0] == "-h" || args[0] == "/?"))
        {
            Usage();
            return 0;
        }

        string workingDirectory = args.Length == 0 ? Environment.CurrentDirectory : args[0];
        string clickText = args.Length < 2 ? "<CLICK>" : args[1];
        string[] translatorNames = args.Length < 3 ? [] : args.Skip(2).ToArray();

        var outroTexts = new List<List<string>>[6] { [], [], [], [], [], [] };
        int clickGroupIndex = 0;

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

        foreach (var clickGroup in Directory.GetDirectories(path).Where(d => int.TryParse(Path.GetFileName(d)[0..3], out _)).OrderBy(d => int.Parse(Path.GetFileName(d)[0..3])))
        {
            var clickGroupTexts = outroTexts[clickGroupIndex++];

            foreach (var group in Directory.GetDirectories(clickGroup).OrderBy(d => int.Parse(Path.GetFileName(d)[0..3])))
            {
                var groupTexts = new List<string>();

                foreach (var file in Directory.GetFiles(group).OrderBy(f => int.Parse(Path.GetFileName(f)[0..3])))
                {
                    string text = File.ReadAllText(file, Encoding.UTF8);
                    groupTexts.Add(text);
                }

                clickGroupTexts.Add(groupTexts);
            }
        }

        var dataWriter = new DataWriter();

        dataWriter.Write((ushort)6);

        for (int i = 0; i < 6; ++i)
            dataWriter.Write((ushort)outroTexts[i].Count);

        foreach (var clickGroup in outroTexts)
        {
            for (int i = 0; i < clickGroup.Count; ++i)
                dataWriter.Write((ushort)clickGroup[i].Count);

            foreach (var group in clickGroup)
            {
                foreach (var text in group)
                {
                    dataWriter.WriteNullTerminated(text, Encoding.UTF8);
                }
            }

            if (dataWriter.Size % 2 == 1)
                dataWriter.Write((byte)0);
        }

        dataWriter.Write((ushort)translatorNames.Length); // Number of translators

        foreach (var translatorName in translatorNames)
            dataWriter.WriteNullTerminated(translatorName, Encoding.UTF8);

        dataWriter.WriteNullTerminated(clickText, Encoding.UTF8);

        if (dataWriter.Size % 2 == 1)
            dataWriter.Write((byte)0);

        try
        {
            File.WriteAllBytes(Path.Combine(workingDirectory, "Extro_texts.amb"), dataWriter.ToArray());
            Console.WriteLine("Extro texts packed successfully into 'Extro_texts.amb'.");
            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error writing output file: " + ex.Message);
            return -1;
        }
    }
}