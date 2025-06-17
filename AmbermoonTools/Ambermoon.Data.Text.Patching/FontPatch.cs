using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using static Ambermoon.Data.Legacy.Serialization.AmigaExecutable;

namespace Ambermoon.Data.Text.Patching;

public static partial class Patch
{
    private static void AlignToLongBoundary(IDataWriter dataWriter)
    {
        while (dataWriter.Position % 4 != 0)
            dataWriter.Write((byte)0); // Align to long boundary
    }

    private static void Font(IDataReader executableData, Func<byte[]> fontDataProvider, int expectedHeaderSize, IDataWriter output)
    {
        var hunks = Read(executableData);
        var fontHunk = hunks.Where(h => h.Type == HunkType.Data).LastOrDefault();

        if (fontHunk == null)
        {
            throw new AmbermoonException(ExceptionScope.Data, "Font patching failed: No font data hunk found in the executable.");
        }

        if (fontHunk.Size * 4 != expectedHeaderSize)
        {
            throw new AmbermoonException(ExceptionScope.Data, $"Unexpected font hunk size: {fontHunk.Size * 4}. Expected: {expectedHeaderSize}.");
        }

        int fontHunkIndex = hunks.IndexOf(fontHunk);

        hunks[fontHunkIndex] = new Hunk(HunkType.Data, fontHunk.MemoryFlags, fontDataProvider());

        Write(output, hunks);
    }

    private static void Font(List<IHunk> hunks, Func<byte[]> fontDataProvider, int expectedHeaderSize)
    {
        var fontHunk = hunks.Where(h => h.Type == HunkType.Data).LastOrDefault();

        if (fontHunk == null)
        {
            throw new AmbermoonException(ExceptionScope.Data, "Font patching failed: No font data hunk found in the executable.");
        }

        if (fontHunk.Size * 4 != expectedHeaderSize)
        {
            throw new AmbermoonException(ExceptionScope.Data, $"Unexpected font hunk size: {fontHunk.Size * 4}. Expected: {expectedHeaderSize}.");
        }

        int fontHunkIndex = hunks.IndexOf(fontHunk);

        hunks[fontHunkIndex] = new Hunk(HunkType.Data, fontHunk.MemoryFlags, fontDataProvider());
    }

    private static byte[] FontsProvider(Fonts fonts)
    {
        var fontData = new DataWriter();
        fonts.Write(fontData);
        AlignToLongBoundary(fontData);
        return fontData.ToArray();
    }

    private static byte[] FontProvider(Font font)
    {
        var fontData = new DataWriter();
        font.Write(fontData);
        AlignToLongBoundary(fontData);
        return fontData.ToArray();
    }

    public static void Font(IDataReader executableData, Fonts fonts, IDataWriter output)
    {
        Font(executableData, () => FontsProvider(fonts), 12, output);
    }

    public static void Font(IDataReader executableData, Font font, IDataWriter output)
    {
        Font(executableData, () => FontProvider(font), 8, output);
    }

    public static void Font(List<IHunk> hunks, Fonts fonts)
    {
        Font(hunks, () => FontsProvider(fonts), 12);
    }

    public static void Font(List<IHunk> hunks, Font font)
    {
        Font(hunks, () => FontProvider(font), 8);
    }
}
