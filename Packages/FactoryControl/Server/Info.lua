return {
    Name = "FactoryControlServer",
    Namespace = "FactoryControl.Server",
    Version = "0.1-100",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database",
        "DNS.Client",
        "FactoryControl.Core",
        "Hosting",
        "Net.Rest.Api.Server",
        "Services.Callback.Server"
    },
    ModuleIndex={
        ["FactoryControl.Server.__main"] = {
            Location = "FactoryControl.Server.__main",
            Namespace = "FactoryControl.Server.__main",
            IsRunnable = true,
        },

        ["FactoryControl.Server.DatabaseAccessLayer"] = {
            Location = "FactoryControl.Server.DatabaseAccessLayer",
            Namespace = "FactoryControl.Server.DatabaseAccessLayer",
            IsRunnable = true,
        },

        ["FactoryControl.Server.Endpoints.Controller"] = {
            Location = "FactoryControl.Server.Endpoints.Controller",
            Namespace = "FactoryControl.Server.Endpoints.Controller",
            IsRunnable = true,
        },

        ["FactoryControl.Server.Endpoints.Feature"] = {
            Location = "FactoryControl.Server.Endpoints.Feature",
            Namespace = "FactoryControl.Server.Endpoints.Feature",
            IsRunnable = true,
        },

        ["FactoryControl.Server.Services.FeatureService"] = {
            Location = "FactoryControl.Server.Services.FeatureService",
            Namespace = "FactoryControl.Server.Services.FeatureService",
            IsRunnable = true,
        },
    },
}
