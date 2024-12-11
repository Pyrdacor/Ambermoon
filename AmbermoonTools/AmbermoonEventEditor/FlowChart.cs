using Ambermoon.Data;
using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;

namespace AmbermoonEventEditor
{
    internal class FlowChart
    {
        private const string EndMarker = "<< END >>";

        private record Node
        {
            public int Index { get; init; }
            public string Name { get; init; }
            public Node Next { get; set; }
        }

        private record Branch : Node
        {
            public Node BranchTarget { get; set; }
        }

        private class NodeComparer : IEqualityComparer<Node>
        {
            public bool Equals(Node x, Node y)
            {
                return x.Index.Equals(y.Index);
            }

            public int GetHashCode([DisallowNull] Node obj)
            {
                return obj.Index.GetHashCode();
            }
        }

        private static readonly NodeComparer nodeComparer = new NodeComparer();
        private readonly List<Node> nodes = new List<Node>();
        private readonly OrderedDictionary<Node, Node> BackReferenceSources = new(nodeComparer); // drawn on the left
        private readonly OrderedDictionary<Node, Node> BranchReferenceSources = new(nodeComparer); // drawn on the right
        private readonly OrderedDictionary<Node, List<Node>> BackReferenceTargets = new(nodeComparer); // drawn on the left
        private readonly OrderedDictionary<Node, List<Node>> BranchReferenceTargets = new(nodeComparer); // drawn on the right
        private readonly List<bool> BranchRefForward = new List<bool>();

        private static bool IsBranchEvent(Event @event)
        {
            return @event is ConditionEvent ||
                   @event is Dice100RollEvent ||
                   @event is DecisionEvent ||
                   @event is DoorEvent ||
                   @event is ChestEvent ||
				   @event is PartyMemberConditionEvent;
        }

        public FlowChart(Event startEvent, List<Event> events)
        {
            bool processBranchActions = false;
            var processedEvents = new List<Event>();
            var branchProcessActions = new List<Action>();
            ProcessEvent(startEvent);

            Node FindNodeByEvent(Event @event)
            {
                int index = processedEvents.IndexOf(@event);

                if (index != -1)
                    return nodes[index];

                return null;
            }

            Node ProcessEvent(Event @event)
            {
                if (processedEvents.Contains(@event))
                    return nodes[processedEvents.IndexOf(@event)];

                Node node;

                void CommitNode()
                {
                    processedEvents.Add(@event);
                    nodes.Add(node);
                    if (@event.Next != null)
                    {
                        Node targetNode = FindNodeByEvent(@event.Next);

                        if (targetNode != null)
                        {
                            // if the next event already exists, it is a back reference!
                            if (!BackReferenceTargets.TryAdd(targetNode, new List<Node> { node }))
                                BackReferenceTargets[targetNode].Add(node);
                            BackReferenceSources.Add(node, targetNode);
                        }

                        node.Next = targetNode ?? ProcessEvent(@event.Next);
                    }
                }

                Event EventFromIndex(uint index)
                {
                    return index == 0xffff ? null : events[(int)index];
                }

                if (IsBranchEvent(@event))
                {
                    var branchEvent = @event switch
                    {
                        ConditionEvent c => EventFromIndex(c.ContinueIfFalseWithMapEventIndex),
                        Dice100RollEvent d => EventFromIndex(d.ContinueIfFalseWithMapEventIndex),
                        DecisionEvent d => EventFromIndex(d.NoEventIndex),
                        DoorEvent d => EventFromIndex(d.UnlockFailedEventIndex),
                        ChestEvent c => EventFromIndex(c.UnlockFailedEventIndex),
						PartyMemberConditionEvent c => EventFromIndex(c.ContinueIfFalseWithMapEventIndex),

						_ => null
                    };

                    if (branchEvent == null)
                    {
                        node = new Node
                        {
                            Index = nodes.Count,
                            Name = $"{events.IndexOf(@event):x2} {@event}"
                        };
                        CommitNode();
                    }
                    else
                    {
                        var branch = new Branch
                        {
                            Index = nodes.Count,
                            Name = $"{events.IndexOf(@event):x2} {@event}"
                        };
                        node = branch;
                        CommitNode();

                        Node targetNode = FindNodeByEvent(branchEvent);

                        var process = () =>
                        {
                            bool forward = targetNode == null || targetNode.Index > branch.Index;
                            targetNode = branch.BranchTarget = targetNode ?? ProcessEvent(branchEvent);
                            var foo = FindNodeByEvent(branchEvent);

                            if (!BranchReferenceTargets.TryAdd(targetNode, new List<Node> { node }))
                                BranchReferenceTargets[targetNode].Add(node);
                            BranchReferenceSources.Add(node, targetNode);
                            BranchRefForward.Add(forward);
                        };

                        if (processBranchActions)
                        {
                            process();
                        }
                        else
                        {
                            branchProcessActions.Add(process);
                        }
                    }
                }
                else
                {
                    node = new Node
                    {
                        Index = nodes.Count,
                        Name = $"{events.IndexOf(@event):x2} {@event}"
                    };
                    CommitNode();
                }

                return node;
            }

            processBranchActions = true;

            foreach (var branchProcessAction in ((IEnumerable<Action>)branchProcessActions).Reverse())
                branchProcessAction();
        }

        enum RefDrawType
        {
            None,
            Target,
            Source,
            Between
        }

        class Range
        {
            private readonly int index1;
            private readonly int index2;
            private readonly Node node1;
            private readonly Node node2;

