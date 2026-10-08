namespace Ambermoon.Data.Legacy.ExecutableData;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;

// The parts of the data of the executable (ExecutableData/*.cs). Each reads its part at the position of the reader
// (the old executables) or takes the texts of Text.amb (the new ones, version 1.14 and later).

/// The small digits (5x5 pixels, color 1 on 0).
struct DigitGlyphs
{
    List<Graphic> Entries;

    static DigitGlyphs Read(ref DataReader reader)
    {
        return DigitGlyphs { Entries = _ReadGlyphs(ref reader, 10, 5, 5) };
    }
}

/// The glyphs of the font (6x6 pixels, color 1 on 0).
struct Glyphs
{
    List<Graphic> Entries;

    static Glyphs Read(ref DataReader reader)
    {
        return Glyphs { Entries = _ReadGlyphs(ref reader, 94, 6, 6) };
    }
}

// glyphs of 5 bytes each: the pixels of a row in the most significant bits
List<Graphic> _ReadGlyphs(ref DataReader reader, int count, int width, int height)
{
    var entries = List<Graphic>.Create(count);
    for (var i = 0; i < count; i += 1)
    {
        var graphic = Graphic.Create(width, height, 0);
        for (var y = 0; y < 5; y += 1)
        {
            uint8 line = reader.ReadByte();
            for (var x = 0; x < width; x += 1)
            {
                graphic.Data[x + y * width] = (uint8)((line & 0x80) >> 7);
                line = (uint8)(line << 1);
            }
        }
        entries.Add(graphic);
    }
    return entries;
}

/// A mouse cursor: its hotspot and graphic.
struct Cursor
{
    int16 HotspotX;
    int16 HotspotY;
    Graphic Graphic;
}

/// The mouse cursors.
struct Cursors
{
    List<Cursor> Entries;

    static Cursors Read(ref DataReader reader)
    {
        var info = GraphicInfo { Width = 16, Height = 16, Alpha = true, GraphicFormat = GraphicFormat.Palette3Bit, PaletteOffset = 24 };
        var entries = List<Cursor>.Create(28);
        for (var i = 0; i < 28; i += 1)
        {
            var x = (int16)reader.ReadWord();
            var y = (int16)reader.ReadWord();
            entries.Add(Cursor { HotspotX = x, HotspotY = y, Graphic = _Read(ref reader, info, 0) });
        }
        return Cursors { Entries = entries };
    }
}

/// The list of the files of the game in the executable: for each file the letter of its disk.
///
/// It starts with the offsets of the file entries (0: no entry). An entry starts with the number of the disk (1 to 10
/// for A to J) and the name; a split archive (1Map_data.amb, 2Map_data.amb, ...) has 4 disk numbers (0: not used) and
/// a name with '0' that becomes '1' to '4'. Files may be listed twice.
struct FileList
{
    /// The files and the letters of their disks.
    Dictionary<string, char> Entries;
    /// The entries in the order of the list, each with 0 to 4 file names (null where a split archive has no file).
    List<string[]> IndexedEntries;

    static FileList Create()
    {
        return FileList { Entries = Dictionary<string, char>.Create(), IndexedEntries = List<string[]>.Create() };
    }

    /// Reads the list at the position of the reader (behind it afterwards).
    static Error<FileList> Read(ref DataReader reader)
    {
        var list = Create();
        const int numEntries = 44;
        var offsets = new uint32[numEntries];
        int endOffset = reader.Position;

        for (var i = 0; i < numEntries; i += 1)
            offsets[i] = reader.ReadDword();

        for (var i = 0; i < numEntries; i += 1)
        {
            if (offsets[i] == 0)
            {
                list.IndexedEntries.Add(new string[0]);
                continue;
            }

            reader.Position = (int)offsets[i];
            try list.ReadFileEntry(ref reader);

            if (reader.Position > endOffset)
                endOffset = reader.Position;
        }

        reader.Position = endOffset;
        reader.AlignToWord();
        return list;
    }

