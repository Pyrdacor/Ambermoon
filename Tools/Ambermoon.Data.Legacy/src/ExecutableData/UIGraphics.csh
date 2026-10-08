namespace Ambermoon.Data.Legacy.ExecutableData;

using System;
using Ambermoon.Data;
using Ambermoon.Data.Enumerations;
using Ambermoon.Data.Legacy.Serialization;

/// The graphics of the user interface in the first data hunk of the executable.
struct UIGraphics
{
    Dictionary<UIGraphic, Graphic> Entries;

    static UIGraphics Read(ref DataReader reader)
    {
        var entries = Dictionary<UIGraphic, Graphic>.Create();
        var info = GraphicInfo { Width = 16, Height = 16, Alpha = true, GraphicFormat = GraphicFormat.Palette3Bit, PaletteOffset = 24 };

        // Now 32 bytes follow where each of the 256 bits indicates (1) black or (0) transparent.
        entries[UIGraphic.DisabledOverlay16x16] = _BitMask(ref reader, 16, 16, 28);
        // Then real 3-bit graphics follow.
        // window frames
        entries[UIGraphic.FrameUpperLeft] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameLeft] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameLowerLeft] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameTop] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameBottom] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameUpperRight] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameRight] = _Read(ref reader, info, 0);
        entries[UIGraphic.FrameLowerRight] = _Read(ref reader, info, 0);

        info.GraphicFormat = GraphicFormat.Palette5Bit;
        info.PaletteOffset = 0;
        for (var i = (int)UIGraphic.StatusDead; i <= (int)UIGraphic.StatusRangeAttack; i += 1)
            entries[(UIGraphic)i] = _Read(ref reader, info, 0);

        info.Width = 32;
        info.Height = 29;
        info.GraphicFormat = GraphicFormat.Palette5Bit;
        info.PaletteOffset = 0;
        entries[UIGraphic.Eagle] = _Read(ref reader, info, 0);
        info.Height = 26;
        entries[UIGraphic.DamageSplash] = _Read(ref reader, info, 0);
        info.Height = 23;
        info.GraphicFormat = GraphicFormat.Palette3Bit;
        info.PaletteOffset = 24;
        entries[UIGraphic.Ouch] = _Read(ref reader, info, 0);
        info.Width = 16;
        info.Height = 9;
        info.GraphicFormat = GraphicFormat.Palette5Bit;
        info.PaletteOffset = 0;
        var frames = Graphic.Create(64, 9, 0);
        for (var i = 0; i < 4; i += 1)
            frames.AddOverlay(i * 16, 0, _Read(ref reader, info, 0), false);
        entries[UIGraphic.StarBlinkAnimation] = frames;
        info.GraphicFormat = GraphicFormat.Palette3Bit;
        info.PaletteOffset = 24;
        info.Height = 40;
        entries[UIGraphic.PlusBlinkAnimation] = _Read(ref reader, info, 0);
        info.Height = 36;
        entries[UIGraphic.LeftPortraitBorder] = _Read(ref reader, info, 0);
        entries[UIGraphic.CharacterValueBarFrames] = _Read(ref reader, info, 0);
        entries[UIGraphic.RightPortraitBorder] = _Read(ref reader, info, 0);
        info.Height = 1;
        entries[UIGraphic.SmallBorder1] = _Read(ref reader, info, 0);
        entries[UIGraphic.SmallBorder2] = _Read(ref reader, info, 0);
        info.Height = 16;
        for (var i = (int)UIGraphic.Candle; i <= (int)UIGraphic.Map; i += 1)
            entries[(UIGraphic)i] = _ReadOpaque(ref reader, info);

        info.Width = 32;
        info.Height = 15;
        entries[UIGraphic.Windchain] = _ReadOpaque(ref reader, info);
        info.Height = 32;
        entries[UIGraphic.MonsterEyeInactive] = _ReadOpaque(ref reader, info);
        entries[UIGraphic.MonsterEyeActive] = _ReadOpaque(ref reader, info);
        entries[UIGraphic.Night] = _ReadOpaque(ref reader, info);
        entries[UIGraphic.Dusk] = _ReadOpaque(ref reader, info);
        entries[UIGraphic.Day] = _ReadOpaque(ref reader, info);
        entries[UIGraphic.Dawn] = _ReadOpaque(ref reader, info);

        info.Height = 17;
        info.Alpha = true;
        entries[UIGraphic.ButtonFrame] = _Read(ref reader, info, 0);
        entries[UIGraphic.ButtonFramePressed] = _Read(ref reader, info, 0);
        // Note: There is a 1-bit mask here where a 0 bit means transparent (keep color) and 1 means overlay.
        // As we use this for buttons we will set the color as the button back color (28).
        // The disable overlay is 32x11 in size.
        entries[UIGraphic.ButtonDisabledOverlay] = _BitMask(ref reader, 32, 11, 28);
        info.Width = 32;
        info.Height = 32;
        entries[UIGraphic.Compass] = _ReadOpaque(ref reader, info);
        info.Width = 16;
        info.Height = 9;
        entries[UIGraphic.Attack] = _Read(ref reader, info, 0);
        entries[UIGraphic.Defense] = _Read(ref reader, info, 0);
        info.Width = 32;
        info.Height = 34;
        entries[UIGraphic.Skull] = _Read(ref reader, info, 25);
        entries[UIGraphic.EmptyCharacterSlot] = _ReadOpaque(ref reader, info);
        info.Width = 16;
        info.Height = 16;
        info.GraphicFormat = GraphicFormat.Palette3Bit;
        info.PaletteOffset = 0;
        var compound = Graphic.Create(176, 16, 0);
        for (var i = 0; i < 11; i += 1)
            compound.AddOverlay(i * 16, 0, _Read(ref reader, info, 0), false);
        entries[UIGraphic.ItemConsume] = compound;
        info.Width = 32;
        info.Height = 29;
        info.GraphicFormat = GraphicFormat.Palette5Bit;
        info.PaletteOffset = 0;
        entries[UIGraphic.Talisman] = _Read(ref reader, info, 0);
        entries[UIGraphic.Unused] = _BitMask(ref reader, 16, 13, 28);
        entries[UIGraphic.BrokenItemOverlay] = _BitMask(ref reader, 16, 16, 26);

        if (reader.PeekWord() == 0xCA75)
        {
            reader.Position += 2;
            info.Width = 32;
            info.Height = 34;
            info.GraphicFormat = GraphicFormat.Palette3Bit;
            info.PaletteOffset = 24;
            info.Alpha = true;
            entries[UIGraphic.CatSkull] = _Read(ref reader, info, 25);
        }
        else
            entries[UIGraphic.CatSkull] = entries[UIGraphic.Skull];

        return UIGraphics { Entries = entries };
    }
}

Graphic _Read(ref DataReader reader, GraphicInfo info, uint8 maskColor)
{
    if (GraphicReader.ReadGraphic(ref reader, info, maskColor) is Graphic graphic)
        return graphic;
    return Graphic.Create(info.Width, info.Height, 0);
}

// a graphic whose color 0 becomes 32
Graphic _ReadOpaque(ref DataReader reader, GraphicInfo info)
{
    var graphic = _Read(ref reader, info, 0);
    graphic.ReplaceColor(0, 32);
    return graphic;
}

// a graphic of one bit per pixel (rows of words or dwords): 'color' where a bit is set, else 0
Graphic _BitMask(ref DataReader reader, int width, int height, uint8 color)
{
    var graphic = Graphic.Create(width, height, 0);
    for (var y = 0; y < height; y += 1)
    {
        uint32 bits = width == 32 ? reader.ReadDword() : (uint32)reader.ReadWord() << 16;
        for (var x = 0; x < width; x += 1)
        {
            if ((bits & 0x80000000) != 0)
                graphic.Data[y * width + x] = color;
            bits <<= 1;
        }
    }
    return graphic;
}
