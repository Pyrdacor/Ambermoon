namespace Ambermoon.Data.Legacy
{
    public class Text : IText
    {
        public Text(byte[] glyphIndices)
        {
            GlyphIndices = glyphIndices;
            int currentLineSize = 0;
            LineCount = 1;

            for (int i = 0; i < glyphIndices.Length; ++i)
            {
                if (glyphIndices[i] == (byte)'^')
                {
                    if (currentLineSize > MaxLineSize)
                        MaxLineSize = currentLineSize;

                    ++LineCount;
                }
            }
        }

        static byte[] CharactersToGlyphs(string text, bool rune)
        {
            byte[] glyphIndices = new byte[text.Length];

            for (int i = 0; i < text.Length; ++i)
            {
                char ch = text[i];

                if (ch >= 'a' && ch <= 'z')
                    glyphIndices[i] = (byte)(ch - 'a' + (rune ? 64 : 0));
                else if (ch >= 'A' && ch <= 'Z')
                    glyphIndices[i] = (byte)(ch - 'A' + (rune ? 64 : 0));
                else if (ch == 'ä' || ch == 'Ä')
                    glyphIndices[i] = (byte)(rune ? 90 : 26);
                else if (ch == 'ü' || ch == 'Ü')
                    glyphIndices[i] = (byte)(rune ? 91 : 27);
                else if (ch == 'ö' || ch == 'Ö')
                    glyphIndices[i] = (byte)(rune ? 92 : 28);
                else if (ch == 'ß')
                    glyphIndices[i] = (byte)(rune ? 93 : 29);
                else if (ch == ';')
                    glyphIndices[i] = 30;
                else if (ch == ':')
                    glyphIndices[i] = 31;
                else if (ch == ',')
                    glyphIndices[i] = 32;
                else if (ch == '.')
                    glyphIndices[i] = 33;
                else if (ch == '\'' || ch == '´' || ch == '`')
                    glyphIndices[i] = 34;
                else if (ch == '"')
                    glyphIndices[i] = 35;
                else if (ch == '!')
                    glyphIndices[i] = 36;
                else if (ch == '?')
                    glyphIndices[i] = 37;
                else if (ch == '*')
                    glyphIndices[i] = 38;
                else if (ch == '_')
                    glyphIndices[i] = 39;
                else if (ch == '(')
                    glyphIndices[i] = 40;
                else if (ch == ')')
                    glyphIndices[i] = 41;
                else if (ch == '%')
                    glyphIndices[i] = 42;
                else if (ch == '/')
                    glyphIndices[i] = 43;
                else if (ch == '#')
                    glyphIndices[i] = 44;
                else if (ch == '-')
                    glyphIndices[i] = 45;
                else if (ch == '+')
                    glyphIndices[i] = 46;
                else if (ch == '=')
                    glyphIndices[i] = 47;
                else if (ch >= '0' && ch <= '9')
                    glyphIndices[i] = (byte)(ch - '0' + 48);
                else if (ch == '&')
                    glyphIndices[i] = 58;
                else if (ch == 'á' || ch == 'à' || ch == 'â' || ch == 'Á' || ch == 'À' || ch == 'Â')
                    glyphIndices[i] = 59;
                else if (ch == 'é' || ch == 'è' || ch == 'ê' || ch == 'É' || ch == 'È' || ch == 'Ê')
                    glyphIndices[i] = 60;
                else if (ch == '¢')
                    glyphIndices[i] = 61;
                else if (ch == 'û' || ch == 'Û')
                    glyphIndices[i] = 62;
                else if (ch == 'ô' || ch == 'Ô')
                    glyphIndices[i] = 63;
                else
                    throw new AmbermoonException(ExceptionScope.Data, $"Unsupported text character '{text[i]}' in text \"{text}\".");
            }

            return glyphIndices;
        }

        /// <summary>
        /// Convert text to glyph indices.
        /// </summary>
        /// <param name="text">Text</param>
        /// <param name="rune">Use rune encoding</param>
        public Text(string text, bool rune = false)
            : this(CharactersToGlyphs(text, rune))
        {

        }

        public byte[] GlyphIndices { get; }
        public int LineCount { get; }
        public int MaxLineSize { get; }
    }
}