    /// Reads an entry at the position of the reader.
    /// @error the disk number is 0.
    Error<void> ReadFileEntry(ref DataReader reader)
    {
        uint8 diskNumber = reader.ReadByte();

        if (reader.PeekByte() >= 0x20)
        {
            if (diskNumber == 0)
                return error("[Data] Invalid disk number 0.");
            string fileName = reader.ReadNullTerminatedString(TextEncoding.Latin1);
            Entries[fileName] = (char)('A' + diskNumber - 1);
            IndexedEntries.Add([fileName]);
        }
        else
        {
            reader.Position -= 1;
            var diskNumbers = reader.ReadBytes(4);
            var baseFileName = reader.ReadNullTerminatedString(TextEncoding.Latin1);
            var fileNames = new string[4];

            for (var d = 0; d < 4; d += 1)
            {
                if (diskNumbers[d] != 0)
                {
                    string fileName = baseFileName.Replace("0", ((char)('1' + d)).ToString());
                    Entries[fileName] = (char)('A' + diskNumbers[d] - 1);
                    fileNames[d] = fileName;
                }
            }

            IndexedEntries.Add(fileNames);
        }
        return;
    }
}

/// The names of the 3 worlds.
struct WorldNames
{
    Dictionary<World, string> Entries;

    static Error<WorldNames> FromNames(List<string> names)
    {
        if (names.Count() != 3)
            return error("[Data] Invalid number of world names.");
        var entries = Dictionary<World, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(World)i] = names[i];
        return WorldNames { Entries = entries };
    }

    static WorldNames Read(ref DataReader reader)
    {
        var entries = Dictionary<World, string>.Create();
        var offsets = new uint32[3];
        int endOffset = reader.Position;

        for (var i = 0; i < 3; i += 1)
            offsets[i] = reader.ReadDword();

        for (var i = 0; i < 3; i += 1)
        {
            reader.Position = (int)offsets[i];
            entries[(World)i] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
            if (reader.Position > endOffset)
                endOffset = reader.Position;
        }

        reader.Position = endOffset;
        reader.AlignToWord();
        return WorldNames { Entries = entries };
    }
}

/// The names of the automap types (none and wall have none).
struct AutomapNames
{
    Dictionary<AutomapType, string> Entries;

    static Error<AutomapNames> FromNames(List<string> names)
    {
        if (names.Count() != 17)
            return error("[Data] Invalid number of automap type names.");
        var entries = _NoneAndWall();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(AutomapType)((int)AutomapType.Riddlemouth + i)] = names[i];
        return AutomapNames { Entries = entries };
    }

    static AutomapNames Read(ref DataReader reader)
    {
        var entries = _NoneAndWall();
        var types = GetEnumValues<AutomapType>();
        for (var i = 2; i < 19; i += 1)
            entries[types[i]] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        reader.AlignToWord();
        return AutomapNames { Entries = entries };
    }

    static Dictionary<AutomapType, string> _NoneAndWall()
    {
        var entries = Dictionary<AutomapType, string>.Create();
        entries[AutomapType.None] = "";
        entries[AutomapType.Wall] = "";
        return entries;
    }
}

/// The names of the options.
struct OptionNames
{
    Dictionary<Option, string> Entries;

    static OptionNames FromNames(List<string> names)
    {
        var entries = Dictionary<Option, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Option)(1 << i)] = names[i];
        return OptionNames { Entries = entries };
    }

    static OptionNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Option, string>.Create();
        foreach (var type in GetEnumValues<Option>())
        {
            entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
            if (type == Option.CeilingTexture3D)
                break; // stop here
        }
        reader.AlignToWord();
        return OptionNames { Entries = entries };
    }
}

/// The names of the 32 songs.
struct SongNames
{
    Dictionary<Song, string> Entries;

    static Error<SongNames> FromNames(List<string> names)
    {
        if (names.Count() != 32)
            return error("[Data] Invalid number of songs.");
        var entries = Dictionary<Song, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Song)((int)Song.WhoSaidHiHo + i)] = names[i];
        return SongNames { Entries = entries };
    }

    static SongNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Song, string>.Create();
        for (var i = 1; i <= 32; i += 1)
        {
            var name = reader.ReadNullTerminatedString(TextEncoding.Latin1);
            if (IsWhiteSpaceOnlyNet(name))
                name = "No name";
            entries[(Song)i] = name;
        }
        reader.AlignToWord();
        return SongNames { Entries = entries };
    }
}

/// The names of the spell schools.
struct SpellTypeNames
{
    Dictionary<SpellSchool, string> Entries;

    static Error<SpellTypeNames> FromNames(List<string> names)
    {
        if (names.Count() != 7)
            return error("[Data] Invalid number of spell school names.");
        var entries = Dictionary<SpellSchool, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(SpellSchool)i] = names[i];
        return SpellTypeNames { Entries = entries };
    }

    static SpellTypeNames Read(ref DataReader reader)
    {
        var entries = Dictionary<SpellSchool, string>.Create();
        foreach (var type in GetEnumValues<SpellSchool>())
            entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        return SpellTypeNames { Entries = entries };
    }
}

