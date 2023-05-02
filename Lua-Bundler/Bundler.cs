namespace Lua_Bundler
{
    internal class Bundler
    {
        public BundlerConfig Config { get; }
        public BundlePart RootBundlePart { get; }

        public Bundler(BundlerConfig config)
        {
            if (!Directory.Exists(config.SourcePath)) throw new DirectoryNotFoundException($"Could not find Directory: '{config.SourcePath}'");
            RootBundlePart = new BundlePart(Utils.GenerateStringId(), config.SourcePath, null, true);
            Config = config;
        }

        public void Build(bool buildAllChilds = false)
        {
            RootBundlePart.BuildChilds(buildAllChilds);
        }

        private void BundleInfoFile()
        {
            //TODO: deserialize Json and make Lua out of it
        }

        private void BundleDataFile()
        {
            var dataFilePath = Path.Combine(Config.OutputPath, "Data.lua");

            var writer = File.CreateText(dataFilePath);

            writer.WriteLine("local PackageData = {}");
            RootBundlePart.BundleData(writer);
            writer.WriteLine("return PackageData");
            writer.Flush();
            writer.Close();
        }

        public void Bundle()
        {
            Directory.CreateDirectory(Config.OutputPath);
            BundleInfoFile();
            BundleDataFile();
        }
    }
}
