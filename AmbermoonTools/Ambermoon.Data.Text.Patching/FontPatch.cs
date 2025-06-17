using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using static Ambermoon.Data.Legacy.Serialization.AmigaExecutable;

namespace Ambermoon.Data.Text.Patching;

public static partial class Patch
{
    private static void Font(IDataReader executableData, Func<byte[]> fontDataProvider, int expectedHeaderSize, IDataWriter output)
    {
        var hunks = Read(executableData);
        var fontHunk = hunks.Where(h => h.Type == HunkType.Data).LastOrDefault();

        if (fontHunk == null)
        {
            throw new AmbermoonException(ExceptionScope.Data, "Font patching failed: No font data hunk found in the executable.");
        }

        if (fontHunk.Size != expectedHeaderSize)
        {
            throw new AmbermoonException(ExceptionScope.Data, $"Unexpected font hunk size: {fontHunk.Size}. Expected: {expectedHeaderSize}.");
        }

        int fontHunkIndex = hunks.IndexOf(fontHunk);

        hunks[fontHunkIndex] = new Hunk(HunkType.Data, fontHunk.MemoryFlags, fontDataProvider());

        Write(output, hunks);
    }

    public static void Font(IDataReader executableData, Fonts fonts, IDataWriter output)
    {
        Font(executableData,
            () =>
            {
                var fontData = new DataWriter();
                fonts.Write(fontData);
                return fontData.ToArray();
            },
            12,
            output);
    }

    public static void Font(IDataReader executableData, Font font, IDataWriter output)
    {
        Font(executableData,
            () =>
            {
                var fontData = new DataWriter();
                font.Write(fontData);
                return fontData.ToArray();
            },
            8,
            output);
    }
}
