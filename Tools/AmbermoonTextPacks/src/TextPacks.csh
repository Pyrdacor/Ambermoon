//! The text packs of the remake: Intro_texts.amb and Extro_texts.amb, made from folders of text files. Shared by
//! AmbermoonIntroTextPacker, AmbermoonExtroTextPacker and AmbermoonExtroIntroTextPackCreator (in the original these
//! are in the two packers, and the creator builds and runs them).
namespace AmbermoonTextPacks;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy.Serialization;

/// The texts of the intro: texts shown on their own, and the texts of commands (a command has one or more texts).
struct IntroTexts
{
    List<string> Texts;
    List<List<string>> CommandTexts;

    static IntroTexts Create()
    {
        return IntroTexts { Texts = List<string>.Create(), CommandTexts = List<List<string>>.Create() };
    }
}

/// The number of click groups of the extro.
const int ExtroClickGroupCount = 6;

/// The texts of the extro: for each of the 6 click groups its groups of texts.
struct ExtroTexts
{
    List<List<string>>[] ClickGroups;

    static ExtroTexts Create()
    {
        var groups = new List<List<string>>[ExtroClickGroupCount];
        for (var i = 0; i < ExtroClickGroupCount; i += 1)
            groups[i] = List<List<string>>.Create();
        return ExtroTexts { ClickGroups = groups };
    }
}

// a file of the intro texts: its number, its sub-number (if it has one) and its path
struct _IntroFile : IComparable<_IntroFile>
{
    int Number;
    int SubNumber;
    bool IsCommandText;
    string Path;

    int CompareTo(_IntroFile other)
    {
        return Number != other.Number ? Number.CompareTo(other.Number) : SubNumber.CompareTo(other.SubNumber);
    }
}

// int.Parse of the 3 characters from 'start' on of 'text', a part of the name of a file or folder (the original ends
// with an exception when they are missing or no number)
Error<int> _NumberInName(string text, int start, string what, string name)
{
    if (text.Length >= start + 3 && ParseInt(text[start..start + 3]) is int number)
        return number;
    string where = start == 0 ? "start with a number" : "have a number after the first '.'";
    return error($"The name of the {what} '{name}' does not {where} (3 digits).");
}

/// Reads the intro texts from a folder: `000.txt`, `001.txt`, ... are texts, `012.000.txt`, `012.001.txt`, ... the
/// texts of commands (`.000` starts a command).
/// @error a file name does not start with a number (the original ends with an exception), a file cannot be read.
Error<IntroTexts> ReadIntroTexts(string path)
{
    var files = List<_IntroFile>.Create();
    foreach (var file in GetFiles(path))
    {
        var name = Path.GetFileName(file);
        var stem = _WithoutExtension(name);
        int number = try _NumberInName(name, 0, "file", name);
        int subNumber = 0;
        bool isCommandText = stem.Contains(".");
        if (isCommandText)
            subNumber = try _NumberInName(stem, 4, "file", name);
        files.Add(_IntroFile { Number = number, SubNumber = subNumber, IsCommandText = isCommandText, Path = file });
    }
    files.Sort();

    var texts = IntroTexts.Create();
    var current = List<string>.Create();
    foreach (var file in files)
    {
        if (ReadAllTextNet(file.Path) is not string text)
            return error($"Cannot read the file '{file.Path}'.");

        if (file.IsCommandText)
        {
            if (file.SubNumber == 0 && current.Count() != 0) // a new command
            {
                texts.CommandTexts.Add(current);
                current = List<string>.Create();
            }
            current.Add(text);
        }
        else
            texts.Texts.Add(text);
    }
    if (current.Count() != 0)
        texts.CommandTexts.Add(current);
    return texts;
}

// Path.GetFileNameWithoutExtension of .NET: without the last '.' and what follows it
string _WithoutExtension(string name)
{
    int dot = name.LastIndexOf('.');
    return dot < 0 ? name : name[0..dot].ToString();
}

