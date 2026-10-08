namespace Ambermoon.Data.Descriptions;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;

/// The languages by their bit index (+1).
enum LanguageIndex : int32
{
    Human = 1,
    Elfish,
    Dwarfish,
    Gnomish,
    Sylphic,
    Felinic,
    Morag,
    Animal
}

/// The conditions by their bit index (+1).
enum ConditionIndex : int32
{
    Irritated = 1,
    Crazy,
    Sleep,
    Panic,
    Blind,
    Drugged,
    Exhausted,
    Fleeing,
    Lamed,
    Poisoned,
    Petrified,
    Diseased,
    Aging,
    DeadCorpse,
    DeadAshes,
    DeadDust
}

/// The spell schools by their bit index (+1).
enum SpellTypeIndex : int32
{
    Healing = 1,
    Alchemistic = 2,
    Mystic = 3,
    Destruction = 4,
    Function = 7
}

/// The characters that can join the party.
enum PartyMembers : int32
{
    None,
    Hero,
    Netsrak,
    Mando,
    Erik,
    Chris,
    Monika,
    Tar,
    Egil,
    Selena,
    Nelvin,
    Sabine,
    Valdyn,
    Targor,
    Leonaria,
    Gryban,
    Kasimir
}

/// What an event type allows and the descriptions of its 9 data bytes.
struct EventDescription
{
    bool AllowMaps;
    bool AllowNPCs;
    bool AllowAsFirst;
    bool AllowAsSingle;
    bool AllowOnlyAsFirst;
    /// The slots of the value descriptions in [ValueDescriptions], in the order of the data.
    int[] Slots;
}

/// All value descriptions of the event descriptions, by their slot (they are changed while the program runs, like the
/// objects of the original).
List<ValueDescription> ValueDescriptions = List<ValueDescription>.Create();

/// The event descriptions by event type (EventDescriptions.Events of the original), in the order of the original.
Dictionary<EventType, EventDescription> EventDescriptionTable = _CreateEventDescriptions();

/// The functions of EventDescriptions of the original.
struct EventDescriptions
{
    /// The description of the event type, `null` if there is none.
    static Optional<EventDescription> Get(EventType type)
    {
        return EventDescriptionTable.TryGet(type);
    }

    /// The event types that have descriptions, in their order.
    static EventType[] Types()
    {
        return EventDescriptionTable.Keys();
    }

    /// The value description in a slot (as it is now).
    static ValueDescription Value(int slot)
    {
        return ValueDescriptions[slot];
    }

    /// Stores a changed value description (nothing for temporary ones).
    static void Store(ValueDescription value)
    {
        if (value.Slot >= 0)
            ValueDescriptions[value.Slot] = value;
    }

    /// " Name=value," for a value of the event (ToString(Event, ValueDescription) of the original). A display
    /// mapping is used once: the original sets it to null to avoid recursive loops and does not set it back.
    static string ValueText(Event e, ValueDescription value)
    {
        if (value.DisplayMapping != null)
        {
            var displayMapping = value.DisplayMapping;
            value.DisplayMapping = null;
            Store(value);
            return (displayMapping(e, value) is string mapped ? mapped : "") + ",";
        }

        if (value.Kind == DescriptionKind.TenBits)
        {
            var writer = new DataWriter();
            writer.WriteByte(0); // for the data offsets
            EventWriter.WriteEventData(ref writer, e);
            int propertyValue = value.ReadBits(writer.ToArray());
            return $" {value.DisplayName()}={propertyValue},";
        }

        var property = GetProperty(e, value.Name);

        if (value.FlagDescriptions != null)
        {
            string info = $" {value.DisplayName()}=";
            var bits = (uint16)property.Number;
            for (var i = 0; i < value.FlagDescriptions.Length; i += 1)
            {
                int bit = value.FlagDescriptionOffset + i;
                if ((bits & (1 << bit)) != 0)
                    info += $" {value.FlagDescriptions[i]}|";
            }
            return info.TrimEnd('|') + ",";
        }
        if (value.Kind == DescriptionKind.Enum && value.Flags)
            return $" {value.DisplayName()}=" + value.EnumType.FlagNames(value.EnumType.FromNumber((int64)property.Number)) + ",";
        if (value.ShowAsHex)
        {
            var number = (uint16)property.Number;
            if (value.Type == ValueType.Byte)
                return $" {value.DisplayName()}=0x{number:x2},";
            return $" {value.DisplayName()}=0x{number:x4},";
        }
        if (value.Kind == DescriptionKind.Enum)
        {
            var allowed = value.AllowedValues();
            var names = value.AllowedValueNames();
            int number = property.IsNull ? 0 : (int)property.Number;
            int index = -1;
            for (var i = 0; i < allowed.Length; i += 1)
            {
                if ((int)allowed[i] == number && index == -1)
                    index = i;
            }
            string enumValue = index >= 0 && index < names.Length ? names[index] : value.EnumType.Text(value.EnumType.FromNumber((int64)property.Number));
            return $" {value.DisplayName()}={enumValue},";
        }
        return $" {value.DisplayName()}={property.Text},";
    }

