namespace Ambermoon.Data;

using System;
using Ambermoon;
using Ambermoon.Data.Enumerations;

/// A value of a character: the current value (without bonus; while exhausted the exhausted value), the maximum, the
/// bonus from equipment (negative for cursed items) and the stored value (the actual value while exhausted).
struct CharacterValue
{
    uint32 CurrentValue;
    uint32 MaxValue;
    int BonusValue;
    uint32 StoredValue;

    uint32 TotalCurrentValue()
    {
        int64 total = (int64)CurrentValue + BonusValue;
        return total < 0 ? 0 : (uint32)total;
    }

    uint32 TotalMaxValue()
    {
        int64 total = (int64)MaxValue + BonusValue;
        return total < 0 ? 0 : (uint32)total;
    }
}

/// A slot of an inventory or of the equipment.
struct ItemSlot
{
    uint32 ItemIndex;
    /// 0-255, 255 = unlimited
    int Amount;
    /// 0-255, 255 = unlimited
    int NumRemainingCharges;
    ItemSlotFlags Flags;
    /// How often the item was recharged. Only enchanters count, not the spell ChargeItem.
    uint8 RechargeTimes;

    bool Empty()
    {
        return Amount == 0;
    }

    bool Unlimited()
    {
        return Amount == 255;
    }

    bool Stacked()
    {
        return Amount > 1;
    }

    bool Draggable()
    {
        return ItemIndex != 0 && Amount != 0 && (Flags & ItemSlotFlags.Locked) == ItemSlotFlags.None;
    }
}

/// The size of an inventory.
const int InventoryWidth = 3;
const int InventoryHeight = 8;
/// The weight of a gold coin.
const uint32 GoldWeight = 5;

/// A character: a party member, an NPC or a monster (one struct for the three classes of the original; the fields of
/// the others are not used).
struct Character
{
    uint32 Index;
    CharacterType Type;
    Gender Gender;
    Race Race;
    Class Class;
    SpellTypeMastery SpellMastery;
    uint8 Level;
    uint8 NumberOfOccupiedHands;
    uint8 NumberOfOccupiedFingers;
    Language SpokenLanguages;
    ExtendedLanguage SpokenExtendedLanguages;
    /// This is not bound to conditions but its own "inventory is secret" flag
    bool InventoryInaccessible;
    uint8 PortraitIndex;
    /// Not used in Ambermoon.
    uint8 JoinPercentage;
    /// Not used in Ambermoon.
    uint8 SpellChancePercentage;
    /// Not used in Ambermoon.
    uint8 MagicHitBonus;
    SpellTypeImmunity SpellTypeImmunity;
    uint8 AttacksPerRound;
    CharacterElement Element;
    BattleFlags BattleFlags;
    uint16 SpellLearningPoints;
    uint16 TrainingPoints;
    uint16 Gold;
    uint16 Food;
    /// Is used for party members to identify their associated map character. 0xffff means "use the map character you
    /// talked to".
    uint16 CharacterBitIndex;
    Condition Conditions;
    /// Never used in Ambermoon.
    uint16 BattleRoundSpellPointUsage;
    /// 8 attributes, the age and a hidden attribute
    CharacterValue[] Attributes;
    CharacterValue[] Skills;
    CharacterValue HitPoints;
    CharacterValue SpellPoints;
    int16 BaseAttackDamage;
    int16 BaseDefense;
    int16 BonusAttackDamage;
    int16 BonusDefense;
    int16 MagicAttack;
    int16 MagicDefense;
    uint16 AttacksPerRoundIncreaseLevels;
    uint16 HitPointsPerLevel;
    uint16 SpellPointsPerLevel;
    uint16 SpellLearningPointsPerLevel;
    uint16 TrainingPointsPerLevel;
    /// 0 for most chars but there are exceptions like Dönner
    uint16 LookAtCharTextIndex;
    uint32 ExperiencePoints;
    uint32 LearnedHealingSpells;
    uint32 LearnedAlchemisticSpells;
    uint32 LearnedMysticSpells;
    uint32 LearnedDestructionSpells;
    uint32 LearnedSpellsType5;
    uint32 LearnedSpellsType6;
    uint32 LearnedSpellsType7;
    uint32 TotalWeight;
    string Name;
    /// The equipment by the slot (EquipmentSlot as index; 0 is not used).
    ItemSlot[] Equipment;
    /// The inventory (InventoryWidth * InventoryHeight slots).
    ItemSlot[] Inventory;

    // party members
    uint16 MarkOfReturnMapIndex;
    uint16 MarkOfReturnX;
    uint16 MarkOfReturnY;
    uint8 MaxReachedLevel;

    // party members and NPCs
    List<string> Texts;
    EventStore Events;
    List<int> EventIds;
    List<int> EventList;

    // monsters
    MonsterGraphicIndex CombatGraphicIndex;
    uint32 Morale;
    uint16 DefeatExperience;
    AdvancedMonsterFlags AdvancedMonsterFlags;

    /// An empty character of a type.
    static Character Create(CharacterType type, uint32 index)
    {
        var equipment = new ItemSlot[10];
        var inventory = new ItemSlot[InventoryWidth * InventoryHeight];
        return Character
        {
            Index = index,
            Type = type,
            Name = "",
            Attributes = new CharacterValue[10],
            Skills = new CharacterValue[10],
            Equipment = equipment,
            Inventory = inventory,
            Texts = List<string>.Create(),
            Events = EventStore.Create(),
            EventIds = List<int>.Create(),
            EventList = List<int>.Create()
        };
    }

    bool Alive()
    {
        return (Conditions & (Condition.DeadCorpse | Condition.DeadAshes | Condition.DeadDust)) == Condition.None;
    }

    bool HasAnySpell()
    {
        return LearnedHealingSpells != 0 || LearnedAlchemisticSpells != 0 || LearnedMysticSpells != 0 ||
               LearnedDestructionSpells != 0 || (Type == CharacterType.Monster && LearnedSpellsType7 != 0);
    }

    bool HasSpell(Spell spell)
    {
        int school = ((int)spell - 1) / 30;
        if (school < 0 || school > 3) // Only spells of the 4 main schools can be learned
            return false;
        int spellIndex = (int)spell - school * 30;
        uint32 bit = (uint32)1 << spellIndex;
        switch (school)
        {
            case 0: return (LearnedHealingSpells & bit) != 0;
            case 1: return (LearnedAlchemisticSpells & bit) != 0;
            case 2: return (LearnedMysticSpells & bit) != 0;
            default: return (LearnedDestructionSpells & bit) != 0;
        }
    }

    /// The learned spells of the 4 schools (and of school 7 for monsters), in the order of the spells.
    List<Spell> LearnedSpells()
    {
        var spells = List<Spell>.Create();
        _AddSpells(spells, LearnedHealingSpells, 0);
        _AddSpells(spells, LearnedAlchemisticSpells, 30);
        _AddSpells(spells, LearnedMysticSpells, 60);
        _AddSpells(spells, LearnedDestructionSpells, 90);
        if (Type == CharacterType.Monster)
            _AddSpells(spells, LearnedSpellsType7, 180);
        return spells;
    }

    static void _AddSpells(List<Spell> spells, uint32 bits, int offset)
    {
        for (var i = 1; i < 31; i += 1)
        {
            if ((bits & ((uint32)1 << i)) != 0)
                spells.Add((Spell)(i + offset));
        }
    }

    /// The maximum weight a party member can carry.
    uint32 MaxWeight()
    {
        return 999 + Attributes[(int)Attribute.Strength].TotalCurrentValue() * 1000;
    }
}
