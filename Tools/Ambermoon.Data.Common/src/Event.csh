namespace Ambermoon.Data;

using System;
using Ambermoon;
using Ambermoon.Data.Enumerations;

/// An event: its kind, its data and the next event of its chain.
struct Event
{
    /// Which event this is (the identity of the object in the original): the id in its [EventStore].
    int Id;
    /// The 1-based index in the event list it was read from.
    uint32 Index;
    EventType Type;
    /// The id of the next event of the chain, -1 if there is none.
    int Next;
    EventData Data;

    /// Whether there is a next event.
    bool HasNext()
    {
        return Next >= 0;
    }

    /// A copy of the data (arrays are copied too), without an id yet ([EventStore.Add] gives it one), with the same
    /// next event if `keepNext`.
    Event Clone(bool keepNext)
    {
        var clone = Event { Id = -1, Index = Index, Type = Type, Next = keepNext ? Next : -1, Data = Data };
        switch (clone.Data)
        {
            case TeleportEvent e:
                e.Unknown2 = _CloneBytes(e.Unknown2);
                clone.Data = e;
                break;
            case PopupTextEvent e:
                e.Unknown = _CloneBytes(e.Unknown);
                clone.Data = e;
                break;
            case SpinnerEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case TrapEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case ChangeBuffsEvent e:
                e.Unused2 = _CloneBytes(e.Unused2);
                clone.Data = e;
                break;
            case RiddlemouthEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case ChangeTileEvent e:
                e.Unknown = _CloneBytes(e.Unknown);
                clone.Data = e;
                break;
            case StartBattleEvent e:
                e.Unknown1 = _CloneBytes(e.Unknown1);
                e.Unknown2 = _CloneBytes(e.Unknown2);
                clone.Data = e;
                break;
            case ActionEvent e:
                e.Unknown1 = _CloneBytes(e.Unknown1);
                e.Unknown2 = _CloneBytes(e.Unknown2);
                clone.Data = e;
                break;
            case Dice100RollEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case ConversationEvent e:
                e.Unused1 = _CloneBytes(e.Unused1);
                e.Unused2 = _CloneBytes(e.Unused2);
                clone.Data = e;
                break;
            case PrintTextEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case CreateEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case DecisionEvent e:
                e.Unknown1 = _CloneBytes(e.Unknown1);
                clone.Data = e;
                break;
            case ChangeMusicEvent e:
                e.Unknown1 = _CloneBytes(e.Unknown1);
                clone.Data = e;
                break;
            case ExitEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case SpawnEvent e:
                e.Unknown1 = _CloneBytes(e.Unknown1);
                e.Unknown2 = _CloneBytes(e.Unknown2);
                clone.Data = e;
                break;
            case InteractEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case RemovePartyMemberEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case DelayEvent e:
                e.Unused1 = _CloneBytes(e.Unused1);
                clone.Data = e;
                break;
            case ShakeEvent e:
                e.Unused1 = _CloneBytes(e.Unused1);
                clone.Data = e;
                break;
            case ShowMapEvent e:
                e.Unused = _CloneBytes(e.Unused);
                clone.Data = e;
                break;
            case ToggleSwitchEvent e:
                e.GlobalVariableBytes = _CloneBytes(e.GlobalVariableBytes);
                clone.Data = e;
                break;
            case DebugEvent e:
                e.Data = _CloneBytes(e.Data);
                clone.Data = e;
                break;
            default:
                break;
        }
        return clone;
    }

    static uint8[] _CloneBytes(uint8[] bytes)
    {
        return bytes == null ? null : bytes.Clone();
    }

    /// Whether the event can branch (IBranchEvent of the original: doors, chests, conditions, party member
    /// conditions, dice rolls and decisions).
    bool IsBranchEvent()
    {
        switch (Data)
        {
            case DoorEvent d:
            case ChestEvent c:
            case ConditionEvent ce:
            case PartyMemberConditionEvent p:
            case Dice100RollEvent r:
            case DecisionEvent de:
                return true;
            default:
                return false;
        }
    }

