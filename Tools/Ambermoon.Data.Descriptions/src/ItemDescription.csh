namespace Ambermoon.Data.Descriptions;

using System;
using Ambermoon;
using Ambermoon.Data;

/// The values of an item in the order of their bytes (ItemDescription.ValueDescriptions of the original; the name
/// follows them).
ValueDescription[] ItemValueDescriptions()
{
    var skill = EnumInfo.Of<Skill>(false);
    var ammunitionType = EnumInfo.Of<AmmunitionType>(false);
    return [
        Use.Byte("GraphicIndex", true),
        Use.Enum(EnumInfo.Of<ItemType>(false), "Type", true),
        Use.Enum(EnumInfo.Of<EquipmentSlot>(false), "EquipmentSlot", false, (int64)EquipmentSlot.None),
        Use.Byte("BreakChance", false),
        Use.Enum(EnumInfo.Of<GenderFlag>(true), "Genders", false, (int64)GenderFlag.Both),
        Use.Byte("NumberOfHands", false),
        Use.Byte("NumberOfFingers", false),
        Use.SByte("HitPoints", false),
        Use.SByte("SpellPoints", false),
        Use.Enum(EnumInfo.Of<Attribute>(false), "Attribute", false),
        Use.SByte("AttributeValue", false),
        Use.Enum(skill, "Skill", false),
        Use.SByte("SkillValue", false),
        Use.SByte("Defense", false),
        Use.SByte("Damage", false),
        Use.Enum(ammunitionType, "AmmunitionType", false),
        Use.Enum(ammunitionType, "UsedAmmunitionType", false),
        Use.Enum(skill, "SkillPenalty1", false),
        Use.Enum(skill, "SkillPenalty2", false),
        Use.Byte("SkillPenalty1Value", false),
        Use.Byte("SkillPenalty2Value", false),
        Use.Byte("SpecialValue", false),
        Use.Byte("TextSubIndex", false),
        Use.Enum(EnumInfo.Of<SpellSchool>(false), "SpellSchool", false),
        Use.Byte("SpellIndex", false),
        Use.Byte("InitialCharges", false),
        Use.Byte("UnknownByte26", false),
        Use.Byte("MaxRecharges", false),
        Use.Byte("MaxCharges", false),
        Use.Byte("UnknownByte29", false),
        Use.SByte("MagicArmorLevel", false),
        Use.SByte("MagicAttackLevel", false),
        Use.Flags8(EnumInfo.Of<ItemFlags>(true), "Flags", true),
        Use.Flags8(EnumInfo.Of<ItemSlotFlags>(true), "DefaultSlotFlags", false),
        Use.Flags16(EnumInfo.Of<ClassFlag>(true), "Classes", false, (int64)(ClassFlag.All | ClassFlag.Monster)),
        Use.Word("Price", true),
        Use.Word("Weight", true)
    ];
}
