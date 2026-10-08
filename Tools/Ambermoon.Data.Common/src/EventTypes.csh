namespace Ambermoon.Data;

/// The kind of an event (the first byte of its data).
enum EventType : int32
{
    /// Not used.
    Invalid,
    /// Map transitions, teleporters, windgates, etc.
    Teleport,
    /// Locked doors.
    Door,
    /// Chests and lootable map objects (also locked chests).
    Chest,
    /// Shows a text popup.
    MapText,
    /// Rotates the player to a random direction.
    Spinner,
    /// Hurts the player (map traps, fire, chest/door traps, etc).
    Trap,
    /// Removes one or all buffs.
    ChangeBuffs,
    /// Opens the riddlemouth window with some riddle.
    Riddlemouth,
    /// Rewards and punishments.
    Reward,
    /// Changes map tiles.
    ChangeTile,
    /// Starts a battle with a monster group.
    StartBattle,
    /// Enters a place like merchants, healer, etc.
    EnterPlace,
    /// Tests some condition.
    Condition,
    /// Executes some action.
    Action,
    /// Dice roll against some percent value.
    Dice100Roll,
    /// Starts a conversation event chain by user input.
    Conversation,
    /// Prints conversation text (conversation only).
    PrintText,
    /// Creates items (conversation only).
    Create,
    /// Yes/No popup with text.
    Decision,
    /// Changes music to a new song or the default map song.
    ChangeMusic,
    /// Exits conversations (conversation only).
    Exit,
    /// Spawns transports like ships or horses.
    Spawn,
    /// Executes conversation actions like giving the item/gold/food or join/leave the party (conversation only).
    Interact,
    /// Removes a party member and optionally stores its belongings in one or two chests.
    RemovePartyMember,
    /// Adds a non-interactive game delay (Ambermoon Advanced only).
    Delay,
    /// Tests some condition for a specific party member (Ambermoon Advanced only).
    PartyMemberCondition,
    /// Shakes the screen (Ambermoon Advanced only).
    Shake,
    /// Shows the dungeon map (Ambermoon Advanced only).
    ShowMap,
    /// Toggles the event tile appearance and optionally 1-4 global variables.
    ToggleSwitch,
    /// Dynamically changes a tile based on the state of a global variable.
    DynamicChangeTile,
    /// Changes exploration of a rectangular map area.
    RectangularExploration,
    /// Reveals up to 3 vertical lines on the current dungeon map.
    VerticalLineReveal
}

/// TeleportEvent.TransitionType
enum TransitionType : int32
{
    MapChange,
    Teleporter,
    WindGate,
    Climbing,
    Outro,
    Falling
}

/// ChestEvent.ChestFlags ([Flags])
enum ChestFlags : uint8
{
    None = 0,
    /// Close the chest window when looted.
    Treasure = 0x01,
    /// The chest contents are restored after closing the window.
    NoSave = 0x02,
    /// An extended chest (Ambermoon Advanced only).
    ExtendedChest = 0x04
}

/// When text popups and traps trigger ([Flags]).
enum EventTrigger : int32
{
    None = 0,
    Move = 0x01,
    EyeCursor = 0x02,
    Always = Move | EyeCursor
}

/// TrapEvent.TrapAilment
enum TrapAilment : int32
{
    None,
    Crazy,
    Blind,
    Stoned,
    Paralyzed,
    Poisoned,
    Petrified,
    Diseased,
    Aging,
    Dead
}

/// TrapEvent.TrapTarget
enum TrapTarget : int32
{
    ActivePlayer,
    All
}

