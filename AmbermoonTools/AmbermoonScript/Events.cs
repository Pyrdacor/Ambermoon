using Ambermoon;
using Ambermoon.Data;
using New = AmbermoonScript.EventHelper;

namespace AmbermoonScript;

public interface IScriptEventType
{
    static abstract ScriptDescription GetDescription();

    static abstract EventType GetEventType();

    static abstract bool MatchesEvent(Event @event);

    static abstract IScriptEvent FromEvent(Event @event);

    static abstract IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants);
}

public record ScriptEventSequence(uint Index, ICollection<IScriptEvent> Events, List<(IBranchScriptEvent BranchEvent, string AlternativeJumpLabel)> AlternativeJumpLabels)
{
    public const string JumpTo = "JumpTo";
    public const string End = "End";

    public delegate IScriptEvent Factory(Dictionary<string, string> parameterValues, Dictionary<string, long> constants);

    private static readonly Dictionary<string, Factory> eventPool = [];
    private static readonly Dictionary<EventType, IList<(Func<Event, bool> Match, Func<Event, IScriptEvent> Factory)>> scriptEventsByEventType = [];

    static ScriptEventSequence()
    {
        static void AddEvent<T>() where T : IScriptEventType
        {
            var description = T.GetDescription();

            eventPool.Add(description.Name.ToLower(), T.Parse);

            var eventType = T.GetEventType();
            
            if (!scriptEventsByEventType.TryGetValue(eventType, out var scriptEvents))
            {
                scriptEvents = [];
                scriptEventsByEventType[eventType] = scriptEvents;
            }

            var matcher = T.MatchesEvent;
            var factory = T.FromEvent;

            scriptEvents.Add((matcher, factory));
        }

        // Register all event types
        // # Teleports and outro
        AddEvent<MapChangeScriptEvent>();
        AddEvent<TeleportScriptEvent>();
        AddEvent<WindGateScriptEvent>();
        AddEvent<ClimbScriptEvent>();
        AddEvent<FallScriptEvent>();
        AddEvent<OutroScriptEvent>();
        // # Doors and chests
        AddEvent<DoorScriptEvent>();
        AddEvent<ChestScriptEvent>();
        AddEvent<TreasureScriptEvent>();
        // # Spinners and traps
        AddEvent<SpinnerScriptEvent>();
        AddEvent<TrapScriptEvent>();
        // TODO ...
    }

    public static IScriptEvent GetScriptEvent(Event @event)
    {
        var possibleEvents = scriptEventsByEventType[@event.Type];

        if (possibleEvents.Count == 1)
            return possibleEvents[0].Factory(@event);

        return possibleEvents.First(pe => pe.Match(@event)).Factory(@event);
    }

    public static bool TryParse(ScriptParser parser, Dictionary<string, long> constants, out ScriptEventSequence? sequence)
    {
        sequence = null;

        string? line;

        while ((line = parser.PeekNextLine()) != null)
        {
            string originalLine = line;

            line = line.Trim();

            if (line.Length == 0 ||
                line.StartsWith(ScriptParser.CommentPrefix) ||
                line.StartsWith(ScriptParser.HeaderCommentPrefix))
            {
                parser.ConsumePeekedLine();
                continue;
            }

            if (!line.StartsWith(ScriptParser.HeaderPrefix))
                return false;

            string header = line[ScriptParser.HeaderPrefix.Length..];

            if (!header.StartsWith(ScriptParser.SequenceShortName, StringComparison.OrdinalIgnoreCase))
                return false;

            int length = ScriptParser.SequenceShortName.Length;

            if (header.StartsWith(ScriptParser.SequenceName, StringComparison.OrdinalIgnoreCase))
            {
                length = ScriptParser.SequenceName.Length;
                header = header[ScriptParser.SequenceName.Length..];
            }
            else
                header = header[ScriptParser.SequenceShortName.Length..];

            if (!header.StartsWith(' '))
            {
                int offset = originalLine.IndexOf(ScriptParser.SequenceShortName, StringComparison.OrdinalIgnoreCase);
                parser.TrackParserWarning($"Expected a space after {originalLine[offset..(offset + length)]}.",
                    offset + length);
                return false;
            }

            header = header.Trim();

            if (!uint.TryParse(header, out var index))
            {
                int offset = originalLine.IndexOf(ScriptParser.SequenceShortName, StringComparison.OrdinalIgnoreCase) + length + 1;
                parser.TrackParserWarning($"Invalid sequence index: {header}", offset);
                return false;
            }

            parser.EnterContext(ParseContext.ScriptLine);
            parser.ConsumePeekedLine();

            List<IScriptEvent> events = [];
            List<(IBranchScriptEvent BranchEvent, string AlternativeJumpLabel)> alternativeJumpLabels = [];

            while (true)
            {
                if (!ScriptDescription.TryParse(parser, out var name, out var parameters, out bool error, events.Count == 0 ? null : events[^1]))
                {
                    if (error)
                        return false;

                    parser.EnterContext(ParseContext.SequenceHeader); // parse next header or end
                    break;
                }

                if (name!.StartsWith(ScriptParser.BranchPrefix))
                {
                    if (parameters.TryGetValue(ScriptParser.JumpTargetParam, out var jumpTarget))
                        alternativeJumpLabels.Add(((events[^1] as IBranchScriptEvent)!, jumpTarget));

                    parser.EnterContext(ParseContext.ScriptLine);

                    continue;
                }

                if (!eventPool.TryGetValue(name!.ToLower(), out var factory))
                {
                    parser.TrackParserWarning($"Unrecognized event name: {name}");
                    return false;
                }

                var scriptEvent = factory(parameters, constants);

                events.Add(scriptEvent);

                if (scriptEvent is IBranchScriptEvent)
                    parser.EnterContext(ParseContext.ScriptLineAfterBranch);
                else
                    parser.EnterContext(ParseContext.ScriptLine);
            }

            sequence = new(index, events, alternativeJumpLabels);

            return true;
        }

        return false;
    }
}

