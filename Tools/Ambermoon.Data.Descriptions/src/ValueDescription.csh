namespace Ambermoon.Data.Descriptions;

using System;
using Ambermoon;
using Ambermoon.Data;

/// The type of a value of an event.
enum ValueType : int32
{
    Byte,
    Word,
    Bool,
    Enum,
    Flag8,
    Flag16,
    EventIndex,
    SByte,
    ByteList,
    TenBits,
    TwelveBits
}

/// Which description class of the original a [ValueDescription] is.
enum DescriptionKind : uint8
{
    /// ValueDescription and EventIndexDescription
    Plain,
    /// EnumValueDescription<TEnum> (with filtered allowed values if ValueFilter is set)
    Enum,
    /// TenBitValueDescription
    TenBits,
    /// TwelveBitValueDescription
    TwelveBits
}

/// A value of an event: its type, range, default and name, and how it is shown.
///
/// In the original the descriptions are objects that the editor changes (a display name, a display mapping that is
/// used once); here they are values that live in [ValueDescriptions] under their Slot, and changes are stored back
/// there.
struct ValueDescription
{
    /// Where it is stored in [ValueDescriptions] (-1: a temporary description).
    int Slot;
    ValueType Type;
    uint16 DefaultValue;
    string Name;
    Optional<string> _displayName;
    /// Must be set by the user in any case.
    bool Required;
    /// Hidden values are always set to the default value and are not shown.
    bool Hidden;
    bool ShowAsHex;
    uint16 MinValue;
    uint16 MaxValue;
    int FlagDescriptionOffset;
    /// null: none
    string[] FlagDescriptions;
    /// Whether the value is shown for the event (null: always).
    Func<Event, bool> Condition;
    /// The text instead of " Name=value," (null: none; the result may be null).
    Func<Event, ValueDescription, Optional<string>> DisplayMapping;
    /// The display name for the event (null: none).
    Func<Event, ValueDescription, string> DisplayNameMapping;
    DescriptionKind Kind;

    // EnumValueDescription<TEnum>
    /// The enum (TEnum).
    EnumInfo EnumType;
    /// The allowed values (with duplicates, in their order).
    int64[] AllowedEnumValues;
    bool Flags;
    bool Word;
    /// The names of the values (null: Enum.GetName).
    Func<int64, Optional<string>> ValueNameMapping;
    /// Filters of the allowed values and their names (EnumValueDescriptionWithFilteredAllowedValues; null: none).
    Func<int64[], int64[]> ValueFilter;
    Func<string[], string[]> ValueNameFilter;

    // TenBitValueDescription, TwelveBitValueDescription
    string PropertyName;
    int ByteOffset;
    int BitOffset;

    /// The name that is shown: the display name if one was set, otherwise the name.
    string DisplayName()
    {
        return _displayName is string displayName ? displayName : Name;
    }

    /// Sets the display name.
    void SetDisplayName(Optional<string> displayName)
    {
        _displayName = displayName;
    }

    /// The text of a value of this description (AsString of the original).
    string AsString(PropertyValue value)
    {
        if (Kind == DescriptionKind.Enum)
            return _EnumValueString((int64)value.Number) is string name ? name : "";

        switch (Type)
        {
            case ValueType.Byte:
            case ValueType.SByte:
                return ShowAsHex ? "0x" + value.Number.ToString("x2") : value.Text;
            case ValueType.Word:
            case ValueType.EventIndex:
                return ShowAsHex ? "0x" + value.Number.ToString("x4") : value.Text;
            case ValueType.Bool:
                return value.Number != 0 ? "1" : "0";
            case ValueType.Flag8:
                return "0x" + value.Number.ToString("x2");
            case ValueType.Flag16:
                return "0x" + value.Number.ToString("x4");
            default:
                return value.Text;
        }
    }

    /// Whether `input` is a valid value.
    bool Check(uint16 input)
    {
        if (Kind == DescriptionKind.TenBits)
            return input < 1024;
        if (Kind == DescriptionKind.TwelveBits)
            return input < 4096;
        if (Kind == DescriptionKind.Enum)
        {
            if (Flags)
                return true;
            foreach (var v in AllowedEnumValues)
            {
                if ((uint16)v == input)
                    return true;
            }
            return false;
        }

        switch (Type)
        {
            case ValueType.Bool:
                return input == 0 || input == 1;
            case ValueType.Byte:
            case ValueType.Flag8:
                return input >= MinValue && input <= MaxValue && input <= 0xff;
            case ValueType.Word:
            case ValueType.Flag16:
            case ValueType.EventIndex:
                return input >= MinValue && input <= MaxValue;
            case ValueType.SByte:
            {
                int signedInput = AsSignedWord(input);
                int minValue = AsSignedWord(MinValue);
                int maxValue = AsSignedWord(MaxValue);
                return signedInput >= minValue && signedInput <= maxValue;
            }
            default:
                return false;
        }
    }

