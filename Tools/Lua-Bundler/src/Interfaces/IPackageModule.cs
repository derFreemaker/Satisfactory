namespace Lua_Bundler.Interfaces
{
    internal interface IPackageModule
    {
        public String Id { get; }
        public String Location { get; }
        public String Namespace { get; }
        public Boolean IsRunnable { get; }

        public FileInfo FileInfo { get; }
        public IPackage Parent { get; }

        public List<String> RequiringModules { get; }

        public void Map(PackageMap map);
        public void Check(PackageMap map, ref CheckResult result);
        public String BundleInfo(BundleOptions options);
        public String BundleData(BundleOptions options);
    }
}
