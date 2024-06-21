return {
    Name = "TDS.Core",
    Namespace = "TDS.Core",
    Version = "0.1.0-2",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["TDS.Core.Entities.Request"] = {
            Location = "TDS.Core.Entities.Request",
            Namespace = "TDS.Core.Entities.Request",
            IsRunnable = true,
        },
    },
}
