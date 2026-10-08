namespace Ambermoon.Data.Legacy.Serialization;

/// The format of a file: the first 4 bytes of the file (a big-endian dword).
enum FileType : uint32
{
    /// A raw file (no header).
    None = 0,
    /// JH-encrypted (Jurie Horneman's encryption); the lower word of the header holds the key (xor 0x4a48).
    JH = 0x4a480000,
    /// LOB-compressed (Lothar Becks' compression).
    LOB = 0x014c4f42,
    /// Another LOB-compressed format.
    VOL1 = 0x564f4c31,
    /// A container of several files, all JH-encrypted ("crypted").
    AMNC = 0x414d4e43,
    /// A container of several files, JH-encrypted and mostly LOB-compressed as well ("packed").
    AMNP = 0x414d4e50,
    /// A container of several raw files.
    AMBR = 0x414d4252,
    /// A container of several LOB-compressed files.
    AMPC = 0x414d5043,
    /// Not a header of its own: JH with a LOB-compressed file inside. The key is in the lower word.
    JHPlusLOB = 0xaaaa0000,
    /// Not a header of its own: JH with an AMBR container inside. The key is in the lower word.
    JHPlusAMBR = 0xbbbb0000,
    /// A special container of texts.
    AMTX = 0x414d5458
}

/// The file type of a header: JH (and the special JH types) by the upper word, the others by the whole dword.
FileType AsFileType(uint32 header)
{
    uint32 upperHalf = header & 0xffff0000;
    if (upperHalf == (uint32)FileType.JH)
        return FileType.JH;
    if (upperHalf == (uint32)FileType.JHPlusLOB)
        return FileType.JHPlusLOB;
    if (upperHalf == (uint32)FileType.JHPlusAMBR)
        return FileType.JHPlusAMBR;
    return (FileType)header;
}

/// Whether the header is one of the JH types.
bool IsJH(uint32 header)
{
    var fileType = AsFileType(header);
    return fileType == FileType.JH || fileType == FileType.JHPlusLOB || fileType == FileType.JHPlusAMBR;
}

/// How the table of file sizes of a container is stored (an extension of Ambermoon Advanced; the original reads only
/// [FileDictionaryCompression.None]).
enum FileDictionaryCompression : int32
{
    /// A dword per file.
    None = 0,
    /// A word per file (if every file is smaller than 64 KB).
    HalfEntrySize = 1,
    /// Runs of files without gaps ("sections"), so that missing files take no room.
    UseSections = 2,
    /// Both.
    Both = 3,
    /// Half entry sizes if possible, sections only when they save enough.
    UseBest = 4
}
