using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text;

namespace CSharpToC
{
    [Flags]
    public enum MemberConfig
    {
        None = 0,
        IgnoreGetterOnlyProperties = 0x01,
        IgnoreMethods = 0x02,
        IgnoreProperties = 0x04,
        IgnoreCtor = 0x08,
        Default = None,
        DataDefault = IgnoreGetterOnlyProperties | IgnoreMethods
    }

    internal interface IClassProxy : IProxy
    {
        [CIgnore]
        bool NeedsTypesHeader { get; }
        [CIgnore]
        string Fields { get; }
        [CIgnore]
        IReadOnlySet<string> ProcessedFields { get; }
    }

    public abstract class ClassProxy<T> : IClassProxy where T : class
    {
        [CIgnore]
        private const string endl = "\n";
        [CIgnore]
        private readonly Type type = typeof(T);
        [CIgnore]
        private readonly StringBuilder code = new();
        [CIgnore]
        private readonly MemberConfig memberConfig;
        [CIgnore]
        internal readonly Dictionary<string, string> staticFunctionCallReplacements = new();
        [CIgnore]
        public bool NeedsTypesHeader { get; private set; }
        [CIgnore]
        public string Fields { get; }
        [CIgnore]
        private readonly HashSet<string> processedFields = new();
        [CIgnore]
        public IReadOnlySet<string> ProcessedFields => processedFields;

        [CIgnore]
        private void AppendLine(string line = "")
        {
            code.Append(line + endl);
        }

        [CIgnore]
        private void CheckTypesHeader(Type type)
        {
            if (!NeedsTypesHeader && TypeConverter.NeedsTypesHeader(type))
                NeedsTypesHeader = true;
        }
        
        protected ClassProxy(bool autoAddMethods = true, MemberConfig memberConfig = MemberConfig.None, string[]? excludedMembers = null)
        {
            this.memberConfig = memberConfig;
            bool anyInstanceMember = false;
            excludedMembers ??= Array.Empty<string>();
            var baseClass = type.GetCustomAttribute<CInheritAttribute>()?.BaseClass ?? GetType().GetCustomAttribute<CInheritAttribute>()?.BaseClass;
            var baseProxy = baseClass == null ? null : Activator.CreateInstance(baseClass) as IClassProxy;

            AppendLine($"struct {type.Name}");
            AppendLine("{");

            if (baseProxy != null)
            {
                var fieldLines = baseProxy.Fields.Split('\n');

                for (int i = 2; i < fieldLines.Length - 3; ++i)
                    AppendLine(fieldLines[i]);
            }
            
            foreach (var field in type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance))
            {
                if (baseProxy?.Fields?.Contains(field.Name) == true)
                    continue;

                if (!excludedMembers.Contains(field.Name) &&
                    field.GetCustomAttribute<CompilerGeneratedAttribute>() == null &&
                    field.GetCustomAttribute<CIgnoreAttribute>() == null)
                {
                    processedFields.Add(field.Name);
                    CheckTypesHeader(field.FieldType);
                    AppendLine("\t" + TypeConverter.TypeToCName(field.FieldType) + " " + field.Name + ";");
                    anyInstanceMember = true;
                }
            }

            List<Action> addStaticPropActions = new();
            List<Action> addMethodActions = new();

            foreach (var property in type.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
            {
                if (baseProxy?.Fields?.Contains(property.Name) == true)
                    continue;

                if (excludedMembers.Contains(property.Name) ||
                    memberConfig.HasFlag(MemberConfig.IgnoreProperties) ||
                    property.GetCustomAttribute<CIgnoreAttribute>() != null)
                    continue;

                if (property.GetGetMethod() == null)
                    throw new InvalidOperationException("Properties without getters are not allowed.");

                if (property.GetSetMethod() == null || property.GetSetMethod()!.GetCustomAttribute<CompilerGeneratedAttribute>() != null)
                {
                    if (memberConfig.HasFlag(MemberConfig.IgnoreGetterOnlyProperties) && property.GetSetMethod() == null &&
                        property.GetCustomAttribute<CIncludeAttribute>() == null &&
                        type.GetCustomAttributes<CIncludeMemberAttribute>()?.Any(a => a.MemberName == property.Name) != true &&
                        GetType().GetCustomAttributes<CIncludeMemberAttribute>()?.Any(a => a.MemberName == property.Name) != true)
                        continue;

                    if (property.GetGetMethod()!.GetCustomAttribute<CompilerGeneratedAttribute>() != null)
                    {
                        if (property.GetMethod!.IsStatic)
                            addStaticPropActions.Add(() =>
                            {
                                CheckTypesHeader(property.PropertyType);
                                AppendLine("static " + TypeConverter.TypeToCName(property.PropertyType) + " " + type.Name + "_" + property.Name + ";");
                            });
                        else
                        {
                            processedFields.Add(property.Name);
                            CheckTypesHeader(property.PropertyType);
                            AppendLine("\t" + TypeConverter.TypeToCName(property.PropertyType) + " " + property.Name + ";");
                            anyInstanceMember = true;
                        }
                    }
                    else
                    {
                        if (!property.GetMethod!.IsStatic)
                            anyInstanceMember = true;

                        addMethodActions.Add(() => AddMethod("Get_" + property.Name, property.GetMethod!));
                    }
                }
                else
                {
                    if (!property.GetMethod!.IsStatic)
                        anyInstanceMember = true;

                    addMethodActions.Add(() =>
                    {
                        AddMethod("Get_" + property.Name, property.GetMethod!);
                        AddMethod("Set_" + property.Name, property.SetMethod!);
                    });
                }
            }

            AppendLine("};");
            AppendLine();

            if (!anyInstanceMember)
                code.Clear();

            Fields = code.ToString();

            var staticFields = type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static);

