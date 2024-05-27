namespace Lua_Bundler.Interfaces
{
    internal interface IPackageFinder
    {
        public Dictionary<String, IPackage> FindPackages(String location);
        public List<IPackageModule> FindModules(String location, IPackage parent);
    }
}