    /// The event as one or two lines ("Type: Name=value, ..."), broken at a space if it is longer than
    /// 80 - `identation` characters, the next line starting with `subIdentation`. "" for events without description.
    static string ToString(Event e, int identation, string subIdentation)
    {
        if (Get(e.Type) is not EventDescription description)
            return "";

        string info = $"{e.Type}:";
        foreach (var slot in description.Slots)
        {
            var value = ValueDescriptions[slot];
            if (value.Hidden || (value.Condition != null && !value.Condition(e)))
                continue;
            info += ValueText(e, value);
        }

        info = info.TrimEnd(',').TrimEnd(' ').ToString();

        if (info.Length > 80 - identation)
        {
            int lastSpaceIndex = info.Substring(0, 80 - identation).LastIndexOf(' ');
            if (lastSpaceIndex != -1)
            {
                info = info[..lastSpaceIndex] + "\r\n" + subIdentation + info[(lastSpaceIndex + 1)..];
                if (info.Length - lastSpaceIndex - 1 > 80)
                {
                    lastSpaceIndex = info.Substring(0, lastSpaceIndex + 80).LastIndexOf(' ');
                    if (lastSpaceIndex != -1)
                        info = info[..lastSpaceIndex] + "\r\n" + subIdentation + info[(lastSpaceIndex + 1)..];
                }
            }
        }

        return info;
    }
}

// ---- the table ----

void _Add(Dictionary<EventType, EventDescription> table, EventType type, bool allowMaps, bool allowNPCs, bool allowAsFirst,
          bool allowAsSingle, bool allowOnlyAsFirst, ValueDescription[] values)
{
    var slots = new int[values.Length];
    for (var i = 0; i < values.Length; i += 1)
    {
        var value = values[i];
        value.Slot = ValueDescriptions.Count();
        ValueDescriptions.Add(value);
        slots[i] = value.Slot;
    }
    table[type] = EventDescription {
        AllowMaps = allowMaps, AllowNPCs = allowNPCs, AllowAsFirst = allowAsFirst, AllowAsSingle = allowAsSingle,
        AllowOnlyAsFirst = allowOnlyAsFirst, Slots = slots
    };
}

int64[] _Range(int64 start, int count)
{
    var values = new int64[count];
    for (var i = 0; i < count; i += 1)
        values[i] = start + i;
    return values;
}

int64[] _AllValues(EnumInfo info)
{
    var values = new int64[info.Values.Length];
    for (var i = 0; i < values.Length; i += 1)
        values[i] = (int64)info.Values[i];
    return values;
}

ValueDescription[] _Hidden(int count)
{
    var values = new ValueDescription[count];
    for (var i = 0; i < count; i += 1)
        values[i] = Use.HiddenByte();
    return values;
}

