// AmbermoonEventEditor: a command line tool to edit the events of maps, NPCs and party members of Ambermoon. A port of
// AmbermoonEventEditor of https://github.com/Pyrdacor/Ambermoon (AmbermoonTools); see ../README.md for what is
// different.
//
// The events of the original are objects; here they are ids in the EventStore 'Store', and the lists of the original
// ('eventList': the first events of the chains, 'events': all events) are lists of ids.
namespace AmbermoonEventEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;

bool UnsavedChanges = false;
EventStore Store = EventStore.Create();

// the file that is edited: what is around the events, and for maps where the tiles are
struct EditedFile
{
    uint8[] Head;
    uint8[] Tail; // null: none
    string InputFileName;
    bool Map;
    int InitialMapEventCount;
    Optional<MapType> MapType;
    Optional<int> TileOffset;
    Optional<int> NumTiles;
    Optional<int> MapIndex;
}

void Usage(Optional<string> error)
{
    if (error is string text)
        Error(text);

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
    Console.WriteLine(" AmbermoonEventEditor \"NPC_char\\extracted\\001\" 1");
    Console.WriteLine(" AmbermoonEventEditor \"Save.00\\Party_char\\extracted\\001\" 2");
    Console.WriteLine();
}

void Error(string error)
{
    Console.WriteLine();
    Console.WriteLine(error);
}

void Exit(int exitCode)
{
    Environment.Exit(exitCode);
}

// the file is too short for what it should contain (the original ends with an exception then)
void TooShort()
{
    Console.WriteErrorLine("The file is too short for this type of data.");
    Exit(1);
}

int Main(string[] args)
{
    if (args.Length != 2)
    {
        Usage("Invalid number of arguments");
        Exit(1);
    }

    if (!File.Exists(args[0]) || Directory.Exists(args[0]))
    {
        Error("The given file does not exist");
        Exit(1);
    }

    int type = ParseInt(args[1]) is int t ? t : -1;
    if (type < 0 || type > 2)
    {
        Usage("Invalid file type given");
        Exit(1);
    }

    var data = File.ReadAllBytes(args[0]) is uint8[] bytes ? bytes : new uint8[0];
    var dataReader = DataReader.FromData(data);
    var events = List<int>.Create();
    var eventList = List<int>.Create();

    if (type == 0) // map
    {
        if (data.Length < 6)
            TooShort();
        dataReader.Position = 2; // skip flags
        var mapType = (MapType)dataReader.ReadByte();
        dataReader.Position = 4; // skip music index
        int mapWidth = dataReader.ReadByte();
        int mapHeight = dataReader.ReadByte();
        int eventOffset = 0x014C + mapWidth * mapHeight * (mapType == MapType.Map2D ? 4 : 2);
        if (eventOffset > data.Length)
            TooShort();
        dataReader.Position = 0;
        var head = dataReader.ReadBytes(eventOffset);
        _ReadEvents(ref dataReader, events, eventList);
        var tail = dataReader.ReadToEnd();
        int mapIndex = ParseInt(Path.GetFileName(args[0])) is int index ? index : 0;
        ProcessEvents(eventList, events, EditedFile {
            Head = head, Tail = tail, InputFileName = args[0], Map = true, InitialMapEventCount = eventList.Count(), MapType = mapType,
            TileOffset = 0x014C, NumTiles = mapWidth * mapHeight, MapIndex = mapIndex
        });
    }
    else // NPC (1) or party member (2)
    {
        int headSize = type == 1 ? 0x122 : 0x1e8;
        if (headSize > data.Length)
            TooShort();
        var head = dataReader.ReadBytes(headSize);
        _ReadEvents(ref dataReader, events, eventList);
        ProcessEvents(eventList, events, EditedFile { Head = head, Tail = null, InputFileName = args[0], Map = false });
    }
    return 0;
}

void _ReadEvents(ref DataReader dataReader, List<int> events, List<int> eventList)
{
    if (EventReader.ReadEvents(ref dataReader, Store, events, eventList) is error e)
    {
        Console.WriteErrorLine("The events can not be read: " + e.Message);
        Exit(1);
    }
}

