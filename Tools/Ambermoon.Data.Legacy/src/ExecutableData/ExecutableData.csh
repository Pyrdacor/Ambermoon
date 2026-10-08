namespace Ambermoon.Data.Legacy.ExecutableData;

using System;
using Ambermoon;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

/// The data of the executable (AM2_CPU): graphics of the user interface, glyphs, cursors, palettes, the file list, the
/// names and messages, the buttons and the items. Since version 1.14 the texts are in Text.amb, the items in
/// Objects.amb and the buttons in Button_graphics.
///
/// The second data hunk contains palettes, texts, cursors, glyphs and their mappings, button graphics and items; the
/// code finds their offsets in it. The first data hunk contains the graphics of the user interface.
struct ExecutableData
{
    string DataVersionString;
    string DataInfoString;
    Optional<UIGraphics> UIGraphics;
    Optional<DigitGlyphs> DigitGlyphs;
    Optional<Glyphs> Glyphs;
    Optional<Cursors> Cursors;
    Optional<FileList> FileList;
    Optional<WorldNames> WorldNames;
    Optional<Messages> Messages;
    Optional<AutomapNames> AutomapNames;
    Optional<OptionNames> OptionNames;
    Optional<SongNames> SongNames;
    Optional<SpellTypeNames> SpellTypeNames;
    Optional<SpellNames> SpellNames;
    Optional<LanguageNames> LanguageNames;
    Optional<ClassNames> ClassNames;
    Optional<RaceNames> RaceNames;
    Optional<SkillNames> SkillNames;
    Optional<AttributeNames> AttributeNames;
    Optional<ItemTypeNames> ItemTypeNames;
    Optional<ConditionNames> ConditionNames;
    Optional<UITexts> UITexts;
    Optional<Buttons> Buttons;
    Optional<ItemManager> ItemManager;
    /// The palettes of the primary user interface, the automap and the secondary user interface.
    Graphic[] BuiltinPalettes;
    /// 9 vertical color gradients of the skies (RGBA): night, twilight and day of Lyramion, the forest moon and Morag.
    Graphic[] SkyGradients;
    /// 6 partial palettes (16 colors) that replace the first colors of the palette of a map: night and twilight of
    /// each world.
    Graphic[] DaytimePaletteReplacements;

    /// The data of the executable of loaded game data, and of Text.amb, Objects.amb and Button_graphics if it has them.
    /// @error the data is damaged.
    static Error<ExecutableData> FromGameData(GameData gameData)
    {
        return _FromGameData(gameData);
    }

    /// The data of the hunks of an executable (the executable of the original game, before version 1.14).
    static Error<ExecutableData> Create(List<Hunk> hunks)
    {
        return _Create(hunks, null, null, null);
    }

    static Error<ExecutableData> Create(List<Hunk> hunks, Optional<DataReader> textAmb, Optional<DataReader> objectsAmb,
                                        Optional<DataReader> buttonGraphics)
    {
        return _Create(hunks, textAmb, objectsAmb, buttonGraphics);
    }
}

Error<ExecutableData> _FromGameData(GameData gameData)
{
    var hunks = List<Hunk>.Create();
    if (_File1(gameData, "AM2_CPU") is DataReader exe)
        hunks = try AmigaExecutable.Read(exe);
    return _Create(hunks, _File1(gameData, "Text.amb"), _File1(gameData, "Objects.amb"), _File1(gameData, "Button_graphics"));
}

