namespace Lua_Bundler
{
    internal class Bundler
    {
        public BundlerConfig Config { get; }
        public InfoConfig InfoConfig { get; private set; }
        public BundlePart RootBundlePart { get; private set; }

        public Bundler(BundlerConfig config)
        {
            if (!Directory.Exists(config.SourcePath)) throw new DirectoryNotFoundException($"Could not find Directory: '{config.SourcePath}'");
            Config = config;

            InfoConfig = InfoConfig.GetInfoConfig(Config);

            RootBundlePart = new BundlePart(Utils.GenerateStringId(), Config.SourcePath, InfoConfig.Namespace, true);

            Config.OutputPath = Path.Combine(Config.OutputPath, InfoConfig.Name);
        }

        public void Build(bool buildAllChilds = false)
        {
            RootBundlePart.BuildChilds(buildAllChilds);
        }

        private bool BundleInfoFile()
        {
            //TODO: deserialize Json and make Lua out of it

            var writer = File.CreateText(Path.Combine(Config.OutputPath, "Info.lua"));

            if (Config.Optimize)
            {
                writer.Write("return {");
                writer.Write($" Name = \"{InfoConfig.Name}\", ");
                writer.Write($" Namespace = \"{RootBundlePart.Namespace}\"");

                if (InfoConfig.RequiredPackages is not null)
                    writer.Write(", RequiredPackages = { \"" + string.Join("\", \"", InfoConfig.RequiredPackages) + "\" }");

                writer.Write(" }");
            }
            else
            {
                writer.WriteLine("return {");
                writer.WriteLine($"    Name = \"{InfoConfig.Name}\",");
                writer.Write($"    Namespace = \"{RootBundlePart.Namespace}\"");

                if (InfoConfig.RequiredPackages is not null)
                {
                    writer.WriteLine("\n,    RequiredPackages = {");
                    writer.WriteLine(new string(' ', 8) + "\"" + string.Join($"\",\n{new string(' ', 8)}\"", InfoConfig.RequiredPackages) + "\"");
                    writer.Write("    }");
                }

                writer.WriteLine("\n}");
            }

            writer.Flush();
            writer.Close();
            return true;
        }

        private bool BundleDataFile()
        {
            var dataFilePath = Path.Combine(Config.OutputPath, "Data.lua");
            var writer = File.CreateText(dataFilePath);

            if (Config.Optimize)
            {
                writer.Write("local PackageData = {} ");
                RootBundlePart.BundleData(writer, Config);
                writer.Write(" return PackageData");
            }
            else
            {
                writer.WriteLine("local PackageData = {}");
                RootBundlePart.BundleData(writer, Config);
                writer.WriteLine("\nreturn PackageData");
            }

            writer.Flush();
            writer.Close();
            return true;
        }

        public bool Bundle()
        {
            Directory.CreateDirectory(Config.OutputPath);

            if (!BundleInfoFile())
                return false;
            if (!BundleDataFile())
                return false;

            return true;
        }
    }
}
