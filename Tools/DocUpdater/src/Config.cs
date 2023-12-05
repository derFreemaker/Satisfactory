using CommandLine;

namespace DocUpdater
{
    public class Config
    {
        [Option('s', longName: "SourceFilePath", HelpText = "The File that should be translated from lua to markdown", Required = true)]
        public string SourceFilePath { get; set; } = string.Empty;

        [Option('o', longName: "OutputFIlePath", HelpText = "The file path the markdown translation should be written to.", Required = true)]
        public string OutputFilePath { get; set; } = string.Empty;
    }
}
