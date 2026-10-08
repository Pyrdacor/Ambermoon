namespace Ambermoon.Data;

using System;
using Ambermoon.Data.Enumerations;

/// An animation of a monster in battle: the frames it shows.
struct MonsterAnimation
{
    /// 0-32
    int UsedAmount;
    /// 32 bytes
    uint8[] FrameIndices;
}

/// A monster: a character and its battle graphics.
struct Monster
{
    Character Character;
    /// 8 animations (MonsterAnimationType)
    MonsterAnimation[] Animations;
    /// not used
    uint8[] AtariPalette;
    uint8[] MonsterPalette;
    /// 1 bit per animation (if set, play animation backwards after finish)
    uint8 AlternateAnimationBits;
    /// always 0
    uint8 PaddingByte;
    uint32 FrameWidth;
    uint32 FrameHeight;
    uint32 MappedFrameWidth;
    uint32 MappedFrameHeight;
    Optional<Graphic> CombatGraphic;

    /// The frames of an animation (a wave animation is played back after it is finished).
    int[] GetAnimationFrameIndices(MonsterAnimationType animationType)
    {
        var animation = Animations[(int)animationType];
        bool wave = (AlternateAnimationBits & (1 << (int)animationType)) != 0;
        var frames = List<int>.Create();
        for (var i = 0; i < animation.UsedAmount; i += 1)
            frames.Add(animation.FrameIndices[i]);
        if (wave)
        {
            for (var i = animation.UsedAmount - 2; i >= 0; i -= 1)
                frames.Add(animation.FrameIndices[i]);
        }
        return frames.ToArray();
    }
}
