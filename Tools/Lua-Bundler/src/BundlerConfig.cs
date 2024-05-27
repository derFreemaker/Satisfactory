using CommandLine;

namespace Lua_Bundler {
    internal class BundlerConfig {
        internal String SourcePath { get; }
        internal String OutputPath { get; }

        internal String Package { get; }

        internal BundleOptions Options { get; }

        public BundlerConfig(BundlerConfigDataObject config) {
            SourcePath = Path.TrimEndingDirectorySeparator(config.SourcePath);
            OutputPath = Path.TrimEndingDirectorySeparator(config.OutputPath);


            config.Package = config.Package == "*" ? "." : config.Package;
            Package = config.Package;

            Options = new BundleOptions(config);
        }
    }

    public class BundlerConfigDataObject {
        [Option('s', longName: "SourcePath", Required = true,
                HelpText = "Path to the folder which contains the Package that should be bundled.")]
        public required String SourcePath { get; set; }

        [Option('o', longName: "OutputPath",
                HelpText = "Path to the folder which the bundled Package should be saved to.")]
        public String OutputPath { get; set; } = String.Empty;

        [Option('p', longName: "Package", HelpText = "Package Path or Package Folder", Default = "*")]
        public String Package { get; set; } = "*";

        [Option('B', "Bundle", HelpText = "Sets if the packages should be bundled after checking", Default = false)]
        public Boolean Bundle { get; set; } = false;

        [Option("removeComments", HelpText = "Sets if all comments should be removed out of the bundled data.",
                Default = false)]
        public Boolean RemoveComments { get; set; } = false;

        [Option("removeIndents", HelpText = "Sets if all indents should be removed out of the bundled data.",
                Default = false)]
        public Boolean RemoveIndents { get; set; } = false;

        [Option("removeEmptyLines", HelpText = "Sets if all empty lines should be removed out of the bundled data.",
                Default = false)]
        public Boolean RemoveEmptyLines { get; set; } = false;
    }
}