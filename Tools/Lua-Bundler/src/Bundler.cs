using Lua_Bundler.Interfaces;

namespace Lua_Bundler
{
    internal class Bundler
    {
        private readonly PackageMap _PackageMap;

        private readonly BundleOptions _BundleOptions;

        public Bundler(BundlerConfig config, IPackageFinder packageFinder)
        {
            _PackageMap = new PackageMap(config, packageFinder);
            _BundleOptions = config.Options;
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
            if (!_BundleOptions.Bundle)
                throw new InvalidOperationException("bundle feature got deactivated in config");

            foreach (var (_, package) in _PackageMap.GetPackages())
                package.Bundle(_BundleOptions);
        }

        internal int Run()
        {
            Map();
            var result = Check();

            if (result.HasError) {
                Console.WriteLine("Check failed. Exiting...");
                return 1;
            }
            
            if (_BundleOptions.Bundle)
                Bundle();

            return 0;
        }
    }
}
