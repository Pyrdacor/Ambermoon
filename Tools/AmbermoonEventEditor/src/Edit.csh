namespace AmbermoonEventEditor;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Descriptions;
using Ambermoon.Data.Legacy.Serialization;

// lists the possible values of an enum value ("Possible values:")
void _ShowPossibleValues(ValueDescription value)
{
    if (value.Kind != DescriptionKind.Enum)
        return;
    Console.WriteLine("Possible values:");
    var allowed = value.AllowedValues();
    var names = value.AllowedValueNames();
    for (var i = 0; i < allowed.Length; i += 1)
    {
        string name = i < names.Length ? names[i] : "";
        if (value.Flags)
            Console.WriteLine($" 0x{allowed[i]:x4}: {name}");
        else
            Console.WriteLine($" {allowed[i],3}: {name}");
    }
}

// whether the value takes two bytes of the event data
bool _IsWordValue(ValueDescription value)
{
    return value.Type == ValueType.Word || value.Type == ValueType.Flag16 || value.Type == ValueType.EventIndex;
}

// the event from its 12 bytes (type, data, next index), without an id
Event _ParseEvent(uint8[] eventData)
{
    var reader = DataReader.Create(eventData);
    return EventReader.ParseEvent(ref reader);
}

void EditEvent(List<int> eventList, List<int> events, bool map, int index)
{
    int id = events[index];
    var e = Store.Get(id);
    Console.WriteLine($"Do you want to change the event type? Current is {e.Type}. All data will be lost!");
    var option = ReadOption(0, ["No, keep it", "Yes, change please"]);

    if (option == 1)
    {
        UnsavedChanges = true;
        var tempEventList = List<int>.Create();
        var tempEvents = List<int>.Create();
        AddEvent(tempEventList, tempEvents, map, index, true);
        // (the original fails when no event was added)
        if (tempEvents.Count() != 0)
            ReplaceEvent(eventList, events, id, tempEvents[0]);
        return;
    }

    var writer = new DataWriter();
    EventWriter.WriteEventData(ref writer, e);
    var eventData = new uint8[12];
    eventData[0] = (uint8)e.Type;
    int next = e.Next;
    var nextIndex = (uint16)(next < 0 ? 0xffff : events.IndexOf(next));
    eventData[10] = (uint8)((nextIndex >> 8) & 0xff);
    eventData[11] = (uint8)(nextIndex & 0xff);
    Array.Copy(writer.ToArray(), 0, eventData, 1, 9);
    int dataIndex = 1;

    if (EventDescriptions.Get(e.Type) is not EventDescription eventDescription)
    {
        Console.WriteLine($"Events of type {e.Type} can not be edited.");
        Console.WriteLine();
        return;
    }

    foreach (var slot in eventDescription.Slots)
    {
        var value = EventDescriptions.Value(slot);
        if (value.Hidden || (value.Condition != null && !value.Condition(e)))
        {
            dataIndex += _IsWordValue(value) ? 2 : 1;
            continue;
        }

        _ShowPossibleValues(value);

        if (value.DisplayNameMapping != null)
        {
            value.SetDisplayName(value.DisplayNameMapping(e, value));
            EventDescriptions.Store(value);
        }

        PropertyValue currentValue;
        if (value.Kind == DescriptionKind.TenBits || value.Kind == DescriptionKind.TwelveBits)
            currentValue = PropertyValue.Of((uint64)value.ReadBits(eventData));
        else
            currentValue = GetProperty(e, value.Name);

        Console.Write($"> {value.DisplayName()} ({value.AsString(currentValue)}): ");
        var input = ReadInt(value.ShowAsHex);

        if (!(input is int number) || number < 0 || number > 0xffff || !value.Check((uint16)number))
            dataIndex += _IsWordValue(value) ? 2 : 1;
        else
            value.Write(eventData, ref dataIndex, (uint16)number);
    }

    // the event again from the changed data (a new event)
    var changed = _ParseEvent(eventData);
    changed.Next = next;
    int newEvent = Store.Add(changed);
    events[index] = newEvent;

    UnsavedChanges = true;

    int eventListIndex = eventList.IndexOf(id);

    if (eventListIndex != -1)
        eventList[eventListIndex] = newEvent;

    foreach (var ev in events)
    {
        if (Store.NextOf(ev) == id)
            Store.SetNext(ev, newEvent);
    }

    Console.WriteLine("Event was changed successfully.");
    Console.WriteLine();
}

