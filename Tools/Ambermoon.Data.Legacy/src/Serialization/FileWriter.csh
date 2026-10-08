namespace Ambermoon.Data.Legacy.Serialization;

using System;
using Ambermoon.Data.Legacy.Compression;

/// Writes the files of the game: single files (JH, LOB, VOL1, raw) and containers (AMNC, AMNP, AMBR, AMPC).
///
/// The `compressionPrinter` parameters are told about every compressed file: (size before, size after, the number of
/// the file in its container). They may be `null`.
struct FileWriter
{
    /// Writes a file that [FileReader] read (for JH files the key is 0: the container does not keep it).
    static Error<void> Write(ref DataWriter writer, FileContainer fileContainer)
    {
        return Write(ref writer, fileContainer, LobType.Ambermoon, FileDictionaryCompression.None, null);
    }

    /// Writes a file that [FileReader] read, compressing LOB files and container files with `lobType`.
    static Error<void> Write(ref DataWriter writer, FileContainer fileContainer, LobType lobType,
                             FileDictionaryCompression fileDictionaryCompression, Action<int, int, Optional<int>> compressionPrinter)
    {
        uint32 header = fileContainer.Header();
        var key = (uint16)(header & 0xffff);

        switch (AsFileType(header))
        {
            case FileType.JH:
                return WriteJH(ref writer, _AlignData(fileContainer.Files[1].ToArray()), key, false, false, LobType.Ambermoon);
            case FileType.LOB:
                return WriteLob(ref writer, fileContainer.Files[1].ToArray(), lobType, null);
            case FileType.VOL1:
                return WriteVol1(ref writer, fileContainer.Files[1].ToArray(), lobType, null);
            case FileType.AMBR:
            case FileType.AMNC:
            case FileType.AMNP:
            case FileType.AMPC:
                return WriteContainer(ref writer, _FileData(fileContainer), AsFileType(header), null, lobType, fileDictionaryCompression,
                                      compressionPrinter);
            case FileType.JHPlusAMBR:
            {
                var ambrWriter = new DataWriter();
                try WriteContainer(ref ambrWriter, _FileData(fileContainer), FileType.AMBR);
                return WriteJH(ref writer, _AlignData(ambrWriter.ToArray()), key, false, false, LobType.Ambermoon);
            }
            case FileType.JHPlusLOB:
                return WriteJH(ref writer, fileContainer.Files[1].ToArray(), key, true, false, lobType);
            default: // raw
                writer.WriteBytes(fileContainer.Files[1].ToArray());
                return;
        }
    }

    /// Writes a JH file: `fileData` (LOB-compressed first if `additionalLobCompression`) encrypted with
    /// `encryptKey`, after the JH header unless `noHeader`. `fileData` is not changed (the original encrypts the
    /// caller's array in place).
    static Error<void> WriteJH(ref DataWriter writer, uint8[] fileData, uint16 encryptKey, bool additionalLobCompression, bool noHeader,
                               LobType lobType)
    {
        uint8[] data;
        if (additionalLobCompression)
        {
            var lobWriter = new DataWriter();
            try _WriteLob(ref lobWriter, fileData, (uint32)FileType.LOB, lobType, null);
            data = _AlignData(lobWriter.ToArray());
        }
        else
        {
            data = fileData.Clone();
        }

        JH.Crypt(data, encryptKey);

        if (!noHeader)
        {
            uint32 jh = (uint32)FileType.JH;
            writer.WriteDword(jh | (((jh >> 16) ^ encryptKey) & 0xffff));
        }
        writer.WriteBytes(data);
        return;
    }

    /// Writes a JH file without LOB compression.
    static Error<void> WriteJH(ref DataWriter writer, uint8[] fileData, uint16 encryptKey, bool additionalLobCompression)
    {
        return WriteJH(ref writer, fileData, encryptKey, additionalLobCompression, false, LobType.Ambermoon);
    }

