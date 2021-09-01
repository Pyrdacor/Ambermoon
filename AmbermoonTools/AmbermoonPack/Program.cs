using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

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

        static void Usage()
        {
            Console.WriteLine();
            Console.WriteLine("Usage: AmbermoonPack <type> <source> <dest> [key]");
            Console.WriteLine("       AmbermoonPack REPACK <source> <dest>");
            Console.WriteLine("       AmbermoonPack UNPACK <source> <dest>");
            Console.WriteLine();
            Console.WriteLine("The first version packs a directory of single files into a container.");
            Console.WriteLine("UNPACK unpacks a container to a directory of single files.");
            Console.WriteLine("REPACK packs a container to a different format.");
            Console.WriteLine();
            Console.WriteLine(" <type>     JH, LOB, VOL1, AMNC, AMNP, AMBR, AMPC or JH+LOB");
            Console.WriteLine(" <source>   Source file or directory path");
            Console.WriteLine(" <dest>     Destination file path");
            Console.WriteLine(" [key]      Optional encrypt key for JH files");
            Console.WriteLine();
            Console.WriteLine("Examples:");
            Console.WriteLine();
            Console.WriteLine(" AmbermoonPack LOB \"my\\path\\to\\file\" \"test.amb\"");
            Console.WriteLine(" AmbermoonPack AMNP \"my\\path\\to\\dir\\with\\files\" \"test.amb\"");
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
            Console.WriteLine();
        }

        static void Main(string[] args)
        {
            if (args.Length != 3 && args.Length != 4)
            {
                Usage();
                Environment.Exit(ERROR_INVALID_USAGE);
                return;
            }

            FileType? type;
            bool additionalLobCompression = false;

            if (args[0].ToUpper() == "REPACK")
            {
                type = null;
            }
            else if (args[0].ToUpper() == "UNPACK")
            {
                Unpack(args);
                return;
            }
            else if (args[0].ToUpper() == "JH+LOB")
            {
                type = FileType.JH;
                additionalLobCompression = true;
            }
            else if (!Enum.TryParse<FileType>(args[0].ToUpper(), out FileType fileType))
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

            try
            {
                if (type == null)
                {
                    try
                    {
                        var containerData = File.ReadAllBytes(args[1]);
                        var container = new FileReader().ReadFile(Path.GetFileName(args[1]), containerData);
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
                                    WriteFiles(writer, containerType, key, lob, container.Files.First().Value.ToArray());
                                    break;
                                }
                            case FileType.LOB:
                            case FileType.VOL1:
                                WriteFiles(writer, containerType, null, null, container.Files.First().Value.ToArray());
                                break;
                            default:
                                WriteFiles(writer, containerType, container.Files.ToDictionary(f => (uint)f.Key, f => f.Value.ToArray()));
                                break;
                        }
                    }
                    catch
                    {
                        Console.WriteLine("Invalid source file for REPACK.");
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
                            key = ushort.Parse(keyString.Substring(2), System.Globalization.NumberStyles.HexNumber);
                        else
                            key = ushort.Parse(keyString);
                    }
                    catch (FormatException)
                    {
                        Console.WriteLine("Invalid encrypt key. Provide a value from 0 to 65535 (or hex 0x0000 to 0xffff).");
                        Environment.Exit(ERROR_INVALID_JH_KEY);
                        return;
                    }

                    WriteFiles(writer, FileType.JH, key, additionalLobCompression, File.ReadAllBytes(args[1]));
                }
                else if (type == FileType.LOB || type == FileType.VOL1)
                {
                    WriteFiles(writer, type.Value, null, null, File.ReadAllBytes(args[1]));
                }
                else
                {
                    if (File.Exists(args[1]))
                        WriteFiles(writer, type.Value, GetContainerDataFromFiles(args[1]));
                    else
                        WriteFiles(writer, type.Value, GetContainerDataFromFiles(Directory.GetFiles(args[1])));
                }

                try
                {
                    var destinationDirectory = Path.GetDirectoryName(args[2]);

                    if (!string.IsNullOrWhiteSpace(destinationDirectory))
                        Directory.CreateDirectory(destinationDirectory);

                    var destinationStream = File.Create(args[2]);
                    writer.CopyTo(destinationStream);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error writing to destination '{args[2]}': {ex.Message}");
                    Console.WriteLine($" Ensure to specify a valid file path.");
                    Console.WriteLine($" Ensure that you have write permission.");
                    Console.WriteLine($" Ensure that the file is not opened in another program.");
                    Environment.Exit(ERROR_WRITING_TO_DESTINATION);
                    return;
                }

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
                file = reader.ReadFile("", File.ReadAllBytes(args[1]));
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

        static void WriteFiles(DataWriter writer, FileType type, ushort? jhKey, bool? addLob, byte[] file)
        {
            switch (type)
            {
                case FileType.JH:
                    FileWriter.WriteJH(writer, file, jhKey.Value, addLob.Value);
                    break;
                case FileType.LOB:
                    FileWriter.WriteLob(writer, file);
                    break;
                case FileType.VOL1:
                    FileWriter.WriteVol1(writer, file);
                    break;
                default:
                    throw new Exception("Invalid call of WriteFiles for container format.");
            }
        }

        static void WriteFiles(DataWriter writer, FileType type, Dictionary<uint, byte[]> files)
        {
            switch (type)
            {
                case FileType.JH:
                case FileType.LOB:
                case FileType.VOL1:
                    throw new Exception("Invalid call of WriteFiles for non-container format.");
                default:
                    FileWriter.WriteContainer(writer, files, type);
                    break;
            }
        }
    }
}