Error<ExecutableData> _Create(List<Hunk> hunks, Optional<DataReader> textAmb, Optional<DataReader> objectsAmb,
                              Optional<DataReader> buttonGraphics)
{
    var data = ExecutableData
    {
        DataVersionString = "",
        DataInfoString = "",
        BuiltinPalettes = new Graphic[3],
        SkyGradients = new Graphic[9],
        DaytimePaletteReplacements = new Graphic[6]
    };
    string invalid = "[Data] Invalid executable file.";

    int firstCode = -1;
    for (var i = 0; i < hunks.Count() && firstCode < 0; i += 1)
    {
        if (hunks[i].Type == HunkType.Code)
            firstCode = i;
    }

    if (firstCode < 0 && textAmb is null)
    {
        data.DataInfoString = "Unknown data version";
        return data;
    }

    var codeReader = firstCode < 0 ? DataReader.FromData(new uint8[0]) : DataReader.FromData(hunks[firstCode].Data);
    Optional<TextContainer> textContainer = null;

    if (textAmb is DataReader textReader)
    {
        textReader.Position = 0;
        var container = try TextContainerReader.ReadTextContainer(ref textReader, true);
        data.DataVersionString = container.VersionString;
        data.DataInfoString = container.DateAndLanguageString;
        textContainer = container;
    }
    else
    {
        codeReader.Position = 6;
        data.DataVersionString = codeReader.ReadNullTerminatedString(TextEncoding.Ambermoon);
        data.DataInfoString = codeReader.ReadNullTerminatedString(TextEncoding.Ambermoon);
    }

    var dataHunks = List<DataReader>.Create();
    foreach (var hunk in hunks)
    {
        if (hunk.Type == HunkType.Data)
            dataHunks.Add(DataReader.FromData(hunk.Data));
    }
    bool hasHunks = hunks.Count() > 0;
    // the reader of the second data hunk, where the most is read
    var reader = DataReader.FromData(new uint8[0]);

    if (hasHunks)
    {
        if (dataHunks.Count() < 2 || firstCode < 0)
            return error(invalid);

        // Note: First 160 bytes are copper commands which can be dynamically filled to move data to some Amiga
        // registers. The area is permanently used by the copper.
        var reader0 = dataHunks[0];
        reader0.Position = 160;
        data.UIGraphics = UIGraphics.Read(ref reader0);
        // Here follows the note period table for Sonic Arranger (110 words), then the vibrato table (258 bytes),
        // then track data and many more SA tables.

        reader = dataHunks[1];
        try _SetPosition(ref codeReader, 115000);
        reader.Position = (int)(try _ReadOffsetAfterByteSequence(ref codeReader, [0x34, 0x3c, 0x03, 0xe7, 0x41, 0xf9]));
        data.DigitGlyphs = DigitGlyphs.Read(ref reader);

        // NOTE: There is a new AM2_CPU format introduced to ease supporting new languages. Instead of storing the
        // glyph data and character mappings somewhere inside data hunks which contain a lot of other stuff
        // (including arbitrary sized texts), there is a new data hunk at the end solely for glyph-related data.
        //
        // Original AM2_CPUs have 3 data hunks, now there are 4.
        bool newExeFormat = dataHunks.Count() == 4;

        if (newExeFormat)
        {
            try _SetPosition(ref codeReader, codeReader.Position + 27500);
            var found = codeReader.FindByteSequence([0x48, 0xe7, 0x00, 0xc0, 0x41, 0xf9], codeReader.Position);
            try _SetPosition(ref codeReader, (int)found + 180);
            reader.Position = (int)(try _ReadOffsetAfterByteSequence(ref codeReader, [0x48, 0xe7, 0x00, 0xc0, 0x41, 0xf9]));
            data.Cursors = Cursors.Read(ref reader);

            var glyphReader = dataHunks[3];
            glyphReader.Position = 2 * 224; // 224 chars (256 - 32) are mapped for normal and rune glyphs
            data.Glyphs = Glyphs.Read(ref glyphReader);
        }
        else
        {
            try _SetPosition(ref codeReader, codeReader.Position + 29000);
            reader.Position = (int)(try _ReadOffsetAfterByteSequence(ref codeReader, [0x22, 0x48, 0x41, 0xf9]));
            data.Glyphs = Glyphs.Read(ref reader);
            data.Cursors = Cursors.Read(ref reader);
        }

        // Here are the 3 builtin palettes for primary UI, automap and secondary UI.
        for (var i = 0; i < 3; i += 1)
            data.BuiltinPalettes[i] = ReadPalette(ref reader);

        // Then 9 vertical color gradients used for skies are stored. They are stored as 16 bit XRGB colors and not
        // color indices! The first 3 skies are for Lyramion, the next 3 for the forest moon and the last 3 for
        // Morag. The first sky is night, the second twilight and the third day.
        var skyInfo = GraphicInfo { GraphicFormat = GraphicFormat.XRGB16, Width = 1, Height = 72 };
        for (var i = 0; i < 9; i += 1)
            data.SkyGradients[i] = _Read(ref reader, skyInfo, 0);

        // After the 9 sky gradients there are 6 partial palettes (16 colors). Two of them per world (first for
        // night, second for twilight).
        var replacementInfo = GraphicInfo { GraphicFormat = GraphicFormat.XRGB16, Width = 1, Height = 16 };
        for (var i = 0; i < 6; i += 1)
            data.DaytimePaletteReplacements[i] = _Read(ref reader, replacementInfo, 0);

        // Then (not read here): the spell infos, 3D tables, the class exp factors, travel type infos, the world
        // infos, the combat background infos and the heights of the races.
        const string search = "Amberfiles/";
        var at = reader.FindString(search, reader.Position);
        if (at < 0)
            return error(invalid);
        reader.Position = (int)at + search.Length + 54;
    }

    if (textContainer is TextContainer texts)
    {
        if (hasHunks)
        {
            // the first RELOC32 hunk after the second data hunk: the hunk of each file name
            int numDataHunks = 0;
            Optional<Hunk> relocHunk = null;
            foreach (var hunk in hunks)
            {
                if (hunk.Type == HunkType.Data)
                    numDataHunks += 1;
                if (hunk.Type == HunkType.RELOC32 && numDataHunks == 2)
                {
                    relocHunk = hunk;
                    break;
                }
            }

            if (relocHunk is not Hunk relocations)
                return error(invalid);

            var fileList = FileList.Create();

            while (reader.PeekWord() != 0 && !reader.Overrun())
            {
                int hunkIndex = _FindHunk(relocations, (uint32)reader.Position);

                // (as in the original the number is an index in all hunks, RELOC32 and END hunks included)
                if (hunkIndex < 0 || hunkIndex >= hunks.Count() || hunks[hunkIndex].Data == null)
                    return error(invalid);

                uint32 offset = reader.ReadDword();
                var fileNameReader = DataReader.FromData(hunks[hunkIndex].Data);
                fileNameReader.Position = (int)offset;
                try fileList.ReadFileEntry(ref fileNameReader);
            }

            data.FileList = fileList;
        }

        data.WorldNames = try WorldNames.FromNames(texts.WorldNames);
        data.Messages = try Messages.FromNames(texts.FormatMessages, texts.Messages);
        data.AutomapNames = try AutomapNames.FromNames(texts.AutomapTypeNames);
        data.OptionNames = OptionNames.FromNames(texts.OptionNames);
        data.SongNames = try SongNames.FromNames(texts.MusicNames);
        data.SpellTypeNames = try SpellTypeNames.FromNames(texts.SpellClassNames);
        data.SpellNames = try SpellNames.FromNames(texts.SpellNames);
        data.LanguageNames = try LanguageNames.FromNames(texts.LanguageNames);
        data.ClassNames = try ClassNames.FromNames(texts.ClassNames);
        data.RaceNames = try RaceNames.FromNames(texts.RaceNames);
        data.SkillNames = try SkillNames.FromNames(texts.SkillNames, texts.SkillShortNames);
        data.AttributeNames = try AttributeNames.FromNames(texts.AttributeNames, texts.AttributeShortNames);
        data.ItemTypeNames = try ItemTypeNames.FromNames(texts.ItemTypeNames);
        data.ConditionNames = try ConditionNames.FromNames(texts.ConditionNames);
        data.UITexts = try UITexts.FromNames(texts.UITexts);
    }
    else
    {
        data.FileList = try FileList.Read(ref reader);
        data.WorldNames = WorldNames.Read(ref reader);
        data.Messages = Messages.Read(ref reader);
        data.AutomapNames = AutomapNames.Read(ref reader);
        data.OptionNames = OptionNames.Read(ref reader);
        data.SongNames = SongNames.Read(ref reader);
        data.SpellTypeNames = SpellTypeNames.Read(ref reader);
        data.SpellNames = SpellNames.Read(ref reader);
        data.LanguageNames = LanguageNames.Read(ref reader);
        data.ClassNames = ClassNames.Read(ref reader);
        data.RaceNames = RaceNames.Read(ref reader);
        var skillNames = SkillNames.Read(ref reader);
        var attributeNames = AttributeNames.Read(ref reader);
        skillNames.AddShortNames(ref reader);
        attributeNames.AddShortNames(ref reader);
        data.SkillNames = skillNames;
        data.AttributeNames = attributeNames;
        data.ItemTypeNames = ItemTypeNames.Read(ref reader);
        data.ConditionNames = ConditionNames.Read(ref reader);
        data.UITexts = UITexts.Read(ref reader);
    }

    if (buttonGraphics is DataReader buttonReader)
    {
        buttonReader.Position = 0;
        data.Buttons = Buttons.Read(ref buttonReader);
    }
    else if (hasHunks)
        data.Buttons = Buttons.Read(ref reader);
    else
        return error(invalid);

    var items = Dictionary<uint32, Item>.Create();

    if (objectsAmb is DataReader objectsReader)
    {
        objectsReader.Position = 0;
        int itemCount = objectsReader.ReadWord();
        for (uint32 i = 1; i <= (uint32)itemCount; i += 1) // in original Ambermoon there are 402 items
            items[i] = try ItemReader.ReadItem(i, ref objectsReader);
    }
    else
    {
        if (!hasHunks)
            return error(invalid);
        int itemCount = reader.ReadWord();
        if (reader.ReadWord() != itemCount)
            return error("[Data] Invalid item data.");
        for (uint32 i = 1; i <= (uint32)itemCount; i += 1)
            items[i] = try ItemReader.ReadItem(i, ref reader);
    }

    data.ItemManager = ItemManager.Create(items);
    return data;
}


Optional<DataReader> _File1(GameData gameData, string name)
{
    if (gameData.Files.TryGet(name) is FileContainer container)
        return container.Files.TryGet(1);
    return null;
}

// the number of the hunk whose relocations contain an offset; -1 if none does
int _FindHunk(Hunk relocations, uint32 offset)
{
    foreach (var entry in relocations.Entries.Entries())
    {
        if (entry.Value.Contains(offset))
            return (int)entry.Key;
    }
    return -1;
}

// the position of a reader (the original fails for positions outside of the data)
Error<void> _SetPosition(ref DataReader reader, int position)
{
    if (position < 0 || position > reader.Size())
        return error("Data index out of range.");
    reader.Position = position;
    return;
}

// the dword behind the first sequence of bytes from the position on
Error<uint32> _ReadOffsetAfterByteSequence(ref DataReader reader, ReadOnlySlice<uint8> sequence)
{
    var index = reader.FindByteSequence(sequence, reader.Position);
    if (index == -1)
        return error("[Data] Could not find byte sequence.");
    reader.Position = (int)index + sequence.Length;
    return reader.ReadDword();
}
