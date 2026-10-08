namespace Ambermoon.Data;

using System;
using Ambermoon;
using Ambermoon.Data.Enumerations;

// The events of maps and characters. In the original every kind of event is a class derived from Event; here an
// Event holds the data of its kind in a union (EventData), and the objects become ids: Event.Id tells which event
// it is (copies of an Event with the same id are the same event), Event.Next is the id of the next event in the
// chain (-1: none). An EventStore keeps the events by their ids.

/// Map transitions, teleporters, windgates, etc.
struct TeleportEvent
{
    uint32 MapIndex;
    uint32 X;
    uint32 Y;
    CharacterDirection Direction;
    Optional<TravelType> NewTravelType;
    TransitionType Transition;
    uint8[] Unknown2;
}

/// Locked doors.
struct DoorEvent
{
    uint32 LockpickingChanceReduction;
    uint8 DoorIndex;
    uint32 TextIndex;
    uint32 UnlockTextIndex;
    uint8 Unused;
    uint32 KeyIndex;
    uint32 UnlockFailedEventIndex;
}

/// Chests and lootable map objects.
struct ChestEvent
{
    uint32 LockpickingChanceReduction;
    uint32 TextIndex; // 255 = none
    uint32 ChestIndex; // 0-based
    ChestFlags Flags;
    uint32 KeyIndex;
    uint32 UnlockFailedEventIndex;
    /// Not 0: a search skill check finds the chest (the original only tests for 0).
    uint8 FindChanceReduction;

    /// The 1-based chest index (extended chests of Ambermoon Advanced start at 257).
    uint32 RealChestIndex()
    {
        return (Flags & ChestFlags.ExtendedChest) != ChestFlags.None ? 257u + ChestIndex : 1u + ChestIndex;
    }

    bool SearchSkillCheck()
    {
        return FindChanceReduction != 0;
    }
}

/// Text popups.
struct PopupTextEvent
{
    uint32 TextIndex;
    /// From event_pix (0-based). 0xff: no image.
    uint32 EventImageIndex;
    EventTrigger PopupTrigger;
    bool TriggerIfBlind;
    uint8[] Unknown;
}

/// Rotates the player.
struct SpinnerEvent
{
    CharacterDirection Direction;
    uint8[] Unused;
}

/// Hurts the player.
struct TrapEvent
{
    TrapAilment Ailment;
    TrapTarget Target;
    uint8 BaseDamage;
    GenderFlag AffectedGenders;
    uint8[] Unused;
}

/// Adds or removes buffs.
struct ChangeBuffsEvent
{
    /// null means all.
    Optional<ActiveSpellType> AffectedBuff;
    bool Add;
    uint8 Unused1;
    uint16 Value;
    /// In 5 minute chunks.
    uint16 Duration;
    uint8[] Unused2;
}

/// The riddlemouth window.
struct RiddlemouthEvent
{
    uint32 RiddleTextIndex;
    uint32 SolutionTextIndex;
    uint32 CorrectAnswerDictionaryIndex1;
    uint32 CorrectAnswerDictionaryIndex2;
    uint8[] Unused;
}

/// Rewards and punishments.
struct RewardEvent
{
    RewardType TypeOfReward;
    RewardTarget Target;
    RewardOperation Operation;
    /// The real value is random in the range 0 to Value.
    bool Random;
    uint16 RewardTypeValue;
    uint32 Value;
    uint8 Unused;

    Optional<Attribute> GetAttribute()
    {
        if (TypeOfReward == RewardType.Attribute || TypeOfReward == RewardType.MaxAttribute)
            return (Attribute)RewardTypeValue;
        return null;
    }

    Optional<Skill> GetSkill()
    {
        if (TypeOfReward == RewardType.Skill || TypeOfReward == RewardType.MaxSkill)
            return (Skill)RewardTypeValue;
        return null;
    }

    Optional<uint32> _AnyLanguages()
    {
        if (TypeOfReward == RewardType.Languages)
            return (uint32)1 << (RewardTypeValue & 31);
        return null;
    }

    Optional<Language> GetLanguages()
    {
        if (_AnyLanguages() is uint32 languages && languages < 0x100)
            return (Language)languages;
        return null;
    }

