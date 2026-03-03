using Ambermoon;

namespace AmbermoonScript;

internal static class Extensions
{
    public static string ToCamelCase(this string value)
    {
        return char.ToLower(value[0]) + value[1..];
    }

    public static string ToPrintString<T>(this T enumValue) where T : Enum
    {
        return enumValue.ToString().ToCamelCase();
    }

    public static string ToFlagsPrintString<T>(this T enumValue, int bytes) where T : Enum
    {
        var flagNames = EnumHelper.GetFlagNames(enumValue, bytes);
        var flags = flagNames.Split('|');
        
        return string.Join(" | ", flags.Select(flag => flag.Trim().ToCamelCase()));
    }

    public static string ToPrintString(this bool booleanValue)
    {
        return booleanValue ? ScriptEvent.True : ScriptEvent.False;
    }
}
