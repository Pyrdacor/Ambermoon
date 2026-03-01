using System.Text;
using Ambermoon;
using Ambermoon.Data;

namespace AmbermoonScript;

/*public class ScriptSerializer
{
    private const uint LockpickItemIndex = 138;

    private static string DeserializeEvent(Event @event, Dictionary<uint, string> labelsByEventIndex)
    {
        static string Opt<T>(string name, T value, Func<T, bool> omit, Func<T, string>? valueConverter = null)
            where T: notnull
        {
            if (omit(value))
                return "";

            return $", {name} = {valueConverter?.Invoke(value) ?? value.ToString()}";
        }

        string Branch(Event @event, string condition, bool inverseLogic)
        {
            var builder = new StringBuilder();
            var branchEventIndex = (@event as IBranchEvent)?.AlternativeBranchEventIndex;
            bool hasBranch = branchEventIndex != null && branchEventIndex != 0xffff;

            string EnsureBranchLabel()
            {
                if (!labelsByEventIndex.TryGetValue(branchEventIndex!.Value, out var branchLabel))
                {
                    branchLabel = $".local{labelsByEventIndex.Count}";
                    labelsByEventIndex[branchEventIndex!.Value] = branchLabel;
                }

                return branchLabel;
            }

            if (@event.Next == null)
            {
                if (!hasBranch)
                    return "End()";

                builder.AppendLine($"if {condition}");
                builder.AppendLine($"! {EnsureBranchLabel()}");
                builder.AppendLine("End()");
            }
            else
            {
                builder.AppendLine($"if {condition}");

                if (hasBranch)
                    builder.AppendLine($"! {EnsureBranchLabel()}");
            }

            return builder.ToString();
        }

        return @event switch
        {
            TeleportEvent teleport => teleport.Transition switch
            {
                TeleportEvent.TransitionType.MapChange => $"MapChange(mapIndex = {teleport.MapIndex}, x = {teleport.X}, y = {teleport.Y}, dir = {teleport.Direction})",
                TeleportEvent.TransitionType.Teleporter => $"Teleport(x = {teleport.X}, y = {teleport.Y}, dir = {teleport.Direction})",
                TeleportEvent.TransitionType.WindGate => $"WindGate(mapIndex = {teleport.MapIndex}, x = {teleport.X}, y = {teleport.Y}, dir = {teleport.Direction})",
                TeleportEvent.TransitionType.Climbing => $"Climb(mapIndex = {teleport.MapIndex}, x = {teleport.X}, y = {teleport.Y}, dir = {teleport.Direction})",
                TeleportEvent.TransitionType.Falling => $"Fall(mapIndex = {teleport.MapIndex}, x = {teleport.X}, y = {teleport.Y}, dir = {teleport.Direction})",
                TeleportEvent.TransitionType.Outro => $"Outro()",
                _ => throw new NotImplementedException()
            },
            DoorEvent door => $"Door(DoorIndex = {door.DoorIndex}, KeyIndex = {(door.KeyIndex != 0 ? door.KeyIndex : LockpickItemIndex)}, Door(LockpickChanceReduction = {door.LockpickingChanceReduction}{Opt("TextIndex", door.TextIndex, i => i == 0xff)}{Opt("UnlockTextIndex", door.TextIndex, i => i == 0xff)}){Branch(door, "TrapTriggered()")}",
            ChestEvent chest => chest.Flags.HasFlag(ChestEvent.ChestFlags.JunkPile)
                ? $"Pile(ChestIndex = {(chest.Flags.HasFlag(ChestEvent.ChestFlags.ExtendedChest) ? 256 + chest.ChestIndex : chest.ChestIndex)}{Opt("SearchSkillCheck", chest.SearchSkillCheck, i => i)}{Opt("SaveChest", chest.Flags, i => !i.HasFlag(ChestEvent.ChestFlags.NoSave), _ => "false")}{Opt("TextIndex", chest.TextIndex, i => i == 0xff)}){Branch(chest, "TrapTriggered()")}"
                : $"Chest(ChestIndex = {(chest.Flags.HasFlag(ChestEvent.ChestFlags.ExtendedChest) ? 256 + chest.ChestIndex : chest.ChestIndex)}, LockpickChanceReduction = {chest.LockpickingChanceReduction}{Opt("KeyIndex", chest.KeyIndex, i => i != 0)}{Opt("TextIndex", chest.TextIndex, i => i == 0xff)}){Branch(chest, "TrapTriggered()")}",
            SpinnerEvent spinner => $"Spin(dir = {spinner.Direction})",
            PopupTextEvent print => print.EventImageIndex == 0xff
                ? $"Print(TextIndex = {print.TextIndex}, Trigger={print.PopupTrigger}, TriggerIfBlind = {print.TriggerIfBlind})"
                : $"Picture(PictureIndex = {print.EventImageIndex}, TextIndex = {print.TextIndex}, Trigger={print.PopupTrigger}, TriggerIfBlind = {print.TriggerIfBlind})",
            TrapEvent trap => $"Trap(BaseDamage = {trap.BaseDamage}, Target = {trap.Target}, Ailment = {trap.Ailment}, AffectedGenders = {EnumHelper.GetFlagNames(trap.AffectedGenders, 1)})",
            DecisionEvent ask => $"Ask(TextIndex = {ask.TextIndex})"
            _ => "Unsupported", //throw new NotImplementedException()

        "Trap",
        Arg("BaseDamage"),
        Enum<TrapEvent.TrapTarget>("Target"),
        OptEnum("Ailment", TrapEvent.TrapAilment.None),
        OptEnum("AffectedGenders", GenderFlag.Both));
    };
    }

    public static string Deserialize(List<Event> eventChains, List<Event> events)
    {
        var builder = new StringBuilder();

        for (int i = 0; i < eventChains.Count; i++)
        {
            builder.AppendLine($"# Sequence {i}");

            var processedEvents = new List<Event>();
            var ev = eventChains[i];
            var labeledAlternativeBranches = new Queue<(string Label, Event Event)>();
            var labeledAlternativeBranchIndices = new Dictionary<uint, string>();

            ProcessEventChain(ev);

            while (labeledAlternativeBranches.Count != 0)
            {
                var labeledAlternativeBranch = labeledAlternativeBranches.Dequeue();

                builder.AppendLine();
                builder.AppendLine(labeledAlternativeBranch.Label + ":");

                ProcessEventChain(labeledAlternativeBranch.Event);
            }

            void ProcessEventChain(Event ev)
            {
                while (ev != null)
                {
                    processedEvents.Add(ev);
                    builder.AppendLine($"- {DeserializeEvent(ev)}");

                    if (ev is IBranchEvent branchEvent)
                    {
                        if (ev.Next == null && branchEvent.AlternativeBranchEventIndex != 0xffff)
                        {
                            ev = events[(int)branchEvent.AlternativeBranchEventIndex];
                        }
                        else if (ev.Next != null)
                        {
                            ev = ev.Next;

                            if (branchEvent.AlternativeBranchEventIndex != 0xffff)
                            {
                                if (!labeledAlternativeBranchIndices.TryGetValue(branchEvent.AlternativeBranchEventIndex, out var labelName))
                                {
                                    labelName = $".local{labeledAlternativeBranches.Count}";
                                    labeledAlternativeBranchIndices.TryAdd(branchEvent.AlternativeBranchEventIndex, labelName);
                                    labeledAlternativeBranches.Enqueue((labelName, events[(int)branchEvent.AlternativeBranchEventIndex]));

                                }
                                    
                                builder.AppendLine($"! {labelName}");
                            }
                        }
                        else // Both branches end here
                        {
                            builder.AppendLine("End()");
                            break;
                        }
                    }
                }
            }
        }

        return builder.ToString();
    }
}*/
