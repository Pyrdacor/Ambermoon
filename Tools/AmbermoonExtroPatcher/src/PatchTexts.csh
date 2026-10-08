namespace AmbermoonExtroPatcher;

using System;
using Ambermoon;
using Ambermoon.Data.Text.Patching;

// small texts usually start at X = 12
const int MaxLineWidth = 320 - 12;

// If in the source there was only 1 line of text but we have to split it into 2 or more lines due to its length in
// the translation, we need to know how much the first text should scroll.
const int DefaultSmallTextScroll = 13;

/// The widths of texts in the fonts.
struct TextMeasure
{
    Fonts Fonts;
    TextPatchEncoding Encoding;

    /// @error a character is not in the font.
    Error<int> Width(StringSlice text, bool large)
    {
        int spaceAdvance = large ? Fonts.LargeSpaceAdvance : Fonts.SmallSpaceAdvance;
        var advanceValues = large ? Fonts.LargeAdvanceValues : Fonts.SmallAdvanceValues;
        int width = 0;

        foreach (var ch in Encoding.GetBytes(text))
        {
            if (ch == 0x20)
                width += spaceAdvance;
            else
            {
                if (ch < 32 || ch - 32 >= Fonts.GlyphMapping.Length)
                    return error("Index was outside the bounds of the array.");
                int glyphIndex = Fonts.GlyphMapping[ch - 32];

                if (glyphIndex != 255)
                {
                    if (glyphIndex >= advanceValues.Length)
                        return error("Index was outside the bounds of the array.");
                    width += advanceValues[glyphIndex];
                }
            }
        }

        return width;
    }
}

// the UTF-16 code units of a text (for the indices of .NET)
List<int> Utf16Units(StringSlice text)
{
    var units = List<int>.Create(text.Length);
    int i = 0;
    while (i < text.Length)
    {
        uint8 b = text[i];
        int length = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        if (i + length > text.Length)
            length = text.Length - i;
        int c = b;
        if (length > 1)
        {
            c = b & (0xFF >> (length + 1));
            for (var k = 1; k < length; k += 1)
                c = (c << 6) | (text[i + k] & 0x3F);
        }
        if (c > 0xFFFF)
        {
            units.Add(0xD800 + ((c - 0x10000) >> 10));
            units.Add(0xDC00 + ((c - 0x10000) & 0x3FF));
        }
        else
            units.Add(c);
        i += length;
    }
    return units;
}

// the byte offset of a UTF-16 index in a text
int ByteOffsetOf(StringSlice text, int unitIndex)
{
    int units = 0;
    int i = 0;
    while (i < text.Length && units < unitIndex)
    {
        uint8 b = text[i];
        int length = b < 0x80 ? 1 : b < 0xE0 ? 2 : b < 0xF0 ? 3 : 4;
        units += length == 4 ? 2 : 1;
        i += length;
    }
    return i < text.Length ? i : text.Length;
}

// `line.Split(' ')`
List<string> SplitAtSpaces(StringSlice line)
{
    var words = List<string>.Create();
    foreach (var part in line.Split(' '))
        words.Add(part.ToString());
    return words;
}

// the words of a line: split at spaces; a line that starts with spaces keeps them with its first word
Error<List<string>> GetWords(string line)
{
    if (IsWhiteSpaceOnlyNet(line))
        return List<string>.Create();

    if (line.StartsWith(" "))
    {
        var units = Utf16Units(line);
        int wordStartIndex = 0;

        while (units[wordStartIndex] == ' ')
            wordStartIndex += 1;
        wordStartIndex += 1;

        // (as in the original: the search starts 2 characters behind the first one of the word)
        int start = wordStartIndex + 1;
        if (start > units.Count())
            return error("Specified argument was out of the range of valid values. (Parameter 'startIndex')");
        int wordEndIndex = -1;
        for (var i = start; i < units.Count() && wordEndIndex < 0; i += 1)
        {
            if (units[i] == ' ')
                wordEndIndex = i;
        }

        var words = List<string>.Create();
        if (wordEndIndex == -1) // only one word
        {
            words.Add(line);
            return words;
        }

        int end = ByteOffsetOf(line, wordEndIndex);
        words.Add(line[0..end].ToString());
        foreach (var word in SplitAtSpaces(line[(end + 1)..]))
            words.Add(word);
        return words;
    }

    return SplitAtSpaces(line);
}

string JoinWithSpaces(List<string> words, int from)
{
    var result = StringBuilder.Create();
    for (var i = from; i < words.Count(); i += 1)
    {
        if (i > from)
            result.Append(" ");
        result.Append(words[i]);
    }
    return result.ToString();
}