            foreach (var field in staticFields)
            {
                if (!excludedMembers.Contains(field.Name) &&
                    field.GetCustomAttribute<CompilerGeneratedAttribute>() == null &&
                    field.GetCustomAttribute<CIgnoreAttribute>() == null)
                {
                    CheckTypesHeader(field.FieldType);
                    AppendLine("static " + TypeConverter.TypeToCName(field.FieldType) + " " + type.Name + "_" + field.Name + ";");
                }
            }

            foreach (var addStaticPropAction in addStaticPropActions)
                addStaticPropAction();

            if (staticFields.Length != 0 || addStaticPropActions.Count != 0)
                AppendLine();

            foreach (var addMethodAction in addMethodActions)
                addMethodAction();

            if (autoAddMethods && !memberConfig.HasFlag(MemberConfig.IgnoreMethods))
            {
                foreach (var method in type.GetMethods(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
                {
                    if (!excludedMembers.Contains(method.Name) &&
                        !method.Name.StartsWith("get_") &&
                        !method.Name.StartsWith("set_") &&
                        method.DeclaringType != typeof(object) &&
                        method.DeclaringType != typeof(IClassProxy) &&
                        method.GetCustomAttribute<CIgnoreAttribute>() == null &&
                        method.GetCustomAttribute<CompilerGeneratedAttribute>() == null)
                        AddMethod(method);
                }
            }

            if (!memberConfig.HasFlag(MemberConfig.IgnoreCtor) && !excludedMembers.Contains(type.Name))
            {
                foreach (var ctor in type.GetConstructors(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static))
                {
                    if ((ctor.IsPublic || ctor.IsAssembly) &&
                        ctor.DeclaringType == typeof(T) &&
                        ctor.GetCustomAttribute<CIgnoreAttribute>() == null)
                        AddMethod($"{type.Name}_Ctor", ctor);
                }
            }
        }

        [CIgnore]
        public void AddMethod(string methodName)
        {
            AddMethod(methodName, type.GetMethod(methodName, BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.Static) ?? throw new MissingMethodException($"Method with name {methodName} not found."));
        }

        [CIgnore]
        public void AddMethod(MethodBase method)
        {
            AddMethod(method.Name, method);
        }

        [CIgnore]
        public void AddMethod(string name, MethodBase method)
        {
            var ccode = method.GetCustomAttribute<CCodeAttribute>()?.Code ??
                type.GetCustomAttributes<CCodeForMethodAttribute>().FirstOrDefault(a => a.MemberName == name || a.MemberName + "_Ctor" == name)?.Code ??
                GetType().GetCustomAttributes<CCodeForMethodAttribute>().FirstOrDefault(a => a.MemberName == name || a.MemberName + "_Ctor" == name)?.Code;

            if (ccode == null)
                throw new InvalidOperationException($"Method {method.Name} needs a CCode attribute to specify the C code.");

            AddMethod(name, method, ccode);
        }

        [CIgnore]
        public void AddMethod(MethodBase method, string cCode)
        {
            AddMethod(method.Name, method, cCode);
        }

        [CIgnore]
        public void AddMethod(string name, MethodBase method, string cCode)
        {
            if (method is MethodInfo && memberConfig.HasFlag(MemberConfig.IgnoreMethods))
                return;

            if (method is ConstructorInfo && memberConfig.HasFlag(MemberConfig.IgnoreCtor))
                return;

            string BuildArgList()
            {
                var args = method.GetParameters();

                foreach (var arg in args)
                    CheckTypesHeader(arg.ParameterType);

                if (method.IsStatic)
                    return string.Join(", ", args.Select(arg => TypeConverter.TypeToCName(arg.ParameterType) + " " + arg.Name));

                string argList = "struct " + type.Name + "* this";

                if (args.Length != 0)
                    argList += ", " + string.Join(", ", args.Select(arg => TypeConverter.TypeToCName(arg.ParameterType) + " " + arg.Name));

                return argList;
            }

            if (method.IsStatic)
            {
                name = type.Name + "_" + name;
                staticFunctionCallReplacements.Add(type.Name + "." + method.Name, name);
            }

            var returnType = method is MethodInfo mi ? mi.ReturnType : typeof(void);
            CheckTypesHeader(returnType);
            AppendLine((method.IsStatic ? "static " : "") + TypeConverter.TypeToCName(returnType) + " " + name + "(" + BuildArgList() + ")");
            AppendLine("{");
            var codeLines = cCode.Replace("\r\n", "\n").Replace('\r', '\n').TrimEnd('\n').Split('\n');
            foreach (var codeLine in codeLines)
                AppendLine("\t" + codeLine);
            AppendLine("}");
            AppendLine();
        }

        [CIgnore]
        public override string ToString() => code.ToString();
    }
}
