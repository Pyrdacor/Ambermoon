namespace CSharpToC
{
    [CExport]
    public class Console : ClassProxy<Console>
    {
        [CIgnore]
        internal Console()
        {

        }

        [CCode("printf(\"%s\\n\", text);")]
        public static void WriteLine(string text)
        {
            System.Console.WriteLine(text);
        }

        [CCode("printf(text);")]
        public static void Write(string text)
        {
            System.Console.Write(text);
        }
    }
}