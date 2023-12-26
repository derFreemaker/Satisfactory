using Newtonsoft.Json;

namespace Lua_Bundler.Package
{
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
