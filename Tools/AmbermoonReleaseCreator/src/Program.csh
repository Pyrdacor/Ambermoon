// AmbermoonReleaseCreator <language_name> <version>: makes a release of Ambermoon in a language, run in the folder of
// the Ambermoon repository. Non-German releases are made of the German release of the same version: the texts of
// the game, the intro and the extro are patched (with AmbermoonTextManager, AmbermoonFontCreator,
// AmbermoonIntroPatcher and AmbermoonExtroPatcher); German releases are made of the previous German release and the
// files in Disks/Bugfixing/German. The results are ADF images and the archives (zip, tar.gz, LHA) of the images and
// of the files, in Disks/<language>.
//
// The tools are the CShift ports (or the originals): found in the folder of the environment variable AMBERMOON_TOOLS,
// else on the PATH. SOURCE_DATE_EPOCH (seconds since 1970) replaces the current time (texts, ADF images, archives).

using System;
using Ambermoon;
using Ambermoon.Release;
using Amiga.FileFormats.ADF;

void Usage()
{
    Console.WriteLine("AmbermoonReleaseCreator <language_name> <version>");
}

int Main(string[] args)
{
    if (args.Length != 2 || args[0].Length == 0)
    {
        Usage();
        return 1;
    }

    // the language as "English", "German", ...
    string lower = ToLowerNet(args[0]);
    int first = _CodePointLength(lower, 0);
    string language = ToUpperNet(lower[0..first]) + lower[first..];

    string version = ToLowerNet(args[1]);
    var versionRegex = Regex.Create("^([1-9])[.]([0-9]{2})$");
    Optional<RegexMatch> matched = null;
    if (versionRegex is Regex vr)
        matched = vr.Match(version);
    if (matched is not RegexMatch versionMatch)
    {
        Console.WriteErrorLine("Version '" + version + "' does not match the expected format 'X.XX' (e.g., '1.00').");
        Console.WriteErrorLine("");
        Usage();
        return 1;
    }

    var c = Creator
    {
        SolutionDirectory = Directory.GetCurrentDirectory(), Language = language, Version = version,
        VersionMajor = versionMatch.Group(1).ParseInt() is int major ? major : 0,
        VersionMinor = versionMatch.Group(2).ParseInt() is int minor ? minor : 0,
        Now = ReleaseNow(), TempFiles = List<string>.Create(), TempDirs = List<string>.Create()
    };
    c.TempDir = Path.Combine(TempPath(), NewGuid());
    Directory.Create(c.TempDir);
    Console.WriteLine("Using temporary directory: " + c.TempDir);

    int result = c.Run();
    if (result != 0 && c.Error.Length > 0)
        Console.WriteErrorLine(c.Error);
    Directory.Delete(c.TempDir, true);
    return result;
}

struct Creator
{
    string SolutionDirectory;
    string Language;
    string Version;
    int VersionMajor;
    int VersionMinor;
    DateTime Now;
    string TempDir;
    List<string> TempFiles;
    List<string> TempDirs;
    string Error;     // why the release failed (where the original ends with an exception)

    int Run()
    {
        Error = "";
        if (Language != "German")
        {
            if (!PatchLanguage())
                return 1;
        }
        else if (!UpdateGerman())
            return 1;
        return CreateRelease();
    }

    int Fail(string message)
    {
        Error = message;
        return 1;
    }

    // ------------------------------------------------------------------------------------------------------------------
    // Other languages: the German release of the same version with the texts of the language

    bool PatchLanguage()
    {
        var germanSourcePath = Path.Combine(Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "German"),
                                            "ambermoon_german_" + Version + "_extracted.zip");
        if (!IsFile(germanSourcePath))
        {
            Console.WriteErrorLine("German source file '" + germanSourcePath + "' does not exist.");
            return false;
        }
        if (ExtractZip(germanSourcePath, TempDir) is error e)
            return Failed(e.Message);

        TempFiles.Add(Path.Combine(TempDir, "liesmich.txt")); // it's only for german

        var readme = Path.Combine(TempDir, "readme.txt");
        if (!SetFirstLine(readme, "Ambermoon " + Language + " " + Version + " by Pyrdacor (" + FormatDate(Now) + ")"))
            return false;

