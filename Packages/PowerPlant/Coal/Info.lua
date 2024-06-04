return {
    Name = "PowerPlant.Coal",
    Namespace = "PowerPlant.Coal",
    Version = "0.1.0-36",
    PackageType = "Application",
    RequiredPackages = {
        "Adapter.Pipeline",
        "Core",
        "FactoryControl.Client"
    },
    ModuleIndex={
        ["PowerPlant.Coal.__main"] = {
            Location = "PowerPlant.Coal.__main",
            Namespace = "PowerPlant.Coal.__main",
            IsRunnable = true,
        },
    },
}
