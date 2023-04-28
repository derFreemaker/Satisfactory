namespace Lua_Bundler
{
    internal class BundlePart
    {
        public Guid Id { get; }
        public string Location { get; }
        public bool IsDirectory { get; }
        public string FullName { get; }
        public string Name { get; }
        public BundlePart[] Childs { get; private set; }
        public BundlePart? Parent { get; }

        public BundlePart(Guid id, string location, bool isDirectory, BundlePart? parent = null)
        {
            Id = id;
            Location = location;
            IsDirectory = isDirectory;

            FullName = IsDirectory ? Path.GetDirectoryName(location) ?? throw new DirectoryNotFoundException($"Could not find '{location}'") : Path.GetFileName(location);
            Name = IsDirectory ? FullName : Path.GetFileNameWithoutExtension(location);

            Childs = Array.Empty<BundlePart>();
            Parent = parent;
        }

        private void BuildChilds(bool buildAllChilds = false)
        {
            if (!IsDirectory) return;

            var childs = new List<BundlePart>();
            foreach (var child in Directory.GetDirectories(Location, "*", SearchOption.TopDirectoryOnly))
            {
                var bundlePart = new BundlePart(Guid.NewGuid(), child, true, this);
                childs.Add(bundlePart);
                if (buildAllChilds) bundlePart.BuildChilds(buildAllChilds);
            }

            foreach (var child in Directory.GetFiles(Location, "*", SearchOption.TopDirectoryOnly))
                childs.Add(new BundlePart(Guid.NewGuid(), child, false, this));

            Childs = childs.ToArray();
        }
    }
}