    Optional<ExtendedLanguage> GetExtendedLanguages()
    {
        if (_AnyLanguages() is uint32 languages && languages >= 0x100)
            return (ExtendedLanguage)(languages >> 8);
        return null;
    }

    Optional<Condition> GetConditions()
    {
        if (TypeOfReward == RewardType.Conditions)
            return (Condition)(1 << (RewardTypeValue & 31));
        return null;
    }

    Optional<SpellTypeMastery> GetUsableSpellTypes()
    {
        if (TypeOfReward == RewardType.UsableSpellTypes)
            return (SpellTypeMastery)(1 << (RewardTypeValue & 31));
        return null;
    }
}

/// Changes map tiles.
struct ChangeTileEvent
{
    uint32 X;
    uint32 Y;
    uint8[] Unknown;
    uint32 FrontTileIndex;
    /// 0 means the same map.
    uint32 MapIndex;
}

/// Starts a battle.
struct StartBattleEvent
{
    uint32 MonsterGroupIndex;
    uint8[] Unknown1;
    uint8[] Unknown2;
}

/// Enters a place like a merchant or a healer.
struct EnterPlaceEvent
{
    uint8 OpeningHour;
    uint8 ClosingHour;
    uint32 PlaceIndex;
    uint8 ClosedTextIndex;
    PlaceType PlaceType;
    /// The text when a horse, ship, etc. was bought (from the map texts; 0xff: a default text).
    uint8 UsePlaceTextIndex;
    uint32 MerchantDataIndex;
}

/// Tests some condition.
struct ConditionEvent
{
    ConditionType TypeOfCondition;
    Condition DisallowedAilments;
    uint32 ObjectIndex;
    uint32 Value;
    uint32 Count;
    /// The map event to continue with if the condition is not met (0xffff: stop).
    uint32 ContinueIfFalseWithMapEventIndex;
}

/// Tests some condition for a party member (Ambermoon Advanced only).
struct PartyMemberConditionEvent
{
    PartyMemberConditionType TypeOfCondition;
    Condition DisallowedAilments;
    uint32 Value;
    uint32 ConditionValueIndex;
    PartyMemberConditionTarget Target;
    uint32 ContinueIfFalseWithMapEventIndex;
}

/// Executes some action.
struct ActionEvent
{
    ActionType TypeOfAction;
    uint8[] Unknown1;
    uint32 ObjectIndex;
    uint32 Value;
    uint32 Count;
    uint8[] Unknown2;
}

/// A dice roll against some percent value.
struct Dice100RollEvent
{
    /// Chance in percent: 0 ~ 100
    uint32 Chance;
    uint32 ContinueIfFalseWithMapEventIndex;
    uint8[] Unused;
}

/// Starts a conversation event chain by user input.
struct ConversationEvent
{
    InteractionType Interaction;
    uint16 Value;
    uint8[] Unused1;
    uint8[] Unused2;
}

/// Prints conversation text.
struct PrintTextEvent
{
    uint32 NPCTextIndex;
    uint8[] Unused;
}

/// Creates items, gold or food.
struct CreateEvent
{
    CreateType TypeOfCreation;
    uint32 Amount;
    uint32 ItemIndex;
    uint8[] Unused;
}

/// Yes/No popup with text.
struct DecisionEvent
{
    uint32 TextIndex;
    uint8[] Unknown1;
    /// The event to continue with on "No" (0xffff: stop).
    uint32 NoEventIndex;
}

/// Changes the music.
struct ChangeMusicEvent
{
    uint32 MusicIndex;
    uint8 Volume;
    uint8[] Unknown1;
}

/// Exits conversations.
struct ExitEvent
{
    uint8[] Unused;
}

/// Spawns transports like ships or horses.
struct SpawnEvent
{
    uint32 X;
    uint32 Y;
    TravelType TravelType;
    uint8[] Unknown1;
    uint32 MapIndex;
    uint8[] Unknown2;
}

/// Executes conversation actions.
struct InteractEvent
{
    uint8[] Unused;
}

