using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy.Serialization;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using File = System.IO.File;
using Console = System.Console;
using Ambermoon.Data.Enumerations;

namespace AmbermoonEventEditor
{
    class Program
    {
        static bool unsavedChanges = false;

        static void Usage(string error = null)
        {
            if (error != null)
                Error(error);

            Console.WriteLine();
            Console.WriteLine("Usage: AmbermoonEventEditor <path> <type>");
            Console.WriteLine();
            Console.WriteLine(" <path>  Path to an extracted single map_data/NPC_char/party_char");
            Console.WriteLine("         file (= sub-file of an .amb container)");
            Console.WriteLine(" <type>  0: Map, 1: NPC, 2: Party member");
            Console.WriteLine();
            Console.WriteLine("Note: This version can not handle loading directly from container");
            Console.WriteLine("      files like 2Map_data.amb etc.");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine();
            Console.WriteLine(" AmbermoonEventEditor \"1Map_data\\extracted\\001\" 0");
            Console.WriteLine(" AmbermoonEventEditor \"Party_char\\extracted\\001\" 1");
            Console.WriteLine(" AmbermoonEventEditor \"NPC_char\\extracted\\001\" 2");
            Console.WriteLine();
        }

        static void Error(string error)
        {
            Console.WriteLine();
            Console.WriteLine(error);
        }

        static void Exit(int exitCode = 0) => System.Environment.Exit(exitCode);

        static void Main(string[] args)
        {
            if (args.Length != 2)
            {
                Usage("Invalid number of arguments");
                Exit(1);
                return;
            }

            if (!File.Exists(args[0]))
            {
                Error("The given file does not exist");
                Exit(1);
                return;
            }

            if (!int.TryParse(args[1], out int type) || type < 0 || type > 2)
            {
                Usage("Invalid file type given");
                Exit(1);
                return;
            }

            var dataReader = new DataReader(File.ReadAllBytes(args[0]));

            if (type == 0) // map
            {
                dataReader.Position = 2; // skip flags
                var mapType = (MapType)dataReader.ReadByte();
                dataReader.Position = 4; // skip music index
                var mapWidth = dataReader.ReadByte();
                var mapHeight = dataReader.ReadByte();
                int eventOffset = 0x014C + mapWidth * mapHeight * (mapType == MapType.Map2D ? 4 : 2);
                dataReader.Position = 0;
                var head = dataReader.ReadBytes(eventOffset);
                var events = new List<Event>();
                var eventList = new List<Event>();
                EventReader.ReadEvents(dataReader, events, eventList);
                var tail = dataReader.ReadToEnd();
                ProcessEvents(eventList, events, head, tail, args[0], true, eventList.Count, mapType);
            }
            else if (type == 1) // NPC
            {
                var head = dataReader.ReadBytes(0x122);
                var events = new List<Event>();
                var eventList = new List<Event>();
                EventReader.ReadEvents(dataReader, events, eventList);
                ProcessEvents(eventList, events, head, null, args[0], false);
            }
            else // party member
            {
                var head = dataReader.ReadBytes(0x1e8);
                var events = new List<Event>();
                var eventList = new List<Event>();
                EventReader.ReadEvents(dataReader, events, eventList);
                ProcessEvents(eventList, events, head, null, args[0], false);
            }
        }

        static void DrawLine()
        {
            Console.WriteLine("+" + new string('-', 78) + "+");
        }

