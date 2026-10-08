namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;

/// Writes the texts of a text file (map texts, NPC texts, ...): their number, their lengths (words) and the texts.
struct TextWriter
{
    /// Writes the texts, without spaces (`trimSpaces`) and 0s (`trimZeros`) at both ends. Texts of the Amiga data
    /// (`amigaData`) start with a space and end with " \0 ", other texts end with a 0. As in the original the ends
    /// are checked like .NET's culture-aware StartsWith and EndsWith: a text that ends with two spaces counts as one
    /// that ends with " \0 " (and gets only a 0).
    static void WriteTexts(ref DataWriter writer, List<string> texts, bool trimSpaces, bool trimZeros, bool amigaData)
    {
        writer.WriteWord((uint16)texts.Count());

        var processedTexts = List<string>.Create(texts.Count());

        foreach (var original in texts)
        {
            string text = TrimCharacters(original, trimSpaces, trimZeros);

            if (amigaData && !StartsWithNet(text, " "))
                text = " " + text;

            if (amigaData && !EndsWithNet(text, " \0 "))
                text += " \0 ";
            else if (text.IndexOf('\0') < 0)
                text += "\0";

            processedTexts.Add(text);
        }

        foreach (var text in processedTexts)
            writer.WriteWord((uint16)(LengthNet(text) & 0xffff));

        foreach (var text in processedTexts)
            writer.WriteBytes(AmbermoonEncoding.GetBytes(text));
    }
}