/// RewardEvent.RewardType
enum RewardType : int32
{
    Attribute = 0x00,
    Skill = 0x01,
    HitPoints = 0x02,
    SpellPoints = 0x03,
    SpellLearningPoints = 0x04,
    Conditions = 0x05,
    UsableSpellTypes = 0x06,
    Languages = 0x07,
    Experience = 0x08,
    MaxAttribute = 0x09,
    AttacksPerRound = 0x0a,
    TrainingPoints = 0x0b,
    Level = 0x0c,
    Damage = 0x0d,
    Defense = 0x0e,
    MaxHitPoints = 0x0f,
    MaxSpellPoints = 0x10,
    EmpowerSpells = 0x11,
    ChangePortrait = 0x12,
    MaxSkill = 0x13,
    MagicArmorLevel = 0x14,
    MagicWeaponLevel = 0x15,
    Spells = 0x16
}

/// RewardEvent.RewardOperation
enum RewardOperation : int32
{
    Increase,
    Decrease,
    IncreasePercentage,
    DecreasePercentage,
    Fill,
    Remove,
    Add,
    Toggle
}

/// RewardEvent.RewardTarget
enum RewardTarget : int32
{
    ActivePlayer,
    All,
    RandomPlayer, // Ambermoon Advanced only
    FirstAnimal, // Ambermoon Advanced only
    FirstPartyMember = 100,
    AllButFirstPartyMember = 200
}

/// ConditionEvent.ConditionType
enum ConditionType : int32
{
    GlobalVariable = 0x00,
    EventBit = 0x01,
    DoorOpen = 0x02,
    ChestOpen = 0x03,
    CharacterBit = 0x04,
    PartyMember = 0x05,
    ItemOwned = 0x06,
    UseItem = 0x07,
    KnowsKeyword = 0x08,
    LastEventResult = 0x09,
    GameOptionSet = 0x0a,
    CanSee = 0x0b,
    Direction = 0x0c,
    HasCondition = 0x0d,
    Hand = 0x0e,
    SayWord = 0x0f,
    EnterNumber = 0x10,
    Levitating = 0x11,
    HasGold = 0x12,
    HasFood = 0x13,
    Eye = 0x14,
    Mouth = 0x15,
    TransportAtLocation = 0x16,
    MultiCursor = 0x17,
    TravelType = 0x18,
    LeadClass = 0x19,
    SpellEmpowered = 0x1a,
    IsNight = 0x1b,
    Attribute = 0x1c,
    Skill = 0x1d,
    HourTime = 0x1e
}

/// PartyMemberConditionEvent.PartyMemberConditionType
enum PartyMemberConditionType : uint8
{
    Level = 0x00,
    Attribute = 0x01,
    Skill = 0x02,
    TrainingPoints = 0x03,
    Language = 0x04
}

/// PartyMemberConditionEvent.PartyMemberConditionTarget
enum PartyMemberConditionTarget : uint8
{
    ActivePlayer,
    All,
    Any,
    Min,
    Max,
    Average,
    Random,
    FirstCharacter,
    ActiveInventory = 0xff
}

/// ActionEvent.ActionType
enum ActionType : int32
{
    SetGlobalVariable = 0x00,
    SetEventBit = 0x01,
    LockDoor = 0x02,
    LockChest = 0x03,
    SetCharacterBit = 0x04,
    AddItem = 0x06,
    AddKeyword = 0x08,
    SetGameOption = 0x0a,
    SetDirection = 0x0c,
    AddCondition = 0x0d,
    AddGold = 0x12,
    AddFood = 0x13
}

/// ConversationEvent.InteractionType
enum InteractionType : int32
{
    Keyword = 0,
    ShowItem = 1,
    GiveItem = 2,
    GiveGold = 3,
    GiveFood = 4,
    JoinParty = 5,
    LeaveParty = 6,
    Talk = 7,
    Leave = 8
}

/// CreateEvent.CreateType
enum CreateType : int32
{
    Item,
    Gold,
    Food
}

/// ShowMapEvent.MapOptions ([Flags])
enum MapOptions : int32
{
    None = 0,
    ShowSecretDoors = 0x1,
    ShowMonsters = 0x2,
    ShowPersons = 0x4,
    ShowTraps = 0x8
}

/// RectangularExplorationEvent.ExplorationType
enum ExplorationType : uint8
{
    Hide,
    Reveal,
    Invert
}
