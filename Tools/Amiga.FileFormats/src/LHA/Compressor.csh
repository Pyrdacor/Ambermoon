namespace Amiga.FileFormats.LHA;

using System;

/// The compression methods of LHA archives.
enum CompressionMethod : uint8
{
    /// Stored (`-lh0-`).
    None = 0,
    /// LZ77 with an 8 KB dictionary and Huffman codes (`-lh5-`).
    LH5 = 1,
    /// The same with a 32 KB dictionary (`-lh6-`).
    LH6 = 2,
    /// The same with a 64 KB dictionary (`-lh7-`).
    LH7 = 3,
    /// LArc's `-lz5-` (only read by the original, not written).
    LZ5 = 4
}

/// The name of a compression method in an entry header; "" for one that cannot be written.
string CompressionMethodName(CompressionMethod method)
{
    switch (method)
    {
        case CompressionMethod.None: return "-lh0-";
        case CompressionMethod.LH5: return "-lh5-";
        case CompressionMethod.LH6: return "-lh6-";
        case CompressionMethod.LH7: return "-lh7-";
        default: return "";
    }
}

/// The CRC-16 of LHA (the polynomial 0xA001, starting at 0).
uint16 Crc16(ReadOnlySlice<uint8> data)
{
    int crc = 0;
    for (var i = 0; i < data.Length; i += 1)
        crc = _Crc16Table[(crc ^ data[i]) & 0xff] ^ (crc >> 8);
    return (uint16)crc;
}

const ReadOnlySlice<int> _Crc16Table = [
    0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241, 0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
    0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40, 0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
    0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40, 0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
    0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641, 0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
    0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240, 0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
    0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41, 0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
    0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41, 0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
    0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640, 0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
    0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240, 0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
    0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41, 0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
    0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41, 0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
    0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640, 0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
    0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241, 0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
    0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40, 0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
    0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40, 0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
    0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641, 0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040
];

const int _MaxMatch = 256;
const int _HashSize = 1 << 15;
const int _HashMask = _HashSize - 1;
const int _Threshold = 3;
const int _HashChainLimit = 0x100;
const int _CharBits = 8;
const int _BufferSize = 65408;
const int _NP = 16 + 1;           // the most position codes (LH7)
const int _NT = 19;
const int _NC = 255 + _MaxMatch + 2 - _Threshold;
const int _NPT = 0x80;
const int _TBit = 5;
const int _CBit = 9;

struct _LhaMatch
{
    int Length;
    int Offset;
}

/// The result of [LhaCompress]: the compressed data, or the data itself when it does not get smaller (`Stored`), and
/// the CRC-16 of the data.
struct LhaCompressed
{
    uint8[] Data;
    bool Stored;
    uint16 Crc;
}

/// Compresses `rawData` with `method` (LH5, LH6 or LH7) like the encoder of LHa for UNIX (as ported by
/// Amiga.FileFormats.LHA, whose output this is byte for byte); stored when the result is not smaller.
LhaCompressed LhaCompress(uint8[] rawData, CompressionMethod method)
{
    if (method != CompressionMethod.LH5 && method != CompressionMethod.LH6 && method != CompressionMethod.LH7)
        return LhaCompressed { Data = rawData, Stored = true, Crc = Crc16(rawData) };
    int dictBits = method == CompressionMethod.LH5 ? 13 : method == CompressionMethod.LH6 ? 15 : 16;
    var c = _LhaCompressor.Create(rawData, dictBits, method == CompressionMethod.LH5 ? 4 : 5);
    c.Run();
    if (c.CannotPack)
        return LhaCompressed { Data = rawData, Stored = true, Crc = Crc16(rawData) };
    return LhaCompressed { Data = c.Output.ToArray(), Stored = false, Crc = (uint16)c.Crc };
}

// The state of the encoder (the local functions of the original, which share its locals).
struct _LhaCompressor
{
    uint8[] RawData;
    int DictSize;
    int TextSize;
    int Np;
    int PBit;
    uint8[] Text;
    int DataPosition;
    int Remainder;
    int Position;
    uint32 Token;
    int[] PreviousHashPosition;
    int[] HashPosition;
    bool[] HashTooLong;
    int OutputMask;
    int OutputPosition;
    int Cpos;
    uint8[] Buffer;
    int[] Left;
    int[] Right;
    int[] CCode;
    int[] PtCode;
    int[] CFreq;
    int[] PFreq;
    int[] TFreq;
    int[] CLen;
    int[] PtLen;
    int BitCount;
    int SubBitBuffer;
    int CompressedSize;
    bool CannotPack;
    List<uint8> Output;
    int Crc;
    _LhaMatch Match;