            public Range(Node x, Node y)
            {
                node1 = x.Index < y.Index ? x : y;
                node2 = x.Index >= y.Index ? x : y;
                index1 = Math.Min(x.Index, y.Index);
                index2 = Math.Max(x.Index, y.Index);
            }

            public bool IsWithin(int index) => index > index1 && index < index2;

            public Node GetLowIndexNode() => node1;

            public Node GetHighIndexNode() => node2;

            public int LowIndex => index1;

            public int HighIndex => index2;
        }

        public void Print(Action<string> printLine)
        {
            printLine ??= Console.WriteLine;

            string identation = new string(' ', BackReferenceTargets.Count);
            int branchSpace = BranchReferenceTargets.Count;
            int maxLabelSize = 78 - identation.Length - branchSpace;
            var backRefSpans = BackReferenceSources.Select(r => new Range(r.Key, r.Value));
            var branchRefSpans = BranchReferenceSources.Select(r => new Range(r.Key, r.Value)).ToList();

            if (maxLabelSize < 10)
                throw new Exception("Space is not large enough to show the graph.");

            void WriteLine(string text, int index, int backRefIndex = -1, int branchRefIndex = -1,
                RefDrawType backRefDrawType = RefDrawType.None, RefDrawType branchRefDrawType = RefDrawType.None)
            {
                string backRef = identation;

                if (backRefIndex != -1)
                {
                    switch (backRefDrawType)
                    {
                        case RefDrawType.None:
                        default:
                            break;
                        case RefDrawType.Target:
                            backRef = backRef[0..backRefIndex] + new string('-', backRef.Length - backRefIndex - 1) + ">";
                            break;
                        case RefDrawType.Source:
                            backRef = backRef[0..backRefIndex] + new string('-', backRef.Length - backRefIndex);
                            break;
                        case RefDrawType.Between:
                            backRef = backRef[0..backRefIndex] + "|" + (backRefIndex == backRef.Length - 1 ? "" : backRef[(backRefIndex + 1)..]);
                            break;
                    }
                }

                bool endMarker = text == EndMarker;

                if (text.Length > maxLabelSize)
                    text = text.Substring(0, maxLabelSize - 3) + "...";
                else if (text.Length < maxLabelSize)
                    text = text.PadRight(maxLabelSize);

                string branchRef = "";

                if (branchRefIndex != -1)
                {
                    switch (branchRefDrawType)
                    {
                        case RefDrawType.None:
                        default:
                            break;
                        case RefDrawType.Target:
                            branchRef = "<" + new string('-', branchRefIndex);
                            break;
                        case RefDrawType.Source:
                            branchRef = new string('-', branchRefIndex + 1);
                            break;
                        case RefDrawType.Between:
                            branchRef = new string(' ', branchRefIndex) + "|";
                            break;
                    }
                }

                foreach (var backRefSpan in backRefSpans.Where(s => s.IsWithin(index)))
                {
                    var sourceNode = backRefSpan.GetHighIndexNode();
                    int otherBackRefIndex = BackReferenceSources.IndexOf(sourceNode);

                    if (backRef[otherBackRefIndex] != '>')
                        backRef = backRef[0..otherBackRefIndex] + "|" + (otherBackRefIndex == backRef.Length - 1 ? "" : backRef[(otherBackRefIndex + 1)..]);
                }

                bool ContainsIndex(Range r)
                {
                    if (r.IsWithin(index))
                        return true;

                    if (endMarker && index == r.LowIndex)
                        return true;

                    return false;
                }

                foreach (var branchRefSpan in branchRefSpans.Where(s => ContainsIndex(s)))
                {
                    int refIndex = branchRefSpans.IndexOf(branchRefSpan);
                    var sourceNode = BranchRefForward[refIndex] ? branchRefSpan.GetLowIndexNode() : branchRefSpan.GetHighIndexNode();
                    int otherBranchRefIndex = BranchReferenceSources.IndexOf(sourceNode);

                    if (otherBranchRefIndex < branchRef.Length)
                    {
                        if (branchRef[otherBranchRefIndex] != '<')
                            branchRef = branchRef[0..otherBranchRefIndex] + "|" + (otherBranchRefIndex == branchRef.Length - 1 ? "" : branchRef[(otherBranchRefIndex + 1)..]);
                    }
                    else
                        branchRef = branchRef + new string(' ', otherBranchRefIndex - branchRef.Length) + "|";
                  }

                printLine(backRef + text + branchRef);
            }

            foreach (var node in nodes)
            {
                RefDrawType backRefDrawType = RefDrawType.None;
                RefDrawType branchRefDrawType = RefDrawType.None;
                int backRefIndex = BackReferenceSources.IndexOf(node);
                if (backRefIndex != -1)
                    backRefDrawType = RefDrawType.Source;
                else
                {
                    backRefIndex = BackReferenceTargets.IndexOf(node);
                    if (backRefIndex != -1)
                        backRefDrawType = RefDrawType.Target;
                }
                int branchRefIndex = BranchReferenceSources.IndexOf(node);
                if (branchRefIndex != -1)
                    branchRefDrawType = RefDrawType.Source;
                else
                {
                    branchRefIndex = BranchReferenceTargets.IndexOf(node);
                    if (branchRefIndex != -1)
                        branchRefDrawType = RefDrawType.Target;
                }
                WriteLine(node.Name, node.Index, backRefIndex, branchRefIndex, backRefDrawType, branchRefDrawType);
                if (node.Next == null)
                    WriteLine(EndMarker, node.Index);
            }
        }
    }
}