void DrawLine()
{
    Console.WriteLine("+" + "-".Repeat(78) + "+");
}

void ProcessEvents(List<int> eventList, List<int> events, EditedFile file)
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
        string command = ReadLine();
        DrawLine();

        var request = ProcessCommand(command, eventList, events, file);

        if (request.Save)
            SaveFile(eventList, events, file, request.FileName is string name ? name : file.InputFileName);
    }
}

// the chain with the 0-based index was removed: adjust the event indices of the map tiles and the event bits
void RemoveEventChain(List<int> eventList, List<int> events, EditedFile file, int eventChainIndex)
{
    if (file.MapType is not MapType mapType)
        return;
    if (file.TileOffset is not int tileOffset)
        return;
    if (file.NumTiles is not int numTiles)
        return;

    eventChainIndex += 1; // 0-based to 1-based

    // the tiles: remove the chain, and decrease the index of chains with a higher index
    int sizePerTile = mapType == MapType.Map2D ? 4 : 2;
    int index = tileOffset + 1;
    var head = file.Head;

    for (var i = 0; i < numTiles; i += 1)
    {
        if (head[index] == eventChainIndex)
            head[index] = 0;
        else if (head[index] > eventChainIndex)
            head[index] = (uint8)(head[index] - 1);
        index += sizePerTile;
    }

    // the SetEventBit actions and EventBit conditions that refer to events of the same map with a higher index
    int mapIndex = file.MapIndex is int m ? m : 0;
    if (mapIndex < 1 || mapIndex > 530)
    {
        Console.WriteLine("WARNING: The map index could not be determined so SetEventBit actions could not be adjusted. You have to do so on your own.");
        return;
    }

    int mapBitOffset = (mapIndex - 1) * 64;
    int end = mapBitOffset + 64; // behind the last index to decrease
    int start = mapBitOffset + eventChainIndex; // the first index to decrease
    int remove = start - 1; // this can be removed
    var eventsToRemove = List<int>.Create();

    foreach (var id in events)
    {
        var e = Store.Get(id);
        if (e.Data is ActionEvent action && action.TypeOfAction == ActionType.SetEventBit)
        {
            if (action.ObjectIndex == remove)
            {
                eventsToRemove.Add(id);
            }
            else if (action.ObjectIndex >= start && action.ObjectIndex < end)
            {
                action.ObjectIndex -= 1;
                e.Data = action;
                Store.Set(e);
            }
        }
    }

    foreach (var id in events)
    {
        var e = Store.Get(id);
        if (e.Data is ConditionEvent condition && condition.TypeOfCondition == ConditionType.EventBit)
        {
            if (condition.ObjectIndex == remove)
            {
                // hopefully this does not happen; the resolution might be complex, so just warn
                Console.WriteLine($"EventBit condition event {events.IndexOf(id):x2} references the removed event chain. Please check this manually.");
            }
            else if (condition.ObjectIndex >= start && condition.ObjectIndex < end)
            {
                condition.ObjectIndex -= 1;
                e.Data = condition;
                Store.Set(e);
            }
        }
    }

    eventsToRemove.Reverse();

    foreach (var id in eventsToRemove)
    {
        int eventIndex = events.IndexOf(id);
        Console.WriteLine($"SetEventBit action event {eventIndex:x2} references the removed event chain. Now trying to remove it.");
        RemoveEvent(eventList, events, eventIndex, false, null);
    }
}

void SaveFile(List<int> eventList, List<int> events, EditedFile file, string saveFileName)
{
    var writer = DataWriter.Create(file.Head);
    EventWriter.WriteEvents(ref writer, Store, events, eventList);
    var tail = file.Tail;
    if (tail != null && tail.Length != 0)
    {
        bool map3D = file.MapType is MapType mapType && mapType == MapType.Map3D;
        if (file.Map && map3D && eventList.Count() != file.InitialMapEventCount)
        {
            if (eventList.Count() < file.InitialMapEventCount)
            {
                int removeByteCount = file.InitialMapEventCount - eventList.Count();
                int keep = tail.Length - removeByteCount;
                if (keep > 0)
                    writer.WriteBytes(tail, 0, keep);
            }
            else
            {
                writer.WriteBytes(tail);
                for (var i = file.InitialMapEventCount; i < eventList.Count(); i += 1)
                    writer.WriteByte((uint8)_AutomapType(Store.Get(eventList[i])));
            }
        }
        else
        {
            writer.WriteBytes(tail);
        }
    }

    if (File.WriteAllBytes(saveFileName, writer.ToArray()) is error)
        Console.WriteLine($"Failed to save to '{saveFileName}'.");
    else
        Console.WriteLine($"Successfully saved to '{saveFileName}'.");

    Console.WriteLine();
}

