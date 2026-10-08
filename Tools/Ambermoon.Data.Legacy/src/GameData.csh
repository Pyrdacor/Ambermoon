namespace Ambermoon.Data.Legacy;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy.Serialization;

/// Where the files of the game are loaded from: extracted files in the folder or the ADF disk images in it.
enum LoadPreference : int32
{
    PreferAdf,
    PreferExtracted,
    ForceAdf,
    ForceExtracted
}

/// The version of the game data and its language, as the data says.
struct GameDataInfo
{
    string Version;
    string Language;
    bool Advanced;
}

/// The data of the game: its files (decrypted and decompressed), loaded from a folder with the extracted files or
/// with the ADF disk images (a port of GameData of Ambermoon.Data.Legacy).
///
/// The original also makes all the parts of the game from the files when it loads them (graphics, maps, songs, the
/// data of the executable, ...). This port only loads the files; the parts are made when they are needed (for
/// example [ExecutableData.FromGameData], [MapManager.Create]).
struct GameData
{
    /// The files by their names ("AM2_CPU", "2Map_data.amb", "Save.00/Party_char.amb", ...).
    Dictionary<string, FileContainer> Files;
    /// The dictionaries (file 1 of Dictionary.<language> or Dict.amb) by their language.
    Dictionary<GameLanguage, DataReader> Dictionaries;
    LoadPreference LoadPreference;
    VersionPreference VersionPreference;
    bool StopAtFirstError;
    bool Loaded;
    GameDataSource GameDataSource;
    string Version;
    GameLanguage Language;
    bool Advanced;
    Dictionary<char, Dictionary<string, uint8[]>> _loadedDisks;

    /// Game data that prefers extracted files and stops at the first error.
    static GameData Create()
    {
        return Create(LoadPreference.PreferExtracted, true, VersionPreference.Any);
    }

    static GameData Create(LoadPreference loadPreference, bool stopAtFirstError)
    {
        return Create(loadPreference, stopAtFirstError, VersionPreference.Any);
    }

    /// Game data that loads with these preferences; with `stopAtFirstError` missing files and damaged data are
    /// errors of [Load], else they are left out.
    static GameData Create(LoadPreference loadPreference, bool stopAtFirstError, VersionPreference versionPreference)
    {
        return GameData
        {
            Files = Dictionary<string, FileContainer>.Create(),
            Dictionaries = Dictionary<GameLanguage, DataReader>.Create(),
            LoadPreference = loadPreference,
            VersionPreference = versionPreference,
            StopAtFirstError = stopAtFirstError,
            GameDataSource = GameDataSource.Memory,
            Version = "Unknown",
            Language = GameLanguage.English,
            _loadedDisks = Dictionary<char, Dictionary<string, uint8[]>>.Create()
        };
    }

    /// The dictionary of the language of the data, or the first one.
    Optional<DataReader> Dictionary()
    {
        if (Dictionaries.TryGet(Language) is DataReader dictionary)
            return dictionary;
        foreach (var entry in Dictionaries.Entries())
            return entry.Value;
        return null;
    }

    /// Loads the files of the game from a folder.
    /// @error (with StopAtFirstError) the folder does not exist, a file of the game is missing, no dictionary;
    /// (always) a file or an ADF image is damaged.
    Error<void> Load(string folderPath)
    {
        return Load(folderPath, false);
    }