        static void ProcessEvents(List<Event> eventList, List<Event> events, byte[] head, byte[] tail,
            string inputFileName, bool map, int initialMapEventCount = 0, MapType? mapType = null)
        {
            Console.WriteLine();
            Console.WriteLine("Event list");
            Console.WriteLine("+--------+");
            ListEvents(eventList, 1);

            Console.WriteLine();
            Console.WriteLine("For help just enter the command 'help'");
            Console.WriteLine();

            while (true)
            {
                DrawLine();
                Console.Write("Enter command: ");
                string command = Console.ReadLine();
                DrawLine();

                ProcessCommand(command, eventList, events, map, out bool save, out string saveFileName);

                if (save)
                {
                    saveFileName ??= inputFileName;

                    try
                    {
                        var writer = new DataWriter(head);
                        EventWriter.WriteEvents(writer, events, eventList);
                        if (tail != null && tail.Length != 0)
                        {
                            if (map && mapType == MapType.Map3D && eventList.Count != initialMapEventCount)
                            {
                                if (eventList.Count < initialMapEventCount)
                                {
                                    int removeByteCount = initialMapEventCount - eventList.Count;
                                    writer.Write(tail.Take(tail.Length - removeByteCount).ToArray());
                                }
                                else // >
                                {
                                    writer.Write(tail);

                                    for (int i = initialMapEventCount; i < eventList.Count; ++i)
                                    {
                                        switch (eventList[i].Type)
                                        {
                                            case EventType.Chest:
                                                writer.Write((byte)AutomapType.Chest);
                                                break;
                                            case EventType.Door:
                                                writer.Write((byte)AutomapType.Door);
                                                break;
                                            case EventType.EnterPlace:
                                            {
                                                switch ((eventList[i] as EnterPlaceEvent).PlaceType)
                                                {
                                                    case PlaceType.FoodDealer:
                                                    case PlaceType.Library:
                                                    case PlaceType.Merchant:
                                                        writer.Write((byte)AutomapType.Merchant);
                                                        break;
                                                    case PlaceType.Inn:
                                                        writer.Write((byte)AutomapType.Tavern);
                                                        break;
                                                    default:
                                                        writer.Write((byte)AutomapType.DoorOpen);
                                                        break;
                                                }
                                                break;
                                            }
                                            case EventType.Riddlemouth:
                                                writer.Write((byte)AutomapType.Riddlemouth);
                                                break;
                                            case EventType.Spinner:
                                                writer.Write((byte)AutomapType.Spinner);
                                                break;
                                            case EventType.StartBattle:
                                                writer.Write((byte)AutomapType.Monster);
                                                break;
                                            case EventType.Teleport:
                                            {
                                                switch ((eventList[i] as TeleportEvent).Transition)
                                                {
                                                    case TeleportEvent.TransitionType.MapChange:
                                                    case TeleportEvent.TransitionType.Outro:
                                                        writer.Write((byte)AutomapType.Exit);
                                                        break;
                                                    case TeleportEvent.TransitionType.Teleporter:
                                                        writer.Write((byte)AutomapType.Teleporter);
                                                        break;
                                                    case TeleportEvent.TransitionType.Falling:
                                                        writer.Write((byte)AutomapType.Trapdoor);
                                                        break;
                                                    default:
                                                        writer.Write((byte)AutomapType.None);
                                                        break;
                                                }
                                                break;
                                            }
                                            case EventType.Trap:
                                                writer.Write((byte)AutomapType.Trap);
                                                break;
                                            default:
                                                writer.Write((byte)AutomapType.None);
                                                break;
                                        }
                                    }
                                }
                            }
                            else
                                writer.Write(tail);
                        }
                        File.WriteAllBytes(saveFileName, writer.ToArray());
                        Console.WriteLine($"Successfully saved to '{saveFileName}'.");
                    }
                    catch
                    {
                        Console.WriteLine($"Failed to save to '{saveFileName}'.");
                    }

                    Console.WriteLine();
                }
            }
        }

        static void ProcessCommand(string command, List<Event> eventList, List<Event> events,
            bool map, out bool save, out string saveFileName)
        {
            save = false;
            saveFileName = null;
            var args = command.Split(' ', System.StringSplitOptions.RemoveEmptyEntries);

            if (args.Length == 0)
            {
                ShowHelp();
                return;
            }

            command = args[0].ToLower();

            switch (command)
            {
                case "exit":
                    Exit();
                    break;
                case "list":
                    ListEvents(eventList, 1);
                    break;
                case "short":
                    ListEventsShort(eventList);
                    break;
                case "events":
                    ListEvents(events);
                    break;
                case "summary":
                    ListEventsShort(events);
                    break;
                case "chain":
                    if (args.Length < 2)
                    {
                        Console.WriteLine();
                        Console.WriteLine("No event list index given");
                        Console.WriteLine();
                    }
                    else if (!int.TryParse(args[1], NumberStyles.AllowHexSpecifier, null, out int index))
                    {
                        Console.WriteLine();
                        Console.WriteLine("No valid event list index given");
                        Console.WriteLine();
                    }
                    else
                    {
                        ShowChain(eventList, events, index - 1);
                    }
                    break;
                case "add":
                    AddEvent(eventList, events, map);
                    break;
                case "edit":
                    EditEvent(eventList, events, map);
                    break;
                case "remove":
                    RemoveEvent(eventList, events);
                    break;
                case "connect":
                    ConnectEvent(eventList, events);
                    break;
                case "disconnect":
                    DisconnectEvent(eventList, events);
                    break;
                case "connections":
                    ShowConnections(eventList, events);
                    break;
                case "reorder":
                    ReorderEvents(eventList, events);
                    break;
                case "save":
                    Save(out save, out saveFileName);
                    break;
                case "help":
                    ShowHelp(args.Length == 1 ? "" : args[1].ToLower());
                    break;
                case "usage":
                    Usage();
                    break;
                default:
                    ShowHelp();
                    break;
            }
        }

        static int? ReadInt(bool hex = false)
        {
            if (hex)
                return int.TryParse(Console.ReadLine(), NumberStyles.AllowHexSpecifier, null, out int hexValue) ? hexValue : (int?)null;

            return int.TryParse(Console.ReadLine(), out int value) ? value : (int?)null;
        }

        static int? ReadOption(int? defaultOption, params string[] options)
        {
            for (int i = 0; i < options.Length; ++i)
                Console.WriteLine($"{i}: {options[i]}");

            Console.Write("Enter: ");
            var option = ReadInt();

            if (option != null && option < 0 || option >= options.Length)
                return defaultOption;

            return option ?? defaultOption;
        }

