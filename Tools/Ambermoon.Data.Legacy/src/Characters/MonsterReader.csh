namespace Ambermoon.Data.Legacy.Characters;

using System;
using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;

/// Reads the monsters of Monster_char_data.amb (Monster_char.amb since version 1.14).
struct MonsterReader
{
    /// Reads a monster; with game data also its combat graphic (from Monster_gfx.amb).
    /// @error the data is damaged or the graphic is missing.
    static Error<Monster> ReadMonster(uint32 index, ref DataReader reader, Optional<GameData> gameData)
    {
        var character = Character.Create(CharacterType.Monster, index);
        try CharacterReader.ReadCharacter(ref character, ref reader);
        var monster = Monster { Character = character, Animations = new MonsterAnimation[8] };

        for (var i = 0; i < 8; i += 1)
            monster.Animations[i] = MonsterAnimation { FrameIndices = reader.ReadBytes(32) };

        for (var i = 0; i < 8; i += 1)
            monster.Animations[i].UsedAmount = reader.ReadByte();

        monster.AtariPalette = reader.ReadBytes(16);
        monster.MonsterPalette = reader.ReadBytes(32);
        monster.AlternateAnimationBits = reader.ReadByte();
        monster.PaddingByte = reader.ReadByte();
        monster.FrameWidth = reader.ReadWord();
        monster.FrameHeight = reader.ReadWord();
        monster.MappedFrameWidth = reader.ReadWord();
        monster.MappedFrameHeight = reader.ReadWord();

        if (reader.Overrun())
            return error("[Data] Invalid monster data.");

        if (gameData is GameData data)
            monster.CombatGraphic = try LoadCombatGraphic(monster, data);

        return monster;
    }

    /// The frames of the combat graphic of a monster side by side, in the colors of its palette.
    /// @error Monster_gfx.amb or the graphic is missing.
    static Error<Graphic> LoadCombatGraphic(Monster monster, GameData gameData)
    {
        if (gameData.Files.TryGet("Monster_gfx.amb") is not FileContainer graphics)
            return error("The given key 'Monster_gfx.amb' was not present in the dictionary.");
        int graphicIndex = (int)monster.Character.CombatGraphicIndex;
        if (graphics.Files.TryGet(graphicIndex) is not DataReader file)
            return error($"The given key '{graphicIndex}' was not present in the dictionary.");
        file.Position = 0;
        var info = GraphicInfo
        {
            Width = (int)monster.FrameWidth,
            Height = (int)monster.FrameHeight,
            GraphicFormat = GraphicFormat.Palette5Bit,
            Alpha = true,
            PaletteOffset = 0
        };
        int frameSize = (info.Width * info.Height * 5 + 7) / 8;
        int numFrames = frameSize == 0 ? 0 : file.Size() / frameSize;
        var compound = Graphic.Create(numFrames * (int)monster.FrameWidth, (int)monster.FrameHeight, 0);
        for (var i = 0; i < numFrames; i += 1)
        {
            var frame = try GraphicReader.ReadGraphic(ref file, info);
            try compound.AddOverlay((int64)i * monster.FrameWidth, 0, frame.CreateScaled((int)monster.FrameWidth, (int)monster.FrameHeight), false);
        }
        for (var i = 0; i < compound.Data.Length; i += 1)
            compound.Data[i] = monster.MonsterPalette[compound.Data[i] & 0x1f];
        return compound;
    }
}
