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

        internal void Map()
        {
            _PackageMap.Map();
        }

        internal void Check()
        {
            foreach ((_, var package) in _PackageMap.GetPackages())
                package.Check(_PackageMap);
        }

        internal void Bundle()
        {
            if (!_BundleOptions.Bundle)
                throw new InvalidOperationException("bundle feature got deactivated in config");

            foreach ((_, var package) in _PackageMap.GetPackages())
                package.Bundle(_BundleOptions);
        }

        internal void Run()
        {
            Map();
            Check();

            if (_BundleOptions.Bundle)
                Bundle();
        }
    }
}
