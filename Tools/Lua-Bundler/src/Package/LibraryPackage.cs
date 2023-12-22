using Lua_Bundler.Interfaces;
using System.Collections.Specialized;

namespace Lua_Bundler.Package
{
    internal class LibraryPackage : IPackage
    {
        private readonly PackageInfo Info;
        public List<IPackageModule> Modules { get; private set; } = new();

        public LibraryPackage(PackageInfo info)
        {
            Info = info;
        }

        public IPackageInfo GetInfo()
            => Info;

        public void Map(PackageMap map)
        {
            Modules = map.Finder.FindModules(Info.LocationSourcePath, this);

            foreach (var module in Modules)
                module.Map(map);
        }

        public void Check(PackageMap map)
        {
            foreach (var module in Modules)
                module.Check(map);

            Info.Check(map);
            Info.Save();

            foreach (var requiredPackge in Info.RequiredPackages)
            {
                if (!map.TryGetPackage(requiredPackge, out var package))
                {
                    ErrorWriter.PackageRequireNotFound(requiredPackge, Info.InfoFileSourcePath);
                    continue;
                }

                if (package.RequiredPackages.Contains(Info.Location))
                    ErrorWriter.PackageCircularReference(package, this);
            }
        }

        /// <inheritdoc/>
        public void Bundle(BundleOptions options)
        {
            if (!Directory.Exists(Info.LocationOutputPath))
                Directory.CreateDirectory(Info.LocationOutputPath);

            var changed = BundleData(options);
            if (changed)
            {
                Info.UpdateBuildNumber();
                Info.Save();
            }

            Info.Bundle(options, this);
        }

        /// <inheritdoc/>
        public bool BundleData(BundleOptions options)
        {
            var dataFilePath = Path.Combine(Info.LocationOutputPath, "Data.txt");
            var copyDataFilePath = dataFilePath + ".copy";
            if (File.Exists(dataFilePath))
            {
                if (File.Exists(copyDataFilePath))
                    File.Delete(copyDataFilePath);

                File.Copy(dataFilePath, copyDataFilePath);
            }

            var writer = File.CreateText(dataFilePath);
            writer.NewLine = "\n";
            int count = 0;

            if (options.Optimize)
            {
                foreach (var module in Modules)
                {
                    writer.Write(module.BundleData(options, ref count));
                }
            }
            else
            {
                foreach (var module in Modules)
                {
                    var text = $"-- Module: {module.Namespace} From: {module.Location} --\n";
                    writer.WriteLine(text);
                    count += text.Length + 1;

                    writer.WriteLine(module.BundleData(options, ref count));
                    count++;
                }
            }

            writer.Dispose();

            if (File.Exists(copyDataFilePath))
            {
                var data = File.ReadAllText(dataFilePath);
                var dataCopy = File.ReadAllText(copyDataFilePath);
                File.Delete(copyDataFilePath);

                var changed = data.CompareTo(dataCopy) != 0;
                return changed;
            }

            return false;
        }

        #region - IPackage -

        string IPackage.Name
            => Info.Name;
        string IPackage.Version
            => Info.Version;
        string IPackage.Namespace
            => Info.Namespace;
        List<string> IPackage.RequiredPackages
            => Info.RequiredPackages;
        string IPackage.Location
            => Info.Location;
        string IPackage.LocationPath
            => Info.LocationSourcePath;

        #endregion
    }
}
