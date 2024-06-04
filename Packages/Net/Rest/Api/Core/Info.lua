return {
    Name = "Net.Rest.Api.Core",
    Namespace = "Net.Rest.Api.Core",
    Version = "0.1.0-3",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core"
    },
    ModuleIndex={
        ["Net.Rest.Api.Core.__events"] = {
            Location = "Net.Rest.Api.Core.__events",
            Namespace = "Net.Rest.Api.Core.__events",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Core.NetworkContextExtensions"] = {
            Location = "Net.Rest.Api.Core.NetworkContextExtensions",
            Namespace = "Net.Rest.Api.Core.NetworkContextExtensions",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Core.Request"] = {
            Location = "Net.Rest.Api.Core.Request",
            Namespace = "Net.Rest.Api.Core.Request",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Core.Response"] = {
            Location = "Net.Rest.Api.Core.Response",
            Namespace = "Net.Rest.Api.Core.Response",
            IsRunnable = true,
        },
    },
}
