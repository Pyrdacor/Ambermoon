// The 'graph' command: an event chain as a flow chart in text, with the references back (on the left) and the
// branches (on the right) drawn as lines.
namespace AmbermoonEventEditor;

using System;
using Ambermoon;
using Ambermoon.Data;

const string _EndMarker = "<< END >>";

// a node of the chart: an event
struct _Node
{
    int Index;
    string Name;
    int Next; // node index, -1: none
}

// an insertion-ordered map from nodes to nodes (OrderedDictionary<Node, ...> of the original, by node index)
struct _NodeMap
{
    List<int> Keys;
    Dictionary<int, int> Values; // the first value (the original's lists of values are not drawn)

    static _NodeMap Create()
    {
        return _NodeMap { Keys = List<int>.Create(), Values = Dictionary<int, int>.Create() };
    }

    int Count()
    {
        return Keys.Count();
    }

    // the position of the key in the order (-1: not there)
    int IndexOf(int key)
    {
        return Keys.IndexOf(key);
    }

    // adds the key if it is new (TryAdd)
    bool TryAdd(int key, int value)
    {
        if (Values.ContainsKey(key))
            return false;
        Keys.Add(key);
        Values[key] = value;
        return true;
    }
}

// a branch that is processed later (a deferred action of the original): the branch node and its event, and the
// target node that was known when it was found (-1: none)
struct _PendingBranch
{
    int Node;
    int BranchEvent;
    int TargetNode;
}

// the range between two nodes of a reference
struct _Range
{
    int Low;  // node index
    int High; // node index

    static _Range Create(int x, int y)
    {
        return _Range { Low = x < y ? x : y, High = x >= y ? x : y };
    }

    bool IsWithin(int index)
    {
        return index > Low && index < High;
    }
}

enum _RefDrawType : uint8
{
    None,
    Target,
    Source,
    Between
}

struct FlowChart
{
    List<_Node> _nodes;
    List<int> _processedEvents; // event ids, in the order of their nodes
    List<int> _events;
    _NodeMap _backReferenceSources;   // drawn on the left
    _NodeMap _branchReferenceSources; // drawn on the right
    _NodeMap _backReferenceTargets;   // drawn on the left
    _NodeMap _branchReferenceTargets; // drawn on the right
    List<bool> _branchRefForward;
    List<int> _branchSourceOrder;     // the sources of the branch references in their order (with their targets)
    List<int> _branchTargetOrder;
    bool _processBranchActions;
    List<_PendingBranch> _branchProcessActions;

    static FlowChart Create(int startEvent, List<int> events)
    {
        var chart = FlowChart {
            _nodes = List<_Node>.Create(), _processedEvents = List<int>.Create(), _events = events,
            _backReferenceSources = _NodeMap.Create(), _branchReferenceSources = _NodeMap.Create(),
            _backReferenceTargets = _NodeMap.Create(), _branchReferenceTargets = _NodeMap.Create(),
            _branchRefForward = List<bool>.Create(), _branchSourceOrder = List<int>.Create(), _branchTargetOrder = List<int>.Create(),
            _branchProcessActions = List<_PendingBranch>.Create()
        };
        chart._ProcessEvent(startEvent);

        chart._processBranchActions = true;
        for (var i = chart._branchProcessActions.Count() - 1; i >= 0; i -= 1)
            chart._ProcessBranch(chart._branchProcessActions[i]);
        return chart;
    }

    static bool _IsBranchEvent(Event e)
    {
        return e.Type == EventType.Condition || e.Type == EventType.Dice100Roll || e.Type == EventType.Decision ||
               e.Type == EventType.Door || e.Type == EventType.Chest || e.Type == EventType.PartyMemberCondition;
    }

    int _FindNodeByEvent(int id)
    {
        int index = _processedEvents.IndexOf(id);
        return index;
    }

    // the node of the event (made, with the nodes behind it, if it is new)
    int _ProcessEvent(int id)
    {
        int existing = _processedEvents.IndexOf(id);
        if (existing != -1)
            return existing;

        var e = Store.Get(id);
        string name = $"{_events.IndexOf(id):x2} {e.ToString()}";
        int node = _nodes.Count();
        _nodes.Add(_Node { Index = node, Name = name, Next = -1 });
        _processedEvents.Add(id);

        // the next event
        if (e.HasNext())
        {
            int targetNode = _FindNodeByEvent(e.Next);

            if (targetNode != -1)
            {
                // the next event exists already: a back reference
                _backReferenceTargets.TryAdd(targetNode, node);
                _backReferenceSources.TryAdd(node, targetNode);
            }

            int nextNode = targetNode != -1 ? targetNode : _ProcessEvent(e.Next);
            var n = _nodes[node];
            n.Next = nextNode;
            _nodes[node] = n;
        }

        if (_IsBranchEvent(e))
        {
            uint32 branchIndex = e.AlternativeBranchEventIndex();
            // (the original fails for an index outside of the events)
            if (branchIndex != 0xffff && branchIndex < (uint32)_events.Count())
            {
                int branchEvent = _events[(int)branchIndex];
                var pending = _PendingBranch { Node = node, BranchEvent = branchEvent, TargetNode = _FindNodeByEvent(branchEvent) };
                if (_processBranchActions)
                    _ProcessBranch(pending);
                else
                    _branchProcessActions.Add(pending);
            }
        }

        return node;
    }

