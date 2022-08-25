namespace CSharpToC
{
    internal static class TypeConverter
    {
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
    }
}
