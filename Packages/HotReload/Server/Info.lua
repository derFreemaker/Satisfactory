return {
    Name = "HotReload.Server",
    Namespace = "HotReload.Server",
    Version = "0.1.0-2",
    PackageType = "Application",
    RequiredPackages = {
        "Adapter.Computer",
        "Core",
        "Hosting",
        "HotReload.Client",
        "Net.Core"
    },
    ModuleIndex={
        ["HotReload.Server.__main"] = {
            Location = "HotReload.Server.__main",
            Namespace = "HotReload.Server.__main",
            IsRunnable = true,
        },
    },
}
