using Lua_Bundler.Interfaces;
using System.Diagnostics.CodeAnalysis;

namespace Lua_Bundler
{
    internal class PackageMap
    {
        internal IPackageFinder Finder { get; }

        private readonly Dictionary<String, IPackage> _Packages = new();
        private readonly PackageMapPart _RootMapPart = new();
        private readonly Dictionary<String, FileLineInfo> _Classes = new();

        public PackageMap(IPackageFinder finder)
        {
            Finder = finder;
        }

        internal void Map()
        {
            var packages = Finder.FindPackages("");

            foreach (var (_, package) in packages)
            {
                if (TryAddPackage(package))
                    package.Map(this);
                else
                    ErrorWriter.PackageExistsMoreThanOnce(package, GetPackage(package.Location));
            }
        }

        #region - Packages -
        internal Dictionary<String, IPackage> GetPackages()
        {
            return _Packages;
        }

        internal Boolean TryAddPackage(IPackage package) {
            return _Packages.TryAdd(package.Location, package);
        }

        internal IPackage GetPackage(String packageLocation)
        {
            return _Packages[packageLocation];
        }

        internal Boolean TryGetPackage(String packageLocation, [MaybeNullWhen(false)] out IPackage package)
        {
            package = null;

            if (!_Packages.ContainsKey(packageLocation))
                return false;

            package = GetPackage(packageLocation);
            return true;
        }

        internal Boolean TryGetPackageWithNamespace(String packageNamespace,
                                                    [MaybeNullWhen(false)] out IPackage package) {
            package = _Packages.FirstOrDefault(x => x.Value.Namespace == packageNamespace).Value;
            return package is not null;
        }

        internal Boolean PackageExists(String packageLocation)
        {
            return TryGetPackage(packageLocation, out _);
        }
        #endregion

        #region - Modules -
        internal Boolean TryAddModule(IPackageModule module)
        {
            var splitedNamespace = module.Namespace.Split(".");
            return _RootMapPart.TryAddModule(module, splitedNamespace);
        }

        internal void RemoveModule(String moduleNamespace)
        {
            var splitedNamespace = moduleNamespace.Split(".");
            _RootMapPart.RemoveModule(splitedNamespace);
        }

        internal IPackageModule? GetModule(String moduleNamespace)
        {
            var splitedNamespace = moduleNamespace.Split(".");
            return _RootMapPart.GetModule(splitedNamespace);
        }

        internal Boolean TryGetModule(String moduleNamespace, [MaybeNullWhen(false)] out IPackageModule module)
        {
            module = GetModule(moduleNamespace);
            if (module is not null)
                return true;

            return false;
        }

        internal Boolean ModuleExists(String moduleNamespace)
        {
            return GetModule(moduleNamespace) is not null;
        }
        #endregion

        #region - Classes -

        internal Boolean TryAddClass(String className, FileLineInfo info)
        {
            if (_Classes.ContainsKey(className))
                return false;

            _Classes.Add(className, info);
            return true;
        }

        internal FileLineInfo GetClassFileLineInfo(String className)
        {
            return _Classes[className];
        }

        internal Boolean TryGetClassFileLineInfo(String className, [MaybeNullWhen(false)] out FileLineInfo info)
        {
            return _Classes.TryGetValue(className, out info);
        }

        #endregion
    }
}
