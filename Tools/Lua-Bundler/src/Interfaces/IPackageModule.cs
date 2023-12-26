namespace Lua_Bundler.Interfaces
{
    internal interface IPackageModule
    {
        public string Id { get; }
        public string Location { get; }
        public string Namespace { get; }
        public bool IsRunnable { get; }

        public string LocationPath { get; }
        public IPackage Parent { get; }

        public List<string> RequiringModules { get; }

        public void Map(PackageMap map);
        public void Check(PackageMap map);
        public string BundleInfo(BundleOptions options);
        public string BundleData(BundleOptions options);
    }
}
