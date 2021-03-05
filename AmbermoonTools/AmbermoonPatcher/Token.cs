using System.Collections.Generic;

namespace AmbermoonPatcher
{
    enum TokenType
    {
        FixDescription,
        Whitespace,
        Enumeration,
        String,
        Integer,
        ByteSequence,
        Colon,
        Comma,
        Index,
        LineComment,
        BlockComment,
        Error
    }

    class Token
    {
        public TokenType Type { get; set; }
        public string Value { get; set; }
        public int CharacterIndex { get; set; }
    }

    class TokenLine
    {
        public List<Token> Tokens { get; } = new List<Token>();
        public int LineNumber { get; set; }
    }
}
