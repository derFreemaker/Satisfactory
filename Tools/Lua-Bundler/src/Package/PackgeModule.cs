using Lua_Bundler.Interfaces;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;

namespace Lua_Bundler.Package {
    internal partial class PackageModule : IPackageModule {
        public String Id { get; }
        public String Location { get; }
        public String Namespace { get; private set; }
        public Boolean IsRunnable { get; private set; }


        public FileInfo FileInfo { get; }
        public IPackage Parent { get; }

        public List<String> RequiringModules { get; } = new();

        public PackageModule(String directoryLocation, FileInfo info, IPackage parent) {
            var fileStem = Path.GetFileNameWithoutExtension(info.Name);

            var locationDirectory = directoryLocation
                .Replace("\\", ".");

            var namespaceDirectory = directoryLocation
                                     .Replace("\\", ".")
                                     .Replace(parent.Location, parent.Namespace);

            Location = $"{locationDirectory}.{fileStem}";
            Namespace = $"{namespaceDirectory}.{fileStem}";
            IsRunnable = info.Extension == ".lua";

            FileInfo = info;
            Parent = parent;

            Id = Namespace;
        }

        #region - Analyse -

        [GeneratedRegex("---@namespace ([a-zA-Z0-9._]*)")]
        private static partial Regex GetRegexNamespace();

        private void SearchNamespace(String content, PackageMap map) {
            var namespaceRegex = GetRegexNamespace();
            var namespaceMatches = namespaceRegex.Matches(content);

            foreach (var match in namespaceMatches.Cast<Match>()) {
                var group = match.Groups[1];
                var @namespace = group.Value;

                // change Namespace and refresh map
                map.RemoveModule(Namespace);
                Namespace = @namespace;
                if (!map.TryAddModule(this))
                    ErrorWriter.ModuleExistsMoreThanOnce(this);
            }
        }

        [GeneratedRegex("---@isRunnable (true|false)")]
        private static partial Regex GetRegexIsRunnable();

        private void SearchIsRunnable(String content) {
            var isRunnableRegex = GetRegexIsRunnable();
            var isRunnableMatches = isRunnableRegex.Matches(content);

            foreach (var match in isRunnableMatches.Cast<Match>()) {
                var group = match.Groups[1];
                var boolStr = group.Value;

                IsRunnable = Boolean.Parse(boolStr);
            }
        }

        private void AnalyseContent(String content, PackageMap map) {
            SearchNamespace(content, map);
            SearchIsRunnable(content);
        }

        #endregion

        public void Map(PackageMap map) {
            if (!map.TryAddModule(this))
                ErrorWriter.ModuleExistsMoreThanOnce(this);

            var content = File.ReadAllText(FileInfo.FullName);
            AnalyseContent(content, map);
        }

        #region - Check -

        [GeneratedRegex("require(?>\\(| )(?>\\\"|\\')([^\\\"]+?)(?>\\\"|\\')(?>\\)|)")]
        private static partial Regex GetRegexRequireFunction();

        private void CheckRequireFunctions(String content, PackageMap map, ref CheckResult result) {
            var requireRegex = GetRegexRequireFunction();
            var requireMatches = requireRegex.Matches(content).Cast<Match>();

            foreach (var match in requireMatches) {
                var group = match.Groups[1];
                var moduleNamespace = group.Value;

                if (!map.TryGetModule(moduleNamespace, out var module)) {
                    ErrorWriter.ModuleNotFound(moduleNamespace,
                                               (FileInfo.FullName, Utils.GetLine(content, group.Index, group.Length)));
                    result.Error();
                    continue;
                }

                if (module.RequiringModules.Contains(Namespace))
                    ErrorWriter.ModuleCircularReference(this, module);

                if (module.Parent.Location == Parent.Location)
                    continue;

                if (!Parent.RequiredPackages.Contains(module.Parent.Location))
                    Parent.RequiredPackages.Add(module.Parent.Location);

                RequiringModules.Add(moduleNamespace);
            }
        }

        [GeneratedRegex("class\\(\"(.+)\".*?")]
        private static partial Regex GetRegexCreateClass();

        private void CheckCreateClass(String content, PackageMap map, ref CheckResult result) {
            var createClassRegex = GetRegexCreateClass();
            var createClassMatches = createClassRegex.Matches(content);

            foreach (var match in createClassMatches.Cast<Match>()) {
                var classGroup = match.Groups[1];
                var className = classGroup.Value;

                var lineInfo = Utils.GetLine(content, classGroup.Index, classGroup.Length);
                if (map.TryAddClass(className, (FileInfo.FullName, lineInfo)))
                    continue;

                ErrorWriter.ClassExistsMoreThanOnce(className, (FileInfo.FullName, lineInfo),
                                                    map.GetClassFileLineInfo(className));
                result.Error();
            }
        }

