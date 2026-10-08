namespace Ambermoon.Data;

using System;

// Enumerations of Ambermoon.Data.Common (Enumerations/*.cs in the namespace Ambermoon.Data).

enum EquipmentSlot : uint8
{
    None,
    Neck, // chains
    Head, // headgear
    Chest, // brooches
    RightHand, // weapon
    Body, // armor
    LeftHand, // shield, ammunition
    RightFinger, // rings
    Feet, // footgear
    LeftFinger // rings
}

enum Race : uint8
{
    Human,
    Elf,
    Dwarf,
    Gnome,
    HalfElf,
    Sylphe,
    Felinic,
    Moranian,
    Thalionic, // only Netsrak
    Unknown9,
    Unknown10,
    Unknown11,
    Unknown12,
    Animal, // only Necros the cat NPC on Nera's isle
    Monster, // all non-human monsters
    Unknown15
}

enum World : uint8
{
    Lyramion,
    ForestMoon,
    Morag
}

/// [Flags]
enum ItemElement : uint8
{
    None = 0,
    Spirit = 1,
    Undead = 3,
    Earth = 4,
    Wind = 5,
    Fire = 6,
    Water = 7
}

/// [Flags]
enum ItemFlags : uint8
{
    None = 0,
    /// If equipped it can't be unequipped until the curse
    /// is removed. Moreover all addtions like attributes,
    /// LP or SP are subtracted instead of added.
    Accursed = 0x01,
    /// Item is not important and therefore can be sold. Items without this
    /// flag can not be left after battles, in conversations or at merchants.
    /// They also can't be dropped or sold at merchants without this flag.
    NotImportant = 0x02,
    Stackable = 0x04,
    /// Mostly used for armor but also for some other
    /// equipment like pickaxe or Valdyn's boots.
    RemovableDuringFight = 0x08,
    /// After using the last charge the item will be destroyed.
    DestroyAfterUsage = 0x10,
    /// If set for weapons, armor, tools, text and normal items
    /// this will stop the items from breaking.
    Indestructible = 0x20,
    /// Item can be duplicated.
    Cloneable = 0x40,
    /// If given, the graphic index is 256 higher than the given one.
    /// This allows more than 256 graphics for items.
    ExtendedGraphicIndex = 0x80
}

/// [Flags]
enum ItemSlotFlags : uint8
{
    None = 0,
    /// Magic item is identified already.
    Identified = 0x01,
    /// Item is broken.
    /// Can not be used nor equipped before repaired.
    Broken = 0x02,
    /// Only cursed equipment slots use this flag.
    /// If true, the item bonus is negative. Affected are:
    /// - Bonus HP
    /// - Bonus SP
    /// - Damage
    /// - Defense
    /// - Bonus Attribute
    /// - Bonus Skill
    /// Cursed items can only be removed by using a Remove Curse spell
    /// in which case they are destroyed completely. If a cursed item
    /// is not equipped, the curse has no effect until it is equipped.
    Cursed = 0x04,
    /// Advanced only. Can not drag the item.
    /// Mainly used for cat items which resemble skills.
    Locked = 0x08
}

enum ItemType : uint8
{
    None,
    Armor,
    Headgear,
    Footgear,
    Shield,
    CloseRangeWeapon,
    LongRangeWeapon,
    Ammunition,
    TextScroll,
    SpellScroll,
    Potion,
    Amulet,
    Brooch,
    Ring,
    Gem,
    Tool,
    Key,
    NormalItem, // collectable / loot
    MagicalItem, // lantern, torch, etc
    SpecialItem, // clock, monster eye, compass, etc
    Transportation, // witch broom, flute, magical flying disc, etc
    Condition
}

enum SpellSchool : uint8
{
    Healing,
    Alchemistic,
    Mystic,
    Destruction,
    Unknown1,
    Unknown2,
    Function // lockpicking, call eagle, play elf harp etc
}