/// The names of the spells, also per spell school (30 each).
struct SpellNames
{
    Dictionary<Spell, string> Entries;
    Dictionary<SpellSchool, List<string>> EntriesPerType;

    static Error<SpellNames> FromNames(List<string> names)
    {
        if (names.Count() != 210)
            return error("[Data] Invalid number of spell names.");
        var result = SpellNames { Entries = Dictionary<Spell, string>.Create(), EntriesPerType = Dictionary<SpellSchool, List<string>>.Create() };
        for (var i = 0; i < 7; i += 1)
            result.EntriesPerType[(SpellSchool)i] = List<string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
        {
            result.Entries[(Spell)(i + 1)] = names[i];
            result.EntriesPerType[(SpellSchool)(i / 30)].Add(names[i]);
        }
        return result;
    }

    static SpellNames Read(ref DataReader reader)
    {
        var result = SpellNames { Entries = Dictionary<Spell, string>.Create(), EntriesPerType = Dictionary<SpellSchool, List<string>>.Create() };
        result.Entries[Spell.None] = "";
        int spellIndex = 1; // we skip Spell.None as it has no text entry
        foreach (var type in GetEnumValues<SpellSchool>())
        {
            var list = List<string>.Create(30);
            result.EntriesPerType[type] = list;
            for (var i = 0; i < 30; i += 1)
            {
                var name = reader.ReadNullTerminatedString(TextEncoding.Latin1);
                result.Entries[(Spell)spellIndex] = name;
                spellIndex += 1;
                list.Add(name);
            }
        }
        return result;
    }
}

/// The names of the languages.
struct LanguageNames
{
    Dictionary<Language, string> Entries;

    static Error<LanguageNames> FromNames(List<string> names)
    {
        if (names.Count() != 8)
            return error("[Data] Invalid number of language names.");
        var entries = Dictionary<Language, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Language)(1 << i)] = names[i];
        return LanguageNames { Entries = entries };
    }

    static LanguageNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Language, string>.Create();
        entries[Language.None] = "";
        foreach (var type in GetEnumValues<Language>())
        {
            if (type != Language.None)
                entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        }
        return LanguageNames { Entries = entries };
    }
}

/// The names of the classes.
struct ClassNames
{
    Dictionary<Class, string> Entries;

    static Error<ClassNames> FromNames(List<string> names)
    {
        if (names.Count() < 9 || names.Count() > 11)
            return error("[Data] Invalid number of class names.");
        var entries = Dictionary<Class, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Class)i] = names[i];
        if (names.Count() < 10)
            entries[Class.Animal] = "";
        if (names.Count() < 11)
            entries[Class.Monster] = "";
        return ClassNames { Entries = entries };
    }

    static ClassNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Class, string>.Create();
        foreach (var type in GetEnumValues<Class>())
            entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        return ClassNames { Entries = entries };
    }
}

/// The names of the races.
struct RaceNames
{
    Dictionary<Race, string> Entries;

    static Error<RaceNames> FromNames(List<string> names)
    {
        if (names.Count() != 15)
            return error("[Data] Invalid number of race names.");
        var entries = Dictionary<Race, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Race)i] = names[i];
        entries[Race.Unknown15] = "";
        return RaceNames { Entries = entries };
    }

    static RaceNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Race, string>.Create();
        foreach (var type in GetEnumValues<Race>())
            entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        return RaceNames { Entries = entries };
    }
}

/// The names of the skills and their short names.
struct SkillNames
{
    Dictionary<Skill, string> Entries;
    Dictionary<Skill, string> ShortNames;

    static Error<SkillNames> FromNames(List<string> names, List<string> shortNames)
    {
        if (names.Count() != 10 || shortNames.Count() != 10)
            return error("[Data] Invalid number of skill names.");
        var result = SkillNames { Entries = Dictionary<Skill, string>.Create(), ShortNames = Dictionary<Skill, string>.Create() };
        for (var i = 0; i < names.Count(); i += 1)
        {
            result.Entries[(Skill)i] = names[i];
            result.ShortNames[(Skill)i] = shortNames[i];
        }
        return result;
    }

    static SkillNames Read(ref DataReader reader)
    {
        var result = SkillNames { Entries = Dictionary<Skill, string>.Create(), ShortNames = Dictionary<Skill, string>.Create() };
        foreach (var type in GetEnumValues<Skill>())
            result.Entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        return result;
    }

