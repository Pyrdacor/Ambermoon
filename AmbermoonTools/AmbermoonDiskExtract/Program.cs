using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using static Ambermoon.Data.Legacy.Compression.LobCompression;

namespace AmbermoonDiskExtract
{
    class Program
    {
        static void Usage()
        {
            Console.WriteLine();
            Console.WriteLine("Usage: AmbermoonDiskExtract <folder_with_adfs> [dest_path]");
            Console.WriteLine("       AmbermoonDiskExtract -u <folder_with_adfs> [dest_path]");
            Console.WriteLine();
            Console.WriteLine("First version extracts the encoded files.");
            Console.WriteLine("Second version extracts all files as raw files or AMBR containers.");
            Console.WriteLine();
        }

        static void Main(string[] args)
        {
            if (args.Length < 1 || args.Length > 3)
            {
                Usage();
                Environment.Exit(1);
                return;
            }

            if (args.Length == 3 && args[0] != "-u")
            {
                Usage();
                Environment.Exit(1);
                return;
            }

            bool uncompressed = args[0] == "-u";
            string gameDataPath = uncompressed ? args[1] : args[0];
            var gameData = new GameData(GameData.LoadPreference.ForceAdf, null, false);

            try
            {
                gameData.Load(gameDataPath);
            }
            catch
            {
                Console.WriteLine($"No valid ADF files found at '{gameDataPath}'.");
                Environment.Exit(1);
                return;
            }

            string outPath = uncompressed ? (args.Length == 3 ? args[2] : null) : (args.Length == 2 ? args[1] : null);
            outPath ??= Path.GetDirectoryName(Process.GetCurrentProcess().MainModule.FileName);

            void WriteFile(string filename, DataWriter dataWriter)
            {
                var filePath = Path.Combine(outPath, filename);
                Directory.CreateDirectory(Path.GetDirectoryName(filePath));
                using var output = File.Create(filePath);
                dataWriter.CopyTo(output);
            }

            try
            {
                foreach (var file in gameData.Files)
                {
                    var dataWriter = new DataWriter();
                    var fileType = ((file.Value.Header & 0xffff0000) == (uint)FileType.JH) ? FileType.JH : (FileType)file.Value.Header;

                    switch (fileType)
                    {
                        case FileType.JH:
                        case FileType.LOB:
                        case FileType.VOL1:
                            if (uncompressed)
                                dataWriter.Write(file.Value.Files[1].ToArray());
                            else
                                FileWriter.Write(dataWriter, file.Value, LobType.Ambermoon);
                            break;
                        case FileType.AMBR:
                        case FileType.AMNC:
                        case FileType.AMNP:
                        case FileType.AMPC:
                            if (uncompressed)
                                FileWriter.WriteContainer(dataWriter, file.Value.Files.ToDictionary(f => (uint)f.Key, f => f.Value.ToArray()), FileType.AMBR);
                            else
                                FileWriter.Write(dataWriter, file.Value, LobType.Ambermoon);
                            break;
                        default: // raw
                            dataWriter.Write(file.Value.Files[1].ToArray());
                            break;
                    }
                    WriteFile(file.Key, dataWriter);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error writing ADF content to '{outPath}': {ex.Message}");
                Environment.Exit(1);
                return;
            }

            Environment.Exit(0);
        }
    }
}