    /// The event index of the other branch (0xffff: none); 0xffff for events that do not branch.
    uint32 AlternativeBranchEventIndex()
    {
        switch (Data)
        {
            case DoorEvent d:
                return d.UnlockFailedEventIndex;
            case ChestEvent c:
                return c.UnlockFailedEventIndex;
            case ConditionEvent ce:
                return ce.ContinueIfFalseWithMapEventIndex;
            case PartyMemberConditionEvent p:
                return p.ContinueIfFalseWithMapEventIndex;
            case Dice100RollEvent r:
                return r.ContinueIfFalseWithMapEventIndex;
            case DecisionEvent de:
                return de.NoEventIndex;
            default:
                return 0xffff;
        }
    }

    /// Sets the event index of the other branch (nothing for events that do not branch).
    void SetAlternativeBranchEventIndex(uint32 index)
    {
        switch (Data)
        {
            case DoorEvent d:
                d.UnlockFailedEventIndex = index;
                Data = d;
                break;
            case ChestEvent c:
                c.UnlockFailedEventIndex = index;
                Data = c;
                break;
            case ConditionEvent ce:
                ce.ContinueIfFalseWithMapEventIndex = index;
                Data = ce;
                break;
            case PartyMemberConditionEvent p:
                p.ContinueIfFalseWithMapEventIndex = index;
                Data = p;
                break;
            case Dice100RollEvent r:
                r.ContinueIfFalseWithMapEventIndex = index;
                Data = r;
                break;
            case DecisionEvent de:
                de.NoEventIndex = index;
                Data = de;
                break;
            default:
                break;
        }
    }

