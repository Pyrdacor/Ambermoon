using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using static Ambermoon.Data.Legacy.Compression.LobCompression;

namespace AmbermoonPack
{
    class Program
    {
        const int ERROR_INVALID_USAGE = 1;
        const int ERROR_INVALID_TYPE = 2;
        const int ERROR_SOURCE_FOUND = 3;
        const int ERROR_WRITING_TO_DESTINATION = 4;
        const int ERROR_INVALID_JH_KEY = 5;
        const int ERROR_EXECUTION = 6;
        const int ERROR_INVALID_SOURCE_FILE = 7;
        const int ERROR_INVALID_FILE_INDICES = 8;

        static void Usage()
        {
            Console.WriteLine();
            Console.WriteLine("Usage: AmbermoonPack <type> <source> <dest> [key] [options]");
            Console.WriteLine("       AmbermoonPack REPACK <source> <dest> [options]");
            Console.WriteLine("       AmbermoonPack UNPACK <source> <dest>");
            Console.WriteLine("       AmbermoonPack UNITEM <source> <dest>");
            Console.WriteLine("       AmbermoonPack PKITEM <source> <dest>");
            Console.WriteLine();
            Console.WriteLine("The first version packs a directory of single files into a container.");
            Console.WriteLine("UNPACK unpacks a container to a directory of single files.");
            Console.WriteLine("REPACK packs a container to a different format.");
            Console.WriteLine("UNITEM unpacks an item container to a single item files.");
            Console.WriteLine("PKITEM packs a directory of item files into an item container.");
            Console.WriteLine();
            Console.WriteLine(" <type>     JH, LOB, VOL1, AMNC, AMNP, AMBR, AMPC, JH+AMBR, JH+LOB");
            Console.WriteLine(" <source>   Source file or directory path");
            Console.WriteLine(" <dest>     Destination file path");
            Console.WriteLine(" [key]      Optional encrypt key for JH files");
            Console.WriteLine(" [options]  See below");
            Console.WriteLine();
            Console.WriteLine("Don't use the compression options if you plan to pack data for the original!");
            Console.WriteLine();
            Console.WriteLine("Options:");
            Console.WriteLine();
            Console.WriteLine(" -dN: Dictionary compression");
            Console.WriteLine("      N=0: None (default)");
            Console.WriteLine("      N=1: Half file size entry size");
            Console.WriteLine("      N=2: Use file size sections (to compress gaps)");
            Console.WriteLine("      N=3: Combines 1 and 2");
            Console.WriteLine("      N=4: Uses 1 and if valuable also 2");
            Console.WriteLine(" -cN: Lob compression");
            Console.WriteLine("      N=0: Original Lob (default)");
            Console.WriteLine("      N=1: Extended Lob");
            Console.WriteLine("      N=2: Advanced Lob");
            Console.WriteLine("      N=3: Use best of 0, 1 and 2");
            Console.WriteLine("      N=4: Text Lob");
            Console.WriteLine("      N=5: Use best of 0 and 4");
            Console.WriteLine("      Note that for AMNP, the raw data is used if the best compression is worse.");
            Console.WriteLine(" -v: Verbose. Prints compression info for each subfile to the console.");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine();
            Console.WriteLine(" AmbermoonPack LOB \"my\\path\\to\\file\" \"test.amb\"");
            Console.WriteLine(" AmbermoonPack AMNP \"my\\path\\to\\dir\\with\\files\" \"test.amb\"");
            Console.WriteLine(" AmbermoonPack JH+LOB \"my\\path\\to\\dir\\with\\textfiles\\001\" \"Text.amb\" 0xd2e7");
            Console.WriteLine(" AmbermoonPack UNITEM \"my\\path\\to\\file\" \"my\\path\\to\\dir\"");
            Console.WriteLine();
            Console.WriteLine("Note:");
            Console.WriteLine(" If the files have names like 001, 002, etc this is used as the");
            Console.WriteLine(" file number inside the resulting container. Otherwise they are");
            Console.WriteLine(" sorted alphabetically and numbered 1 to n.");
            Console.WriteLine();
            Console.WriteLine("Error codes:");
            Console.WriteLine(" 0: No error");
            Console.WriteLine(" 1: Invalid usage");
            Console.WriteLine(" 2: Invalid type");
            Console.WriteLine(" 3: Source not found");
            Console.WriteLine(" 4: Destination write error");
            Console.WriteLine(" 5: Invalid JH encrypt key");
            Console.WriteLine(" 6: Internal program error");
            Console.WriteLine(" 7: Invalid source file for repack");
            Console.WriteLine(" 8: Invalid file numbering for item pack");
            Console.WriteLine();
        }

