using Ambermoon.Data.Legacy;
using System;
using System.IO;

namespace AmbermoonPatcher
{
    class Program
    {
        static string GetArg(string[] args, int index, string message)
        {
            if (index < args.Length)
                return args[index];

            Console.Write(message + ": ");
            return Console.ReadLine();
        }

        static GameData LoadGameData(string dataPath)
        {
            var gameData = new GameData();

            try
            {
                gameData.Load(dataPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Unable to load game data: " + ex.Message);
                return null;
            }

            return gameData;
        }


        static void Main(string[] args)
        {
            string dataPath = GetArg(args, 0, "Path to Ambermoon data");
            string patchFile = GetArg(args, 1, "Patch script file");
            var gameData = LoadGameData(dataPath);
            var fileManager = new FileManager(gameData);

            try
            {
                var lines = File.ReadAllLines(patchFile);
                var output = Lexer.Run(lines);
                var actions = Parser.Run(output);

                foreach (var action in actions)
                    action.Run(fileManager);

                Console.WriteLine();

                if (fileManager.Save(dataPath))
                {
                    Console.WriteLine();
                    Console.WriteLine("Patch was applied successfully.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine();
                Console.WriteLine(ex.Message);
            }

            Console.WriteLine();
        }
    }
}
