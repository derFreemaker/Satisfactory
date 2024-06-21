return {
    Name = "TDS.Server",
    Namespace = "TDS.Server",
    Version = "0.1.0-2",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database"
    },
    ModuleIndex={
        ["TDS.Server.__main"] = {
            Location = "TDS.Server.__main",
            Namespace = "TDS.Server.__main",
            IsRunnable = true,
        },

        ["TDS.Server.DatabaseAccessLayer"] = {
            Location = "TDS.Server.DatabaseAccessLayer",
            Namespace = "TDS.Server.DatabaseAccessLayer",
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

        ["TDS.Server.Entities.Station"] = {
            Location = "TDS.Server.Entities.Station",
            Namespace = "TDS.Server.Entities.Station",
            IsRunnable = true,
        },

        ["TDS.Server.Entities.Train"] = {
            Location = "TDS.Server.Entities.Train",
            Namespace = "TDS.Server.Entities.Train",
            IsRunnable = true,
        },
    },
}