/// The bytes of Intro_texts.amb: the number of texts (a byte) and the texts, then the number of commands and for
/// each command the number of its texts and the texts (UTF-8, each ending with a 0).
uint8[] PackIntroTexts(IntroTexts texts)
{
    var writer = new DataWriter();
    writer.WriteByte((uint8)texts.Texts.Count());
    foreach (var text in texts.Texts)
        _WriteNullTerminated(ref writer, text);

    writer.WriteByte((uint8)texts.CommandTexts.Count());
    foreach (var command in texts.CommandTexts)
    {
        writer.WriteByte((uint8)command.Count());
        foreach (var text in command)
            _WriteNullTerminated(ref writer, text);
    }
    return writer.ToArray();
}

void _WriteNullTerminated(ref DataWriter writer, string text)
{
    writer.WriteBytes(text.AsBytes());
    writer.WriteByte(0);
}

// a folder or file whose name starts with a number
struct _Numbered : IComparable<_Numbered>
{
    int Number;
    string Path;

    int CompareTo(_Numbered other)
    {
        return Number.CompareTo(other.Number);
    }
}

// the entries sorted by the numbers their names start with (stable, like OrderBy); with 'skipOthers' the entries
// without such a number are left out, else they are an error
Error<List<_Numbered>> _SortByNumber(List<string> paths, bool skipOthers, string what)
{
    var result = List<_Numbered>.Create();
    foreach (var path in paths)
    {
        var name = Path.GetFileName(path);
        if (skipOthers && name.Length >= 3 && ParseInt(name[0..3]) is null)
            continue;
        int number = try _NumberInName(name, 0, what, name);
        result.Add(_Numbered { Number = number, Path = path });
    }
    result.Sort();
    return result;
}

/// Reads the extro texts from a folder: up to 6 folders `000`, `001`, ... (the click groups; other names are left
/// out), in each folders of groups (`000`, `001`, ...) and in these the texts (`000.txt`, `001.txt`, ...).
/// @error more than 6 click groups, a folder or file name does not start with a number (the original ends with an
/// exception for these), a file cannot be read.
Error<ExtroTexts> ReadExtroTexts(string path)
{
    var texts = ExtroTexts.Create();
    var clickGroups = try _SortByNumber(GetDirectories(path), true, "folder");
    if (clickGroups.Count() > ExtroClickGroupCount)
        return error($"There are more than {ExtroClickGroupCount} click groups in '{path}'.");

    for (var c = 0; c < clickGroups.Count(); c += 1)
    {
        var groups = try _SortByNumber(GetDirectories(clickGroups[c].Path), false, "folder");
        foreach (var group in groups)
        {
            var groupTexts = List<string>.Create();
            var files = try _SortByNumber(GetFiles(group.Path), false, "file");
            foreach (var file in files)
            {
                if (ReadAllTextNet(file.Path) is not string text)
                    return error($"Cannot read the file '{file.Path}'.");
                groupTexts.Add(text);
            }
            texts.ClickGroups[c].Add(groupTexts);
        }
    }
    return texts;
}

/// The bytes of Extro_texts.amb: the number of click groups (6) and the number of groups of each (words); for each
/// click group the number of texts of its groups (words) and the texts (UTF-8, each ending with a 0), filled up to an
/// even size; then the number of translators (a word), their names, the click text, filled up to an even size.
uint8[] PackExtroTexts(ExtroTexts texts, ReadOnlySlice<string> translators, string clickText)
{
    var writer = new DataWriter();
    writer.WriteWord(ExtroClickGroupCount);
    foreach (var clickGroup in texts.ClickGroups)
        writer.WriteWord((uint16)clickGroup.Count());

    foreach (var clickGroup in texts.ClickGroups)
    {
        foreach (var group in clickGroup)
            writer.WriteWord((uint16)group.Count());
        foreach (var group in clickGroup)
        {
            foreach (var text in group)
                _WriteNullTerminated(ref writer, text);
        }
        if (writer.Size() % 2 == 1)
            writer.WriteByte(0);
    }

    writer.WriteWord((uint16)translators.Length);
    foreach (var translator in translators)
        _WriteNullTerminated(ref writer, translator);
    _WriteNullTerminated(ref writer, clickText);
    if (writer.Size() % 2 == 1)
        writer.WriteByte(0);
    return writer.ToArray();
}
