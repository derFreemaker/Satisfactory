using Newtonsoft.Json;

namespace Lua_Bundler.Package
{
    internal class PackageInfoConfig
    {
        private const String DEFAULT_VERSION = "0.1.0";
        private const String DEFAULT_BUILD_NUMBER = "-1";

        [JsonProperty]
        public String? Name { get; set; }

        [JsonProperty]
        public String? Namespace { get; set; }

        [JsonProperty]
        public String Version { get; set; }

        [JsonProperty]
        public String[] RequiredPackages { get; set; }

        [JsonProperty]
        public String? PackageType { get; set; }

        [JsonConstructor]
        public PackageInfoConfig(String? name = null, String? version = null, String? @namespace = null, String[]? requiredPackages = null, String? packageType = null)
        {
            Name = name;
            Namespace = @namespace;
            Version = version ?? DEFAULT_VERSION;
            RequiredPackages = requiredPackages ?? Array.Empty<String>();

            // Check if Version has BuildNumber
            var splitedVersionString = Version.Split("-");
            if (splitedVersionString.Length < 2)
                Version += DEFAULT_BUILD_NUMBER;

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
