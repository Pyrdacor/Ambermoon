namespace AmbermoonEventEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;

// how ListEvents numbers the events
enum Indexer : uint8
{
    // from the start index on
    Count,
    // by their index in 'events'
    EventIndex
}

void ListEvents(List<int> list, int startIndex)
{
    ListEvents(list, startIndex, Indexer.Count, new List<int>(), false, false);
}

// the events with their descriptions ("ID | Description"); the original numbers them from startIndex on but takes the
// event at that position for its custom indexer
void ListEvents(List<int> list, int startIndex, Indexer indexer, List<int> events, bool noHeader, bool noFooter)
{
    if (!noHeader)
    {
        Console.WriteLine();
        Console.WriteLine("ID | Description");
        Console.WriteLine("---|" + "-".Repeat(75));
    }

    int index = startIndex;
    foreach (var id in list)
    {
        int displayIndex = indexer == Indexer.Count ? index : events.IndexOf(list[index]);
        Console.WriteLine($"{displayIndex:x2} | " + EventDescriptions.ToString(Store.Get(id), 5, "   | "));
        index += 1;
    }

    if (!noFooter)
        Console.WriteLine();
}

// the events with their types only
void ListEventsShort(List<int> list)
{
    Console.WriteLine();
    Console.WriteLine("ID | Type");
    Console.WriteLine("---|" + "-".Repeat(75));

    int index = 1;
    foreach (var id in list)
    {
        Console.WriteLine($"{index:x2} | " + Store.Get(id).Type.ToString());
        index += 1;
    }

    Console.WriteLine();
}

void ShowChain(List<int> eventList, List<int> events, int index)
{
    if (index < 0 || index >= eventList.Count())
    {
        Console.WriteLine();
        Console.WriteLine("Invalid event list index");
        Console.WriteLine();
        return;
    }

    var chainEvents = List<int>.Create();
    int id = eventList[index];

    // (the original runs forever if the chain is a loop)
    while (id >= 0 && !chainEvents.Contains(id))
    {
        chainEvents.Add(id);
        id = Store.NextOf(id);
    }

    ListEvents(chainEvents, 0, Indexer.EventIndex, events, false, false);
}

void ShowHelp(StringSlice command)
{
    Console.WriteLine();

    switch (command.ToString())
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
        case "remove":
            Console.WriteLine("Removes an existing event.");
            Console.WriteLine("You can change how the remaining");
            Console.WriteLine("connections are handled.");
            break;
        case "copy":
            Console.WriteLine("Adds a duplicate of the given");
            Console.WriteLine("event to the end of the events.");
            break;
        case "copychain":
            Console.WriteLine("Adds a duplicate of the given");
            Console.WriteLine("event chain to the end of the event");
            Console.WriteLine("chains. References to other events");
            Console.WriteLine("that are not given by the Next property");
            Console.WriteLine("will be preserved (like negative condition");
            Console.WriteLine("event indices and so on).");
            break;
        case "copyrange":
            Console.WriteLine("Adds duplicates of the given range");
            Console.WriteLine("of events to the end of the list of events.");
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
            Console.WriteLine("copy        -> Copies an existing event");
            Console.WriteLine("copychain   -> Copies an existing event chain");
            Console.WriteLine("copyrange   -> Copies a range of existing events");
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