Dictionary<EventType, EventDescription> _CreateEventDescriptions()
{
    var table = Dictionary<EventType, EventDescription>.Create();
    var directions = EnumInfo.Of<CharacterDirection>(false);
    int64[] distinctDirections = [0, 1, 2, 3, 4]; // Enum.GetValues<CharacterDirection>().Distinct()

    var teleportDirection = Use.Enum(directions, "Direction", false, (int64)CharacterDirection.Keep, distinctDirections, _TeleportDirectionName);
    teleportDirection.ValueFilter = _SameValues;
    teleportDirection.ValueNameFilter = _WithoutRandom;
    _Add(table, EventType.Teleport, true, true, true, true, false, [
        Use.Byte("X", true, 200),
        Use.Byte("Y", true, 200),
        teleportDirection,
        Use.HiddenByte(0xff),
        Use.Enum(EnumInfo.Of<TransitionType>(false), "Transition", false),
        Use.Word("MapIndex", true, 1023),
        Use.HiddenByte(0x00),
        Use.HiddenByte(0xff)
    ]);
    _Add(table, EventType.Door, true, false, true, true, false, [
        Use.Byte("LockpickingChanceReduction", false, 100),
        Use.Byte("DoorIndex", true),
        Use.Byte("TextIndex", false, 0xff, 0x00, 0xff),
        Use.Byte("UnlockTextIndex", false, 0xff, 0x00, 0xff),
        Use.HiddenByte(0x00),
        Use.Word("KeyIndex", false),
        Use.EventIndex("UnlockFailedEventIndex", false)
    ]);
    _Add(table, EventType.Chest, true, false, true, true, false, [
        Use.Byte("LockpickingChanceReduction", false, 100),
        Use.Bool("SearchSkillCheck", false),
        Use.Byte("TextIndex", false, 0xff, 0x00, 0xff),
        Use.Byte("ChestIndex", true),
        Use.Flags8(EnumInfo.Of<ChestFlags>(true), "Flags", false),
        Use.Word("KeyIndex", false),
        Use.EventIndex("UnlockFailedEventIndex", false)
    ]);
    _Add(table, EventType.MapText, true, false, true, true, false, [
        Use.Byte("EventImageIndex", false, 0xff, 0x00, 0xff),
        Use.Enum(EnumInfo.Of<EventTrigger>(true), "PopupTrigger", false, (int64)EventTrigger.Always),
        Use.Bool("TriggerIfBlind", false),
        Use.Word("TextIndex", true),
        .._Hidden(4)
    ]);
    var spinnerDirection = Use.Enum(directions, "Direction", true, (int64)CharacterDirection.Random, distinctDirections, _SpinnerDirectionName);
    spinnerDirection.ValueFilter = _SameValues;
    spinnerDirection.ValueNameFilter = _WithoutKeep;
    _Add(table, EventType.Spinner, true, false, true, true, false, [spinnerDirection, .._Hidden(8)]);
    _Add(table, EventType.Trap, true, true, true, true, false, [
        Use.Enum(EnumInfo.Of<TrapAilment>(false), "Ailment", false, (int64)TrapAilment.None),
        Use.Enum(EnumInfo.Of<TrapTarget>(false), "Target", true, (int64)TrapTarget.ActivePlayer),
        Use.Enum(EnumInfo.Of<GenderFlag>(true), "AffectedGenders", false, (int64)GenderFlag.Both),
        Use.Byte("BaseDamage", true),
        .._Hidden(5)
    ]);
    _Add(table, EventType.ChangeBuffs, true, true, true, true, false, [
        Use.WithDisplayMapping(Use.Byte("AffectedBuff", false, 6), _AffectedBuffDisplay),
        Use.Bool("Add", false),
        Use.HiddenByte(),
        Use.Conditional(Use.Word("Value", true, 100, 1), _IsAddBuff),
        Use.Conditional(Use.Word("Duration", true, 180, 1), _IsAddBuff),
        Use.HiddenByte(),
        Use.HiddenByte()
    ]);
    _Add(table, EventType.Riddlemouth, true, false, true, true, false, [
        Use.Byte("RiddleTextIndex", true),
        Use.Byte("SolutionTextIndex", true),
        .._Hidden(3),
        Use.Word("CorrectAnswerDictionaryIndex1", true),
        Use.Word("CorrectAnswerDictionaryIndex2", false)
    ]);
    var rewardTargets = EnumInfo.Of<RewardTarget>(false);
    _Add(table, EventType.Reward, true, true, true, true, false, [
        Use.Enum(EnumInfo.Of<RewardType>(false), "TypeOfReward", true),
        Use.Conditional(Use.Enum(EnumInfo.Of<RewardOperation>(false), "Operation", true, (int64)RewardOperation.Increase), _RewardHasOperation),
        Use.Conditional(Use.Bool("Random", true), _RewardHasRandom),
        Use.Enum(rewardTargets, "Target", true, (int64)RewardTarget.ActivePlayer,
                 [0, 1, 2, 3, .._Range(100, (int)PartyMembers.Kasimir), .._Range(200, (int)PartyMembers.Kasimir)], _RewardTargetName),
        Use.HiddenByte(),
        Use.Conditional(Use.WithDisplayMapping(Use.Word("RewardTypeValue", true), _RewardTypeValueDisplay), _RewardHasTypeValue),
        Use.Conditional(Use.Word("Value", false), _RewardHasValue)
    ]);
    _Add(table, EventType.ChangeTile, true, true, true, true, false, [
        Use.Byte("X", true, 200),
        Use.Byte("Y", true, 200),
        .._Hidden(3),
        Use.Word("FrontTileIndex", true),
        Use.Word("MapIndex", true, 1023)
    ]);
    _Add(table, EventType.StartBattle, true, false, true, true, false, [.._Hidden(6), Use.Byte("MonsterGroupIndex", true), .._Hidden(2)]);
    _Add(table, EventType.EnterPlace, true, false, true, true, false, [
        Use.Byte("ClosedTextIndex", false, 0xff, 0x00, 0xff),
        Use.Enum(EnumInfo.Of<PlaceType>(false), "PlaceType", true),
        Use.Byte("OpeningHour", true, 23),
        Use.Byte("ClosingHour", true, 23),
        Use.Byte("UsePlaceTextIndex", false, 0xff, 0, 0xff),
        Use.Word("PlaceIndex", true),
        Use.Conditional(Use.Word("MerchantDataIndex", false), _IsMerchantPlace)
    ]);
    _Add(table, EventType.Condition, true, true, true, false, false, [
        Use.Enum(EnumInfo.Of<ConditionType>(false), "TypeOfCondition", true),
        Use.Byte("Value", true),
        Use.WithDisplayNameMapping(Use.Conditional(Use.Byte("Count", false), _ConditionHasCount), _ConditionCountName),
        Use.Conditional(Use.Flags16(EnumInfo.Of<Condition>(true), "DisallowedAilments", false), _ConditionIsPartyMember),
        Use.Conditional(Use.Word("ObjectIndex", true), _ConditionHasObjectIndex),
        Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
    ]);
    _Add(table, EventType.Action, true, true, true, true, false, [
        Use.Enum(EnumInfo.Of<ActionType>(false), "TypeOfAction", true),
        Use.Byte("Value", true),
        Use.Conditional(Use.Byte("Count", false), _ActionIsAddItem),
        .._Hidden(2),
        Use.Word("ObjectIndex", true),
        .._Hidden(2)
    ]);
    _Add(table, EventType.Dice100Roll, true, true, true, false, false, [
        Use.Byte("Chance", true, 100, 1, 50),
        .._Hidden(6),
        Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
    ]);
    _Add(table, EventType.Conversation, false, true, true, false, true, [
        Use.Enum(EnumInfo.Of<InteractionType>(false), "Interaction", true, (int64)InteractionType.Talk),
        .._Hidden(4),
        Use.Word("Value", false),
        .._Hidden(2)
    ]);
    _Add(table, EventType.PrintText, false, true, false, false, false, [Use.Byte("NPCTextIndex", true), .._Hidden(8)]);
    _Add(table, EventType.Create, false, true, false, false, false, [
        Use.Enum(EnumInfo.Of<CreateType>(false), "TypeOfCreation", false, (int64)CreateType.Item),
        .._Hidden(4),
        Use.Word("Amount", false, 0xffff, 1, 1),
        Use.Word("ItemIndex", false)
    ]);
    _Add(table, EventType.Decision, true, false, true, true, false, [
        Use.Byte("TextIndex", true),
        .._Hidden(6),
        Use.EventIndex("NoEventIndex", false)
    ]);
    _Add(table, EventType.ChangeMusic, true, true, true, true, false, [
        Use.Word("MusicIndex", true),
        Use.Byte("Volume", false, 255, 0, 255, true),
        .._Hidden(6)
    ]);
    _Add(table, EventType.Exit, false, true, false, false, false, _Hidden(9));
    _Add(table, EventType.Spawn, true, true, true, true, false, [
        Use.Byte("X", true, 200),
        Use.Byte("Y", true, 200),
        Use.Enum(EnumInfo.Of<TravelType>(false), "TravelType", true, (int64)TravelType.Horse,
                 [(int64)TravelType.Horse, (int64)TravelType.Raft, (int64)TravelType.Ship, (int64)TravelType.SandLizard, (int64)TravelType.SandShip], null),
        .._Hidden(2),
        Use.Word("MapIndex", true, 1023),
        .._Hidden(2)
    ]);
    _Add(table, EventType.Interact, false, true, false, false, false, _Hidden(9));
    _Add(table, EventType.RemovePartyMember, true, true, true, true, false, [
        Use.Enum(EnumInfo.Of<PartyMembers>(false), "CharacterIndex", true, (int64)PartyMembers.Netsrak, _Range(2, 15), null), // without None and Hero
        Use.Byte("ChestIndexEquipment", true),
        Use.Byte("ChestIndexInventory", true),
        .._Hidden(2),
        Use.HiddenWord(),
        Use.HiddenWord()
    ]);
    _Add(table, EventType.Delay, true, true, true, true, false, [.._Hidden(5), Use.Word("Milliseconds", true), Use.HiddenWord()]);
    _Add(table, EventType.PartyMemberCondition, true, true, true, false, false, [
        Use.Enum(EnumInfo.Of<PartyMemberConditionType>(false), "TypeOfCondition", true),
        Use.WithDisplayMapping(Use.Conditional(Use.Byte("ConditionValueIndex", false), _PartyMemberConditionHasValueIndex),
                               _ConditionValueIndexDisplay),
        Use.Enum(EnumInfo.Of<PartyMemberConditionTarget>(false), "Target", true, (int64)PartyMemberConditionTarget.ActivePlayer,
                 [0, 1, 2, 3, 4, 5, 6, 0xff, .._Range(7, (int)PartyMembers.Kasimir)], _PartyMemberConditionTargetName),
        Use.Flags16(EnumInfo.Of<Condition>(true), "DisallowedAilments", false),
        Use.Conditional(Use.Word("Value", true), _PartyMemberConditionHasValue),
        Use.EventIndex("ContinueIfFalseWithMapEventIndex", false)
    ]);
    _Add(table, EventType.Shake, true, true, true, true, false, [.._Hidden(5), Use.Word("Shakes", true), Use.HiddenWord()]);
    _Add(table, EventType.ShowMap, true, false, true, true, false, [
        Use.Flags8(EnumInfo.Of<MapOptions>(true), "Options", true),
        .._Hidden(4),
        Use.HiddenWord(),
        Use.HiddenWord()
    ]);
    _Add(table, EventType.ToggleSwitch, true, false, true, true, false, [
        Use.TenBits("GlobalVar1", "GlobalVariableBytes", 1, 0, false),
        Use.TenBits("GlobalVar2", "GlobalVariableBytes", 2, 2, false),
        Use.TenBits("GlobalVar3", "GlobalVariableBytes", 3, 4, false),
        Use.TenBits("GlobalVar4", "GlobalVariableBytes", 4, 6, false),
        Use.Word("FrontTileIndexOff", true),
        Use.Word("FrontTileIndexOn", true)
    ]);
    _Add(table, EventType.DynamicChangeTile, true, true, true, true, false, [
        Use.Byte("X", true, 200),
        Use.Byte("Y", true, 200),
        Use.Word("GlobalVariable", true, 1023),
        Use.TwelveBits("FrontTileIndexOff", "FrontTileIndexOff", 5, 0, true),
        Use.TwelveBits("FrontTileIndexOn", "FrontTileIndexOn", 6, 4, true),
        Use.Word("MapIndex", true, 1023)
    ]);
    _Add(table, EventType.RectangularExploration, true, true, true, true, false, [
        Use.Byte("X", true, 200, 1),
        Use.Byte("Y", true, 200, 1),
        Use.Byte("Width", true, 200, 1),
        Use.Byte("Height", true, 200, 1),
        Use.Enum(EnumInfo.Of<ExplorationType>(false), "Exploration", true, (int64)ExplorationType.Reveal),
        Use.Word("MapIndex", true, 1023),
        Use.HiddenWord()
    ]);
    _Add(table, EventType.VerticalLineReveal, true, true, true, true, false, [
        Use.Byte("X1", true, 200, 1),
        Use.Byte("Y1", true, 200, 1),
        Use.Byte("Height1", true, 200, 1),
        Use.Byte("X2", false, 200),
        Use.Byte("Y2", false, 200),
        Use.Byte("Height2", false, 200),
        Use.Byte("X3", false, 200),
        Use.Byte("Y3", false, 200),
        Use.Byte("Height3", false, 200)
    ]);
    return table;
}

