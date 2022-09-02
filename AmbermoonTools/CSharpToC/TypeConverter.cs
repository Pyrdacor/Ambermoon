using System.CodeDom;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace CSharpToC
{
    internal static class TypeConverter
    {
        // TODO: is this working?
        private static Type TypeFromCodeDom(CodeTypeReference type) => Assembly.GetEntryAssembly()!.GetType(type.BaseType)!;

        public static bool HasExplicitConstructor(CodeTypeReference type)
        {
            return HasExplicitConstructor(TypeFromCodeDom(type));
        }

        public static bool HasExplicitConstructor(Type type)
        {
            return type.GetConstructors().Any(c => c.GetCustomAttribute<CompilerGeneratedAttribute>() == null);
        }

        public static string TypeToCName(CodeTypeReference type)
        {
            return TypeToCName(TypeFromCodeDom(type));
        }

        public static string TypeToCName(Type type)
        {
            if (type.IsArray || type.IsPointer)
                return TypeToCName(type.GetElementType()!) + "*";

            if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(List<>))
                return TypeToCName(type.GetGenericArguments()[0]) + "*";

            if (type == typeof(bool))
                return "BOOL";
            else if (type == typeof(byte))
                return "unsigned char";
            else if (type == typeof(sbyte))
                return "char";
            else if (type == typeof(ushort))
                return "unsigned short";
            else if (type == typeof(short))
                return "short";
            else if (type == typeof(uint))
                return "unsigned long";
            else if (type == typeof(int))
                return "long";
            else if (type == typeof(ulong))
                return "unsigned long long";
            else if (type == typeof(long))
                return "long long";
            else if (type == typeof(string))
                return "STRING";
            else if (type == typeof(void))
                return "void";
            else if (type.IsEnum)
                return "enum " + type.Name;
            else if (type.IsClass)
                return "struct " + type.Name + "*";
            else if (type.IsValueType && !type.IsPrimitive)
                return "struct " + type.Name;
            else
                return type.Name;
        }

        public static bool NeedsTypesHeader(Type type)
        {
            return type == typeof(string) || type == typeof(bool);
        }

        public static string? GetDefaultValue(CodeTypeReference type)
        {
            
            return GetDefaultValue(TypeFromCodeDom(type));
        }

        public static string? GetDefaultValue(Type type)
        {
            if (type.IsArray || type.IsPointer)
                return "0";

            if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof(List<>))
                return "0";

            if (type == typeof(bool))
                return "0";
            else if (type == typeof(byte))
                return "0";
            else if (type == typeof(sbyte))
                return "0";
            else if (type == typeof(ushort))
                return "0";
            else if (type == typeof(short))
                return "0";
            else if (type == typeof(uint))
                return "0";
            else if (type == typeof(int))
                return "0";
            else if (type == typeof(ulong))
                return "0";
            else if (type == typeof(long))
                return "0";
            else if (type == typeof(string))
                return "\"\"";
            else if (type == typeof(void))
                throw new NotSupportedException("Type void has no default value.");
            else if (type.IsEnum)
                return null;
            else if (type.IsClass)
                return null;
            else if (type.IsValueType && !type.IsPrimitive)
                return null;
            else
                return null;
        }
    }
}