    /// Loads the files of the game from a folder; with `savesOnly` only the files of the saved games.
    Error<void> Load(string folderPath, bool savesOnly)
    {
        Loaded = false;
        GameDataSource = GameDataSource.Unknown;

        if (!Directory.Exists(folderPath))
        {
            if (StopAtFirstError)
                return error("Given data folder does not exist.");
            return;
        }

        var files = GameFiles(savesOnly, VersionPreference);
        bool foundNoDictionary = true;
        bool dictAmbLoaded = false;

        foreach (var entry in files.Entries())
        {
            var name = entry.Key;
            var disk = entry.Value;

            // prefer direct files but also allow loading ADF disks
            if (LoadPreference == LoadPreference.PreferExtracted && _FileExists(folderPath, name))
            {
                try _LoadFile(folderPath, name);
                _FileLoaded(name, true, ref foundNoDictionary, ref dictAmbLoaded);
            }
            else if (LoadPreference == LoadPreference.ForceExtracted)
            {
                if (_FileExists(folderPath, name))
                {
                    try _LoadFile(folderPath, name);
                    _FileLoaded(name, true, ref foundNoDictionary, ref dictAmbLoaded);
                }
                else if (VersionPreference != VersionPreference.Pre114 && Renamed114File(name) is string newName &&
                         _FileExists(folderPath, newName))
                    continue; // it is part of the file list anyway
                else
                    try _FileNotFound(name, disk);
            }
            else
            {
                // load from disk
                if (!_loadedDisks.ContainsKey(disk))
                {
                    if (try _LoadDisk(folderPath, disk) is Dictionary<string, uint8[]> loadedDisk)
                        _loadedDisks[disk] = loadedDisk;
                }

                var diskFiles = _loadedDisks.TryGet(disk);
                if (diskFiles is Dictionary<string, uint8[]> found && found.TryGet(name) is uint8[] data)
                {
                    GameDataSource = GameDataSource == GameDataSource.LegacyFiles ? GameDataSource.ADFAndLegacyFiles
                                                                                  : GameDataSource.ADF;
                    Files[name] = try FileReader.ReadRawFile(name, data);
                    _FileLoaded(name, false, ref foundNoDictionary, ref dictAmbLoaded);
                    continue;
                }

                if (VersionPreference != VersionPreference.Pre114 && Renamed114File(name) is string renamed &&
                    diskFiles is Dictionary<string, uint8[]> onDisk && onDisk.ContainsKey(renamed))
                    continue; // it is part of the file list anyway

                // file not found
                if (LoadPreference == LoadPreference.ForceAdf && StopAtFirstError)
                    return error($"Unabled to find ADF disk file with letter '{(char)disk}'. Try to rename your ADF file to 'ambermoon_{(char)disk}.adf'.");

                if (LoadPreference == LoadPreference.PreferAdf)
                {
                    if (!_FileExists(folderPath, name))
                    {
                        if (VersionPreference != VersionPreference.Pre114 && Renamed114File(name) is string newName &&
                            _FileExists(folderPath, newName))
                            continue; // it is part of the file list anyway
                        try _FileNotFound(name, disk);
                    }
                    else
                    {
                        try _LoadFile(folderPath, name);
                        _FileLoaded(name, true, ref foundNoDictionary, ref dictAmbLoaded);
                    }
                }
                else if (LoadPreference == LoadPreference.PreferExtracted)
                {
                    if (VersionPreference != VersionPreference.Pre114 && Renamed114File(name) is string newName &&
                        _FileExists(folderPath, newName))
                        continue; // it is part of the file list anyway
                    try _FileNotFound(name, disk);
                }
            }
        }

        if (savesOnly)
        {
            Loaded = true;
            return;
        }

        if (foundNoDictionary && StopAtFirstError)
            return error("Unable to find any dictionary file.");

        if (!Files.ContainsKey("Travel_gfx.amb") && StopAtFirstError)
            return error("Unable to find travel graphics.");

        // the version and language (errors are ignored as in the original)
        Optional<GameDataInfo> info = null;
        if (_File1("Text.amb") is DataReader text)
            info = GetInfoOfText(text);
        else if (_File1(Files.ContainsKey("AM2_CPU") ? "AM2_CPU" : "AM2_BLIT") is DataReader exe)
            info = GetInfoOfExecutable(exe);

        if (info is GameDataInfo i)
        {
            Version = i.Version;
            Language = ToGameLanguage(i.Language);
            Advanced = i.Advanced;
        }

        if (dictAmbLoaded && Language != GameLanguage.English && Dictionaries.TryGet(GameLanguage.English) is DataReader dict)
        {
            Dictionaries[Language] = dict;
            Dictionaries.Remove(GameLanguage.English);
        }

        // The original makes the data of the executable here and fails without AM2_CPU.
        if (!Files.ContainsKey("AM2_CPU") && StopAtFirstError)
            return error("[Data] Incomplete game data. AM2_CPU is missing.");

        Loaded = true;
        return;
    }

