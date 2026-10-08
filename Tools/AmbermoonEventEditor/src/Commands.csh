namespace AmbermoonEventEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy.Serialization;

// the events that branch to the event with this index (conditions, doors, chests, dice rolls, decisions and party member
// conditions)
List<int> _BranchingTo(List<int> events, uint32 index)
{
    var result = List<int>.Create();
    foreach (var id in events)
    {
        var e = Store.Get(id);
        if (e.IsBranchEvent() && e.AlternativeBranchEventIndex() == index)
            result.Add(id);
    }
    return result;
}

// the events of one kind that branch to the event with this index
List<int> _BranchingToOfType(List<int> events, uint32 index, EventType type)
{
    var result = List<int>.Create();
    foreach (var id in events)
    {
        var e = Store.Get(id);
        if (e.Type == type && e.IsBranchEvent() && e.AlternativeBranchEventIndex() == index)
            result.Add(id);
    }
    return result;
}

void _SetBranch(int id, uint32 index)
{
    var e = Store.Get(id);
    e.SetAlternativeBranchEventIndex(index);
    Store.Set(e);
}

// the events whose next event is this one
List<int> _Predecessors(List<int> events, int id)
{
    var result = List<int>.Create();
    foreach (var e in events)
    {
        if (Store.NextOf(e) == id)
            result.Add(e);
    }
    return result;
}

bool _AllowAsFirst(EventType type)
{
    return EventDescriptions.Get(type) is EventDescription d && d.AllowAsFirst;
}

bool _AllowOnlyAsFirst(EventType type)
{
    return EventDescriptions.Get(type) is EventDescription d && d.AllowOnlyAsFirst;
}

void RemoveEvent(List<int> eventList, List<int> events, int index, bool alwaysDisconnect, Optional<EditedFile> file)
{
    int id = events[index];
    var e = Store.Get(id);
    int listIndex = eventList.IndexOf(id);

    if (listIndex != -1)
    {
        // (the original also offers this without a successor, and the chain then starts with nothing)
        bool canMoveSuccessorToBegin = e.HasNext();

        if (e.HasNext() && !_AllowAsFirst(Store.TypeOf(e.Next)))
            canMoveSuccessorToBegin = false;

        Console.WriteLine("The event starts an event chain. What do you want to do?");
        var options = List<string>.Create();
        options.Add("Abort");
        options.Add("Remove chain (keep events)");
        options.Add("Remove chain (and events)");
        if (canMoveSuccessorToBegin)
            options.Add("Make the successor the new chain start");
        var option = ReadOption(0, options.ToArray());

        switch (option)
        {
            case 0:
                Console.WriteLine("Aborted");
                Console.WriteLine();
                return;
            case 1:
                eventList.Remove(id);
                if (file is EditedFile f)
                    RemoveEventChain(eventList, events, f, listIndex);
                Console.WriteLine("Chain removed. Events kept.");
                Console.WriteLine();
                return;
            case 2:
            {
                Console.WriteLine("Are you sure to remove the whole chain?");
                option = ReadOption(0, ["No", "Yes"]);
                if (option == 0)
                {
                    Console.WriteLine("Aborted");
                    Console.WriteLine();
                    return;
                }
                eventList.Remove(id);
                var eventsToRemove = List<int>.Create();
                int eventToRemove = id;
                // (the original runs forever if the chain is a loop)
                while (eventToRemove >= 0 && !eventsToRemove.Contains(eventToRemove))
                {
                    eventsToRemove.Add(eventToRemove);
                    eventToRemove = Store.NextOf(eventToRemove);
                }
                for (var i = eventsToRemove.Count() - 1; i >= 0; i -= 1)
                {
                    int removeIndex = events.IndexOf(eventsToRemove[i]);
                    if (removeIndex >= 0) // (the original fails for events that are not in the list)
                        RemoveEvent(eventList, events, removeIndex, true, null);
                }
                if (file is EditedFile f)
                    RemoveEventChain(eventList, events, f, listIndex);
                Console.WriteLine("Chain removed. Events too.");
                Console.WriteLine();
                return;
            }
            case 3:
                eventList[listIndex] = e.Next;
                Console.WriteLine("Chain now starts with successor.");
                Console.WriteLine();
                return;
        }
    }

    var prevs = _Predecessors(events, id);
    var branches = _BranchingTo(events, (uint32)index);

    if (prevs.Count() != 0 || branches.Count() != 0)
    {
        int successor = -1;

        if (e.HasNext())
        {
            if (alwaysDisconnect)
            {
                successor = -1;
            }
            else
            {
                Console.WriteLine("The event has a successor. How to handle it?");
                var option = ReadOption(0, ["Connect predecessors with successor", "Disconnect"]);
                successor = option == 0 ? e.Next : -1;
            }
        }

        uint32 successorIndex = successor < 0 ? 0xffff : (uint32)events.IndexOf(successor);

        if (successorIndex != 0xffff && successorIndex > (uint32)index)
            successorIndex -= 1;

        foreach (var prev in prevs)
            Store.SetNext(prev, successor);
        foreach (var branch in branches)
            _SetBranch(branch, successorIndex);
    }

    Store.SetNext(id, -1);

    for (var i = index + 1; i < events.Count(); i += 1)
    {
        foreach (var branch in _BranchingTo(events, (uint32)i))
            _SetBranch(branch, unchecked(Store.Get(branch).AlternativeBranchEventIndex() - 1));
    }

    events.Remove(id);

    UnsavedChanges = true;
}

