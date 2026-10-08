namespace Ambermoon;

using System;

/// The names and values of an enum, for the texts of .NET (Enum.ToString, Enum.GetName) and of the original
/// EnumHelper. The values are sorted like .NET sorts them (by value; members with the same value in the order of
/// their declaration).
struct EnumInfo
{
    /// The names of the members.
    string[] Names;
    /// Their values (as unsigned numbers of the enum's size).
    uint64[] Values;
    /// Whether the enum is a [Flags] enum (its texts combine names: "Blind, Poisoned").
    bool IsFlags;
    /// The size of the enum in bytes.
    int Size;

    /// The facts about the enum `T`.
    static EnumInfo Of<T>(bool isFlags)
    {
        int count = Enum<T>.Count;
        var names = List<string>.Create(count);
        var values = List<uint64>.Create(count);
        // insertion sort by value: stable, so members with the same value keep their order
        for (var i = 0; i < count; i += 1)
        {
            uint64 value = ToUnsigned((int64)Enum<T>.Values[i], sizeof(T));
            int position = values.Count();
            while (position > 0 && values[position - 1] > value)
                position -= 1;
            values.Insert(position, value);
            names.Insert(position, Enum<T>.Names[i]);
        }
        return EnumInfo { Names = names.ToArray(), Values = values.ToArray(), IsFlags = isFlags, Size = sizeof(T) };
    }

    /// The value as an unsigned number of `size` bytes.
    static uint64 ToUnsigned(int64 value, int size)
    {
        if (size >= 8)
            return (uint64)value;
        return (uint64)value & (((uint64)1 << (size * 8)) - 1);
    }

    /// A number as a value of the enum (cut to its size, like a cast to the enum).
    uint64 FromNumber(int64 number)
    {
        return ToUnsigned(number, Size);
    }

    /// The name of the value (Enum.GetName: the first member with it), or `null` if no member has it.
    Optional<string> GetName(uint64 value)
    {
        for (var i = 0; i < Values.Length; i += 1)
        {
            if (Values[i] == value)
                return Names[i];
        }
        return null;
    }

    /// The text of the value like .NET's Enum.ToString(): the name; for [Flags] enums the names of the flags
    /// ("Blind, Poisoned"); the number if there is no such text.
    string Text(uint64 value)
    {
        if (GetName(value) is string name)
            return name;
        if (!IsFlags)
            return value.ToString();
        if (value == 0)
            return Values.Length > 0 && Values[0] == 0 ? Names[0] : "0";

        // walk down from the largest value and take the flags that are completely set
        var found = List<int>.Create();
        uint64 rest = value;
        for (var i = Values.Length - 1; i >= 0; i -= 1)
        {
            if (i == 0 && Values[i] == 0)
                break;
            if ((rest & Values[i]) == Values[i])
            {
                rest -= Values[i];
                found.Add(i);
            }
        }
        if (rest != 0)
            return value.ToString();
        var text = StringBuilder.Create();
        for (var i = found.Count() - 1; i >= 0; i -= 1)
        {
            if (i != found.Count() - 1)
                text.Append(", ");
            text.Append(Names[found[i]]);
        }
        return text.ToString();
    }

    /// The flags that are set in the value (EnumHelper.GetFlagNames of the original): the names of all distinct
    /// non-zero values that share a bit with it, by value, joined by " | "; "None" for no flags.
    string FlagNames(uint64 value)
    {
        var values = List<uint64>.Create();
        foreach (var v in Values)
        {
            if (v != 0 && !values.Contains(v))
                values.Add(v);
        }
        if (values.Count() == 0 || value == 0)
            return GetName(0) is string zero ? zero : "None";
        values.Sort();
        var result = StringBuilder.Create();
        foreach (var v in values)
        {
            if ((value & v) == 0)
                continue;
            if (result.Length() != 0)
                result.Append(" | ");
            if (GetName(v) is string name)
                result.Append(name);
        }
        return result.ToString();
    }
}

/// .NET's Enum.ToString() for any enum (names of [Flags] enums are combined when `isFlags`).
string EnumText<T>(T value, bool isFlags)
{
    return EnumInfo.Of<T>(isFlags).Text(EnumInfo.ToUnsigned((int64)value, sizeof(T)));
}

/// EnumHelper.GetFlagNames of the original: the names of the flags in the value, joined by " | ".
/// (The generic variant of the original: "None" for no flags.)
string GetFlagNames<T>(T value)
{
    uint64 flags = EnumInfo.ToUnsigned((int64)value, sizeof(T));
    if (flags == 0)
        return "None";
    return EnumInfo.Of<T>(true).FlagNames(flags);
}

/// Enum.GetName: the name of the value, `null` if no member has it.
Optional<string> EnumName<T>(T value)
{
    return EnumInfo.Of<T>(false).GetName(EnumInfo.ToUnsigned((int64)value, sizeof(T)));
}

/// The values of an enum like `Enum.GetValues` of .NET (EnumHelper.GetValues): all declared members sorted by their
/// value as an unsigned number (members with the same value in the order of their declaration).
T[] GetEnumValues<T>()
{
    var values = Enum<T>.Values;
    var result = new T[values.Length];
    var keys = new uint64[values.Length];
    for (var i = 0; i < values.Length; i += 1)
    {
        // insertion sort: stable, and enums are small
        var key = EnumInfo.ToUnsigned((int64)values[i], sizeof(T));
        int j = i;
        while (j > 0 && keys[j - 1] > key)
        {
            keys[j] = keys[j - 1];
            result[j] = result[j - 1];
            j -= 1;
        }
        keys[j] = key;
        result[j] = values[i];
    }
    return result;
}
