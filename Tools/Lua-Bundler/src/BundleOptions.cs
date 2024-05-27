namespace Lua_Bundler
{
    internal class BundleOptions
    {
        internal Boolean Bundle { get; }

        internal Boolean RemoveComments { get; }

        internal Boolean RemoveIndents { get; }

        internal Boolean RemoveEmptyLines { get; }

        public BundleOptions(BundlerConfigDataObject config)
        {
            Bundle = config.Bundle;
            RemoveComments = config.RemoveComments;
            RemoveIndents = config.RemoveIndents;
            RemoveEmptyLines = config.RemoveEmptyLines;
        }
    }
}
