using System.Reflection;
using System.Text;

namespace CSharpToC
{
    internal interface IEnumProxy : IProxy
    {
        [CIgnore]
        bool Flags { get; }
    }

    public class EnumProxy<T> : IEnumProxy where T : Enum
    {
        [CIgnore]
        private const string endl = "\n";
        [CIgnore]
        private readonly Type type = typeof(T);
        [CIgnore]
        private readonly StringBuilder code = new();
        [CIgnore]
        public bool Flags { get; private set; }

        [CIgnore]
        private void AppendLine(string line = "")
        {
            code.Append(line + endl);
        }

        [CIgnore]
        protected EnumProxy()
        {
            AppendLine("enum " + type.Name);
            AppendLine("{");

            var names = Enum.GetNames(type);
            var values = Enum.GetValues(type);
            Flags = type.GetCustomAttribute<FlagsAttribute>() != null;

            for (int i = 0; i < names.Length; ++i)
            {
                string value = Flags
                    ? $"0x{(uint)Convert.ChangeType(values.GetValue(i)!, typeof(uint)):x8}"
                    : $"{(int)Convert.ChangeType(values.GetValue(i)!, typeof(int))}";

                string line = $"\t{type.Name}_{names[i]} = {value}";
                if (i != names.Length - 1)
                    line += ",";
                AppendLine(line);
            }

            AppendLine("};");
            AppendLine();
        }

        [CIgnore]
        public override string ToString() => code.ToString();
    }
}
