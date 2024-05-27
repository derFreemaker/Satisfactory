using Lua_Bundler.Interfaces;

namespace Lua_Bundler
{
    internal class Bundler
    {
        private readonly PackageMap _PackageMap;

        private readonly BundlerConfig _Config;

        public Bundler(BundlerConfig config, IPackageFinder packageFinder)
        {
            _PackageMap = new PackageMap(packageFinder);
            _Config = config;
        }

        private void Map()
        {
            _PackageMap.Map();
        }

        private CheckResult Check()
        {
            var result = new CheckResult();
            
            foreach (var (_, package) in _PackageMap.GetPackages())
                package.Check(_PackageMap, ref result);

            return result;
        }

        private void Bundle()
        {
            if (!_Config.Options.Bundle)
                throw new InvalidOperationException("bundle feature got deactivated in config");

            foreach (var (_, package) in _PackageMap.GetPackages())
                package.Bundle(_Config.Options);
        }

        internal Int32 Run()
        {
            Map();
            var result = Check();

            if (result.HasError) {
                Console.WriteLine("errors found");
                return 1;
            }

            if (_Config.Options.Bundle) {
                if (_Config.OutputPath == String.Empty) {
                    Console.WriteLine("Cannot bundle with out an output path.");
                    return 1;
                }
                
                Bundle();
            }

            return 0;
        }
    }
}
