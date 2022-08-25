namespace CSharpToC
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct, AllowMultiple = false, Inherited = false)]
    public class CInheritAttribute : CReferenceAttribute
    {
        public Type BaseClass { get; init; }

        public CInheritAttribute(Type baseClass) : base(baseClass)
        {
            BaseClass = baseClass;
        }
    }
}
