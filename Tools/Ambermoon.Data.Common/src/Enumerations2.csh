namespace Ambermoon.Data.Enumerations;

/// The buffs of the active spells.
enum ActiveSpellType : uint8
{
    Light,
    Protection,
    Attack,
    AntiMagic,
    Clairvoyance,
    MysticMap
}

/// What a tile of a 3D map shows on the automap.
enum AutomapType : uint16
{
    None,
    Wall,
    Riddlemouth,
    Teleporter,
    Spinner,
    Trap,
    Trapdoor,
    Special,
    Monster,
    Door,
    DoorOpen,
    Merchant,
    Tavern,
    Chest,
    Exit,
    ChestOpened,
    Pile,
    Person,
    GotoPoint,
    Invalid = 0xffff
}

/// The game options (not [Flags]: a combination has no name).
enum Option : uint16
{
    Music = 0x01,
    FastBattleMode = 0x02,
    TextJustification = 0x04,
    FloorTexture3D = 0x08,
    CeilingTexture3D = 0x10,
    ValdynTalkedToSheera = 0x4000,
    FoundYellowSphere = 0x8000
}

/// The kinds of places.
enum PlaceType : uint8
{
    Trainer,
    Healer,
    Sage,
    Enchanter,
    Inn,
    Merchant,
    FoodDealer,
    Library,
    RaftDealer,
    ShipDealer,
    HorseDealer,
    Blacksmith
}

/// How the party travels.
enum TravelType : uint8
{
    Walk,
    Horse,
    Raft,
    Ship,
    MagicalDisc,
    Eagle,
    Fly,
    Swim,
    WitchBroom,
    SandLizard,
    SandShip,
    Wasp // Ambermoon Advanced only
}
