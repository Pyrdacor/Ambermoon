namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.ExecutableData;

/// The text that the messages of several lines end with: wait for a click.
const string MouseClickMessage = "{{Click}}";

// how format messages with placeholders are merged from their parts: the index of the first part, whether it starts
// with a placeholder (1) or a text (0), the number of parts (texts and placeholders)
const ReadOnlySlice<int> _MergeInfos =
[
    0, 0, 5,
    3, 0, 3,
    12, 1, 2,
    13, 1, 4,
    15, 1, 6,
    18, 1, 2,
    19, 1, 2,
    20, 1, 2,
    21, 0, 3,
    23, 1, 4,
    25, 1, 6,
    28, 1, 4,
    30, 1, 4,
    32, 1, 4,
    34, 0, 3,
    36, 1, 4,
    38, 1, 6,
    41, 1, 2
];

/// Reads Text.amb (file 1).
struct TextContainerReader
{
    /// Reads the texts; with `processUIPlaceholders` the numbers in the texts that are placeholders ("0", "01", ...)
    /// become "{0:0}", "{1:00}" and so on.
    /// @error the data is damaged.
    static Error<TextContainer> ReadTextContainer(ref DataReader reader, bool processUIPlaceholders)
    {
        var container = TextContainer.Create();
        string invalidFormat = "[Data] Invalid format text data.";
        int formatMessageDataSizeInLongs = reader.ReadWord();
        int numFormatMessageOffsets = reader.ReadWord();
        var offsets = new int[numFormatMessageOffsets + 1];

        for (var i = 0; i < numFormatMessageOffsets; i += 1)
            offsets[i] = reader.ReadWord();
        offsets[numFormatMessageOffsets] = formatMessageDataSizeInLongs * 4;

        var data = reader.ReadBytes(formatMessageDataSizeInLongs * 4);
        if (reader.Overrun())
            return error(invalidFormat);

        // Avoid padding bytes in last text
        while (offsets[numFormatMessageOffsets] > 0 && data[offsets[numFormatMessageOffsets] - 1] == 0)
            offsets[numFormatMessageOffsets] -= 1;
        offsets[numFormatMessageOffsets] += 1;

        for (var i = 0; i < numFormatMessageOffsets; i += 1)
        {
            int start = offsets[i];
            int end = offsets[i + 1];
            if (start < 0 || end <= start || end > data.Length)
                return error(invalidFormat);
            var text = AmbermoonEncoding.GetString(data[start..end - 1]);

            if (i < 3)
            {
                if (data[end - 1] != 0)
                    return error(invalidFormat);
                container.WorldNames.Add(text);
            }
            else if (i == 10 || i == 11)
            {
                if (data[end - 1] != 0xff)
                    return error(invalidFormat);
                container.FormatMessages.Add(text.Replace("\0", "\n") + MouseClickMessage);
            }
            else
            {
                if (data[end - 1] != 0)
                    return error(invalidFormat);
                container.FormatMessages.Add(text);
            }
        }

        var messages = container.FormatMessages;
        for (var i = _MergeInfos.Length / 3 - 1; i >= 0; i -= 1)
        {
            int first = _MergeInfos[i * 3];
            bool placeholder = _MergeInfos[i * 3 + 1] != 0;
            int numParts = _MergeInfos[i * 3 + 2];
            var merged = StringBuilder.Create();
            int index = first;
            int deleteCount = 0;
            int placeholderIndex = 0;

            for (var p = 0; p < numParts; p += 1)
            {
                if (placeholder)
                {
                    merged.Append("{" + placeholderIndex.ToString() + "}");
                    placeholderIndex += 1;
                }
                else
                {
                    if (index >= messages.Count())
                        return error(invalidFormat);
                    merged.Append(messages[index]);
                    if (index > first)
                        deleteCount += 1;
                    index += 1;
                }
                placeholder = !placeholder;
            }

            for (var d = 0; d < deleteCount; d += 1)
                messages.RemoveAt(first + 1);
            messages[first] = merged.ToString();
        }

        try _ReadTextSection(ref reader, container.Messages, null, processUIPlaceholders);
        try _ReadSimpleTextSection(ref reader, container.AutomapTypeNames, 17);
        try _ReadSimpleTextSection(ref reader, container.OptionNames, 5);
        try _ReadSimpleTextSection(ref reader, container.MusicNames, 32);
        try _ReadSimpleTextSection(ref reader, container.SpellClassNames, 7);
        try _ReadSimpleTextSection(ref reader, container.SpellNames, 210);
        try _ReadSimpleTextSection(ref reader, container.LanguageNames, 8);
        try _ReadSimpleTextSection(ref reader, container.ClassNames, 11);
        try _ReadSimpleTextSection(ref reader, container.RaceNames, 15);
        try _ReadSimpleTextSection(ref reader, container.SkillNames, 10);
        try _ReadSimpleTextSection(ref reader, container.AttributeNames, 9);
        try _ReadSimpleTextSection(ref reader, container.SkillShortNames, 10);
        try _ReadSimpleTextSection(ref reader, container.AttributeShortNames, 8);
        try _ReadSimpleTextSection(ref reader, container.ItemTypeNames, 20);
        try _ReadSimpleTextSection(ref reader, container.ConditionNames, 16);
        try _ReadTextSection(ref reader, container.UITexts, container.UITextWithPlaceholderIndices, processUIPlaceholders);

        int versionStringLength = reader.ReadByte() * 4;
        int dateAndLanguageStringLength = reader.ReadByte() * 4;

        container.VersionString = AmbermoonEncoding.GetString(reader.ReadBytes(versionStringLength)).TrimEnd('\0').ToString();
        container.DateAndLanguageString = AmbermoonEncoding.GetString(reader.ReadBytes(dateAndLanguageStringLength)).TrimEnd('\0').ToString();

        return container;
    }

