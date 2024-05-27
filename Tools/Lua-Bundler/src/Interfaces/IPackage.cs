namespace Lua_Bundler.Interfaces
{
    internal interface IPackage
    {
        public String Name { get; }
        public String Version { get; }
        public String Namespace { get; }
        public List<String> RequiredPackages { get; }
        public String Location { get; }

        public List<IPackageModule> Modules { get; }
        public String LocationPath { get; }


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
