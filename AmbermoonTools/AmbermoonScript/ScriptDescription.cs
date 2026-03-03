using System.Text.RegularExpressions;
using Ambermoon;

namespace AmbermoonScript;

public interface IParameter
{
    string Name { get; }
    bool Optional { get; }
    string? DefaultValue { get; }
}

public record Parameter(string Name, bool Optional, int MinValue = 0, int MaxValue = byte.MaxValue, int? DefaultValue = null) : IParameter
{
    string? IParameter.DefaultValue => DefaultValue?.ToString();
}

public record BooleanParameter : Parameter
{
    public BooleanParameter(string Name, bool Optional, bool? DefaultValue = null)
        : base(Name, Optional, 0, 1, DefaultValue == null ? null : (DefaultValue.Value ? 1 : 0))
    {

    }
}

public record EnumParameter<T>(string Name, bool Optional, T? DefaultValue, params T[] AllowedValues) : IParameter
    where T : struct, Enum
{
    public Func<T, string>? ValueToString { get; init; }
    public Func<string, T>? StringToValue { get; init; }
    string? IParameter.DefaultValue
    {
        get
        {
            if (DefaultValue == null)
                return null;

            return ValueToString?.Invoke(DefaultValue.Value) ?? DefaultValue.ToString()?.ToLower();
        }
    }
}

public record FlagsParameter<T> : EnumParameter<T>
    where T : struct, Enum
{
    public FlagsParameter(string name, bool optional, int bytes, T? defaultValue, params T[] allowedValues)
        : base(name, optional, defaultValue, allowedValues)
    {
        ValueToString = (value) => value.ToFlagsPrintString(bytes);
        StringToValue = (str) => EnumHelper.ParseFlagsEnum<T>(str, true);
    }
}

public record NullableParameter(IParameter BaseParameter, string NullValueLiteral = "null") : IParameter
{
    public string Name => BaseParameter.Name;
    public bool Optional => true;
    string? IParameter.DefaultValue => NullValueLiteral;
}

