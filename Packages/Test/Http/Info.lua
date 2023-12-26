return {
    Name = "Test.Http",
    Namespace = "Test.Http",
    Version = "0.1.0-18",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "FactoryControl.Core",
        "Net.Http",
        "Net.Rest"
    },
    ModuleIndex={
        ["Test.Http.__main"] = {
            Location = "Test.Http.__main",
            Namespace = "Test.Http.__main",
            IsRunnable = true,
        },
    },
}