    /// The text of the original's Event.ToString().
    string ToString()
    {
        switch (Data)
        {
            case TeleportEvent e:
            {
                string position = e.X == 0 || e.Y == 0 ? "same" : $"{e.X},{e.Y}";
                string travelType = e.NewTravelType is TravelType t ? t.ToString() : "None";
                return $"{Type}: Map {e.MapIndex} / Position {position} / Direction {e.Direction}, Transition {e.Transition}, New Travel Type {travelType}, Unknown3 {HexBytes(e.Unknown2)}";
            }
            case DoorEvent e:
            {
                string lockType = _LockType(e.LockpickingChanceReduction);
                return $"{Type}: Key={(e.KeyIndex == 0 ? "None" : e.KeyIndex.ToString())}, Lock=[{lockType}], Event index if unlock failed {e.UnlockFailedEventIndex:x4}, Text {(e.TextIndex == 0xff ? "none" : e.TextIndex.ToString())}, UnlockText {(e.UnlockTextIndex == 0xff ? "none" : e.UnlockTextIndex.ToString())}, Door Index {e.DoorIndex}";
            }
            case ChestEvent e:
            {
                string lockType = _LockType(e.LockpickingChanceReduction);
                string chestType = (e.Flags & ChestFlags.Treasure) != ChestFlags.None ? "Treasure" : "Chest";
                string flags = "";
                if ((e.Flags & ChestFlags.NoSave) != ChestFlags.None)
                    flags = "NoSave";
                if (e.SearchSkillCheck())
                    flags += flags.Length == 0 ? "SearchCheck" : ",SearchCheck";
                string flagString = flags.Length == 0 ? "" : "Flags=" + flags + ", ";
                return $"{Type}: {chestType} {e.RealChestIndex()}, Lock=[{lockType}], {flagString}Key={(e.KeyIndex == 0 ? "None" : e.KeyIndex.ToString())}, Event index if unlock failed {e.UnlockFailedEventIndex:x4}, Text {(e.TextIndex == 0xff ? "none" : e.TextIndex.ToString())}";
            }
            case PopupTextEvent e:
                return $"{Type}: Text {e.TextIndex}, Image {(e.EventImageIndex == 0xff ? "None" : e.EventImageIndex.ToString())}, Trigger {EnumText(e.PopupTrigger, true)}, {(e.TriggerIfBlind ? "" : "Not ")}Trigger If Blind, Unknown {HexBytes(e.Unknown)}";
            case SpinnerEvent e:
                return $"{Type}: Direction {e.Direction}";
            case TrapEvent e:
                return $"{Type}: {e.BaseDamage} damage with ailment {e.Ailment} on {e.Target}, Affected genders {EnumText(e.AffectedGenders, true)}";
            case ChangeBuffsEvent e:
            {
                string operation = e.Add ? "AddBuff" : "RemoveBuff";
                string values = e.Add ? $" , Value {e.Value}, Duration {e.Duration * 5} minutes" : "";
                string buff = e.AffectedBuff is ActiveSpellType b ? b.ToString() : "all";
                return $"{operation}: Affected buff {buff}{values}";
            }
            case RiddlemouthEvent e:
            {
                string answerIndices = e.CorrectAnswerDictionaryIndex1 == e.CorrectAnswerDictionaryIndex2
                    ? $"AnswerIndex {e.CorrectAnswerDictionaryIndex1}"
                    : $"AnswerIndices {e.CorrectAnswerDictionaryIndex1} or {e.CorrectAnswerDictionaryIndex2}";
                return $"{Type}: RiddleText {e.RiddleTextIndex}, SolvedText {e.SolutionTextIndex}, {answerIndices}";
            }
            case RewardEvent e:
                return _RewardText(e);
            case ChangeTileEvent e:
                return $"{Type}: Map {(e.MapIndex == 0 ? "Self" : e.MapIndex.ToString())}, X {e.X}, Y {e.Y}, Front tile / Wall / Object {e.FrontTileIndex}, Unknown {(e.Unknown == null ? "null" : HexBytes(e.Unknown))}";
            case StartBattleEvent e:
                return $"{Type}: Monster group {e.MonsterGroupIndex}, Unknown1 {HexBytes(e.Unknown1)}, Unknown2 {HexBytes(e.Unknown2)}";
            case EnterPlaceEvent e:
            {
                string index = e.PlaceType == PlaceType.Merchant ? $"Merchant index {e.MerchantDataIndex}"
                    : e.PlaceType == PlaceType.Library ? $"Libary merchant index {e.MerchantDataIndex}" : $"Place index {e.PlaceIndex}";
                return $"{e.PlaceType}: {index}, Open {e.OpeningHour:D2}-{e.ClosingHour:D2}, TextIndexWhenClosed {e.ClosedTextIndex}, UseTextIndex {e.UsePlaceTextIndex}";
            }
            case ConditionEvent e:
                return _ConditionText(e);
            case PartyMemberConditionEvent e:
                return _PartyMemberConditionText(e);
            case ActionEvent e:
                return _ActionText(e);
            case Dice100RollEvent e:
                return $"{Type}: Chance {e.Chance}%, {_FalseHandling(e.ContinueIfFalseWithMapEventIndex)}, Unused {HexBytes(e.Unused)}";
            case ConversationEvent e:
            {
                string argument = "";
                if (e.Interaction == InteractionType.Keyword)
                    argument = $", KeywordIndex {e.Value}";
                else if (e.Interaction == InteractionType.ShowItem || e.Interaction == InteractionType.GiveItem)
                    argument = $", Item {e.Value}";
                return $"{Type}: On interaction {e.Interaction}" + argument;
            }
            case PrintTextEvent e:
                return $"{Type}: NPCTextIndex {e.NPCTextIndex}";
            case CreateEvent e:
            {
                switch (e.TypeOfCreation)
                {
                    case CreateType.Item:
                        return $"{Type}: {e.Amount}x Item {e.ItemIndex}";
                    case CreateType.Gold:
                        return $"{Type}: {e.Amount} Gold";
                    default:
                        return $"{Type}: {e.Amount} Food";
                }
            }
            case DecisionEvent e:
                return $"{Type}: Text {e.TextIndex}, Event index when selecting 'No' {(e.NoEventIndex == 0xffff ? "None" : (e.NoEventIndex + 1).ToString("x4"))}, Unknown1 {HexBytes(e.Unknown1)}";
            case ChangeMusicEvent e:
                return $"{Type}: Music {(e.MusicIndex == 255 ? "<Map music>" : e.MusicIndex.ToString())}, Volume {FormatFloat((float)e.Volume / 255.0f, 1)}, Unknown1 {HexBytes(e.Unknown1)}";
            case ExitEvent e:
                return $"{Type}";
            case SpawnEvent e:
                return $"{Type} {e.TravelType} on map {e.MapIndex} at {e.X}, {e.Y}";
            case InteractEvent e:
                return $"{Type}";
            case RemovePartyMemberEvent e:
                return $"{Type} {e.CharacterIndex} (Equip -> Chest {e.ChestIndexEquipment}, Items -> Chest {e.ChestIndexInventory})";
            case DelayEvent e:
                return $"{Type} {e.Milliseconds} ms";
            case ShakeEvent e:
                return $"{Type} {e.Shakes} shakes";
            case ShowMapEvent e:
                return $"{Type} Option={EnumText(e.Options, true)}";
            case ToggleSwitchEvent e:
            {
                var copy = e;
                string globalVars = "";
                foreach (var v in copy.GlobalVariables())
                {
                    if (v == 0)
                        continue;
                    if (globalVars.Length != 0)
                        globalVars += ",";
                    globalVars += v.ToString();
                }
                return $"{Type} OffTile={e.FrontTileIndexOff}, OnTile={e.FrontTileIndexOn}, GlobVars={globalVars}";
            }
            case DynamicChangeTileEvent e:
                return $"{Type}: Map {(e.MapIndex == 0 ? "Self" : e.MapIndex.ToString())}, X {e.X}, Y {e.Y}, Front tile / Wall / Object {e.FrontTileIndexOff}/{e.FrontTileIndexOn}";
            case RectangularExplorationEvent e:
                return $"{Type}: Map {(e.MapIndex == 0 ? "Self" : e.MapIndex.ToString())}, {e.Exploration} ({e.X},{e.Y}):({e.Width}x{e.Height})";
            case VerticalLineRevealEvent e:
                return $"{Type}: ({e.X1},{e.Y1}:{e.Height1}), ({e.X2},{e.Y2}:{e.Height2}), ({e.X3},{e.Y3}:{e.Height3})";
            case DebugEvent e:
            {
                string text = Type.ToString() + ": ";
                if (e.Data != null)
                {
                    for (var i = 0; i < e.Data.Length; i += 1)
                        text += (i == 0 ? "" : " ") + e.Data[i].ToString("X2");
                }
                return text;
            }
            default:
                return "Ambermoon.Data.Event";
        }
    }