public interface IScriptEvent
{
    EventType EventType { get; }

    Event ToEvent();
    
    bool Print(Event @event, StreamWriter writer);
    
}

public interface IBranchScriptEvent : IScriptEvent
{
    uint? AlternativeBranchIndex { get; }

    string BranchExpressionString { get; }
}

file class EnumParameterBuilder<T> where T : struct, Enum
{
    public record EnumParameterBuilderWithMappings(string Name, bool Optional, T? DefaultValue)
    {
        private readonly Dictionary<string, T> fromStringMappings = [];
        private readonly Dictionary<T, string> toStringMappings = [];

        public EnumParameterBuilderWithMappings Map(T value, string name)
        {
            fromStringMappings.Add(name, value);
            toStringMappings.Add(value, name);

            return this;
        }

        public EnumParameterBuilderWithMappings AsIs(params T[] values)
        {
            foreach (var value in values)
            {
                var name = value.ToString();

                fromStringMappings.Add(name, value);
                toStringMappings.Add(value, name);
            }

            return this;
        }

        public EnumParameter<T> Build()
        {
            return new(Name, Optional, DefaultValue, [.. toStringMappings.Keys])
            {
                ValueToString = (value) => toStringMappings[value],
                StringToValue = (str) => fromStringMappings[str],
            };
        }
    }

    public EnumParameterBuilderWithMappings Start(string name, bool optional, T? defaultValue)
        => new(name, optional, defaultValue);
}

file static class EventHelper
{
    public static Parameter Arg(string name, int min = 0, int max = byte.MaxValue)
            => new(name, false, min, max);
    public static Parameter Opt(string name, int defaultValue, int min = 0, int max = byte.MaxValue)
        => new(name, true, min, max, defaultValue);
    public static BooleanParameter BooleanArg(string name) => new(name, false);
    public static BooleanParameter BooleanOpt(string name, bool defaultValue) => new(name, true, defaultValue);
    public static EnumParameter<T> Enum<T>(string name, params T[] allowedValues)
        where T : struct, Enum
        => new(name, false, allowedValues?.Length is > 0 ? allowedValues[0] : null, allowedValues!);
    public static EnumParameter<T> OptEnum<T>(string name, T defaultValue, params T[] allowedValues)
        where T : struct, Enum
        => new(name, true, defaultValue, allowedValues);
    public static EnumParameter<T> BuildEnum<T>(string name, Action<EnumParameterBuilder<T>.EnumParameterBuilderWithMappings> builder)
        where T : struct, Enum
    {
        var b = new EnumParameterBuilder<T>().Start(name, false, null);
        builder(b);
        return b.Build();
    }
    public static EnumParameter<T> BuildOptEnum<T>(string name, T defaultValue, Action<EnumParameterBuilder<T>.EnumParameterBuilderWithMappings> builder)
        where T : struct, Enum
    {
        var b = new EnumParameterBuilder<T>().Start(name, true, defaultValue);
        builder(b);
        return b.Build();
    }
}

public abstract class ScriptEvent : IScriptEvent
{
    public const string None = "none";
    public const string True = "true";
    public const string False = "false";

    protected Event? Event { get; set; }

    public EventType EventType { get; }

    protected ScriptEvent(EventType eventType)
    {
        EventType = eventType;
    }

