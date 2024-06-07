using Lua_Bundler.Interfaces;

namespace Lua_Bundler;

internal class ErrorWriter
{
    private static class Core
    {
        private static void WriteError(String kind, String message, FileLineInfo info)
        {
            Console.WriteLine("{0}'-'{1}'-'{2}'-{3}:{4}:{5}", kind, message, info.FilePath, info.Line, info.Start, info.End);
        }

        internal static void Error(String subKind, FileLineInfo info, String message)
        {
            WriteError($"{subKind}_Error", message, info);
        }
            
        internal static void CircularReference(String subKind, String location, FileLineInfo info)
        {
            WriteError($"{subKind}_CircularReference",
                       $"'{location}' is already referencing this", info);
        }

        internal static void ExistsMoreThanOnce(String subKind, String location, FileLineInfo info)
        {
            WriteError($"{subKind}_Exists_MoreThanOnce",
                       $"'{location}' exists more than once", info);
        }

        internal static void NotFound(String subKind, String @namespace, FileLineInfo info)
        {
            WriteError($"{subKind}_NotFound", $"'{@namespace}' was not found", info);
        }

        internal static void UnknownType(String subKind, String type, FileLineInfo info)
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

    internal static void PackageRequireNotFound(String packageNamespace, String infoFilePath)
    {
        Core.NotFound("Require_Package", packageNamespace, (infoFilePath, null));
    }

    internal static void PackageUsingNotFound(String packageNamespace, FileLineInfo info)
    {
        Core.NotFound("Using_Package", packageNamespace, info);
    }

    internal static void PackageUnknownType(IPackageInfo info)
    {
        Core.UnknownType("Package", info.GetPackageType(), (info.InfoFileSourcePath, null));
    }

    internal static void ApplicationPackageHasNoMainFile(IPackageInfo info) {
        Core.Error("Package_NoMainFileFound", new FileLineInfo(info.InfoFileSourcePath, 0, 0, 0), "No main file found in Application package.");
    }
    
    #endregion

    #region - Module -

    internal static void ModuleCircularReference(IPackageModule module1, IPackageModule module2)
    {
        Core.CircularReference("Module", module1.Location, (module1.FileInfo.FullName, null));
        Core.CircularReference("Module", module2.Location, (module2.FileInfo.FullName, null));
    }

    internal static void ModuleExistsMoreThanOnce(IPackageModule module)
    {
        Core.ExistsMoreThanOnce("Module", module.Namespace, (module.FileInfo.FullName, null));
    }

    internal static void ModuleNotFound(String moduleNamespace, FileLineInfo info)
    {
        Core.NotFound("Module", moduleNamespace, info);
    }

    internal static void ModuleMultiLineStringWithLevel10Found(FileLineInfo info) {
        Core.Error("Module", info, "Cannot use multiline string close with a level of 10 since it is reserved for the bundler.");
    }

    #endregion

    #region - Class -

    internal static void ClassExistsMoreThanOnce(String className, FileLineInfo first, FileLineInfo second)
    {
        Core.ExistsMoreThanOnce("Class", className, first);
        Core.ExistsMoreThanOnce("Class", className, second);
    }

    #endregion
}