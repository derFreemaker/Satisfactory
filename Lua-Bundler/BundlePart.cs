namespace Lua_Bundler
{
    internal class BundlePart
    {
        public string Id { get; }
        public string Location { get; }
        public string Namespace { get; }
        public bool IsDirectory { get; }
        public string FullName { get; }
        public string Name { get; }
        public BundlePart[] Childs { get; private set; }
        public BundlePart? Parent { get; }

        public BundlePart(string id, string location, string? @namespace, bool isDirectory, BundlePart? parent = null)
        {
            if (isDirectory && @namespace is null)
            {
                var splitedLocation = location.Split("\\");
                @namespace = splitedLocation[^1];
            }

            @namespace ??= Path.GetFileNameWithoutExtension(location).Split('.')[0];

            Id = id;
            Location = location;
            Namespace = @namespace;
            IsDirectory = isDirectory;

            FullName = IsDirectory ? @namespace ?? throw new DirectoryNotFoundException($"Could not find '{location}'") : Path.GetFileName(location);
            Name = IsDirectory ? FullName : Path.GetFileNameWithoutExtension(location);

            Childs = Array.Empty<BundlePart>();
            Parent = parent;
        }

        public void BuildChilds(bool buildAllChilds = false)
        {
            if (!IsDirectory) return;

            var childs = new List<BundlePart>();
            foreach (var child in Directory.GetDirectories(Location, "*", SearchOption.TopDirectoryOnly))
            {
                if (child.EndsWith("%bin%")) continue;

                var folderName = child.Split("\\")[^1];
                var @namespace = $"{Namespace}.{folderName}";
                var bundlePart = new BundlePart(Utils.GenerateStringId(), child, @namespace, true, this);
                childs.Add(bundlePart);

                if (buildAllChilds) bundlePart.BuildChilds(buildAllChilds);
            }

            foreach (var child in Directory.GetFiles(Location, "*", SearchOption.TopDirectoryOnly))
            {
                var fileName = Path.GetFileNameWithoutExtension(child).Split(".")[0];
                if (IgnoreFiles.Contains(fileName)) continue;
                var @namespace = $"{Namespace}.{fileName}";
                childs.Add(new BundlePart(Utils.GenerateStringId(), child, @namespace, false, this));
            }

            Childs = childs.ToArray();
        }

        private void BundleDirectoryData(StreamWriter writer, BundlerConfig config)
        {
            if (!config.Optimize) writer.WriteLine("\n-- " + new string('#', 10) + $" {Namespace} " + new string('#', 10));
            foreach (var child in Childs)
                child.BundleData(writer, config);
            if (!config.Optimize) writer.WriteLine("\n-- " + new string('#', 10) + $" {Namespace} " + new string('#', 10) + " --");
        }

        private void BundleFileData(StreamWriter writer, BundlerConfig config)
        {
            var modifyedContent = new List<string>();
            var content = File.ReadAllLines(Location).AsSpan();
            for (int i = 0; i < content.Length; i++)
            {
                if (content[i] == "" || content[i].StartsWith("--"))
                    continue;
                if (config.Optimize)
                    modifyedContent.Add(content[i].Replace("  ", ""));
                else
                    modifyedContent.Add(content[i]);
            }

            string data;
            if (config.Optimize)
                data = $"[[{string.Join(" ", modifyedContent)}]]";
            else
                data = $"[[\n{string.Join("\n", modifyedContent)}\n]]";

            if (config.Optimize)
            {
                writer.Write($"PackageData.{Id} = " + "{ ");
                writer.Write($"Namespace = \"{Namespace}\", ");
                writer.Write($"Name = \"{Name}\", ");
                writer.Write($"FullName = \"{FullName}\", ");
                writer.Write($"IsRunable = {FullName.EndsWith(".lua").ToString().ToLower()}, ");
                writer.Write($"Data = {data} " + "}");
            }
            else
            {
                writer.WriteLine();
                writer.WriteLine($"PackageData.{Id} = " + "{");
                writer.WriteLine($"    Namespace = \"{Namespace}\",");
                writer.WriteLine($"    Name = \"{Name}\",");
                writer.WriteLine($"    FullName = \"{FullName}\",");
                writer.WriteLine($"    IsRunable = {FullName.EndsWith(".lua").ToString().ToLower()},");
                writer.WriteLine($"    Data = {data} " + "}");
            }

        }

        public void BundleData(StreamWriter writer, BundlerConfig config)
        {
            if (IsDirectory)
                BundleDirectoryData(writer, config);
            else
                BundleFileData(writer, config);
            writer.Flush();
        }

        public static string[] IgnoreFiles = new[] { "Info" };
    }
}
