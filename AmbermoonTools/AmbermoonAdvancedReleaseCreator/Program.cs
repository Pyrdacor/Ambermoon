using System.Text.RegularExpressions;
using AmbermoonAdvancedReleaseCreator;

static void Usage()
{
    Console.WriteLine("Usage AmbermoonAdvancedReleaseCreator <folder> [version]");
    Console.WriteLine();
    Console.WriteLine("<folder>: Folder path of form MyPath\\<lang>\\ambermoon_advanced_<lang>_<version>_extracted");
    Console.WriteLine("<folder>: Folder path of form MyPath but then it must contain the above and version arg is needed");
    Console.WriteLine();
    Console.WriteLine("Prepare a folder with the data in it and name it like mentioned.");
    Console.WriteLine();
    Console.WriteLine("<lang> should be german or english");
    Console.WriteLine("<version> should have the form X.XX");
    Console.WriteLine();
}

if (args.Length < 1 && args.Length > 2)
{
    Console.WriteLine("Invalid number of arguments.");
    Console.WriteLine();
    Usage();
    Environment.Exit(1);
    return;
}

var regex = new Regex(@"^.*[/\\]([a-z]+)[/\\]ambermoon_advanced_([a-z]+)_([1-9][.][0-9][0-9])_extracted$", RegexOptions.Compiled | RegexOptions.IgnoreCase);
var folder = args[0];
bool hasVersion = args.Length == 2;

var match = regex.Match(folder);

if (!hasVersion && !match.Success)
{
    Console.WriteLine("Invalid folder path format. Did you forget to specify a version?");
    Console.WriteLine();
    Usage();
    Environment.Exit(1);
    return;
}
else if (hasVersion && match.Success)
{
    Console.WriteLine("Invalid folder path format if a version is given. Just pass the base path.");
    Console.WriteLine();
    Usage();
    Environment.Exit(1);
    return;
}

string version;
List<string> sourcePaths = [];

if (hasVersion)
{
    version = args[1];

    if (!Regex.IsMatch(version, @"^[1-9][.][0-9][0-9]$"))
    {
        Console.WriteLine("Version must have the form X.XX");
        Console.WriteLine();
        Usage();
        Environment.Exit(1);
        return;
    }

    sourcePaths.Add(Path.Combine(folder, $@"german\ambermoon_advanced_german_{version}_extracted"));
    sourcePaths.Add(Path.Combine(folder, $@"english\ambermoon_advanced_english_{version}_extracted"));

    sourcePaths = sourcePaths.Where(p => Directory.Exists(p)).ToList();

    if (sourcePaths.Count == 0)
    {
        Console.WriteLine("No valid source paths found for the specified version.");
        Console.WriteLine();
        Usage();
        Environment.Exit(1);
        return;
    }
}
else
{
    var language1 = match.Groups[1].Value.ToLowerInvariant().ToLower();
    var language2 = match.Groups[2].Value.ToLowerInvariant().ToLower();

    if (language1 != language2)
    {
        Console.WriteLine("Languages differ in path.");
        Console.WriteLine();
        Usage();
        Environment.Exit(1);
        return;
    }

    if (language1 != "german" && language1 != "english")
    {
        Console.WriteLine("Language must be either german or english.");
        Console.WriteLine();
        Usage();
        Environment.Exit(1);
        return;
    }

    version = match.Groups[3].Value;

    sourcePaths.Add(folder);
}

sourcePaths.ForEach(sourcePath =>
{
    Package.CreateZip(sourcePath, sourcePath + ".zip");
    Package.CreateTarball(sourcePath, sourcePath + ".tar.gz");
    Package.CreateLha(sourcePath, sourcePath + ".lha");
});