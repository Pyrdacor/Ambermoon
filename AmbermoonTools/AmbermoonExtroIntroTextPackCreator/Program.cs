using System.Diagnostics;
using System.Text;
using System.Text.RegularExpressions;
using AmbermoonExtroIntroTextPackCreator;

static void Usage()
{
    Console.WriteLine("AmbermoonReleaseCreator <language_name> <version> <outdir>");
}

if (args.Length != 3)
{
    Usage();
    return 1;
}

// Get language in format "English", "German", etc.
var language = args[0].ToLower();
language = char.ToUpper(language[0]) + language[1..];

var versionRegex = VersionRegex();
var version = args[1].ToLower();

if (!versionRegex.IsMatch(version))
{
    Console.Error.WriteLine($"Version '{version}' does not match the expected format 'X.XX' (e.g., '1.00').");
    Console.Error.WriteLine();
    Usage();
    return 1;
}

var solutionDirectory = Environment.CurrentDirectory;

var tempDir = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
Directory.CreateDirectory(tempDir);
using var deleteTempDir = new Defer(() =>
{
    Environment.CurrentDirectory = solutionDirectory;

    try { Directory.Delete(tempDir, true); } catch { /* ignore */ }
});

Console.WriteLine($"Using temporary directory: {tempDir}");

var tempFiles = new List<string>();
var tempDirs = new List<string>();

void CopyAndTrackDir(string source, string dest)
{
    Console.WriteLine($"Copying directory from '{source}' to '{LocalPath(dest)}'");
    CopyDirectory(source, dest, true);
    tempDirs.Add(dest);
}

string LocalPath(string path)
{
    if (path.ToLower().StartsWith(tempDir.ToLower()))
        return path[(tempDir.Length + 1)..];

    return path;
}

// Copy the language specific directories
var languageSourcePath = Path.Combine(Environment.CurrentDirectory, "Disks", "Bugfixing", language);
var translationSourcePath = Path.Combine(Environment.CurrentDirectory, "Translations");
var languageTranslationSourcePath = Path.Combine(translationSourcePath, language);
var clickTextFile = Path.Combine(languageTranslationSourcePath, "click-text.txt");
var clickTextString = File.Exists(clickTextFile) ? File.ReadAllText(clickTextFile).Trim() : "<CLICK>";
var translatorsFile = Path.Combine(languageTranslationSourcePath, "translators.txt");
var translators = File.Exists(translatorsFile) ? string.Join(' ', File.ReadAllLines(translatorsFile, Encoding.UTF8).Select(line => line.Trim()).Where(line => !line.StartsWith('#') && !string.IsNullOrWhiteSpace(line)).Select(t => $"\"{t}\"")) : "";

CopyAndTrackDir(Path.Combine(languageSourcePath, "IntroTexts"), Path.Combine(tempDir, "IntroTextsTemp"));
CopyAndTrackDir(Path.Combine(languageSourcePath, "ExtroTexts"), Path.Combine(tempDir, "ExtroTextGroups"));

// Intro Patcher and Intro Text Packer use different text files. The source is now for the patcher
// so we will adjust it here. Mainly static texts like town or developer names are no longer used
// in the patcher but are still required by the text packer.
var staticFiles = new Dictionary<int, string>()
{
    { 0, "GEMSTONE" },
    { 1, "ILLIEN" },
    { 2, "SNAKESIGN" },
    { 4, "TWINLAKE" },
    { 5, "LYRAMION" },
};

var indexMapping = new Dictionary<int, int>()
{
    { 3, 0 },
    { 6, 1 },
    { 7, 2 },
    { 8, 3 },
    { 9, 4 },
    { 10, 5 },
    { 11, 6 },
};

string introTextTempPath = Path.Combine(tempDir, "IntroTextsTemp");
string introTextPath = Path.Combine(tempDir, "IntroTexts");
Directory.CreateDirectory(introTextPath);
tempDirs.Add(introTextPath);

for (int i = 0; i < 12; i++)
{
    if (staticFiles.TryGetValue(i, out var text))
        File.WriteAllText(Path.Combine(introTextPath, $"{i:000}.txt"), text);
    else if (indexMapping.TryGetValue(i, out var index))
        File.Copy(Path.Combine(introTextTempPath, $"{index:000}.txt"), Path.Combine(introTextPath, $"{i:000}.txt"));
    else
        throw new Exception($"No text found for index {i}");
}

int[] groupTextCounts = [3, 2, 2, 3, 3, 2, 2, 2, 2];
string[] names =
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
    "",
];

int nameIndex = 0;
int sourceIndex = 7;
bool hold = true; // source index 10 is used twice

