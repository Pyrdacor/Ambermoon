using Ambermoon.Data;

namespace AmbermoonEditor.Extensions;

internal static class CharacterExtensions
{
    public static long AttributeValue(this Character character, Attribute attribute)
    {
        var characterValue = character.Attributes[attribute];

        return characterValue.CurrentValue + characterValue.BonusValue;
    }

    public static long SkillValue(this Character character, Skill skill)
    {
        var characterValue = character.Skills[skill];

        return characterValue.CurrentValue + characterValue.BonusValue;
    }

    public static string FormatCharacterValue(this CharacterValue characterValue, CharacterValueType characterValueType)
    {
        long value = characterValue.CurrentValue;
        long maxValue = characterValue.MaxValue;

        if (characterValueType == CharacterValueType.HpSp)
            maxValue += characterValue.BonusValue;
        else
            value += characterValue.BonusValue;

        return characterValueType switch
        {
            CharacterValueType.HpSp => $"{value} / {maxValue}",
            CharacterValueType.Attribute => $"{value:000}/{maxValue:000}",
            CharacterValueType.Skill => $"{value:00}%/{maxValue:00}%",
            _ => ""
        };
    }
}
