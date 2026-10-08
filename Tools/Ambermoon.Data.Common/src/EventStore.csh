namespace Ambermoon.Data;

using System;

/// The events by their ids: what references between events (and lists of events) refer to. A handle to shared
/// storage, like a List: copies see the same events.
struct EventStore
{
    List<Event> _events;

    /// An empty store.
    static EventStore Create()
    {
        return EventStore { _events = List<Event>.Create() };
    }

    /// Adds the event (a new object of the original) and returns its id (which is also set in the stored event).
    int Add(Event e)
    {
        e.Id = _events.Count();
        _events.Add(e);
        return e.Id;
    }

    /// The event with the id.
    Event Get(int id)
    {
        return _events[id];
    }

    /// Stores the changed event (under its id).
    void Set(Event e)
    {
        _events[e.Id] = e;
    }

    /// The type of the event with the id.
    EventType TypeOf(int id)
    {
        return _events.Get(id).Type;
    }

    /// The id of the next event of the event with the id (-1: none).
    int NextOf(int id)
    {
        return _events.Get(id).Next;
    }

    /// Sets the next event of the event with the id (-1: none).
    void SetNext(int id, int next)
    {
        var e = _events[id];
        e.Next = next;
        _events[id] = e;
    }
}
