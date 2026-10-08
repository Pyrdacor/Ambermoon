namespace Ambermoon;

using System;

/// A position (tile or pixel coordinates).
struct Position
{
    int X;
    int Y;

    static Position Create(int x, int y)
    {
        return Position { X = x, Y = y };
    }
}
