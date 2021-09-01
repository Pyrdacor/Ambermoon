using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace AmbermoonEventEditor
{
    public enum ValueType
    {
        Byte,
        Word,
        Bool,
        Enum,
        Flag8,
        Flag16,
        EventIndex
    }

    class ValueDescription
    {
        public ValueType Type { get; set; } = ValueType.Byte;
        public ushort DefaultValue { get; set; } = 0;
        public string Name { get; set; }
        /// <summary>
        /// Must be set by the user in any case.
        /// </summary>
        public bool Required { get; set; }
        /// <summary>
        /// Hidden properties are always set to the default value
        /// and are not shown.
        /// </summary>
        public bool Hidden { get; set; }
        public bool ShowAsHex { get; set; }
        public ushort MinValue { get; set; } = 0;
        public ushort MaxValue { get; set; }
        public int FlagDescriptionOffset { get; set; } = 0;
        public string[] FlagDescriptions { get; set; } = null;
        public virtual string GetPossibleValues()
        {
            switch (Type)
            {
                case ValueType.Byte:
                    if (MinValue > 0xff)
                        throw new Exception("Invalid min value for type byte");
                    return $"0x{MinValue:x2} ~ 0x{Math.Min(0xff, (int)MaxValue):x2}";
                case ValueType.Word:
                    return $"0x{MinValue:x4} ~ 0x{MaxValue:x4}";
                case ValueType.Bool:
                    return "0 or 1";
                case ValueType.Flag8:
                    if (FlagDescriptions != null)
                        return string.Join("\r\n", FlagDescriptions.Select((d, i) => $"{1 << (FlagDescriptionOffset + i):x2}: {d}"));
                    return "0x00 ~ 0xff";
                case ValueType.Flag16:
                    if (FlagDescriptions != null)
                        return string.Join("\r\n", FlagDescriptions.Select((d, i) => $"{1 << (FlagDescriptionOffset + i):x4}: {d}"));
                    return "0x0000 ~ 0xffff";
                default:
                    throw new Exception();
            }
        }
        public virtual bool Check(ushort input)
        {
            switch (Type)
            {
                case ValueType.Bool:
                    return input == 0 || input == 1;
                case ValueType.Byte:
                case ValueType.Flag8:
                    return input >= MinValue && input <= MaxValue && input <= 0xff;
                case ValueType.Word:
                case ValueType.Flag16:
                case ValueType.EventIndex:
                    return input >= MinValue && input <= MaxValue;
            }

            return false;
        }
        public virtual string DefaultValueText => DefaultValue.ToString();
    }

    class EventIndexDescription : ValueDescription
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

    class EnumValueDescription<TEnum> : ValueDescription where TEnum : System.Enum
    {
        public TEnum[] AllowedValues { get; }

        public EnumValueDescription(string name, bool required, bool hidden, TEnum defaultValue, TEnum[] allowedValues)
        {
            Name = name;
            Required = required;
            Hidden = !required && hidden;
            var values = System.Enum.GetValues(typeof(TEnum)).OfType<TEnum>();
            MinValue = (ushort)Convert.ChangeType(values.Min(), typeof(ushort));
            MaxValue = (ushort)Convert.ChangeType(values.Max(), typeof(ushort));
            DefaultValue = (ushort)Convert.ChangeType(defaultValue, typeof(ushort));
            AllowedValues = allowedValues;
        }

        public override string GetPossibleValues()
        {
            if (AllowedValues != null && AllowedValues.Length != 0)
                return string.Join("\r\n", AllowedValues);

            return string.Join("\r\n", System.Enum.GetValues(typeof(TEnum)));
        }

        public override bool Check(ushort input)
        {
            return System.Enum.GetValues(typeof(TEnum)).OfType<TEnum>().Select(e => (ushort)Convert.ChangeType(e, typeof(ushort))).Contains(input);
        }

        public override string DefaultValueText => ((TEnum)(object)(int)DefaultValue).ToString();
    }

    // Shortcut for description creation -> Use.Byte(...) etc
    static class Use
    {
        public static ValueDescription EventIndex(string name, bool required) => new EventIndexDescription(name, required);

        public static ValueDescription Byte(string name, bool required, byte maxValue = 255, byte minValue = 0, byte defaultValue = 0, bool showAsHex = false) => new ValueDescription
        {
            Type = ValueType.Byte,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenByte(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Byte,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Word(string name, bool required, ushort maxValue = 65535, ushort minValue = 0, ushort defaultValue = 0, bool showAsHex = false) => new ValueDescription
        {
            Type = ValueType.Word,
            Name = name,
            MinValue = minValue,
            MaxValue = maxValue,
            DefaultValue = defaultValue,
            Required = required,
            ShowAsHex = showAsHex
        };

        public static ValueDescription HiddenWord(ushort defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Word,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Bool(string name, bool required, bool defaultValue = false) => new ValueDescription
        {
            Type = ValueType.Bool,
            Name = name,
            MinValue = 0,
            MaxValue = 1,
            DefaultValue = (ushort)(defaultValue ? 1 : 0),
            Required = required
        };

        public static ValueDescription HiddenBool(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Bool,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flag8(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new ValueDescription
        {
            Type = ValueType.Flag8,
            Name = name,
            MinValue = 0,
            MaxValue = 255,
            DefaultValue = 0,
            Required = required,
            FlagDescriptionOffset = flagDescriptionOffset,
            FlagDescriptions = flagDescriptions
        };

        public static ValueDescription HiddenFlag8(byte defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Flag8,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static ValueDescription Flag16(string name, bool required, int flagDescriptionOffset, params string[] flagDescriptions) => new ValueDescription
        {
            Type = ValueType.Flag16,
            Name = name,
            MinValue = 0,
            MaxValue = 65535,
            DefaultValue = 0,
            Required = required,
            FlagDescriptionOffset = flagDescriptionOffset,
            FlagDescriptions = flagDescriptions
        };

        public static ValueDescription HiddenFlag16(ushort defaultValue = 0) => new ValueDescription
        {
            Type = ValueType.Flag16,
            Name = "Unknown",
            DefaultValue = defaultValue,
            Required = false,
            Hidden = true
        };

        public static EnumValueDescription<TEnum> Enum<TEnum>(string name, bool required, TEnum defaultValue = default(TEnum),
            params TEnum[] allowedValues)
            where TEnum : System.Enum => new EnumValueDescription<TEnum>(name, required, false, defaultValue, allowedValues);

        public static EnumValueDescription<TEnum> HiddenEnum<TEnum>(TEnum defaultValue = default(TEnum))
            where TEnum : System.Enum => new EnumValueDescription<TEnum>("Unknown", false, true, defaultValue, null);
    }

    class EventDescription
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

    static class EventDescriptions
    {
        public static string ToString(Event @event, int identation, string subIdentation = "  ")
        {
            if (Events.TryGetValue(@event.Type, out var description))
            {
                string info = $"{@event.Type}:";
                var type = @event.GetType();

                foreach (var value in description.ValueDescriptions)
                {
                    if (value.Hidden)
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
                Use.Byte("X", true, 50),
                Use.Byte("Y", true, 50),
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
                Use.Enum<ChestEvent.ChestFlags>("Flags", false),
                Use.Byte("TextIndex", false, 0xff, 0x00, 0xff),
                Use.Byte("ChestIndex", true),
                Use.Enum<ChestEvent.ChestLootFlags>("LootFlags", false),
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
            { EventType.Award, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<AwardEvent.AwardType>("TypeOfAward", true),
                Use.Enum("Operation", true, AwardEvent.AwardOperation.Increase),
                Use.Bool("Random", true),
                Use.Enum("Target", true, AwardEvent.AwardTarget.ActivePlayer),
                Use.HiddenByte(),
                Use.Word("AwardTypeValue", false),
                Use.Word("Value", false)
            )},
            { EventType.ChangeTile, new EventDescription
            (
                true, true, true, true, false,
                Use.Byte("X", true, 50),
                Use.Byte("Y", true, 50),
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
                Use.Word("MerchantDataIndex", false)
            )},
            { EventType.Condition, new EventDescription
            (
                true, true, true, false, false,
                Use.Enum<ConditionEvent.ConditionType>("TypeOfCondition", true),
                Use.Byte("Value", true),
                Use.Byte("Count", false),
                Use.HiddenByte(),
                Use.HiddenByte(),
                Use.Word("ObjectIndex", true),
                Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
            )},
            { EventType.Action, new EventDescription
            (
                true, true, true, true, false,
                Use.Enum<ActionEvent.ActionType>("TypeOfAction", true),
                Use.Byte("Value", true),
                Use.Byte("Count", false),
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
                Use.Byte("X", true, 50),
                Use.Byte("Y", true, 50),
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