    /// File 1 of a file of the game; null if there is no such file.
    Optional<DataReader> _File1(string name)
    {
        if (Files.TryGet(name) is FileContainer container)
            return container.Files.TryGet(1);
        return null;
    }

    // the path of a file of the game in the folder
    static string _PathOf(string folderPath, string name)
    {
        return Path.Combine(folderPath, name);
    }

    static bool _FileExists(string folderPath, string name)
    {
        return IsFile(_PathOf(folderPath, name));
    }

    Error<void> _LoadFile(string folderPath, string name)
    {
        var path = _PathOf(folderPath, name);
        if (File.ReadAllBytes(path) is not uint8[] data)
            return error($"Could not read file '{path}'.");
        Files[name] = try FileReader.ReadRawFile(name, data);
        return;
    }

    // the files of the game on the ADF image of a disk in the folder; null if there is none
    Error<Optional<Dictionary<string, uint8[]>>> _LoadDisk(string folderPath, char disk)
    {
        if (FindDiskFile(folderPath, disk) is not string diskFile)
            return null;
        if (File.ReadAllBytes(diskFile) is not uint8[] image)
            return error($"Could not read file '{diskFile}'.");
        return try ADFReader.ReadADF(image, VersionPreference);
    }

    void _FileLoaded(string file, bool fromFiles, ref bool foundNoDictionary, ref bool dictAmbLoaded)
    {
        if (fromFiles)
            GameDataSource = GameDataSource == GameDataSource.ADF || GameDataSource == GameDataSource.ADFAndLegacyFiles
                ? GameDataSource.ADFAndLegacyFiles : GameDataSource.LegacyFiles;
        else
            GameDataSource = GameDataSource == GameDataSource.LegacyFiles || GameDataSource == GameDataSource.ADFAndLegacyFiles
                ? GameDataSource.ADFAndLegacyFiles : GameDataSource.ADF;

        if (!IsDictionary(file))
            return;
        if (_File1(file) is not DataReader reader)
            return;

        // (the original ends with an exception when two dictionaries have the same language; this keeps the first)
        GameLanguage language;
        if (ToLowerNet(file) == "dict.amb")
        {
            // the language is replaced later
            language = GameLanguage.English;
            dictAmbLoaded = true;
        }
        else
        {
            var parts = ToLowerNet(file).Split('.');
            language = ToGameLanguage(parts[parts.Length - 1].ToString());
        }
        if (!Dictionaries.ContainsKey(language))
            Dictionaries[language] = reader;
        foundNoDictionary = false;
    }

    Error<void> _FileNotFound(string file, char disk)
    {
        // We only need 1 dictionary, no savegames and only AM2_CPU but not AM2_BLIT.
        if (IsDictionary(file) || disk == 'J' || file == "AM2_BLIT" || file == "Keymap" || file.StartsWith("Initial/"))
            return;

        if (StopAtFirstError)
        {
            if (VersionPreference != VersionPreference.Post114 && IsNew114File(file))
                return;
            return error($"Unable to find file '{file}'.");
        }
        return;
    }

    /// Whether a file is a dictionary ("Dictionary.<language>" or "Dict.amb", in any case).
    static bool IsDictionary(StringSlice file)
    {
        var lower = ToLowerNet(file);
        return lower.StartsWith("dictionary.") || lower == "dict.amb";
    }

