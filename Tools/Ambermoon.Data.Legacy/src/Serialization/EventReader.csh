namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

/// Reads the events of maps and characters.
struct EventReader
{
    /// Reads the events at the reader's position: a word with the number of event chains and a word per chain (the
    /// index of its first event), then a word with the number of events and 12 bytes per event (the type, 9 bytes of
    /// data and the index of the next event, 0xffff for none). The events are added to `store`; `events` gets the ids
    /// of all events, `eventList` those of the first events of the chains.
    static Error<void> ReadEvents(ref DataReader dataReader, EventStore store, List<int> events, List<int> eventList)
    {
        int numEvents = dataReader.ReadWord();
        var eventOffsets = new int[numEvents];
        for (var i = 0; i < numEvents; i += 1)
            eventOffsets[i] = dataReader.ReadWord();

        events.Clear();

        int numTotalEvents = 0;
        if (dataReader.Position <= dataReader.Size() - 4)
            numTotalEvents = dataReader.ReadWord();

        if (numEvents > 0)
        {
            var ids = new int[numTotalEvents];
            var nexts = new int[numTotalEvents];

            // all events and the indices of their next events
            for (var i = 0; i < numTotalEvents; i += 1)
            {
                var e = ParseEvent(ref dataReader);
                e.Index = (uint32)(i + 1);
                nexts[i] = dataReader.ReadWord();
                ids[i] = store.Add(e);
                events.Add(ids[i]);
            }
            if (dataReader.Overrun())
                return error("Index was outside the bounds of the array.");

            for (var i = 0; i < numTotalEvents; i += 1)
            {
                if (nexts[i] == 0xffff)
                    continue;
                if (nexts[i] >= numTotalEvents)
                    return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
                store.SetNext(ids[i], ids[nexts[i]]);
            }

            foreach (var eventOffset in eventOffsets)
            {
                if (eventOffset >= numTotalEvents)
                    return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
                eventList.Add(ids[eventOffset]);
            }
        }
        return;
    }