    static _LhaCompressor Create(uint8[] rawData, int dictBits, int pbit)
    {
        int dictSize = 1 << dictBits;
        int textSize = dictSize * 2 + _MaxMatch;
        var text = new uint8[textSize];
        for (var i = 0; i < textSize; i += 1)
            text[i] = ' ';
        return _LhaCompressor
        {
            RawData = rawData, DictSize = dictSize, TextSize = textSize, Np = dictBits + 1, PBit = pbit, Text = text,
            PreviousHashPosition = new int[dictSize], HashPosition = new int[_HashSize], HashTooLong = new bool[_HashSize],
            Buffer = new uint8[_BufferSize], Left = new int[2 * _NC - 1], Right = new int[2 * _NC - 1], CCode = new int[_NC],
            PtCode = new int[_NPT], CFreq = new int[2 * _NC - 1], PFreq = new int[2 * _NP - 1], TFreq = new int[2 * _NT - 1],
            CLen = new int[_NC], PtLen = new int[_NPT], BitCount = _CharBits, Output = List<uint8>.Create()
        };
    }

    void Run()
    {
        Match.Length = _Threshold - 1;
        Match.Offset = 0;
        Remainder = ReadBytes(DictSize, TextSize - DictSize);
        if (Match.Length > Remainder)
            Match.Length = Remainder;
        Position = DictSize;

        Token = InitHash(Position);
        InsertHash(Token, Position);
        while (Remainder > 0 && !CannotPack)
        {
            var last = Match;
            NextToken();
            SearchDict(Token, Position, last.Length - 1);
            InsertHash(Token, Position);
            if (Match.Length > last.Length || last.Length < _Threshold)
                Output1(Text[Position - 1], 0);   // a literal
            else
            {
                // a match: length and offset
                Output1(last.Length + (256 - _Threshold), (last.Offset - 1) & (DictSize - 1));
                last.Length -= 1;
                last.Length -= 1;
                while (last.Length > 0)
                {
                    NextToken();
                    InsertHash(Token, Position);
                    last.Length -= 1;
                }
                NextToken();
                SearchDict(Token, Position, _Threshold - 1);
                InsertHash(Token, Position);
            }
        }
        // EncodeEnd
        if (!CannotPack)
        {
            SendBlock();
            PutBits(_CharBits - 1, 0); // the remaining bits
        }
    }

    uint32 InitHash(int position)
    {
        return (uint32)((((Text[position] << 5) ^ Text[position + 1]) << 5) ^ Text[position + 2]) & (uint32)_HashMask;
    }

    uint32 NextHash(uint32 hash, int position)
    {
        return ((hash << 5) ^ Text[position + 2]) & (uint32)_HashMask;
    }

    int ReadBytes(int offset, int size)
    {
        int readSize = Math.Min(size, RawData.Length - DataPosition);
        for (var i = 0; i < readSize; i += 1)
        {
            uint8 b = RawData[DataPosition + i];
            Crc = _Crc16Table[(Crc ^ b) & 0xff] ^ (Crc >> 8);
            Text[offset + i] = b;
        }
        DataPosition += readSize;
        return readSize;
    }

    void InsertHash(uint32 token, int position)
    {
        PreviousHashPosition[position & (DictSize - 1)] = HashPosition[(int)token];
        HashPosition[(int)token] = position;
    }

    void NextToken()
    {
        Remainder -= 1;
        Position += 1;
        if (Position >= TextSize - _MaxMatch)
            UpdateDict();
        Token = NextHash(Token, Position);
    }

    void UpdateDict()
    {
        Array.Copy(Text, DictSize, Text, 0, TextSize - DictSize);
        int n = ReadBytes(TextSize - DictSize, DictSize);
        Remainder += n;
        Position -= DictSize;
        for (var i = 0; i < _HashSize; i += 1)
        {
            int j = HashPosition[i];
            HashPosition[i] = j > DictSize ? j - DictSize : 0;
            HashTooLong[i] = false;
        }
        for (var i = 0; i < DictSize; i += 1)
        {
            int j = PreviousHashPosition[i];
            PreviousHashPosition[i] = j > DictSize ? j - DictSize : 0;
        }
    }

