using System.Text;

namespace DocUpdater
{
    internal class Function
    {
        public required string Name { get; init; }
        public List<string> Comments { get; init; } = [];
        public List<FuncParameter> Parameters { get; init; } = [];
        public List<FuncParameter> Returns { get; init; } = [];

        public string BuildParameter()
        {
            var builder = new StringBuilder();
            builder.Append('(');

            if (Parameters.Count > 0)
            {
                var paramArray = Parameters.ToArray();
                var argWithTypes = new string[paramArray.Length];
                for (int i = 0; i < paramArray.Length; i++)
                {
                    var parameter = paramArray[i];
                    if (parameter.Name == "...")
                        argWithTypes[i] = parameter.Name + parameter.Type;
                    else
                        argWithTypes[i] = $"{parameter.Name}: {parameter.Type}";
                }
                builder.Append(string.Join(", ", argWithTypes));
            }

            builder.Append(')');

            return builder.ToString();
        }

        private string BuildReturns()
        {
            if (Returns.Count == 0)
                return string.Empty;

            var builder = new StringBuilder(" -> ");

            var paramArray = Returns.ToArray();
            var paramWithTypes = new string[paramArray.Length];
            for (int i = 0; i < paramArray.Length; i++)
            {
                var parameter = paramArray[i];
                if (parameter.Name != string.Empty)
                    if (parameter.Name == "...")
                        paramWithTypes[i] = parameter.Name + parameter.Type;
                    else
                        paramWithTypes[i] = $"{parameter.Name}: {parameter.Type}";
                else
                    paramWithTypes[i] = parameter.Type;
            }
            builder.Append(string.Join(", ", paramWithTypes));

            return builder.ToString();
        }

        public void ToMarkdown(StreamWriter writer)
        {
            writer.WriteLine($"## {Name}{BuildParameter()}{BuildReturns()}");
            writer.WriteLine();
            writer.WriteLine(string.Join("\n", Comments));
            writer.WriteLine();

            if (Parameters.Count > 0)
            { 
                writer.WriteLine("**Params**");
                writer.WriteLine();
                writer.WriteLine("| Name | Type | Description |");
                writer.WriteLine("| ---- | ---- | ----------- |");

                foreach (var parameter in Parameters)
                {
                    writer.WriteLine($"| {parameter.Name} | {parameter.Type} | {parameter.Description} |");
                }
            }

            if (Returns.Count > 0)
            {
                writer.WriteLine();
                writer.WriteLine("**Returns**");
                writer.WriteLine();
                writer.WriteLine("| Name | Type | Description |");
                writer.WriteLine("| ---- | ---- | ----------- |");

                foreach (var returns in Returns)
                {
                    writer.WriteLine($"| {returns.Name} | {returns.Type} | {returns.Description} |");
                }
            }
        }
    }
}

//## [FunctionName]([ParamsWithType])

//[FunctionDescription]

//### Params

//| Name | Type | Description |
//| ----------- | ----------- | ------------------ |
//| [ParamName] | [ParamType] | [ParamDescription] |

//### Return

//| Name | Type | Description |
//| ------------ | ------------ | ------------------- |
//| [ReturnName] | [ReturnType] | [ReturnDescription] |
