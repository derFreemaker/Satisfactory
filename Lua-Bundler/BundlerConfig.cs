using CommandLine;

namespace Lua_Bundler
{
    internal class BundlerConfig
    {
        [Option('s', longName: "SourcePath", Required = true, HelpText = "Path to the folder wich contains all files wich should be bundled.")]
        public string SourcePath { get; set; } = string.Empty;

        [Option('o', longName: "OutputPath", Required = false, HelpText = "Path to the folder wich the bundled package should be writen.")]
        public string OutputPath { get; set; } = string.Empty;

        [Option('i', longName: "InfoFilePath", Required = false, HelpText = "Path to the Info File", Default = @".\Info.json")]
        public string InfoFilePath { get; set; } = string.Empty;

        //TODO: an option to optimize space usage to remove all newlines and space that are not needed

        public BundlerConfig Build()
        {
            if (OutputPath != string.Empty)
            {
                var splitedPath = SourcePath.Split("\\");
                var directoryName = splitedPath[splitedPath.Length - 1] ?? "Package";
                OutputPath = Path.Combine(OutputPath, directoryName);
            }
            else
                OutputPath = Path.Combine(SourcePath, "%bin%");
            
            if (InfoFilePath == @".\Info.json")
                InfoFilePath = Path.Combine(SourcePath, "Info.json");

            if (!File.Exists(InfoFilePath))
            {
                Console.WriteLine("No Info File found!");
                Environment.Exit(1247);
            }

            return this;
        }
    }
}