    static string _LockType(uint32 lockpickingChanceReduction)
    {
        if (lockpickingChanceReduction == 0)
            return "Open";
        if (lockpickingChanceReduction >= 100)
            return "No Lockpicking";
        return $"-{lockpickingChanceReduction}% Chance";
    }

    static string _FalseHandling(uint32 continueIfFalseWithMapEventIndex)
    {
        return continueIfFalseWithMapEventIndex == 0xffff
            ? "Stop here if false"
            : $"Jump to event {continueIfFalseWithMapEventIndex:x2} if false";
    }

    string _RewardText(RewardEvent e)
    {
        string operationString;
        switch (e.Operation)
        {
            case RewardOperation.Increase:
                operationString = e.Random ? $"+rand(0~{e.Value})" : $"+{e.Value}";
                break;
            case RewardOperation.Fill:
                operationString = "max";
                break;
            case RewardOperation.IncreasePercentage:
                operationString = e.Random ? $"+rand(0%~{e.Value}%)" : $"+{e.Value}%";
                break;
            case RewardOperation.DecreasePercentage:
                operationString = e.Random ? $"-rand(0%~{e.Value}%)" : $"-{e.Value}%";
                break;
            case RewardOperation.Remove:
                operationString = "Remove";
                break;
            case RewardOperation.Add:
                operationString = "Add";
                break;
            case RewardOperation.Toggle:
                operationString = "Toggle";
                break;
            default:
                operationString = $"?op={(int)e.Operation}?";
                break;
        }

        string target;
        if (e.Target >= RewardTarget.AllButFirstPartyMember)
            target = $"All but PartyMember with index {1 + (int)e.Target - (int)RewardTarget.AllButFirstPartyMember}";
        else if (e.Target >= RewardTarget.FirstPartyMember)
            target = $"PartyMember with index {1 + (int)e.Target - (int)RewardTarget.FirstPartyMember}";
        else
            target = e.Target.ToString();

        string attribute = e.GetAttribute() is Attribute a ? a.ToString() : "";
        string skill = e.GetSkill() is Skill s ? s.ToString() : "";

        switch (e.TypeOfReward)
        {
            case RewardType.Attribute:
                return $"{Type}: {attribute} on {target} {operationString}";
            case RewardType.Skill:
                return $"{Type}: {skill} on {target} {operationString}";
            case RewardType.HitPoints:
                return $"{Type}: HP on {target} {operationString}";
            case RewardType.SpellPoints:
                return $"{Type}: SP on {target} {operationString}";
            case RewardType.SpellLearningPoints:
                return $"{Type}: SLP on {target} {operationString}";
            case RewardType.Conditions:
            {
                string conditions = e.GetConditions() is Condition c ? EnumText(c, true) : "";
                return $"{Type}: {operationString} {conditions} on {target}";
            }
            case RewardType.UsableSpellTypes:
            {
                string spellTypes = e.GetUsableSpellTypes() is SpellTypeMastery m ? EnumText(m, true) : "";
                return $"{Type}: {operationString} {spellTypes} on {target}";
            }
            case RewardType.Languages:
            {
                string languages = "";
                if (e.GetLanguages() is Language l)
                    languages = EnumText(l, true);
                else if (e.GetExtendedLanguages() is ExtendedLanguage x)
                    languages = EnumText(x, true);
                return $"{Type}: {operationString} {languages} on {target}";
            }
            case RewardType.Experience:
                return $"{Type}: Exp on {target} {operationString}";
            case RewardType.MaxAttribute:
                return $"{Type}: Max {attribute} on {target} {operationString}";
            case RewardType.AttacksPerRound:
                return $"{Type}: APR on {e.Target} {operationString}";
            case RewardType.TrainingPoints:
                return $"{Type}: TP on {target} {operationString}";
            case RewardType.Level:
                return $"{Type}: Level on {target} {operationString}";
            case RewardType.Damage:
                return $"{Type}: Damage on {target} {operationString}";
            case RewardType.Defense:
                return $"{Type}: Defense on {target} {operationString}";
            case RewardType.MaxHitPoints:
                return $"{Type}: Max HP on {target} {operationString}";
            case RewardType.MaxSpellPoints:
                return $"{Type}: Max SP on {target} {operationString}";
            case RewardType.EmpowerSpells:
            {
                string empower = "Invalid";
                if (e.Value <= 2)
                {
                    string element = e.Value == 0 ? "earth" : e.Value == 1 ? "wind" : "fire";
                    empower = $"Grants empowered {element} spells for {target}";
                }
                return $"{Type}: {empower}";
            }
            case RewardType.ChangePortrait:
                return $"{Type}: Change portrait to {e.Value} for {target}";
            case RewardType.MaxSkill:
                return $"{Type}: Max {skill} on {target} {operationString}";
            case RewardType.MagicArmorLevel:
                return $"{Type}: M-B-A on {target} {operationString}";
            case RewardType.MagicWeaponLevel:
                return $"{Type}: M-B-W on {target} {operationString}";
            case RewardType.Spells:
                return $"{Type}: {operationString} spell {e.RewardTypeValue} on {target}";
            default:
                return $"{Type}: Unknown ({(int)e.TypeOfReward}:{e.RewardTypeValue}) on {target} {operationString}";
        }
    }