    // the longest match for the current token
    void SearchDict(uint32 token, int position, int minMatchLength)
    {
        if (minMatchLength < _Threshold - 1)
            minMatchLength = _Threshold - 1;
        Match.Offset = 0;
        Match.Length = minMatchLength;
        int offset = 0;
        uint32 tok = token;
        while (HashTooLong[(int)tok] && offset < _MaxMatch - _Threshold)
        {
            // the chain of the token is too long: search with a following token (for speed)
            offset += 1;
            tok = NextHash(tok, position + offset);
        }
        if (offset == _MaxMatch - _Threshold)
        {
            offset = 0;
            tok = token;
        }
        SearchDictInternal(tok, position, offset, _MaxMatch);
        if (offset > 0 && Match.Length < offset + 3)
            SearchDictInternal(token, position, 0, offset + 2); // search again
        if (Match.Length > Remainder)
            Match.Length = Remainder;
    }

    void SearchDictInternal(uint32 token, int position, int offset, int maxMatchLength)
    {
        int chain = 0;
        int scanPosition = HashPosition[(int)token];
        int scanBegin = scanPosition - offset;
        int scanEnd = position - DictSize;
        while (scanBegin > scanEnd)
        {
            chain += 1;
            if (Text[scanBegin + Match.Length] == Text[position + Match.Length])
            {
                int length = 0;
                while (length < maxMatchLength && Text[scanBegin + length] == Text[position + length])
                    length += 1;
                if (length > Match.Length)
                {
                    Match.Offset = position - scanBegin;
                    Match.Length = length;
                    if (Match.Length == maxMatchLength)
                        break;
                }
            }
            scanPosition = PreviousHashPosition[scanPosition & (DictSize - 1)];
            scanBegin = scanPosition - offset;
        }
        if (chain >= _HashChainLimit)
            HashTooLong[(int)token] = true;
    }

    // Output of the original: a literal (c < 256) or a match (c = length + 253, p = offset - 1)
    void Output1(int c, int p)
    {
        OutputMask >>= 1;
        if (OutputMask == 0)
        {
            OutputMask = 1 << (_CharBits - 1);
            if (OutputPosition >= _BufferSize - 3 * _CharBits)
            {
                SendBlock();
                if (CannotPack)
                    return;
                OutputPosition = 0;
            }
            Cpos = OutputPosition;
            OutputPosition += 1;
            Buffer[Cpos] = 0;
        }
        Buffer[OutputPosition] = (uint8)(c & 0xff);
        OutputPosition += 1;
        CFreq[c] = (CFreq[c] + 1) & 0xffff;
        if (c >= (1 << _CharBits))
        {
            Buffer[Cpos] |= (uint8)OutputMask;
            Buffer[OutputPosition] = (uint8)(p >> _CharBits);
            Buffer[OutputPosition + 1] = (uint8)(p & 0xff);
            OutputPosition += 2;
            int bits = 0;
            while (p != 0)
            {
                p >>= 1;
                bits += 1;
            }
            PFreq[bits] = (PFreq[bits] + 1) & 0xffff;
        }
    }

    void SendBlock()
    {
        int root = MakeTree(_NC, CFreq, CLen, CCode);
        int size = CFreq[root];
        PutBits(16, (uint32)size);
        if (root >= _NC)
        {
            CountTreeFreq();
            root = MakeTree(_NT, TFreq, PtLen, PtCode);
            if (root >= _NT)
                WritePreTreeLength(_NT, _TBit, 3);
            else
            {
                PutBits(_TBit, 0);
                PutBits(_TBit, (uint32)root);
            }
            WriteCodeLength();
        }
        else
        {
            PutBits(_TBit, 0);
            PutBits(_TBit, 0);
            PutBits(_CBit, 0);
            PutBits(_CBit, (uint32)root);
        }
        root = MakeTree(Np, PFreq, PtLen, PtCode);
        if (root >= Np)
            WritePreTreeLength(Np, PBit, -1);
        else
        {
            PutBits(PBit, 0);
            PutBits(PBit, (uint32)root);
        }

        int position = 0;
        int flags = 0;
        for (var i = 0; i < size; i += 1)
        {
            if (i % _CharBits == 0)
            {
                flags = Buffer[position];
                position += 1;
            }
            else
                flags = (flags << 1) & 0xff;
            if ((flags & (1 << (_CharBits - 1))) != 0)
            {
                // a match
                EncodeWithTree(Buffer[position] + (1 << _CharBits));
                int k = (Buffer[position + 1] << _CharBits) + Buffer[position + 2];
                position += 3;
                EncodeWithPreTree(k);
            }
            else
            {
                // a literal
                EncodeWithTree(Buffer[position]);
                position += 1;
            }
            if (CannotPack)
                return;
        }
        for (var i = 0; i < _NC; i += 1)
            CFreq[i] = 0;
        for (var i = 0; i < Np; i += 1)
            PFreq[i] = 0;
        // (the frequencies of the code length tree are not reset, like in the original)
    }

