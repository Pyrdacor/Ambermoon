using System;

namespace Ambermoon.Data.Descriptions
{
    // Shortcut for description creation -> Use.Byte(...) etc
    internal static class Use
    {
        public static ValueDescription EventIndex(string name, bool required) => new EventIndexDescription(name, required);

        public static ValueDescription Conditional<TEvent>(Func<ValueDescription> provider, Func<TEvent, bool> condition) where TEvent : Event
        {
            var description = provider();

            bool CheckCondition(EventDescription eventDescription, Event @event)
            {
                if (!(@event is TEvent specificEvent))
                    return false;

                return condition?.Invoke(specificEvent) ?? true;
            }

            description.Condition = CheckCondition;
            return description;
        }

        public static ValueDescription Byte(string name, bool required, byte maxValue = 255, byte minValue = 0, byte defaultValue = 0, bool showAsHex = false) => new ValueDescription
        {
            Type = ValueType.Byte,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenByte(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Byte,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription SByte(string name, bool required, sbyte maxValue = 127, sbyte minValue = -128, sbyte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.SByte,
            Name = name,
            MinValue = unchecked((byte)minValue),
            MaxValue = unchecked((byte)maxValue),
            DefaultValue = unchecked((byte)defaultValue),
            Required = required,
            ShowAsHex = false
        };

        public static ValueDescription Word(string name, bool required, ushort maxValue = 65535, ushort minValue = 0, ushort defaultValue = 0, bool showAsHex = false) => new ValueDescription
        {
            Type = ValueType.Word,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenWord(ushort defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Word,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Bool(string name, bool required, bool defaultValue = false) => new ValueDescription
        {
            Type = ValueType.Bool,
            Name = name,
            MinValue = 0,
            MaxValue = 1,
            DefaultValue = (ushort)(defaultValue ? 1 : 0),
            Required = required
        };

        public static ValueDescription HiddenBool(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Bool,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flags8(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new ValueDescription
        {
            Type = ValueType.Flag8,
            Name = name,
            MinValue = 0,
            MaxValue = 255,
            DefaultValue = 0,
            Required = required,
            FlagDescriptionOffset = flagDescriptionOffset,
            FlagDescriptions = flagDescriptions
        };

        public static ValueDescription HiddenFlags8(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Flag8,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flags16(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new ValueDescription
        {
            Type = ValueType.Flag16,
            Name = name,
            MinValue = 0,
            MaxValue = 65535,
            DefaultValue = 0,
            Required = required,
            FlagDescriptionOffset = flagDescriptionOffset,
            FlagDescriptions = flagDescriptions
        };

        public static ValueDescription HiddenFlags16(ushort defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Flag16,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static EnumValueDescription<TEnum> Enum<TEnum>(string name, bool required, TEnum defaultValue = default(TEnum),
            params TEnum[] allowedValues)
            where TEnum : System.Enum => new EnumValueDescription<TEnum>(name, required, false, defaultValue, false, false, allowedValues);

        public static EnumValueDescription<TEnum> HiddenEnum<TEnum>(TEnum defaultValue = default(TEnum))
            where TEnum : System.Enum => new EnumValueDescription<TEnum>("Unknown", false, true, defaultValue, false, false, null);

        public static EnumValueDescription<TEnum> Flags8<TEnum>(string name, bool required, TEnum defaultValue = default(TEnum),
            params TEnum[] allowedValues)
            where TEnum : System.Enum => new EnumValueDescription<TEnum>(name, required, false, defaultValue, true, false, allowedValues);

        public static EnumValueDescription<TEnum> Flags16<TEnum>(string name, bool required, TEnum defaultValue = default(TEnum),
            params TEnum[] allowedValues)
            where TEnum : System.Enum => new EnumValueDescription<TEnum>(name, required, false, defaultValue, true, true, allowedValues);

        public static ValueDescription[] Compound(params ValueDescription[] valueDescriptions) => valueDescriptions;
    }
}
