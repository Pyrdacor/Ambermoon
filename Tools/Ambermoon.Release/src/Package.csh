namespace Ambermoon.Release;

using System;
using Ambermoon;
using Amiga.FileFormats.LHA;

/// The current local time, or the time of `SOURCE_DATE_EPOCH` (seconds since 1970-01-01 UTC) when it is set, so that
/// releases can be made again with the same times (in the texts, the ADF images and the archive headers).
DateTime ReleaseNow()
{
    if (Process.GetEnv("SOURCE_DATE_EPOCH") is string text && ParseLong(text) is int64 seconds)
        return DateTime.FromUnixSeconds(seconds).ToLocalTime();
    return DateTime.Now();
}

/// The archives of a release (`Package` of the release creators): zip, tar.gz and LHA files of a folder, an existing
/// archive is replaced.
struct Package
{
    /// A zip file of the folder ([CreateZip]; `net9`: the header flags of .NET 9).
    static Error<void> CreateZip(StringSlice sourceDirectory, StringSlice outputFilePath, bool net9)
    {
        _DeleteIfExists(outputFilePath);
        return Ambermoon.Release.CreateZip(sourceDirectory, outputFilePath, net9);
    }

    /// A tar.gz file of the files of the folder ([CreateTarball]); the names are relative to `workingDirectory`.
    static Error<void> CreateTarball(StringSlice sourceDirectory, StringSlice outputFilePath, StringSlice workingDirectory)
    {
        _DeleteIfExists(outputFilePath);
        return Ambermoon.Release.CreateTarball(sourceDirectory, outputFilePath, workingDirectory, ReleaseNow());
    }

    /// An LHA archive of the files of the folder (LH5).
    static Error<void> CreateLha(StringSlice sourceDirectory, StringSlice outputFilePath)
    {
        _DeleteIfExists(outputFilePath);
        var result = WriteLhaFile(outputFilePath, sourceDirectory, CompressionMethod.LH5);
        if (result != LHAWriteResult.Success)
            return error("Failed to create LHA archive at " + outputFilePath + ": " + _LhaResultName(result));
        return;
    }

    static void _DeleteIfExists(StringSlice path)
    {
        if (IsFile(path))
            File.Delete(path);
    }

    static string _LhaResultName(LHAWriteResult result)
    {
        switch (result)
        {
            case LHAWriteResult.DiskFullError: return "DiskFullError";
            case LHAWriteResult.WriteAccessError: return "WriteAccessError";
            case LHAWriteResult.UnsupportedCompressionMethod: return "UnsupportedCompressionMethod";
            default: return "InvalidLHAObject";
        }
    }
}
