namespace Lua_Bundler.Interfaces
{
    internal interface IPackageInfo
    {
        public String Name { get; }
        public String Version { get; }
        public String Namespace { get; }
        public List<String> RequiredPackages { get; }


        public String Location { get; }

        public String LocationSourcePath { get; }
        public String LocationOutputPath { get; }

        public String InfoFileSourcePath { get; }
        public String InfoFileOutputPath { get; }

        public String GetPackageType();

        public void UpdateBuildNumber();
        public void Save();
        public void Check(PackageMap map, ref CheckResult result);
        public void Bundle(BundleOptions options, IPackage package);
    }
}
