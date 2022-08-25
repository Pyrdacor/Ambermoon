using System.Reflection;
using System.Text;

namespace CSharpToC
{
    public static class CCodeExporter
    {
        public static void Export(string path, Assembly assembly, Func<string, string>? subPathProvider = null)
        {
            string typesPath = Path.Combine(path, "include", "types.h");

            string Guard(string guardName, string code)
            {
                return
                    $"#ifndef {guardName}\n" +
                    $"#define {guardName}\n\n" +
                    code.TrimEnd('\n') + "\n\n" +
                    $"#endif /* {guardName} */\n";
            }

            static void WriteFile(string path, string text)
            {
                Directory.CreateDirectory(Path.GetDirectoryName(path)!);
                File.WriteAllText(path, text, Encoding.UTF8);
            }

            void ExportType(Type type, IProxy proxy)
            {
                string GetSubPath(Type type)
                {
                    string filename = type.Name + ".h";
                    return subPathProvider?.Invoke(filename) ?? filename;
                }

                string GetRelativePathFromRef(string otherFullPath, Type type)
                {
                    var fullPath = new Uri(Path.Combine(path, GetSubPath(type)), UriKind.Absolute);
                    return GetRelativePath(otherFullPath, fullPath);
                }

                string GetRelativePath(string otherFullPath, Uri fullPath)
                {
                    var relRoot = new Uri(otherFullPath, UriKind.Absolute);

                    return relRoot.MakeRelativeUri(fullPath).ToString();
                }

                string subPath = GetSubPath(type);
                string fullPath = Path.Combine(path, subPath);
                string references = string.Join("\n", type.GetCustomAttributes<CReferenceAttribute>().Select(r => $"#include \"{GetRelativePathFromRef(fullPath, r.Reference)}\""));

                if (proxy is IClassProxy classProxy && classProxy.NeedsTypesHeader)
                    references = $"#include \"{GetRelativePath(fullPath, new Uri(typesPath, UriKind.Absolute))}\"\n" + references;

                if (references.Length != 0)
                    references += "\n\n";

                string guardName = $"__{type.Name.ToUpper()}_H__";
                string content = Guard(guardName, references + proxy.ToString());

                WriteFile(fullPath, content);
            }

            WriteFile(typesPath, Guard($"__TYPES_H__",
                    "#define unsigned char BOOL\n" +
                    "#define const char* STRING"));

            HashSet<string> exportedAssemblies = new();

            void ExportAssembly(Assembly assembly)
            {
                exportedAssemblies.Add(assembly.FullName);

                foreach (var refAsm in assembly.GetReferencedAssemblies())
                {
                    if (!exportedAssemblies.Contains(refAsm.FullName))
                        ExportAssembly(Assembly.Load(refAsm));
                }

                foreach (var type in assembly.GetTypes().Where(t => t.GetCustomAttribute<CExportAttribute>() != null))
                {
                    if (type.IsAssignableTo(typeof(IProxy)))
                    {
                        var inst = (IProxy)Activator.CreateInstance(type, true)!;
                        ExportType(type, inst);
                    }
                }
            }

            ExportAssembly(assembly);
        }
    }
}
