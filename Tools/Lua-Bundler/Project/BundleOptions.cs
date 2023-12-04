namespace Lua_Bundler
{
    internal class BundleOptions
    {
        internal bool Bundle { get; }
        internal bool Optimize { get; }

        public BundleOptions(BundlerConfigDataObject config)
        {
            Bundle = config.Bundle;
            Optimize = config.Optimize;
        }
    }
}