public partial record ScriptDescription(string Name, params IParameter[] Parameters)
{
    public static bool TryParse(ScriptParser parser, out string? name, out Dictionary<string, string> parameters, out bool error, IScriptEvent? lastEvent)
    {
        name = null;
        parameters = [];
        error = false;

        string? line;

        while ((line = parser.PeekNextLine()) != null)
        {
            string originalLine = line;

            line = line.Trim();

            if (line.Length == 0 ||
                line.StartsWith(ScriptParser.CommentPrefix))
            {
                parser.ConsumePeekedLine();
                continue;
            }

            if (line.StartsWith(ScriptParser.HeaderCommentPrefix) || line.StartsWith(ScriptParser.HeaderPrefix))
                return false;

            if (line.StartsWith(ScriptParser.BranchPrefix))
            {
                if (parser.CurrentContext != ParseContext.ScriptLineAfterBranch || lastEvent is not IBranchScriptEvent lastBranchEvent)
                {
                    parser.TrackParserWarning("Conditional jumps (->) are only allowed after branch events.",
                        originalLine.IndexOf(ScriptParser.BranchPrefix));
                    error = true;
                    return false;
                }

                // Valid syntax:
                // -> TrapTriggered: JumpTo(event123)
                // -> TrapTriggered: End()
                // TrapTriggered is the IBranchScriptEvent.BranchExpressionString and depends on the event.
                int dividerPosition = line.IndexOf(ScriptParser.BranchDivider);

                if (dividerPosition == -1)
                {
                    parser.TrackParserWarning("Wrong conditional jump format. Use something like this: -> TrapTriggered: JumpTo(event123)",
                        originalLine.IndexOf(ScriptParser.BranchPrefix) + ScriptParser.BranchPrefix.Length);
                    error = true;
                    return false;
                }

                string expression = line[ScriptParser.BranchPrefix.Length..dividerPosition].Trim();                

                if (!expression.Equals(lastBranchEvent.BranchExpressionString, StringComparison.CurrentCultureIgnoreCase))
                {
                    parser.TrackParserWarning($"Invalid condition name: {expression}. Must be: {lastBranchEvent.BranchExpressionString}.",
                        originalLine.IndexOf(ScriptParser.BranchPrefix) + ScriptParser.BranchPrefix.Length);
                    error = true;
                    return false;
                }

                string jumpExpression = line[(dividerPosition + 1)..].Trim();

                if (jumpExpression.Length == 0)
                {
                    parser.TrackParserWarning($"Missing jump expression after ':'. Use something like JumpTo(event123) or End().",
                        originalLine.IndexOf(ScriptParser.BranchDivider) + ScriptParser.BranchDivider.Length);
                    error = true;
                    return false;
                }

                int openBracketPosition = jumpExpression.IndexOf('(');
                int closeBracketPosition = jumpExpression.IndexOf(')');

                if (openBracketPosition == -1 || closeBracketPosition == -1 || openBracketPosition > closeBracketPosition || closeBracketPosition + 1 != jumpExpression.Length)
                {
                    parser.TrackParserWarning($"Invalid jump expression: {jumpExpression}. Use something like JumpTo(event123) or End().",
                        originalLine.IndexOf(ScriptParser.BranchDivider) + ScriptParser.BranchDivider.Length);
                    error = true;
                    return false;
                }

                string jumpCommand = jumpExpression[..openBracketPosition].Trim();
                bool jumpTo = jumpCommand.Equals(ScriptEventSequence.JumpTo, StringComparison.OrdinalIgnoreCase);
                bool end = jumpCommand.Equals(ScriptEventSequence.End, StringComparison.OrdinalIgnoreCase);

                if (!jumpTo && !end)
                {
                    parser.TrackParserWarning($"Invalid jump expression: {jumpExpression}. Use something like JumpTo(event123) or End().",
                        originalLine.IndexOf(ScriptParser.BranchDivider) + ScriptParser.BranchDivider.Length);
                    error = true;
                    return false;
                }

                string arg = jumpExpression[(openBracketPosition + 1)..closeBracketPosition].Trim();

                if (end && arg.Length != 0)
                {
                    parser.TrackParserWarning($"Invalid jump expression: {jumpExpression}. End() should not have arguments.",
                        originalLine.IndexOf(ScriptParser.BranchDivider) + ScriptParser.BranchDivider.Length);
                    error = true;
                    return false;
                }

                if (jumpTo && (arg.Length == 0 || !LabelNameRegex().IsMatch(arg)))
                {
                    parser.TrackParserWarning($"Invalid jump expression: {jumpExpression}. JumpTo(label) should have a valid label name as argument.",
                        originalLine.IndexOf(ScriptParser.BranchDivider) + ScriptParser.BranchDivider.Length);
                    error = true;
                    return false;
                }

                name = $"{ScriptParser.BranchPrefix}{lastBranchEvent.BranchExpressionString}";

                if (jumpTo)
                    parameters.Add(ScriptParser.JumpTargetParam, arg);

                parser.ConsumePeekedLine();

                return true;
            }

            int commentIndex = line.IndexOf(ScriptParser.CommentPrefix);

            if (commentIndex != -1)
                line = line[..commentIndex].TrimEnd();

            if (!line.StartsWith(ScriptParser.EventPrefix))
                return false;

            line = line[2..];

            int openBracketCount = line.Count('(');
            int closeBracketCount = line.Count(')');

            if (openBracketCount > 1)
            {
                parser.TrackParserWarning("More than one opening bracket found.",
                    originalLine.IndexOf('(', originalLine.IndexOf('(') + 1));
                error = true;
                return false;
            }

            if (closeBracketCount > 1)
            {
                parser.TrackParserWarning("More than one closing bracket found.",
                    originalLine.IndexOf(')', originalLine.IndexOf(')') + 1));
                error = true;
                return false;
            }

            if (openBracketCount != closeBracketCount)
            {
                if (openBracketCount == 1)
                    parser.TrackParserWarning("Missing closing bracket for opening bracket.",
                        originalLine.IndexOf('('));
                else
                    parser.TrackParserWarning("Missing opening bracket for closing bracket.",
                        originalLine.IndexOf(')'));

                error = true;
                return false;
            }

            if (openBracketCount == 1)
            {
                int openBracketIndex = line.IndexOf('(');

                if (openBracketIndex == 0)
                {
                    parser.TrackParserWarning("Missing event name.", originalLine.IndexOf('('));
                    error = true;
                    return false;
                }

                int closeBracketIndex = line.IndexOf(')');

                if (closeBracketIndex < openBracketIndex)
                {
                    parser.TrackParserWarning("Closing bracket must not preceed the opening bracket.", originalLine.IndexOf(')'));
                    error = true;
                    return false;
                }

                var parts = line.Split(['(', ')'], StringSplitOptions.RemoveEmptyEntries);

                if (parts.Length != 2)
                {
                    parser.TrackParserWarning("Invalid data after closing bracket.", originalLine.IndexOf(')') + 1);
                    error = true; 
                    return false;
                }

                var eventOrParamNameRegex = EventOrParamNameRegex();
                name = parts[0];

                if (!eventOrParamNameRegex.IsMatch(name))
                {
                    string namePart = originalLine[..originalLine.IndexOf('(')];
                    parser.TrackParserWarning($"Invalid event name: {name}", namePart.Length - namePart.TrimStart().Length);
                    error = true;
                    return false;
                }

                var parameterParts = parts[1].Split(',');

                if (parameterParts.Length == 1 && parameterParts[0].Trim().Length == 0)
                    return true; // Things like Outro()

                int charOffset = originalLine.IndexOf('(') + 1;
                var paramValueRegex = ParamValueRegex();

                foreach (var parameterPart in parameterParts)
                {
                    charOffset = originalLine.IndexOf(parameterPart, charOffset);

                    var args = parameterPart.Split("=");

                    if (args.Length != 2)
                    {
                        parser.TrackParserWarning("Event parameter has wrong format. Correct: name = value", charOffset);
                        error = true;
                        return false;
                    }

                    string paramName = args[0].Trim();

                    if (!eventOrParamNameRegex.IsMatch(paramName))
                    {
                        parser.TrackParserWarning($"Invalid event parameter name: {args[0]}", charOffset);
                        error = true;
                        return false;
                    }

                    string paramValue = args[1].Trim();

                    if (!paramValueRegex.IsMatch(paramValue))
                    {
                        parser.TrackParserWarning($"Invalid event parameter value: {args[1]}", originalLine.IndexOf('=', charOffset) + 1 + (args[1].TrimEnd().Length - paramValue.Length));
                        error = true;
                        return false;
                    }

                    string lowerParamName = paramName.ToLower();

                    if (!parameters.TryAdd(lowerParamName, paramValue))
                    {
                        parser.TrackParserWarning($"Parameter {paramName} was used twice.", charOffset);
                        error = true;
                        return false;
                    }

                    charOffset += parameterPart.Length;
                }

                parser.ConsumePeekedLine();

                return true;
            }
        }

        return false;
    }

