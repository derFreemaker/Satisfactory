return {
    Name = "Test.Framework",
    Namespace = "Test.Framework",
    Version = "0.1.0-11",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Hosting"
    },
    ModuleIndex={
        ["TestFramework__events"] = {
            Location = "Test.Framework.__events",
            Namespace = "Test.Framework.__events",
            IsRunnable = true,
            StartPos = 69,
            EndPos = 121,
        },

        ["TestFrameworkFramework"] = {
            Location = "Test.Framework.Framework",
            Namespace = "Test.Framework.Framework",
            IsRunnable = true,
            StartPos = 193,
            EndPos = 1255,
        },

        ["TestFrameworkWrapper"] = {
            Location = "Test.Framework.Wrapper",
            Namespace = "Test.Framework.Wrapper",
            IsRunnable = true,
            StartPos = 1323,
            EndPos = 2998,
        },

        ["TestFrameworkExtensionsHostExtensions"] = {
            Location = "Test.Framework.Extensions.HostExtensions",
            Namespace = "Test.Framework.Extensions.HostExtensions",
            IsRunnable = true,
            StartPos = 3102,
            EndPos = 3484,
        },

    },
}
