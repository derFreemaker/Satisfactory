return {
    Name = "Test.Http",
    Namespace = "Test.Http",
    Version = "0.1.0-5",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "FactoryControl.Core",
        "Net.Http",
        "Net.Rest"
    },
    ModuleIndex={
        ["TestHttp__main"] = {
            Location = "Test.Http.__main",
            Namespace = "Test.Http.__main",
            IsRunnable = true,
            StartPos = 49,
            EndPos = 937,
        },

    },
}
