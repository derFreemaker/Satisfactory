using Lua_Bundler.Interfaces;
using System.Text;

namespace Lua_Bundler.Package
{
    internal class LibraryPackage : IPackage
    {
        private readonly PackageInfo _Info;
        public List<IPackageModule> Modules { get; private set; } = new List<IPackageModule>();

        public LibraryPackage(PackageInfo info)
        {
            _Info = info;
        }

        public IPackageInfo GetInfo()
            => _Info;

        public void Map(PackageMap map)
        {
            Modules = map.Finder.FindModules(_Info.LocationSourcePath, this);

            foreach (var module in Modules)
                module.Map(map);
        }

        public void Check(PackageMap map, ref CheckResult result)
        {
            foreach (var module in Modules)
                module.Check(map, ref result);

            _Info.Check(map, ref result);
            _Info.Save();

            foreach (var requiredPackage in _Info.RequiredPackages)
            {
                if (!map.TryGetPackage(requiredPackage, out var package))
                {
                    ErrorWriter.PackageRequireNotFound(requiredPackage, _Info.InfoFileSourcePath);
                    result.Error();
                    continue;
                }

                if (!package.RequiredPackages.Contains(_Info.Location)) {
                    continue;
                }
                
                ErrorWriter.PackageCircularReference(package, this);
                result.Error();
            }
        }

        /// <inheritdoc/>
        public void Bundle(BundleOptions options)
        {
            if (!Directory.Exists(_Info.LocationOutputPath))
                Directory.CreateDirectory(_Info.LocationOutputPath);

            var changed = BundleData(options);
            if (changed)
            {
                _Info.UpdateBuildNumber();
                _Info.Save();
            }

            _Info.Bundle(options, this);
        }

        public Boolean BundleData(BundleOptions options)
        {
            var dataFilePath = Path.Combine(_Info.LocationOutputPath, "Data.lua");
            var copyDataFilePath = dataFilePath + ".copy";
            if (File.Exists(dataFilePath))
            {
                if (File.Exists(copyDataFilePath))
                    File.Delete(copyDataFilePath);

                File.Copy(dataFilePath, copyDataFilePath);
            }

            var builder = new StringBuilder();

            builder.AppendLine("local Data={");

            foreach (var module in Modules)
            {
                builder.AppendLine($"[\"{module.Id}\"] = [==========[");
                builder.AppendLine(module.BundleData(options));
                builder.AppendLine("]==========],");
            }

            builder.AppendLine("}");
            builder.AppendLine();
            builder.AppendLine("return Data");

            File.WriteAllText(dataFilePath, builder.ToString());

            if (File.Exists(copyDataFilePath))
            {
                var data = File.ReadAllText(dataFilePath);
                var dataCopy = File.ReadAllText(copyDataFilePath);
                File.Delete(copyDataFilePath);

                var changed = String.Compare(data, dataCopy, StringComparison.InvariantCulture) != 0;
                return changed;
            }

            return false;
        }

        #region - IPackage -

        String IPackage.Name
            => _Info.Name;
        String IPackage.Version
            => _Info.Version;
        String IPackage.Namespace
            => _Info.Namespace;
        List<String> IPackage.RequiredPackages
            => _Info.RequiredPackages;
        String IPackage.Location
            => _Info.Location;
        String IPackage.LocationPath
            => _Info.LocationSourcePath;

        #endregion
    }
}
