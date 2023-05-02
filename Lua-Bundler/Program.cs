using CommandLine;
using System.Diagnostics;

namespace Lua_Bundler
{
    internal class Program
    {
        static void Main(string[] args)
        {
#if DEBUG
            var test = new[] { "-s", "C:\\Coding\\Lua\\Satisfactory\\src\\Example", "-o", "C:\\Coding\\Lua\\Satisfactory" };
            var config = Parser.Default.ParseArguments<BundlerConfig>(test).Value;
#else
            var config = Parser.Default.ParseArguments<BundlerConfig>(args).Value;
#endif

            var bundler = new Bundler(config.Build());

            Console.WriteLine("building modules map...");
            var stopwatch = Stopwatch.StartNew();
            bundler.Build(true);
            stopwatch.Stop();
            Console.WriteLine($"builded modules map in {stopwatch.Elapsed.TotalMilliseconds}ms");

            Console.WriteLine("\nbundling package...");
            stopwatch = Stopwatch.StartNew();
            bundler.Bundle();
            stopwatch.Stop();
            Console.WriteLine($"bundled package in {stopwatch.Elapsed.TotalMilliseconds}ms");

            Console.WriteLine($"Bundle Data: {bundler.Config.OutputPath}");
        }
    }
}