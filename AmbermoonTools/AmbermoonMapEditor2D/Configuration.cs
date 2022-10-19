using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Text.RegularExpressions;
using Formatting = Newtonsoft.Json.Formatting;
using JsonIgnoreAttribute = Newtonsoft.Json.JsonIgnoreAttribute;

namespace AmbermoonMapEditor2D
{
    internal class Configuration
    {
        public const string FileName = "editor.cfg";
        public const string GameDataPathName = "GameData";
        public const string MapPathName = "Map";
        public const string MapTextPathName = "MapText";
        public const string TilesetPathName = "Tileset";
        public const string ImagePathName = "Image";

        public Dictionary<string, string> SavePaths { get; set; }

        [JsonIgnore]
        private static readonly Regex netFolderRegex = new(@"net[0-9]+\.[0-9]+$", RegexOptions.Compiled);

        [JsonIgnore]
        public static string FilePath { get; } = Path.Combine(ExecutableDirectoryPath, FileName);

        [JsonIgnore]
        public static string ExecutableDirectoryPath
        {
            get
            {
                var assemblyPath = Process.GetCurrentProcess().MainModule.FileName;

#pragma warning disable IL3000
                if (assemblyPath.EndsWith("dotnet"))
                {
                    assemblyPath = Assembly.GetExecutingAssembly().Location;
                }
#pragma warning restore IL3000

                var assemblyDirectory = Path.GetDirectoryName(assemblyPath);

                if (OperatingSystem.IsWindows())
                {
                    if (assemblyDirectory.EndsWith("Debug") || assemblyDirectory.EndsWith("Release")
                         || netFolderRegex.IsMatch(assemblyDirectory))
                    {
                        string projectFile = Path.GetFileNameWithoutExtension(assemblyPath) + ".csproj";

                        var root = new DirectoryInfo(assemblyDirectory);

                        while (root.Parent != null)
                        {
                            if (File.Exists(Path.Combine(root.FullName, projectFile)))
                                break;

                            root = root.Parent;

                            if (root.Parent == null) // we could not find it (should not happen)
                                return assemblyDirectory;
                        }

                        return root.FullName;
                    }
                    else
                    {
                        return assemblyDirectory;
                    }
                }
                else
                {
                    return assemblyDirectory;
                }
            }
        }

        public static Configuration Load(string filename, Configuration defaultValue = null)
        {
            if (!File.Exists(filename))
                return defaultValue ?? new Configuration();

            return JsonConvert.DeserializeObject<Configuration>(File.ReadAllText(filename));    
        }

        public void Save(string filename)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(filename));
            File.WriteAllText(filename, JsonConvert.SerializeObject(this,
                new JsonSerializerSettings
                {
                    Formatting = Formatting.Indented,
                })
            );
        }
    }
}
