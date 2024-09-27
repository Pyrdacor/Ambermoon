using System;
using System.Collections.Generic;
using System.Linq;

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

        public static ValueDescription WithDisplayMapping<TEvent>(Func<ValueDescription> provider, Func<TEvent, ValueDescription, string> displayMapping) where TEvent : Event
        {
            var description = provider();

            string MapDisplay(Event @event, ValueDescription valueDescription)
            {
                if (@event is not TEvent specificEvent)
                    return EventDescriptions.ToString(@event, valueDescription);

                return displayMapping?.Invoke(specificEvent, valueDescription) ?? EventDescriptions.ToString(@event, valueDescription);
            }

            description.DisplayMapping = MapDisplay;
            return description;
        }

        public static ValueDescription WithNameIf<TEvent>(Func<ValueDescription> provider, Func<TEvent, bool> condition, string newName) where TEvent : Event
        {
            var description = provider();

            string MapDisplayName(Event @event, ValueDescription valueDescription)
            {
                if (!(@event is TEvent specificEvent) || condition(specificEvent) == false)
                    return valueDescription.DisplayName;

                return newName;
            }

            description.DisplayNameMapping = MapDisplayName;
            return description;
        }

        public static ValueDescription Byte(string name, bool required, byte maxValue = 255, byte minValue = 0, byte defaultValue = 0, bool showAsHex = false) => new()
		{
            Type = ValueType.Byte,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenByte(byte defaultValue = 0) => new()
		{
            Type = ValueType.Byte,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription SByte(string name, bool required, sbyte maxValue = 127, sbyte minValue = -128, sbyte defaultValue = 0) => new()
		{
            Type = ValueType.SByte,
            Name = name,
            MinValue = unchecked((byte)minValue),
            MaxValue = unchecked((byte)maxValue),
            DefaultValue = unchecked((byte)defaultValue),
            Required = required,
            ShowAsHex = false
        };

        public static ValueDescription Word(string name, bool required, ushort maxValue = 65535, ushort minValue = 0, ushort defaultValue = 0, bool showAsHex = false) => new()
		{
            Type = ValueType.Word,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenWord(ushort defaultValue = 0) => new()
		{
            Type = ValueType.Word,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Bool(string name, bool required, bool defaultValue = false) => new()
		{
            Type = ValueType.Bool,
            Name = name,
            MinValue = 0,
            MaxValue = 1,
            DefaultValue = (ushort)(defaultValue ? 1 : 0),
            Required = required
        };

        public static ValueDescription HiddenBool(byte defaultValue = 0) => new()
		{
            Type = ValueType.Bool,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flags8(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new()
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

        public static ValueDescription HiddenFlags8(byte defaultValue = 0) => new()
		{
            Type = ValueType.Flag8,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flags16(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new()
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

        public static ValueDescription HiddenFlags16(ushort defaultValue = 0) => new()
        {
            Type = ValueType.Flag16,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static EnumValueDescription<TEnum> Enum<TEnum>(string name, bool required, TEnum defaultValue = default,
            params TEnum[] allowedValues)
            where TEnum : struct, Enum => new(name, required, false, defaultValue, false, false, allowedValues, null);

        public static EnumValueDescription<TEnum> Enum<TEnum>(string name, bool required, TEnum defaultValue, IEnumerable<TEnum> allowedValues,
            Func<TEnum, string> valueNameMapping = null)
            where TEnum : struct, Enum => new(name, required, false, defaultValue, false, false, allowedValues.ToArray(), valueNameMapping);

        public static EnumValueDescription<TEnum> HiddenEnum<TEnum>(TEnum defaultValue = default)
            where TEnum : struct, Enum => new("Unknown", false, true, defaultValue, false, false, null, null);

        public static EnumValueDescription<TEnum> Flags8<TEnum>(string name, bool required, TEnum defaultValue = default,
            params TEnum[] allowedValues)
            where TEnum : struct, Enum => new(name, required, false, defaultValue, true, false, allowedValues, null);

        public static EnumValueDescription<TEnum> Flags16<TEnum>(string name, bool required, TEnum defaultValue = default,
            params TEnum[] allowedValues)
            where TEnum : struct, Enum => new(name, required, false, defaultValue, true, true, allowedValues, null);

        public static ValueDescription[] Compound(params ValueDescription[] valueDescriptions) => valueDescriptions;
    }
}
