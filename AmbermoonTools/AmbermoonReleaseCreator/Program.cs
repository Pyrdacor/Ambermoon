using System;
using System.Diagnostics;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;
using AmbermoonReleaseCreator;
using Amiga.FileFormats.ADF;

static void Usage()
{
    Console.WriteLine("AmbermoonReleaseCreator <language_name> <version>");
}

/*
 * This program creates a release of Ambermoon with the given language.
 * 
 * NOTE: The tool is supposed to run in the CI pipeline. If you want to use
 * it locally, ensure that the current working directory is the solution
 * base path!
 * 
 * It will expect the data in <solution_dir>/Disks/Bugfixing/<language_name>.
 * 
 * It needs 3 directories:
 * - AllTexts (for the game texts)
 * - IntroTexts (for the intro texts)
 * - ExtroTexts (for the extro texts)
 * 
 * The program works in a temporary file and if successful, copies the resulting
 * releases archives to <solution_dir>/Disks/<language_name>.
 * 
 * There will be 6 output files:
 * - ambermoon_<language_name>_<version>_adf.lha
 * - ambermoon_<language_name>_<version>_adf.tar.gz
 * - ambermoon_<language_name>_<version>_adf.zip
 * - ambermoon_<language_name>_<version>_extracted.lha
 * - ambermoon_<language_name>_<version>_extracted.tar.gz
 * - ambermoon_<language_name>_<version>_extracted.zip
 *
 * Workflow:
 * 
 * NOTE: The base for game fixes is always the german version!
 * 
 * 1. Copy the current german version from <solution_dir>/Disks/Bugfixing/German to the temp directory.
 * 2. Copy the intro and extro base text directories from <solution_dir>/Translations to the temp directory.
 * 3. Copy the AllTexts, IntroTexts, and ExtroTexts directories from the given language directory to the temp directory.
 * 4. Create needed configuration files.
 * 5. Patch the game texts with the AllTexts directory.
 * 6. Patch the intro texts with the IntroTexts directory.
 * 7. Patch the extro texts with the ExtroTexts directory.
 * 8. Assemble all files for the release.
 * 9. Create ADF disk images.
 * 10. Create release archives.
 * 
 * If language is German, steps 1 to 7 are skipped.
 */

if (args.Length != 2)
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
using var deleteTempDir = new Defer(() => { try { Directory.Delete(tempDir, true); } catch { /* ignore */ } });

Console.WriteLine($"Using temporary directory: {tempDir}");

