namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = true, Inherited = true)]
    public class CCodeForMethodAttribute : Attribute
    {
        public string MemberName { get; init; }
        public string Code { get; init; }

        public CCodeForMethodAttribute(string memberName, string code)
        {
            MemberName = memberName;
            Code = code;
        }
    }
}
