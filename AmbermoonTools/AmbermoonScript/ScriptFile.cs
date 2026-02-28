using System.Text.RegularExpressions;
using Ambermoon;

namespace AmbermoonScript;

public enum ScriptType
{
    Map,
    Npc,
    Custom
}

public partial record ScriptFileHeader(ScriptType Type, uint Index, string Version)
{
    public static bool TryParse(ScriptParser parser, out ScriptFileHeader? header)
    {
        header = null;

        string? line;
        bool readProperties = false;
        string? version = null;
        uint? index = null;
        ScriptType? type = null;

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

            if (!readProperties && !line.StartsWith(ScriptParser.HeaderPrefix))
                return false;
            if (readProperties && !line.StartsWith(ScriptParser.EventPrefix))
            {
                if (type == null)
                {
                    parser.TrackParserWarning("Missing script type");
                    return false;
                }

                if (index == null)
                {
                    parser.TrackParserWarning("Missing script index");
                    return false;
                }

                if (version == null)
                {
                    parser.TrackParserWarning("Missing script version");
                    return false;
                }

                parser.EnterContext(ParseContext.ScriptLine);

                return true;
            }

            string headerString = line[2..].Trim();

            if (readProperties)
            {
                var parts = headerString.Split(':');

                if (parts.Length != 2)
                {
                    parser.TrackParserWarning("Invalid header entry. Must use this form: Property: Value");
                    return false;
                }

                string property = parts[0].Trim().ToLower();
                string value = parts[1].Trim();

                if (property == "version")
                {
                    if (!VersionRegex().IsMatch(value))
                    {
                        parser.TrackParserWarning($"Invalid value for script version: {value}. Should use the following format: 1.0");
                        return false;
                    }

                    version = value;
                }
                else if (property == "index")
                {
                    if (!uint.TryParse(value, out var i))
                    {
                        parser.TrackParserWarning($"Invalid value for script index: {value}. Should be a positive integer.");
                        return false;
                    }

                    index = i;
                }
                else if (property == "type")
                {
                    if (!Enum.TryParse<ScriptType>(value, true, out var t))
                    {
                        parser.TrackParserWarning($"Invalid value for script type: {value}. Must be one of: {string.Join(", ", EnumHelper.GetValues<ScriptType>())}");
                        return false;
                    }

                    type = t;
                }
                else
                {
                    parser.TrackParserWarning($"Unrecognized header property: {property}. Must be one of: version, type, index");
                    return false;
                }
            }
            else
            {
                if (!headerString.Equals(ScriptParser.HeaderName, StringComparison.OrdinalIgnoreCase))
                    return false;

                parser.EnterContext(ParseContext.HeaderLine);
                readProperties = true;
            }
        }

        return false;
    }

    [GeneratedRegex(@"[0-9][.][0-9]+", RegexOptions.Compiled)]
    private static partial Regex VersionRegex();
}

public record ScriptFile
(
    string FileName,
    ScriptFileHeader Header,
    ICollection<ScriptConstant> Constants,
    ICollection<ScriptEventSequence> Sequences
);