if (language != "German")
{
    // Copy the german version to the temp directory
    var germanSourcePath = Path.Combine(Environment.CurrentDirectory, "Disks", "German", $"ambermoon_german_{version}_extracted.zip");

    if (!File.Exists(germanSourcePath))
    {
        Console.Error.WriteLine($"German source file '{germanSourcePath}' does not exist.");
        return 1;
    }

    ZipFile.ExtractToDirectory(germanSourcePath, tempDir);

    var tempFiles = new List<string>();
    var tempDirs = new List<string>();

    tempFiles.Add("liesmich.txt"); // only for german

    var readmeLines = File.ReadLines(Path.Combine(tempDir, "readme.txt")).ToArray();
    readmeLines[0] = $"Ambermoon {language} {version} by Pyrdacor ({DateTime.Now:dd-MM-yyyy})";
    File.WriteAllLines(Path.Combine(tempDir, "readme.txt"), readmeLines);

    void CopyAndTrackDir(string source, string dest)
    {
        Console.WriteLine($"Copying directory from '{source}' to '{LocalPath(dest)}'");
        CopyDirectory(source, dest, true);
        tempDirs.Add(dest);
    }

    void CopyAndTrackFile(string source, string dest)
    {
        Console.WriteLine($"Copying file from '{source}' to '{LocalPath(dest)}'");
        File.Copy(source, dest, true);
        tempFiles.Add(dest);
    }

    // Copy the language specific directories
    var languageSourcePath = Path.Combine(Environment.CurrentDirectory, "Disks", "Bugfixing", language);
    var translationSourcePath = Path.Combine(Environment.CurrentDirectory, "Translations");
    var languageTranslationSourcePath = Path.Combine(translationSourcePath, language);
    var encodingFile = Path.Combine(languageTranslationSourcePath, "encoding.txt");
    var encodingString = File.Exists(encodingFile) ? File.ReadAllText(encodingFile).Trim() : Encoding.Latin1.EncodingName;
    var clickTextFile = Path.Combine(languageTranslationSourcePath, "click-text.txt");
    var clickTextString = File.Exists(clickTextFile) ? File.ReadAllText(clickTextFile).Trim() : "<CLICK>";
    var translatorsFile = Path.Combine(languageTranslationSourcePath, "translators.txt");
    var translators = File.Exists(translatorsFile) ? string.Join(' ', File.ReadAllLines(translatorsFile).Select(line => line.Trim()).Where(line => !line.StartsWith('#') && !string.IsNullOrWhiteSpace(line))) : "";

    CopyAndTrackDir(Path.Combine(languageSourcePath, "AllTexts"), Path.Combine(tempDir, "AllTexts"));
    CopyAndTrackDir(Path.Combine(languageSourcePath, "IntroTexts"), Path.Combine(tempDir, "IntroTexts"));
    CopyAndTrackDir(Path.Combine(languageSourcePath, "ExtroTexts"), Path.Combine(tempDir, "ExtroTexts"));
    CopyAndTrackFile(Path.Combine(translationSourcePath, "Ambermoon_intro_translation_base"), Path.Combine(tempDir, "Ambermoon_intro_translation_base"));
    CopyAndTrackFile(Path.Combine(translationSourcePath, "Ambermoon_extro_translation_base"), Path.Combine(tempDir, "Ambermoon_extro_translation_base"));
    CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "font.json"), Path.Combine(tempDir, "font.json"));
    CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "SmallGlyphs.png"), Path.Combine(tempDir, "SmallGlyphs.png"));
    CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "LargeGlyphs.png"), Path.Combine(tempDir, "LargeGlyphs.png"));

    // Create needed tools
    Publish("AmbermoonTextManager");
    Publish("AmbermoonIntroPatcher");
    Publish("AmbermoonExtroPatcher");
    Publish("AmbermoonFontCreator");

    // Adjust release date
    File.WriteAllText(Path.Combine(tempDir, "AllTexts", "Text.amb", "DateAndLanguageString", "000.txt"), DateTime.Now.ToString("dd-MM-yyyy") + $" / {language}");

    // Adjust version
    File.WriteAllText(Path.Combine(tempDir, "AllTexts", "Text.amb", "VersionString", "000.txt"), $"Ambermoon v{version}");

    // From now on work inside the temp directory
    Environment.CurrentDirectory = tempDir;

    // Patch game texts
    Exec("AmbermoonTextManager.exe", "-i Amberfiles AllTexts");

    // Create fonts
    Exec("AmbermoonFontCreator.exe", "font.json SmallGlyphs.png LargeGlyphs.png Fonts");
    tempFiles.Add(Path.Combine(tempDir, "Fonts"));

    // Patch Intro
    File.Delete(Path.Combine(tempDir, "Amberfiles", "Ambermoon_intro"));
    Exec("AmbermoonIntroPatcher.exe", $"Ambermoon_intro_translation_base IntroTexts Amberfiles\\Ambermoon_intro Fonts {encodingString}");

    // Patch Extro
    File.Delete(Path.Combine(tempDir, "Amberfiles", "Ambermoon_extro"));
    Exec("AmbermoonExtroPatcher.exe", $"Ambermoon_extro_translation_base ExtroTexts Amberfiles\\Ambermoon_extro Fonts {encodingString} {clickTextString} {translators}");

    // Delete tools
    File.Delete(Path.Combine(tempDir, "AmbermoonTextManager.exe"));
    File.Delete(Path.Combine(tempDir, "AmbermoonIntroPatcher.exe"));
    File.Delete(Path.Combine(tempDir, "AmbermoonExtroPatcher.exe"));
    File.Delete(Path.Combine(tempDir, "AmbermoonFontCreator.exe"));

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
}

// Create ADF disk images
var adfTempPath = Path.Combine(tempDir, "ADFTemp");
Directory.CreateDirectory(adfTempPath);

string LocalPath(string path)
{
    if (path.ToLower().StartsWith(tempDir.ToLower()))
        return path[(tempDir.Length + 1)..];

    return path;
}

