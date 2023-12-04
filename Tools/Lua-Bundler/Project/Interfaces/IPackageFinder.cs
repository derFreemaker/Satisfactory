namespace Lua_Bundler.Interfaces
{
    internal interface IPackageFinder
    {
        public Dictionary<string, IPackage> FindPackages(string location);
        public List<IPackageModule> FindModules(string location, IPackage parent);
    }
}
