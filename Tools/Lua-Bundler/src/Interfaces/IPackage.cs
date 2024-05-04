namespace Lua_Bundler.Interfaces
{
    internal interface IPackage
    {
        public string Name { get; }
        public string Version { get; }
        public string Namespace { get; }
        public List<string> RequiredPackages { get; }
        public string Location { get; }

        public List<IPackageModule> Modules { get; }
        public string LocationPath { get; }


        public IPackageInfo GetInfo();

        public void Map(PackageMap map);
        
        public void Check(PackageMap map, ref CheckResult result);

        /// <summary>
        /// </summary>
        /// <param name="options"></param>
        /// <returns>True if output data changed</returns>
        public void Bundle(BundleOptions options);
    }
}