void CopyEvent(List<int> eventList, List<int> events, int index)
{
    int id = events[index];
    bool keepNext = false;

    if (Store.Get(id).HasNext())
    {
        Console.WriteLine();
        Console.WriteLine("You want to create a connection to the original successor?");
        var option = ReadOption(0, ["No, thanks", "Yes, please"]);

        if (option == 1)
            keepNext = true;
    }

    int clone = Store.Add(Store.Get(id).Clone(keepNext));

    events.Add(clone);

    int listIndex = eventList.IndexOf(id);

    if (listIndex != -1)
    {
        Console.WriteLine();
        Console.WriteLine("The event is the start of an event chain.");
        Console.WriteLine("Do you want to create a new event chain for the copied event?");
        var option = ReadOption(0, ["No, thanks", "Yes, please"]);

        if (option == 1)
            eventList.Add(clone);
    }

    Console.WriteLine();
    Console.WriteLine("Event successfully created.");
    Console.WriteLine();

    UnsavedChanges = true;
}

void CopyEventRange(List<int> eventList, List<int> events, int startIndex)
{
    ListEvents(events, startIndex, Indexer.Count, new List<int>(), true, true);
    Console.WriteLine();

    Console.Write("Copy count: ");
    int copyCount = ReadInt() is int count ? count : 0;

    if (copyCount < 1)
    {
        Console.WriteLine("Aborting");
        Console.WriteLine();
        return;
    }

    if (startIndex + copyCount > events.Count())
    {
        Console.WriteLine("Count is too large. Aborting");
        Console.WriteLine();
        return;
    }

    int lastEvent = events[startIndex + copyCount - 1];

    Console.WriteLine($"Copy all events from {startIndex:x2} to {events.IndexOf(lastEvent):x2}, ok?");
    var answer = ReadOption(0, ["No", "Yes"]);

    if (answer != 1)
    {
        Console.WriteLine();
        return;
    }

    bool keepConnections = false;
    bool anyNext = false;
    foreach (var id in events)
    {
        if (Store.Get(id).HasNext())
            anyNext = true;
    }

    if (anyNext)
    {
        Console.WriteLine();
        Console.WriteLine("You want to keep connections between the copied events?");
        var option = ReadOption(0, ["No, thanks", "Yes, please"]);

        if (option == 1)
            keepConnections = true;
    }

    var eventsToCopy = List<int>.Create();
    for (var i = startIndex; i < events.Count() && events[i] != lastEvent; i += 1)
        eventsToCopy.Add(events[i]);
    eventsToCopy.Add(lastEvent);
    var copies = List<int>.Create();
    foreach (var id in eventsToCopy)
        copies.Add(Store.Add(Store.Get(id).Clone(false)));

    if (keepConnections)
    {
        for (var i = 0; i < eventsToCopy.Count(); i += 1)
        {
            int next = Store.NextOf(eventsToCopy[i]);
            if (next >= 0)
            {
                int copied = eventsToCopy.IndexOf(next);
                Store.SetNext(copies[i], copied >= 0 ? copies[copied] : next);
            }
        }
    }

    var sourceEventChainStarts = List<int>.Create();
    foreach (var id in eventsToCopy)
    {
        if (eventList.Contains(id))
            sourceEventChainStarts.Add(id);
    }

    if (sourceEventChainStarts.Count() != 0)
    {
        Console.WriteLine();
        Console.WriteLine("At least one event is the start of an event chain.");
        Console.WriteLine("Do you want to create new event chain for the copied events?");
        var option = ReadOption(0, ["No, thanks", "Yes, please"]);

        if (option == 1)
        {
            foreach (var sourceEventChainStart in sourceEventChainStarts)
                eventList.Add(copies[eventsToCopy.IndexOf(sourceEventChainStart)]);
        }
    }

    foreach (var copy in copies)
        events.Add(copy);

    Console.WriteLine();
    Console.WriteLine($"{copyCount} events were successfully copied.");
    Console.WriteLine();

    UnsavedChanges = true;
}