// ---- names of values ----

Optional<string> _TeleportDirectionName(int64 value)
{
    if (value == (int64)CharacterDirection.Random)
        return "Keep";
    return EnumName((CharacterDirection)value);
}

Optional<string> _SpinnerDirectionName(int64 value)
{
    if (value == (int64)CharacterDirection.Keep)
        return "Random";
    return EnumName((CharacterDirection)value);
}

int64[] _SameValues(int64[] values)
{
    return values;
}

string[] _WithoutName(string[] names, string name)
{
    var result = List<string>.Create();
    foreach (var n in names)
    {
        if (n != name)
            result.Add(n);
    }
    return result.ToArray();
}

string[] _WithoutRandom(string[] names)
{
    return _WithoutName(names, "Random");
}

string[] _WithoutKeep(string[] names)
{
    return _WithoutName(names, "Keep");
}

Optional<string> _RewardTargetName(int64 target)
{
    if (target >= 200)
        return $"All but Party Member {target - 199}";
    if (target >= 100)
        return $"Party Member {target - 99}";
    return EnumName((RewardTarget)target);
}

Optional<string> _PartyMemberConditionTargetName(int64 target)
{
    if (target != 255 && target >= 7)
        return $"Party Member {target - 6}";
    return EnumName((PartyMemberConditionTarget)(uint8)target);
}