    // a section of texts with their lengths in front; lengths 0xffXX are offsets of placeholders in the next text
    // (only for the UI texts, whose indices with placeholders are noted)
    static Error<void> _ReadTextSection(ref DataReader reader, List<string> targetList,
                                        Optional<List<int>> placeholderIndicesToWrite, bool processUIPlaceholders)
    {
        int numberOfTexts = reader.ReadWord();
        var textLengths = new int[numberOfTexts];

        for (var i = 0; i < numberOfTexts; i += 1)
            textLengths[i] = reader.ReadWord();

        var placeholderOffsets = List<int>.Create();
        int textDataSize = 0;

        for (var i = 0; i < numberOfTexts; i += 1)
        {
            int textLength = textLengths[i];

            if ((textLength & 0xff00) == 0xff00)
            {
                if (placeholderIndicesToWrite is null)
                    return error("[Data] Invalid text section data.");

                // placeholder
                placeholderOffsets.Add(textLength & 0xff);
                continue;
            }

            textDataSize += textLength;
            // the bytes of the text as a string (one byte per character as in the original): the placeholders are
            // processed on them, then they are decoded
            var raw = reader.ReadBytes(textLength);
            if (reader.Overrun() || textLength == 0)
                return error("[Data] Invalid text section data.");
            int length = raw[textLength - 1] == 0 ? textLength - 1 : textLength;
            var text = string.FromBytes(raw, 0, length);

            if (placeholderIndicesToWrite is List<int> indices && placeholderOffsets.Count() != 0)
            {
                indices.Add(targetList.Count());

                if (processUIPlaceholders)
                    text = try _ProcessPlaceholders(text, placeholderOffsets);

                placeholderOffsets.Clear();
            }
            else if (processUIPlaceholders)
                text = NumbersToPlaceholders(text, true);

            targetList.Add(AmbermoonEncoding.GetString(text.AsBytes()));
        }

        while (textDataSize % 4 != 0)
        {
            textDataSize += 1;
            reader.Position += 1;
        }
        return;
    }

    // replaces the placeholders "0", "01", "012", ... at the offsets by "{0:0}", "{1:00}", ...
    static Error<string> _ProcessPlaceholders(string text, List<int> placeholderOffsets)
    {
        placeholderOffsets.Sort();

        for (var i = placeholderOffsets.Count() - 1; i >= 0; i -= 1)
        {
            int offset = placeholderOffsets[i];

            if (offset >= text.Length || text[offset] != '0') // expect 0123 etc
                return error("[Data] Invalid placeholder offset.");

            char digit = '1';
            int length = 1;

            while (offset + 1 < text.Length)
            {
                offset += 1;
                if (text[offset] != digit)
                    break; // end of placeholder
                digit += 1;
                length += 1;
                if (length == 10)
                    break; // max 10 digits
            }

            offset = placeholderOffsets[i];
            text = text[0..offset] + "{" + i.ToString() + ":" + "".PadLeft(length, '0') + "}" + text[offset + length..];
        }

        return text;
    }

    // a section of a given number of null-terminated texts; its size (in dwords) in front
    static Error<void> _ReadSimpleTextSection(ref DataReader reader, List<string> targetList, int amount)
    {
        int sizeInLongs = reader.ReadWord();
        int end = reader.Position + sizeInLongs * 4;

        for (var i = 0; i < amount; i += 1)
            targetList.Add(reader.ReadNullTerminatedString());

        if (reader.Position > end || end - reader.Position >= 4)
            return error("[Data] Invalid simple text section or text amount.");

        reader.Position = end;
        return;
    }
}
