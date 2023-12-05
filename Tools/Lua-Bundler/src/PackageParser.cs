using Lua_Bundler.Interfaces;
using Lua_Bundler.Package;

namespace Lua_Bundler
{
    internal static class PackageParser
    {
        internal static IPackage? Parse(PackageInfo info)
        {
            return info.Type switch
            {
                PackageType.Library => new LibraryPackage(info),
                PackageType.Application => new ApplicationPackage(info),
                _ => null
            };
        }
    }
}