    [GeneratedRegex(@"^[a-z][a-z0-9]*$", RegexOptions.Compiled | RegexOptions.IgnoreCase)]
    private static partial Regex EventOrParamNameRegex();

    [GeneratedRegex(@"^([a-z][a-z0-9]*)|0|([1-9][0-9]{0,9})|((0x|\$)[0-9a-f]{1,8})|((0b|%)[01]{1,32})$", RegexOptions.Compiled | RegexOptions.IgnoreCase)]
    private static partial Regex ParamValueRegex();

    [GeneratedRegex(@"^[.]?[a-z][a-z0-9]*$", RegexOptions.Compiled | RegexOptions.IgnoreCase)]
    private static partial Regex LabelNameRegex();
}

public enum EmpoweredSpellType
{
    Earth,
    Wind,
    Fire
}

public enum SpellTypeIndex
{
    Healing,
    Alchemistic,
    Mystic,
    Destruction,
    SpellClass5,
    SpellClass6,
    Function
}

public static class ScriptDescription2
{
    private static readonly Dictionary<string, ScriptDescription> statements;
    private static readonly Dictionary<string, ScriptDescription> advancedStatements;

    static ScriptDescription2()
    {
        static void Add(string name, params IParameter[] args)
            => statements.Add(name, new(name, args));
        static void AddAdvanced(string name, params IParameter[] args)
            => advancedStatements.Add(name, new(name, args));
        static void AddMany(List<string> names, params IParameter[] args)
            => names.ForEach(name => Add(name, args));
        static void AddManyAdvanced(List<string> names, params IParameter[] args)
            => names.ForEach(name => AddAdvanced(name, args));

        // Re-used args
        /*var mapIndex = Arg("mapIndex", 0, 1023);
        var x = Arg("x", 0, 200);
        var y = Arg("y", 0, 200);
        var teleportDir = BuildEnum<CharacterDirection>("dir", builder =>
            builder
                .AsIs(CharacterDirection.Up,
                    CharacterDirection.Right,
                    CharacterDirection.Down,
                    CharacterDirection.Left)
                .Map(CharacterDirection.Keep, "Keep")
        );
        var lockpickChanceReduction = Opt("LockpickChanceReduction", 0, 0, 100);
        var optionalTextIndex = Opt("TextIndex", 0xff);
        var unlockTextIndex = Opt("UnlockTextIndex", 0xff);
        var textIndex = Arg("TextIndex");
        var triggerIfBlind = Opt("TriggerIfBlind", 0, 0, 1);
        var printTrigger = Enum<EventTrigger>("Trigger", EventTrigger.Move, EventTrigger.EyeCursor, EventTrigger.Always);
        var rewardTarget = Enum<RewardEvent.RewardTarget>("Target");

        // Teleports
        Add("MapChange", mapIndex, x, y, teleportDir);
        Add("Teleport", x, y, teleportDir);
        Add("WindGate", mapIndex, x, y, teleportDir);
        Add("Climb", mapIndex, x, y, teleportDir);
        Add("Fall", mapIndex, x, y, teleportDir);
        Add("Outro");

        // Door
        Add("Door",
            lockpickChanceReduction,
            Arg("DoorIndex"),
            optionalTextIndex,
            unlockTextIndex,
            Arg("KeyIndex", 0, 1023));

        // Chests
        Add("Pile",
            Opt("SearchSkillCheck", 0),
            Opt("SaveChest", 0, 0, 1),
            Arg("ChestIndex", 0, 256 + 128 - 1),
            optionalTextIndex);
        Add("Chest",
            lockpickChanceReduction,
            Arg("ChestIndex", 0, 256 + 128 - 1),
            optionalTextIndex,
            Opt("KeyIndex", 0, 0, 1023));

        // Print
        Add("Print",
            textIndex,
            triggerIfBlind,
            printTrigger);
        Add("Ask",
            textIndex);
        Add("Picture",
            textIndex,
            Arg("PictureIndex"),
            triggerIfBlind,
            printTrigger);

        // Traps and Spinners
        Add("Spin",
            BuildEnum<CharacterDirection>("dir", builder =>
            builder
                .AsIs(CharacterDirection.Up,
                    CharacterDirection.Right,
                    CharacterDirection.Down,
                    CharacterDirection.Left)
                .Map(CharacterDirection.Random, "Random")));
        Add("Trap",
            Arg("BaseDamage"),
            Enum<TrapEvent.TrapTarget>("Target"),
            OptEnum("Ailment", TrapEvent.TrapAilment.None),
            OptEnum("AffectedGenders", GenderFlag.Both));

        // Buffs and Rewards
        AddAdvanced("AddBuff",
            Enum<ActiveSpellType>("Buff"),
            Arg("Duration", 0, ushort.MaxValue),
            Opt("Value", 1));
        Add("RemoveBuff",
            new NullableParameter(Enum<ActiveSpellType>("Buff"), "All"));
        AddMany(["AddStrength", "AddIntelligence", "AddDexterity",
            "AddStamina", "AddSpeed", "AddCharisma", "AddLuck, AddAntiMagic",
            "AddStr", "AddInt", "AddDex", "AddSta", "AddSpd", "AddCha",
            "AddLuc", "AddA-M",
            "AddAttack", "AddParry", "AddSwim", "AddCrit", "AddFindTraps",
            "AddDisarmTraps", "AddLockPicking", "AddSearching", "AddReadMagic",
            "AddUseMagic", "AddAtk", "AddPar", "AddSwi", "AddCri", "AddF-T",
            "AddD-T", "AddL-P", "AddSea", "AddR-M", "AddU-M",
            "AddHitPoints", "AddSpellPoints", "AddSpellLearningPoints",
            "AddExperience", "AddHP", "AddSP",
            "AddSLP", "AddExp", "AddXP",
            "RemoveStrength", "RemoveIntelligence", "RemoveDexterity",
            "RemoveStamina", "RemoveSpeed", "RemoveCharisma", "RemoveLuck, RemoveAntiMagic",
            "RemoveStr", "RemoveInt", "RemoveDex", "RemoveSta", "RemoveSpd", "RemoveCha",
            "RemoveLuc", "RemoveA-M",
            "RemoveAttack", "RemoveParry", "RemoveSwim", "RemoveCrit", "RemoveFindTraps",
            "RemoveDisarmTraps", "RemoveLockPicking", "RemoveSearching", "RemoveReadMagic",
            "RemoveUseMagic", "RemoveAtk", "RemovePar", "RemoveSwi", "RemoveCri", "RemoveF-T",
            "RemoveD-T", "RemoveL-P", "RemoveSea", "RemoveR-M", "RemoveU-M",
            "RemoveHitPoints", "RemoveSpellPoints", "RemoveSpellLearningPoints",
            "RemoveExperience", "RemoveHP", "RemoveSP",
            "RemoveSLP", "RemoveExp", "RemoveXP"],
            Opt("Percentage", 0, 0, 1),
            Opt("Random", 0, 0, 1),
            rewardTarget);
        AddManyAdvanced(["AddMaxStrength", "AddMaxIntelligence", "AddMaxDexterity",
            "AddMaxStamina", "AddMaxSpeed", "AddMaxCharisma", "AddMaxLuck, AddMaxAntiMagic",
            "AddMaxStr", "AddMaxInt", "AddMaxDex", "AddMaxSta", "AddMaxSpd", "AddMaxCha",
            "AddMaxLuc", "AddMaxA-M",
            "AddMaxAttack", "AddMaxParry", "AddMaxSwim", "AddMaxCrit", "AddMaxFindTraps",
            "AddMaxDisarmTraps", "AddMaxLockPicking", "AddMaxSearching", "AddMaxReadMagic",
            "AddMaxUseMagic", "AddMaxAtk", "AddMaxPar", "AddMaxSwi", "AddMaxCri", "AddMaxF-T",
            "AddMaxD-T", "AddMaxL-P", "AddMaxSea", "AddMaxR-M", "AddMaxU-M", "AddMaxHitPoints",
            "AddMaxSpellPoints", "AddTrainingPoints", "AddMaxHP", "AddMaxSP", "AddTP",
            "AddAttacksPerRound", "AddAPR", "AddLevel", "AddLvl", "AddDamage", "AddDefense",
            "AddDmg", "AddDef", "AddMagicWeaponLevel", "AddMagicArmorLevel", "AddMBW", "AddMBA",
            "RemoveMaxStrength", "RemoveMaxIntelligence", "RemoveMaxDexterity",
            "RemoveMaxStamina", "RemoveMaxSpeed", "RemoveMaxCharisma", "RemoveMaxLuck, RemoveMaxAntiMagic",
            "RemoveMaxStr", "RemoveMaxInt", "RemoveMaxDex", "RemoveMaxSta", "RemoveMaxSpd", "RemoveMaxCha",
            "RemoveMaxLuc", "RemoveMaxA-M",
            "RemoveMaxAttack", "RemoveMaxParry", "RemoveMaxSwim", "RemoveMaxCrit", "RemoveMaxFindTraps",
            "RemoveMaxDisarmTraps", "RemoveMaxLockPicking", "RemoveMaxSearching", "RemoveMaxReadMagic",
            "RemoveMaxUseMagic", "RemoveMaxAtk", "RemoveMaxPar", "RemoveMaxSwi", "RemoveMaxCri", "RemoveMaxF-T",
            "RemoveMaxD-T", "RemoveMaxL-P", "RemoveMaxSea", "RemoveMaxR-M", "RemoveMaxU-M",
            "RemoveMaxHitPoints", "RemoveMaxSpellPoints", "RemoveTrainingPoints", "RemoveMaxHP",
            "RemoveMaxSP", "RemoveTP", "RemoveAttacksPerRound", "RemoveAPR", "RemoveLevel", "RemoveLvl",
            "RemoveDamage", "RemoveDefense", "RemoveDmg", "RemoveDef", "RemoveMagicWeaponLevel",
            "RemoveMagicArmorLevel", "RemoveMBW", "RemoveMBA"],
            Opt("Percentage", 0, 0, 1),
            Opt("Random", 0, 0, 1),
            rewardTarget);
        AddAdvanced("AddSpell", Arg("SpellIndex", 1, 30));
        AddAdvanced("EmpowerSpells", Enum<EmpoweredSpellType>("SpellType"));
        AddAdvanced("ChangePortrait", Arg("PortraitIndex"));
        Add("AddLanguage", Enum<LanguageIndex>("Language"));
        Add("AddSpellType", Enum<SpellTypeIndex>("SpellType"));
        AddMany(["AddCondition", "RemoveCondition"], Enum<Condition>("Condition"));
        AddMany(["FillHitPoints", "FillSpellPoints", "FillHP", "FillSP"]);

        // Riddlemouth
        Add("Riddlemouth",
            textIndex,
            Arg("SolutionTextIndex"),
            Arg("SolutionKeywordIndex"),
            Opt("AlternativeSolutionKeywordIndex", -1, -1));

        // Tile Change
        Add("ChangeTile", mapIndex, x, y, Arg("TileIndex", 0, ushort.MaxValue));

        // Fight
        Add("Fight", Arg("MonsterGroupIndex", 0, ushort.MaxValue));

        // TODO: ...*/
    }
}