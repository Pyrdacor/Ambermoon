namespace Ambermoon.Data.Legacy.Serialization;

using System;

/// Reads the texts of a text file (map texts, NPC texts, ...): their number, their lengths (words) and the texts.
struct TextReader
{
    /// The texts without spaces and 0s at both ends, each up to its first 0 (some texts have 0s inside of them).
    static List<string> ReadTexts(DataReader reader)
    {
        var texts = List<string>.Create();
        foreach (var text in ReadTexts(reader, true))
        {
            int zero = text.IndexOf('\0');
            texts.Add(zero >= 0 ? text[0..zero].ToString() : text);
        }
        return texts;
    }

    /// The texts; with `trim` without spaces and 0s at both ends.
    static List<string> ReadTexts(DataReader reader, bool trim)
    {
        var texts = List<string>.Create();

        if (reader.Size() == 0)
            return texts;

        reader.Position = 0;
        int numTexts = reader.ReadWord();
        var lengths = new int[numTexts];

        for (var i = 0; i < numTexts; i += 1)
            lengths[i] = reader.ReadWord();

        for (var i = 0; i < numTexts; i += 1)
        {
            var text = reader.ReadString(lengths[i]);
            texts.Add(trim ? _TrimSpacesAndZeros(text) : text);
        }

        return texts;
    }

    /// The texts, without spaces (`trimSpaces`) and 0s (`trimZeros`) at both ends (`ReadTexts(reader, trimChars)`
    /// of the original).
    /// @error the data ends too early.
    static Error<List<string>> ReadTexts(DataReader reader, bool trimSpaces, bool trimZeros)
    {
        var texts = List<string>.Create();

        if (reader.Size() == 0)
            return texts;

        reader.Position = 0;
        int numTexts = reader.ReadWord();
        var lengths = new int[numTexts];

        for (var i = 0; i < numTexts; i += 1)
            lengths[i] = reader.ReadWord();

        for (var i = 0; i < numTexts; i += 1)
            texts.Add(TrimCharacters(reader.ReadString(lengths[i]), trimSpaces, trimZeros));

        if (reader.Overrun())
            return error("[Data] Invalid text data.");
        return texts;
    }
}

/// `text.Trim(trimChars)` for spaces and 0s.
string TrimCharacters(StringSlice text, bool spaces, bool zeros)
{
    int start = 0;
    int end = text.Length;
    while (start < end && ((spaces && text[start] == ' ') || (zeros && text[start] == 0)))
        start += 1;
    while (end > start && ((spaces && text[end - 1] == ' ') || (zeros && text[end - 1] == 0)))
        end -= 1;
    return text[start..end].ToString();
}

// Trim(' ', '\0')
string _TrimSpacesAndZeros(StringSlice text)
{
    int start = 0;
    int end = text.Length;
    while (start < end && (text[start] == ' ' || text[start] == 0))
        start += 1;
    while (end > start && (text[end - 1] == ' ' || text[end - 1] == 0))
        end -= 1;
    return text[start..end].ToString();
}
