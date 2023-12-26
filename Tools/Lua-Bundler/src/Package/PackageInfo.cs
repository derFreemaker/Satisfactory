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

        public void Bundle(BundleOptions options, IPackage package)
        {
            StreamWriter writer = new(File.OpenWrite(InfoFileOutputPath));

            writer.WriteLine("return {");
            writer.WriteLine($"    Name = \"{Name}\",");
            writer.WriteLine($"    Namespace = \"{Namespace}\",");
            writer.WriteLine($"    Version = \"{Version}\",");
            writer.WriteLine($"    PackageType = \"{Type}\",");

            if (RequiredPackages.Count > 0)
            {
                writer.WriteLine("    RequiredPackages = {");
                writer.WriteLine(new string(' ', 8) + "\"" + string.Join($"\",\r\n{new string(' ', 8)}\"", RequiredPackages) + "\"");
                writer.WriteLine("    },");
            }

            writer.WriteLine("    ModuleIndex={");
            var moduleIndexStr = new string[package.Modules.Count];
            for (int i = 0; i < moduleIndexStr.Length; i++)
            {
                moduleIndexStr[i] = package.Modules[i].BundleInfo(options);
            }
            writer.Write(string.Join("\r\n", moduleIndexStr));
            writer.WriteLine("    },");

            writer.WriteLine("}");

            writer.Flush();
            writer.Close();
            writer.Dispose();
        }
    }
}