    public Event ToEvent() => Event ?? throw new InvalidOperationException("No event data parsed or loaded");

    protected delegate void SetParameter(IParameter parameter, string value, bool fromDefault);

    protected static void Parse(ScriptDescription description,
        Dictionary<string, string> parameterValues,
        SetParameter setParameter)
    {
        foreach (var parameter in description.Parameters)
        {
            string lowerName = parameter.Name.ToLower();

            if (parameterValues.TryGetValue(lowerName, out var value))
            {
                parameterValues.Remove(lowerName);
                setParameter(parameter, value, false);
            }
            else if (parameter.Optional)
            {
                setParameter(parameter, parameter.DefaultValue!, true);
            }
            else
            {
                throw new InvalidDataException($"Parameter {parameter.Name} is missing and not optional.");
            }
        }

        if (parameterValues.Count != 0)
        {
            throw new InvalidDataException($"Parameters {string.Join(", ", parameterValues.Keys)} are not known for event {description.Name}.");
        }
    }

    protected static T EnsureLimits<T>(T value, T min, T max) where T : IComparable<T>
    {
        if (value.CompareTo(min) < 0)
            throw new ArgumentOutOfRangeException(nameof(value), $"Value is too small: {value}");
        if (value.CompareTo(max) > 0)
            throw new ArgumentOutOfRangeException(nameof(value), $"Value is too large: {value}");
        return value;
    }

    protected static T EnsureLimits<T>(T value, T max) where T : IComparable<T>
    {
        if (value.CompareTo(max) > 0)
            throw new ArgumentOutOfRangeException(nameof(value), $"Value is too large: {value}");
        return value;
    }

    protected static T EnsureLimits<T>(T value, IParameter parameter) where T : IComparable<T>
    {
        if (parameter is Parameter p)
            return EnsureLimits<T>(value, (T)Convert.ChangeType(p.MinValue, typeof(T)), (T)Convert.ChangeType(p.MaxValue, typeof(T)));
        return value;
    }

    protected static T EnsureValidValues<T>(T value, IParameter parameter) where T : struct, Enum
    {
        if (parameter is EnumParameter<T> p && p.AllowedValues.Length != 0 && !p.AllowedValues.Contains(value))
            throw new ArgumentOutOfRangeException(nameof(value), $"Enum value is invalid. Must be one of: {string.Join(", ", p.AllowedValues.Select(v => v.ToString()))}");
        return value;
    }

    protected static bool ParseBool(string value, Dictionary<string, long> constants)
    {
        var lowerValue = value.ToLower();

        if (lowerValue == True)
            return true;

        if (lowerValue == False)
            return false;

        if (constants.TryGetValue(value, out var booleanValue))
            return booleanValue != 0;

        throw new FormatException($"Invalid value for boolean: {value}");
    }

    protected static byte ParseByte(string value, Dictionary<string, long> constants, byte? noneValue = null)
    {
        if (value.ToLower() == None)
            return noneValue ?? throw new FormatException("Value must not be 'None'.");

        if (constants.TryGetValue(value, out var byteValue))
            return (byte)byteValue;

        return byte.Parse(value);
    }

    protected static sbyte ParseSByte(string value, Dictionary<string, long> constants)
    {
        if (constants.TryGetValue(value, out var sbyteValue))
            return (sbyte)sbyteValue;

        return sbyte.Parse(value);
    }

    protected static ushort ParseWord(string value, Dictionary<string, long> constants, ushort? noneValue = null)
    {
        if (value.ToLower() == None)
            return noneValue ?? throw new FormatException("Value must not be 'None'.");

        if (constants.TryGetValue(value, out var wordValue))
            return (ushort)wordValue;

        return ushort.Parse(value);
    }

    protected static short ParseShort(string value, Dictionary<string, long> constants)
    {
        if (constants.TryGetValue(value, out var shortValue))
            return (short)shortValue;

        return short.Parse(value);
    }

    protected static int ParseInt(string value, Dictionary<string, long> constants)
    {
        if (constants.TryGetValue(value, out var intValue))
            return (int)intValue;

        return int.Parse(value);
    }

    protected static uint ParseUInt(string value, Dictionary<string, long> constants)
    {
        if (constants.TryGetValue(value, out var uintValue))
            return (uint)uintValue;

        return uint.Parse(value);
    }

    protected static void Print(StreamWriter streamWriter, string name, params (IParameter Parameter, string? Value)[] parameterValues)
    {
        var args = string.Join(", ", parameterValues.Where(p => p.Value != null).Select(p => $"{p.Parameter.Name} = {p.Value}"));

        streamWriter.WriteLine($"{name}({args})");
    }

    public abstract bool Print(Event @event, StreamWriter writer);
}

