using System;
using System.Linq;

namespace Ambermoon.Data.Descriptions
{
    public enum ValueType
    {
        Byte,
        Word,
        Bool,
        Enum,
        Flag8,
        Flag16,
        EventIndex,
        SByte
    }

    public class ValueDescription
    {
        public ValueType Type { get; set; } = ValueType.Byte;
        public ushort DefaultValue { get; set; } = 0;
        public string Name { get; set; }
        /// <summary>
        /// Must be set by the user in any case.
        /// </summary>
        public bool Required { get; set; }
        /// <summary>
        /// Hidden properties are always set to the default value
        /// and are not shown.
        /// </summary>
        public bool Hidden { get; set; }
        public bool ShowAsHex { get; set; }
        public ushort MinValue { get; set; } = 0;
        public ushort MaxValue { get; set; }
        public int FlagDescriptionOffset { get; set; } = 0;
        public string[] FlagDescriptions { get; set; } = null;
        public Func<EventDescription, Event, bool> Condition { get; set; } = null;
        public virtual string AsString(object value)
        {
            switch (Type)
            {
                case ValueType.Byte:
                case ValueType.SByte:
                    if (ShowAsHex)
                        return $"0x{value:x2}";
                    else
                        return $"{value}";
                case ValueType.Word:
                case ValueType.EventIndex:
                    if (ShowAsHex)
                        return $"0x{value:x4}";
                    else
                        return $"{value}";
                case ValueType.Bool:
                    if ((bool)value)
                        return "1";
                    else
                        return "0";
                case ValueType.Flag8:
                    return $"0x{Convert.ChangeType(value, typeof(uint)):x2}";
                case ValueType.Flag16:
                    return $"0x{Convert.ChangeType(value, typeof(uint)):x4}";
                default:
                    return value.ToString();
            }
        }
        public virtual string GetPossibleValues()
        {
            switch (Type)
            {
                case ValueType.Byte:
                    if (MinValue > 0xff)
                        throw new Exception("Invalid min value for type byte");
                    if (ShowAsHex)
                        return $"0x{MinValue:x2} ~ 0x{Math.Min(0xff, (int)MaxValue):x2}";
                    else
                        return $"{MinValue} ~ {Math.Min(0xff, (int)MaxValue)}";
                case ValueType.Word:
                    if (ShowAsHex)
                        return $"0x{MinValue:x4} ~ 0x{MaxValue:x4}";
                    else
                        return $"{MinValue} ~ {MaxValue}";
                case ValueType.Bool:
                    return "0 or 1";
                case ValueType.Flag8:
                    if (FlagDescriptions != null)
                        return string.Join("\r\n", FlagDescriptions.Select((d, i) => $"{1 << (FlagDescriptionOffset + i):x2}: {d}"));
                    return "0x00 ~ 0xff";
                case ValueType.Flag16:
                    if (FlagDescriptions != null)
                        return string.Join("\r\n", FlagDescriptions.Select((d, i) => $"{1 << (FlagDescriptionOffset + i):x4}: {d}"));
                    return "0x0000 ~ 0xffff";
                case ValueType.SByte:
                {
                    var minValue = AsSignedWord(MinValue);
                    var maxValue = AsSignedWord(MaxValue);
                    if (minValue < -128 || minValue > 127)
                        throw new Exception("Invalid min value for type sbyte");
                    if (maxValue < -128)
                        throw new Exception("Invalid max value for type sbyte");
                    return $"{minValue} ~ {Math.Min(127, (int)maxValue)}";
                }
                default:
                    throw new Exception();
            }
        }

        public static short AsSignedWord(ushort value) => (short)unchecked((sbyte)(byte)value);

        public static sbyte AsSignedByte(ushort value) => (sbyte)AsSignedWord(value);

        public virtual bool Check(ushort input)
        {
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
                    sbyte signedInput = AsSignedByte(input);
                    var minValue = AsSignedWord(MinValue);
                    var maxValue = AsSignedWord(MaxValue);

                    return signedInput >= minValue && signedInput <= maxValue && signedInput <= 127 && signedInput >= -128;
                }
            }

            return false;
        }

        public virtual string DefaultValueText => Type == ValueType.SByte
            ? AsSignedByte(DefaultValue).ToString()
            : DefaultValue.ToString();
    }
}
