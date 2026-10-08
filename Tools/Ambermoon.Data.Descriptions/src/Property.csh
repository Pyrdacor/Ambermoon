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
    switch (e.Data)
    {
        case TeleportEvent t:
            switch (name)
            {
                case "MapIndex": return PropertyValue.Of(t.MapIndex);
                case "X": return PropertyValue.Of(t.X);
                case "Y": return PropertyValue.Of(t.Y);
                case "Direction": return PropertyValue.OfEnum(t.Direction, false);
                case "NewTravelType": return t.NewTravelType is TravelType travelType ? PropertyValue.OfEnum(travelType, false) : PropertyValue.Null();
                case "Transition": return PropertyValue.OfEnum(t.Transition, false);
            }
            break;
        case DoorEvent d:
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
            break;
        case ChestEvent c:
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
            break;
        case PopupTextEvent p:
            switch (name)
            {
                case "TextIndex": return PropertyValue.Of(p.TextIndex);
                case "EventImageIndex": return PropertyValue.Of(p.EventImageIndex);
                case "PopupTrigger": return PropertyValue.OfEnum(p.PopupTrigger, true);
                case "TriggerIfBlind": return PropertyValue.OfBool(p.TriggerIfBlind);
            }
            break;
        case SpinnerEvent s:
            if (name == "Direction")
                return PropertyValue.OfEnum(s.Direction, false);
            break;
        case TrapEvent t:
            switch (name)
            {
                case "Ailment": return PropertyValue.OfEnum(t.Ailment, false);
                case "Target": return PropertyValue.OfEnum(t.Target, false);
                case "BaseDamage": return PropertyValue.Of(t.BaseDamage);
                case "AffectedGenders": return PropertyValue.OfEnum(t.AffectedGenders, true);
            }
            break;
        case ChangeBuffsEvent b:
            switch (name)
            {
                case "AffectedBuff": return b.AffectedBuff is ActiveSpellType buff ? PropertyValue.OfEnum(buff, false) : PropertyValue.Null();
                case "Add": return PropertyValue.OfBool(b.Add);
                case "Unused1": return PropertyValue.Of(b.Unused1);
                case "Value": return PropertyValue.Of(b.Value);
                case "Duration": return PropertyValue.Of(b.Duration);
            }
            break;
        case RiddlemouthEvent r:
            switch (name)
            {
                case "RiddleTextIndex": return PropertyValue.Of(r.RiddleTextIndex);
                case "SolutionTextIndex": return PropertyValue.Of(r.SolutionTextIndex);
                case "CorrectAnswerDictionaryIndex1": return PropertyValue.Of(r.CorrectAnswerDictionaryIndex1);
                case "CorrectAnswerDictionaryIndex2": return PropertyValue.Of(r.CorrectAnswerDictionaryIndex2);
            }
            break;
        case RewardEvent r:
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
            break;
        case ChangeTileEvent c:
            switch (name)
            {
                case "X": return PropertyValue.Of(c.X);
                case "Y": return PropertyValue.Of(c.Y);
                case "FrontTileIndex": return PropertyValue.Of(c.FrontTileIndex);
                case "MapIndex": return PropertyValue.Of(c.MapIndex);
            }
            break;
        case StartBattleEvent s:
            if (name == "MonsterGroupIndex")
                return PropertyValue.Of(s.MonsterGroupIndex);
            break;
        case EnterPlaceEvent p:
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
            break;
        case ConditionEvent c:
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
            break;
        case PartyMemberConditionEvent c:
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
            break;
        case ActionEvent a:
            switch (name)
            {
                case "TypeOfAction": return PropertyValue.OfEnum(a.TypeOfAction, false);
                case "ObjectIndex": return PropertyValue.Of(a.ObjectIndex);
                case "Value": return PropertyValue.Of(a.Value);
                case "Count": return PropertyValue.Of(a.Count);
            }
            break;
        case Dice100RollEvent d:
            switch (name)
            {
                case "Chance": return PropertyValue.Of(d.Chance);
                case "ContinueIfFalseWithMapEventIndex": return PropertyValue.Of(d.ContinueIfFalseWithMapEventIndex);
                case "AlternativeBranchEventIndex": return PropertyValue.Of(d.ContinueIfFalseWithMapEventIndex);
            }
            break;
        case ConversationEvent c:
            switch (name)
            {
                case "Interaction": return PropertyValue.OfEnum(c.Interaction, false);
                case "Value": return PropertyValue.Of(c.Value);
                case "KeywordIndex": return PropertyValue.Of(c.Value);
                case "ItemIndex": return PropertyValue.Of(c.Value);
            }
            break;
        case PrintTextEvent p:
            if (name == "NPCTextIndex")
                return PropertyValue.Of(p.NPCTextIndex);
            break;
        case CreateEvent c:
            switch (name)
            {
                case "TypeOfCreation": return PropertyValue.OfEnum(c.TypeOfCreation, false);
                case "Amount": return PropertyValue.Of(c.Amount);
                case "ItemIndex": return PropertyValue.Of(c.ItemIndex);
            }
            break;
        case DecisionEvent d:
            switch (name)
            {
                case "TextIndex": return PropertyValue.Of(d.TextIndex);
                case "NoEventIndex": return PropertyValue.Of(d.NoEventIndex);
                case "AlternativeBranchEventIndex": return PropertyValue.Of(d.NoEventIndex);
            }
            break;
        case ChangeMusicEvent m:
            switch (name)
            {
                case "MusicIndex": return PropertyValue.Of(m.MusicIndex);
                case "Volume": return PropertyValue.Of(m.Volume);
            }
            break;
        case SpawnEvent s:
            switch (name)
            {
                case "X": return PropertyValue.Of(s.X);
                case "Y": return PropertyValue.Of(s.Y);
                case "TravelType": return PropertyValue.OfEnum(s.TravelType, false);
                case "MapIndex": return PropertyValue.Of(s.MapIndex);
            }
            break;
        case RemovePartyMemberEvent r:
            switch (name)
            {
                case "CharacterIndex": return PropertyValue.Of(r.CharacterIndex);
                case "ChestIndexEquipment": return PropertyValue.Of(r.ChestIndexEquipment);
                case "ChestIndexInventory": return PropertyValue.Of(r.ChestIndexInventory);
            }
            break;
        case DelayEvent d:
            if (name == "Milliseconds")
                return PropertyValue.Of(d.Milliseconds);
            break;
        case ShakeEvent s:
            if (name == "Shakes")
                return PropertyValue.Of(s.Shakes);
            break;
        case ShowMapEvent s:
            if (name == "Options")
                return PropertyValue.OfEnum(s.Options, true);
            break;
        case ToggleSwitchEvent t:
            switch (name)
            {
                case "FrontTileIndexOff": return PropertyValue.Of(t.FrontTileIndexOff);
                case "FrontTileIndexOn": return PropertyValue.Of(t.FrontTileIndexOn);
            }
            break;
        case DynamicChangeTileEvent d:
            switch (name)
            {
                case "X": return PropertyValue.Of(d.X);
                case "Y": return PropertyValue.Of(d.Y);
                case "GlobalVariable": return PropertyValue.Of(d.GlobalVariable);
                case "FrontTileIndexOff": return PropertyValue.Of(d.FrontTileIndexOff);
                case "FrontTileIndexOn": return PropertyValue.Of(d.FrontTileIndexOn);
                case "MapIndex": return PropertyValue.Of(d.MapIndex);
            }
            break;
        case RectangularExplorationEvent r:
            switch (name)
            {
                case "X": return PropertyValue.Of(r.X);
                case "Y": return PropertyValue.Of(r.Y);
                case "Width": return PropertyValue.Of(r.Width);
                case "Height": return PropertyValue.Of(r.Height);
                case "Exploration": return PropertyValue.OfEnum(r.Exploration, false);
                case "MapIndex": return PropertyValue.Of(r.MapIndex);
            }
            break;
        case VerticalLineRevealEvent v:
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
            break;
        default:
            break;
    }
    if (name == "Index")
        return PropertyValue.Of(e.Index);
    if (name == "Type")
        return PropertyValue.OfEnum(e.Type, false);
    return PropertyValue.Missing();
}
