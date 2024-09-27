using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;

namespace Ambermoon.Data.Descriptions
{
    public interface IEnumValueDescription
    {
        public object[] AllowedValues { get; }
        public string[] AllowedValueNames { get; }
        public Dictionary<long, string> AllowedEntries { get; }
        public bool Flags { get; }
    }

    internal record EnumValueDescriptionWithFilteredAllowedValues<TEnum> : EnumValueDescription<TEnum>, IEnumValueDescription where TEnum : struct, Enum
    {
        private readonly Func<object[], object[]> valueFilter;
        private readonly Func<string[], string[]> valueNameFilter;

        public override string[] AllowedValueNames => valueNameFilter(base.AllowedValueNames);
        public override object[] AllowedValues => valueFilter(base.AllowedValues);

        public EnumValueDescriptionWithFilteredAllowedValues(string name, bool required, bool hidden, TEnum defaultValue,
            bool flags, bool word, TEnum[] allowedValues, Func<object[], object[]> valueFilter, Func<string[], string[]> valueNameFilter)
            : base(name, required, hidden, defaultValue, flags, word, allowedValues, null)
        {
            this.valueFilter = valueFilter;
            this.valueNameFilter = valueNameFilter;
        }
    }

    public record EnumValueDescription<TEnum> : ValueDescription, IEnumValueDescription where TEnum : struct, Enum
    {
        private readonly Func<TEnum, string> valueNameMapping;

		public TEnum[] AllowedEnumValues { get; }
        public bool Flags { get; }
        public virtual string[] AllowedValueNames => AllowedEnumValues.Distinct().OrderBy(e => e).Select(GetEnumValueString).ToArray();
        public virtual object[] AllowedValues => AllowedEnumValues.Distinct().OrderBy(e => e).Select(v => (object)v).ToArray();
        public Dictionary<long, string> AllowedEntries => AllowedValues.Select((v, index) => new { v, index }).ToDictionary(v => (long)Convert.ChangeType(v.v, typeof(long)), v => AllowedValueNames[v.index]);

        public EnumValueDescription(string name, bool required, bool hidden, TEnum defaultValue, bool flags, bool word, TEnum[] allowedValues, Func<TEnum, string> valueNameMapping)
        {
            Type = flags ? (word ? ValueType.Flag16 : ValueType.Flag8) : ValueType.Enum;
            Name = name;
            Required = required;
            Hidden = !required && hidden;
            var values = (TEnum[])Enum.GetValues(typeof(TEnum));
            MinValue = (ushort)Convert.ChangeType(values.Min(), typeof(ushort));
            MaxValue = (ushort)Convert.ChangeType(values.Max(), typeof(ushort));
            DefaultValue = (ushort)Convert.ChangeType(defaultValue, typeof(ushort));
            AllowedEnumValues = allowedValues;

            if (AllowedEnumValues == null || AllowedEnumValues.Length == 0)
            {
                AllowedEnumValues = Enum.GetValues<TEnum>();

                if (flags && !AllowedEnumValues.Contains(default))
                    AllowedEnumValues = Enumerable.Concat(new TEnum[1] { default }, AllowedEnumValues).ToArray();
            }

            Flags = flags;
            ShowAsHex = flags;
            this.valueNameMapping = valueNameMapping;
		}

        public override string GetPossibleValues()
        {
            if (AllowedEnumValues != null && AllowedEnumValues.Length != 0)
                return string.Join("\r\n", AllowedEnumValues);

            return string.Join("\r\n", Enum.GetValues(typeof(TEnum)));
        }

        public override bool Check(ushort input)
        {
            if (Flags) // TODO: maybe improve this later
                return true;

            return AllowedEnumValues.Select(e => (ushort)Convert.ChangeType(e, typeof(ushort))).Contains(input);
        }

        public override string DefaultValueText
        {
            get
            {
                int value = DefaultValue;
                return Unsafe.As<int, TEnum>(ref value).ToString();
            }
        }

        public EnumValueDescription<TEnum> WithFilteredAllowedValues(Func<object[], object[]> valueFilter, Func<string[], string[]> valueNameFilter)
        {
            return new EnumValueDescriptionWithFilteredAllowedValues<TEnum>(Name, Required, Hidden,
                (TEnum)Enum.Parse(typeof(TEnum), DefaultValue.ToString()), Flags, Type == ValueType.Flag16, AllowedEnumValues, valueFilter, valueNameFilter);
        }

        private string GetEnumValueString(TEnum value)
        {
			if (valueNameMapping != null)
				return valueNameMapping(value);

			return Enum.GetName<TEnum>(value);
		}
    }
}
