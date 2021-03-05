using System;
using System.Collections.Generic;
using System.Globalization;

namespace AmbermoonPatcher
{
    static class Lexer
    {
        public static List<TokenLine> Run(string[] lines)
        {
            int lineNumber = 1;
            Token currentBlockCommentToken = null;
            var output = new List<TokenLine>(lines.Length);

            Token ParseNextToken(string line, ref int offset)
            {
                if (offset >= line.Length)
                    return null;

                var input = line.Substring(offset);
                int characterIndex = offset;
                Token CreateToken(TokenType type, string value = null) => new Token { CharacterIndex = characterIndex, Type = type, Value = value };

                if (currentBlockCommentToken != null)
                {
                    if (input.StartsWith("*/"))
                    {
                        if (!string.IsNullOrWhiteSpace(input.Substring(2)))
                            return CreateToken(TokenType.Error, "Block comments must end at the end of a line");

                        currentBlockCommentToken = null;
                        offset += 2;
                        return ParseNextToken(line, ref offset);
                    }
                    else
                    {
                        int nextPossibleCloseTokenIndex = input.IndexOf('*', 1);

                        if (nextPossibleCloseTokenIndex == -1)
                        {
                            currentBlockCommentToken.Value += input;
                            return null;
                        }
                        else
                        {
                            currentBlockCommentToken.Value += input.Substring(0, nextPossibleCloseTokenIndex);
                            offset += nextPossibleCloseTokenIndex;
                            return ParseNextToken(line, ref offset);
                        }
                    }
                }
                else
                {
                    bool IsHexDigit(char ch) => char.IsDigit(ch) || (ch >= 'a' && ch <= 'f');
                    int NextCommentIndex() => input.IndexOf("//");
                    string ValueToEndOfLine(ref int offset)
                    {
                        int nextCommentIndex = NextCommentIndex();

                        if (nextCommentIndex == -1)
                        {
                            offset = line.Length;
                            return input;
                        }
                        else
                        {
                            offset += nextCommentIndex;
                            return input.Substring(0, nextCommentIndex);
                        }
                    }

                    switch (input[0])
                    {
                        case '#':
                            return CreateToken(TokenType.FixDescription, ValueToEndOfLine(ref offset));
                        case ' ':
                        case '\t':
                            ++offset;
                            return CreateToken(TokenType.Whitespace, input[0].ToString());
                        case '-':
                            ++offset;
                            return CreateToken(TokenType.Enumeration);
                        case ':':
                            ++offset;
                            return CreateToken(TokenType.Colon);
                        case ',':
                            ++offset;
                            return CreateToken(TokenType.Comma);
                        case '\'':
                        {
                            int closeIndex = input.IndexOf('\'', 1);

                            if (closeIndex == -1)
                                return CreateToken(TokenType.Error, "Byte sequence was not closed with a single quote");

                            int nextCommentIndex = NextCommentIndex();

                            if (nextCommentIndex != -1 && nextCommentIndex < closeIndex)
                                return CreateToken(TokenType.Error, "Byte sequence was not closed with a single quote (there is a single quote inside a line comment though)");

                            string sequence = input.Substring(1, closeIndex - 1).ToLower();

                            if (sequence.Length < 2)
                                return CreateToken(TokenType.Error, $"Invalid byte sequence '{sequence}'");

                            int index = 0;

                            while (true)
                            {
                                if (!IsHexDigit(sequence[index]) || !IsHexDigit(sequence[index + 1]))
                                    return CreateToken(TokenType.Error, $"Invalid byte sequence '{sequence}'");

                                index += 2;

                                if (index == sequence.Length)
                                    break;

                                if (sequence[index++] != ' ' || sequence.Length - index < 2)
                                    return CreateToken(TokenType.Error, $"Invalid byte sequence '{sequence}'");
                            }

                            offset += closeIndex + 1;

                            return CreateToken(TokenType.ByteSequence, sequence);
                        }
                        case ']':
                            return CreateToken(TokenType.Error, "Closing index found without associated open index '['");
                        case '[':
                        {
                            int closeIndex = input.IndexOf(']');

                            if (closeIndex == -1)
                                return CreateToken(TokenType.Error, "Index was not closed with ']'");

                            int nextCommentIndex = NextCommentIndex();

                            if (nextCommentIndex != -1 && nextCommentIndex < closeIndex)
                                return CreateToken(TokenType.Error, "Index was not closed with ']' (there is a closing index inside a line comment though)");

                            string index = input.Substring(1, closeIndex - 1);

                            if (index.Trim().Length == 0)
                                return CreateToken(TokenType.Error, "Empty index '[]' found");

                            if (index.Contains('['))
                                return CreateToken(TokenType.Error, "Double opened index found");

                            long? indexValue = null;

                            if (index.StartsWith("0x"))
                            {
                                if (long.TryParse(index.Substring(2), NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out var value))
                                    indexValue = value;
                            }
                            else if (index.StartsWith("$"))
                            {
                                if (long.TryParse(index.Substring(1), NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out var value))
                                    indexValue = value;
                            }
                            else
                            {
                                if (long.TryParse(index, NumberStyles.None, CultureInfo.InvariantCulture, out var value))
                                    indexValue = value;
                            }

                            if (indexValue == null)
                                return CreateToken(TokenType.Error, $"Invalid index value: [{index}]");

                            if (indexValue < 0 || indexValue > ushort.MaxValue)
                                return CreateToken(TokenType.Error, $"Index value must be in the range 0..65535 but was {indexValue}");

                            offset += closeIndex + 1;

                            return CreateToken(TokenType.Index, indexValue.ToString());
                        }
                        default:
                        {
                            if (input.StartsWith("0x") || input.StartsWith("$"))
                            {
                                int headerLength = input.StartsWith("$") ? 1 : 2;

                                if (input.Length == headerLength)
                                    return CreateToken(TokenType.Error, "Incomplete hex literal: " + input.Substring(0, headerLength));

                                string value = input.Substring(headerLength).ToLower();

                                if (!IsHexDigit(value[0]))
                                    return CreateToken(TokenType.Error, "Invalid hex literal: " + input.Substring(0, headerLength + 1));

                                int length = 1;

                                while (length < value.Length && IsHexDigit(value[length]))
                                    ++length;

                                offset += headerLength + length;

                                // Note: When hex is given the number of bytes is determined by the digits.
                                // To keep this information we will store it as hex as well.
                                return CreateToken(TokenType.Integer, input.Substring(headerLength, length));
                            }
                            else if (char.IsDigit(input[0]))
                            {
                                int length = 1;

                                while (length < input.Length && char.IsDigit(input[length]))
                                    ++length;

                                offset += length;

                                // Note: When dec is given the number of bytes is determined by the smallest
                                // number of bytes (limited to 1, 2 or 4) this value can be stored.
                                // Negative values are not possible at all.
                                long value = long.Parse(input.Substring(0, length));
                                string storeValue = null;
                                if (value <= 0xff)
                                    storeValue = value.ToString("x1");
                                else if (value <= 0xffff)
                                    storeValue = value.ToString("x2");
                                else if (value <= 0xffffffff)
                                    storeValue = value.ToString("x4");
                                else
                                    return CreateToken(TokenType.Error, "Integer value was out of range. Must be in the range 0..0xffffffff.");

                                return CreateToken(TokenType.Integer, storeValue);
                            }
                            else if (input.StartsWith("/*"))
                            {
                                if (offset != 0 && !string.IsNullOrWhiteSpace(line.Substring(0, offset)))
                                    return CreateToken(TokenType.Error, "Block comments must start at the beginning of a line");

                                int closingCommentIndex = input.IndexOf("*/");

                                if (closingCommentIndex == -1)
                                {
                                    offset = line.Length;
                                    currentBlockCommentToken = CreateToken(TokenType.BlockComment, input.Substring(2).TrimStart() + Environment.NewLine);
                                    return currentBlockCommentToken;
                                }
                                else // block comment ends on line
                                {
                                    if (!string.IsNullOrWhiteSpace(input.Substring(closingCommentIndex + 2)))
                                        return CreateToken(TokenType.Error, "Block comments must end at the end of a line");

                                    offset += closingCommentIndex + 2;
                                    return CreateToken(TokenType.BlockComment, input.Substring(2, closingCommentIndex - 2).Trim());
                                }
                            }
                            else if (input.StartsWith("*/"))
                            {
                                return CreateToken(TokenType.Error, "Block comment end found without associated block comment start");
                            }
                            else if (input.StartsWith("//"))
                            {
                                offset = line.Length;
                                return CreateToken(TokenType.LineComment, input.Substring(2));
                            }
                            else // string
                            {
                                bool isStringChar(char ch) => ch == '_' || ch == '.' || char.IsLetter(ch);
                                string value = "";

                                while (isStringChar(line[offset]))
                                {
                                    value += line[offset++];
                                }

                                if (value.Length == 0)
                                    return CreateToken(TokenType.Error, "Unknown token");

                                return CreateToken(TokenType.String, value);
                            }
                        }
                    }
                }
            }

            foreach (var line in lines)
            {
                if (line.Trim().Length == 0) // Empty line
                {
                    if (currentBlockCommentToken != null)
                        currentBlockCommentToken.Value += line + Environment.NewLine;

                    ++lineNumber;
                    continue;
                }

                int offset = 0;
                TokenLine tokenLine = new TokenLine { LineNumber = lineNumber };
                Token token;

                while ((token = ParseNextToken(line, ref offset)) != null)
                {
                    if (token.Type == TokenType.Error)
                        throw new FormatException($"Error (at {lineNumber},{token.CharacterIndex}): {token.Value}");

                    tokenLine.Tokens.Add(token);
                }

                output.Add(tokenLine);
                ++lineNumber;
            }

            return output;
        }
    }
}
