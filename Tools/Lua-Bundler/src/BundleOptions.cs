namespace Lua_Bundler
{
    internal class BundleOptions
    {
        internal bool Bundle { get; }

        internal bool RemoveComments { get; }

        internal bool RemoveIndents { get; }

        internal bool RemoveEmptyLines { get; }

        public BundleOptions(BundlerConfigDataObject config)
        {
            Bundle = config.Bundle;
            RemoveComments = config.RemoveComments;
            RemoveIndents = config.RemoveIndents;
            RemoveEmptyLines = config.RemoveEmptyLines;
        }
    }
}
