namespace Ambermoon.Data.Text.Patching;

using System;
using Ambermoon;
using Ambermoon.Data.Legacy;

// the names of the encodings that .NET knows for the supported code pages (lowercase), and their code pages
const ReadOnlySlice<string> _EncodingAliases =
[
    "437", "cp437", "ibm437", "cspc8codepage437", "cp850", "ibm850", "cp852", "ibm852", "cp866", "ibm866",
    "windows-1250", "x-cp1250", "windows-1251", "x-cp1251", "windows-1252", "x-ansi", "cp1252",
    "iso-8859-1", "latin1", "l1", "cp819", "csisolatin1", "ibm819", "iso_8859-1", "iso_8859-1:1987", "iso-ir-100",
    "iso8859-1", "iso-8859-2", "latin2", "l2", "csisolatin2", "iso_8859-2", "iso_8859-2:1987", "iso-ir-101", "iso8859-2",
    "iso-8859-15", "latin9", "l9", "csisolatin9", "iso_8859-15", "us-ascii", "ascii", "us", "ansi_x3.4-1968",
    "ansi_x3.4-1986", "cp367", "csascii", "ibm367", "iso-ir-6", "iso646-us", "iso_646.irv:1991", "utf-8",
    "unicode-1-1-utf-8", "unicode-2-0-utf-8"
];
const ReadOnlySlice<int> _EncodingAliasCodePages =
[
    437, 437, 437, 437, 850, 850, 852, 852, 866, 866,
    1250, 1250, 1251, 1251, 1252, 1252, 1252,
    28591, 28591, 28591, 28591, 28591, 28591, 28591, 28591, 28591,
    28591, 28592, 28592, 28592, 28592, 28592, 28592, 28592, 28592,
    28605, 28605, 28605, 28605, 28605, 20127, 20127, 20127, 20127,
    20127, 20127, 20127, 20127, 20127, 20127, 20127, 65001,
    65001, 65001
];

/// An encoding of the texts that the patchers write: the encoding of the game ([AmbermoonEncoding]) or an encoding of
/// .NET by its code page or name. Supported are the code pages 437, 850, 852, 866, 1250, 1251, 1252, 28591, 28592,
/// 28605 (with the best-fit replacements of .NET for characters they do not have), 20127 (ASCII) and 65001 (UTF-8).
struct TextPatchEncoding
{
    /// 0: the encoding of the game.
    int CodePage;
    /// The names of .NET (Encoding.WebName, Encoding.EncodingName).
    string WebName;
    string EncodingName;

    /// The encoding of the game.
    static TextPatchEncoding Game()
    {
        return TextPatchEncoding { CodePage = 0, WebName = "", EncodingName = "" };
    }

    /// The encoding of a code page; null if it is not supported.
    static Optional<TextPatchEncoding> FromCodePage(int codePage)
    {
        switch (codePage)
        {
            case 437: return _Create(437, "ibm437", "OEM United States");
            case 850: return _Create(850, "ibm850", "Western European (DOS)");
            case 852: return _Create(852, "ibm852", "Central European (DOS)");
            case 866: return _Create(866, "cp866", "Cyrillic (DOS)");
            case 1250: return _Create(1250, "windows-1250", "Central European (Windows)");
            case 1251: return _Create(1251, "windows-1251", "Cyrillic (Windows)");
            case 1252: return _Create(1252, "windows-1252", "Western European (Windows)");
            case 28591: return _Create(28591, "iso-8859-1", "Western European (ISO)");
            case 28592: return _Create(28592, "iso-8859-2", "Central European (ISO)");
            case 28605: return _Create(28605, "iso-8859-15", "Latin 9 (ISO)");
            case 20127: return _Create(20127, "us-ascii", "US-ASCII");
            case 65001: return _Create(65001, "utf-8", "Unicode (UTF-8)");
            default: return null;
        }
    }

    /// The encoding of a name (as .NET knows it, without regard to case); null if it is not supported.
    static Optional<TextPatchEncoding> FromName(StringSlice name)
    {
        var lower = ToLowerNet(name);
        for (var i = 0; i < _EncodingAliases.Length; i += 1)
        {
            if (_EncodingAliases[i] == lower)
                return FromCodePage(_EncodingAliasCodePages[i]);
        }
        return null;
    }

    static TextPatchEncoding _Create(int codePage, string webName, string encodingName)
    {
        return TextPatchEncoding { CodePage = codePage, WebName = webName, EncodingName = encodingName };
    }

    /// The bytes of a text (a character outside of the BMP is two '?' except in UTF-8).
    uint8[] GetBytes(StringSlice text)
    {
        if (CodePage == 0)
            return AmbermoonEncoding.GetBytes(text);
        if (CodePage == 65001)
            return text.AsBytes().ToArray();

        var output = new uint8[text.Length];
        int o = 0;
        int i = 0;
        while (i < text.Length)
        {
            uint8 b = text[i];
            int length = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
            if (i + length > text.Length)
                length = text.Length - i;
            int c = b;
            if (length > 1)
            {
                c = b & (0xFF >> (length + 1));
                for (var k = 1; k < length; k += 1)
                    c = (c << 6) | (text[i + k] & 0x3F);
            }
            i += length;

            if (c > 0xFFFF)
            {
                output[o] = (uint8)'?';
                output[o + 1] = (uint8)'?';
                o += 2;
                continue;
            }

            if (CodePage == 20127)
                output[o] = c < 0x80 ? (uint8)c : (uint8)'?';
            else if (CodePage == 28591)
                output[o] = c <= 0xFF ? (uint8)c : Latin1BestFit(c);
            else
                output[o] = (uint8)_CodePageByte(CodePage, c);
            o += 1;
        }
        return output[0..o].ToArray();
    }
}
