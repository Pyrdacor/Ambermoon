namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Method | AttributeTargets.Property | AttributeTargets.Field | AttributeTargets.Constructor, AllowMultiple = false, Inherited = true)]
    public class CIncludeAttribute : Attribute
    {

    }
}
