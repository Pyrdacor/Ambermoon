using Ambermoon.Data;
using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Characters;
using Ambermoon.Data.Legacy.Serialization;
using Ambermoon.Data.Serialization;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;

namespace MonsterValueChanger
{
    class Program
    {
        static void Usage()
        {
            Console.WriteLine("USAGE: MonsterValueChanger --list");
            Console.WriteLine("       MonsterValueChanger <monsterIdOrName> <offset> <size>");
            Console.WriteLine("       MonsterValueChanger <monsterIdOrName> <offset> <size> <value>");
            Console.WriteLine("       MonsterValueChanger --all <offset> <size>");
            Console.WriteLine("       MonsterValueChanger --all-not-0 <offset> <size>");
            Console.WriteLine();
            Console.WriteLine("1st version shows all monsters with their id and name.");
            Console.WriteLine("2nd version shows a value at the given offset with a given size.");
            Console.WriteLine("3rd version changes a value at the given offset.");
            Console.WriteLine("4th version list the value for all monsters.");
            Console.WriteLine();
            Console.WriteLine("The <monsterIdOrName> param is case-insensitive.");
            Console.WriteLine("The <offset> param is in bytes and can be decimal or hex (with 0x prefix).");
            Console.WriteLine("The <size> param is in bytes. So possible values are 1, 2 and 4.");
            Console.WriteLine("The <value> param can be decimal or hex (add the prefix 0x then).");
            Console.WriteLine();
            Console.WriteLine("Example 1: Show portrait index of spider");
            Console.WriteLine("-> MonsterValueChanger Spider 9 2");
            Console.WriteLine("Example 2: Set gold amount of zombie master to 1000");
            Console.WriteLine("-> MonsterValueChanger \"ZOMBIE MASTER\" 0x18 2 1000");
            Console.WriteLine("Example 3: Set combat attack damage of bandit to 32");
            Console.WriteLine("-> MonsterValueChanger bandit 0xda 2 0x20");
            Console.WriteLine();
        }

        static string DataPath = Path.GetDirectoryName(Assembly.GetEntryAssembly().Location);

        enum ErrorCode
        {
            NoError,
            InvalidNumberOfArguments,
            InvalidOptions,
            UnableToLoadGameData,
            UnableToLoadMonsters,
            NoMonsterWithIdOrName,
            InvalidArgumentFormat,
            ArgumentOutOfRange,
            UnableToCreateBackup
        }

        static void Exit(ErrorCode errorCode)
        {
            Environment.Exit((int)errorCode);
        }

        static Dictionary<int, IDataReader> LoadMonsterFiles()
        {
            var gameData = new GameData();

            try
            {
                gameData.Load(DataPath);
            }
            catch (FileNotFoundException)
            {
                try
                {
                    DataPath = Environment.CurrentDirectory;
                    gameData = new GameData();
                    gameData.Load(DataPath);
                }
                catch (FileNotFoundException)
                {
                    Console.WriteLine("Unable to load game data. Ensure you run this tool next to Ambermoon game data files.");
                    Exit(ErrorCode.UnableToLoadGameData);
                    return null;
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Unable to load game data: " + ex.Message);
                    Exit(ErrorCode.UnableToLoadGameData);
                    return null;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Unable to load game data: " + ex.Message);
                Exit(ErrorCode.UnableToLoadGameData);
                return null;
            }

            try
            {
                return gameData.Files["Monster_char_data.amb"].Files;
            }
            catch
            {
                Console.WriteLine("Unable to load monsters from game data. Is Monster_char_data.amb present in the game data files?");
                Exit(ErrorCode.UnableToLoadMonsters);
                return null;
            }
        }

        static Dictionary<int, Monster> LoadMonsters()
        {
            var monsterReader = new MonsterReader();

            try
            {
                var files = LoadMonsterFiles();

                if (files == null)
                    return null;

                return files.Select(f => new { i = f.Key, m = Monster.Load(monsterReader, f.Value) }).ToDictionary(x => x.i, x => x.m);
            }
            catch
            {
                Console.WriteLine("Unable to load monsters from game data. Invalid Monster_char_data.amb file.");
                Exit(ErrorCode.UnableToLoadMonsters);
                return null;
            }
        }

        static Dictionary<int, Monster> LoadMonsters(out Dictionary<int, IDataReader> files)
        {
            var monsterReader = new MonsterReader();
            files = null;

            try
            {
                files = LoadMonsterFiles();

                if (files == null)
                    return null;

                return files.Select(f => new { i = f.Key, m = Monster.Load(monsterReader, f.Value) }).ToDictionary(x => x.i, x => x.m);
            }
            catch
            {
                Console.WriteLine("Unable to load monsters from game data. Invalid Monster_char_data.amb file.");
                Exit(ErrorCode.UnableToLoadMonsters);
                return null;
            }
        }

        static void ListMonsters()
        {
            var monsters = LoadMonsters();

            if (monsters == null)
                return;

            foreach (var monster in monsters)
            {
                Console.WriteLine($"{monster.Key:000}: {monster.Value.Name}");
            }

            Console.WriteLine();
        }

        static void ShowMonsterValues(long offset, long size, Func<Monster, uint, bool> condition)
        {
            var monsters = LoadMonsters(out var files);

            if (monsters == null)
                return;

            Console.WriteLine(" -- Value --");

            foreach (var monster in monsters)
            {
                var monsterFile = files[monster.Key];
                monsterFile.Position = (int)offset;
                uint value = size switch
                {
                    1 => monsterFile.ReadByte(),
                    2 => monsterFile.ReadWord(),
                    4 => monsterFile.ReadDword(),
                    _ => 0
                };
                if (!condition(monster.Value, value))
                    continue;
                string hex = value.ToString($"x{size * 2}");
                int sizeShift = (int)size * 8 - 1;
                long signed = value & ((1 << sizeShift) - 1);
                if ((value & (1 << sizeShift)) != 0)
                    signed = -signed;

                Console.WriteLine($"{monster.Key:000}: {monster.Value.Name}");
                Console.WriteLine($" Dec unsigned: {value}");
                Console.WriteLine($" Hex unsigned: {hex}");
                Console.WriteLine($" Dec signed  : {signed}");
                Console.WriteLine();
            }

            Console.WriteLine();
        }

        static long ParseInt(string arg)
        {
            // all args are upper case
            if (arg.StartsWith("0X"))
                return long.Parse(arg.Substring(2), System.Globalization.NumberStyles.AllowHexSpecifier);
            else
                return long.Parse(arg);
        }

        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Invalid number of arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidNumberOfArguments);
                return;
            }