// a branch of a copied chain that is copied as well: the copied branch event and the start of the branch
struct _BranchStart
{
    int Root;
    int Start;
}

// the state of CopyEventChain (the local functions of the original are its methods)
struct _ChainCopier
{
    List<int> Events;
    // the event index of an original event -> its copy
    Dictionary<int, int> Processed;
    Queue<_BranchStart> BranchStarts;

    // the copy of the event (made once)
    int Clone(int id)
    {
        int index = Events.IndexOf(id);
        if (Processed.TryGet(index) is int existing)
            return existing;
        int clone = Store.Add(Store.Get(id).Clone(false));
        Processed[index] = clone;
        return clone;
    }

    // remembers the branch of a branching event to copy it later
    void EnqueueBranch(int clone, int original)
    {
        var e = Store.Get(original);
        // (the original fails for an index outside of the events)
        if (e.IsBranchEvent() && e.AlternativeBranchEventIndex() != 0xffff && e.AlternativeBranchEventIndex() < (uint32)Events.Count())
            BranchStarts.Enqueue(_BranchStart { Root = clone, Start = Events[(int)e.AlternativeBranchEventIndex()] });
    }

    // copies a branch (once) and returns the event index of its copy
    uint32 CopyBranch(int branchStart)
    {
        int index = Events.IndexOf(branchStart);

        if (Processed.TryGet(index) is int existing)
            return (uint32)Events.IndexOf(existing);

        int clone = Store.Add(Store.Get(branchStart).Clone(false));
        Processed[index] = clone;
        int ev = Store.NextOf(branchStart);

        var branchIndex = (uint32)Events.Count();
        Events.Add(clone);

        EnqueueBranch(clone, branchStart);

        while (ev >= 0)
        {
            index = Events.IndexOf(ev);

            if (Processed.TryGet(index) is int evClone)
            {
                Store.SetNext(clone, evClone);
                break;
            }

            int parent = clone;
            clone = Clone(ev);

            EnqueueBranch(clone, ev);

            ev = Store.NextOf(ev);

            Store.SetNext(parent, clone);
            Events.Add(clone);
        }

        return branchIndex;
    }
}

void CopyEventChain(List<int> eventList, List<int> events, int index)
{
    Console.WriteLine();
    Console.WriteLine("You want to copy the whole chain or only some part of it?");
    var option = ReadOption(0, ["Whole chain (copy branches)", "Whole chain (keep branches)", "Only a part (cut off the rest)",
                                "Only a part (keep the rest from original)"]);
    Optional<int> copyCount = null;

    if (option > 1)
    {
        ShowChain(eventList, events, index);
        Console.WriteLine();

        Console.Write("Copy count: ");
        copyCount = ReadInt();

        if ((copyCount is int c ? c : 0) < 1)
        {
            Console.WriteLine("Aborting");
            Console.WriteLine();
            return;
        }
    }

    bool copyBranches = option == 0;
    var copier = _ChainCopier { Events = events, Processed = Dictionary<int, int>.Create(), BranchStarts = Queue<_BranchStart>.Create() };

    int e = eventList[index];
    int clone = Store.Add(Store.Get(e).Clone(false));
    copier.Processed[events.IndexOf(e)] = clone;

    if (copyBranches)
        copier.EnqueueBranch(clone, e);

    e = Store.NextOf(e);

    eventList.Add(clone);
    events.Add(clone);

    int numCopies = 1;

    while (e >= 0 && (!(copyCount is int limit) || numCopies < limit))
    {
        int eventIndex = events.IndexOf(e);

        if (copier.Processed.TryGet(eventIndex) is int evClone)
        {
            Store.SetNext(clone, evClone);
            break;
        }

        int parent = clone;
        clone = copier.Clone(e);

        if (copyBranches)
            copier.EnqueueBranch(clone, e);

        e = Store.NextOf(e);

        Store.SetNext(parent, clone);
        events.Add(clone);
        numCopies += 1;
    }

    if (option == 3)
        Store.SetNext(clone, e);

    while (copier.BranchStarts.Count() > 0)
    {
        var branch = copier.BranchStarts.Dequeue();
        var copiedBranchIndex = copier.CopyBranch(branch.Start);
        _SetBranch(branch.Root, copiedBranchIndex);
    }

    Console.WriteLine();
    Console.WriteLine("Chain successfully created.");
    Console.WriteLine();

    UnsavedChanges = true;
}

