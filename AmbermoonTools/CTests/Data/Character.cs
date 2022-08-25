using Char = Ambermoon.Data.Character;

namespace CSharpToC.Data
{
    [CExport]
    [CIncludeMember(nameof(Char.Type))]
    public class Character : DataObject<Char>
    {
        public Character() : base
        (
            nameof(Char.Died),
            nameof(Char.PossibleConditions),
            nameof(Char.PossibleVisibleConditions)
        )
        {

        }
    }
}