// ---- conditions ----

bool _IsAddBuff(Event e)
{
    return e.Data is ChangeBuffsEvent b && b.Add;
}

bool _RewardHasOperation(Event e)
{
    if (e.Data is not RewardEvent r)
        return false;
    return r.TypeOfReward != RewardType.ChangePortrait && r.TypeOfReward != RewardType.EmpowerSpells;
}

bool _RewardHasRandom(Event e)
{
    if (e.Data is not RewardEvent r)
        return false;
    var t = r.TypeOfReward;
    return t != RewardType.ChangePortrait && t != RewardType.Conditions && t != RewardType.EmpowerSpells && t != RewardType.Languages &&
           t != RewardType.UsableSpellTypes && t != RewardType.Spells;
}

bool _RewardHasTypeValue(Event e)
{
    if (e.Data is not RewardEvent r)
        return false;
    var t = r.TypeOfReward;
    return t == RewardType.Attribute || t == RewardType.Skill || t == RewardType.MaxAttribute || t == RewardType.MaxSkill ||
           t == RewardType.Conditions || t == RewardType.Languages || t == RewardType.UsableSpellTypes || t == RewardType.Spells;
}

bool _RewardHasValue(Event e)
{
    if (e.Data is not RewardEvent r)
        return false;
    var t = r.TypeOfReward;
    return t != RewardType.Conditions && t != RewardType.Languages && t != RewardType.UsableSpellTypes && t != RewardType.Spells;
}