    /// The value as a signed byte (the original: (short)(sbyte)(byte)value).
    static int AsSignedWord(uint16 value)
    {
        int b = value & 0xff;
        return b >= 128 ? b - 256 : b;
    }

    /// Reads the value from the data at `dataIndex` and moves `dataIndex` behind it: a word big-endian, a signed byte
    /// with its sign, other values as a byte (not for ten and twelve bit values).
    int Read(uint8[] data, ref int dataIndex)
    {
        int index = dataIndex;
        if (Type == ValueType.Word || Type == ValueType.Flag16 || Type == ValueType.EventIndex)
        {
            dataIndex += 2;
            return (data[index] << 8) | data[index + 1];
        }
        dataIndex += 1;
        if (Type == ValueType.SByte)
            return data[index] >= 128 ? data[index] - 256 : data[index];
        return data[index];
    }

    /// Writes the value into the event data at `dataIndex` and moves `dataIndex` behind it.
    void Write(uint8[] data, ref int dataIndex, uint16 value)
    {
        if (Kind == DescriptionKind.TenBits || Kind == DescriptionKind.TwelveBits)
        {
            _WriteBits(data, ref dataIndex, value);
            return;
        }
        if (Type == ValueType.Word || Type == ValueType.Flag16 || Type == ValueType.EventIndex)
        {
            data[dataIndex] = (uint8)((value >> 8) & 0xff);
            dataIndex += 1;
        }
        data[dataIndex] = (uint8)(value & 0xff);
        dataIndex += 1;
    }

    /// The text of the default value.
    string DefaultValueText()
    {
        if (Kind == DescriptionKind.Enum)
            return _EnumValueString(DefaultValue) is string name ? name : "";
        if (Type == ValueType.SByte)
            return AsSignedWord(DefaultValue).ToString();
        return DefaultValue.ToString();
    }

    // ---- EnumValueDescription<TEnum> ----

    /// The allowed values: distinct, by value (filtered if there is a filter).
    int64[] AllowedValues()
    {
        var values = _DistinctSorted();
        if (ValueFilter != null)
            return ValueFilter(values);
        return values;
    }

    /// The names of the allowed values (filtered if there is a filter).
    string[] AllowedValueNames()
    {
        var values = _DistinctSorted();
        var names = new string[values.Length];
        for (var i = 0; i < values.Length; i += 1)
            names[i] = _EnumValueString(values[i]) is string name ? name : "";
        if (ValueNameFilter != null)
            return ValueNameFilter(names);
        return names;
    }

    int64[] _DistinctSorted()
    {
        var values = List<int64>.Create();
        foreach (var v in AllowedEnumValues)
        {
            if (!values.Contains(v))
                values.Add(v);
        }
        values.Sort();
        return values.ToArray();
    }

    Optional<string> _EnumValueString(int64 value)
    {
        if (ValueNameMapping != null)
            return ValueNameMapping(value);
        return EnumType.GetName(EnumType.FromNumber(value));
    }

    // ---- TenBitValueDescription, TwelveBitValueDescription ----

    int _BitCount()
    {
        return Kind == DescriptionKind.TenBits ? 10 : 12;
    }

    /// Reads the value from the event data (at its byte and bit offset).
    int ReadBits(uint8[] data)
    {
        int dataIndex = ByteOffset;
        int bits = _BitCount();
        int readBitOffset = BitOffset;
        int bitsInByte = 8 - readBitOffset;
        int mask = (1 << bitsInByte) - 1;
        int result = data[dataIndex] & mask;
        dataIndex += 1;
        readBitOffset = bits - bitsInByte;
        result <<= readBitOffset;
        result |= data[dataIndex] >> (8 - readBitOffset);
        return result;
    }

    void _WriteBits(uint8[] data, ref int dataIndex, uint16 value)
    {
        if (dataIndex != ByteOffset)
            Environment.Panic("Expected write offset " + ByteOffset.ToString() + " but was " + dataIndex.ToString());
        int bits = _BitCount();
        int v = value & ((1 << bits) - 1);
        int bitsInByte = 8 - BitOffset;
        int writeBitOffset = bits - bitsInByte;

        int mask = (1 << bitsInByte) - 1;
        data[dataIndex] = (uint8)(data[dataIndex] & ~mask);
        data[dataIndex] = (uint8)(data[dataIndex] | (v >> writeBitOffset));
        dataIndex += 1;

        mask = 0xff >> writeBitOffset;
        data[dataIndex] = (uint8)(data[dataIndex] & mask);
        data[dataIndex] = (uint8)(data[dataIndex] | (v << (8 - writeBitOffset)));

        if (writeBitOffset == 8)
            dataIndex += 1;
    }
}
