using Lua_Bundler.Interfaces;
using System.Text;

namespace Lua_Bundler.Package
{
    internal class ApplicationPackage : IPackage
    {
        private readonly PackageInfo _Info;
        public List<IPackageModule> Modules { get; private set; } = new();

        public ApplicationPackage(PackageInfo info)
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

        public void Check(PackageMap map)
        {
            foreach (var module in Modules)
                module.Check(map);

            _Info.Check(map);
            _Info.Save();

            foreach (var requiredPackage in _Info.RequiredPackages)
            {
                if (!map.TryGetPackage(requiredPackage, out var package))
                {
                    ErrorWriter.PackageRequireNotFound(requiredPackage, _Info.InfoFileSourcePath);
                    continue;
                }

                if (package.RequiredPackages.Contains(_Info.Location))
                    ErrorWriter.PackageCircularReference(package, this);
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

        public bool BundleData(BundleOptions options)
        {
            var dataFilePath = Path.Combine(_Info.LocationOutputPath, "Data.lua");
            var copyDataFilePath = dataFilePath + ".copy";
            if (File.Exists(dataFilePath))
            {
                if (File.Exists(copyDataFilePath))
                    File.Delete(copyDataFilePath);

                File.Copy(dataFilePath, copyDataFilePath);
            }

            StringBuilder builder = new();

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

                var changed = string.Compare(data, dataCopy, StringComparison.InvariantCulture) != 0;
                return changed;
            }

            return false;
        }

        #region - IPackage -

        string IPackage.Name
            => _Info.Name;
        string IPackage.Version
            => _Info.Version;
        string IPackage.Namespace
            => _Info.Namespace;
        List<string> IPackage.RequiredPackages
            => _Info.RequiredPackages;
        string IPackage.Location
            => _Info.Location;
        string IPackage.LocationPath
            => _Info.LocationSourcePath;

        #endregion
    }
}