        var languageSourcePath = Path.Combine(Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "Bugfixing"), Language);
        var translationSourcePath = Path.Combine(SolutionDirectory, "Translations");
        var languageTranslationSourcePath = Path.Combine(translationSourcePath, Language);

        bool createIntroAndExtro = true;
        string encodingString = "";
        string clickTextString = "";
        string translators = "";

        if (!Directory.Exists(languageTranslationSourcePath))
        {
            if (!CopyAndTrackFile(Path.Combine(languageSourcePath, Path.Combine("Amberfiles", "Ambermoon_intro")),
                                  Path.Combine(TempDir, Path.Combine("Amberfiles", "Ambermoon_intro")), true))
                return false;
            if (!CopyAndTrackFile(Path.Combine(languageSourcePath, Path.Combine("Amberfiles", "Ambermoon_extro")),
                                  Path.Combine(TempDir, Path.Combine("Amberfiles", "Ambermoon_extro")), true))
                return false;
            createIntroAndExtro = false;
        }
        else
        {
            var encodingFile = Path.Combine(languageTranslationSourcePath, "encoding.txt");
            // (the name of .NET's Encoding.Latin1, which the patchers do not know: as in the original)
            encodingString = IsFile(encodingFile) ? TrimNet(ReadText(encodingFile)).ToString() : "Western European (ISO)";
            var clickTextFile = Path.Combine(languageTranslationSourcePath, "click-text.txt");
            clickTextString = IsFile(clickTextFile) ? TrimNet(ReadText(clickTextFile)).ToString() : "<CLICK>";
            var translatorsFile = Path.Combine(languageTranslationSourcePath, "translators.txt");
            if (IsFile(translatorsFile))
            {
                var names = StringBuilder.Create();
                foreach (var line in SplitLinesNet(ReadText(translatorsFile)))
                {
                    var name = TrimNet(line);
                    if (name.StartsWith("#") || IsWhiteSpaceOnlyNet(name))
                        continue;
                    if (names.Length() > 0)
                        names.Append(" ");
                    names.Append("\"" + name + "\"");
                }
                translators = names.ToString();
            }

            if (!CopyAndTrackDir(Path.Combine(languageSourcePath, "IntroTexts"), Path.Combine(TempDir, "IntroTexts")) ||
                !CopyAndTrackDir(Path.Combine(languageSourcePath, "ExtroTexts"), Path.Combine(TempDir, "ExtroTexts")) ||
                !CopyAndTrackFile(Path.Combine(translationSourcePath, "Ambermoon_intro_translation_base"), Path.Combine(TempDir, "Ambermoon_intro_translation_base"), false) ||
                !CopyAndTrackFile(Path.Combine(translationSourcePath, "Ambermoon_extro_translation_base"), Path.Combine(TempDir, "Ambermoon_extro_translation_base"), false) ||
                !CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "font.json"), Path.Combine(TempDir, "font.json"), false) ||
                !CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "SmallGlyphs.png"), Path.Combine(TempDir, "SmallGlyphs.png"), false) ||
                !CopyAndTrackFile(Path.Combine(languageTranslationSourcePath, "LargeGlyphs.png"), Path.Combine(TempDir, "LargeGlyphs.png"), false))
                return false;
        }

        if (!CopyAndTrackDir(Path.Combine(languageSourcePath, "AllTexts"), Path.Combine(TempDir, "AllTexts")) ||
            !CopyAndTrackFile(Path.Combine(languageSourcePath, Path.Combine("Amberfiles", "Button_graphics")),
                              Path.Combine(TempDir, Path.Combine("Amberfiles", "Button_graphics")), true))
            return false;

        if (!SetVersionTexts(Language))
            return false;

        // patch the game texts
        string additionalOptions = Language != "German" && Language != "English" ? " -u" : "";
        Exec("AmbermoonTextManager", "-i Amberfiles AllTexts" + additionalOptions);

        if (createIntroAndExtro)
        {
            Exec("AmbermoonFontCreator", "font.json SmallGlyphs.png LargeGlyphs.png Fonts");
            TempFiles.Add(Path.Combine(TempDir, "Fonts"));

            string sep = Process.IsWindows() ? "\\" : "/";
            DeleteFile(Path.Combine(TempDir, Path.Combine("Amberfiles", "Ambermoon_intro")));
            Exec("AmbermoonIntroPatcher", "Ambermoon_intro_translation_base IntroTexts Amberfiles" + sep + "Ambermoon_intro Fonts \"" + encodingString + "\"");
            DeleteFile(Path.Combine(TempDir, Path.Combine("Amberfiles", "Ambermoon_extro")));
            Exec("AmbermoonExtroPatcher", "Ambermoon_extro_translation_base ExtroTexts Amberfiles" + sep + "Ambermoon_extro Fonts \"" + encodingString +
                 "\" \"" + clickTextString + "\" " + translators);
        }

        // the tools the original publishes into the temporary directory are deleted: also the AmbermoonTextManager.exe
        // that the German releases contain
        DeleteFile(Path.Combine(TempDir, "AmbermoonTextManager.exe"));
        if (createIntroAndExtro)
        {
            DeleteFile(Path.Combine(TempDir, "AmbermoonIntroPatcher.exe"));
            DeleteFile(Path.Combine(TempDir, "AmbermoonExtroPatcher.exe"));
            DeleteFile(Path.Combine(TempDir, "AmbermoonFontCreator.exe"));
        }

        foreach (var file in TempFiles)
        {
            if (IsFile(file))
                File.Delete(file);
        }
        foreach (var dir in TempDirs)
        {
            if (Directory.Exists(dir))
                Directory.Delete(dir, true);
        }
        return true;
    }

    // ------------------------------------------------------------------------------------------------------------------
    // German: the previous German release with the files of Disks/Bugfixing/German

    bool UpdateGerman()
    {
        var germanSourcePath = Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "German");
        var regex = Regex.Create("ambermoon_german_([0-9])[.]([0-9]+)_extracted.zip");
        string previous = "";
        int previousMajor = -1;
        int previousMinor = -1;
        if (regex is Regex fileRegex && Directory.Exists(germanSourcePath))
        {
            foreach (var file in FindFiles(germanSourcePath, "*.zip", false))
            {
                if (fileRegex.Match(Path.GetFileName(file)) is not RegexMatch m)
                    continue;
                int major = m.Group(1).ParseInt() is int a ? a : 0;
                int minor = m.Group(2).ParseInt() is int b ? b : 0;
                if (!(major < VersionMajor || (major == VersionMajor && minor < VersionMinor)))
                    continue;
                // the newest of them (the first one of equal versions, as OrderByDescending keeps the order)
                if (major > previousMajor || (major == previousMajor && minor > previousMinor))
                {
                    previous = file;
                    previousMajor = major;
                    previousMinor = minor;
                }
            }
        }
        if (previous.Length == 0)
        {
            Console.WriteErrorLine("No previous German release found in '" + germanSourcePath + "'.");
            return false;
        }
        Console.WriteLine("Using German release '" + previous + "' as a basis.");
        if (ExtractZip(previous, TempDir) is error e)
            return Failed(e.Message);

        // the files and directories of the previous release: only those are updated
        var filenames = HashSet<string>.Create();
        var directories = HashSet<string>.Create();
        foreach (var entry in FileSystemEntriesWindows(TempDir))
        {
            string relative = RelativeKey(entry.Path, TempDir);
            if (entry.IsDirectory)
                directories.Add(relative);
            else
                filenames.Add(relative);
        }

        var germanBugfixPath = Path.Combine(Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "Bugfixing"), "German");
        var changelogPath = Path.Combine(Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "Bugfixing"), "Changelog");

        Console.WriteLine("Copying directory from '" + Path.Combine(germanBugfixPath, "Amberfiles") + "' to '" +
                          LocalPath(Path.Combine(TempDir, "Amberfiles")) + "'");
        if (!CopyDirectory(Path.Combine(germanBugfixPath, "Amberfiles"), Path.Combine(TempDir, "Amberfiles"), true, filenames, directories, true))
            return false;
        if (!CopyFiles(germanBugfixPath, TempDir, ["Ambermoon", "Ambermoon_install"]) ||
            !CopyFiles(changelogPath, TempDir, ["readme.txt", "liesmich.txt"]))
            return false;

        string header = "Ambermoon German " + Version + " by Pyrdacor (" + FormatDate(Now) + ")";
        if (!SetFirstLine(Path.Combine(TempDir, "readme.txt"), header) || !SetFirstLine(Path.Combine(TempDir, "liesmich.txt"), header))
            return false;

        var allTextsDir = Path.Combine(TempDir, "AllTexts");
        Console.WriteLine("Copying directory from '" + Path.Combine(germanBugfixPath, "AllTexts") + "' to '" + LocalPath(allTextsDir) + "'");
        if (!CopyDirectory(Path.Combine(germanBugfixPath, "AllTexts"), allTextsDir, true, HashSet<string>.Create(), HashSet<string>.Create(), false))
            return false;

        if (!SetVersionTexts("Deutsch"))
            return false;
        Exec("AmbermoonTextManager", "-i Amberfiles AllTexts");
        Directory.Delete(allTextsDir, true);
        return true;
    }

    // ------------------------------------------------------------------------------------------------------------------
    // The ADF images and the archives

    int CreateRelease()
    {
        var adfTempPath = Path.Combine(TempDir, "ADFTemp");
        Directory.Create(adfTempPath);

        var bootDiskSourcePath = Path.Combine(Path.Combine(SolutionDirectory, "Disks"), "BootDisk");
        var bootDiskDirPath = Path.Combine(TempDir, "BootDisk");
        Console.WriteLine("Copying directory from '" + bootDiskSourcePath + "' to 'BootDisk'");
        if (!CopyDirectory(bootDiskSourcePath, bootDiskDirPath, true, HashSet<string>.Create(), HashSet<string>.Create(), false))
            return 1;
        if (Language != "English")
        {
            Console.WriteLine("Patch english boot disk files to " + ToLowerNet(Language));
            if (!PatchBootDiskFiles(bootDiskDirPath))
                return 1;
        }

        var a = List<AdfEntry>.Create();
        AddAllFilesIn(ref a, "BootDisk", "", true);
        foreach (var name in ["Ambermoon", "Ambermoon.info", "Ambermoon_install", "Ambermoon_install.info", "readme.txt"])
            a.Add(AdfEntry { Path = name, Target = "" });
        AddAllFilesIn(ref a, AmberPath("Save.00"), "Initial", false);
        AddAmberfiles(ref a, ["AM2_CPU", "Button_graphics", "Objects.amb", "Text.amb"]);
        if (!CreateADF(adfTempPath, 'A', a))
            return 1;
        Directory.Delete(bootDiskDirPath, true);

        if (!CreateADF(adfTempPath, 'B', Amberfiles(["Ambermoon_intro", "Fantasy_intro", "Intro_music"])) ||
            !CreateADF(adfTempPath, 'C', Amberfiles(["1Icon_gfx.amb", "1Map_data.amb", "1Map_texts.amb"])) ||
            !CreateADF(adfTempPath, 'D', Amberfiles(["2Icon_gfx.amb", "2Lab_data.amb", "2Map_data.amb", "2Map_texts.amb", "2Object3D.amb"])) ||
            !CreateADF(adfTempPath, 'E', Amberfiles(["2Overlay3D.amb", "2Wall3D.amb"])) ||
            !CreateADF(adfTempPath, 'F', Amberfiles(["3Icon_gfx.amb", "3Lab_data.amb", "3Map_data.amb", "3Map_texts.amb", "3Object3D.amb",
                                                     "3Overlay3D.amb", "3Wall3D.amb"])) ||
            !CreateADF(adfTempPath, 'G', Amberfiles(["Automap_graphics", "Combat_graphics", "Dict.amb", "Event_pix.amb", "Floors.amb",
                                                     "Icon_data.amb", "Lab_background.amb", "Layouts.amb", "NPC_char.amb", "NPC_gfx.amb",
                                                     "NPC_texts.amb", "Object_icons", "Object_texts.amb", "Palettes.amb", "Party_gfx.amb",
                                                     "Party_texts.amb", "Pics_80x80.amb", "Place_data", "Portraits.amb",
                                                     "Riddlemouth_graphics", "Stationary", "Travel_gfx.amb"])) ||
            !CreateADF(adfTempPath, 'H', Amberfiles(["Combat_background.amb", "Monster_char.amb", "Monster_gfx.amb", "Monster_groups.amb"])) ||
            !CreateADF(adfTempPath, 'I', Amberfiles(["Ambermoon_extro", "Extro_music", "Music.amb"])))
            return 1;
        var j = Amberfiles(["Saves"]);
        for (var s = 0; s <= 10; s += 1)
            AddAllFilesIn(ref j, AmberPath("Save.00"), "Save." + (s < 10 ? "0" : "") + s.ToString(), false);
        if (!CreateADF(adfTempPath, 'J', j))
            return 1;

        var releasePath = Path.Combine(Path.Combine(SolutionDirectory, "Disks"), Language);
        var releaseName = "ambermoon_" + ToLowerNet(Language) + "_" + Version;
        Directory.Create(releasePath);

        Console.WriteLine("Creating ADF releases in " + releasePath);
        if (Package.CreateZip(adfTempPath, Path.Combine(releasePath, releaseName + "_adf.zip"), true) is error e1)
            return Fail("Failed to create ADF releases: " + e1.Message);
        if (Package.CreateTarball(adfTempPath, Path.Combine(releasePath, releaseName + "_adf.tar.gz"), TempDir) is error e2)
            return Fail("Failed to create ADF releases: " + e2.Message);
        if (Package.CreateLha(adfTempPath, Path.Combine(releasePath, releaseName + "_adf.lha")) is error e3)
            return Fail("Failed to create ADF releases: " + e3.Message);
        Directory.Delete(adfTempPath, true);

        Console.WriteLine();
        Console.WriteLine("Current files in the temporary directory:");
        if (Process.IsWindows())
            ExecCommand("cmd.exe", "/c dir /s /b");
        else
            ExecCommand("ls", "-R -l");

        Console.WriteLine("Creating extracted releases in " + releasePath);
        if (Package.CreateZip(TempDir, Path.Combine(releasePath, releaseName + "_extracted.zip"), true) is error e4)
            return Fail("Failed to create extracted releases: " + e4.Message);
        if (Package.CreateTarball(TempDir, Path.Combine(releasePath, releaseName + "_extracted.tar.gz"), TempDir) is error e5)
            return Fail("Failed to create extracted releases: " + e5.Message);
        if (Package.CreateLha(TempDir, Path.Combine(releasePath, releaseName + "_extracted.lha")) is error e6)
            return Fail("Failed to create extracted releases: " + e6.Message);
        return 0;
    }

    string AmberPath(string name)
    {
        return Path.Combine("Amberfiles", name);
    }

    List<AdfEntry> Amberfiles(ReadOnlySlice<string> names)
    {
        var list = List<AdfEntry>.Create();
        AddAmberfiles(ref list, names);
        return list;
    }

    void AddAmberfiles(ref List<AdfEntry> list, ReadOnlySlice<string> names)
    {
        foreach (var name in names)
            list.Add(AdfEntry { Path = AmberPath(name), Target = "" });
    }

    // AllFilesIn of the original: the files below a folder of the temporary directory, in the folder `target` of the
    // disk, with the folders below `folder` (keepHierarchy) or all directly in it
    void AddAllFilesIn(ref List<AdfEntry> list, string folder, string target, bool keepHierarchy)
    {
        foreach (var file in GetFilesWindows(Path.Combine(TempDir, folder)))
        {
            string relative = RelativeKey(file, TempDir);
            string inFolder = relative[(RelativeKey(Path.Combine(TempDir, folder), TempDir).Length + 1)..].ToString();
            int slash = inFolder.LastIndexOf('/');
            string localDirectory = slash < 0 ? "" : inFolder[0..slash].ToString();
            string targetDirectory = keepHierarchy ? (target.Length == 0 ? localDirectory : localDirectory.Length == 0 ? target : target + "/" + localDirectory) : target;
            list.Add(AdfEntry { Path = relative, Target = targetDirectory });
        }
    }

    bool CreateADF(string directory, char letter, List<AdfEntry> entries)
    {
        var files = List<AdfFile>.Create();
        var targets = HashSet<string>.Create();
        foreach (var entry in entries)
        {
            string fileName = Path.GetFileName(entry.Path);
            string target = entry.Target.Length == 0 ? fileName : entry.Target.Replace("\\", "/").TrimEnd('/').ToString() + "/" + fileName;
            var read = File.ReadAllBytes(Path.Combine(TempDir, entry.Path));
            if (read is not uint8[] data)
                return Failed("Could not find file '" + Path.Combine(TempDir, entry.Path) + "'.");
            if (!targets.Add(target))
                return Failed("The file '" + target + "' is twice on disk " + letter.ToString() + ".");
            files.Add(AdfFile { Path = target, Data = data });
        }
        var config = AdfConfiguration { FileSystem = FileSystem.OFS, Bootable = letter == 'A' };
        var image = new uint8[0];
        string name = "AMBER_" + letter.ToString();
        var result = WriteAdf(files, name, config, Now, ref image);
        if (result != ADFWriteResult.Success)
            return Failed("The files of disk " + letter.ToString() + " do not fit on the disk."); // (the original writes an empty file)
        if (File.WriteAllBytes(Path.Combine(directory, name + ".adf"), image) is error e)
            return Failed(e.Message);
        return true;
    }

    bool PatchBootDiskFiles(string sourceDir)
    {
        // the texts of raminstall in the languages; other languages are not supported (the original ends with an
        // exception)
        const ReadOnlySlice<string> english = ["Do you want to copy some files to the RAM disk?", "Installing 7 disks to RAM...",
            "Remove all disks now ! Except Amber_A, Amber_B and Amber_J (Put them in)", "Ready.", "Running now..."];
        const ReadOnlySlice<string> german = ["Moechten Sie Dateien in die RAM Disk kopieren?", "Installiere 7 Disketten in RAM...",
            "Entferne jetzt alle Disketten! Ausser Amber_A, Amber_B und Amber_J (Lege sie ein)", "Fertig.", "Starte jetzt..."];
        const ReadOnlySlice<string> french = ["Voulez vous copier les fichiers sur le disque RAM ?", "Installation de 7 disquettes en RAM...",
            "Retire tous les disques maintenant ! Sauf Amber_A, Amber_B et Amber_J (Mets les)", "Pret.", "Execution maintenant..."];
        const ReadOnlySlice<string> czech = ["Chcete kopirovat soubory na RAM disk ?", "Instaluji 7 disket do RAM...",
            "Odeber vsechny diskety ted ! Krome Amber_A, Amber_B a Amber_J (Vloz je)", "Hotovo.", "Teraz dziala..."];
        const ReadOnlySlice<string> polish = ["Czy skopiowac pliki na RAM dysk ?", "Instalowanie 7 dyskow do RAM...",
            "Usun wszystkie dyski teraz! Z wyjatkiem Amber_A, Amber_B i Amber_J (Wloz je)", "Gotowe.", "Prave bezi..."];
        ReadOnlySlice<string> translated;
        switch (Language)
        {
            case "German": translated = german; break;
            case "French": translated = french; break;
            case "Czech": translated = czech; break;
            case "Polish": translated = polish; break;
            default: return Failed("The boot disk has no texts in " + Language + " (only German, French, Czech and Polish).");
        }
        var raminstall = Path.Combine(sourceDir, "raminstall");
        var content = ReadText(raminstall);
        for (var i = 0; i < english.Length; i += 1)
            content = content.Replace(english[i], translated[i]);
        if (File.WriteAllText(raminstall, content) is error e1)
            return Failed(e1.Message);

        var startup = Path.Combine(Path.Combine(sourceDir, "S"), "startup-original");
        var startupText = ReadText(startup);
        if (Language == "German")
            startupText = startupText.Replace("gb", "d");
        else if (Language == "French")
            startupText = startupText.Replace("gb", "f");
        // (all other languages keep the English keymap, gb)
        if (File.WriteAllText(startup, startupText) is error e2)
            return Failed(e2.Message);
        return true;
    }

    // ------------------------------------------------------------------------------------------------------------------
    // Helpers

    bool Failed(string message)
    {
        Error = message;
        return false;
    }

    // the date and the language, and the version of Text.amb
    bool SetVersionTexts(string languageText)
    {
        var textAmb = Path.Combine(Path.Combine(TempDir, "AllTexts"), "Text.amb");
        if (File.WriteAllText(Path.Combine(Path.Combine(textAmb, "DateAndLanguageString"), "000.txt"), FormatDate(Now) + " / " + languageText) is error e1)
            return Failed(e1.Message);
        if (File.WriteAllText(Path.Combine(Path.Combine(textAmb, "VersionString"), "000.txt"), "Ambermoon v" + Version) is error e2)
            return Failed(e2.Message);
        Directory.Create(Path.Combine(Path.Combine(TempDir, "AllTexts"), "1Map_data.amb"));
        return true;
    }

    // File.ReadAllLines and WriteAllLines of .NET with a new first line
    bool SetFirstLine(string path, string line)
    {
        if (ReadAllTextNet(path) is not string text)
            return Failed("Could not find file '" + path + "'.");
        var lines = SplitLinesNet(text);
        if (lines.Count() == 0)
            return Failed("The file '" + path + "' is empty.");
        lines[0] = line;
        string newLine = Process.IsWindows() ? "\r\n" : "\n";
        var sb = StringBuilder.Create();
        foreach (var l in lines)
        {
            sb.Append(l);
            sb.Append(newLine);
        }
        if (File.WriteAllText(path, sb.ToString()) is error e)
            return Failed(e.Message);
        return true;
    }

    string ReadText(string path)
    {
        return ReadAllTextNet(path) is string text ? text : "";
    }

    string LocalPath(string path)
    {
        if (ToLowerNet(path).StartsWith(ToLowerNet(TempDir)))
            return path[(TempDir.Length + 1)..].ToString();
        return path;
    }

    bool CopyAndTrackDir(string source, string dest)
    {
        Console.WriteLine("Copying directory from '" + source + "' to '" + LocalPath(dest) + "'");
        if (!CopyDirectory(source, dest, true, HashSet<string>.Create(), HashSet<string>.Create(), false))
            return false;
        TempDirs.Add(dest);
        return true;
    }

    bool CopyAndTrackFile(string source, string dest, bool noTrack)
    {
        Console.WriteLine("Copying file from '" + source + "' to '" + LocalPath(dest) + "'");
        if (!CopyFile(source, dest))
            return false;
        if (!noTrack)
            TempFiles.Add(dest);
        return true;
    }

    bool CopyFiles(string sourceDir, string destDir, ReadOnlySlice<string> files)
    {
        foreach (var file in files)
        {
            string source = Path.Combine(sourceDir, file);
            string dest = Path.Combine(destDir, file);
            Console.WriteLine("Copying file from '" + source + "' to '" + LocalPath(dest) + "'");
            if (!CopyFile(source, dest))
                return false;
        }
        return true;
    }

    // File.Copy of .NET on Windows: the copy keeps the time of the last write
    bool CopyFile(string source, string dest)
    {
        var read = File.ReadAllBytes(source);
        if (read is not uint8[] data)
            return Failed("Could not find file '" + source + "'.");
        string parent = Path.GetDirectory(dest);
        if (parent.Length > 0 && !Directory.Exists(parent))
            return Failed("Could not find a part of the path '" + dest + "'.");
        if (File.WriteAllBytes(dest, data) is error e)
            return Failed(e.Message);
        if (File.GetLastWriteTimeUtc(source) is DateTime time)
            File.SetLastWriteTimeUtc(dest, time);
        return true;
    }

    void DeleteFile(string path)
    {
        if (IsFile(path))
            File.Delete(path);
    }

    // CopyDirectory of the original; with `filter` only the files and directories that are in the sets (relative to
    // the temporary directory, '/' between directories)
    bool CopyDirectory(string sourceDir, string targetDir, bool recursive, HashSet<string> allowedFiles, HashSet<string> allowedDirectories, bool filter)
    {
        if (!Directory.Exists(sourceDir))
            return Failed("Source directory '" + sourceDir + "' does not exist.");
        if (!filter || allowedDirectories.Contains(RelativeKey(targetDir, TempDir)))
            Directory.Create(targetDir);
        foreach (var entry in Directory.GetEntries(sourceDir))
        {
            var source = Path.Combine(sourceDir, entry);
            if (Directory.Exists(source))
                continue;
            var target = Path.Combine(targetDir, entry);
            if (!filter || allowedFiles.Contains(RelativeKey(target, TempDir)))
            {
                if (!CopyFile(source, target))
                    return false;
            }
        }
        if (recursive)
        {
            foreach (var entry in Directory.GetEntries(sourceDir))
            {
                var source = Path.Combine(sourceDir, entry);
                if (!Directory.Exists(source))
                    continue;
                var target = Path.Combine(targetDir, entry);
                if (!filter || allowedDirectories.Contains(RelativeKey(target, TempDir)))
                {
                    if (!CopyDirectory(source, target, true, allowedFiles, allowedDirectories, filter))
                        return false;
                }
            }
        }
        return true;
    }

    // Runs a tool (the CShift port or the original) in the temporary directory; a failure is reported, but the release
    // goes on (as in the original)
    void Exec(string tool, string arguments)
    {
        string exe = Process.IsWindows() ? tool + ".exe" : tool;
        string command = exe;
        if (Process.GetEnv("AMBERMOON_TOOLS") is string toolsDir && toolsDir.Length > 0)
            command = Path.Combine(toolsDir, exe);
        Console.WriteLine();
        Console.WriteLine("Executing: " + exe + " " + arguments);
        Report(exe, RunIn(TempDir, "\"" + command + "\" " + arguments));
    }

    void ExecCommand(string command, string arguments)
    {
        Console.WriteLine();
        Console.WriteLine("Executing: " + command + " " + arguments);
        Report(command, RunIn(TempDir, command + " " + arguments));
    }

    void Report(string command, int exitCode)
    {
        if (exitCode != 0)
            Console.WriteErrorLine("Process '" + command + "' failed with exit code " + exitCode.ToString() + ".");
    }
}