// what the automap shows for a new event chain of a 3D map
AutomapType _AutomapType(Event e)
{
    switch (e.Type)
    {
        case EventType.Chest:
            return AutomapType.Chest;
        case EventType.Door:
            return AutomapType.Door;
        case EventType.EnterPlace:
        {
            var placeType = e.Data is EnterPlaceEvent p ? p.PlaceType : PlaceType.Trainer;
            switch (placeType)
            {
                case PlaceType.FoodDealer:
                case PlaceType.Library:
                case PlaceType.Merchant:
                    return AutomapType.Merchant;
                case PlaceType.Inn:
                    return AutomapType.Tavern;
                default:
                    return AutomapType.DoorOpen;
            }
        }
        case EventType.Riddlemouth:
            return AutomapType.Riddlemouth;
        case EventType.Spinner:
            return AutomapType.Spinner;
        case EventType.StartBattle:
            return AutomapType.Monster;
        case EventType.Teleport:
        {
            var transition = e.Data is TeleportEvent t ? t.Transition : TransitionType.WindGate;
            switch (transition)
            {
                case TransitionType.MapChange:
                case TransitionType.Outro:
                    return AutomapType.Exit;
                case TransitionType.Teleporter:
                    return AutomapType.Teleporter;
                case TransitionType.Falling:
                    return AutomapType.Trapdoor;
                default:
                    return AutomapType.None;
            }
        }
        case EventType.Trap:
            return AutomapType.Trap;
        default:
            return AutomapType.None;
    }
}

// what the 'save' command asks for
struct SaveRequest
{
    bool Save;
    Optional<string> FileName;
}

// the commands that take an event index
enum IndexCommand : uint8
{
    Chain,
    Edit,
    Remove,
    Copy,
    CopyChain,
    CopyRange,
    Connect,
    Disconnect,
    Connections,
    Graph
}

SaveRequest ProcessCommand(string command, List<int> eventList, List<int> events, EditedFile file)
{
    var request = SaveRequest { Save = false };
    var args = List<StringSlice>.Create();
    foreach (var part in command.Split(' '))
    {
        if (part.Length != 0)
            args.Add(part);
    }

    if (args.Count() == 0)
    {
        ShowHelp("");
        return request;
    }

    switch (args[0].ToLower())
    {
        case "exit":
            Exit(0);
            break;
        case "list":
            ListEvents(eventList, 1);
            break;
        case "short":
            ListEventsShort(eventList);
            break;
        case "events":
            ListEvents(events, 0);
            break;
        case "summary":
            ListEventsShort(events);
            break;
        case "chain":
            EventIndexAction(args, IndexCommand.Chain, eventList, events, file, eventList, "Which event list to chain: ", true);
            break;
        case "add":
            AddEvent(eventList, events, file.Map, -1, false);
            break;
        case "edit":
            EventIndexAction(args, IndexCommand.Edit, eventList, events, file, events, "Which event to edit: ", false);
            break;
        case "remove":
            EventIndexAction(args, IndexCommand.Remove, eventList, events, file, events, "Which event to remove: ", false);
            break;
        case "copy":
            EventIndexAction(args, IndexCommand.Copy, eventList, events, file, events, "Which event to copy: ", false);
            break;
        case "copychain":
            EventIndexAction(args, IndexCommand.CopyChain, eventList, events, file, eventList, "Which event chain to copy: ", true);
            break;
        case "copyrange":
            EventIndexAction(args, IndexCommand.CopyRange, eventList, events, file, events, "Which event to start the copy at: ", false);
            break;
        case "connect":
            EventIndexAction(args, IndexCommand.Connect, eventList, events, file, events, "Which event to connect: ", false);
            break;
        case "disconnect":
            EventIndexAction(args, IndexCommand.Disconnect, eventList, events, file, events, "Which event to disconnect: ", false);
            break;
        case "connections":
            EventIndexAction(args, IndexCommand.Connections, eventList, events, file, events, "Which event to show connections for: ", false);
            break;
        case "reorder":
            ReorderEvents(eventList, events);
            break;
        case "save":
            request = Save();
            break;
        case "graph":
            EventIndexAction(args, IndexCommand.Graph, eventList, events, file, eventList, "Which event chain to graph: ", true);
            break;
        case "help":
            ShowHelp(args.Count() == 1 ? "" : args[1].ToLower());
            break;
        case "usage":
            Usage(null);
            break;
        default:
            ShowHelp("");
            break;
    }
    return request;
}