    void _ProcessBranch(_PendingBranch pending)
    {
        int targetNode = pending.TargetNode;
        bool forward = targetNode == -1 || targetNode > pending.Node;
        if (targetNode == -1)
            targetNode = _ProcessEvent(pending.BranchEvent);

        _branchReferenceTargets.TryAdd(targetNode, pending.Node);
        _branchReferenceSources.TryAdd(pending.Node, targetNode);
        _branchSourceOrder.Add(pending.Node);
        _branchTargetOrder.Add(targetNode);
        _branchRefForward.Add(forward);
    }

    void Print()
    {
        int backCount = _backReferenceSources.Count() > _backReferenceTargets.Count() ? _backReferenceSources.Count() : _backReferenceTargets.Count();
        string identation = " ".Repeat(backCount);
        int branchSpace = _branchReferenceTargets.Count();
        int maxLabelSize = 78 - identation.Length - branchSpace;

        if (maxLabelSize < 10)
        {
            // (the original ends with an exception here)
            Console.WriteLine("Space is not large enough to show the graph.");
            return;
        }

        foreach (var node in _nodes)
        {
            var backRefDrawType = _RefDrawType.None;
            var branchRefDrawType = _RefDrawType.None;
            int backRefIndex = _backReferenceSources.IndexOf(node.Index);
            if (backRefIndex != -1)
            {
                backRefDrawType = _RefDrawType.Source;
            }
            else
            {
                backRefIndex = _backReferenceTargets.IndexOf(node.Index);
                if (backRefIndex != -1)
                    backRefDrawType = _RefDrawType.Target;
            }
            int branchRefIndex = _branchReferenceSources.IndexOf(node.Index);
            if (branchRefIndex != -1)
            {
                branchRefDrawType = _RefDrawType.Source;
            }
            else
            {
                branchRefIndex = _branchReferenceTargets.IndexOf(node.Index);
                if (branchRefIndex != -1)
                    branchRefDrawType = _RefDrawType.Target;
            }
            _WriteLine(identation, maxLabelSize, node.Name, node.Index, backRefIndex, branchRefIndex, backRefDrawType, branchRefDrawType);
            if (node.Next == -1)
                _WriteLine(identation, maxLabelSize, _EndMarker, node.Index, -1, -1, _RefDrawType.None, _RefDrawType.None);
        }
    }

    static string _Replace(string text, int index, string replacement)
    {
        return text[..index] + replacement + (index == text.Length - 1 ? "" : text[(index + 1)..].ToString());
    }

    void _WriteLine(string identation, int maxLabelSize, string text, int index, int backRefIndex, int branchRefIndex,
                    _RefDrawType backRefDrawType, _RefDrawType branchRefDrawType)
    {
        string backRef = identation;

        if (backRefIndex != -1)
        {
            switch (backRefDrawType)
            {
                case _RefDrawType.Target:
                    backRef = backRef[..backRefIndex] + "-".Repeat(backRef.Length - backRefIndex - 1) + ">";
                    break;
                case _RefDrawType.Source:
                    backRef = backRef[..backRefIndex] + "-".Repeat(backRef.Length - backRefIndex);
                    break;
                case _RefDrawType.Between:
                    backRef = _Replace(backRef, backRefIndex, "|");
                    break;
                default:
                    break;
            }
        }

        bool endMarker = text == _EndMarker;

        if (text.Length > maxLabelSize)
            text = text.Substring(0, maxLabelSize - 3) + "...";
        else if (text.Length < maxLabelSize)
            text = text.PadRight(maxLabelSize);

        string branchRef = "";

        if (branchRefIndex != -1)
        {
            switch (branchRefDrawType)
            {
                case _RefDrawType.Target:
                    branchRef = "<" + "-".Repeat(branchRefIndex);
                    break;
                case _RefDrawType.Source:
                    branchRef = "-".Repeat(branchRefIndex + 1);
                    break;
                case _RefDrawType.Between:
                    branchRef = " ".Repeat(branchRefIndex) + "|";
                    break;
                default:
                    break;
            }
        }

        // the back references that pass this line
        for (var i = 0; i < _backReferenceSources.Count(); i += 1)
        {
            int source = _backReferenceSources.Keys[i];
            var span = _Range.Create(source, _backReferenceSources.Values[source]);
            if (!span.IsWithin(index))
                continue;
            int otherBackRefIndex = _backReferenceSources.IndexOf(span.High);
            if (otherBackRefIndex >= 0 && backRef[otherBackRefIndex] != '>')
                backRef = _Replace(backRef, otherBackRefIndex, "|");
        }

        // the branches that pass this line (and those that start at a node whose end marker this is)
        for (var refIndex = 0; refIndex < _branchSourceOrder.Count(); refIndex += 1)
        {
            var span = _Range.Create(_branchSourceOrder[refIndex], _branchTargetOrder[refIndex]);
            if (!(span.IsWithin(index) || (endMarker && index == span.Low)))
                continue;
            int sourceNode = _branchRefForward[refIndex] ? span.Low : span.High;
            int otherBranchRefIndex = _branchReferenceSources.IndexOf(sourceNode);
            if (otherBranchRefIndex < 0)
                continue; // (the original fails here)

            if (otherBranchRefIndex < branchRef.Length)
            {
                if (branchRef[otherBranchRefIndex] != '<')
                    branchRef = _Replace(branchRef, otherBranchRefIndex, "|");
            }
            else
            {
                branchRef = branchRef + " ".Repeat(otherBranchRefIndex - branchRef.Length) + "|";
            }
        }

        Console.WriteLine(backRef + text + branchRef);
    }
}
