using CommandLine;
using DocUpdater;

ParserResult<Config> parseResult = Parser.Default.ParseArguments<Config>(args);
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
var config = parseResult.Value;

// #-------------------------# //
// #   I am sorry for this   # //
// #-------------------------# //

(string Name, List<string> Comments) @class = new(string.Empty, []);
var functions = new List<Function>();

var comments = new List<string>();
var parameters = new List<FuncParameter>();
var returns = new List<FuncParameter>();

var lines = File.ReadAllLines(config.SourceFilePath);
foreach (var line in lines)
{
    if (ParseFunctions.IsComment(line, out var comment))
    {
        if (ParseFunctions.IsParameter(comment, out var parameter))
        {
            parameters.Add(parameter);
        }
        else if (ParseFunctions.IsReturn(comment, out var @return))
        {
            returns.Add(@return);
        }
        else if (ParseFunctions.IsClass(comment, out var name))
        {
            @class = (name, comments);
        }
        else
        {
            comments.Add(comment);
        }
    }
    else if (ParseFunctions.IsFunction(line, out var data))
    {
        var funcArgs = data.argNames.ToList();
        var funcParameters = new Dictionary<string, FuncParameter>();

        foreach (var funcArg in parameters)
        {
            if (!funcArgs.Contains(funcArg.Name))
                parameters.Remove(funcArg);
        }

        foreach (var funcArg in data.argNames)
        {
            var parameter = parameters.FirstOrDefault(x => x.Name == funcArg);
            parameter ??= new()
            {
                Name = funcArg,
                Type = "unkown"
            };

            funcParameters.Add(funcArg, parameter);
        }

        var func = new Function()
        {
            Name = data.Name,
            Parameters = parameters,
            Returns = returns,
            Comments = comments
        };
        functions.Add(func);

        comments = [];
        parameters = [];
        returns = [];
    }
    else
    {
        comments = [];
        parameters = [];
        returns = [];
    }
}


if (File.Exists(config.OutputFilePath))
    File.Delete(config.OutputFilePath);

using var fileStream = File.OpenWrite(config.OutputFilePath);
using var writer = new StreamWriter(fileStream);

writer.WriteLine("---");
writer.WriteLine($"title: {@class.Name}");
writer.WriteLine($"date: \"{DateTime.UtcNow:yyyy-MM-dd}\"");
writer.WriteLine("---");
writer.WriteLine();
writer.WriteLine($"# {@class.Name}");
writer.WriteLine($"{string.Join("\n", @class.Comments)}");
writer.WriteLine();

foreach (var func in functions)
{
    writer.WriteLine();
    func.ToMarkdown(writer);
}
