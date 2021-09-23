using Ambermoon.Data.Legacy;
using Ambermoon.Data.Legacy.Serialization;
using System;

namespace AmbermoonItemEditor
{
    internal class Program
    {
        static void Main(string[] args)
        {
            var gameData = new GameData(GameData.LoadPreference.ForceExtracted, null, false);

            try
            {
                gameData.Load(args[0]);

                if (!gameData.Files.ContainsKey("AM2_CPU") || !gameData.Files.ContainsKey("AM2_BLIT"))
                    throw new Exception();
            }
            catch
            {
                Console.WriteLine("Unable to load executables.");
                Environment.Exit(1);
                return;
            }

            var exe1 = new Executable(gameData.Files["AM2_CPU"].Files[1]);
            var exe2 = new Executable(gameData.Files["AM2_BLIT"].Files[1]);

            ProcessExecutables(exe1, exe2);
        }

        static void PrintLine()
        {
            Console.WriteLine("*" + new string('=', 77) + "*");
        }

        static void ProcessExecutables(Executable exe1, Executable exe2)
        {
            Console.WriteLine("Items");
            PrintLine();
            exe1.PrintItems();
        }
    }
}
