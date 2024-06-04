return {
    Name = "PowerPlant.Watcher",
    Namespace = "PowerPlant.Watcher",
    Version = "0.1.0-1",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "FactoryControl.Client"
    },
    ModuleIndex={
        ["PowerPlant.Watcher.__main"] = {
            Location = "PowerPlant.Watcher.__main",
            Namespace = "PowerPlant.Watcher.__main",
            IsRunnable = true,
        },
    },
}
