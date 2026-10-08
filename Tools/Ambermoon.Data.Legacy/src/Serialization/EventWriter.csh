namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;

/// Writes the events of maps and characters.
struct EventWriter
{
    /// Writes the events in the format [EventReader.ReadEvents] reads (`events` and `eventList` are ids of `store`).
    static void WriteEvents(ref DataWriter dataWriter, EventStore store, List<int> events, List<int> eventList)
    {
        dataWriter.WriteWord((uint16)eventList.Count());
        foreach (var id in eventList)
            dataWriter.WriteWord((uint16)events.IndexOf(id));

        dataWriter.WriteWord((uint16)events.Count());
        foreach (var id in events)
        {
            var e = store.Get(id);
            dataWriter.WriteByte((uint8)e.Type);
            WriteEventData(ref dataWriter, e);
            dataWriter.WriteWord(e.Next < 0 ? (uint16)0xffff : (uint16)events.IndexOf(e.Next));
        }
    }

    /// Writes the 9 bytes of event data (not the type before them, not the index of the next event behind them).
    static void WriteEventData(ref DataWriter dataWriter, Event e)
    {
        switch (e.Data)
        {
            case TeleportEvent t:
                dataWriter.WriteByte((uint8)t.X);
                dataWriter.WriteByte((uint8)t.Y);
                dataWriter.WriteByte((uint8)t.Direction);
                dataWriter.WriteByte(t.NewTravelType is TravelType travelType ? (uint8)travelType : (uint8)0xff);
                dataWriter.WriteByte((uint8)t.Transition);
                dataWriter.WriteWord((uint16)t.MapIndex);
                dataWriter.WriteBytes(t.Unknown2);
                break;
            case DoorEvent d:
                dataWriter.WriteByte((uint8)d.LockpickingChanceReduction);
                dataWriter.WriteByte(d.DoorIndex);
                dataWriter.WriteByte((uint8)d.TextIndex);
                dataWriter.WriteByte((uint8)d.UnlockTextIndex);
                dataWriter.WriteByte(d.Unused);
                dataWriter.WriteWord((uint16)d.KeyIndex);
                dataWriter.WriteWord((uint16)d.UnlockFailedEventIndex);
                break;
            case ChestEvent c:
                dataWriter.WriteByte((uint8)c.LockpickingChanceReduction);
                dataWriter.WriteByte(c.FindChanceReduction);
                dataWriter.WriteByte((uint8)c.TextIndex);
                dataWriter.WriteByte((uint8)c.ChestIndex);
                dataWriter.WriteByte((uint8)c.Flags);
                dataWriter.WriteWord((uint16)c.KeyIndex);
                dataWriter.WriteWord((uint16)c.UnlockFailedEventIndex);
                break;
            case PopupTextEvent p:
                dataWriter.WriteByte((uint8)p.EventImageIndex);
                dataWriter.WriteByte((uint8)p.PopupTrigger);
                dataWriter.WriteByte(p.TriggerIfBlind ? (uint8)1 : (uint8)0);
                dataWriter.WriteByte(0);
                dataWriter.WriteByte((uint8)p.TextIndex);
                dataWriter.WriteBytes(p.Unknown);
                break;
            case SpinnerEvent s:
                dataWriter.WriteByte((uint8)s.Direction);
                dataWriter.WriteBytes(s.Unused);
                break;
            case TrapEvent t:
                dataWriter.WriteByte((uint8)t.Ailment);
                dataWriter.WriteByte((uint8)t.Target);
                dataWriter.WriteByte((uint8)t.AffectedGenders);
                dataWriter.WriteByte(t.BaseDamage);
                dataWriter.WriteBytes(t.Unused);
                break;
            case ChangeBuffsEvent b:
                dataWriter.WriteByte(b.AffectedBuff is ActiveSpellType buff ? (uint8)(1 + (int)buff) : (uint8)0);
                dataWriter.WriteByte(b.Add ? (uint8)1 : (uint8)0);
                dataWriter.WriteByte(b.Unused1);
                dataWriter.WriteWord(b.Value);
                dataWriter.WriteWord(b.Duration);
                dataWriter.WriteBytes(b.Unused2);
                break;
            case RiddlemouthEvent r:
                dataWriter.WriteByte((uint8)r.RiddleTextIndex);
                dataWriter.WriteByte((uint8)r.SolutionTextIndex);
                dataWriter.WriteBytes(r.Unused);
                dataWriter.WriteWord((uint16)r.CorrectAnswerDictionaryIndex1);
                dataWriter.WriteWord((uint16)r.CorrectAnswerDictionaryIndex2);
                break;
            case RewardEvent r:
                dataWriter.WriteByte((uint8)r.TypeOfReward);
                dataWriter.WriteByte((uint8)r.Operation);
                dataWriter.WriteByte(r.Random ? (uint8)1 : (uint8)0);
                dataWriter.WriteByte((uint8)r.Target);
                dataWriter.WriteByte(r.Unused);
                dataWriter.WriteWord(r.RewardTypeValue);
                dataWriter.WriteWord((uint16)r.Value);
                break;
            case ChangeTileEvent c:
                dataWriter.WriteByte((uint8)c.X);
                dataWriter.WriteByte((uint8)c.Y);
                dataWriter.WriteBytes(c.Unknown);
                dataWriter.WriteWord((uint16)c.FrontTileIndex);
                dataWriter.WriteWord((uint16)c.MapIndex);
                break;
            case StartBattleEvent s:
                dataWriter.WriteBytes(s.Unknown1);
                dataWriter.WriteByte((uint8)s.MonsterGroupIndex);
                dataWriter.WriteBytes(s.Unknown2);
                break;
            case EnterPlaceEvent p:
                dataWriter.WriteByte(p.ClosedTextIndex);
                dataWriter.WriteByte((uint8)p.PlaceType);
                dataWriter.WriteByte(p.OpeningHour);
                dataWriter.WriteByte(p.ClosingHour);
                dataWriter.WriteByte(p.UsePlaceTextIndex);
                dataWriter.WriteWord((uint16)p.PlaceIndex);
                dataWriter.WriteWord((uint16)p.MerchantDataIndex);
                break;
            case ConditionEvent c:
                dataWriter.WriteByte((uint8)c.TypeOfCondition);
                dataWriter.WriteByte((uint8)c.Value);
                dataWriter.WriteByte((uint8)c.Count);
                dataWriter.WriteWord((uint16)c.DisallowedAilments);
                dataWriter.WriteWord((uint16)c.ObjectIndex);
                dataWriter.WriteWord((uint16)c.ContinueIfFalseWithMapEventIndex);
                break;
            case ActionEvent a:
                dataWriter.WriteByte((uint8)a.TypeOfAction);
                dataWriter.WriteByte((uint8)a.Value);
                dataWriter.WriteByte((uint8)a.Count);
                dataWriter.WriteBytes(a.Unknown1);
                dataWriter.WriteWord((uint16)a.ObjectIndex);
                dataWriter.WriteBytes(a.Unknown2);
                break;
            case Dice100RollEvent d:
                dataWriter.WriteByte((uint8)d.Chance);
                dataWriter.WriteBytes(d.Unused);
                dataWriter.WriteWord((uint16)d.ContinueIfFalseWithMapEventIndex);
                break;
            case ConversationEvent c:
                dataWriter.WriteByte((uint8)c.Interaction);
                dataWriter.WriteBytes(c.Unused1);
                dataWriter.WriteWord(c.Value);
                dataWriter.WriteBytes(c.Unused2);
                break;
            case PrintTextEvent p:
                dataWriter.WriteByte((uint8)p.NPCTextIndex);
                dataWriter.WriteBytes(p.Unused);
                break;
            case CreateEvent c:
                dataWriter.WriteByte((uint8)c.TypeOfCreation);
                dataWriter.WriteBytes(c.Unused);
                dataWriter.WriteWord((uint16)c.Amount);
                dataWriter.WriteWord((uint16)c.ItemIndex);
                break;
            case DecisionEvent d:
                dataWriter.WriteByte((uint8)d.TextIndex);
                dataWriter.WriteBytes(d.Unknown1);
                dataWriter.WriteWord((uint16)d.NoEventIndex);
                break;
            case ChangeMusicEvent m:
                dataWriter.WriteWord((uint16)m.MusicIndex);
                dataWriter.WriteByte(m.Volume);
                dataWriter.WriteBytes(m.Unknown1);
                break;
            case ExitEvent x:
                dataWriter.WriteBytes(x.Unused);
                break;
            case SpawnEvent s:
                dataWriter.WriteByte((uint8)s.X);
                dataWriter.WriteByte((uint8)s.Y);
                dataWriter.WriteByte((uint8)s.TravelType);
                dataWriter.WriteBytes(s.Unknown1);
                dataWriter.WriteWord((uint16)s.MapIndex);
                dataWriter.WriteBytes(s.Unknown2);
                break;
            case InteractEvent i:
                dataWriter.WriteBytes(i.Unused);
                break;
            case RemovePartyMemberEvent r:
                dataWriter.WriteByte(r.CharacterIndex);
                dataWriter.WriteByte(r.ChestIndexEquipment);
                dataWriter.WriteByte(r.ChestIndexInventory);
                dataWriter.WriteBytes(r.Unused);
                break;
            case DelayEvent d:
                dataWriter.WriteBytes(d.Unused1);
                dataWriter.WriteWord((uint16)d.Milliseconds);
                dataWriter.WriteWord(d.Unused2);
                break;
            case PartyMemberConditionEvent c:
                dataWriter.WriteByte((uint8)c.TypeOfCondition);
                dataWriter.WriteByte((uint8)c.ConditionValueIndex);
                dataWriter.WriteByte((uint8)c.Target);
                dataWriter.WriteWord((uint16)c.DisallowedAilments);
                dataWriter.WriteWord((uint16)c.Value);
                dataWriter.WriteWord((uint16)c.ContinueIfFalseWithMapEventIndex);
                break;
            case ShakeEvent s:
                dataWriter.WriteBytes(s.Unused1);
                dataWriter.WriteWord((uint16)s.Shakes);
                dataWriter.WriteWord(s.Unused2);
                break;
            case ShowMapEvent s:
                dataWriter.WriteByte((uint8)s.Options);
                dataWriter.WriteBytes(s.Unused);
                break;
            case ToggleSwitchEvent t:
                dataWriter.WriteBytes(t.GlobalVariableBytes);
                dataWriter.WriteWord((uint16)t.FrontTileIndexOff);
                dataWriter.WriteWord((uint16)t.FrontTileIndexOn);
                break;
            case DynamicChangeTileEvent d:
            {
                var frontTileIndexWord = (uint16)((d.FrontTileIndexOff << 4) | ((d.FrontTileIndexOn >> 8) & 0xf));
                var frontTileIndexByte = (uint8)(d.FrontTileIndexOn & 0xff);
                dataWriter.WriteByte((uint8)d.X);
                dataWriter.WriteByte((uint8)d.Y);
                dataWriter.WriteWord((uint16)d.GlobalVariable);
                dataWriter.WriteWord(frontTileIndexWord);
                dataWriter.WriteByte(frontTileIndexByte);
                dataWriter.WriteWord((uint16)d.MapIndex);
                break;
            }
            case RectangularExplorationEvent r:
                dataWriter.WriteByte((uint8)r.X);
                dataWriter.WriteByte((uint8)r.Y);
                dataWriter.WriteByte((uint8)r.Width);
                dataWriter.WriteByte((uint8)r.Height);
                dataWriter.WriteByte((uint8)r.Exploration);
                dataWriter.WriteWord((uint16)r.MapIndex);
                dataWriter.WriteWord(r.Unused);
                break;
            case VerticalLineRevealEvent v:
                dataWriter.WriteByte((uint8)v.X1);
                dataWriter.WriteByte((uint8)v.Y1);
                dataWriter.WriteByte((uint8)v.Height1);
                dataWriter.WriteByte((uint8)v.X2);
                dataWriter.WriteByte((uint8)v.Y2);
                dataWriter.WriteByte((uint8)v.Height2);
                dataWriter.WriteByte((uint8)v.X3);
                dataWriter.WriteByte((uint8)v.Y3);
                dataWriter.WriteByte((uint8)v.Height3);
                break;
            case DebugEvent d:
                dataWriter.WriteBytes(d.Data);
                break;
        }
    }
}
