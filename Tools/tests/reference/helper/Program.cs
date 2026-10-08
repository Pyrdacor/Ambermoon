using Ambermoon.Data.Legacy.Serialization;
using System.Text;
// helper <exe in> <out>: the executable (container file 1) with its last data hunk replaced by 12 zero bytes (or 8: arg 3)
// helper --cp <codepage>: dumps the code page: name lines, decode table, encode table
// helper --names <name>...: the code pages of encoding names
if (args[0] == "--names")
{
    Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
    foreach (var name in args.Skip(1))
    {
        try { var e = Encoding.GetEncoding(name); Console.WriteLine($"{name} -> {e.CodePage} {e.WebName}|{e.EncodingName}"); }
        catch (Exception ex) { Console.WriteLine($"{name} -> error {ex.GetType().Name}"); }
    }
    return;
}
if (args[0] == "--cp")
{
    Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);
    var enc = Encoding.GetEncoding(int.Parse(args[1]));
    Console.WriteLine($"name {enc.WebName}|{enc.EncodingName}|{enc.CodePage}|{enc.IsSingleByte}|{enc.EncoderFallback.GetType().Name}");
    for (int b = 0; b < 256; b++) { var c = enc.GetChars(new[] { (byte)b }); Console.WriteLine($"d {b:X2} {(int)c[0]:X4}"); }
    for (int c = 0; c <= 0xFFFF; c++)
    {
        if (c >= 0xD800 && c <= 0xDFFF) continue;
        var bytes = enc.GetBytes(new[] { (char)c });
        if (bytes.Length != 1) { Console.WriteLine($"L {c:X4} {bytes.Length}"); continue; }
        if (bytes[0] != (byte)'?' || c == '?') Console.WriteLine($"e {c:X4} {bytes[0]:X2}");
    }
    return;
}
var data = File.ReadAllBytes(args[0]);
var container = new FileReader().ReadFile("", new DataReader(data));
var hunks = AmigaExecutable.Read(container.Files[1]);
int last = hunks.FindLastIndex(h => h.Type == AmigaExecutable.HunkType.Data);
Console.WriteLine($"hunks {hunks.Count}, last data {last}, size {hunks[last].Size * 4}");
int size = args.Length > 2 ? int.Parse(args[2]) : 12;
hunks[last] = new AmigaExecutable.Hunk(AmigaExecutable.HunkType.Data, hunks[last].MemoryFlags, new byte[size]);
var w = new DataWriter();
AmigaExecutable.Write(w, hunks);
File.WriteAllBytes(args[1], w.ToArray());