bool _IsMerchantPlace(Event e)
{
    return e.Data is EnterPlaceEvent p && (p.PlaceType == PlaceType.Merchant || p.PlaceType == PlaceType.Library);
}

bool _ConditionHasCount(Event e)
{
    if (e.Data is not ConditionEvent c)
        return false;
    return c.TypeOfCondition == ConditionType.ItemOwned || c.TypeOfCondition == ConditionType.Attribute || c.TypeOfCondition == ConditionType.Skill;
}

bool _ConditionIsPartyMember(Event e)
{
    return e.Data is ConditionEvent c && c.TypeOfCondition == ConditionType.PartyMember;
}

bool _ConditionHasObjectIndex(Event e)
{
    if (e.Data is not ConditionEvent c)
        return false;
    var t = c.TypeOfCondition;
    return t != ConditionType.CanSee && t != ConditionType.Eye && t != ConditionType.Hand && t != ConditionType.Mouth &&
           t != ConditionType.LastEventResult && t != ConditionType.Levitating && t != ConditionType.IsNight;
}

bool _ActionIsAddItem(Event e)
{
    return e.Data is ActionEvent a && a.TypeOfAction == ActionType.AddItem;
}

bool _PartyMemberConditionHasValueIndex(Event e)
{
    if (e.Data is not PartyMemberConditionEvent c)
        return false;
    var t = c.TypeOfCondition;
    return t == PartyMemberConditionType.Attribute || t == PartyMemberConditionType.Skill || t == PartyMemberConditionType.Language;
}

