namespace Ambermoon;

using System;

/// `int.TryParse(text)` of .NET: white space around the number, an optional sign, decimal digits; `null` if the text
/// is no int.
Optional<int> ParseInt(StringSlice text)
{
    if (_ParseInteger(text, 2147483648) is not int64 value)
        return null;
    if (value > 2147483647)
        return null;
    return (int)value;
}

/// `uint.TryParse(text)` of .NET: like [ParseInt], for 0 to 4294967295 (`-0` is 0).
Optional<uint32> ParseUInt(StringSlice text)
{
    if (_ParseInteger(text, 4294967295) is not int64 value)
        return null;
    if (value < 0)
        return null;
    return (uint32)value;
}

/// `long.TryParse(text)` of .NET: like [ParseInt], for -9223372036854775808 to 9223372036854775807.
Optional<int64> ParseLong(StringSlice text)
{
    var t = _TrimNetWhiteSpace(text);
    if (t.Length == 0)
        return null;
    bool negative = t[0] == '-';
    int start = t[0] == '+' || negative ? 1 : 0;
    if (start == t.Length)
        return null;
    uint64 limit = negative ? (uint64)9223372036854775807 + 1 : 9223372036854775807;
    uint64 value = 0;
    for (var i = start; i < t.Length; i += 1)
    {
        if (t[i] < '0' || t[i] > '9')
            return null;
        uint64 digit = (uint64)(t[i] - '0');
        if (value > (limit - digit) / 10)
            return null;
        value = value * 10 + digit;
    }
    return negative ? unchecked((int64)(0 - value)) : (int64)value;
}

/// `long.Parse(text, NumberStyles.AllowHexSpecifier)` of .NET: hexadecimal digits only (up to 16 that are not leading
/// zeros, the bits of a long: "ffffffffffffffff" is -1); `null` if it is no such number.
Optional<int64> ParseHexLong(StringSlice text)
{
    if (text.Length == 0)
        return null;
    uint64 value = 0;
    int digits = 0;
    foreach (var c in text)
    {
        if (!Char.IsHexDigit(c))
            return null;
        if (digits > 0 || c != '0')
            digits += 1;
        if (digits > 16)
            return null;
        value = (value << 4) | (uint64)Char.HexValue(c);
    }
    return unchecked((int64)value);
}

// the value of an optionally signed decimal number with white space around it whose magnitude is at most 'limit'
Optional<int64> _ParseInteger(StringSlice text, int64 limit)
{
    var t = _TrimNetWhiteSpace(text);
    if (t.Length == 0)
        return null;
    bool negative = false;
    int start = 0;
    if (t[0] == '+' || t[0] == '-')
    {
        negative = t[0] == '-';
        start = 1;
    }
    if (start == t.Length)
        return null;
    int64 value = 0;
    for (var i = start; i < t.Length; i += 1)
    {
        if (t[i] < '0' || t[i] > '9')
            return null;
        value = value * 10 + (t[i] - '0');
        if (value > limit)
            return null;
    }
    return negative ? -value : value;
}

// the white space that the number parsing of .NET allows around a number: tab, line feed, vertical tab, form feed,
// carriage return and space
StringSlice _TrimNetWhiteSpace(StringSlice text)
{
    int start = 0;
    int end = text.Length;
    while (start < end && (text[start] == ' ' || (text[start] >= '\t' && text[start] <= '\r')))
        start += 1;
    while (end > start && (text[end - 1] == ' ' || (text[end - 1] >= '\t' && text[end - 1] <= '\r')))
        end -= 1;
    return text[start..end];
}

/// `int.TryParse(text, NumberStyles.AllowHexSpecifier)` of .NET: hexadecimal digits only (up to 8 that are not
/// leading zeros, the bits of an int: "ffffffff" is -1); `null` if it is no such number.
Optional<int> ParseHex(StringSlice text)
{
    if (text.Length == 0)
        return null;
    uint64 value = 0;
    int digits = 0;
    foreach (var c in text)
    {
        if (!Char.IsHexDigit(c))
            return null;
        if (digits > 0 || c != '0')
            digits += 1;
        value = value * 16 + (uint64)Char.HexValue(c);
        if (digits > 8)
            return null;
    }
    return (int)(uint32)value;
}
