using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace AmbermoonPatcher
{
    class Parser
    {
        public static List<IAction> Run(List<TokenLine> tokenLines)
        {
            var actions = new List<IAction>(tokenLines.Count);

            foreach (var tokenLine in tokenLines)
            {
                // Remove all whitespace tokens
                for (int i = tokenLine.Tokens.Count - 1; i >= 0; --i)
                {
                    if (tokenLine.Tokens[i].Type == TokenType.Whitespace)
                        tokenLine.Tokens.RemoveAt(i);
                }

                if (tokenLine.Tokens.Count == 0)
                    continue;

                var first = tokenLine.Tokens.First();

                switch (first.Type)
                {
                    case TokenType.FixDescription:
                        actions.Add(new PrintAction($"Applying fix '{first.Value.Substring(1).Trim()}'"));
                        break;
                    case TokenType.BlockComment:
                    case TokenType.LineComment:
                        // Do nothing
                        break;
                    case TokenType.Enumeration:
                    {
                        actions.Add(ParseAction(tokenLine, tokenLine.Tokens.IndexOf(first) + 1));
                        break;
                    }
                    default:
                        throw new FormatException($"Error (at {tokenLine.LineNumber},{first.CharacterIndex}): Unexpected token {first.Type}");
                }
            }

            return actions;
        }

        static IAction ParseAction(TokenLine tokenLine, int tokenIndex)
        {
            if (tokenIndex >= tokenLine.Tokens.Count)
                throw new FormatException($"Error (at {tokenLine.LineNumber}): No command given");

            var commandToken = tokenLine.Tokens[tokenIndex];

            if (commandToken.Type != TokenType.String)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{commandToken.CharacterIndex}): Expected command but found token '{commandToken.Type}'");

            string command = commandToken.Value.ToLower();

            void VerifyRemainingTokensEmpty(int tokenIndex)
            {
                var invalidToken = tokenLine.Tokens.Skip(tokenIndex)
                    .FirstOrDefault(token =>
                        token.Type != TokenType.BlockComment &&
                        token.Type != TokenType.LineComment);

                if (invalidToken != null)
                    throw new FormatException($"Error (at {tokenLine.LineNumber},{invalidToken.CharacterIndex}): Unexpected token");
            }

            ++tokenIndex;

            if (command == "r" || command == "rep" || command == "replace")
            {
                var replaceAction = new ReplaceAction(ParseDestination(tokenLine, ref tokenIndex), ParseRValue(tokenLine, ref tokenIndex));
                VerifyRemainingTokensEmpty(tokenIndex);
                return replaceAction;
            }
            else if (command == "i" || command == "ins" || command == "insert")
            {
                var insertAction = new InsertAction(ParseDestination(tokenLine, ref tokenIndex), ParseRValue(tokenLine, ref tokenIndex));
                VerifyRemainingTokensEmpty(tokenIndex);
                return insertAction;
            }
            else if (command == "d" || command == "del" || command == "delete")
            {
                var deleteAction = new DeleteAction(ParseDestination(tokenLine, ref tokenIndex), ParseInteger(tokenLine, tokenIndex++));
                VerifyRemainingTokensEmpty(tokenIndex);
                return deleteAction;
            }
            else
            {
                throw new FormatException($"Error (at {tokenLine.LineNumber},{commandToken.CharacterIndex}): Unknown command '{commandToken.Value}'");
            }
        }

        static Destination ParseDestination(TokenLine tokenLine, ref int tokenIndex)
        {
            var tokens = tokenLine.Tokens.Skip(tokenIndex).ToList();

            if (tokens.Count == 0)
                throw new FormatException($"Error (at {tokenLine.LineNumber}): Missing destination argument");

            if (tokens[0].Type != TokenType.String)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Expected filename argument but found token '{tokens[0].Type}'");

            string filename = tokens[0].Value;

            if (tokens.Count == 1)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Destination with filename '{filename}' has no offset");

            int subFileIndex = 1;
            int index = 1;

            if (tokens[1].Type == TokenType.Index)
            {
                subFileIndex = int.Parse(tokens[1].Value);
                ++index;
            }

            if (tokens.Count <= index + 2)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Destination with filename '{filename}' has no valid offset");

            if (tokens[index].Type != TokenType.Colon)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index].CharacterIndex}): Missing colon in destination");

            if (tokens[index + 1].Type != TokenType.Integer)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index + 1].CharacterIndex}): Expected offset as integer but found token '{tokens[index + 1].Type}'");

            int offset = int.Parse(tokens[index + 1].Value, NumberStyles.AllowHexSpecifier);
            index += 2;
            tokenIndex += index;            

            return new Destination
            {
                File = filename,
                Offset = offset,
                SubFileIndex = subFileIndex
            };
        }

        static RValue ParseRValue(TokenLine tokenLine, ref int tokenIndex)
        {
            var tokens = tokenLine.Tokens.Skip(tokenIndex).ToList();

            if (tokens.Count == 0)
                throw new FormatException($"Error (at {tokenLine.LineNumber}): Missing r-value argument (source, integer or byte sequence)");

            static byte[] BytesFromString(string byteSequenceString)
            {
                var bytes = byteSequenceString.Split(' ');
                return bytes.Select(b => byte.Parse(b, NumberStyles.AllowHexSpecifier)).ToArray();
            }

            switch (tokens[0].Type)
            {
                case TokenType.ByteSequence:
                    ++tokenIndex;
                    var bytes = BytesFromString(tokens[0].Value);
                    return new RValue { Bytes = bytes, Length = bytes.Length };
                case TokenType.Integer:
                {
                    long value = long.Parse(tokens[0].Value, NumberStyles.AllowHexSpecifier);
                    ++tokenIndex;
                    int length = (tokens[0].Value.Length + 1) / 2;
                    if (tokens.Count > 1 && tokens[1].Type == TokenType.Comma)
                    {
                        if (tokens.Count == 2)
                            throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[1].CharacterIndex}): Comma found without a length value");

                        if (tokens[2].Type != TokenType.Integer)
                            throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[2].CharacterIndex}): Expected length value but found token '{tokens[2].Type}'");

                        length = (int)Math.Min(int.MaxValue, long.Parse(tokens[2].Value, NumberStyles.AllowHexSpecifier));

                        if (length == int.MaxValue)
                            throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[2].CharacterIndex}): Invalid length value given");

                        tokenIndex += 2;
                    }
                    return new RValue { Value = long.Parse(tokens[0].Value), Length = length };
                }
                case TokenType.String:
                    var source = ParseSource(tokenLine, ref tokenIndex);
                    return new RValue { Source = source, Length = source.Length };
                default:
                    throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Expected r-value but found token '{tokens[0].Type}'");
            }
        }

        static Source ParseSource(TokenLine tokenLine, ref int tokenIndex)
        {
            var tokens = tokenLine.Tokens.Skip(tokenIndex).ToList();

            if (tokens.Count == 0)
                throw new FormatException($"Error (at {tokenLine.LineNumber}): Missing source argument");

            if (tokens[0].Type != TokenType.String)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Expected filename argument but found token '{tokens[0].Type}'");

            string filename = tokens[0].Value;

            if (tokens.Count == 1)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Source with filename '{filename}' has no offset");

            int subFileIndex = 1;
            int index = 1;

            if (tokens[1].Type == TokenType.Index)
            {
                subFileIndex = int.Parse(tokens[1].Value);
                ++index;
            }

            if (tokens.Count <= index + 4)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[0].CharacterIndex}): Source with filename '{filename}' has no valid offset and length");

            if (tokens[index].Type != TokenType.Colon)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index].CharacterIndex}): Missing colon in source");

            if (tokens[index + 1].Type != TokenType.Integer)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index + 1].CharacterIndex}): Expected offset as integer but found token '{tokens[index + 1].Type}'");

            if (tokens[index + 2].Type != TokenType.Comma)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index + 2].CharacterIndex}): Missing comma in source");

            if (tokens[index + 3].Type != TokenType.Integer)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{tokens[index + 3].CharacterIndex}): Expected length as integer but found token '{tokens[index + 3].Type}'");

            int offset = int.Parse(tokens[index + 1].Value, NumberStyles.AllowHexSpecifier);
            int length = int.Parse(tokens[index + 3].Value, NumberStyles.AllowHexSpecifier);
            index += 4;
            tokenIndex += index;

            return new Source
            {
                File = filename,
                Offset = offset,
                SubFileIndex = subFileIndex,
                Length = length
            };
        }

        static int ParseInteger(TokenLine tokenLine, int tokenIndex)
        {
            var integerToken = tokenLine.Tokens.Skip(tokenIndex).FirstOrDefault();

            if (integerToken == null)
                throw new FormatException($"Error (at {tokenLine.LineNumber}): Missing integer argument");

            if (integerToken.Type != TokenType.Integer)
                throw new FormatException($"Error (at {tokenLine.LineNumber},{integerToken.CharacterIndex}): Expected integer argument but found token '{integerToken.Type}'");

            return int.Parse(integerToken.Value);
        }

        class Destination
        {
            public string File { get; set; }
            public int SubFileIndex { get; set; }
            public int Offset { get; set; }
        }

        class Source
        {
            public string File { get; set; }
            public int SubFileIndex { get; set; }
            public int Offset { get; set; }
            public int Length { get; set; }
        }

        class RValue
        {
            public Source Source { get; set; }
            public long? Value { get; set; }
            public byte[] Bytes { get; set; }
            public int Length { get; set; }
        }

        static byte[] GetRValueData(RValue rValue, FileManager fileManager)
        {
            if (rValue.Source != null)
            {
                var source = rValue.Source;
                var data = fileManager.GetFileData(source.File, source.SubFileIndex);

                if (source.Offset < 0 || source.Offset + source.Length > data.Length)
                    throw new Exception($"Source data offset and length are outside the subfile boundaries of '{source.File}[{source.SubFileIndex}]'");

                return data.Skip(source.Offset).Take(source.Length).ToArray();
            }
            else if (rValue.Bytes != null)
            {
                return rValue.Bytes;
            }
            else if (rValue.Value != null)
            {
                if (rValue.Length == 1)
                    return new byte[] { (byte)(rValue.Value & 0xff) };
                else if (rValue.Length == 2)
                    return new byte[] { (byte)((rValue.Value >> 8) & 0xff), (byte)(rValue.Value & 0xff) };
                else if (rValue.Length == 4)
                    return new byte[] { (byte)((rValue.Value >> 24) & 0xff), (byte)((rValue.Value >> 16) & 0xff), (byte)((rValue.Value >> 8) & 0xff), (byte)(rValue.Value & 0xff) };
                else
                    throw new Exception("Invalid source value length");
            }
            else
                throw new Exception("Invalid source R-value data");
        }

        class PrintAction : IAction
        {
            readonly string text;

            internal PrintAction(string text)
            {
                this.text = text;
            }

            public void Run(FileManager _)
            {
                Console.WriteLine(text);
            }
        }

        class ReplaceAction : IAction
        {
            readonly Destination destination;
            readonly RValue rValue;

            internal ReplaceAction(Destination destination, RValue rValue)
            {
                this.destination = destination;
                this.rValue = rValue;
            }

            public void Run(FileManager fileManager)
            {
                Console.Write($"- Replacing {rValue.Length} bytes in '{destination.File}[{destination.SubFileIndex}]' at offset 0x{destination.Offset:x4} ... ");

                try
                {
                    var data = fileManager.GetFileData(destination.File, destination.SubFileIndex);

                    if (data == null)
                        throw new Exception($"File '{destination.File}' is not present in game data.");

                    if (destination.Offset < 0 || destination.Offset + rValue.Length > data.Length)
                        throw new Exception($"Tried to replace more bytes than the size of '{destination.File}[{destination.SubFileIndex}]'.");

                    var rValueData = GetRValueData(rValue, fileManager);

                    for (int i = 0; i < rValue.Length; ++i)
                        data[destination.Offset + i] = rValueData[i];

                    fileManager.SetFileData(destination.File, destination.SubFileIndex, data);

                    Console.WriteLine("done");
                }
                catch
                {
                    Console.WriteLine("failed");
                    throw;
                }
            }
        }

        class InsertAction : IAction
        {
            readonly Destination destination;
            readonly RValue rValue;

            internal InsertAction(Destination destination, RValue rValue)
            {
                this.destination = destination;
                this.rValue = rValue;
            }

            public void Run(FileManager fileManager)
            {
                Console.Write($"- Inserting {rValue.Length} bytes in '{destination.File}[{destination.SubFileIndex}]' at offset 0x{destination.Offset:x4} ... ");

                try
                {
                    var data = fileManager.GetFileData(destination.File, destination.SubFileIndex);

                    if (data == null)
                        throw new Exception($"File '{destination.File}' is not present in game data.");

                    if (destination.Offset < 0 || destination.Offset > data.Length)
                        throw new Exception($"Tried to insert outside of '{destination.File}[{destination.SubFileIndex}]'.");

                    var rValueData = GetRValueData(rValue, fileManager);
                    var bytes = new List<byte>(data);

                    for (int i = 0; i < rValue.Length; ++i)
                        bytes.Insert(destination.Offset + i, rValueData[i]);

                    fileManager.SetFileData(destination.File, destination.SubFileIndex, bytes.ToArray());

                    Console.WriteLine("done");
                }
                catch
                {
                    Console.WriteLine("failed");
                    throw;
                }
            }
        }

        class DeleteAction : IAction
        {
            readonly Destination destination;
            readonly int length;

            internal DeleteAction(Destination destination, int length)
            {
                this.destination = destination;
                this.length = length;
            }

            public void Run(FileManager fileManager)
            {
                Console.Write($"- Deleting {length} bytes in '{destination.File}[{destination.SubFileIndex}]' at offset 0x{destination.Offset:x4} ... ");

                try
                {
                    var data = fileManager.GetFileData(destination.File, destination.SubFileIndex);

                    if (data == null)
                        throw new Exception($"File '{destination.File}' is not present in game data.");

                    if (destination.Offset < 0 || destination.Offset + length > data.Length)
                        throw new Exception($"Tried to delete outside of '{destination.File}[{destination.SubFileIndex}]'.");

                    byte[] result = new byte[data.Length - length];

                    if (result.Length != 0)
                    {
                        if (destination.Offset > 0)
                            Array.Copy(data, result, destination.Offset);
                        if (destination.Offset + length < data.Length)
                            Array.Copy(data, destination.Offset + length, result, destination.Offset, data.Length - (destination.Offset + length));
                    }

                    fileManager.SetFileData(destination.File, destination.SubFileIndex, result);

                    Console.WriteLine("done");
                }
                catch
                {
                    Console.WriteLine("failed");
                    throw;
                }
            }
        }
    }
}