        static string[] ParseOptions(string[] args, out bool verbose, out LobType lobType, out FileDictionaryCompression fileDictionaryCompression)
        {
            var dictionaryCompressOptions = args.Where(a => a.StartsWith("-d")).ToList();
            var compressOptions = args.Where(a => a.StartsWith("-c")).ToList();
            verbose = args.Any(a => a == "-v");
            lobType = LobType.Ambermoon;
            fileDictionaryCompression = FileDictionaryCompression.None;

            if (dictionaryCompressOptions.Count > 1 || compressOptions.Count > 1)
                return null;

            if (dictionaryCompressOptions.Count == 1)
            {
                string option = dictionaryCompressOptions[0];

                if (option.Length != 3 || !int.TryParse(option[2].ToString(), out int dictionaryCompression) || dictionaryCompression > 4)
                    return null;

                fileDictionaryCompression = (FileDictionaryCompression)dictionaryCompression;
            }

            if (compressOptions.Count == 1)
            {
                string option = compressOptions[0];

                if (option.Length != 3 || !int.TryParse(option[2].ToString(), out int fileCompression) || fileCompression > 6)
                    return null;

                lobType = fileCompression switch
                {
                    0 => LobType.Ambermoon,
                    1 => LobType.LZRS,
                    2 => LobType.Extended,
                    3 => LobType.TakeBest,
                    4 => LobType.Text,
                    5 => LobType.TakeBestForText,
                    _ => LobType.Ambermoon
                };
            }

            return args.Where(a => a[0] != '-').ToArray();
        }