    /// The ADF image of a disk in a folder: a file "*.adf" whose name contains "amb" and ends with the letter of the
    /// disk (also as "(a)" or "[a]"), in any case; null if there is none.
    static Optional<string> FindDiskFile(string folderPath, char disk)
    {
        if (!Directory.Exists(folderPath))
            return null;

        var letter = ToLowerNet(((char)disk).ToString());
        bool windows = Process.IsWindows();

        foreach (var adfFile in GetFiles(folderPath))
        {
            // Directory.GetFiles(folder, "*.adf"): the case of the extension matters except on Windows
            var fileName = Path.GetFileName(adfFile);
            if (!(windows ? ToLowerNet(fileName) : fileName).EndsWith(".adf"))
                continue;

            var stem = ToLowerNet(fileName[0..fileName.Length - 4]);
            if (stem.Contains("amb") && (stem.EndsWith(letter) || stem.EndsWith("(" + letter + ")") ||
                                         stem.EndsWith("[" + letter + "]")))
                return adfFile;
        }

        return null;
    }

    /// The version, language and edition (advanced or not) of the game as Text.amb (file 1) says them: the two
    /// strings at its end. null if they cannot be read.
    static Optional<GameDataInfo> GetInfoOfText(DataReader textAmb)
    {
        var info = GameDataInfo { };
        textAmb.Position = textAmb.Size() - 1;

        while (textAmb.Position > 0)
        {
            var b = textAmb.PeekByte();

            if (b == 0 || b >= 0x20)
            {
                textAmb.Position -= 1;
                continue;
            }

            textAmb.Position -= 1;
            int versionStringLength = textAmb.ReadByte() * 4;
            int languageStringLength = textAmb.ReadByte() * 4;
            if (textAmb.Position + versionStringLength + languageStringLength > textAmb.Size())
                return null;
            var versionString = textAmb.ReadString(versionStringLength).TrimEnd('\0').ToString();
            info.Version = _VersionOf(versionString) is string version ? version : "1.0";
            info.Advanced = ToLowerNet(versionString).Contains("adv");
            var languageString = textAmb.ReadString(languageStringLength).TrimEnd('\0').ToString();
            info.Language = _LastWord(languageString);
            return info;
        }

        return info;
    }

    /// The version, language and edition of the game as the executable (AM2_CPU or AM2_BLIT) says them: the strings
    /// at offset 6 of its first code hunk. null if they cannot be read.
    static Optional<GameDataInfo> GetInfoOfExecutable(DataReader exe)
    {
        if (AmigaExecutable.Read(exe) is not List<Hunk> hunks)
            return null;

        foreach (var hunk in hunks)
        {
            if (hunk.Type != HunkType.Code)
                continue;
            var reader = DataReader.FromData(hunk.Data);
            reader.Position = 6;
            string versionString = reader.ReadNullTerminatedString();
            // (the original fails without a version number: nothing is set)
            if (_VersionOf(versionString) is not string version)
                return null;
            var info = GameDataInfo { Version = version, Advanced = ToLowerNet(versionString).Contains("adv") };
            info.Language = _LastWord(reader.ReadNullTerminatedString());
            return info;
        }

        return null;
    }

    // the last match of "[vV]?([0-9]+[.][0-9]+)": the last number with a point in it
    static Optional<string> _VersionOf(StringSlice text)
    {
        Optional<string> last = null;
        int i = 0;
        while (i < text.Length)
        {
            if (!Char.IsDigit(text[i]))
            {
                i += 1;
                continue;
            }
            int start = i;
            while (i < text.Length && Char.IsDigit(text[i]))
                i += 1;
            if (i + 1 < text.Length && text[i] == '.' && Char.IsDigit(text[i + 1]))
            {
                i += 1;
                while (i < text.Length && Char.IsDigit(text[i]))
                    i += 1;
                last = text[start..i].ToString();
            }
        }
        return last;
    }

    // languageString.Trim().Split(' ').Last()
    static string _LastWord(StringSlice text)
    {
        var parts = TrimNet(text).Split(' ');
        return parts[parts.Length - 1].ToString();
    }
}
