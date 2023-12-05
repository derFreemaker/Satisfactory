using Lua_Bundler.Interfaces;
using System.Diagnostics.CodeAnalysis;

namespace Lua_Bundler
{
    internal class PackageMap
    {
        internal BundlerConfig Config { get; }
        internal IPackageFinder Finder { get; }

        private readonly Dictionary<string, IPackage> _Packages = new();
        private readonly PackageMapPart _RootMapPart = new();
        private readonly Dictionary<string, FileLineInfo> _Classes = new();

        public PackageMap(BundlerConfig config, IPackageFinder finder)
        {
            Config = config;
            Finder = finder;
        }

        internal void Map()
        {
            var packages = Finder.FindPackages("");

            foreach ((_, var package) in packages)
            {
                if (TryAddPackage(package))
                    package.Map(this);
                else
                    ErrorWriter.PackageExistsMoreThanOnce(package, GetPackage(package.Namespace)!);
            }
        }

        #region - Packages -
        internal Dictionary<string, IPackage> GetPackages()
        {
            return _Packages;
        }

        internal bool TryAddPackage(IPackage package)
        {
            if (_Packages.ContainsKey(package.Namespace))
                return false;

            _Packages.Add(package.Namespace, package);
            return true;
        }

        internal IPackage? GetPackage(string packageNamespace)
        {
            return _Packages[packageNamespace];
        }

        internal bool TryGetPackage(string packageNamespace, [MaybeNullWhen(false)] out IPackage package)
        {
            package = null;

            if (!_Packages.ContainsKey(packageNamespace))
                return false;

            package = GetPackage(packageNamespace)!;
            return true;
        }

        internal bool PackageExists(string packageNamespace)
        {
            return TryGetPackage(packageNamespace, out _);
        }
        #endregion

        #region - Modules -
        internal bool TryAddModule(IPackageModule module)
        {
            var splitedNamespace = module.Namespace.Split(".");
            return _RootMapPart.TryAddModule(module, splitedNamespace);
        }

        internal void RemoveModule(string moduleNamespace)
        {
            var splitedNamespace = moduleNamespace.Split(".");
            _RootMapPart.RemoveModule(splitedNamespace);
        }

        internal IPackageModule? GetModule(string moduleNamespace)
        {
            var splitedNamespace = moduleNamespace.Split(".");
            return _RootMapPart.GetModule(splitedNamespace);
        }

        internal bool TryGetModule(string moduleNamespace, [MaybeNullWhen(false)] out IPackageModule module)
        {
            module = GetModule(moduleNamespace);
            if (module is not null)
                return true;

            return false;
        }

        internal bool ModuleExists(string moduleNamespace)
        {
            return GetModule(moduleNamespace) is not null;
        }
        #endregion

        #region - Classes -

        internal bool TryAddClass(string className, FileLineInfo info)
        {
            if (_Classes.ContainsKey(className))
                return false;

            _Classes.Add(className, info);
            return true;
        }

        internal FileLineInfo? GetClassFileLineInfo(string className)
        {
            return _Classes[className];
        }

        internal bool TryGetClassFileLineInfo(string className, [MaybeNullWhen(false)] out FileLineInfo info)
        {
            info = null;

            if (!_Classes.ContainsKey(className))
                return false;

            info = _Classes[className];
            return true;
        }

        #endregion
    }
}
