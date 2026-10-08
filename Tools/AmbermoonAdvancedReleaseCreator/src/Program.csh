// AmbermoonAdvancedReleaseCreator <folder> [version]: makes the zip, tar.gz and LHA archives of the prepared folders of
// a release of Ambermoon Advanced (<lang>/ambermoon_advanced_<lang>_<version>_extracted).

using System;
using Ambermoon;
using Ambermoon.Release;

void Usage()
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

int Fail(string message)
{
    Console.WriteLine(message);
    Console.WriteLine();
    Usage();
    return 1;
}

int Main(string[] args)
{
    // (the original checks "args.Length < 1 && args.Length > 2", which is never true: without arguments it ends with
    // an exception, more than two are ignored)
    if (args.Length < 1)
        return Fail("Invalid number of arguments.");

    var regex = Regex.Create("(?i)^.*[/\\\\]([a-z]+)[/\\\\]ambermoon_advanced_([a-z]+)_([1-9][.][0-9][0-9])_extracted$");
    if (regex is not Regex folderRegex)
        return 1;
    string folder = args[0];
    bool hasVersion = args.Length == 2;
    var match = folderRegex.Match(folder);

    if (!hasVersion && match is null)
        return Fail("Invalid folder path format. Did you forget to specify a version?");
    else if (hasVersion && match is not null)
        return Fail("Invalid folder path format if a version is given. Just pass the base path.");

    var sourcePaths = List<string>.Create();
    if (hasVersion)
    {
        string version = args[1];
        if (Regex.Create("^[1-9][.][0-9][0-9]$") is Regex versionRegex && !versionRegex.IsMatch(version))
            return Fail("Version must have the form X.XX");
        foreach (var language in ["german", "english"])
        {
            var path = Path.Combine(Path.Combine(folder, language), "ambermoon_advanced_" + language + "_" + version + "_extracted");
            if (Directory.Exists(path))
                sourcePaths.Add(path);
        }
        if (sourcePaths.Count() == 0)
            return Fail("No valid source paths found for the specified version.");
    }
    else if (match is RegexMatch m)
    {
        string language1 = ToLowerNet(m.Group(1));
        string language2 = ToLowerNet(m.Group(2));
        if (language1 != language2)
            return Fail("Languages differ in path.");
        if (language1 != "german" && language1 != "english")
            return Fail("Language must be either german or english.");
        sourcePaths.Add(folder);
    }

    // (the names in the tar.gz files are relative to the current folder, as in the original)
    string workingDirectory = Directory.GetCurrentDirectory();
    foreach (var sourcePath in sourcePaths)
    {
        // (the original is a program for .NET 8, whose zip files do not have the flag of the compression level)
        if (Package.CreateZip(sourcePath, sourcePath + ".zip", false) is error e1)
            return Fail(e1.Message);
        if (Package.CreateTarball(sourcePath, sourcePath + ".tar.gz", workingDirectory) is error e2)
            return Fail(e2.Message);
        if (Package.CreateLha(sourcePath, sourcePath + ".lha") is error e3)
            return Fail(e3.Message);
    }
    return 0;
}
