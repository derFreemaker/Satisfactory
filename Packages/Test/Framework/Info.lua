return {
    Name = "Test.Framework",
    Namespace = "Test.Framework",
    Version = "0.1.0-31",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Hosting"
    },
    ModuleIndex={
        ["Test.Framework.__events"] = {
            Location = "Test.Framework.__events",
            Namespace = "Test.Framework.__events",
            IsRunnable = true,
        },

        ["Test.Framework.init"] = {
            Location = "Test.Framework.init",
            Namespace = "Test.Framework.init",
            IsRunnable = true,
        },

        ["Test.Framework.Wrapper"] = {
            Location = "Test.Framework.Wrapper",
            Namespace = "Test.Framework.Wrapper",
            IsRunnable = true,
        },

        ["Test.Framework.Extensions.HostExtensions"] = {
            Location = "Test.Framework.Extensions.HostExtensions",
            Namespace = "Test.Framework.Extensions.HostExtensions",
            IsRunnable = true,
        },
    },
}
