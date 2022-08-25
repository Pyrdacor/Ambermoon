namespace CSharpToC
{
    public abstract class DataObject<T> : ClassProxy<T> where T : class
    {
        public DataObject(params string[] excludedMembers) : base(false, MemberConfig.DataDefault, excludedMembers)
        {

        }
    }
}