        static void Save(out bool save, out string saveFileName)
        {
            save = false;
            saveFileName = null;
            Console.WriteLine();

            if (unsavedChanges)
            {
                Console.WriteLine("Where should the data be saved?");
                var option = ReadOption(0, "Overwrite input data", "Store at new location");

                if (option == 1)
                {
                    Console.Write("Save to: ");
                    var filename = Console.ReadLine();

                    if (string.IsNullOrWhiteSpace(filename) || !CheckFileNameValidity(filename))
                    {
                        Console.WriteLine("Invalid or empty filename was given. Aborting.");
                    }
                    else
                    {
                        saveFileName = filename;
                        save = true;
                    }
                }
                else
                {
                    save = true;
                }
            }
            else
            {
                Console.WriteLine("No changes to save. Everything is up-to-date.");
                Console.WriteLine("Do you want to save to a different location?");
                var option = ReadOption(0, "No, just abort", "Yes, please");

                if (option == 1)
                {
                    Console.Write("Save to: ");
                    var filename = Console.ReadLine();

                    if (string.IsNullOrWhiteSpace(filename) || !CheckFileNameValidity(filename))
                    {
                        Console.WriteLine("Invalid or empty filename was given. Aborting.");
                    }
                    else
                    {
                        saveFileName = filename;
                        save = true;
                    }
                }
            }

            Console.WriteLine();
        }

        static bool CheckFileNameValidity(string filename)
        {
            try
            {
                new System.IO.FileInfo(filename);
                return true;
            }
            catch
            {
                return false;
            }
        }