bool _PartyMemberConditionHasValue(Event e)
{
    return e.Data is PartyMemberConditionEvent c && c.TypeOfCondition != PartyMemberConditionType.Language;
}

// ---- display mappings (with the fallback of Use.WithDisplayMapping) ----

Optional<string> _AffectedBuffDisplay(Event e, ValueDescription description)
{
    if (e.Data is ChangeBuffsEvent b)
    {
        // (the original fails for 'all buffs' (null) here: this shows "All" for it as well)
        if (b.AffectedBuff is not ActiveSpellType buff)
            return "All";
        if ((int)buff == 6)
            return "All";
    }
    return EventDescriptions.ValueText(e, description);
}

Optional<string> _RewardTypeValueDisplay(Event e, ValueDescription description)
{
    if (e.Data is not RewardEvent r)
        return EventDescriptions.ValueText(e, description);

    ValueDescription displayDescription;
    switch (r.TypeOfReward)
    {
        case RewardType.Attribute:
        case RewardType.MaxAttribute:
            displayDescription = Use.WordEnum(EnumInfo.Of<Attribute>(false), description.Name, description.Required, 0, _Range(0, 8));
            break;
        case RewardType.Skill:
        case RewardType.MaxSkill:
            displayDescription = Use.WordEnum(EnumInfo.Of<Skill>(false), description.Name, description.Required, 0, _Range(0, 10));
            break;
        case RewardType.Conditions:
            displayDescription = Use.WordEnum(EnumInfo.Of<ConditionIndex>(false), description.Name, description.Required, 0, new int64[0]);
            break;
        case RewardType.Languages:
            displayDescription = Use.WordEnum(EnumInfo.Of<LanguageIndex>(false), description.Name, description.Required, 0, new int64[0]);
            break;
        case RewardType.UsableSpellTypes:
            displayDescription = Use.WordEnum(EnumInfo.Of<SpellTypeIndex>(false), description.Name, description.Required, 0, new int64[0]);
            break;
        case RewardType.Spells:
            displayDescription = Use.Word(description.Name, description.Required, 1, 30);
            break;
        default:
            return EventDescriptions.ValueText(e, description);
    }
    return EventDescriptions.ValueText(e, displayDescription);
}

Optional<string> _ConditionValueIndexDisplay(Event e, ValueDescription description)
{
    if (e.Data is PartyMemberConditionEvent c)
    {
        if (c.TypeOfCondition == PartyMemberConditionType.Skill)
            return "Skill";
        if (c.TypeOfCondition == PartyMemberConditionType.Attribute)
            return "Attribute";
    }
    return EventDescriptions.ValueText(e, description);
}

string _ConditionCountName(Event e, ValueDescription description)
{
    if (e.Data is ConditionEvent c && (c.TypeOfCondition == ConditionType.Attribute || c.TypeOfCondition == ConditionType.Skill))
        return "Amount";
    return description.DisplayName();
}