        static void Main(string[] args)
        {
            args = ParseOptions(args, out bool verbose, out var lobType, out var fileDictionaryCompression);

            if (args == null)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            if (args.Length != 3 && args.Length != 4)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            FileType? type;
            bool additionalLobCompression = false;
            string op = args[0].ToUpper();

            if (op == "REPACK")
            {
                type = null;
            }
            else if (op == "UNPACK")
            {
                Unpack(args);
                return;
            }
            else if (op == "JH+LOB")
            {
                type = FileType.JH;
                additionalLobCompression = true;
            }
            else if (op == "JH+AMBR")
            {
                type = FileType.JHPlusAMBR;
            }
            else if (op == "UNITEM")
            {
                UnpackItems(args);
                return;
            }
            else if (op == "PKITEM")
            {
                PackItems(args);
                return;
            }
            else if (!Enum.TryParse<FileType>(op.TrimEnd('+').ToUpper(), out FileType fileType))
            {
                Console.WriteLine($"Invalid type '{args[0]}'");
                Usage();
                Environment.Exit(ERROR_INVALID_TYPE);
                return;
            }
            else
            {
                type = fileType;
            }

            if (type != FileType.JH && args.Length == 4)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            if (!File.Exists(args[1]))
            {
                if (type == null || type == FileType.JH || type == FileType.LOB || type == FileType.VOL1)
                {
                    Console.WriteLine($"Source file '{args[1]}' not found.");
                    Usage();
                    Environment.Exit(ERROR_SOURCE_FOUND);
                    return;
                }
                else if (!Directory.Exists(args[1]))
                {
                    Console.WriteLine($"Source file or directory '{args[1]}' not found.");
                    Usage();
                    Environment.Exit(ERROR_SOURCE_FOUND);
                    return;
                }
            }

            var writer = new DataWriter();

            void PrintCompression(int uncompressedSize, int compressedSize, int? subfile = null)
            {
                if (!verbose)
                    return;

                if (subfile != null)
                    Console.WriteLine($"{subfile:000}: {uncompressedSize,-10} -> {compressedSize,-10} ({(float)compressedSize * 100.0f / uncompressedSize:0.00}%)");
                else
                    Console.WriteLine($"Compression result: {uncompressedSize,-10} -> {compressedSize,-10} ({(float)compressedSize * 100.0f / uncompressedSize:0.00}%)");
            }

            try
            {
                if (type == null) // repack
                {
                    try
                    {
                        var containerData = File.ReadAllBytes(args[1]);
                        var container = new FileReader().ReadFile(Path.GetFileName(args[1]), new DataReader(containerData));
                        var containerType = (FileType)container.Header;

                        switch (containerType)
                        {
                            case FileType.JH:
                                {
                                    var tempReader = new DataReader(containerData);
                                    var header = tempReader.ReadDword();
                                    ushort key = (ushort)(((header & 0xffff0000u) >> 16) ^ (header & 0x0000ffffu));
                                    containerData = Ambermoon.Data.Legacy.Compression.JH.Crypt(tempReader, key);
                                    tempReader = new DataReader(containerData);
                                    header = tempReader.ReadDword(); // read potential LOB/VOL1 header
                                    bool lob = header == (uint)FileType.LOB || header == (uint)FileType.VOL1;
                                    WriteFiles(writer, containerType, key, lob, container.Files.First().Value.ToArray(), lobType);
                                    break;
                                }
                            case FileType.LOB:
                            case FileType.VOL1:
                                WriteFiles(writer, containerType, null, null, container.Files.First().Value.ToArray(), lobType);
                                break;
                            default:
                                WriteFiles(writer, containerType, container.Files.ToDictionary(f => (uint)f.Key, f => f.Value.ToArray()),
                                    lobType, fileDictionaryCompression, PrintCompression);
                                break;
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("Invalid source file for REPACK.");
                        Console.WriteLine("Error: " + ex.Message);
                        Environment.Exit(ERROR_INVALID_SOURCE_FILE);
                        return;
                    }
                }
                else if (type == FileType.JH)
                {
                    string keyString;

                    if (args.Length == 4)
                        keyString = args[3];
                    else
                    {
                        Console.Write("Enter encrypt key (16 bit): ");
                        keyString = Console.ReadLine();
                    }

                    ushort key;

                    try
                    {
                        if (keyString.StartsWith("0x", StringComparison.InvariantCultureIgnoreCase))
                            key = ushort.Parse(keyString[2..], System.Globalization.NumberStyles.HexNumber);
                        else
                            key = ushort.Parse(keyString);
                    }
                    catch (FormatException)
                    {
                        Console.WriteLine("Invalid encrypt key. Provide a value from 0 to 65535 (or hex 0x0000 to 0xffff).");
                        Environment.Exit(ERROR_INVALID_JH_KEY);
                        return;
                    }

                    WriteFiles(writer, FileType.JH, key, additionalLobCompression, File.ReadAllBytes(args[1]), lobType);
                }
                else if (type == FileType.LOB || type == FileType.VOL1)
                {
                    var data = File.ReadAllBytes(args[1]);
                    WriteFiles(writer, type.Value, null, null, data, lobType);
                    PrintCompression(data.Length, writer.Size);
                }
                else
                {
                    if (File.Exists(args[1]))
                        WriteFiles(writer, type.Value, GetContainerDataFromFiles(args[1]), lobType, fileDictionaryCompression, PrintCompression);
                    else
                        WriteFiles(writer, type.Value, GetContainerDataFromFiles(Directory.GetFiles(args[1])), lobType, fileDictionaryCompression, PrintCompression);
                }

                WriteFile(args[2], writer);

                Console.WriteLine("File was written successfully.");
                Environment.Exit(0);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Internal error: " + ex.Message);
                Environment.Exit(ERROR_EXECUTION);
            }
        }

        static void Unpack(string[] args)
        {
            if (args.Length != 3)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            if (!File.Exists(args[1]))
            {
                Console.WriteLine($"Source file '{args[1]}' not found.");
                Usage();
                Environment.Exit(ERROR_SOURCE_FOUND);
                return;
            }

            var reader = new FileReader();
            Ambermoon.Data.IFileContainer file;

            try
            {
                file = reader.ReadFile("", new DataReader(File.ReadAllBytes(args[1])));
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error loading file: " + ex.Message);
                Environment.Exit(ERROR_INVALID_SOURCE_FILE);
                return;
            }

            string outDir = args[2];

            if (File.Exists(outDir))
                outDir = Path.GetDirectoryName(outDir);

            try
            {
                Directory.CreateDirectory(outDir);
            }
            catch
            {
                Console.WriteLine("Failed to create output directory");
                Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                return;
            }

            try
            {
                foreach (var subfile in file.Files)
                {
                    File.WriteAllBytes(Path.Combine(outDir, subfile.Key.ToString("000")), subfile.Value.ReadToEnd());
                }
            }
            catch
            {
                Console.WriteLine("Failed to write output files");
                Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                return;
            }
        }

        static void UnpackItems(string[] args)
        {
            if (args.Length != 3)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            var tempDir = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            var tempFile = Path.Combine(tempDir, "001");
            Unpack(new string[] { args[0], args[1], tempDir });
            var reader = new DataReader(File.ReadAllBytes(tempFile));
            int itemCount = reader.ReadWord();

            try
            {
                Directory.CreateDirectory(args[2]);
            }
            catch
            {
                Console.WriteLine("Failed to create output directory");
                Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                return;
            }

            try
            {
                for (int i = 0; i < itemCount; ++i)
                {
                    File.WriteAllBytes(Path.Combine(args[2], $"{(i + 1):000}"), reader.ReadBytes(60));
                }
            }
            catch
            {
                Console.WriteLine("Failed to write output files");
                Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                return;
            }

            return;
        }

        static void WriteFile(string path, DataWriter dataWriter)
        {
            try
            {
                var destinationDirectory = Path.GetDirectoryName(path);

                if (!string.IsNullOrWhiteSpace(destinationDirectory))
                    Directory.CreateDirectory(destinationDirectory);

                var destinationStream = File.Create(path);
                dataWriter.CopyTo(destinationStream);
                destinationStream.Flush();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error writing to destination '{path}': {ex.Message}");
                Console.WriteLine($" Ensure to specify a valid file path.");
                Console.WriteLine($" Ensure that you have write permission.");
                Console.WriteLine($" Ensure that the file is not opened in another program.");
                Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                return;
            }
        }

        static void PackItems(string[] args)
        {
            if (args.Length != 3)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            if (!Directory.Exists(args[1]))
            {
                Console.WriteLine($"Source directory '{args[1]}' not found.");
                Usage();
                Environment.Exit(ERROR_SOURCE_FOUND);
                return;
            }

            var files = GetContainerDataFromFiles(Directory.GetFiles(args[1]));

            if (files.Keys.Max() != files.Count)
            {
                Console.WriteLine($"Invalid file numbering. Ensure file names starting at 001 and without gaps.");
                Environment.Exit(ERROR_INVALID_FILE_INDICES);
                return;
            }

            var dataWriter = new DataWriter();

            dataWriter.Write((ushort)files.Count);

            foreach (var file in files.ToList().OrderBy(f => f.Key))
            {
                dataWriter.Write(file.Value);
            }

            var outputWriter = new DataWriter();

            WriteFiles(outputWriter, FileType.JH, 0xd2e7, true, dataWriter.ToArray(), LobType.Ambermoon);

            WriteFile(args[2], outputWriter);

            Console.WriteLine("File was written successfully.");
            Environment.Exit(0);
        }

        static Dictionary<uint, byte[]> GetContainerDataFromFiles(params string[] files)
        {
            if (files == null)
                return new Dictionary<uint, byte[]>();

            var result = new Dictionary<uint, byte[]>(files.Length);
            var list = new List<string>(files);
            list.Sort();
            var regex = new Regex("^[0-9]+$", RegexOptions.Compiled);
            uint lastIndex = 0;

            foreach (var file in list)
            {
                uint index = lastIndex + 1;

                if (regex.IsMatch(Path.GetFileNameWithoutExtension(file)))
                {
                    index = uint.Parse(Path.GetFileNameWithoutExtension(file));
                }

                result[index] = File.ReadAllBytes(file);

                lastIndex = index;
            }

            return result;
        }

        static void WriteFiles(DataWriter writer, FileType type, ushort? jhKey, bool? addLob, byte[] file, LobType lobType)
        {
            switch (type)
            {
                case FileType.JH:
                    FileWriter.WriteJH(writer, file, jhKey.Value, addLob.Value);
                    break;
                case FileType.LOB:
                    FileWriter.WriteLob(writer, file, lobType);
                    break;
                case FileType.VOL1:
                    FileWriter.WriteVol1(writer, file, lobType);
                    break;
                default:
                    throw new Exception("Invalid call of WriteFiles for container format.");
            }
        }

        static void WriteFiles(DataWriter writer, FileType type, Dictionary<uint, byte[]> files, LobType lobType,
            FileDictionaryCompression fileDictionaryCompression, Action<int, int, int?> compressionPrinter)
        {
            switch (type)
            {
                case FileType.JH:
                case FileType.LOB:
                case FileType.VOL1:
                    throw new Exception("Invalid call of WriteFiles for non-container format.");
                default:
                    FileWriter.WriteContainer(writer, files, type, null, lobType, fileDictionaryCompression, compressionPrinter);
                    break;
            }
        }
    }
}
