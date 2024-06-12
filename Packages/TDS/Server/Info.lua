return {
    Name = "TDS.Server",
    Namespace = "TDS.Server",
    Version = "0.1.0-1",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database",
        "TDS.Core"
    },
    ModuleIndex={
        ["TDS.Server.__main"] = {
            Location = "TDS.Server.__main",
            Namespace = "TDS.Server.__main",
            IsRunnable = true,
        },

        ["TDS.Server.DistributionSystem"] = {
            Location = "TDS.Server.DistributionSystem",
            Namespace = "TDS.Server.DistributionSystem",
            IsRunnable = true,
        },

        ["TDS.Server.TrainHandler"] = {
            Location = "TDS.Server.TrainHandler",
            Namespace = "TDS.Server.TrainHandler",
            IsRunnable = true,
        },
    },
}
