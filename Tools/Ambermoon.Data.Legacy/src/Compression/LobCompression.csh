namespace Ambermoon.Data.Legacy.Compression;

using Ambermoon.Data.Legacy.Serialization;

/// The compression of a LOB file: the upper byte of the dword after the LOB header.
enum LobType : uint8
{
    /// Writing only: the smallest of [LobType.Ambermoon], [LobType.LZRS] and [LobType.Extended].
    TakeBest = 0x00,
    /// Writing only: the smaller of [LobType.Ambermoon] and [LobType.Text].
    TakeBestForText = 0x01,
    /// The LOB compression of the original game.
    Ambermoon = 0x06,
    /// Extended LOB (Ambermoon Advanced): longer matches, runs of the same byte.
    LZRS = 0x10,
    /// Advanced LOB (Ambermoon Advanced): small and large matches, runs, small literals.
    Extended = 0x11,
    /// Text LOB (Ambermoon Advanced): for texts, with 2-byte matches.
    Text = 0x12
}

/// Compressing and decompressing data with one of the LOB compressions.
struct LobCompression
{
    /// `data` compressed with `lobType` ([LobType.TakeBest] and [LobType.TakeBestForText] mean [LobType.Ambermoon]
    /// here; [FileWriter] chooses between the compressions).
    static Error<uint8[]> Compress(uint8[] data, LobType lobType)
    {
        switch (lobType)
        {
            case LobType.LZRS:
                return ExtendedLob.CompressData(data);
            case LobType.Extended:
                return AdvancedLob.CompressData(data);
            case LobType.Text:
                return TextLob.CompressData(data);
            default:
                return Lob.CompressData(data);
        }
    }

    /// Decompresses `decodedSize` bytes from the reader's position on. A type that is not known means
    /// [LobType.Ambermoon].
    static Error<DataReader> Decompress(ref DataReader reader, uint32 decodedSize, LobType lobType)
    {
        switch (lobType)
        {
            case LobType.LZRS:
                return ExtendedLob.Decompress(ref reader, decodedSize);
            case LobType.Extended:
                return AdvancedLob.Decompress(ref reader, decodedSize);
            case LobType.Text:
                return TextLob.Decompress(ref reader, decodedSize);
            default:
                return Lob.Decompress(ref reader, decodedSize);
        }
    }

    /// Decompresses `decodedSize` bytes of `data`.
    static Error<DataReader> Decompress(uint8[] data, uint32 decodedSize, LobType lobType)
    {
        var reader = DataReader.FromData(data);
        return Decompress(ref reader, decodedSize, lobType);
    }
}

// the message of .NET's IndexOutOfRangeException: what the original reports for data that ends too early or refers
// to bytes outside of the result
const string _OutOfBounds = "Index was outside the bounds of the array.";
