using Ambermoon.Data.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Ambermoon.Data.Descriptions
{
    public record EventIndexDescription : ValueDescription
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
        public static bool IsBranchEvent(Event @event)
        {
            return @event.Type == EventType.Condition || @event.Type == EventType.Decision || @event.Type == EventType.Dice100Roll;
        }

        public static uint GetBranchEventIndex(Event branchEvent)
        {
            return branchEvent switch
            {
                ConditionEvent c => c.ContinueIfFalseWithMapEventIndex,
                DecisionEvent d => d.NoEventIndex,
                Dice100RollEvent d => d.ContinueIfFalseWithMapEventIndex,
                _ => 0xffff
            };
        }

        internal static string ToString(Event @event, ValueDescription value)
        {
            return ToString(@event.GetType(), @event, value);
        }
            
        private static string ToString(Type type, Event @event, ValueDescription value)
        {
            if (value.DisplayMapping != null)
            {
                var displayMapping = value.DisplayMapping;
                value.DisplayMapping = null; // avoid recursive loops
                return displayMapping(@event, value) + ",";
            }

            var property = type.GetProperty(value.Name).GetValue(@event);

            if (value.FlagDescriptions != null)
            {
                string info = $" {value.DisplayName}=";
                var bits = (ushort)Convert.ChangeType(property, typeof(ushort));

                for (int i = 0; i < value.FlagDescriptions.Length; ++i)
                {
                    int bit = value.FlagDescriptionOffset + i;

                    if ((bits & (1 << bit)) != 0)
                        info += $" {value.FlagDescriptions[i]}|";
                }

                return  info.TrimEnd('|') + ",";
            }
            else if (value is IEnumValueDescription enumValueDescription && enumValueDescription.Flags)
            {
                return $" {value.DisplayName}=" + EnumHelper.GetFlagNames(value.GetType().GetGenericArguments()[0], property) + ",";
            }
            else if (value.ShowAsHex)
            {
                if (value.Type == ValueType.Byte)
                    return $" {value.DisplayName}=0x{(ushort)Convert.ChangeType(property, typeof(ushort)):x2},";
                else
                    return $" {value.DisplayName}=0x{(ushort)Convert.ChangeType(property, typeof(ushort)):x4},";
            }
            else
            {
                if (value is IEnumValueDescription enumDesc)
                {
                    int index = enumDesc.AllowedValues.Select(Convert.ToInt32).ToList().IndexOf(Convert.ToInt32(property));
                    object enumValue;
                    if (index >= 0 && index < enumDesc.AllowedValueNames.Length)
                        enumValue = enumDesc.AllowedValueNames[index];
                    else
                        enumValue = Enum.ToObject(value.GetType().GetGenericArguments()[0], property);
                    return $" {value.DisplayName}={enumValue},";
                }

                return $" {value.DisplayName}={property},";
            }
        }

        public static string ValueToString(Event @event, ValueDescription value)
        {
            var result = ToString(@event.GetType(), @event, value).TrimEnd(',');

            if (result.Contains('='))
                return Regex.Match(result, "([^=]*=)(.*)").Groups[^1].Value;

            return result;
        }

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

                    info += ToString(type, @event, value);
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
                Use.Byte(nameof(TeleportEvent.X), true, 200),
                Use.Byte(nameof(TeleportEvent.Y), true, 200),
                Use.Enum(nameof(TeleportEvent.Direction), false, CharacterDirection.Keep).WithFilteredAllowedValues
                (
                    values => values.Distinct().ToArray(),
                    valueNames => valueNames.Where(name => name != nameof(CharacterDirection.Random)).ToArray()
                ),
                Use.HiddenByte(0xff),
                Use.Enum<TeleportEvent.TransitionType>(nameof(TeleportEvent.Transition), false),
                Use.Word(nameof(TeleportEvent.MapIndex), true, 1023),
                Use.HiddenByte(0x00),
                Use.HiddenByte(0xff)
            )},
            { EventType.Door, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(DoorEvent.LockpickingChanceReduction), false, 100),
                Use.Byte(nameof(DoorEvent.DoorIndex), true),
                Use.Byte(nameof(DoorEvent.TextIndex), false, 0xff, 0x00, 0xff),
                Use.Byte(nameof(DoorEvent.UnlockTextIndex), false, 0xff, 0x00, 0xff),
                Use.HiddenByte(0x00),
                Use.Word(nameof(DoorEvent.KeyIndex), false),
                Use.EventIndex(nameof(DoorEvent.UnlockFailedEventIndex), false)
            )},
            { EventType.Chest, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(ChestEvent.LockpickingChanceReduction), false, 100),
                Use.Bool(nameof(ChestEvent.SearchSkillCheck), false),
                Use.Byte(nameof(ChestEvent.TextIndex), false, 0xff, 0x00, 0xff),
                Use.Byte(nameof(ChestEvent.ChestIndex), true),
                Use.Flags8<ChestEvent.ChestFlags>(nameof(ChestEvent.Flags), false),
                Use.Word(nameof(ChestEvent.KeyIndex), false),
                Use.EventIndex(nameof(ChestEvent.UnlockFailedEventIndex), false)
            )},
            { EventType.MapText, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(PopupTextEvent.EventImageIndex), false, 0xff, 0x00, 0xff),
                Use.Enum(nameof(PopupTextEvent.PopupTrigger), false, EventTrigger.Always),
                Use.HiddenBool(),
                Use.Word(nameof(PopupTextEvent.TextIndex), true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Spinner, new EventDescription
            (
                true, false, true, true, false,
                Use.Enum(nameof(SpinnerEvent.Direction), true, CharacterDirection.Random).WithFilteredAllowedValues
                (
                    values => values.Distinct().ToArray(),
                    valueNames => valueNames.Where(name => name != nameof(CharacterDirection.Keep)).ToArray()
                ),
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
                Use.Enum(nameof(TrapEvent.Ailment), false, TrapEvent.TrapAilment.None),
                Use.Enum(nameof(TrapEvent.Target), true, TrapEvent.TrapTarget.ActivePlayer),
                Use.Enum(nameof(TrapEvent.AffectedGenders), false, GenderFlag.Both),
                Use.Byte(nameof(TrapEvent.BaseDamage), true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.ChangeBuffs, new EventDescription
            (
                true, true, true, true, false,
                Use.WithDisplayMapping<ChangeBuffsEvent>
                (
                    () => Use.Byte(nameof(ChangeBuffsEvent.AffectedBuff), false, 6),
                    (changeBuffsEvent, valueDescription) => (int)changeBuffsEvent.AffectedBuff == 6 ? "All" : EventDescriptions.ToString(changeBuffsEvent, valueDescription)
                ),
                Use.Bool(nameof(ChangeBuffsEvent.Add), false),
                Use.HiddenByte(),
                Use.Conditional<ChangeBuffsEvent>(() => Use.Word(nameof(ChangeBuffsEvent.Value), true, 100, 1), changeBuffEvent => changeBuffEvent.Add),
                Use.Conditional<ChangeBuffsEvent>(() => Use.Word(nameof(ChangeBuffsEvent.Duration), true, 180, 1), changeBuffEvent => changeBuffEvent.Add),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Riddlemouth, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(RiddlemouthEvent.RiddleTextIndex), true),
                Use.Byte(nameof(RiddlemouthEvent.SolutionTextIndex), true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(RiddlemouthEvent.CorrectAnswerDictionaryIndex1), true),
                Use.Word(nameof(RiddlemouthEvent.CorrectAnswerDictionaryIndex2), false)
            )},
            { EventType.Reward, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<RewardEvent.RewardType>(nameof(RewardEvent.TypeOfReward), true),
                Use.Conditional<RewardEvent>(() => Use.Enum(nameof(RewardEvent.Operation), true, RewardEvent.RewardOperation.Increase), rewardEvent =>
                {
                    return rewardEvent.TypeOfReward != RewardEvent.RewardType.ChangePortrait &&
                           rewardEvent.TypeOfReward != RewardEvent.RewardType.EmpowerSpells;
                }),
                Use.Conditional<RewardEvent>(() => Use.Bool(nameof(RewardEvent.Random), true), rewardEvent =>
                {
                    return rewardEvent.TypeOfReward != RewardEvent.RewardType.ChangePortrait &&
                           rewardEvent.TypeOfReward != RewardEvent.RewardType.Conditions &&
                           rewardEvent.TypeOfReward != RewardEvent.RewardType.EmpowerSpells &&
                           rewardEvent.TypeOfReward != RewardEvent.RewardType.Languages &&
                           rewardEvent.TypeOfReward != RewardEvent.RewardType.UsableSpellTypes &&
						   rewardEvent.TypeOfReward != RewardEvent.RewardType.Spells;
                }),
				Use.Enum(nameof(RewardEvent.Target), true, RewardEvent.RewardTarget.ActivePlayer, Enum.GetValues<RewardEvent.RewardTarget>()
                        .Where(t => (int)t < 100)
                        .Concat(Enumerable.Range(100, (int)Enum.GetValues<PartyMembers>().Max()).Select(i => (RewardEvent.RewardTarget)i))
                        .Concat(Enumerable.Range(200, (int)Enum.GetValues<PartyMembers>().Max()).Select(i => (RewardEvent.RewardTarget)i)),
					(target) => (int)target >= 200 ? $"All but Party Member {(int)target - 199}" : (int)target >= 100 ? $"Party Member {(int)target - 99}" : Enum.GetName(target)
				),
                Use.HiddenByte(),
                Use.Conditional<RewardEvent>
                (
                    () => Use.WithDisplayMapping<RewardEvent>
                    (
                        () => Use.Word(nameof(RewardEvent.RewardTypeValue), false),
                        (rewardEvent, description) =>
                        {
                            ValueDescription displayDescription = null;

                            switch (rewardEvent.TypeOfReward)
                            {
                                case RewardEvent.RewardType.Attribute:
                                case RewardEvent.RewardType.MaxAttribute:
                                    displayDescription = Use.Enum(description.Name, description.Required, default, Enum.GetValues<Attribute>().Take(8).ToArray());
                                    break;
                                case RewardEvent.RewardType.Skill:
                                case RewardEvent.RewardType.MaxSkill:
                                    displayDescription = Use.Enum(description.Name, description.Required, default, Enum.GetValues<Skill>().Take(10).ToArray());
                                    break;
                                default:
                                    return null;
                            };

                            return EventDescriptions.ToString(rewardEvent, displayDescription);
                        }
                    ),
                    rewardEvent =>
                    {
                        return rewardEvent.TypeOfReward == RewardEvent.RewardType.Attribute ||
                               rewardEvent.TypeOfReward == RewardEvent.RewardType.Skill ||
                               rewardEvent.TypeOfReward == RewardEvent.RewardType.MaxAttribute ||
                               rewardEvent.TypeOfReward == RewardEvent.RewardType.MaxSkill;
                    }
                ),
                Use.Word(nameof(RewardEvent.Value), false)
            )},
            { EventType.ChangeTile, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte(nameof(ChangeTileEvent.X), true, 200),
                Use.Byte(nameof(ChangeTileEvent.Y), true, 200),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(ChangeTileEvent.FrontTileIndex), true),
                Use.Word(nameof(ChangeTileEvent.MapIndex), true, 1023)
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
                Use.Byte(nameof(StartBattleEvent.MonsterGroupIndex), true),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.EnterPlace, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(EnterPlaceEvent.ClosedTextIndex), false, 0xff, 0x00, 0xff),
                Use.Enum<PlaceType>(nameof(EnterPlaceEvent.PlaceType), true),
                Use.Byte(nameof(EnterPlaceEvent.OpeningHour), true, 23),
                Use.Byte(nameof(EnterPlaceEvent.ClosingHour), true, 23),
                Use.Byte(nameof(EnterPlaceEvent.UsePlaceTextIndex), false, 0xff, 0, 0xff),
                Use.Word(nameof(EnterPlaceEvent.PlaceIndex), true),
                Use.Conditional<EnterPlaceEvent>(() => Use.Word(nameof(EnterPlaceEvent.MerchantDataIndex), false), enterPlaceEvent => enterPlaceEvent.PlaceType == PlaceType.Merchant || enterPlaceEvent.PlaceType == PlaceType.Library)
            )},
            { EventType.Condition, new EventDescription
            (
                true, true, true, false, false,
                Use.Enum<ConditionEvent.ConditionType>(nameof(ConditionEvent.TypeOfCondition), true),
                Use.Byte(nameof(ConditionEvent.Value), true),
                Use.WithNameIf<ConditionEvent>(
                    () => Use.Conditional<ConditionEvent>(() => Use.Byte(nameof(ConditionEvent.Count), false), conditionEvent =>
                        conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.ItemOwned ||
                        conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.Attribute ||
                        conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.Skill
                    ),
                    conditionEvent =>
                        conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.Attribute ||
                        conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.Skill,
                    "Amount"),
                Use.Conditional<ConditionEvent>(() => Use.Flags16<Condition>(nameof(ConditionEvent.DisallowedAilments), false), conditionEvent => conditionEvent.TypeOfCondition == ConditionEvent.ConditionType.PartyMember),
                Use.Conditional<ConditionEvent>(() => Use.Word(nameof(ConditionEvent.ObjectIndex), true), conditionEvent =>
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.CanSee &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Eye &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Hand &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Mouth &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.LastEventResult &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.Levitating &&
                    conditionEvent.TypeOfCondition != ConditionEvent.ConditionType.IsNight
                ),
                Use.EventIndex(nameof(ConditionEvent.ContinueIfFalseWithMapEventIndex), false)
            )},
            { EventType.Action, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<ActionEvent.ActionType>(nameof(ActionEvent.TypeOfAction), true),
                Use.Byte(nameof(ActionEvent.Value), true),
                Use.Conditional<ActionEvent>(() => Use.Byte(nameof(ActionEvent.Count), false), actionEvent => actionEvent.TypeOfAction == ActionEvent.ActionType.AddItem),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(ActionEvent.ObjectIndex), true),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.Dice100Roll, new EventDescription
            (
                true, true, true, false, false,
                Use.Byte(nameof(Dice100RollEvent.Chance), true, 100, 1, 50),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.EventIndex(nameof(Dice100RollEvent.ContinueIfFalseWithMapEventIndex), false)
            )},
            { EventType.Conversation, new EventDescription
            (
                false, true, true, false, true,
                Use.Enum(nameof(ConversationEvent.Interaction), true, ConversationEvent.InteractionType.Talk),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(ConversationEvent.Value), false),
                Use.HiddenByte(),
                Use.HiddenByte()
            )},
            { EventType.PrintText, new EventDescription
            (
                false, true, false, false, false,
                Use.Byte(nameof(PrintTextEvent.NPCTextIndex), true),
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
                Use.Enum(nameof(CreateEvent.TypeOfCreation), false, CreateEvent.CreateType.Item),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(CreateEvent.Amount), false, 0xffff, 1, 1),
                Use.Word(nameof(CreateEvent.ItemIndex), false)
            )},
            { EventType.Decision, new EventDescription
            (
                true, false, true, true, false,
                Use.Byte(nameof(DecisionEvent.TextIndex), true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.EventIndex(nameof(DecisionEvent.NoEventIndex), false)
            )},
            { EventType.ChangeMusic, new EventDescription
            (
                true, true, true, true, false,
                Use.Word(nameof(ChangeMusicEvent.MusicIndex), true),
                Use.Byte(nameof(ChangeMusicEvent.Volume), false, 255, 0, 255, true),
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
                Use.Byte(nameof(SpawnEvent.X), true, 200),
                Use.Byte(nameof(SpawnEvent.Y), true, 200),
                Use.Enum(nameof(SpawnEvent.TravelType), true, TravelType.Horse,
                    TravelType.Horse, TravelType.Raft, TravelType.Ship, TravelType.SandLizard, TravelType.SandShip),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(SpawnEvent.MapIndex), true, 1023),
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
            )},
            { EventType.RemovePartyMember, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum(nameof(RemovePartyMemberEvent.CharacterIndex), true, PartyMembers.Netsrak, Enum.GetValues<PartyMembers>().Skip(2)), // Skip "None" and "Hero"
                Use.Byte(nameof(RemovePartyMemberEvent.ChestIndexEquipment), true),
                Use.Byte(nameof(RemovePartyMemberEvent.ChestIndexInventory), true),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenWord(),
                Use.HiddenWord()
            )},
            { EventType.Delay, new EventDescription
            (
                true, true, true, true, false,
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word(nameof(DelayEvent.Milliseconds), true),
                Use.HiddenWord()
            )}
        };

        public static Dictionary<EventType, Func<Event>> EventFactories { get; } = new Dictionary<EventType, Func<Event>>
        {
            { EventType.Teleport, () => new TeleportEvent() },
            { EventType.Door, () => new DoorEvent() },
            { EventType.Chest, () => new ChestEvent() },
            { EventType.MapText, () => new PopupTextEvent() },
            { EventType.Spinner, () => new SpinnerEvent() },
            { EventType.Trap, () => new TrapEvent() },
            { EventType.ChangeBuffs, () => new ChangeBuffsEvent() },
            { EventType.Riddlemouth, () => new RiddlemouthEvent() },
            { EventType.Reward, () => new RewardEvent() },
            { EventType.ChangeTile, () => new ChangeTileEvent() },
            { EventType.StartBattle, () => new StartBattleEvent() },
            { EventType.EnterPlace, () => new EnterPlaceEvent() },
            { EventType.Condition, () => new ConditionEvent() },            
            { EventType.Action, () => new ActionEvent() },
            { EventType.Dice100Roll, () => new Dice100RollEvent() },
            { EventType.Conversation, () => new ConversationEvent() },
            { EventType.PrintText, () => new PrintTextEvent() },
            { EventType.Create, () => new CreateEvent() },
            { EventType.Decision, () => new DecisionEvent() },
            { EventType.ChangeMusic, () => new ChangeMusicEvent() },
            { EventType.Exit, () => new ExitEvent() },
            { EventType.Spawn, () => new SpawnEvent() },
            { EventType.Interact, () => new InteractEvent() },
            { EventType.RemovePartyMember, () => new RemovePartyMemberEvent() },
            { EventType.Delay, () => new DelayEvent() }
        };
    }
}
