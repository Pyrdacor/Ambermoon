//using Ambermoon.Data;
using CSharpToC;
using System.Reflection;
/*using Console = CSharpToC.Console;

var c = new Console();
var ch = new DataObject<Character>();

System.Console.WriteLine(c.ToString());
System.Console.WriteLine();
System.Console.WriteLine(ch.ToString());*/


CCodeExporter.Export(@"C:\Users\Robert\Desktop\CCodeTest", Assembly.GetEntryAssembly()!);