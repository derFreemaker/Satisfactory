using CommandLine;

namespace Lua_Bundler
{
    internal class BundlerConfig
    {
#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.
        [Option('s', longName: "SourcePath", Required = true, HelpText = "Path to the folder wich contains all files wich should be bundled.")]
        public string SourcePath { get; set; }

        [Option('o', longName: "OutputPath", Required = true, HelpText = "Path to the folder wich the bundled package should be writen.")]
        public string OutputPath { get; set; }

        [Option('i', longName: "InfoFilePath", Required = false, HelpText = "Path to the Info File", Default = @".\Info.json")]
        public string InfoFilePath { get; set; }
        internal bool InfoFileExsits { get; private set; } = true;

        [Option('p', "Optimize", Required = false, HelpText = "Sets if newlines and spaces that are not required to run should be removed", Default = false)]
        public bool Optimize { get; set; }
#pragma warning restore CS8618 // Non-nullable field must contain a non-null value when exiting constructor. Consider declaring as nullable.

        private (bool Success, int ExitCode) Check()
        {
            if (!Directory.Exists(OutputPath))
                return (false, 3461);

            if (!File.Exists(InfoFilePath))
            {
                Console.WriteLine("no info file found");
                InfoFileExsits = false;
            }

            return (true, 0);
        }

        public (bool Success, int ExitCode) Build(out BundlerConfig config)
        {
            if (InfoFilePath == @".\Info.json")
                InfoFilePath = Path.Combine(SourcePath, "Info.json");

            config = this;
            return Check();
        }
    }
}
