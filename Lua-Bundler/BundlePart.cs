using System.Net.Http.Headers;
using System.Text;

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

        private void BundleDirectoryData(StreamWriter writer)
        {
            writer.WriteLine("\n-- " + new string('#', 10) + $" {Namespace} " + new string('#', 10));
            foreach (var child in Childs)
                child.BundleData(writer);
            writer.WriteLine("-- " + new string('#', 10) + $" {Namespace} " + new string('#', 10) + " --\n");
        }

        private void BundleFileData(StreamWriter writer)
        {
            var modifyedContent = new List<string>();
            var content = File.ReadAllLines(Location).AsSpan();
            for (int i = 0; i < content.Length; i++)
            {
                if (content[i] == "" || content[i].StartsWith("--"))
                    continue;
                modifyedContent.Add(content[i]);
            }

            writer.WriteLine(Environment.NewLine + $"PackageData.{Id} = " + "{");
            writer.WriteLine($"    Namespace = \"{Namespace}\",");
            writer.WriteLine($"    Name = \"{Name}\",");
            writer.WriteLine($"    FullName = \"{FullName}\",");
            writer.WriteLine($"    IsRunable = {FullName.EndsWith(".lua").ToString().ToLower()},");
            writer.WriteLine($"    Data = [[\n{string.Join("\n", modifyedContent)}\n]] " + "}" + Environment.NewLine);
        }

        public void BundleData(StreamWriter writer)
        {
            if (IsDirectory)
                BundleDirectoryData(writer);
            else
                BundleFileData(writer);
            writer.Flush();
        }

        public static string[] IgnoreFiles = new[] { "Info" };
    }
}
