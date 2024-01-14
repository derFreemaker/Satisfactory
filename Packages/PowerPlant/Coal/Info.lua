return {
    Name = "PowerPlant.Coal",
    Namespace = "PowerPlant.Coal",
    Version = "0.1.0-34",
    PackageType = "Application",
    RequiredPackages = {
        "Adapter.Pipeline"
    },
    ModuleIndex={
        ["PowerPlant.Coal.__main"] = {
            Location = "PowerPlant/Coal/__main",
            Namespace = "PowerPlant.Coal.__main",
            IsRunnable = true,
        },
    },
}
