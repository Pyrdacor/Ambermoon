namespace Ambermoon.Data.Descriptions
{
    public static class ItemDescription
    {
        public static ValueDescription[] ValueDescriptions { get; }

        static ItemDescription()
        {
            ValueDescriptions = Create
            (
                Use.Byte("GraphicIndex", true),
                Use.Enum<ItemType>("Type", true),
                Use.Enum("EquipmentSlot", false, EquipmentSlot.None),
                Use.Byte("BreakChance", false),
                Use.Enum("Genders", false, GenderFlag.Both),
                Use.Byte("NumberOfHands", false),
                Use.Byte("NumberOfFingers", false),
                Use.SByte("HitPoints", false),
                Use.SByte("SpellPoints", false),
                Use.Enum<Attribute>("Attribute", false),
                Use.SByte("AttributeValue", false),
                Use.Enum<Ability>("Ability", false),
                Use.SByte("AbilityValue", false),
                Use.SByte("Defense", false),
                Use.SByte("Damage", false),
                Use.Enum<AmmunitionType>("AmmunitionType", false),
                Use.Enum<AmmunitionType>("UsedAmmunitionType", false),
                Use.Enum<Ability>("SkillPenalty1", false),
                Use.Enum<Ability>("SkillPenalty2", false),
                Use.Byte("SkillPenalty1Value", false),
                Use.Byte("SkillPenalty2Value", false),
                Use.Byte("SpecialValue", false),
                Use.Byte("TextSubIndex", false),
                Use.Enum<SpellSchool>("SpellSchool", false),
                Use.Byte("SpellIndex", false),
                Use.Byte("InitialCharges", false),
                Use.Byte("UnknownByte26", false),
                Use.Byte("MaxRecharges", false),
                Use.Byte("MaxCharges", false),
                Use.Byte("UnknownByte29", false),
                Use.SByte("MagicArmorLevel", false),
                Use.SByte("MagicAttackLevel", false),
                Use.Flags8<ItemFlags>("Flags", true),
                Use.Flags8<ItemSlotFlags>("DefaultSlotFlags", false),
                Use.Flags16("Classes", false, ClassFlag.All | ClassFlag.Monster),
                Use.Word("Price", true),
                Use.Word("Weight", true)
            );
        }

        static ValueDescription[] Create(params ValueDescription[] valueDescriptions) => valueDescriptions;
    }
}
