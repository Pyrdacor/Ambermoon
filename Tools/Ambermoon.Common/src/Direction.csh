//! The parts of Ambermoon.Common (https://github.com/Pyrdacor/Ambermoon.net) that the tools need: directions, helpers
//! for enums and numbers that give the same texts as .NET.
namespace Ambermoon;

/// The direction a character looks to.
enum CharacterDirection : int32
{
    Up,
    Right,
    Down,
    Left,
    Random,
    Keep = Random
}