    void EncodeWithTree(int value)
    {
        PutCode(CLen[value], (uint32)CCode[value]);
    }

    void EncodeWithPreTree(int value)
    {
        int c = 0;
        int v = value;
        while (v != 0)
        {
            v >>= 1;
            c += 1;
        }
        PutCode(PtLen[c], (uint32)PtCode[c]);
        if (c > 1)
            PutBits(c - 1, (uint32)value);
    }

    void WriteCodeLength()
    {
        int n = _NC;
        while (n > 0 && CLen[n - 1] == 0)
            n -= 1;
        PutBits(_CBit, (uint32)n);
        int i = 0;
        while (i < n)
        {
            int k = CLen[i];
            i += 1;
            if (k == 0)
            {
                int count = 1;
                while (i < n && CLen[i] == 0)
                {
                    i += 1;
                    count += 1;
                }
                if (count <= 2)
                {
                    for (var z = 0; z < count; z += 1)
                        PutCode(PtLen[0], (uint32)PtCode[0]);
                }
                else if (count <= 18)
                {
                    PutCode(PtLen[1], (uint32)PtCode[1]);
                    PutBits(4, (uint32)(count - 3));
                }
                else if (count == 19)
                {
                    PutCode(PtLen[0], (uint32)PtCode[0]);
                    PutCode(PtLen[1], (uint32)PtCode[1]);
                    PutBits(4, 15);
                }
                else
                {
                    PutCode(PtLen[2], (uint32)PtCode[2]);
                    PutBits(_CBit, (uint32)(count - 20));
                }
            }
            else
                PutCode(PtLen[k + 2], (uint32)PtCode[k + 2]);
        }
    }

    void WritePreTreeLength(int n, int nbit, int special)
    {
        while (n > 0 && PtLen[n - 1] == 0)
            n -= 1;   // trailing zero lengths are left out
        PutBits(nbit, (uint32)n);
        int i = 0;
        while (i < n)
        {
            int k = PtLen[i];
            i += 1;
            if (k <= 6)
                PutBits(3, (uint32)k);
            else
                PutBits(k - 3, 0xFFFFu << 1);   // 7: 1110, 8: 11110, ...
            if (i == special)
            {
                // the lengths 3, 4 and 5 are rare: zero lengths at 3 to 5 are skipped with 2 bits
                while (i < 6 && PtLen[i] == 0)
                    i += 1;
                PutBits(2, (uint32)(i - 3));
            }
        }
    }

    void CountTreeFreq()
    {
        int n = _NC;
        while (n > 0 && CLen[n - 1] == 0)
            n -= 1;
        int i = 0;
        while (i < n)
        {
            int k = CLen[i];
            i += 1;
            if (k == 0)
            {
                int count = 1;
                while (i < n && CLen[i] == 0)
                {
                    i += 1;
                    count += 1;
                }
                if (count <= 2)
                    TFreq[0] = (TFreq[0] + count) & 0xffff;
                else if (count <= 18)
                    TFreq[1] = (TFreq[1] + 1) & 0xffff;
                else if (count == 19)
                {
                    TFreq[0] = (TFreq[0] + 1) & 0xffff;
                    TFreq[1] = (TFreq[1] + 1) & 0xffff;
                }
                else
                    TFreq[2] = (TFreq[2] + 1) & 0xffff;
            }
            else
                TFreq[k + 2] = (TFreq[k + 2] + 1) & 0xffff;
        }
    }

    void PutBits(int bits, uint32 value)
    {
        value &= 0xffff;
        value <<= 16 - bits;
        value &= 0xffff;
        PutCode(bits, value);
    }

    void PutCode(int bits, uint32 code)
    {
        code &= 0xffff;
        while (bits >= BitCount)
        {
            bits -= BitCount;
            SubBitBuffer = (SubBitBuffer + (int)((code >> (16 - BitCount)) & 0xff)) & 0xff;
            code <<= BitCount;
            if (CompressedSize < RawData.Length)
            {
                Output.Add((uint8)SubBitBuffer);
                CompressedSize += 1;
            }
            else
                CannotPack = true;
            SubBitBuffer = 0;
            BitCount = _CharBits;
        }
        SubBitBuffer = (SubBitBuffer + (int)((code >> (16 - BitCount)) & 0xff)) & 0xff;
        BitCount -= bits;
    }

