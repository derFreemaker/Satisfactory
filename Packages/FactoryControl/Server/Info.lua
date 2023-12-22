return {
    Name = "FactoryControlServer",
    Namespace = "FactoryControl.Server",
    Version = "0.1-80",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database",
        "FactoryControl.Core",
        "Net.Rest",
        "Services.Callback.Server"
    },
    ModuleIndex={
        ["FactoryControlServer__events"] = {
            Location = "FactoryControl.Server.__events",
            Namespace = "FactoryControl.Server.__events",
            IsRunnable = true,
            StartPos = 77,
            EndPos = 230,
        },

        ["FactoryControlServer__main"] = {
            Location = "FactoryControl.Server.__main",
            Namespace = "FactoryControl.Server.__main",
            IsRunnable = true,
            StartPos = 304,
            EndPos = 2340,
        },

        ["FactoryControlServerDatabaseAccessLayer"] = {
            Location = "FactoryControl.Server.DatabaseAccessLayer",
            Namespace = "FactoryControl.Server.DatabaseAccessLayer",
            IsRunnable = true,
            StartPos = 2440,
            EndPos = 6344,
        },

        ["FactoryControlServerEndpointsController"] = {
            Location = "FactoryControl.Server.Endpoints.Controller",
            Namespace = "FactoryControl.Server.Endpoints.Controller",
            IsRunnable = true,
            StartPos = 6446,
            EndPos = 10299,
        },

        ["FactoryControlServerEndpointsFeature"] = {
            Location = "FactoryControl.Server.Endpoints.Feature",
            Namespace = "FactoryControl.Server.Endpoints.Feature",
            IsRunnable = true,
            StartPos = 10395,
            EndPos = 13025,
        },

        ["FactoryControlServerServicesFeatureService"] = {
            Location = "FactoryControl.Server.Services.FeatureService",
            Namespace = "FactoryControl.Server.Services.FeatureService",
            IsRunnable = true,
            StartPos = 13133,
            EndPos = 16924,
        },

    },
}
