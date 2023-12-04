using Lua_Bundler.Interfaces;
using Newtonsoft.Json;

namespace Lua_Bundler.Package
{
    internal class PackageInfo : IPackageInfo
    {
        public string Name { get; }
        public string Version { get; private set; }
        public string Namespace { get; }
        public List<string> RequiredPackages { get; }
        public PackageType Type { get; }

        public string Location { get; }
        public string LocationSourcePath { get; }
        public string LocationOutputPath { get; }

        public string InfoFileSourcePath { get; }
        public string InfoFileOutputPath { get; }

        public PackageInfo(PackageInfoConfig config, string location, string locationPath, string outputLocationPath)
        {
            Name = config.Name ?? location;
            Version = config.Version;
            Namespace = config.Namespace ?? location;
            RequiredPackages = new();
            Type = (PackageType)Enum.Parse(typeof(PackageType), config.PackageType ?? "Library");

            Location = location;
            LocationSourcePath = locationPath;
            LocationOutputPath = outputLocationPath;
            InfoFileSourcePath = Path.Combine(locationPath, "Info.package.json");
            InfoFileOutputPath = Path.Combine(outputLocationPath, "Info.lua");
        }

        public string GetPackageType()
            => Type.ToString();

        public void UpdateBuildNumber()
        {
            string[] splitedVersionString = Version.Split("-");

            double buildNumber = double.Parse(splitedVersionString[1]);
            buildNumber += 1;
            splitedVersionString[1] = buildNumber.ToString();
            Version = string.Join("-", splitedVersionString);
        }

        public void Save()
        {
            var config = new PackageInfoConfig(this);
            var json = JsonConvert.SerializeObject(config, Formatting.Indented);
            var infoFilePath = Path.Combine(LocationSourcePath, "Info.package.json");
            File.WriteAllText(infoFilePath, json);
        }

        public void Check(PackageMap map)
        {
            foreach (var package in RequiredPackages)
            {
                if (!map.PackageExists(package))
                    ErrorWriter.PackageRequireNotFound(package, InfoFileSourcePath);
            }

            RequiredPackages.Sort();
        }

        public void Bundle(BundleOptions options)
        {
            using StreamWriter writer = File.CreateText(InfoFileOutputPath);

            if (options.Optimize)
            {
                writer.Write("return{");
                writer.Write($"Name=\"{Name}\",");
                writer.Write($"Version=\"{Version}\",");
                writer.Write($"Namespace=\"{Namespace}\",");
                writer.Write($"PackageType=\"{Type}\",");

                if (RequiredPackages.Count > 0)
                    writer.Write("RequiredPackages={\"" + string.Join("\",\"", RequiredPackages) + "\"},");

                writer.Write("}");
                return;
            }

            writer.Write("return {\n");
            writer.Write($"    Name = \"{Name}\",\n");
            writer.Write($"    Namespace = \"{Namespace}\",\n");
            writer.Write($"    Version = \"{Version}\",\n");
            writer.Write($"    PackageType = \"{Type}\",\n");

            if (RequiredPackages.Count > 0)
            {
                writer.Write("    RequiredPackages = {\n");
                writer.Write(new string(' ', 8) + "\"" + string.Join($"\",\n{new string(' ', 8)}\"", RequiredPackages) + "\"\n");
                writer.Write("    },\n");
            }

            writer.Write("}\n");
        }
    }

    internal class PackageInfoConfig
    {
        private const string DEFAULT_VERSION = "0.1.0";
        private const string DEFAULT_BUILD_NUMBER = "-1";

        [JsonProperty]
        public string? Name { get; set; }

        [JsonProperty]
        public string? Namespace { get; set; }

        [JsonProperty]
        public string Version { get; set; }

        [JsonProperty]
        public string[] RequiredPackages { get; set; }

        [JsonProperty]
        public string? PackageType { get; set; }

        [JsonConstructor]
        public PackageInfoConfig(string? Name = null, string? Version = null, string? Namespace = null, string[]? RequiredPackages = null, string? packageType = null)
        {
            this.Name = Name;
            this.Namespace = Namespace;
            this.Version = Version ?? DEFAULT_VERSION;
            this.RequiredPackages = RequiredPackages ?? Array.Empty<string>();

            // Check if Version has BuildNumber
            string[] splitedVersionString = this.Version.Split("-");
            if (splitedVersionString.Length < 2)
                this.Version += DEFAULT_BUILD_NUMBER;

            PackageType = packageType;
        }

        public PackageInfoConfig(PackageInfo info)
        {
            Name = info.Name;
            Namespace = info.Namespace;
            Version = info.Version;
            RequiredPackages = info.RequiredPackages.ToArray();
            PackageType = info.Type.ToString();
        }
    }
}
