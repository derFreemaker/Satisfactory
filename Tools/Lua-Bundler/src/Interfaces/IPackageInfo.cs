namespace Lua_Bundler.Interfaces
{
    internal interface IPackageInfo
    {
        public string Name { get; }
        public string Version { get; }
        public string Namespace { get; }
        public List<string> RequiredPackages { get; }


        public string Location { get; }

        public string LocationSourcePath { get; }
        public string LocationOutputPath { get; }

        public string InfoFileSourcePath { get; }
        public string InfoFileOutputPath { get; }

        public string GetPackageType();

        public void UpdateBuildNumber();
        public void Save();
        public void Check(PackageMap map);
        public void Bundle(BundleOptions options, IPackage package);
    }
}
