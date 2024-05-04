using System.Globalization;
using Lua_Bundler.Interfaces;
using Newtonsoft.Json;
using System.Text;

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
            RequiredPackages = new List<string>();
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
            string[] splitVersionString = Version.Split("-");

            double buildNumber = double.Parse(splitVersionString[1]);
            buildNumber += 1;
            splitVersionString[1] = buildNumber.ToString(CultureInfo.InvariantCulture);
            Version = string.Join("-", splitVersionString);
        }

        public void Save()
        {
            var config = new PackageInfoConfig(this);
            var json = JsonConvert.SerializeObject(config, Formatting.Indented);
            var infoFilePath = Path.Combine(LocationSourcePath, "Info.package.json");
            File.WriteAllText(infoFilePath, json);
        }

        public void Check(PackageMap map, ref CheckResult result) {
            foreach (var package in RequiredPackages) {
                if (map.PackageExists(package)) {
                    continue;
                }
                
                ErrorWriter.PackageRequireNotFound(package, InfoFileSourcePath);
                result.Error();
            }

            RequiredPackages.Sort();
        }

        public void Bundle(BundleOptions options, IPackage package)
        {
            StringBuilder builder = new();

            builder.AppendLine("return {");
            builder.AppendLine($"    Name = \"{Name}\",");
            builder.AppendLine($"    Namespace = \"{Namespace}\",");
            builder.AppendLine($"    Version = \"{Version}\",");
            builder.AppendLine($"    PackageType = \"{Type}\",");

            if (RequiredPackages.Count > 0)
            {
                builder.AppendLine("    RequiredPackages = {");
                builder.AppendLine(new string(' ', 8) + "\"" + string.Join($"\",\r\n{new string(' ', 8)}\"", RequiredPackages) + "\"");
                builder.AppendLine("    },");
            }

            builder.AppendLine("    ModuleIndex={");
            var moduleIndexStr = new string[package.Modules.Count];
            for (int i = 0; i < moduleIndexStr.Length; i++)
            {
                moduleIndexStr[i] = package.Modules[i].BundleInfo(options);
            }
            builder.Append(string.Join("\r\n", moduleIndexStr));
            builder.AppendLine("    },");

            builder.AppendLine("}");

            File.WriteAllText(InfoFileOutputPath, builder.ToString());
        }
    }
}
