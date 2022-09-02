using PM = Ambermoon.Data.PartyMember;

namespace CSharpToC.Data
{
    [CExport]
    [CInherit(typeof(Character))]
    [CCodeForMethod(nameof(PartyMember), "this->Type = CharacterType_PartyMember;")]
    [CSFileName($"{Program.BasePath}/data/character")]
    public class PartyMember : DataObject<PM>
    {
        public PartyMember() : base
        (
            nameof(PM.Died),
            nameof(PM.PossibleConditions),
            nameof(PM.PossibleVisibleConditions)
        )
        {

        }
    }
}
