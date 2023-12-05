using Lua_Bundler.Interfaces;
using Lua_Bundler.Package;
using Newtonsoft.Json;
using System.Diagnostics.CodeAnalysis;

namespace Lua_Bundler
{
    internal class PackageFinder : IPackageFinder
    {
        private readonly BundlerConfig _Config;

        public PackageFinder(BundlerConfig config)
        {
            _Config = config;
        }

        private bool TryFindPackage(string location, [MaybeNullWhen(false)] out IPackage package)
        {
            package = default;

            var packageSourcePath = Path.Combine(_Config.SourcePath, location);
            var infoFilePath = Path.Combine(packageSourcePath, "Info.package.json");

            if (!File.Exists(infoFilePath))
                return false;

            var infoFileContent = File.ReadAllText(infoFilePath);
            var infoConfig = JsonConvert.DeserializeObject<PackageInfoConfig>(infoFileContent)
                                ?? new PackageInfoConfig();

            var packageOutputPath = Path.Combine(_Config.OutputPath, location);            
            var info = new PackageInfo(infoConfig, location.Replace("\\", "."), packageSourcePath, packageOutputPath);

            package = PackageParser.Parse(info);
            if (package is null)
            {
                ErrorWriter.PackageUnknownType(info);
                return false;
            }                

            return true;
        }

        public Dictionary<string, IPackage> FindPackages(string location)
        {
            var packages = new Dictionary<string, IPackage>();

            if (TryFindPackage(location, out var package))
            {
                packages.Add(package.LocationPath.Replace(_Config.SourcePath + "\\", "").Replace("\\", "."), package);
                return packages;
            }

            // didn't find a package in this directory
            // searching for packages in sub directories
            var path = Path.Combine(_Config.SourcePath, location);
            var directories = Directory.GetDirectories(path, "*", SearchOption.TopDirectoryOnly).ToList();
            directories.Sort();
            foreach (var directoryPath in directories)
            {
                string directory = Path.Combine(location, directoryPath.Split("\\")[^1]);
                var foundPackages = FindPackages(directory);
                foreach (var foundPackage in foundPackages)
                    packages.Add(foundPackage.Key, foundPackage.Value);
            }
            return packages;
        }

        public List<IPackageModule> FindModules(string locationPath, IPackage parent)
        {
            var modules = new List<IPackageModule>();

            var files = Directory.GetFiles(locationPath, "*", SearchOption.TopDirectoryOnly).ToList();
            files.Sort();
            foreach (var filePath in files)
            {
                var file = new FileInfo(filePath);

                if (file.Name == "Info.package.json")
                    continue;

                var package = new PackageModule(locationPath.Replace(_Config.SourcePath + "\\", "").Replace("\\", "."), file, parent);
                modules.Add(package);
            }

            var directories = Directory.GetDirectories(locationPath, "*", SearchOption.TopDirectoryOnly).ToList();
            directories.Sort();
            foreach (var directory in directories)
            {
                //var directoryName = directory.Split("\\")[^1];
                var modulesInDirectory = FindModules(directory, parent);
                foreach (var module in modulesInDirectory)
                    modules.Add(module);
            }

            return modules;
        }
    }
}
