namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;

/// Writes Text.amb (file 1).
struct TextContainerWriter
{
    /// Writes the texts; with `withProcessedUIPlaceholders` the placeholders of the UI texts are "{0:00}" and so on
    /// (as [TextContainerReader.ReadTextContainer] reads them with processUIPlaceholders), else numbers ("0", "01",
    /// ...). Sizes are counted in characters as in the original (one byte each in the encoding).
    /// @error there are not 3 world names, a multi-line message lacks the mouse click message, a section has the
    /// wrong number of texts or a placeholder is too long.
    static Error<void> WriteTextContainer(TextContainer textContainer, ref DataWriter writer, bool withProcessedUIPlaceholders)
    {
        if (textContainer.WorldNames.Count() != 3)
            return error($"[Data] Invalid number of world names: {textContainer.WorldNames.Count()}, expected: 3.");

        int formatMessageDataSize = 0;
        foreach (var name in textContainer.WorldNames)
            formatMessageDataSize += LengthNet(name) + 1;

        var formatMessages = List<string>.Create(textContainer.FormatMessages.Count() + 24);
        foreach (var message in textContainer.FormatMessages)
            formatMessages.Add(message);

        if (formatMessages.Count() < 6)
            return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
        formatMessages[4] = try _WithoutMouseClickMessage(formatMessages[4]);
        formatMessages[5] = try _WithoutMouseClickMessage(formatMessages[5]);

        // split the format messages at their placeholders
        for (var i = 0; i < _MergeInfos.Length / 3; i += 1)
        {
            int formatMessageIndex = _MergeInfos[i * 3];
            if (formatMessageIndex >= formatMessages.Count())
                return error("Index was out of range. Must be non-negative and less than the size of the collection. (Parameter 'index')");
            var parts = _SplitAtBraces(formatMessages[formatMessageIndex]); // there is a '0' where a placeholder would be
            bool placeholder = _MergeInfos[i * 3 + 1] != 0;
            bool first = true;
            int index = formatMessageIndex;

            for (var p = 0; p < _MergeInfos[i * 3 + 2]; p += 1)
            {
                if (!placeholder)
                {
                    if (p >= parts.Count())
                        return error("Index was outside the bounds of the array.");
                    if (first)
                    {
                        formatMessages[index] = parts[p];
                        first = false;
                    }
                    else
                        formatMessages.Insert(index, parts[p]);
                    index += 1;
                }

                placeholder = !placeholder;
            }
        }

        int numFormatMessageOffsets = textContainer.WorldNames.Count() + formatMessages.Count();
        foreach (var message in formatMessages)
            formatMessageDataSize += LengthNet(message) + 1; // +1 for terminating 0, or 0xff for multi-line strings
        int formatMessageDataSizeInLongs = (formatMessageDataSize + 3) >> 2;

        writer.WriteWord((uint16)formatMessageDataSizeInLongs);
        writer.WriteWord((uint16)numFormatMessageOffsets);

        int offset = 0;
        foreach (var name in textContainer.WorldNames)
        {
            writer.WriteWord((uint16)(offset & 0xffff));
            offset += LengthNet(name) + 1;
        }
        foreach (var message in formatMessages)
        {
            writer.WriteWord((uint16)(offset & 0xffff));
            offset += LengthNet(message) + 1;
        }

        foreach (var name in textContainer.WorldNames)
            _WriteNullTerminated(ref writer, name);

        for (var i = 0; i < formatMessages.Count(); i += 1)
        {
            if (i == 7 || i == 8)
            {
                // the lines of the multi-line messages end with 0s, the message with 0xff (as in the original also
                // after the 0 that ends every text: a message without a line break at its end is one byte longer
                // than its offsets say)
                var lines = formatMessages[i].Replace("\n", "\0");
                int end = lines.Length;
                while (end > 0 && lines[end - 1] == 0)
                    end -= 1;
                _WriteNullTerminated(ref writer, lines[0..end]);
                writer.WriteByte(0xff);
            }
            else
                _WriteNullTerminated(ref writer, formatMessages[i]);
        }

        while (formatMessageDataSize % 4 != 0)
        {
            writer.WriteByte(0);
            formatMessageDataSize += 1;
        }

        try _WriteTextSection(ref writer, textContainer.Messages, null, withProcessedUIPlaceholders);
        try _WriteSimpleTextSection(ref writer, textContainer.AutomapTypeNames, 17);
        try _WriteSimpleTextSection(ref writer, textContainer.OptionNames, 5);
        try _WriteSimpleTextSection(ref writer, textContainer.MusicNames, 32);
        try _WriteSimpleTextSection(ref writer, textContainer.SpellClassNames, 7);
        try _WriteSimpleTextSection(ref writer, textContainer.SpellNames, 210);
        try _WriteSimpleTextSection(ref writer, textContainer.LanguageNames, 8);
        try _WriteSimpleTextSection(ref writer, textContainer.ClassNames, 11);
        try _WriteSimpleTextSection(ref writer, textContainer.RaceNames, 15);
        try _WriteSimpleTextSection(ref writer, textContainer.SkillNames, 10);
        try _WriteSimpleTextSection(ref writer, textContainer.AttributeNames, 9);
        try _WriteSimpleTextSection(ref writer, textContainer.SkillShortNames, 10);
        try _WriteSimpleTextSection(ref writer, textContainer.AttributeShortNames, 8);
        try _WriteSimpleTextSection(ref writer, textContainer.ItemTypeNames, 20);
        try _WriteSimpleTextSection(ref writer, textContainer.ConditionNames, 16);
        try _WriteTextSection(ref writer, textContainer.UITexts, textContainer.UITextWithPlaceholderIndices, withProcessedUIPlaceholders);

        int versionStringLength = (LengthNet(textContainer.VersionString) + 1 + 3) >> 2;
        int dateAndLanguageStringLength = (LengthNet(textContainer.DateAndLanguageString) + 1 + 3) >> 2;

        writer.WriteByte((uint8)(versionStringLength & 0xff));
        writer.WriteByte((uint8)(dateAndLanguageStringLength & 0xff));

        _WriteNullTerminated(ref writer, textContainer.VersionString);
        for (var i = 0; i < versionStringLength * 4 - LengthNet(textContainer.VersionString) - 1; i += 1)
            writer.WriteByte(0);

        _WriteNullTerminated(ref writer, textContainer.DateAndLanguageString);
        for (var i = 0; i < dateAndLanguageStringLength * 4 - LengthNet(textContainer.DateAndLanguageString) - 1; i += 1)
            writer.WriteByte(0);

        return;
    }

