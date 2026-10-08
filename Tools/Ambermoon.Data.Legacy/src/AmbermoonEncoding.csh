namespace Ambermoon.Data.Legacy;

using System;
using Ambermoon;

/// The encoding of the texts of the game: ISO-8859-1 with some characters at other bytes (see
/// https://gitlab.com/ambermoon/research/-/wikis/font). Strings in memory are UTF-8.
struct AmbermoonEncoding
{
    /// The text of bytes: one character per byte.
    static string GetString(ReadOnlySlice<uint8> bytes)
    {
        var output = new uint8[bytes.Length * 2];
        int o = 0;
        foreach (var b in bytes)
            o = _PutLatin1(output, o, _CharOf(b));
        return string.FromBytes(output, 0, o);
    }

    /// The bytes of a text: one byte per character (UTF-16 character as in .NET: a character outside of the BMP is two
    /// '?'); other characters become their best fit of .NET's ISO-8859-1 (— is '-', “ is '"', Ā is 'A', ...) or '?'.
    static uint8[] GetBytes(StringSlice text)
    {
        var output = new uint8[text.Length];
        int o = 0;
        int i = 0;
        while (i < text.Length)
        {
            int length = _Utf8Length(text[i]);
            int codePoint = _Decode(text, i, length);
            i += length;
            if (codePoint > 0xFFFF)
            {
                output[o] = (uint8)'?';
                o += 1;
                output[o] = (uint8)'?';
            }
            else
                output[o] = _ByteOf(codePoint);
            o += 1;
        }
        return output[0..o].ToArray();
    }

    /// The character (code point) of a byte.
    static int _CharOf(uint8 b)
    {
        switch (b)
        {
            case 0x81: return 0xfc; // ü
            case 0x82: return 0xe9; // é
            case 0x83: return 0xe2; // â
            case 0x84: return 0xe4; // ä
            case 0x85: return 0xe0; // à
            case 0x87: return 0xe7; // ç
            case 0x88: return 0xea; // ê
            case 0x8a: return 0xe8; // è
            case 0x8e: return 0xc4; // Ä
            case 0x90: return 0xc9; // É
            case 0x94: return 0xf6; // ö
            case 0x96: return 0xfb; // û
            case 0x99: return 0xd6; // Ö
            case 0x9a: return 0xdc; // Ü
            case 0x9b: return 0xa2; // ¢
            case 0x9e: return 0xdf; // ß
            case 0xa0: return 0xe1; // á
            case 0xb6: return 0xc0; // À
            case 0xb4: return '\''; // ´ -> '
            default: return b;
        }
    }

    /// The byte of a character (code point).
    static uint8 _ByteOf(int codePoint)
    {
        switch (codePoint)
        {
            case 0xfc: return 0x81; // ü
            case 0xe9: return 0x82; // é
            case 0xe2: return 0x83; // â
            case 0xe4: return 0x84; // ä
            case 0xe0: return 0x85; // à
            case 0xe7: return 0x87; // ç
            case 0xea: return 0x88; // ê
            case 0xe8: return 0x8a; // è
            case 0xc4: return 0x8e; // Ä
            case 0xc9: return 0x90; // É
            case 0xf6: return 0x94; // ö
            case 0xfb: return 0x96; // û
            case 0xd6: return 0x99; // Ö
            case 0xdc: return 0x9a; // Ü
            case 0xa2: return 0x9b; // ¢
            case 0xdf: return 0x9e; // ß
            case 0xe1: return 0xa0; // á
            case 0xc0: return 0xb6; // À
            default: return codePoint <= 0xff ? (uint8)codePoint : Latin1BestFit(codePoint);
        }
    }
}

// writes a code point below 0x100 as UTF-8
int _PutLatin1(uint8[] output, int o, int codePoint)
{
    if (codePoint < 0x80)
    {
        output[o] = (uint8)codePoint;
        return o + 1;
    }
    output[o] = (uint8)(0xC0 | (codePoint >> 6));
    output[o + 1] = (uint8)(0x80 | (codePoint & 0x3F));
    return o + 2;
}

int _Utf8Length(uint8 b)
{
    return b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
}

int _Decode(StringSlice text, int i, int length)
{
    if (i + length > text.Length)
        return 0xFFFD;
    int b = text[i];
    if (length == 1)
        return b;
    int value = b & (0xFF >> (length + 1));
    for (var k = 1; k < length; k += 1)
        value = (value << 6) | (text[i + k] & 0x3F);
    return value;
}

/// ISO-8859-1 (Latin-1): one character per byte, the strings of Amiga executables and file systems.
struct Latin1Encoding
{
    static string GetString(ReadOnlySlice<uint8> bytes)
    {
        var output = new uint8[bytes.Length * 2];
        int o = 0;
        foreach (var b in bytes)
            o = _PutLatin1(output, o, b);
        return string.FromBytes(output, 0, o);
    }

    static uint8[] GetBytes(StringSlice text)
    {
        var output = new uint8[text.Length];
        int o = 0;
        int i = 0;
        while (i < text.Length)
        {
            int length = _Utf8Length(text[i]);
            int codePoint = _Decode(text, i, length);
            i += length;
            if (codePoint > 0xFFFF)
            {
                output[o] = (uint8)'?';
                o += 1;
                output[o] = (uint8)'?';
            }
            else
                output[o] = codePoint <= 0xff ? (uint8)codePoint : Latin1BestFit(codePoint);
            o += 1;
        }
        return output[0..o].ToArray();
    }
}

/// The encodings of the texts in the data: [AmbermoonEncoding] (the texts of the game), ISO-8859-1 (Amiga
/// executables and file systems) and UTF-8 (the files of the remake).
enum TextEncoding : uint8
{
    Ambermoon,
    Latin1,
    Utf8
}

/// The text of bytes in an encoding (invalid UTF-8 becomes U+FFFD).
string DecodeText(ReadOnlySlice<uint8> bytes, TextEncoding encoding)
{
    switch (encoding)
    {
        case TextEncoding.Latin1:
            return Latin1Encoding.GetString(bytes);
        case TextEncoding.Utf8:
            return DecodeTextNet(bytes.ToArray());
        default:
            return AmbermoonEncoding.GetString(bytes);
    }
}

/// The bytes of a text in an encoding.
uint8[] EncodeText(StringSlice text, TextEncoding encoding)
{
    switch (encoding)
    {
        case TextEncoding.Latin1:
            return Latin1Encoding.GetBytes(text);
        case TextEncoding.Utf8:
            return text.AsBytes().ToArray();
        default:
            return AmbermoonEncoding.GetBytes(text);
    }
}
