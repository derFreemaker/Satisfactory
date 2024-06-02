return {
    Name = "Test.Core",
    Namespace = "Test.Core",
    Version = "0.1.0-29",
    PackageType = "Library",
    RequiredPackages = {
        "Adapter.Computer",
        "Core",
        "Hosting",
        "Test.Framework"
    },
    ModuleIndex={
        ["Test.Core.__main"] = {
            Location = "Test.Core.__main",
            Namespace = "Test.Core.__main",
            IsRunnable = true,
        },

        ["Test.Core.Tests.NetworkCard"] = {
            Location = "Test.Core.Tests.NetworkCard",
            Namespace = "Test.Core.Tests.NetworkCard",
            IsRunnable = true,
        },
    },
}