/// Removes a party member.
struct RemovePartyMemberEvent
{
    uint8 CharacterIndex;
    uint8 ChestIndexEquipment;
    uint8 ChestIndexInventory;
    uint8[] Unused;
}

/// A non-interactive delay (Ambermoon Advanced only).
struct DelayEvent
{
    uint32 Milliseconds;
    uint8[] Unused1;
    uint16 Unused2;
}

/// Shakes the screen (Ambermoon Advanced only).
struct ShakeEvent
{
    uint32 Shakes;
    uint8[] Unused1;
    uint16 Unused2;
}

/// Shows the dungeon map (Ambermoon Advanced only).
struct ShowMapEvent
{
    MapOptions Options;
    uint8[] Unused;
}

/// Toggles the event tile and up to 4 global variables.
struct ToggleSwitchEvent
{
    uint32 FrontTileIndexOff;
    uint32 FrontTileIndexOn;
    /// 5 bytes = 40 bits = 4 global variables with 10 bits each
    uint8[] GlobalVariableBytes;

    /// The 4 global variables.
    uint32[] GlobalVariables()
    {
        if (GlobalVariableBytes == null || GlobalVariableBytes.Length < 5)
            GlobalVariableBytes = new uint8[5];
        else if (GlobalVariableBytes.Length > 5)
            GlobalVariableBytes = GlobalVariableBytes[..(GlobalVariableBytes.Length - 5)].ToArray(); // (as in the original)
        uint32 globalVar1 = GlobalVariableBytes[0];
        uint32 globalVar2 = GlobalVariableBytes[1];
        uint32 globalVar3 = GlobalVariableBytes[2];
        uint32 globalVar4 = GlobalVariableBytes[3];
        globalVar1 <<= 2;
        globalVar1 |= globalVar2 >> 6;
        globalVar2 &= 0x3f;
        globalVar2 <<= 4;
        globalVar2 |= globalVar3 >> 4;
        globalVar3 &= 0xf;
        globalVar3 <<= 6;
        globalVar3 |= globalVar4 >> 2;
        globalVar4 &= 0x3;
        globalVar4 <<= 8;
        globalVar4 |= GlobalVariableBytes[4];
        return [globalVar1, globalVar2, globalVar3, globalVar4];
    }
}

/// Changes a tile depending on a global variable.
struct DynamicChangeTileEvent
{
    uint32 X;
    uint32 Y;
    uint32 GlobalVariable;
    uint32 FrontTileIndexOff;
    uint32 FrontTileIndexOn;
    /// 0 means the same map.
    uint32 MapIndex;
}

/// Changes the exploration of a rectangular map area.
struct RectangularExplorationEvent
{
    uint32 X;
    uint32 Y;
    uint32 Width;
    uint32 Height;
    ExplorationType Exploration;
    /// 0 means the same map.
    uint32 MapIndex;
    uint16 Unused;
}

/// Reveals up to 3 vertical lines on the dungeon map.
struct VerticalLineRevealEvent
{
    uint32 X1;
    uint32 Y1;
    uint32 Height1;
    uint32 X2;
    uint32 Y2;
    uint32 Height2;
    uint32 X3;
    uint32 Y3;
    uint32 Height3;
}

/// An event of an unknown type: its 9 data bytes.
struct DebugEvent
{
    uint8[] Data;
}

/// The data of an event, by its kind.
union EventData
{
    TeleportEvent, DoorEvent, ChestEvent, PopupTextEvent, SpinnerEvent, TrapEvent, ChangeBuffsEvent, RiddlemouthEvent,
    RewardEvent, ChangeTileEvent, StartBattleEvent, EnterPlaceEvent, ConditionEvent, PartyMemberConditionEvent,
    ActionEvent, Dice100RollEvent, ConversationEvent, PrintTextEvent, CreateEvent, DecisionEvent, ChangeMusicEvent,
    ExitEvent, SpawnEvent, InteractEvent, RemovePartyMemberEvent, DelayEvent, ShakeEvent, ShowMapEvent,
    ToggleSwitchEvent, DynamicChangeTileEvent, RectangularExplorationEvent, VerticalLineRevealEvent, DebugEvent
}
