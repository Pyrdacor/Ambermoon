using Ambermoon;

namespace AmbermoonScript;

public enum ParseContext
{
    Header,
    HeaderLine,
    SequenceHeader,
    ScriptLine,
    ScriptLineAfterIf
}

public class ScriptParser
{
    public const string CommentPrefix = "//";
    public const string HeaderCommentPrefix = "##";
    public const string HeaderPrefix = "# ";
    public const string EventPrefix = "- ";
    public const string SuccessPrefix = "? ";
    public const string FailPrefix = "! ";
    public const string HeaderName = "script";
    public const string SequenceName = "sequence";
    public const string SequenceShortName = "seq";

    public bool EndOfFile { get; private set; } = false;
    public ParseContext CurrentContext { get; private set; } = ParseContext.Header;
    private int currentLine = 1;
    private string currentFile = "";
    private string? peekedLine = null;
    private StreamReader? reader = null;
    private readonly Dictionary<ParseContext, Dictionary<string, Dictionary<int, (string Message, int? Position)>>> warnings = [];
    private readonly Dictionary<string, ScriptFile> parsedFiles = [];

    public ScriptParser()
    {
        foreach (var context in EnumHelper.GetValues<ParseContext>())
            warnings[context] = [];
    }

    internal void EnterContext(ParseContext context)
    {
        CurrentContext = context;
    }

    public bool TryParseFile(string file, out ScriptFile? scriptFile)
    {
        if (!parsedFiles.TryGetValue(file, out scriptFile))
        {
            currentFile = file;
            currentLine = 1;
            CurrentContext = ParseContext.Header;
            EndOfFile = false;

            foreach (var context in EnumHelper.GetValues<ParseContext>())
                warnings[context][file] = [];

            using var reader = new StreamReader(file);
            this.reader = reader;

            try
            {
                // TODO: parse
                var header = new ScriptFileHeader(ScriptType.Map, 1, "1.0");
                // TODO: parse
                var constants = new List<ScriptConstant>();

                var sequences = new List<ScriptEventSequence>();

                while (ScriptEventSequence.TryParse(this, out var sequence))
                    sequences.Add(sequence!);

                if (!EndOfFile) // TODO: error message
                    return false;

                scriptFile = new(file, header, constants, sequences);
            }
            finally
            {
                this.reader = null;
            }
        }

        return true;
    }

    public string? PeekNextLine()
    {
        if (peekedLine != null)
            return peekedLine;

        peekedLine = reader!.ReadLine();

        EndOfFile = peekedLine == null;

        return peekedLine;
    }

    public string? ReadNextLine()
    {
        currentLine++;

        if (peekedLine != null)
        {
            string line = peekedLine;
            peekedLine = null;
            return line;
        }

        var nextLine = reader!.ReadLine();

        EndOfFile = nextLine == null;

        return nextLine;
    }

    public void ConsumePeekedLine()
    {
        peekedLine = null;
        currentLine++;
    }

    public void TrackParserWarning(string message, int? characterPosition = null)
    {
        warnings[CurrentContext][currentFile][currentLine] = (message, characterPosition);
    }
}