        [GeneratedRegex("---@using ([a-zA-Z0-9._]*)")]
        private static partial Regex GetRegexUsing();

        private void CheckUsing(String content, PackageMap map, ref CheckResult result) {
            var usingRegex = GetRegexUsing();
            var usingMatches = usingRegex.Matches(content);

            foreach (var match in usingMatches.Cast<Match>()) {
                var group = match.Groups[1];
                var packageNamespace = group.Value;

                if (!map.TryGetPackageWithNamespace(packageNamespace, out var package)) {
                    ErrorWriter.PackageUsingNotFound(packageNamespace,
                                                     (FileInfo.FullName, Utils.GetLine(content, group.Index, group.Length)));
                    result.Error();
                    continue;
                }

                if (!Parent.RequiredPackages.Contains(package.Location))
                    Parent.RequiredPackages.Add(package.Location);
            }
        }

        [GeneratedRegex(@"(\]==========\])")]
        private static partial Regex GetRegexMultiLineStringWithLevel10();

        private void CheckMultiLineStringWithLevel10(String content, ref CheckResult result) {
            var multiLineStringWithLevel10Regex = GetRegexMultiLineStringWithLevel10();
            var multiLineStringWithLevel10Matches = multiLineStringWithLevel10Regex.Matches(content);

            foreach (var match in multiLineStringWithLevel10Matches.Cast<Match>()) {
                var group = match.Groups[1];
                ErrorWriter.ModuleMultiLineStringWithLevel10Found((FileInfo.FullName,
                                                                   Utils.GetLine(content, group.Index, group.Length)));
                result.Error();
            }
        }

        private void CheckContent(String content, PackageMap map, ref CheckResult result) {
            CheckMultiLineStringWithLevel10(content, ref result);

            if (IsRunnable) {
                CheckRequireFunctions(content, map, ref result);
                CheckCreateClass(content, map, ref result);
            }

            CheckUsing(content, map, ref result);
        }

        #endregion

        public void Check(PackageMap map, ref CheckResult result) {
            var content = File.ReadAllText(FileInfo.FullName);
            CheckContent(content, map, ref result);
        }

        #region - Modify -

        private static void RemoveComments(Span<String> lines) {
            for (Int32 i = 0; i < lines.Length; i++) {
                String line = lines[i];
                Int32 foundComment = line.IndexOf("--", StringComparison.InvariantCulture);
                if (foundComment == -1) {
                    continue;
                }

                lines[i] = line[..foundComment];
            }
        }

        private static void RemoveIndents(Span<String> lines) {
            for (Int32 i = 0; i < lines.Length; i++) {
                String line = lines[i];
                lines[i] = line.Replace("  ", "");
            }
        }

        private static Span<String> RemoveEmptyLines(Span<String> lines) {
            var newLines = new List<String>();
            foreach (var line in lines) {
                if (line.Length == 0) {
                    continue;
                }

                newLines.Add(line.TrimEnd());
            }

            return CollectionsMarshal.AsSpan(newLines);
        }

        private static Span<String> ModifyContent(Span<String> content, BundleOptions options) {
            if (options.RemoveComments) {
                RemoveComments(content);
            }

            if (options.RemoveIndents) {
                RemoveIndents(content);
            }

            if (options.RemoveEmptyLines) {
                content = RemoveEmptyLines(content);
            }

            return content;
        }

        #endregion

        public String BundleInfo(BundleOptions options) {
            var builder = new StringBuilder();

            builder.Append($"        [\"{Id}\"] = {{\n");
            builder.Append($"            Location = \"{Location}\",\n");
            builder.Append($"            Namespace = \"{Namespace}\",\n");
            builder.Append($"            IsRunnable = {IsRunnable.ToString().ToLower()},\n");
            builder.Append($"        }},\n");

            return builder.ToString();
        }

        public String BundleData(BundleOptions options) {
            var content = File.ReadAllLines(FileInfo.FullName).AsSpan();
            content = ModifyContent(content, options);
            var builder = new StringBuilder();

            foreach (var line in content) {
                builder.Append(line + "\n");
            }

            return builder.ToString();
        }
    }
}