        static void RemoveEvent(List<Event> eventList, List<Event> events)
        {
            ListEvents(events);
            Console.WriteLine();
            Console.Write("Which event to remove: ");
            var index = ReadInt(true);

            if (index == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var @event = events[index.Value];

            int listIndex = eventList.IndexOf(@event);

            if (listIndex != -1)
            {
                bool canMoveSuccessorToBegin = true;

                if (@event.Next != null)
                {
                    if (!EventDescriptions.Events[@event.Next.Type].AllowAsFirst)
                        canMoveSuccessorToBegin = false;
                }

                Console.WriteLine("The event starts an event chain. What do you want to do?");
                var options = new List<string> { "Abort", "Remove chain (keep events)", "Remove chain (and events)" };
                if (canMoveSuccessorToBegin)
                    options.Add("Make the successor the new chain start");
                var option = ReadOption(0, options.ToArray()) ?? 0;

                switch (option)
                {
                    case 0:
                        Console.WriteLine("Aborted");
                        Console.WriteLine();
                        return;
                    case 1:
                        eventList.Remove(@event);
                        Console.WriteLine("Chain removed. Events kept.");
                        Console.WriteLine();
                        return;
                    case 2:
                        Console.WriteLine("Are you sure to remove the whole chain?");
                        option = ReadOption(0, "No", "Yes") ?? 0;
                        if (option == 0)
                        {
                            Console.WriteLine("Aborted");
                            Console.WriteLine();
                            return;
                        }
                        eventList.Remove(@event);
                        var eventsToRemove = new List<Event>();
                        var eventToRemove = @event;
                        while (eventToRemove != null)
                        {
                            eventsToRemove.Add(eventToRemove);
                            eventToRemove = eventToRemove.Next;
                        }
                        Console.WriteLine("Chain removed. Events too.");
                        Console.WriteLine();
                        break;
                    case 3:
                        eventList[listIndex] = @event.Next;
                        Console.WriteLine("Chain now starts with successor.");
                        Console.WriteLine();
                        return;
                }
            }

            var prevs = events.Where(e => e.Next == @event).ToList();
            var conds = events.Where(e => e is ConditionEvent c && c.ContinueIfFalseWithMapEventIndex == index.Value).Cast<ConditionEvent>().ToList();
            var doors = events.Where(e => e is DoorEvent d && d.UnlockFailedEventIndex == index.Value).Cast<DoorEvent>().ToList();
            var chests = events.Where(e => e is ChestEvent c && c.UnlockFailedEventIndex == index.Value).Cast<ChestEvent>().ToList();
            var dices = events.Where(e => e is Dice100RollEvent r && r.ContinueIfFalseWithMapEventIndex == index.Value).Cast<Dice100RollEvent>().ToList();
            var decisions = events.Where(e => e is DecisionEvent d && d.NoEventIndex == index.Value).Cast<DecisionEvent>().ToList();

            if (prevs.Count != 0 || conds.Count != 0 || doors.Count != 0 || chests.Count != 0 || dices.Count != 0 || decisions.Count != 0)
            {
                Event successor = null;

                if (@event.Next != null)
                {
                    Console.WriteLine("The event has a successor. How to handle it?");
                    var option = ReadOption(0, "Connect predecessors with successor", "Disconnect") ?? 0;
                    successor = option == 0 ? @event.Next : null;
                }

                uint successorIndex = successor == null ? 0xffff : (uint)events.IndexOf(successor);

                if (successorIndex != 0xffff && successorIndex > index.Value)
                    --successorIndex;

                foreach (var prev in prevs)
                    prev.Next = successor;
                foreach (var cond in conds)
                    cond.ContinueIfFalseWithMapEventIndex = successorIndex;
                foreach (var door in doors)
                    door.UnlockFailedEventIndex = successorIndex;
                foreach (var chest in chests)
                    chest.UnlockFailedEventIndex = successorIndex;
                foreach (var dice in dices)
                    dice.ContinueIfFalseWithMapEventIndex = successorIndex;
                foreach (var decision in decisions)
                    decision.NoEventIndex = successorIndex;
            }

            @event.Next = null;

            for (int i = index.Value + 1; i < events.Count; ++i)
            {
                var ev = events[i];
                conds = events.Where(e => e is ConditionEvent c && c.ContinueIfFalseWithMapEventIndex == i).Cast<ConditionEvent>().ToList();
                doors = events.Where(e => e is DoorEvent d && d.UnlockFailedEventIndex == i).Cast<DoorEvent>().ToList();
                chests = events.Where(e => e is ChestEvent c && c.UnlockFailedEventIndex == i).Cast<ChestEvent>().ToList();
                dices = events.Where(e => e is Dice100RollEvent r && r.ContinueIfFalseWithMapEventIndex == i).Cast<Dice100RollEvent>().ToList();
                decisions = events.Where(e => e is DecisionEvent d && d.NoEventIndex == i).Cast<DecisionEvent>().ToList();

                foreach (var cond in conds)
                    --cond.ContinueIfFalseWithMapEventIndex;
                foreach (var door in doors)
                    --door.UnlockFailedEventIndex;
                foreach (var chest in chests)
                    --chest.UnlockFailedEventIndex;
                foreach (var dice in dices)
                    --dice.ContinueIfFalseWithMapEventIndex;
                foreach (var decision in decisions)
                    --decision.NoEventIndex;
            }

            events.Remove(@event);

            unsavedChanges = true;
        }

        static void ReplaceEvent(List<Event> eventList, List<Event> events, Event eventOld, Event eventNew)
        {
            int eventListIndex = eventList.IndexOf(eventOld);
            int eventsIndex = events.IndexOf(eventOld);

            if (eventListIndex != -1)
                eventList[eventListIndex] = eventNew;

            events[eventsIndex] = eventNew;

            foreach (var @event in events)
            {
                if (@event.Next == eventOld)
                    @event.Next = eventNew;
            }
        }

        static void EditEvent(List<Event> eventList, List<Event> events, bool map)
        {
            ListEvents(events);
            Console.WriteLine();
            Console.Write("Which event to edit: ");
            var index = ReadInt(true);

            if (index == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var @event = events[index.Value];
            Console.WriteLine($"Do you want to change the event type? Current is {@event.Type}. All data will be lost!");
            var option = ReadOption(0, "No, keep it", "Yes, change please") ?? 0;

            if (option == 1)
            {
                unsavedChanges = true;
                var tempEventList = new List<Event>();
                var tempEvents = new List<Event>();
                AddEvent(tempEventList, tempEvents, map, index.Value, true);
                ReplaceEvent(eventList, events, @event, tempEvents[0]);
                return;
            }
            else
            {
                var writer = new DataWriter();
                EventWriter.SaveEvent(writer, @event);
                var eventData = new byte[12];
                eventData[0] = (byte)@event.Type;
                var next = @event.Next;
                var nextIndex = (ushort)(next == null ? 0xffff : events.IndexOf(next));
                eventData[10] = (byte)((nextIndex >> 8) & 0xff);
                eventData[11] = (byte)(nextIndex & 0xff);
                System.Array.Copy(writer.ToArray(), 0, eventData, 1, 9);
                int dataIndex = 1;

                void Write(ValueDescription valueDescription, ushort value)
                {
                    if (valueDescription.Type == ValueType.Word ||
                        valueDescription.Type == ValueType.Flag16 ||
                        valueDescription.Type == ValueType.EventIndex)
                        WriteWord(value);
                    else
                        eventData[dataIndex++] = (byte)(value & 0xff);
                }

                void WriteWord(ushort value)
                {
                    eventData[dataIndex++] = (byte)((value >> 8) & 0xff);
                    eventData[dataIndex++] = (byte)(value & 0xff);
                }

                var eventDescription = EventDescriptions.Events[@event.Type];
                var type = @event.GetType();

                foreach (var value in eventDescription.ValueDescriptions)
                {
                    if (value.Hidden)
                    {
                        if (value.Type == ValueType.Word ||
                            value.Type == ValueType.Flag16 ||
                            value.Type == ValueType.EventIndex)
                            dataIndex += 2;
                        else
                            ++dataIndex;
                    }
                    else
                    {
                        var property = type.GetProperty(value.Name);
                        var currentValue = property.GetValue(@event);
                        Console.Write($"> {value.Name} ({currentValue}): ");
                        var input = ReadInt(value.ShowAsHex);

                        if (input == null || input < 0 || input > 0xffff || !value.Check((ushort)input))
                        {
                            if (value.Type == ValueType.Word ||
                                value.Type == ValueType.Flag16 ||
                                value.Type == ValueType.EventIndex)
                                dataIndex += 2;
                            else
                                ++dataIndex;
                        }
                        else
                        {
                            Write(value, (ushort)input);
                        }                        
                    }
                }

                // re-create event from filled data
                var eventReader = new DataReader(eventData);
                events[index.Value] = EventReader.ParseEvent(eventReader);
                events[index.Value].Next = next;

                unsavedChanges = true;

                var newEvent = events[index.Value];
                int eventListIndex = eventList.IndexOf(@event);

                if (eventListIndex != -1)
                    eventList[eventListIndex] = newEvent;

                foreach (var ev in events)
                {
                    if (ev.Next == @event)
                        ev.Next = newEvent;
                }

                Console.WriteLine("Event was changed successfully.");
                Console.WriteLine();
            }
        }

        static void ShowConnections(List<Event> eventList, List<Event> events)
        {
            ListEvents(events);
            Console.WriteLine();
            Console.Write("Which event to show connections for: ");

            var index = ReadInt(true);

            if (index == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var @event = events[index.Value];
            int listIndex = eventList.IndexOf(@event);
            var prevEvents = events.Where(e => e.Next == @event).Select(e => events.IndexOf(e)).ToList();

            Console.WriteLine();

            if (listIndex == -1 && prevEvents.Count == 0 && @event.Next == null)
            {
                Console.WriteLine("This event has no connections.");
            }
            else
            {
                Console.WriteLine("Connections:");

                if (listIndex != -1)
                    Console.WriteLine($"Start of event chain {listIndex + 1:x2}");

                if (@event.Next != null)
                    Console.WriteLine($"Following event is {events.IndexOf(@event.Next):x2}");

                foreach (var prevEvent in prevEvents)
                    Console.WriteLine($"Event {prevEvent:x2} is a predecessor");
            }

            Console.WriteLine();
        }

        static void DisconnectEvent(List<Event> eventList, List<Event> events)
        {
            ListEvents(events);
            Console.WriteLine();
            Console.Write("Which event to disconnect: ");

            var index = ReadInt(true);

            if (index == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var @event = events[index.Value];
            int listIndex = eventList.IndexOf(@event);

            if (listIndex != -1)
            {
                Console.WriteLine("The event starts an event chain. Do you want to remove this chain?");
                int option = ReadOption(0, "No", "Yes") ?? 0;

                if (option != 0)
                {
                    Console.WriteLine("Event chain removed. Note that event chain indices inside maps can't be adjusted automatically.");
                    eventList.RemoveAt(listIndex);
                }
            }

            var prevs = events.Where(e => e.Next == @event).ToList();
            var conds = events.Where(e => e is ConditionEvent c && c.ContinueIfFalseWithMapEventIndex == index.Value).Cast<ConditionEvent>().ToList();
            var doors = events.Where(e => e is DoorEvent d && d.UnlockFailedEventIndex == index.Value).Cast<DoorEvent>().ToList();
            var chests = events.Where(e => e is ChestEvent c && c.UnlockFailedEventIndex == index.Value).Cast<ChestEvent>().ToList();
            var dices = events.Where(e => e is Dice100RollEvent r && r.ContinueIfFalseWithMapEventIndex == index.Value).Cast<Dice100RollEvent>().ToList();
            var decisions = events.Where(e => e is DecisionEvent d && d.NoEventIndex == index.Value).Cast<DecisionEvent>().ToList();

            foreach (var prev in prevs)
                prev.Next = null;

            @event.Next = null;

            if (@event is ConditionEvent c)
                c.ContinueIfFalseWithMapEventIndex = 0xffff;
            else if (@event is DoorEvent d)
                d.UnlockFailedEventIndex = 0xffff;
            else if (@event is ChestEvent ch)
                ch.UnlockFailedEventIndex = 0xffff;
            else if (@event is Dice100RollEvent dc)
                dc.ContinueIfFalseWithMapEventIndex = 0xffff;
            else if (@event is DecisionEvent dec)
                dec.NoEventIndex = 0xffff;

            if (conds.Count != 0 || doors.Count != 0 || chests.Count != 0 || dices.Count != 0)
            {
                Console.WriteLine("There are events that chain the event through a failed condition. Should these also be disconnected?");
                ListEvents(conds, 0, ev => events.IndexOf(ev), false, true);
                ListEvents(doors, 0, ev => events.IndexOf(ev), true, true);
                ListEvents(chests, 0, ev => events.IndexOf(ev), true, true);
                ListEvents(dices, 0, ev => events.IndexOf(ev), true, false);
                ListEvents(decisions, 0, ev => events.IndexOf(ev), true, false);
                int option = ReadOption(0, "No", "Yes") ?? 0;

                if (option == 1)
                {
                    foreach (var cond in conds)
                        cond.ContinueIfFalseWithMapEventIndex = 0xffff;
                    foreach (var door in doors)
                        door.UnlockFailedEventIndex = 0xffff;
                    foreach (var chest in chests)
                        chest.UnlockFailedEventIndex = 0xffff;
                    foreach (var dice in dices)
                        dice.ContinueIfFalseWithMapEventIndex = 0xffff;
                    foreach (var decision in decisions)
                        decision.NoEventIndex = 0xffff;
                }
            }

            unsavedChanges = true;
            Console.WriteLine("Successfully disconnected the event.");
            Console.WriteLine();
        }

        static void ConnectEvent(List<Event> eventList, List<Event> events)
        {
            ListEvents(events);
            Console.WriteLine();
            Console.Write("Which event to connect: ");
            var index = ReadInt(true);

            if (index == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var @event = events[index.Value];
            var description = EventDescriptions.Events[@event.Type];

            if (description.AllowOnlyAsFirst)
            {
                Console.WriteLine($"Event of type {@event.Type} must be first in a chain and cannot be connected.");
                Console.WriteLine();
                return;
            }

            /*if (eventList.Contains(@event))
            {
                Console.WriteLine("The event is the first of an event chain. You can't connect it to another event.");
                Console.WriteLine("If you really want to do this, first disconnect the event with the 'disconnect'");
                Console.WriteLine("command and then try again to connect it.");
                Console.WriteLine();
                return;
            }*/

            Console.WriteLine();
            Console.Write("Which event to connect to: ");
            var targetIndex = ReadInt(true);

            if (targetIndex == null)
            {
                Console.WriteLine("Invalid event index");
                Console.WriteLine();
                return;
            }

            var targetEvent = events[targetIndex.Value];
            
            if (targetEvent.Next != null)
            {
                Console.WriteLine("The target event already has a connected event.");
                Console.WriteLine("What do you want to do with it?");
                var option = ReadOption(0, "Remove its connection.", @event.Next == null ?
                    "Use it as the new successor." : "Replace the current successor by it.") ?? 0;

                if (option != 0)
                    @event.Next = targetEvent.Next;
            }

            unsavedChanges = true;
            targetEvent.Next = @event;

            if (!IsPartOfChain(eventList, targetEvent))
            {
                Console.WriteLine("The target event is not part of a chain. Do you want to create a");
                Console.WriteLine("new event chain with the target event as a start?");

                if ((ReadOption(0, "No, thanks", "Yes, please") ?? 0) == 1)
                    eventList.Add(targetEvent);
            }

            Console.WriteLine("Successfully connected both events.");
            Console.WriteLine();
        }

        static bool IsPartOfChain(List<Event> eventList, Event @event)
        {
            if (eventList.Contains(@event))
                return true;

            foreach (var startEvent in eventList)
            {
                var checkedEvents = new HashSet<Event>();
                var ev = startEvent;

                while (ev != null)
                {
                    if (!checkedEvents.Add(ev))
                        break;

                    if (ev == @event)
                        return true;

                    ev = ev.Next;
                }
            }

            return false;
        }

        static void AddEvent(List<Event> eventList, List<Event> events, bool map, int insertIndex = -1, bool fromEdit = false)
        {
            var availableEvents = EventDescriptions.Events.Where(e => map && e.Value.AllowMaps || !map && e.Value.AllowNPCs).Select(e => e.Key).ToList();

            availableEvents.Remove(EventType.Invalid);
            availableEvents.Remove(EventType.Unknown);

            if (!map && fromEdit)
            {
                availableEvents.Remove(EventType.Conversation);
                availableEvents.Remove(EventType.Create);
                availableEvents.Remove(EventType.Exit);
                availableEvents.Remove(EventType.Interact);
                availableEvents.Remove(EventType.PrintText);
            }

            Console.WriteLine();
            Console.WriteLine("Available events");
            Console.WriteLine("+--------------+");
            foreach (var eventType in availableEvents)
            {
                Console.WriteLine($"{(int)eventType:00}: {eventType}");
            }
            Console.WriteLine();
            Console.Write("Which event to add: ");
            int? type = ReadInt();
            if (type == null || !availableEvents.Cast<int>().Contains(type.Value))
            {
                Console.WriteLine("Invalid event type");
                Console.WriteLine();
                return;
            }

            var eventDescription = EventDescriptions.Events[(EventType)type];

            bool newChain = false;
            int? connectTo = null;

            if (eventDescription.AllowOnlyAsFirst)
            {
                Console.WriteLine("This event type must be the first in a chain so a new event chain will be added.");
                if (eventList.Count == 64)
                {
                    Console.WriteLine("There is no free event chain slot. Aborting.");
                    Console.WriteLine();
                    return;
                }
                newChain = true;
            }
            else
            {
                if (fromEdit)
                {
                    newChain = false;
                }
                else if (eventDescription.AllowAsFirst)
                {
                    Console.WriteLine();
                    Console.WriteLine("How should the new event be connected?");
                    var option = ReadOption(0, "Disconnected event", "New event chain", "Connect to event");

                    if (option.Value == 1)
                        newChain = true;
                    else if (option.Value == 2)
                    {
                        Console.WriteLine();
                        Console.WriteLine("Connect to which event");
                        ListEvents(events);
                        var index = ReadInt(true);

                        if (index == null || index < 0 || index >= events.Count)
                        {
                            Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
                        }
                        else
                        {
                            connectTo = index;
                        }
                    }
                }
                else if (eventList.Count == 0)
                {
                    newChain = false;
                }
                else
                {
                    Console.WriteLine();
                    Console.WriteLine("How should the new event be connected?");
                    var option = ReadOption(0, "Disconnected event", "Connect to event");

                    if (option.Value == 1)
                    {
                        Console.WriteLine();
                        Console.WriteLine("Connect to which event");
                        ListEvents(events);
                        var index = ReadInt(true);

                        if (index == null || index < 0 || index >= events.Count)
                        {
                            Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
                        }
                        else
                        {
                            connectTo = index;
                        }
                    }
                }
            }

            byte[] eventData = new byte[12];
            eventData[0] = (byte)type;
            eventData[10] = 0xff;
            eventData[11] = 0xff;
            int dataIndex = 1;

            void Write(ValueDescription valueDescription, ushort value)
            {
                if (valueDescription.Type == ValueType.Word ||
                    valueDescription.Type == ValueType.Flag16 ||
                    valueDescription.Type == ValueType.EventIndex)
                    WriteWord(value);
                else
                    eventData[dataIndex++] = (byte)(value & 0xff);
            }

            void WriteWord(ushort value)
            {
                eventData[dataIndex++] = (byte)((value >> 8) & 0xff);
                eventData[dataIndex++] = (byte)(value & 0xff);
            }

            foreach (var value in eventDescription.ValueDescriptions)
            {
                if (value.Hidden)
                    Write(value, value.DefaultValue);
                else
                {
                    if (value.Required)
                    {
                        Console.Write($"> {value.Name}: ");
                        var input = ReadInt(value.ShowAsHex);

                        if (input == null)
                        {
                            Console.WriteLine("No value given. Aborting.");
                            Console.WriteLine();
                            return;
                        }
                        else if (input < 0 || input > 0xffff || !value.Check((ushort)input.Value))
                        {
                            Console.WriteLine("Invalid value given. Aborting.");
                            Console.WriteLine();
                            return;
                        }

                        Write(value, (ushort)input.Value);
                    }
                    else
                    {
                        Console.Write($"> {value.Name} ({value.DefaultValueText}): ");
                        var input = ReadInt(value.ShowAsHex) ?? value.DefaultValue;

                        if (input < 0 || input > 0xffff || !value.Check((ushort)input))
                        {
                            Console.WriteLine($"Invalid value given. Using default: {value.DefaultValueText}");
                            input = value.DefaultValue;
                        }

                        Write(value, (ushort)input);
                    }
                }
            }

            // create event from filled data
            var eventReader = new DataReader(eventData);
            var @event = EventReader.ParseEvent(eventReader);

            if (insertIndex == -1 || insertIndex >= events.Count)
                events.Add(@event);
            else
                events.Insert(insertIndex, @event);

            unsavedChanges = true;

            if (newChain)
            {
                eventList.Add(@event);
            }
            else if (connectTo != null)
            {
                var prev = events[connectTo.Value];
                @event.Next = prev.Next;
                prev.Next = @event;
            }

            Console.WriteLine($"Event {(fromEdit ? "changed" : "added")} successfully.");
            Console.WriteLine();
        }

        static void ShowHelp(string command = "")
        {
            Console.WriteLine();

            switch (command)
            {
                case "exit":
                    Console.WriteLine("Immediately closes the application.");
                    break;
                case "list":
                    Console.WriteLine("Lists all entries of the event list.");
                    Console.WriteLine("The event list contains the first events");
                    Console.WriteLine("of every event chain on the map or any");
                    Console.WriteLine("conversation start event for NPCs.");
                    Console.WriteLine();
                    Console.WriteLine("To see all events use the command 'events'.");
                    Console.WriteLine();
                    Console.WriteLine("Note that the IDs are not meant to be used");
                    Console.WriteLine("in any command except for chain. These are the");
                    Console.WriteLine("IDs which are referenced from map tiles only.");
                    break;
                case "short":
                    Console.WriteLine("Like the list command but only shows the");
                    Console.WriteLine("names of the events.");
                    break;
                case "events":
                    Console.WriteLine("Lists all events of the map or NPC.");
                    Console.WriteLine();
                    Console.WriteLine("The displayed IDs identify the event in all");
                    Console.WriteLine("kind of commands.");
                    break;
                case "summary":
                    Console.WriteLine("Like the events command but only shows the");
                    Console.WriteLine("names of the events.");
                    break;
                case "chain":
                    Console.WriteLine("Lists all events of a given event chain.");
                    Console.WriteLine();
                    Console.WriteLine("This is the only command to use the ID from");
                    Console.WriteLine("the list command!");
                    break;
                case "add":
                    Console.WriteLine("Adds an event to the end of the list.");
                    Console.WriteLine("You can also start a new event chain");
                    Console.WriteLine("with this command. You will be asked");
                    Console.WriteLine("for several settings interactively.");
                    break;
                case "edit":
                    Console.WriteLine("Edits an existing event.");
                    Console.WriteLine("You can even change the event type.");
                    Console.WriteLine("To (re-)connect events use the commands");
                    Console.WriteLine("'connect' or 'disconnect' instead.");
                    break;
                case "connect":
                    Console.WriteLine("Connects existing events.");
                    break;
                case "disconnect":
                    Console.WriteLine("Disconnects existing events.");
                    break;
                case "connections":
                    Console.WriteLine("Shows the connections of an event.");
                    break;
                case "save":
                    Console.WriteLine("Save all current changes.");
                    Console.WriteLine("You will be ask to overwrite the current file");
                    Console.WriteLine("or save to a new location.");
                    break;
                default:
                    Console.WriteLine("Available commands");
                    Console.WriteLine("+----------------+");
                    Console.WriteLine("list        -> Shows the list of event chains");
                    Console.WriteLine("events      -> Shows the list of all single events");
                    Console.WriteLine("chain       -> Shows all events of a given event chain");
                    Console.WriteLine("add         -> Adds a new event to the end of the list");
                    Console.WriteLine("remove      -> Removes an event by its index");
                    Console.WriteLine("edit        -> Edits an existing event");
                    Console.WriteLine("connect     -> Connects an existing event");
                    Console.WriteLine("disconnect  -> Disconnects an existing event");
                    Console.WriteLine("connections -> Shows the connections of an event");
                    Console.WriteLine("reorder     -> Reorders events");
                    Console.WriteLine("save        -> Saves all changes");
                    Console.WriteLine("exit        -> Exits the application");
                    Console.WriteLine("help        -> Shows this help");
                    Console.WriteLine("usage       -> Shows tool usage");
                    Console.WriteLine();
                    Console.WriteLine("To get more information use: help <command>");
                    break;
            }

            Console.WriteLine();
        }

        static void ListEvents<T>(List<T> events, int startIndex = 0, System.Func<Event, int> customIndexer = null, bool noHeader = false, bool noFooter = false) where T : Event
        {
            if (!noHeader)
            {
                Console.WriteLine();
                Console.WriteLine("ID | Description");
                Console.WriteLine("---|" + new string('-', 75));
            }

            int index = startIndex;
            foreach (var @event in events)
            {
                int displayIndex = customIndexer == null ? index : customIndexer(events[index]);
                Console.WriteLine($"{displayIndex:x2} | " + EventDescriptions.ToString(@event, 5, "   | "));
                ++index;
            }

            if (!noFooter)
                Console.WriteLine();
        }

        static void ListEventsShort<T>(List<T> events) where T : Event
        {
            Console.WriteLine();
            Console.WriteLine("ID | Type");
            Console.WriteLine("---|" + new string('-', 75));

            int index = 1;
            foreach (var @event in events)
            {
                Console.WriteLine($"{index:x2} | " + @event.Type.ToString());
                ++index;
            }

            Console.WriteLine();
        }

        static void ShowChain(List<Event> eventList, List<Event> events, int index)
        {
            if (index < 0 || index >= eventList.Count)
            {
                Console.WriteLine();
                Console.WriteLine("Invalid event list index");
                Console.WriteLine();
                return;
            }

            var chainEvents = new List<Event>();
            var @event = eventList[index];

            while (@event != null)
            {
                chainEvents.Add(@event);
                @event = @event.Next;
            }

            ListEvents(chainEvents, 0, ev => events.IndexOf(ev));
        }

        static void ReorderEvents(List<Event> eventList, List<Event> events)
        {
            var idMapping = new Dictionary<uint, uint>();
            var visited = new HashSet<int>();

            void ProcessEvents(Event startEvent)
            {
                var branches = new Queue<Event>();
                var @event = startEvent;

                Event Visit(Event ev)
                {
                    int eventIndex = events.IndexOf(ev);

                    if (!visited.Add(eventIndex))
                        return null;

                    idMapping.Add((uint)eventIndex, (uint)idMapping.Count);

                    if (ev is ConditionEvent conditionEvent && conditionEvent.ContinueIfFalseWithMapEventIndex != 0xffff)
                        branches.Enqueue(events[(int)conditionEvent.ContinueIfFalseWithMapEventIndex]);
                    else if (ev is Dice100RollEvent diceEvent && diceEvent.ContinueIfFalseWithMapEventIndex != 0xffff)
                        branches.Enqueue(events[(int)diceEvent.ContinueIfFalseWithMapEventIndex]);
                    else if (ev is DoorEvent doorEvent && doorEvent.UnlockFailedEventIndex != 0xffff)
                        branches.Enqueue(events[(int)doorEvent.UnlockFailedEventIndex]);
                    else if (ev is ChestEvent chestEvent && chestEvent.UnlockFailedEventIndex != 0xffff)
                        branches.Enqueue(events[(int)chestEvent.UnlockFailedEventIndex]);
                    else if (ev is DecisionEvent decisionEvent && decisionEvent.NoEventIndex != 0xffff)
                        branches.Enqueue(events[(int)decisionEvent.NoEventIndex]);

                    return ev.Next;
                }

                while (@event != null)
                {
                    @event = Visit(@event);
                }

                while (branches.Count != 0)
                {
                    @event = branches.Dequeue();

                    ProcessEvents(@event);
                }
            }
          
            foreach (var chain in eventList)
            {
                ProcessEvents(chain);
            }

            // Also add all events that have no connection
            foreach (var ev in events)
                ProcessEvents(ev);

            foreach (var ev in events)
            {
                if (ev is ConditionEvent conditionEvent && conditionEvent.ContinueIfFalseWithMapEventIndex != 0xffff)
                    conditionEvent.ContinueIfFalseWithMapEventIndex = idMapping[conditionEvent.ContinueIfFalseWithMapEventIndex];
                else if (ev is Dice100RollEvent diceEvent && diceEvent.ContinueIfFalseWithMapEventIndex != 0xffff)
                    diceEvent.ContinueIfFalseWithMapEventIndex = idMapping[diceEvent.ContinueIfFalseWithMapEventIndex];
                else if (ev is DecisionEvent decisionEvent && decisionEvent.NoEventIndex != 0xffff)
                    decisionEvent.NoEventIndex = idMapping[decisionEvent.NoEventIndex];
                else if (ev is DoorEvent doorEvent && doorEvent.UnlockFailedEventIndex != 0xffff)
                    doorEvent.UnlockFailedEventIndex = idMapping[doorEvent.UnlockFailedEventIndex];
                else if (ev is ChestEvent chestEvent && chestEvent.UnlockFailedEventIndex != 0xffff)
                    chestEvent.UnlockFailedEventIndex = idMapping[chestEvent.UnlockFailedEventIndex];
            }

            var reorderedList = idMapping.Keys.Select(i => events[(int)i]).ToList();

            events.Clear();
            events.AddRange(reorderedList);
        }
    }
}
