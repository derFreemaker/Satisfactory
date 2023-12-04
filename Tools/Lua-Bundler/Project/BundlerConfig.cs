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

        [Option('O', "Optimize", HelpText = "Sets if newlines and spaces that are not required to run should be removed", Default = false)]
        public bool Optimize { get; set; } = false;

        [Option('B', "Bundle", HelpText = "Sets if the packages should be bundled after checking", Default = false)]
        public bool Bundle { get; set; } = false;
    }
}