public abstract class BranchScriptEvent(EventType eventType) : ScriptEvent(eventType), IBranchScriptEvent
{
    public abstract uint? AlternativeBranchIndex { get; }
    public abstract string BranchExpressionString { get; }
}


#region Teleports and outro

internal abstract class TeleportBaseScriptEvent() : ScriptEvent(EventType.Teleport)
{
    protected static readonly Parameter mapIndex = New.Arg("mapIndex", 0, 1023);
    protected static readonly Parameter x = New.Arg("x", 0, 200);
    protected static readonly Parameter y = New.Arg("y", 0, 200);
    protected static readonly EnumParameter<CharacterDirection> teleportDir = New.BuildEnum<CharacterDirection>("dir",
        build => build
            .AsIs(CharacterDirection.Up,
                CharacterDirection.Right,
                CharacterDirection.Down,
                CharacterDirection.Left)
            .Map(CharacterDirection.Keep, "Keep")
    );
}

internal class MapChangeScriptEvent : TeleportBaseScriptEvent, IScriptEventType
{
    static readonly ScriptDescription description = new("MapChange", mapIndex, x, y, teleportDir);

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new MapChangeScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.MapChange;
    }
    
    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent teleportEvent)
        {
            Print(writer, description.Name,
                (mapIndex, teleportEvent.MapIndex.ToString()),
                (x, teleportEvent.X.ToString()),
                (y, teleportEvent.Y.ToString()),
                (teleportDir, teleportEvent.Direction == CharacterDirection.Keep ? "Keep" : teleportEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.MapChange,
            Unknown2 = [0, 0]
        };
        var mapChangeScriptEvent = new MapChangeScriptEvent()
        {
            Event = teleportEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == mapIndex.Name)
                teleportEvent.MapIndex = EnsureLimits(ParseWord(value, constants), parameter);
            else if (name == x.Name)
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == y.Name)
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == teleportDir.Name)
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return mapChangeScriptEvent;
    }
}

internal class TeleportScriptEvent : TeleportBaseScriptEvent, IScriptEventType
{
    static readonly ScriptDescription description = new("Teleport", x, y, teleportDir);

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new TeleportScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.Teleporter;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent teleportEvent)
        {
            Print(writer, description.Name,
                (x, teleportEvent.X.ToString()),
                (y, teleportEvent.Y.ToString()),
                (teleportDir, teleportEvent.Direction == CharacterDirection.Keep ? "Keep" : teleportEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.Teleporter,
            MapIndex = 0,
            Unknown2 = [0, 0]
        };
        var teleportScriptEvent = new TeleportScriptEvent()
        {
            Event = teleportEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == "x")
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == "y")
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == "dir")
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return teleportScriptEvent;
    }
}

internal class WindGateScriptEvent : TeleportBaseScriptEvent, IScriptEventType
{
    static readonly ScriptDescription description = new("WindGate", mapIndex, x, y, teleportDir);

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new WindGateScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.WindGate;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent teleportEvent)
        {
            Print(writer, description.Name,
                (mapIndex, teleportEvent.MapIndex.ToString()),
                (x, teleportEvent.X.ToString()),
                (y, teleportEvent.Y.ToString()),
                (teleportDir, teleportEvent.Direction == CharacterDirection.Keep ? "Keep" : teleportEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.WindGate,
            Unknown2 = [0, 0]
        };
        var windGateScriptEvent = new WindGateScriptEvent()
        {
            Event = teleportEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == mapIndex.Name)
                teleportEvent.MapIndex = EnsureLimits(ParseWord(value, constants), parameter);
            else if (name == x.Name)
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == y.Name)
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == teleportDir.Name)
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return windGateScriptEvent;
    }
}

internal class ClimbScriptEvent : TeleportBaseScriptEvent, IScriptEventType
{
    static readonly ScriptDescription description = new("Climb", mapIndex, x, y, teleportDir);

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new ClimbScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.Climbing;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent teleportEvent)
        {
            Print(writer, description.Name,
                (mapIndex, teleportEvent.MapIndex.ToString()),
                (x, teleportEvent.X.ToString()),
                (y, teleportEvent.Y.ToString()),
                (teleportDir, teleportEvent.Direction == CharacterDirection.Keep ? "Keep" : teleportEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.Climbing,
            Unknown2 = [0, 0]
        };
        var climbScriptEvent = new ClimbScriptEvent()
        {
            Event = teleportEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == mapIndex.Name)
                teleportEvent.MapIndex = EnsureLimits(ParseWord(value, constants), parameter);
            else if (name == x.Name)
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == y.Name)
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == teleportDir.Name)
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return climbScriptEvent;
    }
}

