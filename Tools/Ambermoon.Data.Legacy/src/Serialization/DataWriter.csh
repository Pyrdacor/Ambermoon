namespace Ambermoon.Data.Legacy.Serialization;

using System;

/// Writes big-endian values (the byte order of the Amiga) into a growing buffer.
///
/// A writer is a value that owns its buffer: pass it as `ref` to the functions that write into it (copies would share
/// the bytes written so far, but not what is written afterwards). `new DataWriter()` is an empty writer.
struct DataWriter
{
    uint8[] _data;
    int _size;

    /// A writer that starts with a copy of `data`.
    static DataWriter Create(ReadOnlySlice<uint8> data)
    {
        var writer = new DataWriter();
        writer.WriteBytes(data);
        return writer;
    }

    /// The number of bytes written.
    int Size()
    {
        return _size;
    }

    /// Where the next value is written: always the end.
    int Position()
    {
        return _size;
    }

    /// The byte at `index` (also `writer[index]`).
    uint8 Get(int index)
    {
        if (index < 0 || index >= _size)
            Environment.Panic("DataWriter index out of range (index " + index.ToString() + ", size " + _size.ToString() + ")");
        return _data[index];
    }

    /// Replaces the byte at `index`; `index == Size()` appends it (also `writer[index] = value`).
    void Set(int index, uint8 value)
    {
        if (index == _size)
            WriteByte(value);
        else
            ReplaceByte(index, value);
    }

    /// Writes 1 for true and 0 for false.
    void WriteBool(bool value)
    {
        WriteByte(value ? (uint8)1 : (uint8)0);
    }

    /// Writes a byte.
    void WriteByte(uint8 value)
    {
        if (_data == null || _size == _data.Length)
            _Grow(1);
        _data[_size] = value;
        _size += 1;
    }

    /// Writes a word (16 bits, big-endian).
    void WriteWord(uint16 value)
    {
        _Grow(2);
        _data[_size] = (uint8)(value >> 8);
        _data[_size + 1] = (uint8)value;
        _size += 2;
    }

    /// Writes a dword (32 bits, big-endian).
    void WriteDword(uint32 value)
    {
        _Grow(4);
        _data[_size] = (uint8)(value >> 24);
        _data[_size + 1] = (uint8)(value >> 16);
        _data[_size + 2] = (uint8)(value >> 8);
        _data[_size + 3] = (uint8)value;
        _size += 4;
    }

    /// Writes a qword (64 bits, big-endian).
    void WriteQword(uint64 value)
    {
        WriteDword((uint32)(value >> 32));
        WriteDword((uint32)value);
    }

    /// Writes bytes: an array, a part of one, or text as UTF-8 (`text.AsBytes()`).
    void WriteBytes(ReadOnlySlice<uint8> bytes)
    {
        int n = bytes.Length;
        if (n == 0)
            return;
        _Grow(n);
        for (var i = 0; i < n; i += 1)
            _data[_size + i] = bytes[i];
        _size += n;
    }

    /// Writes all bytes of an array.
    void WriteBytes(uint8[] bytes)
    {
        int n = bytes.Length;
        if (n == 0)
            return;
        _Grow(n);
        Array.Copy(bytes, 0, _data, _size, n);
        _size += n;
    }

    /// Writes `count` bytes of an array, from `offset` on.
    void WriteBytes(uint8[] bytes, int offset, int count)
    {
        if (count == 0)
            return;
        _Grow(count);
        Array.Copy(bytes, offset, _data, _size, count);
        _size += count;
    }

    /// Replaces the byte at `offset`.
    /// @panics when `offset` is not in 0 to `Size() - 1`.
    void ReplaceByte(int offset, uint8 value)
    {
        _CheckRange(offset, 1);
        _data[offset] = value;
    }

    /// Replaces the word at `offset`.
    void ReplaceWord(int offset, uint16 value)
    {
        _CheckRange(offset, 2);
        _data[offset] = (uint8)(value >> 8);
        _data[offset + 1] = (uint8)value;
    }

    /// Replaces the dword at `offset`.
    void ReplaceDword(int offset, uint32 value)
    {
        _CheckRange(offset, 4);
        _data[offset] = (uint8)(value >> 24);
        _data[offset + 1] = (uint8)(value >> 16);
        _data[offset + 2] = (uint8)(value >> 8);
        _data[offset + 3] = (uint8)value;
    }

    /// Replaces the bytes from `offset` on with `bytes`.
    void ReplaceBytes(int offset, ReadOnlySlice<uint8> bytes)
    {
        _CheckRange(offset, bytes.Length);
        for (var i = 0; i < bytes.Length; i += 1)
            _data[offset + i] = bytes[i];
    }

    /// A copy of the bytes written.
    uint8[] ToArray()
    {
        var result = new uint8[_size];
        if (_size > 0)
            Array.Copy(_data, 0, result, 0, _size);
        return result;
    }

    /// A copy of `length` bytes from `offset` on.
    uint8[] GetBytes(int offset, int length)
    {
        _CheckRange(offset, length);
        var result = new uint8[length];
        if (length > 0)
            Array.Copy(_data, offset, result, 0, length);
        return result;
    }

    /// The bytes written, as a view (no copy; valid until the next write).
    ReadOnlySlice<uint8> AsSlice()
    {
        if (_data == null)
            return new uint8[0];
        return _data[0.._size];
    }

    /// Removes `count` bytes from `index` on (nothing if `index` is behind the end).
    void Remove(int index, int count)
    {
        if (index >= _size)
            return;
        _CheckRange(index, count);
        Array.Copy(_data, index + count, _data, index, _size - index - count);
        _size -= count;
    }

    /// Removes everything.
    void Clear()
    {
        _size = 0;
    }

    void _CheckRange(int offset, int length)
    {
        if (offset < 0 || length < 0 || offset + length > _size)
            Environment.Panic("Index was outside the data writer size (offset " + offset.ToString() + ", length " + length.ToString() +
                              ", size " + _size.ToString() + ")");
    }

    // room for 'more' bytes behind the end
    void _Grow(int more)
    {
        int capacity = _data == null ? 0 : _data.Length;
        int needed = _size + more;
        if (needed <= capacity)
            return;
        int bigger = capacity < 64 ? 64 : capacity * 2;
        if (bigger < needed)
            bigger = needed;
        var data = new uint8[bigger];
        if (_size > 0)
            Array.Copy(_data, 0, data, 0, _size);
        _data = data;
    }
}