            var options = new List<string>();
            var parameters = new List<string>();

            foreach (var arg in args)
            {
                if (arg.StartsWith("--"))
                    options.Add(arg.ToLower());
                else if (arg.StartsWith("-"))
                    options.Add(arg.ToLower());
                else
                    parameters.Add(arg.ToUpper());
            }

            if (options.Contains("--help") || options.Contains("-h"))
            {
                Usage();
                Exit(ErrorCode.NoError);
                return;
            }

            if (options.Contains("--list") || options.Contains("-l"))
            {
                ListMonsters();
                return;
            }

            if (options.Contains("--all") || options.Contains("-a"))
            {
                if (!ReadOffsetAndSize(parameters, 0, out long off, out long sz))
                    return;
                ShowMonsterValues(off, sz, (monster, value) => true);
                return;
            }

            if (options.Contains("--all-not-0"))
            {
                if (!ReadOffsetAndSize(parameters, 0, out long off, out long sz))
                    return;
                ShowMonsterValues(off, sz, (monster, value) => value != 0);
                return;
            }

            if (options.Count != 0)
            {
                Console.WriteLine("Invalid options: " + string.Join(" ", options));
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidOptions);
                return;
            }

            if (parameters.Count < 3 || parameters.Count > 4)
            {
                Console.WriteLine("Invalid number of arguments.");
                Console.WriteLine();
                Usage();
                Exit(ErrorCode.InvalidNumberOfArguments);
                return;
            }

            var monsters = LoadMonsters(out var monsterFiles);

            if (monsters == null)
                return;

            IDataReader monsterFile;

            try
            {
                if (int.TryParse(parameters[0], out int monsterId))
                    monsterFile = monsterFiles.ContainsKey(monsterId) ? monsterFiles[monsterId] : throw new Exception($"No monster exists with id {monsterId}.");
                else
                {
                    var monster = monsters.FirstOrDefault(m => m.Value.Name.ToUpper() == parameters[0]);
                    monsterFile = monster.Value == null ? null : monsterFiles[monsters.FirstOrDefault(m => m.Value.Name.ToUpper() == parameters[0]).Key]; // TODO: Do german umlauts work here?

                    if (monsterFile == null)
                        throw new Exception($"No monster exists with name '{parameters[0]}'.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                Exit(ErrorCode.NoMonsterWithIdOrName);
                return;
            }

            if (!ReadOffsetAndSize(parameters, 1, out long offset, out long size))
                return;

            if (parameters.Count == 3)
                ShowMonsterValue(monsterFile, offset, size);
            else
            {
                long value;

                try
                {
                    value = ParseInt(parameters[3]);
                }
                catch
                {
                    Console.WriteLine("Invalid <value> parameter value: " + parameters[3]);
                    Exit(ErrorCode.InvalidArgumentFormat);
                    return;
                }

                if (!CheckSize(ref value, size))
                {
                    Console.WriteLine($"Parameter <value> is too big for given <size> of {size}: " + parameters[3]);
                    Exit(ErrorCode.ArgumentOutOfRange);
                    return;
                }

                SetMonsterValue(monsterFiles, monsterFile, offset, size, value);
            }

            Exit(ErrorCode.NoError);
        }

        static bool ReadOffsetAndSize(List<string> parameters, int index, out long offset, out long size)
        {
            offset = 0;
            size = 0;

            try
            {
                offset = ParseInt(parameters[index]);
            }
            catch
            {
                Console.WriteLine("Invalid <offset> parameter value: " + parameters[index]);
                Exit(ErrorCode.InvalidArgumentFormat);
                return false;
            }

            try
            {
                size = ParseInt(parameters[index + 1]);
            }
            catch
            {
                Console.WriteLine("Invalid <size> parameter value: " + parameters[index + 1]);
                Exit(ErrorCode.InvalidArgumentFormat);
                return false;
            }

            if (offset < 0 || offset > 809)
            {
                Console.WriteLine("Parameter <offset> must be between 0 and 809 but was: " + parameters[1]);
                Exit(ErrorCode.ArgumentOutOfRange);
                return false;
            }

            if (size != 1 && size != 2 && size != 4)
            {
                Console.WriteLine("Parameter <size> must be 1, 2 or 4 but was: " + parameters[2]);
                Exit(ErrorCode.ArgumentOutOfRange);
                return false;
            }

            if (offset + size > 810)
            {
                Console.WriteLine("Parameter <offset> plus <size> exceeds total size of 810. Please adjust values.");
                Exit(ErrorCode.ArgumentOutOfRange);
                return false;
            }

            return true;
        }
        
        static void ShowMonsterValue(IDataReader monsterFile, long offset, long size)
        {
            monsterFile.Position = (int)offset;
            Console.WriteLine(" -- Value --");
            uint value = size switch
            {
                1 => monsterFile.ReadByte(),
                2 => monsterFile.ReadWord(),
                4 => monsterFile.ReadDword(),
                _ => 0
            };
            string hex = value.ToString($"x{size * 2}");
            int sizeShift = (int)size * 8 - 1;
            long signed = value & ((1 << sizeShift) - 1);
            if ((value & (1 << sizeShift)) != 0)
                signed = -signed;

            Console.WriteLine($" Dec unsigned: {value}");
            Console.WriteLine($" Hex unsigned: {hex}");
            Console.WriteLine($" Dec signed  : {signed}");
            Console.WriteLine();
        }

        static void SetMonsterValue(Dictionary<int, IDataReader> monsterFiles, IDataReader monsterFile, long offset, long size, long value)
        {
            var files = new Dictionary<uint, byte[]>();

            foreach (var entry in monsterFiles)
            {
                var file = entry.Value;

                file.Position = 0;

                if (file == monsterFile)
                {
                    var data = new List<byte>();

                    if (offset != 0)
                        data.AddRange(monsterFile.ReadBytes((int)offset));

                    switch (size)
                    {
                        case 1:
                            data.Add((byte)value);
                            break;
                        case 2:
                            data.Add((byte)(value >> 8));
                            data.Add((byte)value);
                            break;
                        case 4:
                            data.Add((byte)(value >> 24));
                            data.Add((byte)(value >> 16));
                            data.Add((byte)(value >> 8));
                            data.Add((byte)value);
                            break;
                    }

                    monsterFile.Position += (int)size;

                    if (offset + size < monsterFile.Size)
                        data.AddRange(monsterFile.ReadToEnd());

                    files.Add((uint)entry.Key, data.ToArray());
                }
                else
                {
                    files.Add((uint)entry.Key, file.ReadToEnd());
                }
            }

            var dataWriter = new DataWriter();
            FileWriter.WriteContainer(dataWriter, files, FileType.AMBR);

            string monsterDataFile = Path.Combine(DataPath, "Monster_char_data.amb");
            string backupFile = Path.Combine(DataPath, "Monster_char_data.amb.backup");

            if (!File.Exists(monsterDataFile))
            {
                Console.WriteLine("No monster data file found at: " + monsterDataFile);
                Exit(ErrorCode.UnableToCreateBackup);
                return;
            }

            if (!File.Exists(backupFile))
            {
                Console.WriteLine("No backup file exists. Creating backup at: " + backupFile);

                try
                {
                    File.Copy(monsterDataFile, backupFile);
                }
                catch
                {
                    Console.WriteLine("Failed to create backup at: " + backupFile);
                    Exit(ErrorCode.UnableToCreateBackup);
                    return;
                }

                Console.Write("Backup created successfully. Changing monster data ... ");
            }
            else
            {
                Console.Write("Backup file does already exist. Changing monster data ... ");
            }

            try
            {
                using var output = File.Create(monsterDataFile);
                dataWriter.CopyTo(output);
                Console.Write("done");
            }
            catch
            {
                Console.Write("failed");
                Console.Write("Restoring backup ... ");

                try
                {
                    File.Copy(backupFile, monsterDataFile);
                    Console.WriteLine("done");
                }
                catch
                {
                    Console.WriteLine("failed. Please restore backup yourself.");
                }
            }

            Console.WriteLine();
        }

        static bool CheckSize(ref long value, long numBytes)
        {
            long min = numBytes switch
            {
                1 => sbyte.MinValue,
                2 => short.MinValue,
                4 => int.MinValue,
                _ => throw new Exception()
            };
            long max = numBytes switch
            {
                1 => byte.MaxValue,
                2 => ushort.MaxValue,
                4 => uint.MaxValue,
                _ => throw new Exception()
            };

            if (value < min || value > max)
                return false;

            if (value < 0)
                value = max + value;

            return true;
        }
    }
}
