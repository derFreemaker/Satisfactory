using CommandLine;

namespace Lua_Bundler
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            ParserResult<BundlerConfigDataObject> parseResult = Parser.Default.ParseArguments<BundlerConfigDataObject>(args);
            if (parseResult.Tag == ParserResultType.NotParsed)
            {
                Console.WriteLine("Unable to parse Bundler settings: ");

                foreach (Error? error in parseResult.Errors)
                {
                    Console.Write(error.Tag);

                    if (error is NamedError namedError)
                        Console.WriteLine(" -> " + namedError.NameInfo);
                    else if (error is TokenError tokenError)
                        Console.WriteLine(" -> " + tokenError.Token);
                }

                Environment.Exit(0);
            }
            var config = new BundlerConfig(parseResult.Value);

            var finder = new PackageFinder(config);

            var bundler = new Bundler(config, finder);

            bundler.Run();
        }
    }
}
