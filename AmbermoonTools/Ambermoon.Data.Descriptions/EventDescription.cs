using Ambermoon.Data.Enumerations;
using System;
using System.Collections.Generic;

namespace Ambermoon.Data.Descriptions
{
    public class EventIndexDescription : ValueDescription
    {
        public EventIndexDescription(string name, bool required)
        {
            Type = ValueType.EventIndex;
            Name = name;
            MinValue = 0;
            MaxValue = 0xffff;
            DefaultValue = 0xffff; // No event
            Required = required;
            Hidden = false;
            ShowAsHex = true;
        }
    }    

    public class EventDescription
    {
        public bool AllowMaps { get; }
        public bool AllowNPCs { get; }
        public bool AllowAsFirst { get; }
        public bool AllowAsSingle { get; }
        public bool AllowOnlyAsFirst { get; }
        public ValueDescription[] ValueDescriptions { get; }

        public EventDescription(bool allowMaps, bool allowNPCs, bool allowAsFirst, bool allowAsSingle,
            bool allowOnlyAsFirst, params ValueDescription[] valueDescriptions)
        {
            AllowMaps = allowMaps;
            AllowNPCs = allowNPCs;
            AllowAsFirst = allowAsFirst;
            AllowAsSingle = allowAsSingle;
            AllowOnlyAsFirst = allowOnlyAsFirst;
            ValueDescriptions = valueDescriptions;
        }
    }

    public static class EventDescriptions
    {
        public static string ToString(Event @event, int identation, string subIdentation = "  ")
        {
            if (Events.TryGetValue(@event.Type, out var description))
            {
                string info = $"{@event.Type}:";
                var type = @event.GetType();

                foreach (var value in description.ValueDescriptions)
                {
                    if (value.Hidden || value.Condition?.Invoke(description, @event) == false)
                        continue;

                    var property = type.GetProperty(value.Name).GetValue(@event);
                    if (value.FlagDescriptions != null)
                    {
                        info += $" {value.Name}=";
                        var bits = (ushort)Convert.ChangeType(property, typeof(ushort));

                        for (int i = 0; i < value.FlagDescriptions.Length; ++i)
                        {
                            int bit = value.FlagDescriptionOffset + i;

                            if ((bits & (1 << bit)) != 0)
                                info += $" {value.FlagDescriptions[i]}|";
                        }

                        info = info.TrimEnd('|') + ",";
                    }
                    else if (value is IEnumValueDescription enumValueDescription && enumValueDescription.Flags)
                    {
                        info += $" {value.Name}=" + Enum.GetFlagNames(value.GetType().GetGenericArguments()[0], property) + ",";
                    }
                    else if (value.ShowAsHex)
                    {
                        if (value.Type == ValueType.Byte)
                            info += $" {value.Name}=0x{(ushort)Convert.ChangeType(property, typeof(ushort)):x2},";
                        else
                            info += $" {value.Name}=0x{(ushort)Convert.ChangeType(property, typeof(ushort)):x4},";
                    }
                    else
                    {
                        info += $" {value.Name}={property},";
                    }
                }

                info = info.TrimEnd(',');
                info = info.TrimEnd(' ');

                if (info.Length > 80 - identation)
                {
                    int lastSpaceIndex = info.Substring(0, 80 - identation).LastIndexOf(' ');

                    if (lastSpaceIndex != -1)
                    {
                        info = info.Remove(lastSpaceIndex, 1).Insert(lastSpaceIndex, "\r\n" + subIdentation);

                        if (info.Length - lastSpaceIndex - 1 > 80)
                        {
                            lastSpaceIndex = info.Substring(0, lastSpaceIndex + 80).LastIndexOf(' ');

                            if (lastSpaceIndex != -1)
                            {
                                info = info.Remove(lastSpaceIndex, 1).Insert(lastSpaceIndex, "\r\n" + subIdentation);
                            }
                        }
                    }
                }

                return info;
            }
            else
            {
                // TODO
                //return @event.ToString();
                return "";
            }
        }

