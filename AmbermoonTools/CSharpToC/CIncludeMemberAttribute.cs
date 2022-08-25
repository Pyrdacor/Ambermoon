namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = true, Inherited = true)]
    public class CIncludeMemberAttribute : Attribute
    {
        public string MemberName { get; init; }

        public CIncludeMemberAttribute(string memberName)
        {
            MemberName = memberName;
        }
    }
}
