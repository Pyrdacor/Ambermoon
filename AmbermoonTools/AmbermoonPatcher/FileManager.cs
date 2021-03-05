using Ambermoon.Data.Legacy;
using System.Collections.Generic;
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
                throw new System.Exception("Sub file data can't be set without retrieving it first.");
            }

            subFileData[file][subFileIndex] = data;
        }

        public void Save()
        {
            // TODO: Write back to game data and save it
        }
    }
}
