namespace Ambermoon;

using System;

/// Whether a code point is white space for .NET (`char.IsWhiteSpace`): tab to carriage return, space, U+0085, U+00A0,
/// U+1680, U+2000 to U+200A, U+2028, U+2029, U+202F, U+205F and U+3000.
bool IsWhiteSpaceNet(int codePoint)
{
    return codePoint == ' ' || (codePoint >= '\t' && codePoint <= '\r') || codePoint == 0x85 || codePoint == 0xA0 ||
           codePoint == 0x1680 || (codePoint >= 0x2000 && codePoint <= 0x200A) || codePoint == 0x2028 ||
           codePoint == 0x2029 || codePoint == 0x202F || codePoint == 0x205F || codePoint == 0x3000;
}

/// `text.Trim()` of .NET: without the white space ([IsWhiteSpaceNet]) at the start and the end.
StringSlice TrimNet(StringSlice text)
{
    int start = 0;
    while (start < text.Length)
    {
        int length = _CodePointLength(text, start);
        if (!IsWhiteSpaceNet(_CodePointAt(text, start, length)))
            break;
        start += length;
    }
    int end = text.Length;
    while (end > start)
    {
        // the start of the last character
        int first = end - 1;
        while (first > start && (text[first] & 0xC0) == 0x80)
            first -= 1;
        if (!IsWhiteSpaceNet(_CodePointAt(text, first, end - first)))
            break;
        end = first;
    }
    return text[start..end];
}

/// `text.TrimStart()` of .NET: without the white space ([IsWhiteSpaceNet]) at the start.
StringSlice TrimStartNet(StringSlice text)
{
    int start = 0;
    while (start < text.Length)
    {
        int length = _CodePointLength(text, start);
        if (!IsWhiteSpaceNet(_CodePointAt(text, start, length)))
            break;
        start += length;
    }
    return text[start..];
}

/// `text.TrimEnd()` of .NET: without the white space ([IsWhiteSpaceNet]) at the end.
StringSlice TrimEndNet(StringSlice text)
{
    int end = text.Length;
    while (end > 0)
    {
        // the start of the last character
        int first = end - 1;
        while (first > 0 && (text[first] & 0xC0) == 0x80)
            first -= 1;
        if (!IsWhiteSpaceNet(_CodePointAt(text, first, end - first)))
            break;
        end = first;
    }
    return text[0..end];
}

/// Whether the text is empty or only white space (`string.IsNullOrWhiteSpace` of .NET).
bool IsWhiteSpaceOnlyNet(StringSlice text)
{
    return TrimNet(text).Length == 0;
}

// the number of bytes of the UTF-8 character at 'i'
int _CodePointLength(StringSlice text, int i)
{
    int b = text[i];
    int length = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
    return i + length <= text.Length ? length : text.Length - i;
}

// the code point of the UTF-8 character of 'length' bytes at 'i'
int _CodePointAt(StringSlice text, int i, int length)
{
    int b = text[i];
    if (length == 1)
        return b;
    int value = b & (0xFF >> (length + 1));
    for (var k = 1; k < length; k += 1)
        value = (value << 6) | (text[i + k] & 0x3F);
    return value;
}

/// The lines of a text like `File.ReadAllLines` of .NET: split at "\r\n", "\n" and "\r"; a line break at the end does
/// not start another line.
List<string> SplitLinesNet(StringSlice text)
{
    var lines = List<string>.Create();
    int start = 0;
    int i = 0;
    while (i < text.Length)
    {
        if (text[i] == '\n' || text[i] == '\r')
        {
            lines.Add(text[start..i].ToString());
            if (text[i] == '\r' && i + 1 < text.Length && text[i + 1] == '\n')
                i += 1;
            i += 1;
            start = i;
        }
        else
            i += 1;
    }
    if (start < text.Length)
        lines.Add(text[start..].ToString());
    return lines;
}

/// `text.ToLower()` of .NET for the letters of European languages: ASCII, Latin-1 and Latin Extended-A (Czech,
/// Polish, French, German, ...); other characters stay as they are.
string ToLowerNet(StringSlice text)
{
    return _MapCase(text, true);
}

/// `text.ToUpper()` of .NET for the letters of European languages (see [ToLowerNet]).
string ToUpperNet(StringSlice text)
{
    return _MapCase(text, false);
}

/// The lower case letter of a code point (see [ToLowerNet]).
int ToLowerCodePoint(int c)
{
    if ((c >= 'A' && c <= 'Z') || (c >= 0xC0 && c <= 0xDE && c != 0xD7))
        return c + 32;
    if (c == 0x178)
        return 0xFF;
    if ((c >= 0x100 && c <= 0x137 && c != 0x130) || (c >= 0x14A && c <= 0x177))
        return c | 1;
    if ((c >= 0x139 && c <= 0x148) || (c >= 0x179 && c <= 0x17E))
        return (c & 1) == 1 ? c + 1 : c;
    return c;
}