    /// Writes a LOB file (an odd size is padded with a 0 byte first).
    static Error<void> WriteLob(ref DataWriter writer, uint8[] fileData, LobType lobType, Action<int, int, Optional<int>> compressionPrinter)
    {
        return _WriteLob(ref writer, _AlignData(fileData), (uint32)FileType.LOB, lobType, compressionPrinter);
    }

    /// Writes a VOL1 file (an odd size is padded with a 0 byte first).
    static Error<void> WriteVol1(ref DataWriter writer, uint8[] fileData, LobType lobType, Action<int, int, Optional<int>> compressionPrinter)
    {
        return _WriteLob(ref writer, _AlignData(fileData), (uint32)FileType.VOL1, lobType, compressionPrinter);
    }

    static Error<void> _WriteLob(ref DataWriter writer, uint8[] fileData, uint32 header, LobType lobType,
                                 Action<int, int, Optional<int>> compressionPrinter)
    {
        if (lobType == LobType.TakeBest)
        {
            var extendedLobWriter = new DataWriter();
            try _WriteLob(ref extendedLobWriter, fileData, header, LobType.LZRS, compressionPrinter);
            var advancedLobWriter = new DataWriter();
            try _WriteLob(ref advancedLobWriter, fileData, header, LobType.Extended, compressionPrinter);
            var originalLobWriter = new DataWriter();
            try _WriteLob(ref originalLobWriter, fileData, header, LobType.Ambermoon, compressionPrinter);

            if (advancedLobWriter.Size() < originalLobWriter.Size())
            {
                if (extendedLobWriter.Size() <= advancedLobWriter.Size())
                    writer.WriteBytes(extendedLobWriter.AsSlice());
                else
                    writer.WriteBytes(advancedLobWriter.AsSlice());
            }
            else if (extendedLobWriter.Size() < originalLobWriter.Size())
            {
                writer.WriteBytes(extendedLobWriter.AsSlice());
            }
            else
            {
                writer.WriteBytes(originalLobWriter.AsSlice());
            }
            return;
        }

        if (lobType == LobType.TakeBestForText)
        {
            var textLobWriter = new DataWriter();
            try _WriteLob(ref textLobWriter, fileData, header, LobType.Text, compressionPrinter);
            var originalLobWriter = new DataWriter();
            try _WriteLob(ref originalLobWriter, fileData, header, LobType.Ambermoon, compressionPrinter);

            if (textLobWriter.Size() < originalLobWriter.Size())
                writer.WriteBytes(textLobWriter.AsSlice());
            else
                writer.WriteBytes(originalLobWriter.AsSlice());
            return;
        }

        var compressedData = try LobCompression.Compress(fileData, lobType);
        // (the original passes the sizes in this order here)
        if (compressionPrinter != null)
            compressionPrinter(compressedData.Length, fileData.Length, null);

        if (fileData.Length % 2 == 1 || compressedData.Length % 2 == 1)
            return error("[Application] Lob source or compressed data is not word-aligned.");

        writer.WriteDword(header);
        writer.WriteDword((uint32)fileData.Length | ((uint32)lobType << 24));
        writer.WriteDword((uint32)compressedData.Length);
        writer.WriteBytes(compressedData);
        return;
    }

    /// Writes a container of the files (numbered from 1 on) without compression options.
    static Error<void> WriteContainer(ref DataWriter writer, Dictionary<uint32, uint8[]> filesData, FileType fileType)
    {
        return WriteContainer(ref writer, filesData, fileType, null, LobType.Ambermoon, FileDictionaryCompression.None, null);
    }

