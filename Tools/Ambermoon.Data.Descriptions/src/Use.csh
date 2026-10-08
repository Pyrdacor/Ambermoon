namespace Ambermoon.Data.Descriptions;

using System;
using Ambermoon;
using Ambermoon.Data;

/// Shortcuts to create descriptions: Use.Byte(...) etc.
struct Use
{
    static ValueDescription EventIndex(string name, bool required)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.EventIndex, Name = name, MinValue = 0, MaxValue = 0xffff, DefaultValue = 0xffff,
            Required = required, Hidden = false, ShowAsHex = true
        };
    }

    static ValueDescription Byte(string name, bool required, uint8 maxValue, uint8 minValue, uint8 defaultValue, bool showAsHex)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.Byte, Name = name, MinValue = minValue, MaxValue = maxValue, DefaultValue = defaultValue,
            Required = required, ShowAsHex = showAsHex
        };
    }

    static ValueDescription Byte(string name, bool required)
    {
        return Byte(name, required, 255, 0, 0, false);
    }

    static ValueDescription Byte(string name, bool required, uint8 maxValue)
    {
        return Byte(name, required, maxValue, 0, 0, false);
    }

    static ValueDescription Byte(string name, bool required, uint8 maxValue, uint8 minValue)
    {
        return Byte(name, required, maxValue, minValue, 0, false);
    }

    static ValueDescription Byte(string name, bool required, uint8 maxValue, uint8 minValue, uint8 defaultValue)
    {
        return Byte(name, required, maxValue, minValue, defaultValue, false);
    }

    static ValueDescription HiddenByte(uint8 defaultValue)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.Byte, Name = "Unknown", DefaultValue = defaultValue, Required = false, Hidden = true
        };
    }

    static ValueDescription HiddenByte()
    {
        return HiddenByte(0);
    }

    /// A signed byte from -128 to 127 (stored as its byte: the minimum -128 is 0x80).
    static ValueDescription SByte(string name, bool required)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.SByte, Name = name, MinValue = 0x80, MaxValue = 0x7f, DefaultValue = 0,
            Required = required, ShowAsHex = false
        };
    }

    static ValueDescription Word(string name, bool required, uint16 maxValue, uint16 minValue, uint16 defaultValue, bool showAsHex)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.Word, Name = name, MinValue = minValue, MaxValue = maxValue, DefaultValue = defaultValue,
            Required = required, ShowAsHex = showAsHex
        };
    }

    static ValueDescription Word(string name, bool required)
    {
        return Word(name, required, 65535, 0, 0, false);
    }

    static ValueDescription Word(string name, bool required, uint16 maxValue)
    {
        return Word(name, required, maxValue, 0, 0, false);
    }

    static ValueDescription Word(string name, bool required, uint16 maxValue, uint16 minValue)
    {
        return Word(name, required, maxValue, minValue, 0, false);
    }

    static ValueDescription Word(string name, bool required, uint16 maxValue, uint16 minValue, uint16 defaultValue)
    {
        return Word(name, required, maxValue, minValue, defaultValue, false);
    }

    static ValueDescription HiddenWord()
    {
        return ValueDescription { Slot = -1, Type = ValueType.Word, Name = "Unknown", DefaultValue = 0, Required = false, Hidden = true };
    }

    static ValueDescription Bool(string name, bool required)
    {
        return ValueDescription {
            Slot = -1, Type = ValueType.Bool, Name = name, MinValue = 0, MaxValue = 1, DefaultValue = 0, Required = required
        };
    }

    /// An enum value (EnumValueDescription<TEnum>): `enumType` is TEnum, `allowedValues` empty means all of its
    /// values (for flags with 0 in front if it is missing).
    static ValueDescription EnumOf(EnumInfo enumType, string name, bool required, bool hidden, int64 defaultValue, bool flags, bool word,
                                   int64[] allowedValues, Func<int64, Optional<string>> valueNameMapping)
    {
        int64 min = 0;
        int64 max = 0;
        for (var i = 0; i < enumType.Values.Length; i += 1)
        {
            int64 v = (int64)enumType.Values[i];
            if (i == 0 || v < min)
                min = v;
            if (i == 0 || v > max)
                max = v;
        }

        int64[] allowed = allowedValues;
        if (allowed == null || allowed.Length == 0)
        {
            allowed = new int64[enumType.Values.Length];
            bool hasZero = false;
            for (var i = 0; i < allowed.Length; i += 1)
            {
                allowed[i] = (int64)enumType.Values[i];
                if (allowed[i] == 0)
                    hasZero = true;
            }
            if (flags && !hasZero)
                allowed = [0, ..allowed];
        }

        return ValueDescription {
            Slot = -1, Kind = DescriptionKind.Enum, Type = flags ? (word ? ValueType.Flag16 : ValueType.Flag8) : ValueType.Enum,
            Name = name, Word = word, Required = required, Hidden = !required && hidden, MinValue = (uint16)min, MaxValue = (uint16)max,
            DefaultValue = (uint16)defaultValue, AllowedEnumValues = allowed, Flags = flags, ShowAsHex = flags, EnumType = enumType,
            ValueNameMapping = valueNameMapping
        };
    }

    static ValueDescription Enum(EnumInfo enumType, string name, bool required, int64 defaultValue)
    {
        return EnumOf(enumType, name, required, false, defaultValue, false, false, new int64[0], null);
    }

    static ValueDescription Enum(EnumInfo enumType, string name, bool required)
    {
        return Enum(enumType, name, required, 0);
    }

    static ValueDescription Enum(EnumInfo enumType, string name, bool required, int64 defaultValue, int64[] allowedValues,
                                 Func<int64, Optional<string>> valueNameMapping)
    {
        return EnumOf(enumType, name, required, false, defaultValue, false, false, allowedValues, valueNameMapping);
    }

    static ValueDescription WordEnum(EnumInfo enumType, string name, bool required, int64 defaultValue, int64[] allowedValues)
    {
        return EnumOf(enumType, name, required, false, defaultValue, false, true, allowedValues, null);
    }

    static ValueDescription Flags8(EnumInfo enumType, string name, bool required)
    {
        return EnumOf(enumType, name, required, false, 0, true, false, new int64[0], null);
    }

    static ValueDescription Flags16(EnumInfo enumType, string name, bool required)
    {
        return EnumOf(enumType, name, required, false, 0, true, true, new int64[0], null);
    }

    static ValueDescription Flags16(EnumInfo enumType, string name, bool required, int64 defaultValue)
    {
        return EnumOf(enumType, name, required, false, defaultValue, true, true, new int64[0], null);
    }

    static ValueDescription TenBits(string name, string propertyName, int byteOffset, int bitOffset, bool required)
    {
        return ValueDescription {
            Slot = -1, Kind = DescriptionKind.TenBits, Type = ValueType.TenBits, Name = name, PropertyName = propertyName,
            Required = required, Hidden = false, MinValue = 0, MaxValue = 1023, DefaultValue = 0, ShowAsHex = false,
            ByteOffset = byteOffset, BitOffset = bitOffset
        };
    }

    static ValueDescription TwelveBits(string name, string propertyName, int byteOffset, int bitOffset, bool required)
    {
        return ValueDescription {
            Slot = -1, Kind = DescriptionKind.TwelveBits, Type = ValueType.TwelveBits, Name = name, PropertyName = propertyName,
            Required = required, Hidden = false, MinValue = 0, MaxValue = 4095, DefaultValue = 0, ShowAsHex = false,
            ByteOffset = byteOffset, BitOffset = bitOffset
        };
    }

    /// The description, shown only for events for which `condition` is true (Use.Conditional).
    static ValueDescription Conditional(ValueDescription description, Func<Event, bool> condition)
    {
        description.Condition = condition;
        return description;
    }

    /// The description with a display mapping (Use.WithDisplayMapping).
    static ValueDescription WithDisplayMapping(ValueDescription description, Func<Event, ValueDescription, Optional<string>> displayMapping)
    {
        description.DisplayMapping = displayMapping;
        return description;
    }

    /// The description with a display name mapping (Use.WithNameIf).
    static ValueDescription WithDisplayNameMapping(ValueDescription description, Func<Event, ValueDescription, string> displayNameMapping)
    {
        description.DisplayNameMapping = displayNameMapping;
        return description;
    }
}
