namespace Ambermoon.Data;

using System;

/// The texts of Text.amb (version 1.14 and later): names, messages and the texts of the user interface.
struct TextContainer
{
    List<string> WorldNames;
    List<string> FormatMessages;
    List<string> Messages;
    List<string> AutomapTypeNames;
    List<string> OptionNames;
    List<string> MusicNames;
    List<string> SpellClassNames;
    List<string> SpellNames;
    List<string> LanguageNames;
    List<string> ClassNames;
    List<string> RaceNames;
    List<string> SkillNames;
    List<string> AttributeNames;
    List<string> SkillShortNames;
    List<string> AttributeShortNames;
    List<string> ItemTypeNames;
    List<string> ConditionNames;
    List<string> UITexts;
    List<int> UITextWithPlaceholderIndices;
    string VersionString;
    string DateAndLanguageString;

    static TextContainer Create()
    {
        return TextContainer
        {
            WorldNames = List<string>.Create(),
            FormatMessages = List<string>.Create(),
            Messages = List<string>.Create(),
            AutomapTypeNames = List<string>.Create(),
            OptionNames = List<string>.Create(),
            MusicNames = List<string>.Create(),
            SpellClassNames = List<string>.Create(),
            SpellNames = List<string>.Create(),
            LanguageNames = List<string>.Create(),
            ClassNames = List<string>.Create(),
            RaceNames = List<string>.Create(),
            SkillNames = List<string>.Create(),
            AttributeNames = List<string>.Create(),
            SkillShortNames = List<string>.Create(),
            AttributeShortNames = List<string>.Create(),
            ItemTypeNames = List<string>.Create(),
            ConditionNames = List<string>.Create(),
            UITexts = List<string>.Create(),
            UITextWithPlaceholderIndices = List<int>.Create(),
            VersionString = "",
            DateAndLanguageString = ""
        };
    }
}