IEnumerable<AdfFileInfo> AllFilesIn(string folder, string targetDirectory = "", bool recursive = true, bool keepHierarchy = false)
{
    string LocalDirectory(string filePath)
    {
        if (filePath.ToLower().StartsWith(tempDir.ToLower()))
            filePath = filePath[(tempDir.Length + 1)..];

        if (filePath.ToLower().StartsWith(folder.ToLower()))
            filePath = filePath[(folder.Length + 1)..];

        return Path.GetDirectoryName(filePath) ?? "";
    }

    return Directory
        .GetFiles(folder, "*.*", recursive ? SearchOption.AllDirectories : SearchOption.TopDirectoryOnly)
        .Select(filePath => new AdfFileInfo(LocalPath(filePath),
            keepHierarchy
                ? string.IsNullOrEmpty(targetDirectory) ? LocalDirectory(filePath) : Path.Combine(targetDirectory, LocalDirectory(filePath))
                : targetDirectory));
}

var bootDiskSourcePath = Path.Combine(solutionDirectory, "Disks", "BootDisk");
var bootDiskDirPath = Path.Combine(tempDir, "BootDisk");
Console.WriteLine($"Copying directory from '{bootDiskSourcePath}' to 'BootDisk'");
CopyDirectory(bootDiskSourcePath, bootDiskDirPath, true);

// Disk A
// TODO: copy files and folders like C, Devs, Trouble.doc etc
CreateADF(adfTempPath, 'A',
[
    ..AllFilesIn("BootDisk", "", true, true),
    "Ambermoon",
    "Ambermoon.info",
    "Ambermoon_install",
    "Ambermoon_install.info",
    "readme.txt",
    ..AllFilesIn("Amberfiles\\Save.00", "Initial"),
    "Amberfiles\\AM2_CPU",
    "Amberfiles\\Button_graphics",
    "Amberfiles\\Objects.amb",
    "Amberfiles\\Text.amb",
]);Directory.Delete(bootDiskDirPath, true);

// Disk B
CreateADF(adfTempPath, 'B',
[
    "Amberfiles\\Ambermoon_intro",
    "Amberfiles\\Fantasy_intro",
    "Amberfiles\\Intro_music",
]);
// Disk C
CreateADF(adfTempPath, 'C',
[
    "Amberfiles\\1Icon_gfx.amb",
    "Amberfiles\\1Map_data.amb",
    "Amberfiles\\1Map_texts.amb",
]);
// Disk D
CreateADF(adfTempPath, 'D',
[
    "Amberfiles\\2Icon_gfx.amb",
    "Amberfiles\\2Lab_data.amb",
    "Amberfiles\\2Map_data.amb",
    "Amberfiles\\2Map_texts.amb",
    "Amberfiles\\2Object3D.amb",
]);
// Disk E
CreateADF(adfTempPath, 'E',
[
    "Amberfiles\\2Overlay3D.amb",
    "Amberfiles\\2Wall3D.amb",
]);
// Disk F
CreateADF(adfTempPath, 'F',
[
    "Amberfiles\\3Icon_gfx.amb",
    "Amberfiles\\3Lab_data.amb",
    "Amberfiles\\3Map_data.amb",
    "Amberfiles\\3Map_texts.amb",
    "Amberfiles\\3Object3D.amb",
    "Amberfiles\\3Overlay3D.amb",
    "Amberfiles\\3Wall3D.amb",
]);
// Disk G
CreateADF(adfTempPath, 'G',
[
    "Amberfiles\\Automap_graphics",
    "Amberfiles\\Combat_graphics",
    "Amberfiles\\Dict.amb",
    "Amberfiles\\Event_pix.amb",
    "Amberfiles\\Floors.amb",
    "Amberfiles\\Icon_data.amb",
    "Amberfiles\\Lab_background.amb",
    "Amberfiles\\Layouts.amb",
    "Amberfiles\\NPC_char.amb",
    "Amberfiles\\NPC_gfx.amb",
    "Amberfiles\\NPC_texts.amb",
    "Amberfiles\\Object_icons",
    "Amberfiles\\Object_texts.amb",
    "Amberfiles\\Palettes.amb",
    "Amberfiles\\Party_gfx.amb",
    "Amberfiles\\Party_texts.amb",
    "Amberfiles\\Pics_80x80.amb",
    "Amberfiles\\Place_data",
    "Amberfiles\\Portraits.amb",
    "Amberfiles\\Riddlemouth_graphics",
    "Amberfiles\\Stationary",
    "Amberfiles\\Travel_gfx.amb",
]);
// Disk H
CreateADF(adfTempPath, 'H',
[
    "Amberfiles\\Combat_background.amb",
    "Amberfiles\\Monster_char.amb",
    "Amberfiles\\Monster_gfx.amb",
    "Amberfiles\\Monster_groups.amb",
]);
// Disk I
CreateADF(adfTempPath, 'I',
[
    "Amberfiles\\Ambermoon_extro",
    "Amberfiles\\Extro_music",
    "Amberfiles\\Music.amb",
]);
// Disk J
CreateADF(adfTempPath, 'J',
[
    "Amberfiles\\Saves",
    ..AllFilesIn("Amberfiles\\Save.00", ""),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.00"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.01"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.02"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.03"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.04"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.05"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.06"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.07"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.08"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.09"),
    ..AllFilesIn("Amberfiles\\Save.00", "Save.10"),
]);