bool IsLarge(string text)
{
    if (text.Length == 0)
        return false;
    if (text[0] == '_')
        return true;
    return StartsWithNet(text, "$_");
}

// the text without the "_" of large texts, trimmed
Error<string> ProcessText(string text)
{
    if (text.Length == 0)
        return error("Index was outside the bounds of the array.");
    return TrimNet(text[0] == '_' ? text[1..] : text).ToString();
}

// Re-arranges the text lines to fit into the max line length. It may add or remove some lines but won't touch large
// text lines (headings) or the click texts.
Error<List<List<string>>> ProcessTextLines(List<List<string>> clickGroup, TextMeasure measure)
{
    var processedClickGroup = List<List<string>>.Create(clickGroup.Count());

    foreach (var group in clickGroup)
    {
        var processedGroup = List<string>.Create(group.Count());

        for (var i = 0; i < group.Count(); i += 1)
        {
            group[i] = TrimEndNet(group[i]).ToString();
            var text = group[i];

            if (text.StartsWith("$"))
            {
                processedGroup.Add(text);
                continue;
            }

            if (IsLarge(text))
            {
                processedGroup.Add(text);
                continue;
            }

            if (i == group.Count() - 1) // can't move excess text to next line in this case
            {
                string remainingText = TrimNet(text).ToString();

                while (remainingText.Length != 0)
                {
                    if (try measure.Width(remainingText, false) > MaxLineWidth)
                    {
                        var words = try GetWords(remainingText);

                        if (try measure.Width(words[0], false) > MaxLineWidth)
                            return error("Outro text could not be fit in.");

                        string fitText = words[0];

                        for (var w = 1; w < words.Count(); w += 1)
                        {
                            if (try measure.Width(fitText, false) + measure.Fonts.SmallSpaceAdvance + try measure.Width(words[w], false) > MaxLineWidth)
                                break;

                            fitText += " " + words[w];
                        }

                        remainingText = TrimStartNet(remainingText[fitText.Length..]).ToString();
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
                var nextWords = try GetWords(TrimEndNet(group[i + 1]).ToString());

                if (nextWords.Count() != 0)
                {
                    int lineLength = try measure.Width(text, false);
                    int consumedNextWords = 0;

                    // + 1 as we need a space character in between
                    while (consumedNextWords < nextWords.Count() &&
                           lineLength + measure.Fonts.SmallSpaceAdvance + try measure.Width(nextWords[consumedNextWords], false) <= MaxLineWidth)
                    {
                        // Add the word to the current line
                        group[i] += " " + nextWords[consumedNextWords];
                        consumedNextWords += 1;
                        lineLength = try measure.Width(group[i], false);
                    }

                    // Remove moved words from next line
                    if (consumedNextWords != 0)
                    {
                        group[i + 1] = JoinWithSpaces(nextWords, consumedNextWords);

                        // Note: in this case it does not make sense to move words of the current line to the next
                        // line.
                        moveExceedingWordsToNextLine = false;
                    }
                }

                if (moveExceedingWordsToNextLine)
                {
                    var words = try GetWords(text);

                    while (try measure.Width(group[i], false) > MaxLineWidth)
                    {
                        if (words.Count() == 1)
                            return error("Outro text could not be fit in.");

                        group[i + 1] = words[words.Count() - 1] + " " + group[i + 1];
                        words.RemoveAt(words.Count() - 1);
                        group[i] = JoinWithSpaces(words, 0);
                    }
                }

                if (TrimNet(group[i]).Length != 0)
                    processedGroup.Add(group[i]);
            }
        }

        processedClickGroup.Add(processedGroup);
    }

    return processedClickGroup;
}

/// A group of actions of the extro: a paragraph or a heading, with the picture that it shows first.
struct TextGroup
{
    Optional<OutroAction> ChangePictureAction;
    bool Large;
    List<OutroAction> TextActions;
}

/// The action groups between two clicks.
struct ClickGroup
{
    List<TextGroup> Groups;
}

// the state of GroupActions
struct Grouping
{
    Dictionary<int, List<ClickGroup>> ClickGroups;
    List<TextGroup> CurrentGroups;
    TextGroup CurrentGroup;

    Error<void> FinishCurrentGroup()
    {
        // If the group only consists of a single empty scroll action we just add it to the last group instead.
        if (CurrentGroup.TextActions.Count() == 1 &&
            CurrentGroup.TextActions[0].Command == OutroCommand.PrintTextAndScroll &&
            CurrentGroup.TextActions[0].TextIndex == null)
        {
            if (CurrentGroups.Count() == 0)
                return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
            CurrentGroups[CurrentGroups.Count() - 1].TextActions.Add(CurrentGroup.TextActions[0]);
        }
        else
        {
            CurrentGroups.Add(CurrentGroup);
        }
        CurrentGroup = TextGroup { TextActions = List<OutroAction>.Create() };
        return;
    }

    Error<void> FinishCurrentClickGroup(int option)
    {
        try FinishCurrentGroup();
        var groups = List<TextGroup>.Create(CurrentGroups.Count());
        foreach (var group in CurrentGroups)
            groups.Add(group);
        var clickGroup = ClickGroup { Groups = groups };
        if (ClickGroups.TryGet(option) is List<ClickGroup> optionClickGroups)
            optionClickGroups.Add(clickGroup);
        else
        {
            var list = List<ClickGroup>.Create();
            list.Add(clickGroup);
            ClickGroups[option] = list;
        }
        CurrentGroups.Clear();
        return;
    }
}

// the actions of the three sequences grouped by clicks and in paragraphs and headings
Error<Dictionary<int, List<ClickGroup>>> GroupActions(List<List<OutroAction>> outroActions)
{
    var options = List<int>.Create();
    var items = List<OutroAction>.Create();
    for (var option = 0; option < outroActions.Count(); option += 1)
    {
        foreach (var action in outroActions[option])
        {
            options.Add(option);
            items.Add(action);
        }
    }

    int firstTextItemIndex = -1;
    for (var i = 0; i < items.Count() && firstTextItemIndex < 0; i += 1)
    {
        if (items[i].TextIndex != null)
            firstTextItemIndex = i;
    }
    if (firstTextItemIndex < 0)
        return error("Sequence contains no matching element");

    var firstTextItem = items[firstTextItemIndex];
    var firstActions = List<OutroAction>.Create();
    firstActions.Add(firstTextItem);
    Optional<OutroAction> firstPicture = null;
    if (items[0].Command == OutroCommand.ChangePicture)
        firstPicture = items[0];

    var grouping = Grouping
    {
        ClickGroups = Dictionary<int, List<ClickGroup>>.Create(),
        CurrentGroups = List<TextGroup>.Create(),
        CurrentGroup = TextGroup { TextActions = firstActions, Large = firstTextItem.LargeText, ChangePictureAction = firstPicture }
    };

    for (var index = firstTextItemIndex + 1; index < items.Count(); index += 1)
    {
        var item = items[index];

        if (item.Command == OutroCommand.WaitForClick)
        {
            grouping.CurrentGroup.TextActions.Add(item);
            try grouping.FinishCurrentClickGroup(options[index]);
            continue;
        }

        if (item.Command == OutroCommand.ChangePicture)
        {
            grouping.CurrentGroup.ChangePictureAction = item;
            continue;
        }

        if (item.LargeText)
        {
            if (grouping.CurrentGroup.TextActions.Count() > 0)
                try grouping.FinishCurrentGroup();
            grouping.CurrentGroup.Large = true;
        }
        else if (grouping.CurrentGroup.TextActions.Count() > 0)
        {
            var lastAction = grouping.CurrentGroup.TextActions[grouping.CurrentGroup.TextActions.Count() - 1];

            if (lastAction.Command == OutroCommand.PrintTextAndScroll && !lastAction.LargeText)
            {
                // When text indentation changes or the previous text is an empty scroll action, we will create a new
                // paragraph group. Also if the last scroll amount was greater than the current one.
                if (item.TextIndex != null && (lastAction.TextIndex == null || lastAction.TextDisplayX != item.TextDisplayX ||
                                               lastAction.ScrollAmount > item.ScrollAmount))
                {
                    try grouping.FinishCurrentGroup();
                }
                // At the end of a paragraph there is a different scroll offset but this is provide by the last line
                // of the paragraph so this line must be included in the current group. So in this case first add the
                // action and then finish the group. We only do this if the scroll amount gets bigger as this
                // indicates the paragraph end. If it gets smaller it was a single line of text in the paragraph which
                // is handled above.
                else if (item.TextIndex != null && lastAction.ScrollAmount < item.ScrollAmount)
                {
                    grouping.CurrentGroup.TextActions.Add(item);
                    try grouping.FinishCurrentGroup();
                    continue;
                }
            }
        }

        grouping.CurrentGroup.TextActions.Add(item);
    }

    if (grouping.CurrentGroup.TextActions.Count() > 0)
        try grouping.FinishCurrentClickGroup(options[options.Count() - 1]);

    return grouping.ClickGroups;
}

// the click groups of an option
Error<List<ClickGroup>> ClickGroupsOfOption(Dictionary<int, List<ClickGroup>> groups, int option)
{
    if (groups.TryGet(option) is List<ClickGroup> clickGroups)
        return clickGroups;
    return error($"The given key '{(option == 0 ? "ValdynInPartyNoYellowSphere" : option == 1 ? "ValdynInPartyWithYellowSphere" : "ValdynNotInParty")}' was not present in the dictionary.");
}

// the last text action of a group from an index on (default: an action without a text)
OutroAction LastTextActionFrom(List<OutroAction> actions, int from)
{
    var last = OutroAction { };
    for (var i = from; i < actions.Count(); i += 1)
    {
        if (actions[i].Command == OutroCommand.PrintTextAndScroll && actions[i].TextIndex != null)
            last = actions[i];
    }
    return last;
}

Error<void> PatchTexts(List<List<OutroAction>> outroActions, List<string> oldTexts, List<List<string>>[] newTextGroups,
                       List<string> translators, string clickText, Fonts fonts, TextPatchEncoding encoding,
                       List<int> clickTextIndices, int theEndTextIndex)
{
    var measure = TextMeasure { Fonts = fonts, Encoding = encoding };

    // Texts starting with an underscore are large texts. Texts starting with a single dollar sign mark the name of the
    // translator dummy. Texts starting with two dollar signs mark the description of the translator.
    var processedTexts = new List<List<string>>[6];
    for (var i = 0; i < 6; i += 1)
        processedTexts[i] = try ProcessTextLines(newTextGroups[i], measure);

    var baseTextGroups = try GroupActions(outroActions);
    var first = try ClickGroupsOfOption(baseTextGroups, 0);
    var second = try ClickGroupsOfOption(baseTextGroups, 1);
    var groups = try SixGroups(first, second);
    var newActionLists = new List<OutroAction>[6];
    for (var i = 0; i < 6; i += 1)
        newActionLists[i] = List<OutroAction>.Create();

    if (theEndTextIndex < 0 || theEndTextIndex >= oldTexts.Count())
        return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
    var oldTheEndText = oldTexts[theEndTextIndex];
    var oldClickText = clickTextIndices.Count() == 0 ? "<CLICK>" : oldTexts[clickTextIndices[0]];
    oldTexts.Clear();

    for (var i = 0; i < 6; i += 1)
    {
        var clickGroup = groups[i];
        var newTexts = processedTexts[i];
        int groupIndex = 0;
        var newActions = newActionLists[i];

        foreach (var textGroup in clickGroup.Groups)
        {
            if (textGroup.ChangePictureAction is OutroAction pictureAction)
                newActions.Add(pictureAction);

            if (groupIndex == newTexts.Count())
            {
                if (textGroup.TextActions.Count() != 1 || textGroup.TextActions[0].Command != OutroCommand.WaitForClick)
                    return error("[Data] Invalid extro data");

                break;
            }

            var texts = newTexts[groupIndex];
            groupIndex += 1;
            int t = 0;

            for (t = 0; t < textGroup.TextActions.Count(); t += 1)
            {
                if (t == texts.Count())
                {
                    // The translation needs fewer text lines. We need to use the last scroll amount.
                    var lastTextAction = LastTextActionFrom(textGroup.TextActions, t);
                    if (lastTextAction.TextIndex != null)
                    {
                        if (newActions.Count() == 0)
                            return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
                        var changed = newActions[newActions.Count() - 1];
                        changed.ScrollAmount = lastTextAction.ScrollAmount;
                        newActions[newActions.Count() - 1] = changed;
                    }
                    break;
                }

                var textAction = textGroup.TextActions[t];

                if (textAction.Command == OutroCommand.WaitForClick || textAction.TextIndex == null)
                    break;

                int actionTextIndex = textAction.TextIndex is int index ? index : -1;

                if (actionTextIndex == theEndTextIndex)
                {
                    var text = try ProcessText(texts[t]);

                    oldTexts.Add(text);

                    int oldWidth = try measure.Width(oldTheEndText, true);
                    int newWidth = try measure.Width(text, true);

                    textAction.TextIndex = oldTexts.Count() - 1;
                    if (oldWidth != newWidth)
                        textAction.TextDisplayX = textAction.TextDisplayX + (oldWidth - newWidth) / 2;

                    newActions.Add(textAction);

                    continue;
                }
                else if (clickTextIndices.Contains(actionTextIndex))
                {
                    oldTexts.Add(clickText);

                    int oldWidth = try measure.Width(oldClickText, true);
                    int newWidth = try measure.Width(clickText, true);

                    textAction.TextIndex = oldTexts.Count() - 1;
                    if (oldWidth != newWidth)
                        textAction.TextDisplayX = textAction.TextDisplayX + (oldWidth - newWidth) / 2;

                    newActions.Add(textAction);

                    continue;
                }

                if (texts[t].Length == 0)
                    return error("Index was outside the bounds of the array.");
                bool largeText = texts[t][0] == '_';

                if (largeText && !textAction.LargeText)
                    break;

                textAction.TextIndex = oldTexts.Count();
                if (translators.Count() > 0 && texts[t].StartsWith("$") && !StartsWithNet(texts[t], "$$"))
                {
                    oldTexts.Add(try ProcessText(translators[0]));
                    newActions.Add(textAction);
                }
                else if (translators.Count() > 1 && StartsWithNet(texts[t], "$$"))
                {
                    oldTexts.Add(try ProcessText(texts[t]));
                    newActions.Add(textAction);

                    for (var tr = 1; tr < translators.Count(); tr += 1)
                    {
                        var translatorTextAction = newActions[newActions.Count() - 2];
                        translatorTextAction.TextIndex = oldTexts.Count();
                        var translatorDescAction = newActions[newActions.Count() - 1];
                        oldTexts.Add(try ProcessText(translators[tr]));
                        newActions.Add(translatorTextAction);
                        newActions.Add(translatorDescAction);
                    }
                }
                else
                {
                    oldTexts.Add(try ProcessText(texts[t]));
                    newActions.Add(textAction);
                }

                if (t != 0 && largeText)
                    return error("[Data] Invalid text patch data.");
            }

            int preT = t;

            if (t < texts.Count())
            {
                if (newActions.Count() == 0)
                    return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");

                // More texts but not enough actions.
                var lastAction = newActions[newActions.Count() - 1];
                int lastScrollAmount = lastAction.ScrollAmount;
                lastAction.ScrollAmount = DefaultSmallTextScroll;
                newActions[newActions.Count() - 1] = lastAction;

                while (t < texts.Count() - 1)
                {
                    var textAction = lastAction;
                    textAction.TextIndex = oldTexts.Count();
                    oldTexts.Add(texts[t]); // no need for ProcessText as the text is always small
                    t += 1;
                    newActions.Add(textAction);
                }

                var lastTextAction = lastAction;
                lastTextAction.TextIndex = oldTexts.Count();
                lastTextAction.ScrollAmount = lastScrollAmount;
                oldTexts.Add(texts[t]);
                t += 1;
                newActions.Add(lastTextAction);
            }

            bool anyEmptyText = false;
            foreach (var action in textGroup.TextActions)
            {
                if (action.Command == OutroCommand.PrintTextAndScroll && action.TextIndex == null)
                    anyEmptyText = true;
            }

            if (preT < textGroup.TextActions.Count())
            {
                var emptyTextActions = List<OutroAction>.Create();
                for (var e = preT; e < textGroup.TextActions.Count(); e += 1)
                {
                    if (textGroup.TextActions[e].TextIndex == null)
                        emptyTextActions.Add(textGroup.TextActions[e]);
                }

                if (emptyTextActions.Count() != 0)
                {
                    if (emptyTextActions.Count() != 1)
                        return error("Invalid text patch data.");

                    newActions.Add(emptyTextActions[0]);
                }
                else if (anyEmptyText)
                    return error("Invalid text patch data.");
            }
            else if (anyEmptyText)
                return error("Invalid text patch data.");
        }
    }

    const ReadOnlySlice<int> groupMappingLengths = [5, 5, 4];
    const ReadOnlySlice<int> groupMappings = [0, 1, 2, 3, 5, 0, 1, 2, 4, 5, 0, 1, 2, 5];
    int mappingStart = 0;

    // Re-assign the new action lists
    for (var i = 0; i < 3; i += 1)
    {
        var actions = List<OutroAction>.Create();
        for (var m = 0; m < groupMappingLengths[i]; m += 1)
        {
            foreach (var action in newActionLists[groupMappings[mappingStart + m]])
                actions.Add(action);
        }
        mappingStart += groupMappingLengths[i];
        outroActions[i] = actions;
    }

    return;
}
