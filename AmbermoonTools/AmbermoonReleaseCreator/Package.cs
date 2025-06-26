using System.IO.Compression;
using Amiga.FileFormats.LHA;
using ICSharpCode.SharpZipLib.GZip;
using ICSharpCode.SharpZipLib.Tar;

namespace AmbermoonReleaseCreator;

internal static class Package
{
    public static void CreateZip(string sourceDirectory, string outputFilePath)
    {
        ZipFile.CreateFromDirectory(sourceDirectory, outputFilePath, CompressionLevel.SmallestSize, false);
    }

    public static void CreateTarball(string sourceDirectory, string outputFilePath)
    {
        using var outStream = File.Create(outputFilePath);
        using var gzipStream = new GZipOutputStream(outStream);
        using var tarArchive = TarArchive.CreateOutputTarArchive(gzipStream);

        foreach (string file in Directory.GetFiles(sourceDirectory, "*", SearchOption.AllDirectories))
        {
            var entry = TarEntry.CreateEntryFromFile(file);
            tarArchive.WriteEntry(entry, true);
        }
    }

    public static void CreateLha(string sourceDirectory, string outputFilePath)
    {
        var result = LHAWriter.WriteLHAFile(outputFilePath, sourceDirectory);

        if (result != LHAWriteResult.Success)
        {
            throw new IOException($"Failed to create LHA archive at {outputFilePath}: {result}");
        }
    }
}
