//! Descriptions of the values of events, for editors (a port of Ambermoon.Data.Descriptions of
//! https://github.com/Pyrdacor/Ambermoon): their types, ranges, names and how they are shown.
namespace Ambermoon.Data.Descriptions;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

/// The value of a property of an event, as the original reads it by its name with reflection.
struct PropertyValue
{
    /// A nullable property without a value.
    bool IsNull;
    /// A bool property (Number is 1 or 0).
    bool IsBool;
    /// The value as a number (enums: their value).
    uint64 Number;
    /// The text of the value as .NET writes it ("True", the name of an enum value, "" for null).
    string Text;
    /// Whether the property exists.
    bool Exists;

    static PropertyValue Of(uint64 number)
    {
        return PropertyValue { Number = number, Text = number.ToString(), Exists = true };
    }

    static PropertyValue OfBool(bool value)
    {
        return PropertyValue { IsBool = true, Number = value ? 1u : 0u, Text = value ? "True" : "False", Exists = true };
    }

    static PropertyValue OfEnum<T>(T value, bool isFlags)
    {
        return PropertyValue { Number = EnumInfo.ToUnsigned((int64)value, sizeof(T)), Text = EnumText(value, isFlags), Exists = true };
    }

    static PropertyValue Null()
    {
        return PropertyValue { IsNull = true, Text = "", Exists = true };
    }

    static PropertyValue Missing()
    {
        return PropertyValue { Text = "" };
    }
}

