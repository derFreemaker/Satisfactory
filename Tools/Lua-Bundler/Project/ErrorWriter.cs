using Lua_Bundler.Interfaces;

namespace Lua_Bundler
{
    internal class ErrorWriter
    {
        private static class Core
        {
            private static void WriteError(string kind, string code, FileLineInfo info)
            {
                Console.WriteLine($"{kind}'-'{code}'-'{info.FilePath}'-{info.Line}:{info.Start}:{info.End}");
            }

            internal static void CircularReference(string subKind, string location, FileLineInfo info)
            {
                WriteError($"{subKind}_CircularReference", $"'{location}' is already referencing this", info);
            }

            internal static void ExistsMoreThanOnce(string subKind, string location, FileLineInfo info)
            {
                WriteError($"{subKind}_Exists_MoreThanOnce", $"'{location}' exists more than once", info);
            }

            internal static void NotFound(string subKind, string @namespace, FileLineInfo info)
            {
                WriteError($"{subKind}_NotFound", $"'{@namespace}' was not found", info);
            }

            internal static void UnknownType(string subKind, string type, FileLineInfo info)
            {
                WriteError($"{subKind}_UnknownType", $"'{type}' is not a valid type", info);
            }
        }

        #region - Package -

        internal static void PackageCircularReference(IPackage first, IPackage second)
        {
            Core.CircularReference("Package", first.Location, (first.GetInfo().InfoFileSourcePath, null));
            Core.CircularReference("Package", second.Location, (second.GetInfo().InfoFileSourcePath, null));
        }

        internal static void PackageExistsMoreThanOnce(IPackage first, IPackage second)
        {
            Core.ExistsMoreThanOnce("Package", first.Namespace, (first.GetInfo().InfoFileSourcePath, null));
            Core.ExistsMoreThanOnce("Package", second.Namespace, (second.GetInfo().InfoFileSourcePath, null));
        }

        internal static void PackageRequireNotFound(string packageNamespace, string infoFilePath)
        {
            Core.NotFound("Require_Package", packageNamespace, (infoFilePath, null));
        }

        internal static void PackageUsingNotFound(string packageNamespace, FileLineInfo info)
        {
            Core.NotFound("Using_Package", packageNamespace, info);
        }

        internal static void PackageUnknownType(IPackageInfo info)
        {
            Core.UnknownType("Package", info.GetPackageType(), (info.InfoFileSourcePath, null));
        }

        #endregion

        #region - Module -

        internal static void ModuleCircularReference(IPackageModule module1, IPackageModule module2)
        {
            Core.CircularReference("Module", module1.Location, (module1.LocationPath, null));
            Core.CircularReference("Module", module2.Location, (module2.LocationPath, null));
        }

        internal static void ModuleExistsMoreThanOnce(IPackageModule module)
        {
            Core.ExistsMoreThanOnce("Module", module.Namespace, (module.LocationPath, null));
        }

        internal static void ModuleNotFound(string moduleName, FileLineInfo info)
        {
            Core.NotFound("Module", moduleName, info);
        }

        #endregion

        #region - Class -

        internal static void ClassExistsMoreThanOnce(string className, FileLineInfo first, FileLineInfo second)
        {
            Core.ExistsMoreThanOnce("Class", className, first);
            Core.ExistsMoreThanOnce("Class", className, second);
        }

        #endregion
    }
}
