namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;

/// Writes items (60 bytes each).
struct ItemWriter
{
    /// Writes an item: its values and its name (at most 19 characters, filled up with zeros to 20 bytes).
    static void WriteItem(Item item, ref DataWriter writer)
    {
        writer.WriteByte((uint8)(item.GraphicIndex % 256));
        writer.WriteByte((uint8)item.Type);
        writer.WriteByte((uint8)item.EquipmentSlot);
        writer.WriteByte(item.BreakChance);
        writer.WriteByte((uint8)item.Genders);
        writer.WriteByte((uint8)(item.NumberOfHands & 0xff));
        writer.WriteByte((uint8)(item.NumberOfFingers & 0xff));
        writer.WriteByte(_SignedByte(item.HitPoints));
        writer.WriteByte(_SignedByte(item.SpellPoints));
        if (item.Attribute is Attribute attribute)
        {
            writer.WriteByte((uint8)attribute);
            writer.WriteByte(_SignedByte(item.AttributeValue));
        }
        else
        {
            writer.WriteByte(0);
            writer.WriteByte(0);
        }
        if (item.Skill is Skill skill)
        {
            writer.WriteByte((uint8)skill);
            writer.WriteByte(_SignedByte(item.SkillValue));
        }
        else
        {
            writer.WriteByte(0);
            writer.WriteByte(0);
        }
        writer.WriteByte(_SignedByte(item.Defense));
        writer.WriteByte(_SignedByte(item.Damage));
        writer.WriteByte((uint8)item.AmmunitionType);
        writer.WriteByte((uint8)item.UsedAmmunitionType);
        writer.WriteByte((uint8)item.SkillPenalty1);
        writer.WriteByte((uint8)item.SkillPenalty2);
        writer.WriteByte((uint8)(item.SkillPenalty1Value & 0xff));
        writer.WriteByte((uint8)(item.SkillPenalty2Value & 0xff));
        writer.WriteByte(item.SpecialValue);
        writer.WriteByte(item.TextSubIndex);
        writer.WriteByte((uint8)item.SpellSchool);
        writer.WriteByte(item.SpellIndex);
        writer.WriteByte(item.InitialCharges);
        writer.WriteByte(item.InitialRecharges);
        writer.WriteByte(item.MaxRecharges);
        writer.WriteByte(item.MaxCharges);
        writer.WriteByte(item.RechargePrice);
        writer.WriteByte(_SignedByte(item.MagicArmorLevel));
        writer.WriteByte(_SignedByte(item.MagicAttackLevel));
        var flags = item.Flags;
        if (item.GraphicIndex >= 256)
            flags |= ItemFlags.ExtendedGraphicIndex;
        writer.WriteByte((uint8)flags);
        writer.WriteByte((uint8)item.DefaultSlotFlags);
        writer.WriteWord((uint16)item.Classes);
        writer.WriteWord((uint16)(item.Price & 0xffff));
        writer.WriteWord((uint16)(item.Weight & 0xffff));
        var name = AmbermoonEncoding.GetBytes(_FirstCharacters(item.Name, 19));
        writer.WriteBytes(name);
        for (var i = name.Length; i < 20; i += 1)
            writer.WriteByte(0);
    }

    static uint8 _SignedByte(int value)
    {
        return (uint8)(value & 0xff);
    }
}

// the first characters of a text (all if it has fewer)
StringSlice _FirstCharacters(StringSlice text, int count)
{
    int i = 0;
    while (i < text.Length && count > 0)
    {
        uint8 b = text[i];
        i += b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        count -= 1;
    }
    return text[0..(i < text.Length ? i : text.Length)];
}