/// The property `name` of the event (what the descriptions name; Type.GetProperty(name).GetValue(event) of the
/// original).
PropertyValue GetProperty(Event e, string name)
{
    // one function per event type: as one function, the code was too large for the short branches of the m68k
    // backend (the Amiga builds of the tools)
    var value = PropertyValue.Missing();
    switch (e.Data)
    {
        case TeleportEvent t:
            value = _PropertyOfTeleportEvent(t, name);
            break;
        case DoorEvent d:
            value = _PropertyOfDoorEvent(d, name);
            break;
        case ChestEvent c:
            value = _PropertyOfChestEvent(c, name);
            break;
        case PopupTextEvent p:
            value = _PropertyOfPopupTextEvent(p, name);
            break;
        case SpinnerEvent s:
            value = _PropertyOfSpinnerEvent(s, name);
            break;
        case TrapEvent t:
            value = _PropertyOfTrapEvent(t, name);
            break;
        case ChangeBuffsEvent b:
            value = _PropertyOfChangeBuffsEvent(b, name);
            break;
        case RiddlemouthEvent r:
            value = _PropertyOfRiddlemouthEvent(r, name);
            break;
        case RewardEvent r:
            value = _PropertyOfRewardEvent(r, name);
            break;
        case ChangeTileEvent c:
            value = _PropertyOfChangeTileEvent(c, name);
            break;
        case StartBattleEvent s:
            value = _PropertyOfStartBattleEvent(s, name);
            break;
        case EnterPlaceEvent p:
            value = _PropertyOfEnterPlaceEvent(p, name);
            break;
        case ConditionEvent c:
            value = _PropertyOfConditionEvent(c, name);
            break;
        case PartyMemberConditionEvent c:
            value = _PropertyOfPartyMemberConditionEvent(c, name);
            break;
        case ActionEvent a:
            value = _PropertyOfActionEvent(a, name);
            break;
        case Dice100RollEvent d:
            value = _PropertyOfDice100RollEvent(d, name);
            break;
        case ConversationEvent c:
            value = _PropertyOfConversationEvent(c, name);
            break;
        case PrintTextEvent p:
            value = _PropertyOfPrintTextEvent(p, name);
            break;
        case CreateEvent c:
            value = _PropertyOfCreateEvent(c, name);
            break;
        case DecisionEvent d:
            value = _PropertyOfDecisionEvent(d, name);
            break;
        case ChangeMusicEvent m:
            value = _PropertyOfChangeMusicEvent(m, name);
            break;
        case SpawnEvent s:
            value = _PropertyOfSpawnEvent(s, name);
            break;
        case RemovePartyMemberEvent r:
            value = _PropertyOfRemovePartyMemberEvent(r, name);
            break;
        case DelayEvent d:
            value = _PropertyOfDelayEvent(d, name);
            break;
        case ShakeEvent s:
            value = _PropertyOfShakeEvent(s, name);
            break;
        case ShowMapEvent s:
            value = _PropertyOfShowMapEvent(s, name);
            break;
        case ToggleSwitchEvent t:
            value = _PropertyOfToggleSwitchEvent(t, name);
            break;
        case DynamicChangeTileEvent d:
            value = _PropertyOfDynamicChangeTileEvent(d, name);
            break;
        case RectangularExplorationEvent r:
            value = _PropertyOfRectangularExplorationEvent(r, name);
            break;
        case VerticalLineRevealEvent v:
            value = _PropertyOfVerticalLineRevealEvent(v, name);
            break;
        default:
            break;
    }
    if (value.Exists)
        return value;
    if (name == "Index")
        return PropertyValue.Of(e.Index);
    if (name == "Type")
        return PropertyValue.OfEnum(e.Type, false);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfTeleportEvent(TeleportEvent t, string name)
{
    switch (name)
    {
        case "MapIndex": return PropertyValue.Of(t.MapIndex);
        case "X": return PropertyValue.Of(t.X);
        case "Y": return PropertyValue.Of(t.Y);
        case "Direction": return PropertyValue.OfEnum(t.Direction, false);
        case "NewTravelType": return t.NewTravelType is TravelType travelType ? PropertyValue.OfEnum(travelType, false) : PropertyValue.Null();
        case "Transition": return PropertyValue.OfEnum(t.Transition, false);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfDoorEvent(DoorEvent d, string name)
{
    switch (name)
    {
        case "LockpickingChanceReduction": return PropertyValue.Of(d.LockpickingChanceReduction);
        case "DoorIndex": return PropertyValue.Of(d.DoorIndex);
        case "TextIndex": return PropertyValue.Of(d.TextIndex);
        case "UnlockTextIndex": return PropertyValue.Of(d.UnlockTextIndex);
        case "Unused": return PropertyValue.Of(d.Unused);
        case "KeyIndex": return PropertyValue.Of(d.KeyIndex);
        case "UnlockFailedEventIndex": return PropertyValue.Of(d.UnlockFailedEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(d.UnlockFailedEventIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfChestEvent(ChestEvent c, string name)
{
    switch (name)
    {
        case "LockpickingChanceReduction": return PropertyValue.Of(c.LockpickingChanceReduction);
        case "TextIndex": return PropertyValue.Of(c.TextIndex);
        case "ChestIndex": return PropertyValue.Of(c.ChestIndex);
        case "RealChestIndex": return PropertyValue.Of(c.RealChestIndex());
        case "Flags": return PropertyValue.OfEnum(c.Flags, true);
        case "KeyIndex": return PropertyValue.Of(c.KeyIndex);
        case "UnlockFailedEventIndex": return PropertyValue.Of(c.UnlockFailedEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(c.UnlockFailedEventIndex);
        case "FindChanceReduction": return PropertyValue.Of(c.FindChanceReduction);
        case "SearchSkillCheck": return PropertyValue.OfBool(c.SearchSkillCheck());
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfPopupTextEvent(PopupTextEvent p, string name)
{
    switch (name)
    {
        case "TextIndex": return PropertyValue.Of(p.TextIndex);
        case "EventImageIndex": return PropertyValue.Of(p.EventImageIndex);
        case "PopupTrigger": return PropertyValue.OfEnum(p.PopupTrigger, true);
        case "TriggerIfBlind": return PropertyValue.OfBool(p.TriggerIfBlind);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfSpinnerEvent(SpinnerEvent s, string name)
{
    if (name == "Direction")
        return PropertyValue.OfEnum(s.Direction, false);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfTrapEvent(TrapEvent t, string name)
{
    switch (name)
    {
        case "Ailment": return PropertyValue.OfEnum(t.Ailment, false);
        case "Target": return PropertyValue.OfEnum(t.Target, false);
        case "BaseDamage": return PropertyValue.Of(t.BaseDamage);
        case "AffectedGenders": return PropertyValue.OfEnum(t.AffectedGenders, true);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfChangeBuffsEvent(ChangeBuffsEvent b, string name)
{
    switch (name)
    {
        case "AffectedBuff": return b.AffectedBuff is ActiveSpellType buff ? PropertyValue.OfEnum(buff, false) : PropertyValue.Null();
        case "Add": return PropertyValue.OfBool(b.Add);
        case "Unused1": return PropertyValue.Of(b.Unused1);
        case "Value": return PropertyValue.Of(b.Value);
        case "Duration": return PropertyValue.Of(b.Duration);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfRiddlemouthEvent(RiddlemouthEvent r, string name)
{
    switch (name)
    {
        case "RiddleTextIndex": return PropertyValue.Of(r.RiddleTextIndex);
        case "SolutionTextIndex": return PropertyValue.Of(r.SolutionTextIndex);
        case "CorrectAnswerDictionaryIndex1": return PropertyValue.Of(r.CorrectAnswerDictionaryIndex1);
        case "CorrectAnswerDictionaryIndex2": return PropertyValue.Of(r.CorrectAnswerDictionaryIndex2);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfRewardEvent(RewardEvent r, string name)
{
    switch (name)
    {
        case "TypeOfReward": return PropertyValue.OfEnum(r.TypeOfReward, false);
        case "Target": return PropertyValue.OfEnum(r.Target, false);
        case "Operation": return PropertyValue.OfEnum(r.Operation, false);
        case "Random": return PropertyValue.OfBool(r.Random);
        case "RewardTypeValue": return PropertyValue.Of(r.RewardTypeValue);
        case "Value": return PropertyValue.Of(r.Value);
        case "Unused": return PropertyValue.Of(r.Unused);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfChangeTileEvent(ChangeTileEvent c, string name)
{
    switch (name)
    {
        case "X": return PropertyValue.Of(c.X);
        case "Y": return PropertyValue.Of(c.Y);
        case "FrontTileIndex": return PropertyValue.Of(c.FrontTileIndex);
        case "MapIndex": return PropertyValue.Of(c.MapIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfStartBattleEvent(StartBattleEvent s, string name)
{
    if (name == "MonsterGroupIndex")
        return PropertyValue.Of(s.MonsterGroupIndex);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfEnterPlaceEvent(EnterPlaceEvent p, string name)
{
    switch (name)
    {
        case "OpeningHour": return PropertyValue.Of(p.OpeningHour);
        case "ClosingHour": return PropertyValue.Of(p.ClosingHour);
        case "PlaceIndex": return PropertyValue.Of(p.PlaceIndex);
        case "ClosedTextIndex": return PropertyValue.Of(p.ClosedTextIndex);
        case "PlaceType": return PropertyValue.OfEnum(p.PlaceType, false);
        case "UsePlaceTextIndex": return PropertyValue.Of(p.UsePlaceTextIndex);
        case "MerchantDataIndex": return PropertyValue.Of(p.MerchantDataIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfConditionEvent(ConditionEvent c, string name)
{
    switch (name)
    {
        case "TypeOfCondition": return PropertyValue.OfEnum(c.TypeOfCondition, false);
        case "DisallowedAilments": return PropertyValue.OfEnum(c.DisallowedAilments, true);
        case "ObjectIndex": return PropertyValue.Of(c.ObjectIndex);
        case "Value": return PropertyValue.Of(c.Value);
        case "Count": return PropertyValue.Of(c.Count);
        case "ContinueIfFalseWithMapEventIndex": return PropertyValue.Of(c.ContinueIfFalseWithMapEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(c.ContinueIfFalseWithMapEventIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfPartyMemberConditionEvent(PartyMemberConditionEvent c, string name)
{
    switch (name)
    {
        case "TypeOfCondition": return PropertyValue.OfEnum(c.TypeOfCondition, false);
        case "DisallowedAilments": return PropertyValue.OfEnum(c.DisallowedAilments, true);
        case "Value": return PropertyValue.Of(c.Value);
        case "ConditionValueIndex": return PropertyValue.Of(c.ConditionValueIndex);
        case "Target": return PropertyValue.OfEnum(c.Target, false);
        case "ContinueIfFalseWithMapEventIndex": return PropertyValue.Of(c.ContinueIfFalseWithMapEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(c.ContinueIfFalseWithMapEventIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfActionEvent(ActionEvent a, string name)
{
    switch (name)
    {
        case "TypeOfAction": return PropertyValue.OfEnum(a.TypeOfAction, false);
        case "ObjectIndex": return PropertyValue.Of(a.ObjectIndex);
        case "Value": return PropertyValue.Of(a.Value);
        case "Count": return PropertyValue.Of(a.Count);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfDice100RollEvent(Dice100RollEvent d, string name)
{
    switch (name)
    {
        case "Chance": return PropertyValue.Of(d.Chance);
        case "ContinueIfFalseWithMapEventIndex": return PropertyValue.Of(d.ContinueIfFalseWithMapEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(d.ContinueIfFalseWithMapEventIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfConversationEvent(ConversationEvent c, string name)
{
    switch (name)
    {
        case "Interaction": return PropertyValue.OfEnum(c.Interaction, false);
        case "Value": return PropertyValue.Of(c.Value);
        case "KeywordIndex": return PropertyValue.Of(c.Value);
        case "ItemIndex": return PropertyValue.Of(c.Value);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfPrintTextEvent(PrintTextEvent p, string name)
{
    if (name == "NPCTextIndex")
        return PropertyValue.Of(p.NPCTextIndex);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfCreateEvent(CreateEvent c, string name)
{
    switch (name)
    {
        case "TypeOfCreation": return PropertyValue.OfEnum(c.TypeOfCreation, false);
        case "Amount": return PropertyValue.Of(c.Amount);
        case "ItemIndex": return PropertyValue.Of(c.ItemIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfDecisionEvent(DecisionEvent d, string name)
{
    switch (name)
    {
        case "TextIndex": return PropertyValue.Of(d.TextIndex);
        case "NoEventIndex": return PropertyValue.Of(d.NoEventIndex);
        case "AlternativeBranchEventIndex": return PropertyValue.Of(d.NoEventIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfChangeMusicEvent(ChangeMusicEvent m, string name)
{
    switch (name)
    {
        case "MusicIndex": return PropertyValue.Of(m.MusicIndex);
        case "Volume": return PropertyValue.Of(m.Volume);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfSpawnEvent(SpawnEvent s, string name)
{
    switch (name)
    {
        case "X": return PropertyValue.Of(s.X);
        case "Y": return PropertyValue.Of(s.Y);
        case "TravelType": return PropertyValue.OfEnum(s.TravelType, false);
        case "MapIndex": return PropertyValue.Of(s.MapIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfRemovePartyMemberEvent(RemovePartyMemberEvent r, string name)
{
    switch (name)
    {
        case "CharacterIndex": return PropertyValue.Of(r.CharacterIndex);
        case "ChestIndexEquipment": return PropertyValue.Of(r.ChestIndexEquipment);
        case "ChestIndexInventory": return PropertyValue.Of(r.ChestIndexInventory);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfDelayEvent(DelayEvent d, string name)
{
    if (name == "Milliseconds")
        return PropertyValue.Of(d.Milliseconds);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfShakeEvent(ShakeEvent s, string name)
{
    if (name == "Shakes")
        return PropertyValue.Of(s.Shakes);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfShowMapEvent(ShowMapEvent s, string name)
{
    if (name == "Options")
        return PropertyValue.OfEnum(s.Options, true);
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfToggleSwitchEvent(ToggleSwitchEvent t, string name)
{
    switch (name)
    {
        case "FrontTileIndexOff": return PropertyValue.Of(t.FrontTileIndexOff);
        case "FrontTileIndexOn": return PropertyValue.Of(t.FrontTileIndexOn);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfDynamicChangeTileEvent(DynamicChangeTileEvent d, string name)
{
    switch (name)
    {
        case "X": return PropertyValue.Of(d.X);
        case "Y": return PropertyValue.Of(d.Y);
        case "GlobalVariable": return PropertyValue.Of(d.GlobalVariable);
        case "FrontTileIndexOff": return PropertyValue.Of(d.FrontTileIndexOff);
        case "FrontTileIndexOn": return PropertyValue.Of(d.FrontTileIndexOn);
        case "MapIndex": return PropertyValue.Of(d.MapIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfRectangularExplorationEvent(RectangularExplorationEvent r, string name)
{
    switch (name)
    {
        case "X": return PropertyValue.Of(r.X);
        case "Y": return PropertyValue.Of(r.Y);
        case "Width": return PropertyValue.Of(r.Width);
        case "Height": return PropertyValue.Of(r.Height);
        case "Exploration": return PropertyValue.OfEnum(r.Exploration, false);
        case "MapIndex": return PropertyValue.Of(r.MapIndex);
    }
    return PropertyValue.Missing();
}

PropertyValue _PropertyOfVerticalLineRevealEvent(VerticalLineRevealEvent v, string name)
{
    switch (name)
    {
        case "X1": return PropertyValue.Of(v.X1);
        case "Y1": return PropertyValue.Of(v.Y1);
        case "Height1": return PropertyValue.Of(v.Height1);
        case "X2": return PropertyValue.Of(v.X2);
        case "Y2": return PropertyValue.Of(v.Y2);
        case "Height2": return PropertyValue.Of(v.Height2);
        case "X3": return PropertyValue.Of(v.X3);
        case "Y3": return PropertyValue.Of(v.Y3);
        case "Height3": return PropertyValue.Of(v.Height3);
    }
    return PropertyValue.Missing();
}
