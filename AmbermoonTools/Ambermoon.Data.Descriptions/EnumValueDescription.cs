using System;
using System.Linq;
using System.Runtime.CompilerServices;

namespace Ambermoon.Data.Descriptions
{
    public interface IEnumValueDescription
    {
        public object[] AllowedValues { get; }
        public string[] AllowedValueNames { get; }
        public bool Flags { get; }
    }

    public class EnumValueDescription<TEnum> : ValueDescription, IEnumValueDescription where TEnum : System.Enum
    {
        public TEnum[] AllowedEnumValues { get; }
        public bool Flags { get; }
        public string[] AllowedValueNames => AllowedEnumValues.Select(v => Enum.GetName(v)).ToArray();
        public object[] AllowedValues => AllowedEnumValues.Select(v => (object)v).ToArray();

        public EnumValueDescription(string name, bool required, bool hidden, TEnum defaultValue, bool flags, bool word, TEnum[] allowedValues)
        {
            Type = flags ? (word ? ValueType.Flag16 : ValueType.Flag8) : ValueType.Enum;
            Name = name;
            Required = required;
            Hidden = !required && hidden;
            var values = (TEnum[])System.Enum.GetValues(typeof(TEnum));
            MinValue = (ushort)Convert.ChangeType(values.Min(), typeof(ushort));
            MaxValue = (ushort)Convert.ChangeType(values.Max(), typeof(ushort));
            DefaultValue = (ushort)Convert.ChangeType(defaultValue, typeof(ushort));
            AllowedEnumValues = allowedValues;

            if (AllowedEnumValues == null || AllowedEnumValues.Length == 0)
            {
                AllowedEnumValues = Enum.GetValues<TEnum>();

                if (flags && !AllowedEnumValues.Contains(default(TEnum)))
                    AllowedEnumValues = Enumerable.Concat(new TEnum[1] { default(TEnum) }, AllowedEnumValues).ToArray();
            }

            Flags = flags;
        }

        public override string GetPossibleValues()
        {
            if (AllowedEnumValues != null && AllowedEnumValues.Length != 0)
                return string.Join("\r\n", AllowedEnumValues);

            return string.Join("\r\n", System.Enum.GetValues(typeof(TEnum)));
        }

        public override bool Check(ushort input)
        {
            if (Flags) // TODO: maybe improve this later
                return true;

            return System.Enum.GetValues(typeof(TEnum)).OfType<TEnum>().Select(e => (ushort)Convert.ChangeType(e, typeof(ushort))).Contains(input);
        }

        public override string DefaultValueText
        {
            get
            {
                int value = DefaultValue;
                return Unsafe.As<int, TEnum>(ref value).ToString();
            }
        }
    }
}