    static Error<string> _WithoutMouseClickMessage(string text)
    {
        if (!EndsWithNet(text, MouseClickMessage))
            return error("[Data] Missing mouse click message in multi-line text.");
        // (the last characters, as in the original: after characters that the comparison ignores these are not the
        // mouse click message)
        int keep = LengthNet(text) - LengthNet(MouseClickMessage);
        return FirstCharactersNet(text, keep < 0 ? 0 : keep).ToString();
    }

    // `text.Split({'{', '}'}, RemoveEmptyEntries)`
    static List<string> _SplitAtBraces(string text)
    {
        var parts = List<string>.Create();
        int start = 0;
        for (var i = 0; i <= text.Length; i += 1)
        {
            if (i == text.Length || text[i] == '{' || text[i] == '}')
            {
                if (i > start)
                    parts.Add(text[start..i].ToString());
                start = i + 1;
            }
        }
        return parts;
    }

    static void _WriteNullTerminated(ref DataWriter writer, StringSlice text)
    {
        writer.WriteBytes(AmbermoonEncoding.GetBytes(text));
        writer.WriteByte(0);
    }

    // a section of texts with their lengths in front; texts with placeholders get entries 0xff, offset before their
    // length (the last placeholder first)
    static Error<void> _WriteTextSection(ref DataWriter writer, List<string> texts, Optional<List<int>> placeholderTextIndices,
                                         bool withProcessedUIPlaceholders)
    {
        int countPosition = writer.Position();
        writer.WriteWord(0); // reserve space for text count

        var processedTexts = List<string>.Create(texts.Count());
        int entryCount = texts.Count();

        for (var textIndex = 0; textIndex < texts.Count(); textIndex += 1)
        {
            string processedText = texts[textIndex];

            if (placeholderTextIndices is List<int> indices && indices.Contains(textIndex))
            {
                if (!withProcessedUIPlaceholders)
                {
                    // There is only 1 case with two placeholders and it stores the second placeholder first.
                    var offsets = _NumberPlaceholderOffsets(processedText);
                    for (var i = offsets.Count() - 1; i >= 0; i -= 1)
                    {
                        writer.WriteByte(0xff);
                        writer.WriteByte((uint8)(offsets[i] & 0xff));
                        entryCount += 1;
                    }
                }
                else
                {
                    while (_FindProcessedPlaceholder(processedText) is ProcessedPlaceholder placeholder)
                    {
                        if (placeholder.DigitCount < 1 || placeholder.DigitCount > 10)
                            return error("[Data] Placeholder length out of range (allowed is 1 to 10).");
                        var digits = StringBuilder.Create();
                        for (var d = 0; d < placeholder.DigitCount; d += 1)
                            digits.Append((char)('0' + d));
                        processedText = processedText[0..placeholder.Start] + digits.ToString() +
                                        processedText[placeholder.End..];
                        writer.WriteByte(0xff);
                        writer.WriteByte((uint8)(LengthNet(processedText[0..placeholder.Start]) & 0xff));
                        entryCount += 1;
                    }
                }
            }

            processedTexts.Add(processedText);
            writer.WriteWord((uint16)((LengthNet(processedText) + 1) & 0xffff));
        }

        writer.ReplaceWord(countPosition, (uint16)(entryCount & 0xffff));

        int start = writer.Position();

        foreach (var text in processedTexts)
            _WriteNullTerminated(ref writer, text);

        int size = writer.Position() - start;

        while (size % 4 != 0)
        {
            writer.WriteByte(0);
            size += 1;
        }
        return;
    }

