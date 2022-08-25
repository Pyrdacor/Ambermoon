namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Method, AllowMultiple = false, Inherited = true)]
    public class CCodeAttribute : Attribute
    {
        public string Code { get; init; }

        public CCodeAttribute(string code)
        {
            Code = code;
        }
    }
}
