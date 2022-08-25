namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = true, Inherited = true)]
    public class CReferenceAttribute : Attribute
    {
        public Type Reference { get; init; }

        public CReferenceAttribute(Type reference)
        {
            Reference = reference;
        }
    }
}
