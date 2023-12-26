using CommandLine;

namespace Lua_Bundler
{
    internal class BundlerConfig
    {
        internal string SourcePath { get; }
        internal string OutputPath { get; }

        internal string Package { get; }

        internal BundleOptions Options { get; }

        public BundlerConfig(BundlerConfigDataObject config)
        {
            SourcePath = config.SourcePath;
            OutputPath = config.OutputPath;


            config.Package = config.Package == "*" ? "." : config.Package;
            Package = config.Package;

            Options = new BundleOptions(config);
        }
    }

    public class BundlerConfigDataObject
    {
        [Option('s', longName: "SourcePath", Required = true, HelpText = "Path to the folder which contains the Package that should be bundled.")]
        public required string SourcePath { get; set; }

        [Option('o', longName: "OutputPath", Required = true, HelpText = "Path to the folder which the bundled Package should be saved to.")]
        public required string OutputPath { get; set; }

        [Option('p', longName: "Package", HelpText = "Package Path or Package Folder", Default = "*")]
        public string Package { get; set; } = "*";

        [Option('B', "Bundle", HelpText = "Sets if the packages should be bundled after checking", Default = false)]
        public bool Bundle { get; set; } = false;

        [Option("removeComments", HelpText = "Sets if all comments should be removed out of the bundled data.", Default = false)]
        public bool RemoveComments { get; set; } = false;

        [Option("removeIndents", HelpText = "Sets if all indents should be removed out of the bundled data.", Default = false)]
        public bool RemoveIndents { get; set; } = false;

        [Option("removeEmptyLines", HelpText = "Sets if all empty lines should be removed out of the bundled data.", Default = false)]
        public bool RemoveEmptyLines { get; set; } = false;
    }
}