void ReplaceEvent(List<int> eventList, List<int> events, int eventOld, int eventNew)
{
    int eventListIndex = eventList.IndexOf(eventOld);
    int eventsIndex = events.IndexOf(eventOld);

    if (eventListIndex != -1)
        eventList[eventListIndex] = eventNew;

    events[eventsIndex] = eventNew;

    foreach (var id in events)
    {
        if (Store.NextOf(id) == eventOld)
            Store.SetNext(id, eventNew);
    }
}

void ShowConnections(List<int> eventList, List<int> events, int index)
{
    int id = events[index];
    int listIndex = eventList.IndexOf(id);
    var prevEvents = List<int>.Create();
    foreach (var prev in _Predecessors(events, id))
        prevEvents.Add(events.IndexOf(prev));

    Console.WriteLine();

    int next = Store.NextOf(id);

    if (listIndex == -1 && prevEvents.Count() == 0 && next < 0)
    {
        Console.WriteLine("This event has no connections.");
    }
    else
    {
        Console.WriteLine("Connections:");

        if (listIndex != -1)
            Console.WriteLine($"Start of event chain {listIndex + 1:x2}");

        if (next >= 0)
            Console.WriteLine($"Following event is {events.IndexOf(next):x2}");

        foreach (var prevEvent in prevEvents)
            Console.WriteLine($"Event {prevEvent:x2} is a predecessor");
    }

    Console.WriteLine();
}

void DisconnectEvent(List<int> eventList, List<int> events, int index)
{
    int id = events[index];
    int listIndex = eventList.IndexOf(id);

    if (listIndex != -1)
    {
        Console.WriteLine("The event starts an event chain. Do you want to remove this chain?");
        int option = ReadOption(0, ["No", "Yes"]);

        if (option != 0)
        {
            Console.WriteLine("Event chain removed. Note that event chain indices inside maps can't be adjusted automatically.");
            eventList.RemoveAt(listIndex);
        }
    }

    var prevs = _Predecessors(events, id);
    var conds = _BranchingToOfType(events, (uint32)index, EventType.Condition);
    var doors = _BranchingToOfType(events, (uint32)index, EventType.Door);
    var chests = _BranchingToOfType(events, (uint32)index, EventType.Chest);
    var dices = _BranchingToOfType(events, (uint32)index, EventType.Dice100Roll);
    var decisions = _BranchingToOfType(events, (uint32)index, EventType.Decision);
    var pconds = _BranchingToOfType(events, (uint32)index, EventType.PartyMemberCondition);

    foreach (var prev in prevs)
        Store.SetNext(prev, -1);

    Store.SetNext(id, -1);

    if (Store.Get(id).IsBranchEvent())
        _SetBranch(id, 0xffff);

    if (conds.Count() != 0 || doors.Count() != 0 || chests.Count() != 0 || dices.Count() != 0 || pconds.Count() != 0)
    {
        Console.WriteLine("There are events that chain the event through a failed condition. Should these also be disconnected?");
        ListEvents(conds, 0, Indexer.EventIndex, events, false, true);
        ListEvents(doors, 0, Indexer.EventIndex, events, true, true);
        ListEvents(chests, 0, Indexer.EventIndex, events, true, true);
        ListEvents(dices, 0, Indexer.EventIndex, events, true, true);
        ListEvents(decisions, 0, Indexer.EventIndex, events, true, true);
        ListEvents(pconds, 0, Indexer.EventIndex, events, true, false);
        int option = ReadOption(0, ["No", "Yes"]);

        if (option == 1)
        {
            foreach (var branch in [..conds.ToArray(), ..doors.ToArray(), ..chests.ToArray(), ..dices.ToArray(), ..decisions.ToArray(), ..pconds.ToArray()])
                _SetBranch(branch, 0xffff);
        }
    }

    UnsavedChanges = true;
    Console.WriteLine("Successfully disconnected the event.");
    Console.WriteLine();
}

