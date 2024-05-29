using Lua_Bundler.Interfaces;

namespace Lua_Bundler
{
    internal class PackageMapPart
    {
        private readonly Int32 _Depth;

        private readonly Dictionary<String, IPackageModule> _Modules = new();
        private readonly Dictionary<String, PackageMapPart> _Childs = new();

        public PackageMapPart(Int32 depth = 0)
        {
            _Depth = depth;
        }

        internal Boolean TryAddModule(IPackageModule module, String[] splitedNamespace, Int32 depth = 0)
        {
            var moduleNamespaceNextPart = splitedNamespace[depth];
            if (_Depth == splitedNamespace.Length - 1)
            {
                return _Modules.TryAdd(moduleNamespaceNextPart, module);
            }

            if (!_Childs.TryGetValue(moduleNamespaceNextPart, out var child))
            {
                child = new PackageMapPart(_Depth + 1);
                _Childs[splitedNamespace[depth]] = child;
            }
            return child.TryAddModule(module, splitedNamespace, depth + 1);
        }

        internal void RemoveModule(String[] splitedNamespace, Int32 depth = 0)
        {
            // no good naming found for this variable
            var splitedNamespaceLength = splitedNamespace.Length - 1;
            if (splitedNamespaceLength == depth)
            {
                _Modules.Remove(splitedNamespace[depth + 1]);
                return;
            }

            if (splitedNamespaceLength > depth
                && _Childs.TryGetValue(splitedNamespace[depth + 1], out var child)) {
                child.RemoveModule(splitedNamespace, depth + 1);
            }
        }

        internal IPackageModule? GetModule(String[] splitedNamespace, Int32 depth = 0)
        {
            PackageMapPart? child;

            var moduleNamespaceAtCurrent = splitedNamespace[depth];
            // no good naming found for this variable
            var splitedNamespaceLength = splitedNamespace.Length - 1;
            if (splitedNamespaceLength == depth)
            {
                if (_Modules.TryGetValue(moduleNamespaceAtCurrent, out var module))
                    return module;

                if (_Childs.TryGetValue(moduleNamespaceAtCurrent, out child))
                {
                    var newSplitedNamespace = splitedNamespace.ToList();
                    newSplitedNamespace.Add("init");
                    return child.GetModule(newSplitedNamespace.ToArray(), depth + 1);
                }

                return null;
            }

            if (_Childs.TryGetValue(moduleNamespaceAtCurrent, out child))
            {
                return child.GetModule(splitedNamespace, depth + 1);
            }
            return null;
        }
    }
}
