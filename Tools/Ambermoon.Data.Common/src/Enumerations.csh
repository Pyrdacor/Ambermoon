//! The data model of Ambermoon (a part of Ambermoon.Data.Common of https://github.com/Pyrdacor/Ambermoon.net): the
//! events of maps and characters and the enumerations they use.
namespace Ambermoon.Data;

/// A primary attribute of a character.
enum Attribute : uint8
{
    Strength,
    Intelligence,
    Dexterity,
    Speed,
    Stamina,
    Charisma,
    Luck,
    AntiMagic,
    Age,
    BonusSpellDamage // Ambermoon Advanced only
}

/// A skill of a character.
enum Skill : uint8
{
    Attack,
    Parry,
    Swim,
    CriticalHit,
    FindTraps,
    DisarmTraps,
    LockPicking,
    Searching,
    ReadMagic,
    UseMagic
}

/// The class of a character.
enum Class : uint8
{
    Adventurer,
    Warrior,
    Paladin,
    Thief,
    Ranger,
    Healer,
    Alchemist,
    Mystic,
    Mage,
    Animal,
    Monster
}

/// Classes as flags ([Flags]).
enum ClassFlag : uint16
{
    None = 0x0000,
    Adventurer = 0x0001,
    Warrior = 0x0002,
    Paladin = 0x0004,
    Thief = 0x0008,
    Ranger = 0x0010,
    Healer = 0x0020,
    Alchemist = 0x0040,
    Mystic = 0x0080,
    Mage = 0x0100,
    Animal = 0x0200,
    Monster = 0x0400,
    Unknown1 = 0x0800,
    Unknown2 = 0x1000,
    Unknown3 = 0x2000,
    Unknown4 = 0x4000,
    AllWithUnused = 0x7fff,
    AllWithoutAnimal = 0x1ff,
    All = 0x03ff
}

/// The conditions (ailments) of a character ([Flags]).
enum Condition : uint16
{
    None = 0,
    Irritated = 0x0001,
    Crazy = 0x0002,
    Sleep = 0x0004,
    Panic = 0x0008,
    Blind = 0x0010,
    Drugged = 0x0020,
    Exhausted = 0x0040,
    Fleeing = 0x0080,
    Lamed = 0x0100,
    Poisoned = 0x0200,
    Petrified = 0x0400,
    Diseased = 0x0800,
    Aging = 0x1000,
    DeadCorpse = 0x2000,
    DeadAshes = 0x4000,
    DeadDust = 0x8000
}

/// The gender of a character.
enum Gender : uint8
{
    Male,
    Female
}

/// Genders as flags ([Flags]).
enum GenderFlag : uint8
{
    None = 0x00,
    Male = 0x01,
    Female = 0x02,
    Both = 0x03
}

/// Languages ([Flags]).
enum Language : uint8
{
    None = 0,
    Human = 0x01,
    Elfish = 0x02,
    Dwarfish = 0x04,
    Gnomish = 0x08,
    Sylphic = 0x10,
    Felinic = 0x20,
    Morag = 0x40,
    Animal = 0x80
}

/// More languages (Ambermoon Advanced, [Flags]).
enum ExtendedLanguage : uint8
{
    None = 0,
    Ancient = 0x01
}

/// The elements of a character ([Flags]).
enum CharacterElement : uint8
{
    None = 0,
    Mental = 0x01,
    Spirit = 0x02,
    Physical = 0x04,
    Undead = 0x08,
    Earth = 0x10,
    Wind = 0x20,
    Fire = 0x40,
    Water = 0x80
}

/// The kind of a map.
enum MapType : uint8
{
    Map3D = 1,
    Map2D = 2
}

/// The spell schools a character masters ([Flags]).
enum SpellTypeMastery : uint8
{
    None = 0x00,
    Healing = 0x01,
    Alchemistic = 0x02,
    Mystic = 0x04,
    Destruction = 0x08,
    Unused1 = 0x10,
    Unused2 = 0x20,
    Function = 0x40,
    All = 0x7f,
    Mastered = 0x80
}
