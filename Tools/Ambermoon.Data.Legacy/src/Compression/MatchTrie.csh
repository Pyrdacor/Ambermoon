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
/// byte), but stored in arrays instead of objects: the children of the root are a table by byte, those of the other
/// nodes one hash table from (parent, key) to the child, and the nodes of the added offsets are a sorted array instead
/// of a SortedDictionary. Like in the original, removing a node removes whatever child its parent has under its key,
/// and nodes that were cut off stay where they are.
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

    // the children of the root by byte (every walk starts there), 0 if there is none (the root is no child)
    int[] _rootChildren;

    // the other children: open addressing by (parent, byte), in 32 bits (the 68000 multiplies only 16 by 16 bits); a
    // slot holds parent + 1, so that a new (zeroed) array is empty
    int[] _slotParents; // 0 empty, -1 deleted, else the parent + 1
    uint8[] _slotBytes;
    int[] _slotNodes;
    int _slotsUsed;     // filled or deleted
    int _slotsLive;

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
        trie._parent = new int[4096];
        trie._key = new uint8[4096];
        trie._lastMatchOffset = new int[4096];
        trie._isLeaf = new bool[4096];
        trie._leafOffset = new int[4096];
        trie._leafLength = new int[4096];
        trie._NewNode(-1, 0, 0, false); // the root
        trie._rootChildren = new int[256];
        trie._slotParents = new int[8192];
        trie._slotBytes = new uint8[8192];
        trie._slotNodes = new int[8192];
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
    /// the end of the data) and removes the sequences that are too far behind it now. Returns what
    /// [MatchTrie.GetLongestMatch] with the same arguments would have returned before (both walk the same way).
    TrieMatch Add(uint8[] sequence, int offset, int length)
    {
        int node = 0;
        int matchOffset = -1;
        int i = 0;
        int leafLength = 0; // the bytes that match the rest of the leaf that the walk ended in
        bool nodeIsLeaf = false;
        while (i < length)
        {
            // the child with the next byte (_GetChild written out: the walk knows whether the node is a leaf)
            uint8 key = sequence[offset + i];
            int child = -1;
            if (node == 0)
            {
                int rootChild = _rootChildren[key];
                if (rootChild != 0)
                    child = rootChild;
            }
            else if (!nodeIsLeaf)
            {
                int mask = _slotParents.Length - 1;
                int slot = unchecked(node ^ (key << 11) ^ (key << 3) ^ (node >> 9)) & mask;
                int stored = node + 1;
                while (true)
                {
                    int p = _slotParents[slot];
                    if (p == stored && _slotBytes[slot] == key)
                    {
                        child = _slotNodes[slot];
                        break;
                    }
                    if (p == 0)
                        break;
                    slot = (slot + 1) & mask;
                }
            }
            if (child >= 0)
            {
                // found a child, go on in the trie
                matchOffset = _lastMatchOffset[child];
                nodeIsLeaf = _isLeaf[child];
                if (!nodeIsLeaf)
                    _lastMatchOffset[child] = offset;
                node = child;
                i += 1;
                continue;
            }

            if (nodeIsLeaf)
            {
                // split the leaf
                int leaf = node;
                int matchLength = _LeafMatchLength(leaf, sequence, offset + i, length - i);
                leafLength = matchLength;
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
        var match = TrieMatch { Offset = matchOffset, Length = i + leafLength };

        // remove the nodes that are too far away (matches are searched before adding, hence the + 1)
        int firstOffset = offset - _maxMatchOffset + 1;
        while (_matchFirst < _matchCount && _matchOffsets[_matchFirst] < firstOffset)
        {
            _Remove(_matchNodes[_matchFirst], firstOffset);
            _matchFirst += 1;
        }
        return match;
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
        // usually behind the last one, with room for it
        int count = _matchCount;
        if (count < _matchOffsets.Length && (count == _matchFirst || _matchOffsets[count - 1] < offset))
        {
            _matchOffsets[count] = offset;
            _matchNodes[count] = node;
            _matchCount = count + 1;
            return;
        }
        // the RLE parts of the compressors add a few offsets later
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

    // where the search for (parent, byte) starts: no multiplication; the byte spread over the higher bits, so that the
    // children of one node and the nodes after it do not crowd the same slots (also written out where it is used)
    int _Slot(int parent, uint8 key, int mask)
    {
        return unchecked(parent ^ (key << 11) ^ (key << 3) ^ (parent >> 9)) & mask;
    }

    // the child of a branch node with this key, -1 if there is none (leaves have no children)
    int _GetChild(int node, uint8 key)
    {
        if (node == 0)
        {
            int rootChild = _rootChildren[key];
            return rootChild != 0 ? rootChild : -1;
        }
        if (_isLeaf[node])
            return -1;
        int mask = _slotParents.Length - 1;
        int i = unchecked(node ^ (key << 11) ^ (key << 3) ^ (node >> 9)) & mask;
        int stored = node + 1;
        while (true)
        {
            int p = _slotParents[i];
            if (p == stored && _slotBytes[i] == key)
                return _slotNodes[i];
            if (p == 0)
                return -1;
            i = (i + 1) & mask;
        }
        return -1;
    }

    // sets the child of 'parent' with this key (replaces the one that is there)
    void _SetChild(int parent, uint8 key, int child)
    {
        if (parent == 0)
        {
            _rootChildren[key] = child;
            return;
        }
        int mask = _slotParents.Length - 1;
        int i = unchecked(parent ^ (key << 11) ^ (key << 3) ^ (parent >> 9)) & mask;
        int stored = parent + 1;
        int deleted = -1;
        while (true)
        {
            int p = _slotParents[i];
            if (p == stored && _slotBytes[i] == key)
            {
                _slotNodes[i] = child;
                return;
            }
            if (p == 0)
                break;
            if (p == -1 && deleted < 0)
                deleted = i;
            i = (i + 1) & mask;
        }
        if (deleted >= 0)
            i = deleted;
        else
            _slotsUsed += 1;
        _slotParents[i] = stored;
        _slotBytes[i] = key;
        _slotNodes[i] = child;
        _slotsLive += 1;
        if (_slotsUsed * 2 > _slotParents.Length)
            _Rehash();
    }

    // removes the child of 'parent' with this key (whichever node it is)
    void _RemoveChild(int parent, uint8 key)
    {
        if (parent == 0)
        {
            _rootChildren[key] = 0;
            return;
        }
        int mask = _slotParents.Length - 1;
        int i = unchecked(parent ^ (key << 11) ^ (key << 3) ^ (parent >> 9)) & mask;
        int stored = parent + 1;
        while (true)
        {
            int p = _slotParents[i];
            if (p == stored && _slotBytes[i] == key)
            {
                _slotParents[i] = -1;
                _slotsLive -= 1;
                return;
            }
            if (p == 0)
                return;
            i = (i + 1) & mask;
        }
    }

    void _Rehash()
    {
        int size = _slotParents.Length;
        while (_slotsLive * 4 > size)
            size *= 2;
        var oldParents = _slotParents;
        var oldBytes = _slotBytes;
        var oldNodes = _slotNodes;
        _slotParents = new int[size];
        _slotBytes = new uint8[size];
        _slotNodes = new int[size];
        int mask = size - 1;
        for (var j = 0; j < oldParents.Length; j += 1)
        {
            int p = oldParents[j];
            if (p <= 0)
                continue;
            int i = _Slot(p - 1, oldBytes[j], mask);
            while (_slotParents[i] != 0)
                i = (i + 1) & mask;
            _slotParents[i] = p;
            _slotBytes[i] = oldBytes[j];
            _slotNodes[i] = oldNodes[j];
        }
        _slotsUsed = _slotsLive;
    }
}