for (int i = 12; i <= 20; i++)
{
    File.Copy(Path.Combine(introTextTempPath, $"{sourceIndex++:000}.txt"), Path.Combine(introTextPath, $"{i:000}.000.txt"));

    if (sourceIndex == 11) // was 10
    {
        if (hold)
        {
            hold = false;
            sourceIndex--;
        }
    }

    for (int t = 1; t < groupTextCounts[i - 12]; t++)
    {
        File.WriteAllText(Path.Combine(introTextPath, $"{i:000}.{t:000}.txt"), names[nameIndex++]);
    }
}

// Create needed tools
Publish("AmbermoonIntroTextPacker");
Publish("AmbermoonExtroTextPacker");

// From now on work inside the temp directory
Environment.CurrentDirectory = tempDir;

// Create Intro Text Pack
Exec("AmbermoonIntroTextPacker.exe", $"\"{tempDir}\"");

// Create Extro Text Pack
Exec("AmbermoonExtroTextPacker.exe", $"\"{tempDir}\" \"{clickTextString}\" {translators}");

var outputDirectory = args[2];

Directory.CreateDirectory(outputDirectory);

File.Move(Path.Combine(tempDir, "Intro_texts.amb"), Path.Combine(outputDirectory, "Intro_texts.amb"), true);
File.Move(Path.Combine(tempDir, "Extro_texts.amb"), Path.Combine(outputDirectory, "Extro_texts.amb"), true);

// Delete tools
File.Delete(Path.Combine(tempDir, "AmbermoonIntroTextPacker.exe"));
File.Delete(Path.Combine(tempDir, "AmbermoonExtroTextPacker.exe"));

// Delete temp files and directories
foreach (var file in tempFiles)
{
    if (File.Exists(file))
    {
        File.Delete(file);
    }
}

foreach (var dir in tempDirs)
{
    if (Directory.Exists(dir))
    {
        Directory.Delete(dir, true);
    }
}

return 0;

static void CopyDirectory(string sourceDir, string targetDir, bool recursive)
{
    if (!Directory.Exists(sourceDir))
    {
        throw new DirectoryNotFoundException($"Source directory '{sourceDir}' does not exist.");
    }

    Directory.CreateDirectory(targetDir);

    foreach (var file in Directory.GetFiles(sourceDir))
    {
        var targetFile = Path.Combine(targetDir, Path.GetFileName(file));
        File.Copy(file, targetFile, true);
    }

    if (recursive)
    {
        foreach (var dir in Directory.GetDirectories(sourceDir))
        {
            var targetSubDir = Path.Combine(targetDir, Path.GetFileName(dir));
            CopyDirectory(dir, targetSubDir, true);
        }
    }
}

void Publish(string name)
{
    Exec("dotnet", $"publish -c Release \"./AmbermoonTools/{name}/{name}.csproj\" -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -p:DebugType=None -p:DebugSymbols=false -p:NoWarn=NU1900 -p:WarningLevel=0 -r win-x64 --no-self-contained --nologo -o \"{tempDir}\"", KeyValuePair.Create("HTTP_PROXY", ""), KeyValuePair.Create("HTTPS_PROXY", ""), KeyValuePair.Create("DOTNET_CLI_WORKLOAD_UPDATE_NOTIFICATION", "0"));
}

static void Exec(string command, string args, params List<KeyValuePair<string, string>> environmentVariables)
{
    Console.WriteLine();
    Console.WriteLine($"Executing: {command} {args}");

    var processStartInfo = new ProcessStartInfo
    {
        FileName = command,
        Arguments = args,
        RedirectStandardOutput = true,
        RedirectStandardError = true,
        UseShellExecute = false,
        CreateNoWindow = true,
        WorkingDirectory = Environment.CurrentDirectory
    };

    if (environmentVariables != null)
    {
        foreach (var variable in environmentVariables)
            processStartInfo.EnvironmentVariables[variable.Key] = variable.Value;
    }

    var process = new Process
    {
        StartInfo = processStartInfo
    };

    process.OutputDataReceived += (sender, args) =>
    {
        if (args.Data != null)
            Console.Out.WriteLine(args.Data);
    };

    process.ErrorDataReceived += (sender, args) =>
    {
        if (args.Data != null)
            Console.Error.WriteLine(args.Data);
    };

    if (!process.Start())
    {
        Console.Error.WriteLine($"Failed to start process '{command}'.");
    }
    else
    {
        process.BeginOutputReadLine();
        process.BeginErrorReadLine();
    }

    process.WaitForExit();

    if (process.ExitCode != 0)
    {
        Console.Error.WriteLine($"Process '{command}' failed with exit code {process.ExitCode}.");
    }
}

partial class Program
{
    [GeneratedRegex("^([1-9])[.]([0-9]{2})$")]
    private static partial Regex VersionRegex();
}