    // the offsets (in characters) of the placeholders "0", "01", "012", ... "0123456789" in a text (the matches of
    // the regular expression 0(1(2(3(4(5(6(7(89?)?)?)?)?)?)?)?)? of the original)
    static List<int> _NumberPlaceholderOffsets(StringSlice text)
    {
        var offsets = List<int>.Create();
        int characterIndex = 0;
        int i = 0;
        while (i < text.Length)
        {
            if (text[i] != '0')
            {
                int length = text[i] < 0x80 ? 1 : text[i] < 0xE0 ? 2 : text[i] < 0xF0 ? 3 : 4;
                characterIndex += length == 4 ? 2 : 1;
                i += length;
                continue;
            }
            offsets.Add(characterIndex);
            int matched = 1;
            while (matched < 10 && i + matched < text.Length && text[i + matched] == '0' + matched)
                matched += 1;
            characterIndex += matched;
            i += matched;
        }
        return offsets;
    }

    // the first placeholder "{n:000}" of a text (the regular expression \{[0-9]+:([0-9]+)\} of the original); the
    // positions are bytes of the text
    static Optional<ProcessedPlaceholder> _FindProcessedPlaceholder(StringSlice text)
    {
        for (var i = 0; i < text.Length; i += 1)
        {
            if (text[i] != '{')
                continue;
            int p = i + 1;
            while (p < text.Length && text[p] >= '0' && text[p] <= '9')
                p += 1;
            if (p == i + 1 || p >= text.Length || text[p] != ':')
                continue;
            int digitsStart = p + 1;
            p = digitsStart;
            while (p < text.Length && text[p] >= '0' && text[p] <= '9')
                p += 1;
            if (p == digitsStart || p >= text.Length || text[p] != '}')
                continue;
            return ProcessedPlaceholder { Start = i, End = p + 1, DigitCount = p - digitsStart };
        }
        return null;
    }

    // a section of a given number of null-terminated texts; its size (in dwords) in front
    static Error<void> _WriteSimpleTextSection(ref DataWriter writer, List<string> texts, int expectedAmount)
    {
        if (texts.Count() != expectedAmount)
            return error($"[Data] Invalid number of text: {texts.Count()}, expected: {expectedAmount}.");

        int size = 0;
        foreach (var text in texts)
            size += LengthNet(text) + 1;

        writer.WriteWord((uint16)(((size + 3) >> 2) & 0xffff));

        foreach (var text in texts)
            _WriteNullTerminated(ref writer, text);

        while (size % 4 != 0)
        {
            writer.WriteByte(0);
            size += 1;
        }
        return;
    }
}

/// A placeholder "{n:000}" in a text: where it is (bytes) and its number of digits.
struct ProcessedPlaceholder
{
    int Start;
    int End;
    int DigitCount;
}