    void AddShortNames(ref DataReader reader)
    {
        foreach (var type in GetEnumValues<Skill>())
            ShortNames[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
    }
}

/// The names of the attributes and their short names (the age and the bonus spell damage have none).
struct AttributeNames
{
    Dictionary<Attribute, string> Entries;
    Dictionary<Attribute, string> ShortNames;

    static Error<AttributeNames> FromNames(List<string> names, List<string> shortNames)
    {
        if (names.Count() != 9 || shortNames.Count() != 8)
            return error("[Data] Invalid number of attribute names.");
        var result = AttributeNames { Entries = Dictionary<Attribute, string>.Create(), ShortNames = Dictionary<Attribute, string>.Create() };
        for (var i = 0; i < names.Count(); i += 1)
        {
            result.Entries[(Attribute)i] = names[i];
            if (i != 8)
                result.ShortNames[(Attribute)i] = shortNames[i];
        }
        result.Entries[Attribute.BonusSpellDamage] = "";
        result.ShortNames[Attribute.Age] = "";
        result.ShortNames[Attribute.BonusSpellDamage] = "";
        return result;
    }

    static AttributeNames Read(ref DataReader reader)
    {
        var result = AttributeNames { Entries = Dictionary<Attribute, string>.Create(), ShortNames = Dictionary<Attribute, string>.Create() };
        foreach (var type in GetEnumValues<Attribute>())
        {
            if (type != Attribute.BonusSpellDamage)
                result.Entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        }
        result.Entries[Attribute.BonusSpellDamage] = "";
        return result;
    }

    void AddShortNames(ref DataReader reader)
    {
        foreach (var type in GetEnumValues<Attribute>())
        {
            if (type != Attribute.Age && type != Attribute.BonusSpellDamage)
                ShortNames[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        }
        ShortNames[Attribute.Age] = "";
        ShortNames[Attribute.BonusSpellDamage] = "";
    }
}

/// The names of the item types.
struct ItemTypeNames
{
    Dictionary<ItemType, string> Entries;

    static Error<ItemTypeNames> FromNames(List<string> names)
    {
        if (names.Count() != 20)
            return error("[Data] Invalid number of item type names.");
        var entries = Dictionary<ItemType, string>.Create();
        for (var i = 0; i < names.Count(); i += 1)
            entries[(ItemType)(i + 1)] = names[i];
        return ItemTypeNames { Entries = entries };
    }

    static ItemTypeNames Read(ref DataReader reader)
    {
        var entries = Dictionary<ItemType, string>.Create();
        entries[ItemType.None] = "";
        foreach (var type in GetEnumValues<ItemType>())
        {
            if (type != ItemType.None)
                entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        }
        return ItemTypeNames { Entries = entries };
    }
}

/// The names of the conditions (the dead ones without a name of their own have the name of DeadCorpse).
struct ConditionNames
{
    Dictionary<Condition, string> Entries;

    static Error<ConditionNames> FromNames(List<string> names)
    {
        if (names.Count() != 16)
            return error("[Data] Invalid number of condition names.");
        var entries = Dictionary<Condition, string>.Create();
        entries[Condition.None] = "";
        for (var i = 0; i < names.Count(); i += 1)
            entries[(Condition)(1 << i)] = names[i];
        return _Fixed(entries);
    }

    static ConditionNames Read(ref DataReader reader)
    {
        var entries = Dictionary<Condition, string>.Create();
        entries[Condition.None] = "";
        foreach (var type in GetEnumValues<Condition>())
        {
            if (type != Condition.None)
                entries[type] = reader.ReadNullTerminatedString(TextEncoding.Latin1);
        }
        return _Fixed(entries);
    }

    static ConditionNames _Fixed(Dictionary<Condition, string> entries)
    {
        if (IsWhiteSpaceOnlyNet(entries[Condition.DeadAshes]))
            entries[Condition.DeadAshes] = entries[Condition.DeadCorpse];
        if (IsWhiteSpaceOnlyNet(entries[Condition.DeadDust]))
            entries[Condition.DeadDust] = entries[Condition.DeadCorpse];
        return ConditionNames { Entries = entries };
    }
}

/// The texts of the user interface; placeholders are "{0:00}" and so on.
struct UITexts
{
    Dictionary<UITextIndex, string> Entries;

