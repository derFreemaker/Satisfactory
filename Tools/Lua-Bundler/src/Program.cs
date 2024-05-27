using CommandLine;

namespace Lua_Bundler;

internal class Program {
#if DEBUG
    private static Int32 Main() {
        var parseResult = Parser.Default.ParseArguments<BundlerConfigDataObject>(["--SourcePath", @"C:\Coding\Games\Satisfactory\FIN\FiGiL\src"]);
#else
    private static Int32 Main(String[] args) {
            var parseResult = Parser.Default.ParseArguments<BundlerConfigDataObject>(args);
            if (parseResult.Tag == ParserResultType.NotParsed)
            {
                Environment.Exit(1);
            }
#endif
        
        var config = new BundlerConfig(parseResult.Value);
        
        var finder = new PackageFinder(config);

        var bundler = new Bundler(config, finder);
        
        return bundler.Run();
    }
}