internal class FallScriptEvent : TeleportBaseScriptEvent, IScriptEventType
{
    static readonly ScriptDescription description = new("Fall", mapIndex, x, y, teleportDir);

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new FallScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.Falling;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent teleportEvent)
        {
            Print(writer, description.Name,
                (mapIndex, teleportEvent.MapIndex.ToString()),
                (x, teleportEvent.X.ToString()),
                (y, teleportEvent.Y.ToString()),
                (teleportDir, teleportEvent.Direction == CharacterDirection.Keep ? "Keep" : teleportEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.Falling,
            Unknown2 = [0, 0]
        };
        var fallScriptEvent = new FallScriptEvent()
        {
            Event = teleportEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == mapIndex.Name)
                teleportEvent.MapIndex = EnsureLimits(ParseWord(value, constants), parameter);
            else if (name == x.Name)
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == y.Name)
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == teleportDir.Name)
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return fallScriptEvent;
    }
}

internal class OutroScriptEvent() : ScriptEvent(EventType.Teleport), IScriptEventType
{
    static readonly ScriptDescription description = new("Outro");

    public static EventType GetEventType() => EventType.Teleport;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new OutroScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is TeleportEvent teleportEvent && teleportEvent.Transition == TeleportEvent.TransitionType.Outro;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TeleportEvent)
        {
            Print(writer, description.Name);

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var teleportEvent = new TeleportEvent()
        {
            Type = EventType.Teleport,
            Transition = TeleportEvent.TransitionType.Outro,
            MapIndex = 0,
            X = 0,
            Y = 0,
            Direction = CharacterDirection.Up,
            Unknown2 = [0, 0]
        };
        
        return new OutroScriptEvent()
        {
            Event = teleportEvent
        };
    }
}

#endregion


#region Doors and chests

internal abstract class LockedBaseScriptEvent(EventType eventType) : BranchScriptEvent(eventType)
{
    protected static readonly Parameter keyIndex = New.Arg("KeyIndex", 0, 1023);
    protected static readonly Parameter unlockTextIndex = New.Opt("UnlockTextIndex", 0xff);
    protected static readonly Parameter textIndex = New.Opt("TextIndex", 0xff);
}

internal class DoorScriptEvent() : LockedBaseScriptEvent(EventType.Door), IScriptEventType
{
    static readonly Parameter doorIndex = New.Arg("DoorIndex");
    protected static readonly Parameter lockpickChanceReduction = New.Opt("LockpickChanceReduction", 100, 1, 100);

    static readonly ScriptDescription description = new("Door", doorIndex, keyIndex, unlockTextIndex,
        textIndex, lockpickChanceReduction);

    public override uint? AlternativeBranchIndex
    {
        get
        {
            var alternativeBranchIndex = (Event as DoorEvent)?.UnlockFailedEventIndex;

            return alternativeBranchIndex == null || alternativeBranchIndex == 0xffff ? null : alternativeBranchIndex.Value;
        }
    }

    public override string BranchExpressionString => "TrapTriggered";

    public static EventType GetEventType() => EventType.Door;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new DoorScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event.Type == EventType.Door;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is DoorEvent doorEvent)
        {
            bool hideLockpickingChanceReduction =
                (doorEvent.KeyIndex == 0 && doorEvent.LockpickingChanceReduction == 1) ||
                (doorEvent.KeyIndex != 0 && doorEvent.LockpickingChanceReduction == 100);

            Print(writer, description.Name,
                (doorIndex, doorEvent.DoorIndex.ToString()),
                (keyIndex, doorEvent.KeyIndex == 0 ? None : doorEvent.KeyIndex.ToString()),
                (unlockTextIndex, doorEvent.UnlockTextIndex == 0xff ? None : doorEvent.UnlockTextIndex.ToString()),
                (textIndex, doorEvent.TextIndex == 0xff ? None : doorEvent.TextIndex.ToString()),
                (lockpickChanceReduction, hideLockpickingChanceReduction ? null : doorEvent.LockpickingChanceReduction.ToString()));

            if (doorEvent.UnlockFailedEventIndex != 0xffff)
                writer.WriteLine($"-> {BranchExpressionString}: {ScriptEventSequence.JumpTo}(event{doorEvent.UnlockFailedEventIndex})");

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        bool hasKey = parameterValues.TryGetValue(keyIndex.Name.ToLower(), out var key) && key != "0" && key != None;

        var doorEvent = new DoorEvent()
        {
            Type = EventType.Door,
            TextIndex = 0xff,
            UnlockTextIndex = 0xff,
            LockpickingChanceReduction = hasKey ? 100u : 1u,
            UnlockFailedEventIndex = 0xffff,
        };
        var doorScriptEvent = new DoorScriptEvent()
        {
            Event = doorEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == doorIndex.Name)
                doorEvent.DoorIndex = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == keyIndex.Name)
                doorEvent.KeyIndex = EnsureLimits(ParseWord(value, constants, noneValue: 0), parameter);
            else if (name == unlockTextIndex.Name)
                doorEvent.UnlockTextIndex = EnsureLimits(ParseByte(value, constants, noneValue: 0xff), parameter);
            else if (name == textIndex.Name)
                doorEvent.TextIndex = EnsureLimits(ParseByte(value, constants, noneValue: 0xff), parameter);
            else if (name == lockpickChanceReduction.Name)
                doorEvent.LockpickingChanceReduction = EnsureLimits(ParseByte(value, constants, noneValue: 0), parameter);
        });

        return doorScriptEvent;
    }
}

