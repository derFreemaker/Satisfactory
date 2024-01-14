return {
    Name = "Test-DNS",
    Namespace = "Test.DNS",
    Version = "0.1.0-89",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "DNS.Client",
        "Net.Core"
    },
    ModuleIndex={
        ["Test.DNS.__main"] = {
            Location = "Test/DNS/__main",
            Namespace = "Test.DNS.__main",
            IsRunnable = true,
        },
    },
}
