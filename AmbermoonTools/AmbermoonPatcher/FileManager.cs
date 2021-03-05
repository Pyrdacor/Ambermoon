using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace AmbermoonPatcher
{
    class FileManager
    {
        readonly GameData gameData;
        readonly Dictionary<string, Dictionary<int, byte[]>> subFileData = new Dictionary<string, Dictionary<int, byte[]>>();

        public FileManager(GameData gameData)
        {
            this.gameData = gameData;
        }

        public byte[] GetFileData(string file, int subFileIndex)
        {
            if (!subFileData.ContainsKey(file))
            {
                if (!gameData.Files.ContainsKey(file))
                    return null;

                var data = gameData.Files[file].Files.ToDictionary(f => f.Key, f => f.Value.ToArray());
                subFileData.Add(file, data);
            }

            if (subFileIndex < 1 || subFileIndex > 0xffff || !subFileData[file].ContainsKey(subFileIndex))
                return null;

            return subFileData[file][subFileIndex];
        }

        public void SetFileData(string file, int subFileIndex, byte[] data)
        {
            if (!subFileData.ContainsKey(file) || !subFileData[file].ContainsKey(subFileIndex))
            {
                throw new Exception("Sub file data can't be set without retrieving it first.");
            }

            subFileData[file][subFileIndex] = data;
        }

        public bool Save(string dataPath)
        {
            foreach (var file in subFileData)
            {
                var container = gameData.Files[file.Key];
                var header = container.Header;
                var fileType = (header & 0xffff) == (uint)FileType.JH ? FileType.JH : (FileType)header;
                var writer = new DataWriter();
                var files = new Dictionary<uint, byte[]>();

                foreach (var subFile in container.Files)
                {
                    if (file.Value.ContainsKey(subFile.Key))
                        files.Add((uint)subFile.Key, file.Value[subFile.Key]);
                    else
                        files.Add((uint)subFile.Key, subFile.Value.ToArray());
                }

                FileWriter.WriteContainer(writer, files, fileType);

                string fullPath = Path.Combine(dataPath, file.Key);

                try
                {
                    if (File.Exists(fullPath))
                    {
                        string backupFile = fullPath + ".backup";

                        if (!File.Exists(backupFile))
                        {
                            Console.WriteLine("Target file already exists and there is no backup.");
                            Console.Write("Trying to create backup ... ");

                            try
                            {
                                File.Copy(fullPath, backupFile);
                                Console.WriteLine("done");
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine("failed");
                                Console.WriteLine("Error creating backup: " + ex.Message);
                                Console.WriteLine("Aborting");
                                return false;
                            }
                        }
                    }

                    Console.Write($"Writing file '{file.Key}' ... ");

                    try
                    {
                        using var outputFile = File.Create(fullPath);
                        writer.CopyTo(outputFile);
                        Console.WriteLine("done");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine("failed");
                        Console.WriteLine("Error writing file: " + ex.Message);
                        Console.WriteLine("Aborting");
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error: " + ex.Message);
                    Console.WriteLine("Aborting");
                    return false;
                }
            }

            return true;
        }
    }
}