struct AdfEntry
{
    string Path;      // relative to the temporary directory, '/' between directories
    string Target;    // the directory on the disk ("" for the root)
}

// Runs a command line in a directory.
int RunIn(string directory, string commandLine)
{
    if (Process.IsWindows())
        return Process.Run("cd /d \"" + directory + "\" && " + commandLine);
    return Process.Run("cd '" + directory.Replace("'", "'\\''") + "' && " + commandLine);
}

// A path relative to a directory, with '/' between directories.
string RelativeKey(string path, string root)
{
    string p = path.Replace("\\", "/");
    string r = root.Replace("\\", "/").TrimEnd('/').ToString();
    if (p.StartsWith(r + "/"))
        return p[(r.Length + 1)..].ToString();
    return p;
}

// dd-MM-yyyy
string FormatDate(DateTime time)
{
    return time.Day().ToString("D2") + "-" + time.Month().ToString("D2") + "-" + time.Year().ToString("D4");
}

// Path.GetTempPath of .NET
string TempPath()
{
    if (Process.IsWindows())
    {
        foreach (var name in ["TMP", "TEMP", "USERPROFILE"])
        {
            if (Process.GetEnv(name) is string value && value.Length > 0)
                return value;
        }
        return "C:\\Windows\\Temp";
    }
    if (Process.GetEnv("TMPDIR") is string tmp && tmp.Length > 0)
        return tmp;
    return "/tmp";
}

// Guid.NewGuid().ToString() (version 4, random)
string NewGuid()
{
    var random = Random.Create();
    const string hex = "0123456789abcdef";
    var sb = StringBuilder.Create();
    for (var i = 0; i < 32; i += 1)
    {
        if (i == 8 || i == 12 || i == 16 || i == 20)
            sb.Append("-");
        int digit = random.Next(16);
        if (i == 12)
            digit = 4;
        else if (i == 16)
            digit = 8 + (digit & 3);
        sb.Append(hex[digit]);
    }
    return sb.ToString();
}
