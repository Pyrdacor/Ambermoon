namespace Ambermoon.Data;

using System;

/// An item of the game.
struct Item
{
    uint32 Index;
    uint32 GraphicIndex;
    ItemType Type;
    EquipmentSlot EquipmentSlot;
    uint8 BreakChance;
    GenderFlag Genders;
    uint32 NumberOfHands;
    uint32 NumberOfFingers;
    int HitPoints;
    int SpellPoints;
    Optional<Attribute> Attribute;
    int AttributeValue;
    Optional<Skill> Skill;
    int SkillValue;
    int Defense;
    int Damage;
    /// Used if this is a ammunition.
    AmmunitionType AmmunitionType;
    /// Used if this is a long-ranged weapon with ammunition.
    AmmunitionType UsedAmmunitionType;
    Skill SkillPenalty1;
    uint32 SkillPenalty1Value;
    Skill SkillPenalty2;
    uint32 SkillPenalty2Value;
    /// The purpose of a special item, the transportation, the text index of a text scroll or the element of a weapon.
    uint8 SpecialValue;
    uint8 TextSubIndex;
    SpellSchool SpellSchool;
    uint8 SpellIndex;
    /// 255 = infinite
    uint8 InitialCharges;
    /// initial times of recharging
    uint8 InitialRecharges;
    /// only used by enchanter
    uint8 MaxRecharges;
    uint8 MaxCharges;
    /// if 0, use enchanter base price
    uint8 RechargePrice;
    /// M-B-R
    int MagicArmorLevel;
    /// M-B-W
    int MagicAttackLevel;
    ItemFlags Flags;
    ItemSlotFlags DefaultSlotFlags;
    ClassFlag Classes;
    uint32 Price;
    uint32 Weight;
    string Name;

    /// The element of a weapon (the special value).
    ItemElement Element()
    {
        return (ItemElement)SpecialValue;
    }

    /// The purpose of a special item (the special value).
    SpecialItemPurpose SpecialItemPurpose()
    {
        return (SpecialItemPurpose)SpecialValue;
    }

    /// The transportation of a transportation item (the special value).
    Transportation Transportation()
    {
        return (Transportation)SpecialValue;
    }

    /// The text index of a text scroll (the special value).
    uint32 TextIndex()
    {
        return SpecialValue;
    }

    Spell Spell()
    {
        return SpellIndex == 0 ? Spell.None : (Spell)((int)SpellSchool * 30 + SpellIndex);
    }

    bool IsUsable()
    {
        return Spell() != Spell.None || Type == ItemType.Potion || Type == ItemType.SpecialItem ||
               Type == ItemType.SpellScroll || Type == ItemType.TextScroll || Type == ItemType.Tool ||
               Type == ItemType.Transportation;
    }

    bool IsImportant()
    {
        return (Flags & ItemFlags.NotImportant) == ItemFlags.None && (Flags & ItemFlags.Cloneable) == ItemFlags.None;
    }

    bool CanBreak()
    {
        if (BreakChance == 0 || (Flags & (ItemFlags.Indestructible | ItemFlags.DestroyAfterUsage | ItemFlags.Stackable)) != ItemFlags.None)
            return false;
        switch (Type)
        {
            case ItemType.CloseRangeWeapon:
            case ItemType.LongRangeWeapon:
            case ItemType.Armor:
            case ItemType.Shield:
            case ItemType.Tool:
            case ItemType.NormalItem:
            case ItemType.TextScroll:
                return true;
            default:
                return false;
        }
    }
}
