namespace Ambermoon.Data.Legacy.Compression;

using System;

/// A match that [MatchTrie.GetLongestMatch] found: where the earlier sequence starts and how many bytes match.
struct TrieMatch
{
    /// The offset of the earlier sequence (-1 if there is none).
    int Offset;
    /// The number of matching bytes.
    int Length;
}

/// The trie of the LOB compressors: finds the longest earlier sequence that matches the bytes at an offset.
///
/// A modified trie: a branch node stores one byte (its key), a leaf the rest of its sequence (an offset and a length
/// into the data). Every node remembers the last offset that went through it. Sequences that leave the match window
/// (`maxMatchOffset`) are removed after each [MatchTrie.Add].
///
/// This is the trie of Ambermoon.Data.Legacy with the same results (the compressed data must be the same byte for
/// byte), but stored in arrays instead of objects: the children of all nodes are one hash table from (parent, key) to
/// the child, and the nodes of the added offsets are a sorted array instead of a SortedDictionary. Like in the
/// original, removing a node removes whatever child its parent has under its key, and nodes that were cut off stay
/// where they are.
struct MatchTrie
{
    // the nodes; 0 is the root (a branch node)
    int[] _parent;
    uint8[] _key;
    int[] _lastMatchOffset;
    bool[] _isLeaf;
    int[] _leafOffset;  // leaves: where the rest of the sequence starts in the data
    int[] _leafLength;  // leaves: its length (can become -1 when a leaf is split, as in the original)
    int _nodeCount;

    // the children: open addressing, the key is parent * 256 + byte
    int64[] _slotKeys;  // _Empty, _Deleted or a key
    int[] _slotNodes;
    int _slotsUsed;     // filled or deleted
    int _slotsLive;
    int _slotShift;     // 64 - log2(number of slots)

    // the node that each added offset ended in, sorted by offset; the entries before _matchFirst are removed
    int[] _matchOffsets;
    int[] _matchNodes;
    int _matchFirst;
    int _matchCount;

    int _maxMatchOffset;
    string _error;

    /// A trie with a match window of 4095 bytes (LOB).
    static MatchTrie Create()
    {
        return Create((1 << 12) - 1);
    }

    /// A trie whose matches are at most `maxMatchOffset` bytes back.
    static MatchTrie Create(int maxMatchOffset)
    {
        var trie = MatchTrie { _maxMatchOffset = maxMatchOffset, _error = "" };
        trie._parent = new int[1024];
        trie._key = new uint8[1024];
        trie._lastMatchOffset = new int[1024];
        trie._isLeaf = new bool[1024];
        trie._leafOffset = new int[1024];
        trie._leafLength = new int[1024];
        trie._NewNode(-1, 0, 0, false); // the root
        trie._slotKeys = new int64[1024];
        trie._slotNodes = new int[1024];
        trie._slotShift = 64 - 10;
        for (var i = 0; i < 1024; i += 1)
            trie._slotKeys[i] = -1;
        trie._matchOffsets = new int[256];
        trie._matchNodes = new int[256];
        return trie;
    }

    /// "" or why the trie cannot be used: an offset was added twice (the original throws then).
    string Error()
    {
        return _error;
    }

