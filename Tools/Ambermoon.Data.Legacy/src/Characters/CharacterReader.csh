namespace Ambermoon.Data.Legacy.Characters;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;

/// Reads characters: party members, NPCs and monsters share the first part of the data.
struct CharacterReader
{
    /// Reads the data of a character from the start of the reader; its type must be the one of `character`.
    /// @error a character of another type, or the data ends too early.
    static Error<void> ReadCharacter(ref Character character, ref DataReader reader)
    {
        reader.Position = 0;

        if (reader.ReadByte() != (uint8)character.Type)
            return error("Wrong character type.");

        bool monster = character.Type == CharacterType.Monster;
        bool partyMember = character.Type == CharacterType.PartyMember;

        character.Gender = (Gender)reader.ReadByte();
        character.Race = (Race)reader.ReadByte();
        character.Class = (Class)reader.ReadByte();
        character.SpellMastery = (SpellTypeMastery)reader.ReadByte();
        character.Level = reader.ReadByte();
        character.NumberOfOccupiedHands = reader.ReadByte();
        character.NumberOfOccupiedFingers = reader.ReadByte();
        character.SpokenLanguages = (Language)reader.ReadByte();
        character.InventoryInaccessible = reader.ReadByte() != 0;
        character.PortraitIndex = reader.ReadByte();
        if (monster)
            character.AdvancedMonsterFlags = (AdvancedMonsterFlags)reader.ReadByte();
        else
            character.JoinPercentage = reader.ReadByte();
        var combatGraphicIndex = reader.ReadByte();
        if (monster)
            character.CombatGraphicIndex = (MonsterGraphicIndex)combatGraphicIndex;
        if (monster)
            character.SpellChancePercentage = reader.ReadByte();
        else
            character.SpokenExtendedLanguages = (ExtendedLanguage)reader.ReadByte();
        character.MagicHitBonus = reader.ReadByte();
        var moraleOrLevel = reader.ReadByte();
        if (monster)
            character.Morale = moraleOrLevel;
        else if (partyMember)
            character.MaxReachedLevel = moraleOrLevel;
        character.SpellTypeImmunity = (SpellTypeImmunity)reader.ReadByte();
        character.AttacksPerRound = reader.ReadByte();
        character.BattleFlags = (BattleFlags)reader.ReadByte();
        character.Element = (CharacterElement)reader.ReadByte();
        character.SpellLearningPoints = reader.ReadWord();
        character.TrainingPoints = reader.ReadWord();
        character.Gold = reader.ReadWord();
        character.Food = reader.ReadWord();
        character.CharacterBitIndex = reader.ReadWord();
        character.Conditions = (Condition)reader.ReadWord();
        var defeatExperience = reader.ReadWord();
        if (monster)
            character.DefeatExperience = defeatExperience;
        character.BattleRoundSpellPointUsage = reader.ReadWord(); // Unknown
        // mark of return location is stored here: word x, word y, word mapIndex
        var markX = reader.ReadWord();
        var markY = reader.ReadWord();
        var markMap = reader.ReadWord();
        if (partyMember)
        {
            character.MarkOfReturnX = markX;
            character.MarkOfReturnY = markY;
            character.MarkOfReturnMapIndex = markMap;
        }
        for (var i = 0; i < character.Attributes.Length; i += 1) // Note: this includes Age and the 10th unused attribute
            character.Attributes[i] = _ReadValue(ref reader, true);
        for (var i = 0; i < character.Skills.Length; i += 1)
            character.Skills[i] = _ReadValue(ref reader, true);
        character.HitPoints = _ReadValue(ref reader, false);
        character.SpellPoints = _ReadValue(ref reader, false);
        character.BaseDefense = (int16)reader.ReadWord();
        character.BonusDefense = (int16)reader.ReadWord();
        character.BaseAttackDamage = (int16)reader.ReadWord();
        character.BonusAttackDamage = (int16)reader.ReadWord();
        character.MagicAttack = (int16)reader.ReadWord();
        character.MagicDefense = (int16)reader.ReadWord();
        character.AttacksPerRoundIncreaseLevels = reader.ReadWord();
        character.HitPointsPerLevel = reader.ReadWord();
        character.SpellPointsPerLevel = reader.ReadWord();
        character.SpellLearningPointsPerLevel = reader.ReadWord();
        character.TrainingPointsPerLevel = reader.ReadWord();
        character.LookAtCharTextIndex = reader.ReadWord();
        character.ExperiencePoints = reader.ReadDword();
        character.LearnedHealingSpells = reader.ReadDword();
        character.LearnedAlchemisticSpells = reader.ReadDword();
        character.LearnedMysticSpells = reader.ReadDword();
        character.LearnedDestructionSpells = reader.ReadDword();
        character.LearnedSpellsType5 = reader.ReadDword();
        character.LearnedSpellsType6 = reader.ReadDword();
        character.LearnedSpellsType7 = reader.ReadDword();
        character.TotalWeight = reader.ReadDword();
        var name = reader.ReadString(16);

        // the name up to the first 0, without spaces at the end (as in the original, a name that starts with 0 is
        // kept as it is, only without the spaces at the end)
        int zero = name.IndexOf('\0');
        character.Name = zero != 0 ? _TrimEndSpaces(zero > 0 ? name[0..zero] : name) : _TrimEndSpaces(name);

        if (!monster && character.LookAtCharTextIndex == 0xffff)
            character.LookAtCharTextIndex = 0; // fallback to text index 0, as there are some flawed characters

        if (character.Type != CharacterType.NPC)
        {
            // Equipment
            foreach (var slot in GetEnumValues<EquipmentSlot>())
            {
                if (slot != EquipmentSlot.None)
                    character.Equipment[(int)slot] = _ReadItemSlot(ref reader);
            }

            // Inventory
            for (var i = 0; i < InventoryWidth * InventoryHeight; i += 1)
                character.Inventory[i] = _ReadItemSlot(ref reader);
        }

        if (reader.Overrun())
            return error("[Data] Invalid character data.");
        return;
    }