    /// Reads an event: its type and its 9 bytes of data (not the index of the next event).
    static Event ParseEvent(ref DataReader dataReader)
    {
        var type = (EventType)dataReader.ReadByte();
        EventData data;

        switch (type)
        {
            case EventType.Teleport:
            {
                uint32 x = dataReader.ReadByte();
                uint32 y = dataReader.ReadByte();
                var direction = (CharacterDirection)dataReader.ReadByte();
                var newTravelType = dataReader.ReadByte();
                var transition = (TransitionType)dataReader.ReadByte();
                uint32 mapIndex = dataReader.ReadWord();
                var unknown2 = dataReader.ReadBytes(2);
                Optional<TravelType> travelType = null;
                if (newTravelType != 0xff)
                    travelType = (TravelType)newTravelType;
                data = TeleportEvent {
                    MapIndex = mapIndex, X = x, Y = y, Direction = direction, NewTravelType = travelType,
                    Transition = transition, Unknown2 = unknown2
                };
                break;
            }
            case EventType.Door:
            {
                var lockpickingChanceReduction = dataReader.ReadByte();
                var doorIndex = dataReader.ReadByte();
                var textIndex = dataReader.ReadByte();
                var unlockTextIndex = dataReader.ReadByte();
                var unused = dataReader.ReadByte();
                uint32 keyIndex = dataReader.ReadWord();
                var unlockFailEventIndex = dataReader.ReadWord();
                data = DoorEvent {
                    LockpickingChanceReduction = lockpickingChanceReduction, DoorIndex = doorIndex, TextIndex = textIndex,
                    UnlockTextIndex = unlockTextIndex, Unused = unused, KeyIndex = keyIndex, UnlockFailedEventIndex = unlockFailEventIndex
                };
                break;
            }
            case EventType.Chest:
            {
                var lockpickingChanceReduction = dataReader.ReadByte();
                var findChanceReduction = dataReader.ReadByte();
                var textIndex = dataReader.ReadByte();
                uint32 chestIndex = dataReader.ReadByte();
                var flags = (ChestFlags)dataReader.ReadByte();
                uint32 keyIndex = dataReader.ReadWord();
                var unlockFailEventIndex = dataReader.ReadWord();
                data = ChestEvent {
                    LockpickingChanceReduction = lockpickingChanceReduction, FindChanceReduction = findChanceReduction,
                    TextIndex = textIndex, ChestIndex = chestIndex, Flags = flags, KeyIndex = keyIndex,
                    UnlockFailedEventIndex = unlockFailEventIndex
                };
                break;
            }
            case EventType.MapText:
            {
                var eventImageIndex = dataReader.ReadByte();
                var popupTrigger = (EventTrigger)dataReader.ReadByte();
                var triggerIfBlind = dataReader.ReadByte() != 0;
                // planned as a search skill check like for chests, but not used by the original
                dataReader.Position += 1;
                var textIndex = dataReader.ReadByte();
                var unknown = dataReader.ReadBytes(4);
                data = PopupTextEvent {
                    EventImageIndex = eventImageIndex, PopupTrigger = popupTrigger, TextIndex = textIndex,
                    TriggerIfBlind = triggerIfBlind, Unknown = unknown
                };
                break;
            }
            case EventType.Spinner:
            {
                var direction = (CharacterDirection)dataReader.ReadByte();
                var unused = dataReader.ReadBytes(8);
                data = SpinnerEvent { Direction = direction, Unused = unused };
                break;
            }
            case EventType.Trap:
            {
                var ailment = (TrapAilment)dataReader.ReadByte();
                var target = (TrapTarget)dataReader.ReadByte();
                var affectedGenders = (GenderFlag)dataReader.ReadByte();
                var baseDamage = dataReader.ReadByte();
                var unused = dataReader.ReadBytes(5);
                data = TrapEvent { Ailment = ailment, Target = target, AffectedGenders = affectedGenders, BaseDamage = baseDamage, Unused = unused };
                break;
            }
            case EventType.ChangeBuffs:
            {
                uint8 affectedBuffs = dataReader.ReadByte();
                bool add = dataReader.ReadByte() != 0;
                var unused1 = dataReader.ReadByte();
                var value = dataReader.ReadWord();
                var duration = dataReader.ReadWord();
                var unused2 = dataReader.ReadBytes(2);
                Optional<ActiveSpellType> affectedBuff = null;
                if (affectedBuffs != 0)
                    affectedBuff = (ActiveSpellType)(affectedBuffs - 1);
                data = ChangeBuffsEvent {
                    AffectedBuff = affectedBuff, Add = add, Value = value, Duration = duration, Unused1 = unused1, Unused2 = unused2
                };
                break;
            }
            case EventType.Riddlemouth:
            {
                var introTextIndex = dataReader.ReadByte();
                var solutionTextIndex = dataReader.ReadByte();
                var unused = dataReader.ReadBytes(3);
                var correctAnswerTextIndex1 = dataReader.ReadWord();
                var correctAnswerTextIndex2 = dataReader.ReadWord();
                data = RiddlemouthEvent {
                    RiddleTextIndex = introTextIndex, SolutionTextIndex = solutionTextIndex,
                    CorrectAnswerDictionaryIndex1 = correctAnswerTextIndex1, CorrectAnswerDictionaryIndex2 = correctAnswerTextIndex2,
                    Unused = unused
                };
                break;
            }
            case EventType.Reward:
            {
                var rewardType = (RewardType)dataReader.ReadByte();
                var rewardOperation = (RewardOperation)dataReader.ReadByte();
                var random = dataReader.ReadByte() != 0;
                var rewardTarget = (RewardTarget)dataReader.ReadByte();
                var unknown = dataReader.ReadByte();
                var rewardTypeValue = dataReader.ReadWord();
                var value = dataReader.ReadWord();
                data = RewardEvent {
                    TypeOfReward = rewardType, Operation = rewardOperation, Random = random, Target = rewardTarget,
                    RewardTypeValue = rewardTypeValue, Value = value, Unused = unknown
                };
                break;
            }
            case EventType.ChangeTile:
            {
                var x = dataReader.ReadByte();
                var y = dataReader.ReadByte();
                var unknown = dataReader.ReadBytes(3);
                var frontTileIndex = dataReader.ReadWord(); // also the wall/object index in the lower byte
                var mapIndex = dataReader.ReadWord();
                data = ChangeTileEvent { X = x, Y = y, FrontTileIndex = frontTileIndex, MapIndex = mapIndex, Unknown = unknown };
                break;
            }
            case EventType.StartBattle:
            {
                var unknown1 = dataReader.ReadBytes(6);
                var monsterGroupIndex = dataReader.ReadByte();
                var unknown2 = dataReader.ReadBytes(2);
                data = StartBattleEvent { MonsterGroupIndex = monsterGroupIndex, Unknown1 = unknown1, Unknown2 = unknown2 };
                break;
            }
            case EventType.EnterPlace:
            {
                var textIndexWhenClosed = dataReader.ReadByte();
                var placeType = (PlaceType)dataReader.ReadByte();
                var openingHour = dataReader.ReadByte();
                var closingHour = dataReader.ReadByte();
                var usePlaceTextIndex = dataReader.ReadByte();
                var placeIndex = dataReader.ReadWord();
                var merchantIndex = dataReader.ReadWord();
                data = EnterPlaceEvent {
                    ClosedTextIndex = textIndexWhenClosed, PlaceType = placeType, OpeningHour = openingHour,
                    ClosingHour = closingHour, PlaceIndex = placeIndex, UsePlaceTextIndex = usePlaceTextIndex,
                    MerchantDataIndex = merchantIndex
                };
                break;
            }
            case EventType.Condition:
            {
                var conditionType = (ConditionType)dataReader.ReadByte();
                var value = dataReader.ReadByte();
                var count = dataReader.ReadByte();
                var disallowedAilments = (Condition)dataReader.ReadWord();
                var objectIndex = dataReader.ReadWord();
                var jumpToIfNotFulfilled = dataReader.ReadWord();
                data = ConditionEvent {
                    TypeOfCondition = conditionType, ObjectIndex = objectIndex, Value = value, Count = count,
                    DisallowedAilments = disallowedAilments, ContinueIfFalseWithMapEventIndex = jumpToIfNotFulfilled
                };
                break;
            }
            case EventType.Action:
            {
                var actionType = (ActionType)dataReader.ReadByte();
                var value = dataReader.ReadByte();
                var count = dataReader.ReadByte();
                var unknown1 = dataReader.ReadBytes(2);
                var objectIndex = dataReader.ReadWord();
                var unknown2 = dataReader.ReadBytes(2);
                data = ActionEvent {
                    TypeOfAction = actionType, ObjectIndex = objectIndex, Value = value, Count = count, Unknown1 = unknown1,
                    Unknown2 = unknown2
                };
                break;
            }
            case EventType.Dice100Roll:
            {
                var chance = dataReader.ReadByte();
                var unused = dataReader.ReadBytes(6);
                var jumpToIfNotFulfilled = dataReader.ReadWord();
                data = Dice100RollEvent { Chance = chance, Unused = unused, ContinueIfFalseWithMapEventIndex = jumpToIfNotFulfilled };
                break;
            }
            case EventType.Conversation:
            {
                var interaction = (InteractionType)dataReader.ReadByte();
                var unused1 = dataReader.ReadBytes(4);
                var value = dataReader.ReadWord();
                var unused2 = dataReader.ReadBytes(2);
                data = ConversationEvent { Interaction = interaction, Value = value, Unused1 = unused1, Unused2 = unused2 };
                break;
            }
            case EventType.PrintText:
            {
                var npcTextIndex = dataReader.ReadByte();
                var unused = dataReader.ReadBytes(8);
                data = PrintTextEvent { NPCTextIndex = npcTextIndex, Unused = unused };
                break;
            }
            case EventType.Create:
            {
                var createType = (CreateType)dataReader.ReadByte();
                var unused = dataReader.ReadBytes(4);
                var amount = dataReader.ReadWord();
                var itemIndex = dataReader.ReadWord();
                data = CreateEvent { TypeOfCreation = createType, Unused = unused, Amount = amount, ItemIndex = itemIndex };
                break;
            }
            case EventType.Decision:
            {
                var textIndex = dataReader.ReadByte();
                var unknown1 = dataReader.ReadBytes(6);
                var noEventIndex = dataReader.ReadWord();
                data = DecisionEvent { TextIndex = textIndex, NoEventIndex = noEventIndex, Unknown1 = unknown1 };
                break;
            }
            case EventType.ChangeMusic:
            {
                var musicIndex = dataReader.ReadWord();
                var volume = dataReader.ReadByte();
                var unknown1 = dataReader.ReadBytes(6);
                data = ChangeMusicEvent { MusicIndex = musicIndex, Volume = volume, Unknown1 = unknown1 };
                break;
            }
            case EventType.Exit:
                data = ExitEvent { Unused = dataReader.ReadBytes(9) };
                break;
            case EventType.Spawn:
            {
                var x = dataReader.ReadByte();
                var y = dataReader.ReadByte();
                var travelType = (TravelType)dataReader.ReadByte();
                var unknown1 = dataReader.ReadBytes(2);
                var mapIndex = dataReader.ReadWord();
                var unknown2 = dataReader.ReadBytes(2);
                data = SpawnEvent { X = x, Y = y, TravelType = travelType, Unknown1 = unknown1, MapIndex = mapIndex, Unknown2 = unknown2 };
                break;
            }
            case EventType.Interact:
                data = InteractEvent { Unused = dataReader.ReadBytes(9) };
                break;
            case EventType.RemovePartyMember:
            {
                var characterIndex = dataReader.ReadByte();
                var chestIndexEquipment = dataReader.ReadByte();
                var chestIndexInventory = dataReader.ReadByte();
                var unused = dataReader.ReadBytes(6);
                data = RemovePartyMemberEvent {
                    CharacterIndex = characterIndex, ChestIndexEquipment = chestIndexEquipment,
                    ChestIndexInventory = chestIndexInventory, Unused = unused
                };
                break;
            }
            case EventType.Delay:
            {
                var unused1 = dataReader.ReadBytes(5);
                var milliseconds = dataReader.ReadWord();
                var unused2 = dataReader.ReadWord();
                data = DelayEvent { Unused1 = unused1, Milliseconds = milliseconds, Unused2 = unused2 };
                break;
            }
            case EventType.PartyMemberCondition:
            {
                var conditionType = (PartyMemberConditionType)dataReader.ReadByte();
                var conditionValueIndex = dataReader.ReadByte();
                var target = (PartyMemberConditionTarget)dataReader.ReadByte();
                var disallowedAilments = (Condition)dataReader.ReadWord();
                var value = dataReader.ReadWord();
                var jumpToIfNotFulfilled = dataReader.ReadWord();
                data = PartyMemberConditionEvent {
                    TypeOfCondition = conditionType, ConditionValueIndex = conditionValueIndex, Target = target,
                    DisallowedAilments = disallowedAilments, Value = value, ContinueIfFalseWithMapEventIndex = jumpToIfNotFulfilled
                };
                break;
            }
            case EventType.Shake:
            {
                var unused1 = dataReader.ReadBytes(5);
                var shakes = dataReader.ReadWord();
                var unused2 = dataReader.ReadWord();
                data = ShakeEvent { Unused1 = unused1, Shakes = shakes, Unused2 = unused2 };
                break;
            }
            case EventType.ShowMap:
            {
                var options = (MapOptions)dataReader.ReadByte();
                var unused = dataReader.ReadBytes(8);
                data = ShowMapEvent { Options = options, Unused = unused };
                break;
            }
            case EventType.ToggleSwitch:
            {
                var globalVarBytes = dataReader.ReadBytes(5);
                var frontTileOff = dataReader.ReadWord();
                var frontTileOn = dataReader.ReadWord();
                data = ToggleSwitchEvent { GlobalVariableBytes = globalVarBytes, FrontTileIndexOff = frontTileOff, FrontTileIndexOn = frontTileOn };
                break;
            }
            case EventType.DynamicChangeTile:
            {
                var x = dataReader.ReadByte();
                var y = dataReader.ReadByte();
                // the global variable has a word, the two front tile indices 12 bits each in the 3 bytes behind it
                var globalVar = dataReader.ReadWord();
                uint32 frontTileIndexOff = dataReader.ReadWord();
                uint32 frontTileIndexOn = dataReader.ReadByte();
                frontTileIndexOn |= (frontTileIndexOff << 8) & 0xf00;
                frontTileIndexOff >>= 4;
                var mapIndex = dataReader.ReadWord();
                data = DynamicChangeTileEvent {
                    X = x, Y = y, GlobalVariable = globalVar, FrontTileIndexOff = frontTileIndexOff, FrontTileIndexOn = frontTileIndexOn,
                    MapIndex = mapIndex
                };
                break;
            }
            case EventType.RectangularExploration:
            {
                var x = dataReader.ReadByte();
                var y = dataReader.ReadByte();
                var width = dataReader.ReadByte();
                var height = dataReader.ReadByte();
                var explorationType = (ExplorationType)dataReader.ReadByte();
                var mapIndex = dataReader.ReadWord();
                var unused = dataReader.ReadWord();
                data = RectangularExplorationEvent {
                    X = x, Y = y, Width = width, Height = height, Exploration = explorationType, MapIndex = mapIndex, Unused = unused
                };
                break;
            }
            case EventType.VerticalLineReveal:
            {
                var x1 = dataReader.ReadByte();
                var y1 = dataReader.ReadByte();
                var height1 = dataReader.ReadByte();
                var x2 = dataReader.ReadByte();
                var y2 = dataReader.ReadByte();
                var height2 = dataReader.ReadByte();
                var x3 = dataReader.ReadByte();
                var y3 = dataReader.ReadByte();
                var height3 = dataReader.ReadByte();
                data = VerticalLineRevealEvent { X1 = x1, Y1 = y1, Height1 = height1, X2 = x2, Y2 = y2, Height2 = height2, X3 = x3, Y3 = y3, Height3 = height3 };
                break;
            }
            default:
                data = DebugEvent { Data = dataReader.ReadBytes(9) };
                break;
        }

        return Event { Id = -1, Type = type, Next = -1, Data = data };
    }
}