internal class ChestScriptEvent() : LockedBaseScriptEvent(EventType.Chest), IScriptEventType
{
    static readonly Parameter chestIndex = New.Arg("ChestIndex", 1, 256 + 128);
    static readonly BooleanParameter alwaysOpen = New.BooleanOpt("AlwaysOpen", false);
    protected static readonly Parameter lockpickChanceReduction = New.Opt("LockpickChanceReduction", 0, 0, 100);

    static readonly ScriptDescription description = new("Chest", chestIndex, keyIndex,
        textIndex, alwaysOpen, lockpickChanceReduction);

    public override uint? AlternativeBranchIndex
    {
        get
        {
            var alternativeBranchIndex = (Event as DoorEvent)?.UnlockFailedEventIndex;

            return alternativeBranchIndex == null || alternativeBranchIndex == 0xffff ? null : alternativeBranchIndex.Value;
        }
    }

    public override string BranchExpressionString => "TrapTriggered";

    public static EventType GetEventType() => EventType.Chest;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new ChestScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is ChestEvent chestEvent && !chestEvent.Flags.HasFlag(ChestEvent.ChestFlags.JunkPile);
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is ChestEvent chestEvent)
        {
            bool extendedChest = chestEvent.Flags.HasFlag(ChestEvent.ChestFlags.ExtendedChest);
            uint realChestIndex = 1 + (extendedChest ? 256 + chestEvent.ChestIndex : chestEvent.ChestIndex);
            bool hideLockpickingChanceReduction =
                chestEvent.LockpickingChanceReduction == 0 ||
                (chestEvent.KeyIndex == 0 && chestEvent.LockpickingChanceReduction == 1) ||
                (chestEvent.KeyIndex != 0 && chestEvent.LockpickingChanceReduction == 100);
            bool hideKey = chestEvent.LockpickingChanceReduction == 0;
            bool hideAlwaysOpen = chestEvent.LockpickingChanceReduction != 0 && chestEvent.KeyIndex != 0;

            Print(writer, description.Name,
                (chestIndex, realChestIndex.ToString()),
                (keyIndex, hideKey ? null : chestEvent.KeyIndex == 0 ? None : chestEvent.KeyIndex.ToString()),
                (textIndex, chestEvent.TextIndex == 0xff ? None : chestEvent.TextIndex.ToString()),
                (alwaysOpen, hideAlwaysOpen ? null : chestEvent.LockpickingChanceReduction == 0 ? True : False),
                (lockpickChanceReduction, hideLockpickingChanceReduction ? null : chestEvent.LockpickingChanceReduction.ToString()));

            if (chestEvent.UnlockFailedEventIndex != 0xffff && chestEvent.UnlockFailedEventIndex != 0)
                writer.WriteLine($"-> {BranchExpressionString}: {ScriptEventSequence.JumpTo}(event{chestEvent.UnlockFailedEventIndex})");

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        bool hasKey = parameterValues.TryGetValue(keyIndex.Name.ToLower(), out var key) && key != "0" && key != None;

        var chestEvent = new ChestEvent()
        {
            Type = EventType.Chest,
            TextIndex = 0xff,
            LockpickingChanceReduction = hasKey ? 100u : 1u,
            UnlockFailedEventIndex = 0xffff,
            Flags = ChestEvent.ChestFlags.None
        };
        var chestScriptEvent = new ChestScriptEvent()
        {
            Event = chestEvent
        };

        bool? alwaysOpenSet = null;
        bool lockpickChangeReductionGiven = false;
        bool keyIndexGiven = false;

        Parse(description, parameterValues, (parameter, value, fromDefault) =>
        {
            string name = parameter.Name;

            if (name == chestIndex.Name)
            {
                uint chestIndex = EnsureLimits(ParseWord(value, constants), parameter);

                if (chestIndex > 256)
                {
                    chestEvent.Flags = ChestEvent.ChestFlags.ExtendedChest;
                    chestEvent.ChestIndex = chestIndex - 257;
                }
                else
                {
                    chestEvent.Flags = ChestEvent.ChestFlags.None;
                    chestEvent.ChestIndex = chestIndex - 1;
                }
            }
            else if (name == keyIndex.Name)
            {
                var keyIndex = EnsureLimits(ParseWord(value, constants, noneValue: 0), parameter);

                chestEvent.KeyIndex = keyIndex;

                if (alwaysOpenSet == true && keyIndex != 0)
                    throw new InvalidOperationException("AlwaysOpen must not be set to true if a KeyIndex is specified.");

                keyIndexGiven = keyIndex != 0;
            }
            else if (name == textIndex.Name)
                chestEvent.TextIndex = EnsureLimits(ParseByte(value, constants, noneValue: 0xff), parameter);
            else if (name == lockpickChanceReduction.Name)
            {
                if (fromDefault)
                    return;

                var reduction = EnsureLimits(ParseByte(value, constants, noneValue: 0), parameter);

                if (alwaysOpenSet == true && reduction != 0)
                    throw new FormatException("LockpickChanceReduction must be 0 if AlwaysOpen is set to true.");

                if (alwaysOpenSet == false && reduction == 0)
                    throw new FormatException("LockpickChanceReduction must not be 0 if AlwaysOpen is set to false.");

                chestEvent.LockpickingChanceReduction = reduction;

                lockpickChangeReductionGiven = true;
            }
            else if (name == alwaysOpen.Name)
            {
                var isAlwaysOpenSet = ParseBool(value, constants);

                if (isAlwaysOpenSet && (lockpickChangeReductionGiven && chestEvent.LockpickingChanceReduction != 0))
                    throw new FormatException("LockpickChanceReduction must be 0 if AlwaysOpen is set to true.");

                if (isAlwaysOpenSet && keyIndexGiven)
                    throw new FormatException("AlwaysOpen must not be set to true if a KeyIndex is specified.");

                if (isAlwaysOpenSet)
                    chestEvent.LockpickingChanceReduction = 0;
                else if (chestEvent.LockpickingChanceReduction == 0)
                    chestEvent.LockpickingChanceReduction = 1;

                alwaysOpenSet = isAlwaysOpenSet;
            }
        });

        return chestScriptEvent;
    }
}

