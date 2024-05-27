using System.Globalization;
using Lua_Bundler.Interfaces;
using Newtonsoft.Json;
using System.Text;

namespace Lua_Bundler.Package
{
    internal class PackageInfo : IPackageInfo
    {
        public String Name { get; }
        public String Version { get; private set; }
        public String Namespace { get; }
        public List<String> RequiredPackages { get; }
        public PackageType Type { get; }
        
        public String Location { get; }
        public String LocationSourcePath { get; }
        public String LocationOutputPath { get; }

        public String InfoFileSourcePath { get; }
        public String InfoFileOutputPath { get; }

        public PackageInfo(PackageInfoConfig config, String location, String locationPath, String outputLocationPath)
        {
            Name = config.Name ?? location;
            Version = config.Version;
            Namespace = config.Namespace ?? location;
            RequiredPackages = new List<String>();
            Type = (PackageType)Enum.Parse(typeof(PackageType), config.PackageType ?? "Library");

            Location = location;
            LocationSourcePath = locationPath;
            LocationOutputPath = outputLocationPath;
            InfoFileSourcePath = Path.Combine(locationPath, "Info.package.json");
            InfoFileOutputPath = Path.Combine(outputLocationPath, "Info.lua");
        }

        public String GetPackageType()
            => Type.ToString();

        public void UpdateBuildNumber()
        {
            String[] splitVersionString = Version.Split("-");

            var buildNumber = Double.Parse(splitVersionString[1]);
            buildNumber += 1;
            splitVersionString[1] = buildNumber.ToString(CultureInfo.InvariantCulture);
            Version = String.Join("-", splitVersionString);
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
                builder.AppendLine(new String(' ', 8) + "\"" + String.Join($"\",\r\n{new String(' ', 8)}\"", RequiredPackages) + "\"");
                builder.AppendLine("    },");
            }

            builder.AppendLine("    ModuleIndex={");
            var moduleIndexStr = new String[package.Modules.Count];
            for (Int32 i = 0; i < moduleIndexStr.Length; i++)
            {
                moduleIndexStr[i] = package.Modules[i].BundleInfo(options);
            }
            builder.Append(String.Join("\r\n", moduleIndexStr));
            builder.AppendLine("    },");

            builder.AppendLine("}");

            File.WriteAllText(InfoFileOutputPath, builder.ToString());
        }
    }
}