    /// Adds the sequence of `length` bytes at `offset` (at most the longest match length of the compression; less at
    /// the end of the data) and removes the sequences that are too far behind it now.
    void Add(uint8[] sequence, int offset, int length)
    {
        int node = 0;
        for (var i = 0; i < length; i += 1)
        {
            int child = _GetChild(node, sequence[offset + i]);
            if (child >= 0)
            {
                // found a child, go on in the trie
                if (!_isLeaf[child])
                    _lastMatchOffset[child] = offset;
                node = child;
                continue;
            }

            if (_isLeaf[node])
            {
                // split the leaf
                int leaf = node;
                int matchLength = _LeafMatchLength(leaf, sequence, offset + i, length - i);
                if (matchLength == length - i)
                {
                    // the whole rest matches: only the last match offset changes
                    _lastMatchOffset[leaf] = offset;
                }
                else
                {
                    // the leaf becomes a chain of branch nodes with two leaves at its end
                    int parent = _parent[leaf];
                    int branch = _NewNode(parent, _key[leaf], offset, false);
                    _SetChild(parent, _key[branch], branch);
                    parent = branch;
                    int n = 0;
                    while (n < matchLength)
                    {
                        branch = _NewNode(parent, sequence[_leafOffset[leaf] + n], offset, false);
                        _SetChild(parent, _key[branch], branch);
                        parent = branch;
                        n += 1;
                    }
                    int newLeaf = _NewNode(parent, sequence[offset + i + n], offset, true);
                    _leafOffset[newLeaf] = offset + i + n + 1;
                    _leafLength[newLeaf] = length - i - n - 1;
                    _SetChild(parent, _key[newLeaf], newLeaf);

                    // the old leaf keeps the rest behind the common part (it replaces the new leaf if the keys are
                    // the same, like in the original)
                    _key[leaf] = sequence[_leafOffset[leaf] + matchLength];
                    _leafOffset[leaf] += matchLength + 1;
                    _leafLength[leaf] -= matchLength + 1;
                    _parent[leaf] = parent;
                    _SetChild(parent, _key[leaf], leaf);
                    node = newLeaf;
                }
            }
            else
            {
                // a branch node without this key: a new leaf
                int newLeaf = _NewNode(node, sequence[offset + i], offset, true);
                _leafOffset[newLeaf] = offset + i + 1;
                _leafLength[newLeaf] = length - i - 1;
                _SetChild(node, _key[newLeaf], newLeaf);
                node = newLeaf;
            }
            break;
        }

        _AddMatchNode(offset, node);

        // remove the nodes that are too far away (matches are searched before adding, hence the + 1)
        int firstOffset = offset - _maxMatchOffset + 1;
        while (_matchFirst < _matchCount && _matchOffsets[_matchFirst] < firstOffset)
        {
            _Remove(_matchNodes[_matchFirst], firstOffset);
            _matchFirst += 1;
        }
    }

    /// The longest earlier sequence that matches the bytes at `searchOffset`, at most `maxLength` bytes.
    TrieMatch GetLongestMatch(uint8[] sequence, int searchOffset, int maxLength)
    {
        int node = 0;
        int i = 0;
        while (i < maxLength)
        {
            int child = _GetChild(node, sequence[searchOffset + i]);
            if (child < 0)
                break;
            node = child;
            i += 1;
        }

        if (node == 0)
            return TrieMatch { Offset = -1, Length = 0 };

        if (_isLeaf[node])
        {
            int length = i + _LeafMatchLength(node, sequence, searchOffset + i, maxLength - i);
            return TrieMatch { Offset = _lastMatchOffset[node], Length = length < maxLength ? length : maxLength };
        }
        return TrieMatch { Offset = _lastMatchOffset[node], Length = i };
    }

    // how many bytes of the sequence at 'offset' match the rest of the leaf (at most 'length')
    int _LeafMatchLength(int leaf, uint8[] sequence, int offset, int length)
    {
        int compareLength = length < _leafLength[leaf] ? length : _leafLength[leaf];
        int start = _leafOffset[leaf];
        int i = 0;
        while (i < compareLength && sequence[offset + i] == sequence[start + i])
            i += 1;
        return i;
    }

    // removes the node and the parents that no newer sequence went through (up to the root)
    void _Remove(int node, int firstOffset)
    {
        while (node != 0 && _lastMatchOffset[node] < firstOffset)
        {
            _RemoveChild(_parent[node], _key[node]);
            node = _parent[node];
        }
    }

    void _AddMatchNode(int offset, int node)
    {
        // usually behind the last one; the RLE parts of the compressors add a few offsets later
        int position = _matchCount;
        while (position > _matchFirst && _matchOffsets[position - 1] > offset)
            position -= 1;
        if (position > _matchFirst && _matchOffsets[position - 1] == offset)
        {
            if (_error.Length == 0)
                _error = "An item with the same key has already been added. Key: " + offset.ToString();
            return;
        }
        if (_matchCount == _matchOffsets.Length)
        {
            int live = _matchCount - _matchFirst;
            if (_matchFirst >= _matchOffsets.Length / 2)
            {
                // move the live entries to the front instead of growing
                Array.Copy(_matchOffsets, _matchFirst, _matchOffsets, 0, live);
                Array.Copy(_matchNodes, _matchFirst, _matchNodes, 0, live);
            }
            else
            {
                var offsets = new int[_matchOffsets.Length * 2];
                var nodes = new int[_matchOffsets.Length * 2];
                Array.Copy(_matchOffsets, _matchFirst, offsets, 0, live);
                Array.Copy(_matchNodes, _matchFirst, nodes, 0, live);
                _matchOffsets = offsets;
                _matchNodes = nodes;
            }
            position -= _matchFirst;
            _matchFirst = 0;
            _matchCount = live;
        }
        if (position < _matchCount)
        {
            Array.Copy(_matchOffsets, position, _matchOffsets, position + 1, _matchCount - position);
            Array.Copy(_matchNodes, position, _matchNodes, position + 1, _matchCount - position);
        }
        _matchOffsets[position] = offset;
        _matchNodes[position] = node;
        _matchCount += 1;
    }

