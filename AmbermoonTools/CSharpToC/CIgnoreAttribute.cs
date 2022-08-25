namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Property | AttributeTargets.Field | AttributeTargets.Constructor, AllowMultiple = false, Inherited = true)]
    public class CIgnoreAttribute : Attribute
    {

    }
}