// Create release archives
var releasePath = Path.Combine(solutionDirectory, "Disks", language);
var releaseName = $"ambermoon_{language.ToLower()}_{version}";
var adfArchiveName = $"{releaseName}_adf";
var extractedArchiveName = $"{releaseName}_extracted";

Directory.CreateDirectory(releasePath);

// ADF releases
Console.WriteLine($"Creating ADF releases in {releasePath}");
try
{
    Package.CreateZip(adfTempPath, Path.Combine(releasePath, $"{adfArchiveName}.zip"));
    Package.CreateTarball(adfTempPath, Path.Combine(releasePath, $"{adfArchiveName}.tar.gz"));
    Package.CreateLha(adfTempPath, Path.Combine(releasePath, $"{adfArchiveName}.lha"));
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Failed to create ADF releases: {ex.Message}");
    return 1;
}

Directory.Delete(adfTempPath, true);

Console.WriteLine();
Console.WriteLine("Current files in the temporary directory:");
ShowFiles();

// Extracted releases
Console.WriteLine($"Creating extracted releases in {releasePath}");
try
{
    Package.CreateZip(tempDir, Path.Combine(releasePath, $"{extractedArchiveName}.zip"));
    Package.CreateTarball(tempDir, Path.Combine(releasePath, $"{extractedArchiveName}.tar.gz"));
    Package.CreateLha(tempDir, Path.Combine(releasePath, $"{extractedArchiveName}.lha"));
}
catch (Exception ex)
{
    Console.Error.WriteLine($"Failed to create extracted releases: {ex.Message}");
    return 1;
}

Thread.Sleep(2000); // Wait before trying to delete the temp directory

return 0;


string TargetPath(AdfFileInfo fileInfo)
{
    var filename = Path.GetFileName(fileInfo.Path);

    return string.IsNullOrEmpty(fileInfo.TargetDirectory) ? filename : fileInfo.TargetDirectory.Replace('\\', '/').TrimEnd('\\', '/') + "/" + filename;
}

void CreateADF(string directory, char letter, List<AdfFileInfo> fileInfos)
{
    var fileStreams = fileInfos
        .Select(fileInfo =>
        (
            TargetPath(fileInfo),
            (Stream)File.OpenRead(Path.Combine(tempDir, fileInfo.Path))
        ))
        .ToDictionary(file => file.Item1, file => file.Item2);

    using var stream = File.Create(Path.Combine(directory, $"AMBER_{letter}.adf"));

    ADFWriter.WriteADFFile(stream, $"AMBER_{letter}", FileSystem.OFS, letter == 'A', false, false, fileStreams);

    foreach (var fileStream in fileStreams.Values)
        fileStream.Close();
}

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

void ShowFiles()
{
    if (OperatingSystem.IsWindows())
    {
        Exec("cmd.exe", "/c dir /s /b");
    }
    else
    {
        Exec("ls", "-R -l");
    }
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

file record AdfFileInfo(string Path, string TargetDirectory = "")
{
    public static implicit operator AdfFileInfo(string path) => new(path, "");
}

partial class Program
{
    [GeneratedRegex("^[1-9][.][0-9]{2}$")]
    private static partial Regex VersionRegex();
}