internal class TreasureScriptEvent() : LockedBaseScriptEvent(EventType.Chest), IScriptEventType
{
    static readonly Parameter chestIndex = New.Arg("ChestIndex", 1, 256 + 128);
    static readonly BooleanParameter searchSkillCheck = New.BooleanOpt("SearchSkillCheck", false);
    static readonly BooleanParameter saveChestContents = New.BooleanOpt("SaveContents", false);

    static readonly ScriptDescription description = new("Treasure", chestIndex,
        textIndex, searchSkillCheck, saveChestContents);

    public override uint? AlternativeBranchIndex => null; // Treasures can not be unlocked!
    public override string BranchExpressionString => throw new NotSupportedException("Treasures do not support trap triggering conditions.");

    public static EventType GetEventType() => EventType.Chest;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new TreasureScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event is ChestEvent chestEvent && chestEvent.Flags.HasFlag(ChestEvent.ChestFlags.JunkPile);
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is ChestEvent chestEvent)
        {
            bool extendedChest = chestEvent.Flags.HasFlag(ChestEvent.ChestFlags.ExtendedChest);
            uint realChestIndex = 1 + (extendedChest ? 256 + chestEvent.ChestIndex : chestEvent.ChestIndex);

            Print(writer, description.Name,
                (chestIndex, realChestIndex.ToString()),
                (textIndex, chestEvent.TextIndex == 0xff ? None : chestEvent.TextIndex.ToString()),
                (searchSkillCheck, chestEvent.SearchSkillCheck ? True : False),
                (saveChestContents, chestEvent.Flags.HasFlag(ChestEvent.ChestFlags.NoSave) ? False : True));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var chestEvent = new ChestEvent()
        {
            Type = EventType.Chest,
            TextIndex = 0xff,
            LockpickingChanceReduction = 0,
            UnlockFailedEventIndex = 0xffff,
            Flags = ChestEvent.ChestFlags.JunkPile
        };
        var treasureScriptEvent = new TreasureScriptEvent()
        {
            Event = chestEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == chestIndex.Name)
            {
                uint chestIndex = EnsureLimits(ParseWord(value, constants), parameter);

                if (chestIndex > 256)
                {
                    chestEvent.Flags = ChestEvent.ChestFlags.ExtendedChest;
                    chestEvent.ChestIndex = chestIndex - 257;
                }
                else
                {
                    chestEvent.Flags = ChestEvent.ChestFlags.None;
                    chestEvent.ChestIndex = chestIndex - 1;
                }
            }
            else if (name == textIndex.Name)
                chestEvent.TextIndex = EnsureLimits(ParseByte(value, constants, noneValue: 0xff), parameter);
            else if (name == searchSkillCheck.Name)
                chestEvent.FindChanceReduction = (byte)(ParseBool(value, constants) ? 50 : 0);
            else if (name == saveChestContents.Name)
            {
                if (!ParseBool(value, constants))
                    chestEvent.Flags |= ChestEvent.ChestFlags.NoSave;
            }
        });

        return treasureScriptEvent;
    }
}