    string _ConditionText(ConditionEvent e)
    {
        string falseHandling = _FalseHandling(e.ContinueIfFalseWithMapEventIndex);
        uint32 o = e.ObjectIndex;
        bool zero = e.Value == 0;

        switch (e.TypeOfCondition)
        {
            case ConditionType.GlobalVariable:
                return $"{Type}: Global variable {o} = {e.Value}, {falseHandling}";
            case ConditionType.EventBit:
                return $"{Type}: Event bit {o / 64 + 1}:{1 + o % 64} = {e.Value}, {falseHandling}";
            case ConditionType.DoorOpen:
                return $"{Type}: Door {o} {(zero ? "closed" : "open")}, {falseHandling}";
            case ConditionType.ChestOpen:
                return $"{Type}: Chest {o} {(zero ? "closed" : "open")}, {falseHandling}";
            case ConditionType.CharacterBit:
                return $"{Type}: Character bit {o / 32 + 1}:{1 + o % 32} = {e.Value}, {falseHandling}";
            case ConditionType.PartyMember:
                return $"{Type}: Has party member {o} without ailments {GetFlagNames(e.DisallowedAilments)}, {falseHandling}";
            case ConditionType.ItemOwned:
            {
                string own = zero ? "Not own item" : $"Own item {(e.Count > 1 ? e.Count : 1)}x";
                return $"{Type}: {own} {o}, {falseHandling}";
            }
            case ConditionType.UseItem:
                return $"{Type}: Use item {o}, {falseHandling}";
            case ConditionType.KnowsKeyword:
                return $"{Type}: {(zero ? "Not know" : "Know")} keyword {o}, {falseHandling}";
            case ConditionType.LastEventResult:
                return $"{Type}: Success of last event, {falseHandling}";
            case ConditionType.GameOptionSet:
                return $"{Type}: Game option {(Option)(uint16)(1 << (int)(o & 31))} is {(zero ? "not set" : "set")}, {falseHandling}";
            case ConditionType.CanSee:
                return $"{Type}: {(zero ? "Can't see" : "Can see")}, {falseHandling}";
            case ConditionType.HasCondition:
                return $"{Type}: {(zero ? "Has not" : "Has")} condition {EnumText((Condition)(uint16)(1 << (int)(o & 31)), true)}, {falseHandling}";
            case ConditionType.Hand:
                return $"{Type}: Hand cursor {(zero ? "not " : "")}used, {falseHandling}";
            case ConditionType.SayWord:
                return $"{Type}: Say keyword {o}, {falseHandling}";
            case ConditionType.EnterNumber:
                return $"{Type}: Enter number {o}, {falseHandling}";
            case ConditionType.Levitating:
                return $"{Type}: Levitating, {falseHandling}";
            case ConditionType.HasGold:
                return $"{Type}: Gold {(zero ? "<" : ">=")} {o}, {falseHandling}";
            case ConditionType.HasFood:
                return $"{Type}: Food {(zero ? "<" : ">=")} {o}, {falseHandling}";
            case ConditionType.Eye:
                return $"{Type}: Eye cursor {(zero ? " not " : "")}used, {falseHandling}";
            case ConditionType.Mouth:
                return $"{Type}: Mouth cursor {(zero ? " not " : "")}used, {falseHandling}";
            case ConditionType.TransportAtLocation:
                return $"{Type}: Transport {(zero ? "not " : "")}at event location , {falseHandling}";
            case ConditionType.MultiCursor:
            {
                string cursors = "";
                if ((o & 0x1) != 0)
                    cursors += "Hand";
                if ((o & 0x2) != 0)
                    cursors += "Eye";
                if ((o & 0x4) != 0)
                    cursors += "Mouth";
                if (cursors.Length == 0)
                    cursors = "None";
                return $"{Type}: Any cursor of {cursors} {(zero ? "not " : "")}used, {falseHandling}";
            }
            case ConditionType.TravelType:
            {
                string name = EnumName((TravelType)(uint8)o) is string n ? n : "";
                return $"{Type}: Travel type {(zero ? "not " : "")}{name}, {falseHandling}";
            }
            case ConditionType.LeadClass:
            {
                string name = EnumName((Class)(uint8)o) is string n ? n : "";
                return $"{Type}: Active party member has {(zero ? "not " : "")}class {name}, {falseHandling}";
            }
            case ConditionType.SpellEmpowered:
            {
                uint32 element = o > 2 ? 2 : o;
                string elementName = EnumText((CharacterElement)(uint8)(1 << (4 + (int)element)), true).ToLower();
                return $"{Type}: Active party member has {(zero ? "not " : "")}{elementName} spells empowered, {falseHandling}";
            }
            case ConditionType.IsNight:
                return $"{Type}: Is {(zero ? "not " : "")}night, {falseHandling}";
            case ConditionType.Attribute:
                return $"{Type}: Active player {(Attribute)(uint8)o} {(zero ? "<" : ">=")} {e.Count}, {falseHandling}";
            case ConditionType.Skill:
                return $"{Type}: Active player {(Skill)(uint8)o} {(zero ? "<" : ">=")} {e.Count}, {falseHandling}";
            case ConditionType.HourTime:
                return $"{Type}: Minute of hour {(zero ? "<>" : "==")} {o}, {falseHandling}";
            default:
                return $"{Type}: Unknown ({e.TypeOfCondition}), Index {o}, Value {e.Value}, {falseHandling}";
        }
    }