void AddEvent(List<int> eventList, List<int> events, bool map, int insertIndex, bool fromEdit)
{
    var availableEvents = List<EventType>.Create();
    foreach (var type in EventDescriptions.Types())
    {
        if (EventDescriptions.Get(type) is EventDescription d && ((map && d.AllowMaps) || (!map && d.AllowNPCs)))
            availableEvents.Add(type);
    }

    availableEvents.Remove(EventType.Invalid);

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
        Console.WriteLine($"{(int)eventType:D2}: {eventType}");
    Console.WriteLine();
    Console.Write("Which event to add: ");
    var typeInput = ReadInt();
    bool valid = false;
    if (typeInput is int requested)
    {
        foreach (var eventType in availableEvents)
        {
            if ((int)eventType == requested)
                valid = true;
        }
    }
    if (!valid)
    {
        Console.WriteLine("Invalid event type");
        Console.WriteLine();
        return;
    }

    var newType = (EventType)(typeInput is int chosen ? chosen : 0);
    var eventDescription = EventDescriptions.Get(newType) is EventDescription description ? description : new EventDescription();

    bool newChain = false;
    Optional<int> connectTo = null;
    bool prepend = false;

    if (eventDescription.AllowOnlyAsFirst)
    {
        Console.WriteLine("This event type must be the first in a chain so a new event chain will be added.");
        if (eventList.Count() == 64)
        {
            Console.WriteLine("There is no free event chain slot. Aborting.");
            Console.WriteLine();
            return;
        }
        newChain = true;
    }
    else if (fromEdit)
    {
        newChain = false;
    }
    else if (eventDescription.AllowAsFirst)
    {
        Console.WriteLine();
        Console.WriteLine("How should the new event be connected?");
        var option = ReadOption(0, ["Disconnected event", "New event chain", "Connect to event", "Prepend to event"]);

        if (option == 1)
        {
            newChain = true;
        }
        else if (option == 2) // append to event
        {
            Console.WriteLine();
            Console.WriteLine("Connect to which event");
            ListEvents(events, 0);
            var index = ReadInt(true);

            if (!(index is int i) || i < 0 || i >= events.Count())
                Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
            else
                connectTo = i;
        }
        else if (option == 3) // prepend to event
        {
            Console.WriteLine();
            Console.WriteLine("Prepend to which event");
            var filteredEvents = List<int>.Create();
            foreach (var ev in events)
            {
                if (!_AllowOnlyAsFirst(Store.TypeOf(ev)))
                    filteredEvents.Add(ev);
            }
            ListEvents(filteredEvents, 0, Indexer.EventIndex, events, false, false);
            var index = ReadInt(true);

            if (!(index is int i) || !_AnyWithIndex(filteredEvents, events, i))
            {
                Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
            }
            else
            {
                connectTo = i;
                prepend = true;
            }
        }
    }
    else if (eventList.Count() == 0)
    {
        newChain = false;
    }
    else
    {
        Console.WriteLine();
        Console.WriteLine("How should the new event be connected?");

        var noChainStartEvents = List<int>.Create();
        foreach (var ev in events)
        {
            if (!eventList.Contains(ev))
                noChainStartEvents.Add(ev);
        }

        var option = noChainStartEvents.Count() != 0
            ? ReadOption(0, ["Disconnected event", "Connect to event", "Prepend to event"])
            : ReadOption(0, ["Disconnected event", "Connect to event"]);

        if (option == 1) // append to event
        {
            Console.WriteLine();
            Console.WriteLine("Connect to which event");
            ListEvents(events, 0);
            var index = ReadInt(true);

            if (!(index is int i) || i < 0 || i >= events.Count())
                Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
            else
                connectTo = i;
        }
        else if (noChainStartEvents.Count() != 0 && option == 2) // prepend to event
        {
            Console.WriteLine();
            Console.WriteLine("Prepend to which event");
            ListEvents(noChainStartEvents, 0, Indexer.EventIndex, events, false, false);
            var index = ReadInt(true);

            if (!(index is int i) || !_AnyWithIndex(noChainStartEvents, events, i))
            {
                Console.WriteLine("Invalid event index. Creating a disconnected event instead.");
            }
            else
            {
                connectTo = i;
                prepend = true;
            }
        }
    }

    var eventData = new uint8[12];
    eventData[0] = (uint8)newType;
    eventData[10] = 0xff;
    eventData[11] = 0xff;
    int dataIndex = 1;

    foreach (var slot in eventDescription.Slots)
    {
        var ev = _ParseEvent(eventData);
        var value = EventDescriptions.Value(slot);

        if (value.Hidden || (value.Condition != null && !value.Condition(ev)))
        {
            value.Write(eventData, ref dataIndex, value.DefaultValue);
            continue;
        }

        if (value.DisplayNameMapping != null)
        {
            value.SetDisplayName(value.DisplayNameMapping(ev, value));
            EventDescriptions.Store(value);
        }

        if (value.Required)
        {
            _ShowPossibleValues(value);

            Console.Write($"> {value.DisplayName()}: ");
            var input = ReadInt(value.ShowAsHex);

            if (input is not int number)
            {
                Console.WriteLine("No value given. Aborting.");
                Console.WriteLine();
                return;
            }
            if (number < 0 || number > 0xffff || !value.Check((uint16)number))
            {
                Console.WriteLine("Invalid value given. Aborting.");
                Console.WriteLine();
                return;
            }

            value.Write(eventData, ref dataIndex, (uint16)number);
        }
        else
        {
            _ShowPossibleValues(value);

            Console.Write($"> {value.DisplayName()} ({value.DefaultValueText()}): ");
            int number = ReadInt(value.ShowAsHex) is int given ? given : value.DefaultValue;

            if (number < 0 || number > 0xffff || !value.Check((uint16)number))
            {
                Console.WriteLine($"Invalid value given. Using default: {value.DefaultValueText()}");
                number = value.DefaultValue;
            }

            value.Write(eventData, ref dataIndex, (uint16)number);
        }
    }

    // the event from the filled data
    int newEvent = Store.Add(_ParseEvent(eventData));

    if (insertIndex == -1 || insertIndex >= events.Count())
        events.Add(newEvent);
    else
        events.Insert(insertIndex, newEvent);

    UnsavedChanges = true;

    if (newChain)
    {
        eventList.Add(newEvent);
    }
    else if (connectTo is int target)
    {
        if (prepend)
        {
            int nextEvent = events[target];
            Store.SetNext(newEvent, nextEvent);

            int chainIndex = eventList.IndexOf(nextEvent);

            if (chainIndex != -1)
                eventList[chainIndex] = newEvent;
        }
        else // append
        {
            int prev = events[target];
            Store.SetNext(newEvent, Store.NextOf(prev));
            Store.SetNext(prev, newEvent);
        }
    }

    Console.WriteLine($"Event {(fromEdit ? "changed" : "added")} successfully.");
    Console.WriteLine();
}

// whether one of the events has the event index
bool _AnyWithIndex(List<int> list, List<int> events, int index)
{
    foreach (var id in list)
    {
        if (events.IndexOf(id) == index)
            return true;
    }
    return false;
}
