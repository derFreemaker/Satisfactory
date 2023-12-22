return {
    Name = "Test.Core",
    Namespace = "Test.Core",
    Version = "0.1.0-9",
    PackageType = "Library",
    RequiredPackages = {
        "Adapter.Computer",
        "Core",
        "Hosting",
        "Test.Framework"
    },
    ModuleIndex={
        ["TestCore__main"] = {
            Location = "Test.Core.__main",
            Namespace = "Test.Core.__main",
            IsRunnable = true,
            StartPos = 55,
            EndPos = 583,
        },

        ["TestCoreTestsNetworkCard"] = {
            Location = "Test.Core.Tests.NetworkCard",
            Namespace = "Test.Core.Tests.NetworkCard",
            IsRunnable = true,
            StartPos = 661,
            EndPos = 1341,
        },

    },
}
