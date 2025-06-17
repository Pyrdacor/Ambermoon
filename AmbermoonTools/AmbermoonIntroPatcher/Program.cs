using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.ExecutableData;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using Ambermoon.Data.Text.Patching;
using System.Data;
using System.Text;

// The new file Intro_texts.amb has the following format:
//
// byte NumberOfNonCommandTexts
// string[n] NonCommandTexts (null-terminated)
// byte NumberOfCommandTextGroups
// foreach
//  byte NumberOfCommandTexts (per group, mostly 1 or 2)
//  string[n] CommandTexts (null-terminated)

public static class Program
{
    // args[0]: Working directory (needs Ambermoon_intro or Ambermoon_intro_translation_base and Intro_texts.amb)
    // args[1]: Path for Ambermoon_intro to save
    // args[2]: Optional font file
    public static void Main(string[] args)
    {
        Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

        var gameData = new GameData(GameData.LoadPreference.ForceExtracted, null, false, GameData.VersionPreference.Post114);

        gameData.Load(args[0]);

        var introHunks = AmigaExecutable.Read(gameData.Files["Ambermoon_intro"].Files[1]);
        var dataHunks = introHunks
            .Where(h => h.Type == AmigaExecutable.HunkType.Data)
            .Select(h => new DataReader(((AmigaExecutable.Hunk)h).Data))
            .ToList();
        var dataHunk = dataHunks[0];

        // Special handling of the new "remake-only" Extro_texts.amb
        var fileReader = new FileReader();

        var introTextsContainer = fileReader.ReadFile("Intro_texts.amb", new DataReader(File.ReadAllBytes(Path.Combine(args[0], "Intro_texts.amb"))));

        if (introTextsContainer != null)
        {
            var texts = new Dictionary<IntroText, string>(12);
            var introTextsReader = introTextsContainer.Files[1];
            int nonCommandTextCount = introTextsReader.ReadByte();

            for (int i = 0; i < nonCommandTextCount; ++i)
            {
                string text = introTextsReader.ReadNullTerminatedString(Encoding.UTF8);

                if (i < 12) // In case the count is too high
                    texts[(IntroText)i] = text;
            }

            int commandCount = introTextsReader.ReadByte();
            var textCommandGroups = new List<int[]>(commandCount);
            var currentTextCommandGroup = new List<int>(3);
            int index = 0;
            int firstWhiteTextCommandIndex = -1;

            foreach (var textCommand in textCommands)
            {
                if (textCommand.Type == IntroTextCommandType.Add)
                {
                    currentTextCommandGroup.Add(index);
                }
                else if (textCommand.Type == IntroTextCommandType.Render)
                {
                    if (currentTextCommandGroup.Count != 0)
                    {
                        textCommandGroups.Add(currentTextCommandGroup.ToArray());
                        currentTextCommandGroup.Clear();
                    }
                }
                else if (firstWhiteTextCommandIndex == -1 &&
                    textCommand.Type == IntroTextCommandType.SetTextColor &&
                    textCommand.Args[0] == 0x0ccc)
                {
                    firstWhiteTextCommandIndex = index;

                    while (firstWhiteTextCommandIndex > 0 && textCommands[firstWhiteTextCommandIndex - 1].Type != IntroTextCommandType.Clear)
                        --firstWhiteTextCommandIndex;
                }

                ++index;
            }

            for (int i = 0; i < commandCount; ++i)
            {
                var commandTexts = new string[introTextsReader.ReadByte()];

                for (int t = 0; t < commandTexts.Length; ++t)
                    commandTexts[t] = introTextsReader.ReadNullTerminatedString(System.Text.Encoding.UTF8);

                if (i < textCommandGroups.Count)
                {
                    for (int t = 0; t < commandTexts.Length; ++t)
                    {
                        if (t < textCommandGroups[i].Length)
                        {
                            int commandIndex = textCommandGroups[i][t];
                            var command = (TextCommand)textCommands[commandIndex];
                            string commandText = new string(TextProcessor.RemoveDiacritics(commandTexts[t]).Where(ch => ch == ' ' || glyphs.ContainsKey(ch)).ToArray());
                            textCommandTexts[command.Args[2]] = commandText;

                            if (commandText.Length != 0 && firstWhiteTextCommandIndex != -1 && commandIndex >= firstWhiteTextCommandIndex)
                            {
                                var args = command.Args;
                                int width = commandText.Sum(ch => ch == ' ' ? 6 : glyphs[ch].Advance);
                                args[0] = 160 - width / 2;
                                textCommands[commandIndex] = command with { Args = args };
                            }
                        }
                    }
                }
            }
        }

        var outroTextsContainer = fileReader.ReadFile("Extro_texts.amb", new DataReader(File.ReadAllBytes(Path.Combine(args[0], "Extro_texts.amb"))));

        if (outroTextsContainer != null)
        {
            var outroTextsReader = outroTextsContainer.Files[1];
            outroTextsReader.Position = 0;
            int clickGroupCount = outroTextsReader.ReadWord();
            var clickGroupSizes = new int[clickGroupCount];
            var newTextClickGroups = new List<List<string>>[clickGroupCount];

            for (int i = 0; i < clickGroupCount; ++i)
            {
                int count = clickGroupSizes[i] = outroTextsReader.ReadWord();
                newTextClickGroups[i] = new(count);
            }

            for (int i = 0; i < clickGroupCount; ++i)
            {
                int groupCount = clickGroupSizes[i];
                var groupSizes = new int[groupCount];

                for (int g = 0; g < groupCount; ++g)
                {
                    int count = groupSizes[g] = outroTextsReader.ReadWord();
                    newTextClickGroups[i].Add(new(count));
                }

                for (int g = 0; g < groupCount; ++g)
                {
                    var newTextGroups = newTextClickGroups[i][g];
                    int count = groupSizes[g];

                    for (int t = 0; t < count; ++t)
                        newTextGroups.Add(outroTextsReader.ReadNullTerminatedString(System.Text.Encoding.UTF8));

                    newTextClickGroups[i].Add(newTextGroups);
                }

                if (outroTextsReader.Position % 2 == 1)
                    ++outroTextsReader.Position;
            }

            int translatorCount = outroTextsReader.ReadWord();
            var translators = new List<string>();

            for (int i = 0; i < translatorCount; ++i)
                translators.Add(outroTextsReader.ReadNullTerminatedString(System.Text.Encoding.UTF8));

            var clickText = outroTextsReader.ReadNullTerminatedString(System.Text.Encoding.UTF8);

            if (outroTextsReader.Position % 2 == 1)
                ++outroTextsReader.Position;

            var fontsData = File.ReadAllBytes(Path.Combine(args[0], "Extro_fonts"));

            var encoding = Encoding.GetEncoding(852);//Encoding.GetEncoding("ISO-8859-2");

            try
            {
                PatchTexts(outroActions, texts, newTextClickGroups, translators, clickText, new Fonts(new DataReader(fontsData)), encoding);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.ToString());

                Environment.Exit(-1);

                return;
            }

            dataHunk.Position = 0;
            var newDataHunk = BuildActionHunk(afterListPosition, outroActions, texts, dataHunk, encoding);

            int hunkIndex = introHunks.FindIndex(hunk => hunk.Type == AmigaExecutable.HunkType.Data);
            var hunk = introHunks[hunkIndex];
            introHunks[hunkIndex] = new AmigaExecutable.Hunk(AmigaExecutable.HunkType.Data, hunk.MemoryFlags, newDataHunk);

            var writer = new DataWriter();
            AmigaExecutable.Write(writer, introHunks);
            File.WriteAllBytes(args[1], writer.ToArray());

            Environment.Exit(0);
        }
        else
        {
            Console.WriteLine("No outro_texts.amb was found.");

            Environment.Exit(1);
        }
    }

    static byte[] BuildActionHunk
    (
        int afterListPosition, Dictionary<OutroOption, List<OutroAction>> outroActions,
        List<string> texts, Ambermoon.Data.Serialization.IDataReader dataHunk,
        Encoding encoding)
    {
        var output = new DataWriter();
        Dictionary<int, uint> pointersByTextIndex = [];
        uint actionOffset = (uint)afterListPosition + 9;

        output.Write(dataHunk.ReadBytes(64));

        // 3 sequences
        // 1. Uses 1 2 3 4 6
        // 2. Uses 1 2 3 5 6
        // 3. Uses 1 2 3 6

        var baseTextGroups = new Dictionary<OutroOption, List<List<OutroAction>>>();

        foreach (var actionList in outroActions)
        {
            var actions = actionList.Value;
            var clickGroups = new List<List<OutroAction>>(5);
            var clickGroup = new List<OutroAction>();

            baseTextGroups.Add(actionList.Key, clickGroups);
            clickGroups.Add(clickGroup);

            foreach (var action in actions)
            {
                if (action.Command == OutroCommand.ChangePicture)
                    continue;

                clickGroup.Add(action);

                if (action.Command == OutroCommand.WaitForClick)
                {
                    clickGroup = [];
                    clickGroups.Add(clickGroup);
                }
            }

            if (clickGroups[^1].Count == 0)
                clickGroups.RemoveAt(clickGroups.Count - 1);
        }

        var groups = new List<OutroAction>[6]
        {
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][0],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][1],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][2],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][3],
            baseTextGroups[OutroOption.ValdynInPartyWithYellowSphere][3],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][4]
        };
        var textGroups = new KeyValuePair<IDataWriter, uint>[6];

        for (int i = 0; i < 6; i++)
        {
            var writer = new DataWriter();
            textGroups[i] = KeyValuePair.Create<IDataWriter, uint>(writer, actionOffset);

            foreach (var textAction in groups[i])
            {
                if (textAction.Command == OutroCommand.PrintTextAndScroll)
                {
                    writer.Write((byte)(textAction.ScrollAmount - 1));
                    writer.Write((byte)textAction.TextDisplayX);
                    writer.Write((byte)(textAction.LargeText ? 1 : 0));
                    if (textAction.TextIndex != null)
                        writer.WriteNullTerminated(texts[textAction.TextIndex.Value], encoding);
                    else
                        writer.Write((byte)0);
                }
                else
                {
                    Console.WriteLine();
                }
            }

            writer.Write((byte)0xff); // wait for click

            actionOffset += (uint)writer.Size;
        }

        // 3 sequences
        // 1. Uses 1 2 3 4 6
        // 2. Uses 1 2 3 5 6
        // 3. Uses 1 2 3 6
        List<int>[] sequences =
        [
            [ 1, 2, 3, 4, 6 ], [ 1, 2, 3, 5, 6 ], [ 1, 2, 3, 6 ],
        ];

        for (int i = 0; i < 3; i++)
        {
            var sequence = sequences[i];

            for (int s = 0; s < sequence.Count; s++)
            {
                int clickGroupIndex = sequence[s] - 1;
                output.Write(textGroups[clickGroupIndex].Value);
                dataHunk.Position += 4;

                output.Write(dataHunk.ReadDword());
            }

            var zero = dataHunk.ReadDword(); // Should be zero

            if (zero != 0)
                throw new Exception("Expected 0 pointer.");

            output.Write(zero);
        }

        // Now there should be an intermediate section
        byte[] expected = [0x80, 0, 0, 0, 0x80, 0, 0, 0, 0xff];

        for (int i = 0; i < expected.Length; i++)
        {
            if (dataHunk.ReadByte() != expected[i])
                throw new Exception("Wrong intermediate byte.");

            output.Write(expected[i]);
        }

        for (int i = 0; i < 6; i++)
            output.Write(textGroups[i].Key.ToArray());

        output.Write((byte)0); // end marker

        while (output.Size % 4 != 0) // align to long boundary
            output.Write((byte)0);

        return output.ToArray();
    }

    static void PatchTexts
    (
        Dictionary<OutroOption, List<OutroAction>> outroActions,
        List<string> oldTexts, List<List<string>>[] newTextGroups,
        List<string> translators, string clickText,
        Fonts fonts, Encoding encoding
    )
    {
        int MeasureTextWidth(string text)
        {
            int spaceAdvance = fonts.SmallSpaceAdvance;
            byte[] advanceValues = fonts.SmallAdvanceValues;
            int width = 0;

            foreach (var ch in encoding.GetBytes(text))
            {
                if (ch == 0x20)
                    width += spaceAdvance;
                else
                {
                    int glyphIndex = fonts.GlyphMapping[ch - 32];

                    if (glyphIndex != 255)
                        width += advanceValues[glyphIndex];
                }
            }

            return width;
        }

        const int maxLineWidth = 320 - 12; // small texts usually start at X = 12

        if (newTextGroups.Length != 6)
            throw new Exception("Wrong count of outro text groups.");

        // Texts starting with an underscore are large texts.
        // Texts starting with a single dollar sign mark the name of the translator dummy.
        // Texts starting with two dollar signs mark the description of the translator.
        var processedTexts = new List<string[]>[6];

        string[] GetWords(string line)
        {
            if (string.IsNullOrWhiteSpace(line))
                return [];

            if (line.StartsWith(' '))
            {
                int wordStartIndex = 0;

                while (line[wordStartIndex++] == ' ')
                    ;

                int wordEndIndex = line.IndexOf(' ', wordStartIndex + 1);

                if (wordEndIndex == -1) // only one word
                    return [line];

                return [.. Enumerable.Concat([line[0..wordEndIndex]], line[(wordEndIndex + 1)..].Split(' '))];
            }
            else
            {
                return line.Split(' ');
            }
        }

        bool IsLarge(string text)
        {
            if (text.Length == 0) return false;
            if (text[0] == '_') return true;
            return text.StartsWith("$_");
        }

        // This will re-arrange text lines to fit into the max line length-
        // It may add or remove some lines but won't touch large text lines
        // (headings) or the click texts.
        #region Process text lines
        int clickGroupIndex = 0;
        foreach (var clickGroup in newTextGroups)
        {
            var processedClickGroup = new List<string[]>(clickGroup.Count);

            foreach (var group in clickGroup)
            {
                var processedGroup = new List<string>(group.Count);

                for (int i = 0; i < group.Count; ++i)
                {
                    group[i] = group[i].TrimEnd();
                    var text = group[i];

                    if (text.StartsWith('$'))
                    {
                        processedGroup.Add(text);
                        continue;
                    }

                    if (IsLarge(text))
                    {
                        processedGroup.Add(text);
                        continue;
                    }

                    if (i == group.Count - 1) // can't move excess text to next line in this case
                    {
                        string remainingText = text.Trim();

                        while (remainingText.Length != 0)
                        {
                            if (MeasureTextWidth(remainingText) > maxLineWidth)
                            {
                                var words = GetWords(remainingText);

                                if (MeasureTextWidth(words[0]) > maxLineWidth)
                                    throw new Exception("Outro text could not be fit in.");

                                string fitText = words[0];

                                for (int w = 1; w < words.Length; ++w)
                                {
                                    if (MeasureTextWidth(fitText) + fonts.SmallSpaceAdvance + MeasureTextWidth(words[w]) > maxLineWidth)
                                        break;

                                    fitText += " " + words[w];
                                }

                                remainingText = remainingText[fitText.Length..].TrimStart();
                                processedGroup.Add(fitText);
                            }
                            else
                            {
                                processedGroup.Add(remainingText);
                                break;
                            }
                        }
                    }
                    else
                    {
                        bool moveExceedingWordsToNextLine = true;

                        // Check if words of the next line fit into the current line
                        var nextWords = GetWords(group[i + 1].TrimEnd());

                        if (nextWords.Length != 0)
                        {
                            var words = GetWords(text);
                            int lineLength = MeasureTextWidth(text);
                            int consumedNextWords = 0;

                            // + 1 as we need a space character in between
                            while (consumedNextWords < nextWords.Length && lineLength + fonts.SmallSpaceAdvance + MeasureTextWidth(nextWords[consumedNextWords]) <= maxLineWidth)
                            {
                                // Add the word to the current line
                                group[i] += " " + nextWords[consumedNextWords++];
                                lineLength = MeasureTextWidth(group[i]);
                            }

                            // Remove moved words from next line
                            if (consumedNextWords != 0)
                            {
                                group[i + 1] = string.Join(' ', nextWords.Skip(consumedNextWords));

                                // Note: in this case it does not make sense to move words of
                                // the current line to the next line.
                                moveExceedingWordsToNextLine = false;
                            }
                        }

                        if (moveExceedingWordsToNextLine)
                        {
                            var words = new List<string>(GetWords(text));

                            while (MeasureTextWidth(group[i]) > maxLineWidth)
                            {
                                if (words.Count == 1)
                                    throw new Exception("Outro text could not be fit in.");

                                group[i + 1] = words[^1] + " " + group[i + 1];
                                words.RemoveAt(words.Count - 1);
                                group[i] = string.Join(' ', words);
                            }
                        }

                        if (group[i].Trim().Length != 0)
                            processedGroup.Add(group[i]);
                    }
                }

                processedClickGroup.Add(processedGroup.ToArray());
            }

            processedTexts[clickGroupIndex++] = processedClickGroup;
        }
        #endregion

        var baseTextGroups = GroupActions(outroActions.SelectMany(action => action.Value.Select(a => KeyValuePair.Create(action.Key, a))));
        var groups = new ClickGroup[6]
        {
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][0],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][1],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][2],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][3],
            baseTextGroups[OutroOption.ValdynInPartyWithYellowSphere][3],
            baseTextGroups[OutroOption.ValdynInPartyNoYellowSphere][4]
        };
        var newActionLists = new List<OutroAction>[6] { [], [], [], [], [], [] };
        oldTexts.Clear();

        static string ProcessText(string text)
        {
            return (text[0] == '_' ? text[1..] : text).Trim();
        }

        // If in the source there was only 1 line of text but
        // we have to split it into 2 or more lines due to its
        // length in the translation, we need to know how much
        // the first text should scroll.
        const int DefaultSmallTextScroll = 13;

        for (int i = 0; i < 6; ++i)
        {
            var clickGroup = groups[i];
            var newTexts = processedTexts[i];
            int groupIndex = 0;
            var newActions = newActionLists[i];

            foreach (var textGroup in clickGroup.Groups)
            {
                if (textGroup.ChangePictureAction != null)
                    newActions.Add(textGroup.ChangePictureAction.Value);

                var texts = newTexts[groupIndex++];
                int t;

                for (t = 0; t < textGroup.TextActions.Count; ++t)
                {
                    if (t == texts.Length)
                    {
                        // The translation needs fewer text lines.
                        // We need to use the last scroll amount.
                        var lastTextAction = textGroup.TextActions.Skip(t).LastOrDefault(a => a.Command == OutroCommand.PrintTextAndScroll && a.TextIndex != null);
                        if (lastTextAction.TextIndex != null)
                            newActions[^1] = newActions[^1] with { ScrollAmount = lastTextAction.ScrollAmount };
                        break;
                    }

                    var textAction = textGroup.TextActions[t];

                    if (textAction.Command == OutroCommand.WaitForClick ||
                        textAction.TextIndex == null)
                        break;

                    bool largeText = texts[t][0] == '_';

                    if (largeText && !textAction.LargeText)
                        break;

                    textAction = textAction with { TextIndex = oldTexts.Count };
                    if (translators.Count > 0 && texts[t].StartsWith('$') && !texts[t].StartsWith("$$"))
                    {
                        oldTexts.Add(ProcessText(translators[0]));
                        newActions.Add(textAction);
                    }
                    else if (translators.Count > 1 && texts[t].StartsWith("$$"))
                    {
                        oldTexts.Add(ProcessText(texts[t]));
                        newActions.Add(textAction);

                        for (int tr = 1; tr < translators.Count; ++tr)
                        {
                            var translatorTextAction = newActions[^2] with { TextIndex = oldTexts.Count };
                            var translatorDescAction = newActions[^1];
                            oldTexts.Add(ProcessText(translators[tr]));
                            newActions.Add(translatorTextAction);
                            newActions.Add(translatorDescAction);
                        }
                    }
                    else
                    {
                        oldTexts.Add(ProcessText(texts[t]));
                        newActions.Add(textAction);
                    }

                    if (t != 0 && largeText)
                        throw new Exception("Invalid text patch data.");
                }

                int preT = t;

                if (t < texts.Length)
                {
                    var lastAction = newActions[^1];

                    // More texts but not enough actions.
                    int lastScrollAmount = lastAction.ScrollAmount;
                    lastAction = newActions[^1] = lastAction with { ScrollAmount = DefaultSmallTextScroll };
                    OutroAction textAction;

                    while (t < texts.Length - 1)
                    {
                        textAction = lastAction with { TextIndex = oldTexts.Count };
                        oldTexts.Add(texts[t++]); // no need for ProcessText as the text is always small
                        newActions.Add(textAction);
                    }

                    textAction = lastAction with { TextIndex = oldTexts.Count, ScrollAmount = lastScrollAmount };
                    oldTexts.Add(texts[t++]); // no need for ProcessText as the text is always small
                    newActions.Add(textAction);
                }

                if (preT < textGroup.TextActions.Count)
                {
                    var emptyTextActions = textGroup.TextActions.Skip(preT).Where(x => x.TextIndex == null);

                    if (emptyTextActions.Any())
                    {
                        if (emptyTextActions.Count() != 1)
                            throw new Exception("Invalid text patch data.");

                        newActions.Add(emptyTextActions.First());
                    }
                    else if (textGroup.TextActions.Any(a => a.Command == OutroCommand.PrintTextAndScroll && a.TextIndex == null))
                        throw new Exception("Invalid text patch data.");
                }
                else if (textGroup.TextActions.Any(a => a.Command == OutroCommand.PrintTextAndScroll && a.TextIndex == null))
                    throw new Exception("Invalid text patch data.");
            }
        }

        var groupMappings = new List<int>[3]
        {
            [0, 1, 2, 3, 5],
            [0, 1, 2, 4, 5],
            [0, 1, 2, 5],
        };

        // Re-assign the new action lists
        for (int i = 0; i < 3; ++i)
        {
            outroActions[(OutroOption)i] = groupMappings[i].SelectMany(index => newActionLists[index]).ToList();
        }
    }

    struct ClickGroup
    {
        public struct Group
        {
            public OutroAction? ChangePictureAction;
            public bool Large;
            public List<OutroAction> TextActions;
        }

        public List<Group> Groups;
    }

    static Dictionary<OutroOption, List<ClickGroup>> GroupActions(IEnumerable<KeyValuePair<OutroOption, OutroAction>> input)
    {
        var inputList = new List<KeyValuePair<OutroOption, OutroAction>>(input);
        var firstTextItem = inputList.First(item => item.Value.TextIndex != null);
        int firstTextItemIndex = inputList.IndexOf(firstTextItem);
        var clickGroups = new Dictionary<OutroOption, List<ClickGroup>>();
        var currentGroups = new List<ClickGroup.Group>();
        var currentGroup = new ClickGroup.Group()
        {
            TextActions = new List<OutroAction>()
            {
                firstTextItem.Value,
            },
            Large = firstTextItem.Value.LargeText,
            ChangePictureAction = inputList[0].Value.Command == OutroCommand.ChangePicture ? inputList[0].Value : null,
        };

        void FinishCurrentGroup()
        {
            // If the group only consists of a single empty scroll action
            // we just add it to the last group instead.
            if (currentGroup.TextActions.Count == 1 &&
                currentGroup.TextActions[0].Command == OutroCommand.PrintTextAndScroll &&
                currentGroup.TextActions[0].TextIndex == null)
            {
                currentGroups[^1].TextActions.Add(currentGroup.TextActions[0]);
            }
            else
            {
                currentGroups.Add(currentGroup);
            }
            currentGroup = new()
            {
                TextActions = new()
            };
        }

        void FinishCurrentClickGroup(OutroOption option)
        {
            FinishCurrentGroup();
            var clickGroup = new ClickGroup() { Groups = new(currentGroups) };
            if (!clickGroups.TryGetValue(option, out var optionClickGroups))
                clickGroups.Add(option, new() { clickGroup });
            else
                optionClickGroups.Add(clickGroup);
            currentGroups.Clear();
        }

        foreach (var item in inputList.Skip(firstTextItemIndex + 1))
        {
            if (item.Value.Command == OutroCommand.WaitForClick)
            {
                currentGroup.TextActions.Add(item.Value);
                FinishCurrentClickGroup(item.Key);
                continue;
            }

            if (item.Value.Command == OutroCommand.ChangePicture)
            {
                currentGroup.ChangePictureAction = item.Value;
                continue;
            }

            if (item.Value.LargeText)
            {
                if (currentGroup.TextActions.Count > 0)
                    FinishCurrentGroup();
                currentGroup.Large = true;
            }
            else if (currentGroup.TextActions.Count > 0)
            {
                var lastAction = currentGroup.TextActions[^1];

                if (lastAction.Command == OutroCommand.PrintTextAndScroll && !lastAction.LargeText)
                {
                    // When text indentation changes or the previous text is an empty scroll
                    // action, we will create a new paragraph group. Also if the last scroll
                    // amount was greater than the current one.
                    if (item.Value.TextIndex != null && (lastAction.TextIndex == null || lastAction.TextDisplayX != item.Value.TextDisplayX || lastAction.ScrollAmount > item.Value.ScrollAmount))
                    {
                        FinishCurrentGroup();
                    }

                    // At the end of a paragraph there is a different scroll offset but this is
                    // provide by the last line of the paragraph so this line must be included
                    // in the current group. So in this case first add the action and then finish
                    // the group. We only do this if the scroll amount gets bigger as this indicates
                    // the paragraph end. If it gets smaller it was a single line of text in the
                    // paragraph which is handled above.
                    else if (item.Value.TextIndex != null && lastAction.ScrollAmount < item.Value.ScrollAmount)
                    {
                        currentGroup.TextActions.Add(item.Value);
                        FinishCurrentGroup();
                        continue;
                    }
                }
            }

            currentGroup.TextActions.Add(item.Value);
        }

        if (currentGroup.TextActions.Count > 0)
            FinishCurrentClickGroup(input.Last().Key);

        return clickGroups;
    }
}
