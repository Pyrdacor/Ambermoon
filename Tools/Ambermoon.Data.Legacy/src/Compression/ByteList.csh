namespace Ambermoon.Data.Legacy.Compression;

using System;

/// A growable list of bytes for the compressors: a value (pass it as `ref`), `new ByteList()` is empty.
struct ByteList
{
    uint8[] _items;
    int _count;

    /// An empty list with room for `capacity` bytes.
    static ByteList Create(int capacity)
    {
        return ByteList { _items = new uint8[capacity < 16 ? 16 : capacity] };
    }

    /// The number of bytes.
    int Count()
    {
        return _count;
    }

    /// The byte at `index` (also `list[index]`).
    uint8 Get(int index)
    {
        if (index < 0 || index >= _count)
            Environment.Panic("ByteList index out of range (index " + index.ToString() + ", count " + _count.ToString() + ")");
        return _items[index];
    }

    /// Replaces the byte at `index` (also `list[index] = value`).
    void Set(int index, uint8 value)
    {
        if (index < 0 || index >= _count)
            Environment.Panic("ByteList index out of range (index " + index.ToString() + ", count " + _count.ToString() + ")");
        _items[index] = value;
    }

    /// The last byte.
    uint8 Last()
    {
        return Get(_count - 1);
    }

    /// Adds a byte at the end.
    void Add(uint8 value)
    {
        if (_items == null || _count == _items.Length)
            _Grow(_count + 1);
        _items[_count] = value;
        _count += 1;
    }

    /// Adds `count` bytes of `other` from `start` on.
    void AddRange(const ref ByteList other, int start, int count)
    {
        if (count <= 0)
            return;
        _Grow(_count + count);
        Array.Copy(other._items, start, _items, _count, count);
        _count += count;
    }

    /// Removes the first `count` bytes.
    void RemoveFirst(int count)
    {
        if (count >= _count)
        {
            _count = 0;
            return;
        }
        Array.Copy(_items, count, _items, 0, _count - count);
        _count -= count;
    }

    /// Removes all bytes.
    void Clear()
    {
        _count = 0;
    }

    /// The bytes as a new array.
    uint8[] ToArray()
    {
        var result = new uint8[_count];
        if (_count > 0)
            Array.Copy(_items, 0, result, 0, _count);
        return result;
    }

    void _Grow(int needed)
    {
        int capacity = _items == null ? 0 : _items.Length;
        if (needed <= capacity)
            return;
        int bigger = capacity < 16 ? 16 : capacity * 2;
        if (bigger < needed)
            bigger = needed;
        var items = new uint8[bigger];
        if (_count > 0)
            Array.Copy(_items, 0, items, 0, _count);
        _items = items;
    }
}