enum Spell : int32
{
    None,
    HealingHand,
    RemoveFear,
    RemovePanic,
    RemoveShadows,
    RemoveBlindness,
    RemovePain,
    RemoveDisease,
    SmallHealing,
    RemovePoison,
    NeutralizePoison,
    MediumHealing,
    DispellUndead,
    DestroyUndead,
    HolyWord,
    WakeTheDead,
    ChangeAshes,
    ChangeDust,
    GreatHealing,
    MassHealing,
    Resurrection,
    RemoveRigidness,
    RemoveLamedness,
    HealAging,
    StopAging,
    StoneToFlesh,
    WakeUp,
    RemoveIrritation,
    RemoveDrugged,
    RemoveMadness,
    RestoreStamina,
    ChargeItem,
    Light,
    MagicalTorch,
    MagicalLantern,
    MagicalSun,
    GhostWeapon,
    CreateFood,
    RemoveCurses,
    Blink,
    Jump,
    Escape,
    WordOfMarking,
    WordOfReturning,
    MagicalShield,
    MagicalWall,
    MagicalBarrier,
    MagicalWeapon,
    MagicalAssault,
    MagicalAttack,
    Levitation,
    AntiMagicWall,
    AntiMagicSphere,
    AlchemisticGlobe,
    Hurry,
    MassHurry,
    RepairItem,
    DuplicateItem,
    LPStealer,
    SPStealer,
    GhostInferno, // Advanced only
    MonsterKnowledge,
    Identification,
    Knowledge,
    Clairvoyance,
    SeeTheTruth,
    MapView,
    MagicalCompass,
    FindTraps,
    FindMonsters,
    FindPersons,
    FindSecretDoors,
    MysticalMapping,
    MysticalMapI,
    MysticalMapII,
    MysticalMapIII,
    MysticalGlobe,
    ShowMonsterLP,
    ShowElements, // Advanced only
    RecognizeWeakPoint, // Advanced only
    SeeWeaknesses, // Advanced only
    KnowledgeOfTheWeakness, // Advanced only
    ForeseeMagic, // Advanced only
    ForeseeAttack, // Advanced only
    MysticDecay, // Advanced only
    ProtectionSphere, // Advanced only
    ElementToEarth, // Advanced only
    ElementToWind, // Advanced only
    ElementToFire, // Advanced only
    ElementToWater, // Advanced only
    MysticImitation, // Advanced only
    MagicalProjectile,
    MagicalArrows,
    Lame,
    Poison,
    Petrify,
    CauseDisease,
    CauseAging,
    Irritate,
    CauseMadness,
    Sleep,
    Fear,
    Blind,
    Drug,
    DissolveVictim,
    Mudsling,
    Rockfall,
    Earthslide,
    Earthquake,
    Winddevil,
    Windhowler,
    Thunderbolt,
    Whirlwind,
    Firebeam,
    Fireball,
    Firestorm,
    Firepillar,
    Waterfall,
    Iceball,
    Icestorm,
    Iceshower,
    // Special spells
    Lockpicking = 181, // 6 * 30 + 1
    CallEagle = 182,
    DecreaseAge = 183, // youth potion / youth
    PlayElfHarp = 184, // magic music
    SpellPointsI = 185,
    SpellPointsII = 186,
    SpellPointsIII = 187,
    SpellPointsIV = 188,
    SpellPointsV = 189,
    AllHealing = 190, // all healing potion
    MagicalMap = 191,
    AddStrength = 192,
    AddIntelligence = 193,
    AddDexterity = 194,
    AddSpeed = 195,
    AddStamina = 196,
    AddCharisma = 197,
    AddLuck = 198,
    AddAntiMagic = 199,
    Rope = 200, // levitation on a rope / climb
    Drugs = 201, // stinking mushroom
    SelfHealing = 202, // Advanced only
    SelfReviving = 203, // Advanced only
    ExpExchange = 204, // Advanced only
    MountWasp = 205, // Advanced only
    MagicSwordAttack = 206, // Advanced only
}

enum AmmunitionType : uint8
{
    None,
    Slingstone,
    Arrow,
    Bolt,
    Slingdagger
}

enum Transportation : uint8
{
    FlyingDisc = 4,
    WitchBroom = 8
}

enum SpecialItemPurpose : uint8
{
    Compass,
    MonsterEye,
    DayTime, // magic picture
    WindChain,
    MapLocation,
    Clock
}

enum CharacterType : uint8
{
    PartyMember,
    NPC,
    Monster,
    MapObject // e.g. moving spider on ceiling
}

/// [Flags]
enum SpellTypeImmunity : uint8
{
    None = 0x00,
    Healing = 0x01,
    Alchemistic = 0x02,
    Mystic = 0x04,
    Destruction = 0x08,
    Unused1 = 0x10,
    Unused2 = 0x20,
    Function = 0x40,
    Unused = 0x80
}

/// [Flags]
enum BattleFlags : uint8
{
    None = 0,
    Undead = 0x01, // can be killed by holy spells
    Demon = 0x02,
    Boss = 0x04, // immune to Fear, Paralyze, Petrify, DissolveVictim, Madness, Drugs, Irritation and won't flee
    Animal = 0x08,
    EarthSpellDamageBonus = 0x10,
    WindSpellDamageBonus = 0x20,
    FireSpellDamageBonus = 0x40
}

/// [Flags]
enum AdvancedMonsterFlags : uint8
{
    None = 0,
    ImmuneToNonElementalAttacks = 0x01,
    ImmuneToSpiritAttacks = 0x02,
    ImmuneToUndeadAttacks = 0x08,
    ImmuneToEarthAttacks = 0x10,
    ImmuneToWindAttacks = 0x20,
    ImmuneToFireAttacks = 0x40,
    ImmuneToWaterAttacks = 0x80
}