        public static Dictionary<EventType, EventDescription> Events { get; } = new Dictionary<EventType, EventDescription>
        {
            { EventType.Teleport, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte("X", true, 200),
                Use.Byte("Y", true, 200),
                Use.Enum("Direction", false, CharacterDirection.Random),
                Use.HiddenByte(0xff),
                Use.Enum<TeleportEvent.TransitionType>("Transition", false),
                Use.Word("MapIndex", true, 1023),
                Use.HiddenByte(0x00),
                Use.HiddenByte(0xff)
            )},
            { EventType.Door, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("LockpickingChanceReduction", false, 100),
                Use.Byte("DoorIndex", true),
                Use.Byte("TextIndex", false, 0xff, 0x00, 0xff),
                Use.Byte("UnlockTextIndex", false, 0xff, 0x00, 0xff),
                Use.HiddenByte(0x00),
                Use.Word("KeyIndex", false),
                Use.EventIndex("UnlockFailedEventIndex", false)
            )},
            { EventType.Chest, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("LockpickingChanceReduction", false, 100),
                Use.Flags8<ChestEvent.ChestFlags>("Flags", false),
                Use.Byte("TextIndex", false, 0xff, 0x00, 0xff),
                Use.Byte("ChestIndex", true),
                Use.Flags8<ChestEvent.ChestLootFlags>("LootFlags", false),
                Use.Word("KeyIndex", false),
                Use.EventIndex("UnlockFailedEventIndex", false)
            )},
            { EventType.PopupText, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("EventImageIndex", false, 0xff, 0x00, 0xff),
                Use.Enum("PopupTrigger", false, EventTrigger.Always),
                Use.HiddenBool(),
                Use.Word("TextIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Spinner, new EventDescription
            (
                true, false, true, true, false,
                Use.Enum("Direction", true, CharacterDirection.Random),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Trap, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum("Ailment", false, TrapEvent.TrapAilment.None),
                Use.Enum("Target", true, TrapEvent.TrapTarget.ActivePlayer),
                Use.Enum("AffectedGenders", false, GenderFlag.Both),
                Use.Byte("BaseDamage", true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.RemoveBuffs, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte("AffectedBuff", false, 6),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Riddlemouth, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("RiddleTextIndex", true),
                Use.Byte("SolutionTextIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("CorrectAnswerDictionaryIndex1", true),
                Use.Word("CorrectAnswerDictionaryIndex2", false)
            )},
            { EventType.Reward, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<RewardEvent.RewardType>("TypeOfReward", true),
                Use.Enum("Operation", true, RewardEvent.RewardOperation.Increase),
                Use.Bool("Random", true),
                Use.Enum("Target", true, RewardEvent.RewardTarget.ActivePlayer),
                Use.HiddenByte(),
                Use.Conditional<RewardEvent>(() => Use.Word("RewardTypeValue", false), rewardEvent =>
                {
                    return rewardEvent.TypeOfReward == RewardEvent.RewardType.Attribute ||
                           rewardEvent.TypeOfReward == RewardEvent.RewardType.Skill ||
                           rewardEvent.TypeOfReward == RewardEvent.RewardType.MaxAttribute;
                }),
                Use.Word("Value", false)
            )},
            { EventType.ChangeTile, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte("X", true, 200),
                Use.Byte("Y", true, 200),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("FrontTileIndex", true),
                Use.Word("MapIndex", true, 1023)
            )},
            { EventType.StartBattle, new EventDescription
            (
                true, false, true, true, false,
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Byte("MonsterGroupIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.EnterPlace, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("ClosedTextIndex", false, 0xff, 0x00, 0xff),
                Use.Enum<PlaceType>("PlaceType", true),
                Use.Byte("OpeningHour", true, 23),
                Use.Byte("ClosingHour", true, 23),
                Use.Byte("UsePlaceTextIndex", false, 0xff, 0, 0xff),
                Use.Word("PlaceIndex", true),
                Use.Conditional<EnterPlaceEvent>(() => Use.Word("MerchantDataIndex", false), enterPlaceEvent => enterPlaceEvent.PlaceType == PlaceType.Merchant)
            )},
            { EventType.Condition, new EventDescription
            (
                true, true, true, false, false,
                Use.Enum<ConditionEvent.ConditionType>("TypeOfCondition", true),
                Use.Byte("Value", true),
                Use.Conditional<ConditionEvent>(() => Use.Byte("Count", false), conditionEvent => conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.ItemOwned),
                Use.Conditional<ConditionEvent>(() => Use.Flags16<Condition>("DisallowedAilments", false), conditionEvent => conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.PartyMember),
                Use.Conditional<ConditionEvent>(() => Use.Word("ObjectIndex", true), conditionEvent =>
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.CanSee &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Eye &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Hand &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Mouth &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.LastEventResult &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Levitating
                ),
                Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
            )},
            { EventType.Action, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<ActionEvent.ActionType>("TypeOfAction", true),
                Use.Byte("Value", true),
                Use.Conditional<ActionEvent>(() => Use.Byte("Count", false), actionEvent => actionEvent.TypeOfAction == ActionEvent.ActionType.AddItem),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("ObjectIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Dice100Roll, new EventDescription
            (
                true, true, true, false, false,
                Use.Byte("Chance", true, 100, 1, 50),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
            )},
            { EventType.Conversation, new EventDescription
            (
                false, true, true, false, true,
                Use.Enum("Interaction", true, ConversationEvent.InteractionType.Talk),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("Value", false),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.PrintText, new EventDescription
            (
                false, true, false, false, false,
                Use.Byte("NPCTextIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Create, new EventDescription
            (
                false, true, false, false, false,
                Use.Enum("TypeOfCreation", false, CreateEvent.CreateType.Item),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("Amount", false, 0xffff, 1, 1),
                Use.Word("ItemIndex", false)
            )},
            { EventType.Decision, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte("TextIndex", true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.EventIndex("NoEventIndex", false)
            )},
            { EventType.ChangeMusic, new EventDescription
            (
                true, true, true, true, false,
                Use.Word("MusicIndex", true),
                Use.Byte("Volume", false, 255, 0, 255, true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Exit, new EventDescription
            (
                false, true, false, false, false,
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Spawn, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte("X", true, 200),
                Use.Byte("Y", true, 200),
                Use.Enum("TravelType", true, TravelType.Horse,
                    TravelType.Horse, TravelType.Raft, TravelType.Ship, TravelType.SandLizard, TravelType.SandShip),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("MapIndex", true, 1023),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Interact, new EventDescription
            (
                false, true, false, false, false,
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )}
        };
    }
}