/// The upper case letter of a code point (see [ToLowerNet]).
int ToUpperCodePoint(int c)
{
    if ((c >= 'a' && c <= 'z') || (c >= 0xE0 && c <= 0xFE && c != 0xF7))
        return c - 32;
    if (c == 0xFF)
        return 0x178;
    if (c == 0xB5)
        return 0x39C;
    if ((c >= 0x100 && c <= 0x137 && c != 0x131) || (c >= 0x14A && c <= 0x177))
        return c & ~1;
    if ((c >= 0x139 && c <= 0x148) || (c >= 0x179 && c <= 0x17E))
        return (c & 1) == 0 ? c - 1 : c;
    return c;
}

string _MapCase(StringSlice text, bool lower)
{
    var output = new uint8[text.Length + 8];
    int o = 0;
    int i = 0;
    while (i < text.Length)
    {
        int length = _CodePointLength(text, i);
        int c = _CodePointAt(text, i, length);
        int mapped = lower ? ToLowerCodePoint(c) : ToUpperCodePoint(c);
        if (mapped == c || length > 2)
        {
            for (var k = 0; k < length; k += 1)
                output[o + k] = text[i + k];
            o += length;
        }
        else
        {
            // ASCII and the Latin letters above take 1 or 2 bytes, as do their counterparts
            if (mapped < 0x80)
            {
                output[o] = (uint8)mapped;
                o += 1;
            }
            else
            {
                output[o] = (uint8)(0xC0 | (mapped >> 6));
                output[o + 1] = (uint8)(0x80 | (mapped & 0x3F));
                o += 2;
            }
        }
        i += length;
    }
    return string.FromBytes(output, 0, o);
}

/// Whether ICU (which .NET uses for culture-aware comparisons on Linux) ignores the character completely: control
/// characters other than tab and line breaks, the soft hyphen, zero-width and direction marks, the byte order mark,
/// variation selectors and tags.
bool IsIgnorableNet(int c)
{
    return (c >= 0 && c <= 0x08) || (c >= 0x0E && c <= 0x1F) || (c >= 0x7F && c <= 0x9F) || c == 0xAD ||
           c == 0x34F || c == 0x61C || c == 0x180E || (c >= 0x200B && c <= 0x200F) || (c >= 0x202A && c <= 0x202E) ||
           (c >= 0x2060 && c <= 0x206F) || (c >= 0xFE00 && c <= 0xFE0F) || c == 0xFEFF || (c >= 0xFFF9 && c <= 0xFFFB) ||
           (c >= 0xE0000 && c <= 0xE0FFF);
}

/// The text without the characters that culture-aware comparisons ignore (see [IsIgnorableNet]).
string WithoutIgnorableNet(StringSlice text)
{
    var result = StringBuilder.Create();
    int i = 0;
    while (i < text.Length)
    {
        int length = _CodePointLength(text, i);
        if (!IsIgnorableNet(_CodePointAt(text, i, length)))
            result.Append(text[i..i + length]);
        i += length;
    }
    return result.ToString();
}

/// `text.EndsWith(value)` of .NET (culture-aware: characters that ICU ignores do not count, so `"a  "` ends with
/// `" \0 "`).
bool EndsWithNet(StringSlice text, StringSlice value)
{
    return WithoutIgnorableNet(text).EndsWith(WithoutIgnorableNet(value));
}

/// `text.StartsWith(value)` of .NET (culture-aware, see [EndsWithNet]).
bool StartsWithNet(StringSlice text, StringSlice value)
{
    return WithoutIgnorableNet(text).StartsWith(WithoutIgnorableNet(value));
}

/// `string.Compare(a, b) == 0` of .NET (culture-aware, see [EndsWithNet]).
bool EqualsNet(StringSlice a, StringSlice b)
{
    return WithoutIgnorableNet(a) == WithoutIgnorableNet(b);
}

/// The length of the text in UTF-16 characters (`text.Length` of .NET).
int LengthNet(StringSlice text)
{
    int count = 0;
    int i = 0;
    while (i < text.Length)
    {
        int length = _CodePointLength(text, i);
        count += length == 4 ? 2 : 1;
        i += length;
    }
    return count;
}

/// The first `count` UTF-16 characters of the text (all of it if it is shorter; a character outside of the BMP that
/// would be split is left out).
StringSlice FirstCharactersNet(StringSlice text, int count)
{
    int i = 0;
    while (i < text.Length && count > 0)
    {
        int length = _CodePointLength(text, i);
        int units = length == 4 ? 2 : 1;
        if (units > count)
            break;
        count -= units;
        i += length;
    }
    return text[0..i];
}