    string _PartyMemberConditionText(PartyMemberConditionEvent e)
    {
        string target;
        switch (e.Target)
        {
            case PartyMemberConditionTarget.ActivePlayer:
                target = "Active player";
                break;
            case PartyMemberConditionTarget.All:
                target = "All players";
                break;
            case PartyMemberConditionTarget.Any:
                target = "Any player";
                break;
            case PartyMemberConditionTarget.Min:
                target = "Min";
                break;
            case PartyMemberConditionTarget.Max:
                target = "Max";
                break;
            case PartyMemberConditionTarget.Average:
                target = "Average";
                break;
            case PartyMemberConditionTarget.Random:
                target = "Random player";
                break;
            case PartyMemberConditionTarget.ActiveInventory:
                target = "Active inventory";
                break;
            default:
                target = $"Char {1 + (int)e.Target - (int)PartyMemberConditionTarget.FirstCharacter}";
                break;
        }
        string falseHandling = _FalseHandling(e.ContinueIfFalseWithMapEventIndex);
        string disallowedAilments = e.DisallowedAilments == Condition.None ? "" : $" (not {GetFlagNames(e.DisallowedAilments)})";

        switch (e.TypeOfCondition)
        {
            case PartyMemberConditionType.Level:
                return $"{Type}: {target} Level >= {e.Value}{disallowedAilments}, {falseHandling}";
            case PartyMemberConditionType.Attribute:
                return $"{Type}: {target} {(Attribute)(uint8)e.ConditionValueIndex} >= {e.Value}{disallowedAilments}, {falseHandling}";
            case PartyMemberConditionType.Skill:
                return $"{Type}: {target} {(Skill)(uint8)e.ConditionValueIndex} >= {e.Value}{disallowedAilments}, {falseHandling}";
            case PartyMemberConditionType.TrainingPoints:
                return $"{Type}: {target} TP >= {e.Value}{disallowedAilments}, {falseHandling}";
            case PartyMemberConditionType.Language:
            {
                // (the original casts the index itself to the flags)
                string language = e.ConditionValueIndex < 8 ? EnumText((Language)(uint8)e.ConditionValueIndex, true)
                                                             : EnumText((ExtendedLanguage)(uint8)e.ConditionValueIndex, true);
                return $"{Type}: {target} has language {language} {disallowedAilments}, {falseHandling}";
            }
            default:
                return $"{Type}: Unknown ({e.TypeOfCondition}), Target {target}, Value {e.Value}, {falseHandling}";
        }
    }