    /// Writes a container (AMNC, AMNP, AMBR or AMPC) of the files, by their numbers (from 1 on; missing numbers are
    /// empty files). `minimumFileCount` makes the container have at least that many files.
    static Error<void> WriteContainer(ref DataWriter writer, Dictionary<uint32, uint8[]> filesData, FileType fileType,
                                      Optional<int> minimumFileCount, LobType lobType, FileDictionaryCompression fileDictionaryCompression,
                                      Action<int, int, Optional<int>> compressionPrinter)
    {
        switch (fileType)
        {
            case FileType.JHPlusAMBR:
                return error("[Data] File type '" + fileType + "' is no valid container format. Use the Write method instead for this file type.");
            case FileType.AMNC:
            case FileType.AMNP:
            case FileType.AMBR:
            case FileType.AMPC:
                break;
            default:
                return error("[Data] File type '" + fileType + "' is no container format.");
        }

        if (filesData.Count() >= 0xffff) // JH uses the 1-based index as a word
            return error("[Data] In a container file there can only be " + (0xffff - 1).ToString() + " files at max.");
        if (filesData.ContainsKey(0))
            return error("[Data] The first file must have index 1 and not 0.");
        if (filesData.Count() == 0)
            return error("Sequence contains no elements");

        var sortedKeys = List<uint32>.Create();
        foreach (var key in filesData.Keys())
            sortedKeys.Add(key);
        sortedKeys.Sort();
        uint32 maxIndex = sortedKeys[sortedKeys.Count() - 1];

        var writerWithoutHeader = new DataWriter();
        int totalFileNumber = (int)maxIndex;
        int minimumCount = minimumFileCount is int m ? m : 0;
        if (minimumFileCount is int minimum && minimum > totalFileNumber)
            totalFileNumber = minimum;
        var fileSizes = new int[totalFileNumber];

        foreach (var key in sortedKeys)
        {
            var fileData = filesData[key];
            if (fileData.Length == 0)
            {
                fileSizes[(int)key - 1] = 0;
                continue;
            }

            int prevOffset = writerWithoutHeader.Position();

            if (fileType == FileType.AMNC)
            {
                try WriteJH(ref writerWithoutHeader, fileData, (uint16)key, false);
            }
            else if (fileType == FileType.AMBR)
            {
                writerWithoutHeader.WriteBytes(fileData);
            }
            else if (fileType == FileType.AMPC)
            {
                int position = writerWithoutHeader.Position();
                try WriteLob(ref writerWithoutHeader, fileData, lobType, null);
                if (compressionPrinter != null)
                    compressionPrinter(fileData.Length, writerWithoutHeader.Position() - position, (int)key);
            }
            else // AMNP
            {
                // LOB-compressed if that is smaller, always JH-encrypted (behind the first 8 bytes of a LOB file, or
                // behind 4 zeros)
                var lobWriter = new DataWriter();
                try WriteLob(ref lobWriter, fileData, lobType, null);
                bool lob = lobWriter.Size() - 4 < fileData.Length;
                int dataLength = lob ? lobWriter.Size() : fileData.Length;
                if (compressionPrinter != null)
                    compressionPrinter(fileData.Length, dataLength, (int)key);
                uint8[] encodedData;
                if (lob)
                {
                    writerWithoutHeader.WriteBytes(lobWriter.AsSlice()[0..8]);
                    encodedData = lobWriter.GetBytes(8, lobWriter.Size() - 8);
                }
                else
                {
                    writerWithoutHeader.WriteDword(0);
                    encodedData = fileData.Clone();
                }
                JH.Crypt(encodedData, (uint16)key);
                writerWithoutHeader.WriteBytes(encodedData);
            }

            fileSizes[(int)key - 1] = writerWithoutHeader.Position() - prevOffset;
        }

        writer.WriteDword((uint32)fileType);

        if (fileDictionaryCompression != FileDictionaryCompression.None)
        {
            uint32 largestGapSize = 0;
            uint32 sectionStart = 1;
            bool isGap = false;
            var sectionStarts = List<uint32>.Create();
            var sectionCounts = List<uint32>.Create();

            if (maxIndex > 530) // the limit of the original code
                return error("[Application] More than 530 files are not allowed.");

            bool useSections = false;

            // Sections are not possible if the minimum file count exceeds the highest file number: the empty files
            // at the end could not be expressed.
            if (fileDictionaryCompression != FileDictionaryCompression.HalfEntrySize && (minimumFileCount == null || minimumCount <= (int)maxIndex))
            {
                for (uint32 i = 1; i <= maxIndex; i += 1)
                {
                    bool empty = !(filesData.TryGet(i) is uint8[] data && data.Length != 0);
                    if (empty)
                    {
                        if (i == 1)
                        {
                            isGap = true;
                        }
                        else if (!isGap)
                        {
                            sectionStarts.Add(sectionStart);
                            sectionCounts.Add(i - sectionStart);
                            isGap = true;
                            sectionStart = i;
                        }
                    }
                    else if (isGap)
                    {
                        uint32 gapSize = i - sectionStart;
                        if (gapSize > largestGapSize)
                            largestGapSize = gapSize;
                        isGap = false;
                        sectionStart = i;
                    }
                }

                if (maxIndex >= sectionStart)
                {
                    sectionStarts.Add(sectionStart);
                    sectionCounts.Add(maxIndex + 1 - sectionStart);
                }

                // not worth it for tiny gaps
                useSections = sectionStarts.Count() != 0 && largestGapSize > 2;

                // many small sections are not worth it either with UseBest
                if (useSections && fileDictionaryCompression == FileDictionaryCompression.UseBest &&
                    (largestGapSize < 10 || (sectionStarts.Count() > 4 && largestGapSize < 20)))
                    useSections = false;
            }

            bool anyFileExceedsSize = false;
            foreach (var size in fileSizes)
            {
                if (size > 0xffff)
                    anyFileExceedsSize = true;
            }
            bool useHalfEntrySize = !anyFileExceedsSize && fileDictionaryCompression != FileDictionaryCompression.UseSections;
            uint32 mask = !useHalfEntrySize ? (useSections ? 0x4000u : 0x0000u) : (useSections ? 0xc000u : 0x8000u);
            writer.WriteWord((uint16)(mask | (uint32)totalFileNumber));

            if (useSections)
            {
                writer.WriteWord((uint16)sectionStarts.Count());
                for (var s = 0; s < sectionStarts.Count(); s += 1)
                {
                    writer.WriteWord((uint16)sectionStarts[s]);
                    writer.WriteWord((uint16)sectionCounts[s]);
                    int index = (int)sectionStarts[s] - 1;
                    for (var i = 0; i < (int)sectionCounts[s]; i += 1)
                    {
                        if (!useHalfEntrySize)
                            writer.WriteDword((uint32)fileSizes[index]);
                        else
                            writer.WriteWord((uint16)fileSizes[index]);
                        index += 1;
                    }
                }
            }
            else
            {
                foreach (var size in fileSizes)
                {
                    if (!useHalfEntrySize)
                        writer.WriteDword((uint32)size);
                    else
                        writer.WriteWord((uint16)size);
                }
            }
        }
        else
        {
            writer.WriteWord((uint16)totalFileNumber);
            foreach (var size in fileSizes)
                writer.WriteDword((uint32)size);
        }

        writer.WriteBytes(writerWithoutHeader.AsSlice());
        return;
    }

    // an odd number of bytes gets a 0 byte at the end
    static uint8[] _AlignData(uint8[] data)
    {
        if (data.Length % 2 == 0)
            return data;
        var buffer = new uint8[data.Length + 1];
        Array.Copy(data, 0, buffer, 0, data.Length);
        return buffer;
    }

    static Dictionary<uint32, uint8[]> _FileData(FileContainer fileContainer)
    {
        var result = Dictionary<uint32, uint8[]>.Create();
        foreach (var entry in fileContainer.Files.Entries())
            result[(uint32)entry.Key] = entry.Value.ToArray();
        return result;
    }
}