// an event (list) index from the command line or asked for, then the command
void EventIndexAction(List<StringSlice> args, IndexCommand command, List<int> eventList, List<int> events, EditedFile file,
                      List<int> possibleEvents, string headerText, bool isEventList)
{
    int index;
    if (args.Count() >= 2 && ParseHex(args[1]) is int given)
    {
        index = given;
    }
    else
    {
        ListEvents(possibleEvents, isEventList ? 1 : 0);
        Console.WriteLine();
        Console.Write(headerText);
        index = ReadInt(true) is int read ? read : -1;
    }

    if (isEventList)
        index -= 1;

    if (index < 0 || index >= possibleEvents.Count())
    {
        if (isEventList)
            Console.WriteLine("Invalid event list index");
        else
            Console.WriteLine("Invalid event index");
        Console.WriteLine();
        return;
    }

    switch (command)
    {
        case IndexCommand.Chain:
            ShowChain(eventList, events, index);
            break;
        case IndexCommand.Edit:
            EditEvent(eventList, events, file.Map, index);
            break;
        case IndexCommand.Remove:
            RemoveEvent(eventList, events, index, false, file);
            break;
        case IndexCommand.Copy:
            CopyEvent(eventList, events, index);
            break;
        case IndexCommand.CopyChain:
            CopyEventChain(eventList, events, index);
            break;
        case IndexCommand.CopyRange:
            CopyEventRange(eventList, events, index);
            break;
        case IndexCommand.Connect:
            ConnectEvent(eventList, events, index);
            break;
        case IndexCommand.Disconnect:
            DisconnectEvent(eventList, events, index);
            break;
        case IndexCommand.Connections:
            ShowConnections(eventList, events, index);
            break;
        case IndexCommand.Graph:
            Graph(eventList, events, index);
            break;
    }
}

SaveRequest Save()
{
    var request = SaveRequest { Save = false };
    Console.WriteLine();

    if (UnsavedChanges)
    {
        Console.WriteLine("Where should the data be saved?");
        var option = ReadOption(0, ["Overwrite input data", "Store at new location"]);

        if (option == 1)
        {
            Console.Write("Save to: ");
            var filename = Console.ReadLine();

            if (!(filename is string name) || name.Trim().Length == 0 || !CheckFileNameValidity(name))
            {
                Console.WriteLine("Invalid or empty filename was given. Aborting.");
            }
            else
            {
                request.FileName = name;
                request.Save = true;
            }
        }
        else
        {
            request.Save = true;
        }
    }
    else
    {
        Console.WriteLine("No changes to save. Everything is up-to-date.");
        Console.WriteLine("Do you want to save to a different location?");
        var option = ReadOption(0, ["No, just abort", "Yes, please"]);

        if (option == 1)
        {
            Console.Write("Save to: ");
            var filename = Console.ReadLine();

            if (!(filename is string name) || name.Trim().Length == 0 || !CheckFileNameValidity(name))
            {
                Console.WriteLine("Invalid or empty filename was given. Aborting.");
            }
            else
            {
                request.FileName = name;
                request.Save = true;
            }
        }
    }

    Console.WriteLine();
    return request;
}

// whether the name can be a file name (new FileInfo(name) of the original)
bool CheckFileNameValidity(string filename)
{
    return filename.IndexOf('\0') < 0;
}
