return {
    Name = "TDS.Core",
    Namespace = "TDS.Core",
    Version = "0.1.0-1",
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

        ["TDS.Core.Entities.Train"] = {
            Location = "TDS.Core.Entities.Train",
            Namespace = "TDS.Core.Entities.Train",
            IsRunnable = true,
        },
    },
}
