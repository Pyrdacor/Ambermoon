namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data;

/// Reads and writes items (60 bytes each).
struct ItemReader
{
    /// Reads an item at the position of the reader.
    /// @error the item does not end with 0, or the data ends too early.
    static Error<Item> ReadItem(uint32 index, ref DataReader reader)
    {
        var item = Item { Index = index };
        item.GraphicIndex = reader.ReadByte();
        item.Type = (ItemType)reader.ReadByte();
        item.EquipmentSlot = (EquipmentSlot)reader.ReadByte();
        item.BreakChance = reader.ReadByte();
        item.Genders = (GenderFlag)reader.ReadByte();
        item.NumberOfHands = reader.ReadByte();
        item.NumberOfFingers = reader.ReadByte();
        item.HitPoints = (int8)reader.ReadByte();
        item.SpellPoints = (int8)reader.ReadByte();
        var attribute = (Attribute)reader.ReadByte();
        int attributeValue = (int8)reader.ReadByte();
        if (attributeValue != 0)
        {
            item.Attribute = attribute;
            item.AttributeValue = attributeValue;
        }
        var skill = (Skill)reader.ReadByte();
        int skillValue = (int8)reader.ReadByte();
        if (skillValue != 0)
        {
            item.Skill = skill;
            item.SkillValue = skillValue;
        }
        item.Defense = (int8)reader.ReadByte();
        item.Damage = (int8)reader.ReadByte();
        item.AmmunitionType = (AmmunitionType)reader.ReadByte();
        item.UsedAmmunitionType = (AmmunitionType)reader.ReadByte();
        // There are 4 items in Ambermoon which use this: the whip (01 00 0A 00), the banded armour (00 00 04 00), the
        // plate armour (00 00 06 00) and the knight's armour (00 00 08 00). Only the whip has an effect of -10 attack
        // skill as for the other 3 the first or second byte is 0.
        item.SkillPenalty1 = (Skill)reader.ReadByte();
        item.SkillPenalty2 = (Skill)reader.ReadByte();
        item.SkillPenalty1Value = reader.ReadByte();
        item.SkillPenalty2Value = reader.ReadByte();
        item.SpecialValue = reader.ReadByte();
        item.TextSubIndex = reader.ReadByte();
        item.SpellSchool = (SpellSchool)reader.ReadByte();
        item.SpellIndex = reader.ReadByte();
        item.InitialCharges = reader.ReadByte();
        item.InitialRecharges = reader.ReadByte();
        item.MaxRecharges = reader.ReadByte();
        item.MaxCharges = reader.ReadByte();
        item.RechargePrice = reader.ReadByte();
        item.MagicArmorLevel = (int8)reader.ReadByte();
        item.MagicAttackLevel = (int8)reader.ReadByte();
        item.Flags = (ItemFlags)reader.ReadByte();
        item.DefaultSlotFlags = (ItemSlotFlags)reader.ReadByte();
        item.Classes = (ClassFlag)reader.ReadWord();
        item.Price = reader.ReadWord();
        item.Weight = reader.ReadWord();
        item.Name = _TrimSpacesAndNulls(reader.ReadString(19));

        if (reader.ReadByte() != 0 || reader.Overrun()) // end of item
            return error("[Data] Invalid item data.");

        if ((item.Flags & ItemFlags.ExtendedGraphicIndex) != ItemFlags.None)
            item.GraphicIndex += 256;

        return item;
    }
}

// TrimEnd(' ', '\0')
string _TrimSpacesAndNulls(string text)
{
    int end = text.Length;
    while (end > 0 && (text[end - 1] == ' ' || text[end - 1] == 0))
        end -= 1;
    return text[0..end].ToString();
}