    static Error<UITexts> FromNames(List<string> uiTexts)
    {
        if (uiTexts.Count() != 49)
            return error("[Data] Invalid number of UI texts.");
        var entries = Dictionary<UITextIndex, string>.Create();
        for (var i = 0; i < uiTexts.Count(); i += 1)
        {
            if (i < 11)
                entries[(UITextIndex)i] = uiTexts[i];
            else if (i == 11)
                entries[UITextIndex.BothSexes] = uiTexts[i];
            else if (i < 28)
                entries[(UITextIndex)(i - 1)] = uiTexts[i];
            else if (i < 39)
                entries[(UITextIndex)i] = uiTexts[i];
            else
                entries[(UITextIndex)(i + 2)] = uiTexts[i];
        }
        entries[UITextIndex.Placeholder2Digit] = "{0:00}";
        entries[UITextIndex.Placeholder2DigitInParentheses] = "({0:00})";
        return UITexts { Entries = entries };
    }

    /// Reads the texts: every number in them becomes a placeholder of its width.
    static UITexts Read(ref DataReader reader)
    {
        var entries = Dictionary<UITextIndex, string>.Create();
        foreach (var type in GetEnumValues<UITextIndex>())
            entries[type] = NumbersToPlaceholders(reader.ReadNullTerminatedString(TextEncoding.Latin1), false);
        reader.AlignToWord();
        return UITexts { Entries = entries };
    }
}

/// Replaces the numbers in a text by "{0:00}", "{1:000}", ... (the zeros as many as the digits). With 'zeroOnly' only
/// numbers starting with 0 and not followed by '~' (the regex "[0-9]+(?![~])" matches the digits before a last digit
/// that is followed by '~').
string NumbersToPlaceholders(string text, bool zeroOnly)
{
    var result = StringBuilder.Create();
    int count = 0;
    int i = 0;
    while (i < text.Length)
    {
        if (!Char.IsDigit(text[i]))
        {
            result.Append(text[i]);
            i += 1;
            continue;
        }
        int start = i;
        while (i < text.Length && Char.IsDigit(text[i]))
            i += 1;
        int end = i;
        if (zeroOnly && end < text.Length && text[end] == '~')
            end -= 1; // the last digit is followed by '~': the match is the digits before it (none if it is one)
        if (end > start && (!zeroOnly || text[start] == '0'))
        {
            result.Append("{" + count.ToString() + ":" + "".PadLeft(end - start, '0') + "}");
            count += 1;
        }
        else
            result.Append(text[start..end]);
        result.Append(text[end..i]);
    }
    return result.ToString();
}

/// The graphics of the buttons (32x13 pixels each).
struct Buttons
{
    Dictionary<ButtonType, Graphic> Entries;

    static Buttons Read(ref DataReader reader)
    {
        var info = GraphicInfo { Width = 32, Height = 13, Alpha = true, GraphicFormat = GraphicFormat.Palette3Bit, PaletteOffset = 24 };
        var entries = Dictionary<ButtonType, Graphic>.Create();
        foreach (var type in GetEnumValues<ButtonType>())
            entries[type] = _Read(ref reader, info, 0);
        reader.AlignToWord();
        return Buttons { Entries = entries };
    }
}

/// The messages of the game: the format messages (with placeholders "{0}", ...) and the other messages.
struct Messages
{
    List<string> Entries;

    /// The message of an index ("" if there is none).
    string GetEntry(MessageIndex index)
    {
        return (int)index >= Entries.Count() ? "" : Entries[(int)index];
    }

    static Error<Messages> FromNames(List<string> formatMessages, List<string> messages)
    {
        if (formatMessages.Count() != 26 || messages.Count() < 300)
            return error("[Data] Invalid number of messages.");

        var entries = List<string>.Create();
        entries.Add(""); // None
        for (var i = 0; i < 6; i += 1)
            entries.Add(formatMessages[i]);
        for (var i = 0; i < 11; i += 1)
            entries.Add("");
        for (var i = 6; i < formatMessages.Count(); i += 1)
            entries.Add(_FixMessage(formatMessages[i]));
        foreach (var message in messages)
            entries.Add(message);

        var result = Messages { Entries = entries };
        string textBlockMissing = entries.Count() <= (int)MessageIndex.TextBlockMissing ? "" : result.GetEntry(MessageIndex.TextBlockMissing);

        while (entries.Count() < (int)MessageIndex.Count)
            entries.Add(textBlockMissing);
        return result;
    }