    string _ActionText(ActionEvent e)
    {
        string unknown = $", Unknown1 {HexBytes(e.Unknown1)}, Unknown2 {HexBytes(e.Unknown2)}";
        uint32 o = e.ObjectIndex;
        bool zero = e.Value == 0;

        switch (e.TypeOfAction)
        {
            case ActionType.SetGlobalVariable:
                return $"{Type}: Set global variable {o} to {e.Value}" + unknown;
            case ActionType.SetEventBit:
                return $"{Type}: Set event bit {o / 64 + 1}:{1 + o % 64} to {(e.Value != 0 ? "inactive" : "active")}" + unknown;
            case ActionType.LockDoor:
                return $"{Type}: {(zero ? "Lock" : "Unlock")} door {o}" + unknown;
            case ActionType.LockChest:
                return $"{Type}: {(zero ? "Lock" : "Unlock")} chest {o}" + unknown;
            case ActionType.SetCharacterBit:
                return $"{Type}: Set character bit {o / 32 + 1}:{1 + o % 32} to {(e.Value != 0 ? "hidden" : "show")}" + unknown;
            case ActionType.AddItem:
                return $"{Type}: {(zero ? "Remove" : "Add")} {(e.Count > 1 ? e.Count : 1)}x item {o}" + unknown;
            case ActionType.AddKeyword:
                return $"{Type}: {(zero ? "Remove" : "Add")} keyword {o}" + unknown;
            case ActionType.SetGameOption:
                return $"{Type}: {(zero ? "Deactivate" : "Activate")} game option {(Option)(uint16)(1 << (int)(o & 31))}" + unknown;
            case ActionType.AddCondition:
                return $"{Type}: {(zero ? "Remove" : "Add")} condition {EnumText((Condition)(uint16)(1 << (int)(o & 31)), true)}" + unknown;
            case ActionType.AddGold:
                return $"{Type}: {(zero ? "Remove" : "Add")} {(o > 1 ? o : 1)} gold" + unknown;
            case ActionType.AddFood:
                return $"{Type}: {(zero ? "Remove" : "Add")} {(o > 1 ? o : 1)} food" + unknown;
            default:
                return $"{Type}: Unknown ({e.TypeOfAction}), Index {o}, Value {e.Value}" + unknown;
        }
    }
}

/// The bytes as lower case hex numbers, separated by spaces ("00 ff").
string HexBytes(uint8[] bytes)
{
    if (bytes == null)
        return "";
    var text = StringBuilder.Create();
    for (var i = 0; i < bytes.Length; i += 1)
    {
        if (i != 0)
            text.Append(' ');
        text.Append(bytes[i].ToString("x2"));
    }
    return text.ToString();
}
