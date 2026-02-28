using Ambermoon;
using Ambermoon.Data;
using New = AmbermoonScript.EventHelper;

namespace AmbermoonScript;

// Use cases:
// - Load events and create script from it (Event -> ScriptEvent -> Print)
// - Compile script to events (Parse -> ScriptEvent -> Event)
// - Show as potential statement (name) (List of all statements -> Pick -> ScriptEvent from statement)
// - Show possible/valid parameters (same as before)
// - Every script event has a unique statement
public interface IScriptEvent
{
    static abstract ScriptDescription GetDescription();

    static abstract Func<ScriptEventReference> GetFactory();
}

public record ScriptEventSequence(uint Index, ICollection<ScriptEventReference> Events)
{
    private static readonly Dictionary<string, Func<ScriptEventReference>> eventPool = [];

    static ScriptEventSequence()
    {
        static void AddEvent<T>() where T : IScriptEvent
        {
            var description = T.GetDescription();
            var factory = T.GetFactory();

            eventPool.Add(description.Name.ToLower(), factory);
        }

        // Register all event types
        AddEvent<MapChangeEvent>();
        // TODO ...
    }

    public static bool TryParse(ScriptParser parser, out ScriptEventSequence? sequence)
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

            if (!header.StartsWith(ScriptParser.SequenceShortName))
                return false;

            int length = ScriptParser.SequenceShortName.Length;

            if (header.StartsWith(ScriptParser.SequenceName))
            {
                length = ScriptParser.SequenceName.Length;
                header = header[ScriptParser.SequenceName.Length..];
            }
            else
                header = header[ScriptParser.SequenceShortName.Length..];

            if (!header.StartsWith(' '))
            {
                int offset = originalLine.IndexOf(ScriptParser.SequenceShortName);
                parser.TrackParserWarning($"Expected a space after {originalLine[offset..(offset + length)]}.",
                    offset + length);
                return false;
            }

            header = header.Trim();

            if (!uint.TryParse(header, out var index))
            {
                int offset = originalLine.IndexOf(ScriptParser.SequenceShortName) + length + 1;
                parser.TrackParserWarning($"Invalid sequence index: {header}", offset);
                return false;
            }

            parser.EnterContext(ParseContext.ScriptLine);

            List<ScriptEventReference> events = [];

            while (true)
            {
                if (!ScriptDescription.TryParse(parser, out var name, out var parameters, out bool error))
                {
                    if (error)
                        return false;

                    parser.EnterContext(ParseContext.SequenceHeader); // parse next header or end
                    break;
                }

                if (!eventPool.TryGetValue(name!.ToLower(), out var factory))
                {
                    parser.TrackParserWarning($"Unrecognized event name: {name}");
                    return false;
                }

                var reference = factory();

                events.Add(reference);
            }

            sequence = new(index, events);

            return true;
        }

        return false;
    }
}

public interface IScriptEvent<T> : IScriptEvent
    where T : Event
{
    T ToEvent();
    static abstract IScriptEvent FromEvent(T @event);
    static abstract bool MatchesEvent(T @event);
    void Print(T @event, StreamWriter writer);
    static abstract IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants);
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

public abstract class ScriptEventReference
{
    protected abstract IScriptEvent ScriptEvent { get; }

    protected static void Parse(ScriptDescription description,
        Dictionary<string, string> parameterValues,
        Action<IParameter, string> setParameter)
    {
        foreach (var parameter in description.Parameters)
        {
            string lowerName = parameter.Name.ToLower();

            if (parameterValues.TryGetValue(lowerName, out var value))
            {
                parameterValues.Remove(lowerName);
                setParameter(parameter, value);
            }
            else if (parameter.Optional)
            {
                setParameter(parameter, parameter.DefaultValue!);
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

    protected static byte ParseByte(string value, Dictionary<string, long> constants)
    {
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

    protected static ushort ParseWord(string value, Dictionary<string, long> constants)
    {
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

    protected static void Print(StreamWriter streamWriter, string name, params (IParameter Parameter, string Value)[] parameterValues)
    {
        var args = string.Join(", ", parameterValues.Select(p => $"{p.Parameter.Name} = {p.Value}"));

        streamWriter.WriteLine($"{name}({args})");
    }
}

internal abstract class ScriptEvent<T> : ScriptEventReference
    where T : Event
{
    protected T? Event { get; set; }

    public T ToEvent() => Event ?? throw new InvalidOperationException("No event data parsed or loaded");

}

internal class MapChangeEvent : ScriptEvent<TeleportEvent>, IScriptEvent<TeleportEvent>
{
    static readonly IParameter mapIndex = New.Arg("mapIndex", 0, 1023);
    static readonly IParameter x = New.Arg("x", 0, 200);
    static readonly IParameter y = New.Arg("y", 0, 200);
    static readonly IParameter teleportDir = New.BuildEnum<CharacterDirection>("dir",
        build => build
            .AsIs(CharacterDirection.Up,
                CharacterDirection.Right,
                CharacterDirection.Down,
                CharacterDirection.Left)
            .Map(CharacterDirection.Keep, "Keep")
    );
    static readonly ScriptDescription description = new("MapChange", mapIndex, x, y, teleportDir);

    protected override IScriptEvent ScriptEvent => this;

    public static ScriptDescription GetDescription() => description;

    public static IScriptEvent FromEvent(TeleportEvent @event) => new MapChangeEvent()
    {
        Event = @event
    };

    public static bool MatchesEvent(TeleportEvent @event)
    {
        return @event.Transition == TeleportEvent.TransitionType.MapChange;
    }
    
    public void Print(TeleportEvent @event, StreamWriter writer)
    {
        Print(writer, description.Name,
            (mapIndex, @event.MapIndex.ToString()),
            (x, @event.X.ToString()),
            (y, @event.Y.ToString()),
            (teleportDir, @event.Direction.ToString()));
    }

    public static IScriptEvent Parse(Dictionary<string, string> parameterValues, Dictionary<string, long> constants)
    {
        var mapChangeEvent = new MapChangeEvent()
        {
            Event = new()
            {
                Transition = TeleportEvent.TransitionType.MapChange
            }
        };
        var teleportEvent = mapChangeEvent.Event;

        Parse(description, parameterValues, (parameter, value) =>
        {
            string name = parameter.Name;

            if (name == "mapIndex")
                teleportEvent.MapIndex = EnsureLimits(ParseWord(value, constants), parameter);
            else if (name == "x")
                teleportEvent.X = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == "y")
                teleportEvent.Y = EnsureLimits(ParseByte(value, constants), parameter);
            else if (name == "dir")
                teleportEvent.Direction = EnsureValidValues(Enum.Parse<CharacterDirection>(value, true), parameter);
        });

        return mapChangeEvent;
    }

    public static Func<ScriptEventReference> GetFactory()
    {
        return () => new MapChangeEvent();
    }
}