    // The new Text.amb often prepends a format placeholder for the subject like "{0}'s weapon was broken!". In the old
    // loader from the executable those placeholders were not added and the remake code is based on that. So if we
    // encounter a placeholder at the start of the message, we remove it and adjust the following placeholder indices.
    static string _FixMessage(string message)
    {
        if (!message.StartsWith("{0}"))
            return message;
        var bytes = message[3..].AsBytes().ToArray();
        for (var i = 0; i + 2 < bytes.Length; i += 1)
        {
            // "\{[0-9]\}": the digit one less ('0' becomes '/')
            if (bytes[i] == '{' && Char.IsDigit(bytes[i + 1]) && bytes[i + 2] == '}')
            {
                bytes[i + 1] -= 1;
                i += 2;
            }
        }
        return string.FromBytes(bytes);
    }

    /// Reads the message sections (the reader at the start of the message sections behind the insert disk messages;
    /// behind all message sections afterwards).
    ///
    /// There are two text chunks. The first one contains sections: null-terminated texts or offset sections for texts
    /// split by placeholders (a word-aligned 0 dword, maybe more of them, then the offsets of the parts). The second
    /// chunk starts with the number of its entries as a dword (300), their lengths (words) and the texts.
    static Messages Read(ref DataReader reader)
    {
        var entries = List<string>.Create();

        while (_ReadText(ref reader, entries))
        {
        }

        int numTextEntries = (int)reader.ReadDword();
        var lengths = List<int>.Create(numTextEntries < 0 || numTextEntries > 100000 ? 0 : numTextEntries);

        for (var i = 0; i < numTextEntries && !reader.Overrun(); i += 1)
            lengths.Add(reader.ReadWord());

        foreach (var length in lengths)
            entries.Add(reader.ReadString(length, TextEncoding.Latin1).TrimEnd('\0').ToString());

        reader.AlignToWord();

        if (reader.PeekWord() == 0)
            reader.Position += 2;

        while (entries.Count() < (int)MessageIndex.Count)
            entries.Add("");

        return Messages { Entries = entries };
    }

    static bool _ReadText(ref DataReader reader, List<string> entries)
    {
        if (reader.Overrun() || reader.Position >= reader.Size())
            return false;

        // The next section starts with an amount of 300 as a dword. If we find it we stop reading by returning false.
        // For safety we will check if the value is lower than 0x1000 as the offsets here will be over 0x8000.
        var next = reader.PeekDword();
        var nextWord = next >> 8;

        if (nextWord > 0x100 && nextWord < 0x1000)
        {
            reader.Position -= 1;
            return false;
        }

        nextWord >>= 8;

        if (nextWord > 0x100 && nextWord < 0x1000)
        {
            reader.Position -= 2;
            return false;
        }

        nextWord >>= 8;

        if (nextWord > 0x100 && nextWord < 0x1000)
        {
            reader.Position -= 3;
            return false;
        }

        if (reader.PeekWord() == 0) // offset section / split text with placeholders
        {
            reader.AlignToWord();

            if (reader.PeekWord() != 0)
                return false; // (the original ends with an exception: "Invalid text section.")

            while (reader.PeekDword() == 0 && !reader.Overrun())
                reader.Position += 4;

            if (reader.PeekByte() != 0)
                reader.Position -= 2;

            var text = StringBuilder.Create();
            var offsets = List<uint32>.Create();
            int endOffset = reader.Position;
            uint32 firstOffset = 0xffffffff;

            while (reader.PeekByte() == 0 && (uint32)reader.Position < firstOffset && !reader.Overrun())
            {
                var offset = reader.ReadDword();

                if (offset != 0)
                {
                    if (offset < firstOffset)
                        firstOffset = offset;

                    offsets.Add(offset);
                }
            }

            for (var i = 0; i < offsets.Count(); i += 1)
            {
                reader.Position = (int)offsets[i];
                text.Append(reader.ReadNullTerminatedString(TextEncoding.Latin1));

                if (i != offsets.Count() - 1) // Insert placeholder
                    text.Append("{" + i.ToString() + "}");

                if (reader.Position > endOffset)
                    endOffset = reader.Position;
            }

            entries.Add(text.ToString());
            reader.Position = endOffset;
        }
        else // just a text
        {
            entries.Add(reader.ReadNullTerminatedString(TextEncoding.Latin1));

            bool sectionFollows = reader.PeekDword() == 0;

            while ((reader.PeekByte() == 0 || reader.PeekByte() == 0xff) && !reader.Overrun())
            {
                if (sectionFollows)
                {
                    if ((reader.PeekDword() & 0x0000ffff) > 0xff)
                        break;
                }
                else
                    sectionFollows = reader.PeekDword() == 0;

                reader.Position += 1;
            }
        }

        return !reader.Overrun();
    }
}