    /// Reads a party member: the character, its events and its texts (null: none).
    /// @error the data is damaged.
    static Error<Character> ReadPartyMember(uint32 index, ref DataReader reader, Optional<DataReader> partyTextReader)
    {
        var character = Character.Create(CharacterType.PartyMember, index);
        try ReadCharacter(ref character, ref reader);
        try EventReader.ReadEvents(ref reader, character.Events, character.EventIds, character.EventList);
        if (partyTextReader is DataReader texts)
            character.Texts = TextReader.ReadTexts(texts);
        return character;
    }
}

// a character value: current, maximum, bonus and (with 'stored') stored value
CharacterValue _ReadValue(ref DataReader reader, bool stored)
{
    var value = CharacterValue { };
    value.CurrentValue = reader.ReadWord();
    value.MaxValue = reader.ReadWord();
    value.BonusValue = (int16)reader.ReadWord();
    if (stored)
        value.StoredValue = reader.ReadWord();
    return value;
}

ItemSlot _ReadItemSlot(ref DataReader reader)
{
    var slot = ItemSlot { };
    slot.Amount = reader.ReadByte();
    slot.NumRemainingCharges = reader.ReadByte();
    slot.RechargeTimes = reader.ReadByte();
    slot.Flags = (ItemSlotFlags)reader.ReadByte();
    slot.ItemIndex = reader.ReadWord();
    return slot;
}

string _TrimEndSpaces(StringSlice text)
{
    int end = text.Length;
    // string.TrimEnd() of .NET: all white space
    while (end > 0 && (text[end - 1] == ' ' || (text[end - 1] >= '\t' && text[end - 1] <= '\r')))
        end -= 1;
    return text[0..end].ToString();
}
