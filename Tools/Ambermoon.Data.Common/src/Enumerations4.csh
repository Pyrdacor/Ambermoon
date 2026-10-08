namespace Ambermoon.Data.Enumerations;

using System;

// Enumerations of Ambermoon.Data.Common (Enumerations/*.cs in the namespace Ambermoon.Data.Enumerations).

enum ButtonType : int32
{
    // 78 with 32 pixel wide and 13 pixel high
    TurnLeft,
    MoveForward,
    TurnRight,
    StrafeLeft,
    StrafeRight,
    RotateLeft,
    MoveBackward,
    RotateRight,
    MoveUpLeft,
    MoveUp,
    MoveUpRight,
    MoveLeft,
    MoveRight,
    MoveDownLeft,
    MoveDown,
    MoveDownRight,
    Eye,
    Hand,
    Mouth,
    Transport,
    Spells,
    Camp,
    Map,
    BattlePositions,
    Options,
    Empty,
    Yes,
    No,
    Ok,
    Exit,
    BuyHorse,
    BuyRaft,
    BuyBoat,
    BuyItem,
    BuyFood,
    SellItem,
    RepairItem,
    RechargeItem,
    HealCondition,
    HealPerson,
    RemoveCurse,
    Train,
    Equipment, // sage (3x3 grid)
    GiveItem,
    GiveFoodToNPC,
    GiveGoldToNPC,
    AskToJoin,
    AskToLeave,
    Attack,
    Defend,
    Flee,
    Stats,
    Inventory,
    UseItem,
    ViewItem, // also show item
    GiveGold,
    GiveFood,
    DropItem,
    DropGold,
    DropFood,
    StoreItem,
    StoreGold,
    StoreFood,
    Lockpick,
    FindTrap,
    DisarmTrap,
    DistributeFood,
    DistributeGold,
    Sleep,
    Ear, // re-hear riddle
    ReadScroll,
    Wait, // hourglass
    Save,
    Load,
    Quit,
    Opt,
    Male, // symbol
    Female // symbol
}

enum Song : uint8
{
    Default,
    /// Gnome mine
    WhoSaidHiHo,
    /// Morag places and sand lizard
    MellowCamelFunk,
    /// Dwarfs, forest moon indoor
    CloseToTheHedge,
    /// Gemstone
    VoiceOfTheBagpipe,
    /// Spannenberg
    Downtown,
    /// Ship
    Ship,
    /// Eagle
    WholeLottaDove,
    /// Horse
    HorseIsNoDisgrace,
    /// Tavern I
    DontLookBach,
    /// Tavern II
    RoughWaterfrontTavern,
    /// Battle theme
    SapphireFireballsOfPureLove,
    /// Temple of life
    TheAumRemainsTheSame,
    /// Capital
    Capital,
    /// World map
    PloddingAlong,
    /// Magical fly disc
    CompactDisc,
    /// Raft
    RiversideTravellingBlues,
    /// Thief guild
    NobodysVaultButMine,
    /// Grandfather's cellar
    LaCryptaStrangiato,
    /// Alchemist tower
    MistyDungeonHop,
    /// Witch's broom, Nera's house
    BurnBabyBurn,
    /// Camp, Inn
    BarBrawlin,
    /// Sand ship
    PsychedelicDuneGroove,
    /// Level up
    StairwayToLevel50,
    /// Undeads
    ThatHunchIsBack,
    /// Superman mode, Thalion office
    ChickenSoup,
    /// Luminor's tower
    DragonChaseInCreepyDungeon,
    /// Harp, Matthias in Illien
    HisMastersVoice,
    /// House of healers (has no title)
    NoName,
    /// Magic effect (touching pulsing lights, wishing well, etc)
    OhNoNotAnotherMagicalEvent,
    /// Dramatic events
    TheUhOhSong,
    /// Grandfather theme
    OwnerOfALonelySword,
    /// Game over
    GameOver,
    /// Intro music
    Intro,
    /// Outro music
    Outro,
    /// Menu music
    Menu
}

enum UIGraphic : int32
{
    DisabledOverlay16x16,
    FrameUpperLeft,
    FrameLeft,
    FrameLowerLeft,
    FrameTop,
    FrameBottom,
    FrameUpperRight,
    FrameRight,
    FrameLowerRight,
    StatusDead,
    StatusAttack,
    StatusDefend,
    StatusUseMagic,
    StatusFlee,
    StatusMove,
    StatusUseItem,
    StatusHandStop,
    StatusHandTake,
    StatusLamed,
    StatusPoisoned,
    StatusPetrified,
    StatusDiseased,
    StatusAging,
    StatusIrritated,
    StatusCrazy,
    StatusSleep,
    StatusPanic,
    StatusBlind,
    StatusOverweight,
    StatusDrugs,
    StatusExhausted,
    StatusRangeAttack,
    Eagle, // 32x29 (5-bit)
    DamageSplash, // 32x26 (5-bit)
    Ouch, // 32x23
    StarBlinkAnimation, // 4 frames (16x9, 5-bit)
    PlusBlinkAnimation, // 4 frames (16x10)
    LeftPortraitBorder, // 16x36
    CharacterValueBarFrames, // 16x36
    RightPortraitBorder, // 16x36
    SmallBorder1, // 16x1
    SmallBorder2, // 16x1
    Candle, // light buff icon (16x16)
    Shield, // magic protection buff icon (16x16)
    Sword, // magic attack buff icon (16x16)
    Star, // anti-magic buff icon (16x16)
    Eye, // clairvoyance buff icon (16x16)
    Map, // mystic map buff icon (16x16)
    Windchain, // 32x15
    MonsterEyeInactive, // 32x32
    MonsterEyeActive, // 32x32
    Night, // 32x32
    Dusk, // 32x32
    Day, // 32x32
    Dawn, // 32x32
    ButtonFrame, // 32x17
    ButtonFramePressed, // 32x17
    ButtonDisabledOverlay, // 32x11 (1-bit)
    Compass, // 32x32
    Attack, // 16x9
    Defense, // 16x9
    Skull, // 32x34
    EmptyCharacterSlot, // 32x34
    ItemConsume, // 11 frames with 16x16 pixels
    Talisman, // healer's golden symbol / talisman (32x29, 5-bit)
    Unused, // seems to be unused in original code, 26 bytes
    BrokenItemOverlay, // 16x16 (1-bit) is colored with color index 26
    CatSkull // Ambermoon Advanced only
}

enum MonsterGraphicIndex : int32
{
    None,
    Gargoyle,
    Undead,
    Demon,
    Orc,
    Lizard,
    Giant,
    Knight,
    MoragDragon,
    Golem,
    Hyrda,
    Magician,
    Minotaur,
    Nera,
    MagicGuard,
    FireDragon,
    Spider,
    Bandit,
    Beast,
    EnergySphere,
    MoranianMagician,
    AntiqueGuard,
    CurseWesp,
    Tornak,
    Gizzek,
    MoragMachine,
    SingleEye // Added in Ambermoon Advanced
}

enum MonsterAnimationType : uint8
{
    Move, // also used for random idle animation
    CloseRangedAttack,
    LongRangedAttack,
    Cast,
    Hurt,
    Die,
    Start, // played at start of battle
    Unknown3
}