    // A Huffman tree of the frequencies: the code lengths and codes; the root (a symbol when there are fewer than
    // two symbols). The sorted leaves are kept in `code` until the codes are made.
    int MakeTree(int nchar, int[] freq, int[] bitLength, int[] code)
    {
        var heap = new int[_NC + 1];
        int heapSize = 0;
        int avail = nchar;
        heap[1] = 0;
        for (var i = 0; i < nchar; i += 1)
        {
            bitLength[i] = 0;
            if (freq[i] != 0)
            {
                heapSize += 1;
                heap[heapSize] = i;
            }
        }
        if (heapSize < 2)
        {
            code[heap[1]] = 0;
            return heap[1];
        }
        for (var i = heapSize / 2; i >= 1; i -= 1)
            DownHeap(i, heap, heapSize, freq);

        int sort = 0;
        int root;
        do
        {
            int i = heap[1];   // the least frequent entry
            if (i < nchar)
            {
                code[sort] = i;
                sort += 1;
            }
            heap[1] = heap[heapSize];
            heapSize -= 1;
            DownHeap(1, heap, heapSize, freq);
            int j = heap[1];   // the next least frequent entry
            if (j < nchar)
            {
                code[sort] = j;
                sort += 1;
            }
            root = avail;
            avail += 1;
            freq[root] = (freq[i] + freq[j]) & 0xffff;
            heap[1] = root;
            DownHeap(1, heap, heapSize, freq);
            Left[root] = i;
            Right[root] = j;
        } while (heapSize > 1);

        var leafNum = new int[17];
        CountLeaf(root, nchar, leafNum, 0);
        MakeLength(nchar, bitLength, code, leafNum);
        MakeCode(nchar, bitLength, code, leafNum);
        return root;
    }

    void DownHeap(int i, int[] heap, int heapSize, int[] freq)
    {
        int k = heap[i];
        while (2 * i <= heapSize)
        {
            int j = 2 * i;
            if (j < heapSize && freq[heap[j]] > freq[heap[j + 1]])
                j += 1;
            if (freq[k] <= freq[heap[j]])
                break;
            heap[i] = heap[j];
            i = j;
        }
        heap[i] = k;
    }

    void MakeLength(int nchar, int[] bitLength, int[] sort, int[] leafNum)
    {
        uint32 c = 0;
        for (var i = 16; i > 0; i -= 1)
            c += (uint32)leafNum[i] << (16 - i);
        c &= 0xffff;
        // limit the lengths to 16 bits
        if (c != 0)
        {
            leafNum[16] = (int)(((uint32)leafNum[16] - c) & 0xffff);
            do
            {
                for (var i = 15; i > 0; i -= 1)
                {
                    if (leafNum[i] != 0)
                    {
                        leafNum[i] -= 1;
                        leafNum[i + 1] = (leafNum[i + 1] + 2) & 0xffff;
                        break;
                    }
                }
                c -= 1;
            } while (c != 0);
        }
        int s = 0;
        for (var i = 16; i > 0; i -= 1)
        {
            int k = leafNum[i];
            while (k > 0)
            {
                bitLength[sort[s]] = i;
                s += 1;
                k -= 1;
            }
        }
    }

    void CountLeaf(int node, int nchar, int[] leafNum, int depth)
    {
        if (node < nchar)
            leafNum[depth < 16 ? depth : 16] += 1;
        else
        {
            CountLeaf(Left[node], nchar, leafNum, depth + 1);
            CountLeaf(Right[node], nchar, leafNum, depth + 1);
        }
    }

    void MakeCode(int nchar, int[] bitLength, int[] code, int[] leafNum)
    {
        var weight = new int[17];
        var start = new int[17];
        int total = 0;
        for (var i = 1; i <= 16; i += 1)
        {
            start[i] = total;
            weight[i] = 1 << (16 - i);
            total = (total + weight[i] * leafNum[i]) & 0xffff;
        }
        for (var c = 0; c < nchar; c += 1)
        {
            int i = bitLength[c];
            code[c] = start[i];
            start[i] = (start[i] + weight[i]) & 0xffff;
        }
    }
}