void ConnectEvent(List<int> eventList, List<int> events, int index)
{
    int id = events[index];
    var type = Store.TypeOf(id);

    if (_AllowOnlyAsFirst(type))
    {
        Console.WriteLine($"Event of type {type} must be first in a chain and cannot be connected.");
        Console.WriteLine();
        return;
    }

    Console.WriteLine();
    Console.Write("Which event to connect to: ");
    var targetIndex = ReadInt(true);
    int target = targetIndex is int t ? t : -1;

    // (the original fails for an index outside of the events)
    if (target < 0 || target >= events.Count())
    {
        Console.WriteLine("Invalid event index");
        Console.WriteLine();
        return;
    }

    int targetEvent = events[target];

    if (Store.NextOf(targetEvent) >= 0)
    {
        Console.WriteLine("The target event already has a connected event.");
        Console.WriteLine("What do you want to do with it?");
        var option = ReadOption(0, ["Remove its connection.", Store.NextOf(id) < 0 ? "Use it as the new successor." : "Replace the current successor by it."]);

        if (option != 0)
            Store.SetNext(id, Store.NextOf(targetEvent));
    }

    UnsavedChanges = true;
    Store.SetNext(targetEvent, id);

    if (!IsPartOfChain(eventList, targetEvent))
    {
        Console.WriteLine("The target event is not part of a chain. Do you want to create a");
        Console.WriteLine("new event chain with the target event as a start?");

        if (ReadOption(0, ["No, thanks", "Yes, please"]) == 1)
            eventList.Add(targetEvent);
    }

    Console.WriteLine("Successfully connected both events.");
    Console.WriteLine();
}

bool IsPartOfChain(List<int> eventList, int id)
{
    if (eventList.Contains(id))
        return true;

    foreach (var startEvent in eventList)
    {
        var checkedEvents = HashSet<int>.Create();
        int ev = startEvent;

        while (ev >= 0)
        {
            if (!checkedEvents.Add(ev))
                break;

            if (ev == id)
                return true;

            ev = Store.NextOf(ev);
        }
    }

    return false;
}

void ReorderEvents(List<int> eventList, List<int> events)
{
    var reorderer = _Reorderer { Events = events, IdMapping = Dictionary<uint32, uint32>.Create(), Order = List<uint32>.Create(), Visited = HashSet<int>.Create() };

    foreach (var chain in eventList)
        reorderer.ProcessEvents(chain);

    // also the events that have no connection
    foreach (var ev in events)
        reorderer.ProcessEvents(ev);

    foreach (var id in events)
    {
        var e = Store.Get(id);
        if (!e.IsBranchEvent())
            continue;
        uint32 alternative = e.AlternativeBranchEventIndex();
        if (alternative != 0xffff && reorderer.IdMapping.TryGet(alternative) is uint32 mapped)
            _SetBranch(id, mapped);
    }

    var reordered = List<int>.Create();
    foreach (var i in reorderer.Order)
        reordered.Add(events[(int)i]);

    events.Clear();
    foreach (var id in reordered)
        events.Add(id);
    UnsavedChanges = true;
}

// the state of ReorderEvents (the local functions of the original are its methods)
struct _Reorderer
{
    List<int> Events;
    // old event index -> new event index
    Dictionary<uint32, uint32> IdMapping;
    // the old event indices in their new order (the keys of IdMapping in the order they were added)
    List<uint32> Order;
    HashSet<int> Visited;

    void ProcessEvents(int startEvent)
    {
        var branches = Queue<int>.Create();
        int e = startEvent;

        while (e >= 0)
            e = _Visit(e, branches);

        while (branches.Count() != 0)
        {
            e = branches.Dequeue();
            ProcessEvents(e);
        }
    }

    int _Visit(int ev, Queue<int> branches)
    {
        int eventIndex = Events.IndexOf(ev);

        if (!Visited.Add(eventIndex))
            return -1;

        IdMapping[(uint32)eventIndex] = (uint32)Order.Count();
        Order.Add((uint32)eventIndex);

        var e = Store.Get(ev);
        if (e.IsBranchEvent())
        {
            uint32 alternative = e.AlternativeBranchEventIndex();
            // (the original fails for an index outside of the events)
            if (alternative != 0xffff && alternative < (uint32)Events.Count())
                branches.Enqueue(Events[(int)alternative]);
        }

        return e.Next;
    }
}

void Graph(List<int> eventList, List<int> events, int index)
{
    var flowChart = FlowChart.Create(eventList[index], events);
    flowChart.Print();
    Console.WriteLine();
}