    int _NewNode(int parent, uint8 key, int lastMatchOffset, bool isLeaf)
    {
        if (_nodeCount == _parent.Length)
        {
            int size = _parent.Length * 2;
            var parents = new int[size];
            var keys = new uint8[size];
            var lastMatchOffsets = new int[size];
            var isLeafs = new bool[size];
            var leafOffsets = new int[size];
            var leafLengths = new int[size];
            Array.Copy(_parent, 0, parents, 0, _nodeCount);
            Array.Copy(_key, 0, keys, 0, _nodeCount);
            Array.Copy(_lastMatchOffset, 0, lastMatchOffsets, 0, _nodeCount);
            Array.Copy(_isLeaf, 0, isLeafs, 0, _nodeCount);
            Array.Copy(_leafOffset, 0, leafOffsets, 0, _nodeCount);
            Array.Copy(_leafLength, 0, leafLengths, 0, _nodeCount);
            _parent = parents;
            _key = keys;
            _lastMatchOffset = lastMatchOffsets;
            _isLeaf = isLeafs;
            _leafOffset = leafOffsets;
            _leafLength = leafLengths;
        }
        int node = _nodeCount;
        _parent[node] = parent;
        _key[node] = key;
        _lastMatchOffset[node] = lastMatchOffset;
        _isLeaf[node] = isLeaf;
        _nodeCount += 1;
        return node;
    }

    // ---- the children ----

    int _Slot(int64 key)
    {
        return (int)(unchecked((uint64)key * 11400714819323198485) >> _slotShift);
    }

    // the child of a branch node with this key, -1 if there is none (leaves have no children)
    int _GetChild(int node, uint8 key)
    {
        if (_isLeaf[node])
            return -1;
        int64 slotKey = (int64)node * 256 + key;
        int mask = _slotKeys.Length - 1;
        int i = _Slot(slotKey);
        while (true)
        {
            int64 k = _slotKeys[i];
            if (k == slotKey)
                return _slotNodes[i];
            if (k == -1)
                return -1;
            i = (i + 1) & mask;
        }
        return -1;
    }

    // sets the child of 'parent' with this key (replaces the one that is there)
    void _SetChild(int parent, uint8 key, int child)
    {
        int64 slotKey = (int64)parent * 256 + key;
        int mask = _slotKeys.Length - 1;
        int i = _Slot(slotKey);
        int deleted = -1;
        while (true)
        {
            int64 k = _slotKeys[i];
            if (k == slotKey)
            {
                _slotNodes[i] = child;
                return;
            }
            if (k == -1)
                break;
            if (k == -2 && deleted < 0)
                deleted = i;
            i = (i + 1) & mask;
        }
        if (deleted >= 0)
            i = deleted;
        else
            _slotsUsed += 1;
        _slotKeys[i] = slotKey;
        _slotNodes[i] = child;
        _slotsLive += 1;
        if (_slotsUsed * 2 > _slotKeys.Length)
            _Rehash();
    }

    // removes the child of 'parent' with this key (whichever node it is)
    void _RemoveChild(int parent, uint8 key)
    {
        int64 slotKey = (int64)parent * 256 + key;
        int mask = _slotKeys.Length - 1;
        int i = _Slot(slotKey);
        while (true)
        {
            int64 k = _slotKeys[i];
            if (k == slotKey)
            {
                _slotKeys[i] = -2;
                _slotsLive -= 1;
                return;
            }
            if (k == -1)
                return;
            i = (i + 1) & mask;
        }
    }

    void _Rehash()
    {
        int size = _slotKeys.Length;
        while (_slotsLive * 4 > size)
            size *= 2;
        int bits = 0;
        while ((1 << bits) < size)
            bits += 1;
        var oldKeys = _slotKeys;
        var oldNodes = _slotNodes;
        _slotKeys = new int64[size];
        _slotNodes = new int[size];
        _slotShift = 64 - bits;
        for (var i = 0; i < size; i += 1)
            _slotKeys[i] = -1;
        int mask = size - 1;
        for (var j = 0; j < oldKeys.Length; j += 1)
        {
            int64 k = oldKeys[j];
            if (k < 0)
                continue;
            int i = _Slot(k);
            while (_slotKeys[i] != -1)
                i = (i + 1) & mask;
            _slotKeys[i] = k;
            _slotNodes[i] = oldNodes[j];
        }
        _slotsUsed = _slotsLive;
    }
}
