using Newtonsoft.Json;

namespace Lua_Bundler
{
    public class InfoConfig
    {
        [JsonProperty]
        public string Name { get; internal set; }

        [JsonProperty]
        public string[]? RequiredPackages { get; internal set; }

        [JsonProperty]
        public string? Namespace { get; internal set; }

        [JsonConstructor]
        public InfoConfig(string Name, string[]? RequiredPackages, string? Namespace)
        {
            this.Name = Name;
            this.RequiredPackages = RequiredPackages;
            this.Namespace = Namespace;
        }

        internal InfoConfig(BundlerConfig config)
        {
            var folderName = config.SourcePath.Split("\\")[^1];
            Name = folderName;
        }

        internal static InfoConfig GetInfoConfig(BundlerConfig config)
        {
            if (!config.InfoFileExsits)
                return new InfoConfig(config);

            var content = File.ReadAllText(config.InfoFilePath);
            var infoConfig = JsonConvert.DeserializeObject<InfoConfig>(content);

            return infoConfig ?? new InfoConfig(config);
        }
    }
}