#endregion


#region Spinners and traps

internal class SpinnerScriptEvent() : ScriptEvent(EventType.Spinner), IScriptEventType
{
    static readonly EnumParameter<CharacterDirection> spinDir = New.BuildEnum<CharacterDirection>("dir",
        build => build
            .AsIs(CharacterDirection.Up,
                CharacterDirection.Right,
                CharacterDirection.Down,
                CharacterDirection.Left)
            .Map(CharacterDirection.Random, "Random")
    );

    static readonly ScriptDescription description = new("Spinner", spinDir);

    public static EventType GetEventType() => EventType.Spinner;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new SpinnerScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event.Type == EventType.Spinner;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is SpinnerEvent spinnerEvent)
        {
            Print(writer, description.Name,
                (spinDir, spinnerEvent.Direction == CharacterDirection.Random ? "Random" : spinnerEvent.Direction.ToString()));

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var spinnerEvent = new SpinnerEvent()
        {
            Type = EventType.Spinner,
            Direction = CharacterDirection.Random,
            Unused = [0,0,0,0,0,0,0,0],            
        };
        var spinnerScriptEvent = new SpinnerScriptEvent()
        {
            Event = spinnerEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == spinDir.Name)
                spinnerEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return spinnerScriptEvent;
    }
}

internal class TrapScriptEvent() : ScriptEvent(EventType.Spinner), IScriptEventType
{
    static readonly Parameter baseDamage = New.Arg("baseDamage");
    static readonly EnumParameter<TrapEvent.TrapTarget> target = New.Enum<TrapEvent.TrapTarget>("target");
    static readonly EnumParameter<TrapEvent.TrapAilment> ailment = New.Enum<TrapEvent.TrapAilment>("ailment");
    static readonly EnumParameter<GenderFlag> affectedGenders = New.Enum("affectedGenders", GenderFlag.Male, GenderFlag.Female, GenderFlag.Both);

    static readonly ScriptDescription description = new("Trap", baseDamage, target, ailment, affectedGenders);

    public static EventType GetEventType() => EventType.Trap;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(Event @event) => new TrapScriptEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(Event @event)
    {
        return @event.Type == EventType.Trap;
    }

    public override bool Print(Event @event, StreamWriter writer)
    {
        if (@event is TrapEvent trapEvent)
        {
            Print(writer, description.Name,
                (baseDamage, trapEvent.BaseDamage.ToString()),
                (target, trapEvent.Target.ToString()),
                (ailment, trapEvent.Ailment.ToString()),                
                (affectedGenders, trapEvent.AffectedGenders.ToString())); // TODO: Is it working with flags? ("Both" instead of "Male | Female")

            return true;
        }

        return false;
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var trapEvent = new TrapEvent()
        {
            Type = EventType.Trap,
            BaseDamage = 0,
            Ailment = TrapEvent.TrapAilment.None,
            Target = TrapEvent.TrapTarget.ActivePlayer,
            AffectedGenders = GenderFlag.Both,
            Unused = [0, 0, 0, 0, 0],
        };
        var trapScriptEvent = new TrapScriptEvent()
        {
            Event = trapEvent
        };

        Parse(description, parameterValues, (parameter, value, _) =>
        {
            string name = parameter.Name;

            if (name == baseDamage.Name)
                trapEvent.BaseDamage = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == target.Name)
                trapEvent.Target = EnsureValidValues(Enum.Parse<TrapEvent.TrapTarget>(value, true), parameter);
            else if (name == ailment.Name)
                trapEvent.Ailment = EnsureValidValues(Enum.Parse<TrapEvent.TrapAilment>(value, true), parameter);
            else if (name == affectedGenders.Name)
                trapEvent.AffectedGenders = EnsureValidValues(Enum.Parse<GenderFlag>(value, true), parameter);
        });

        return trapScriptEvent;
    }
}

#endregion