return {
    Name = "Net.Rest.Api.Core",
    Namespace = "Net.Rest.Api",
    Version = "0.1.0-2",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core"
    },
    ModuleIndex={
        ["Net.Rest.Api.__events"] = {
            Location = "Net.Rest.Api.Core.__events",
            Namespace = "Net.Rest.Api.__events",
            IsRunnable = true,
        },

        ["Net.Rest.Api.NetworkContextExtensions"] = {
            Location = "Net.Rest.Api.Core.NetworkContextExtensions",
            Namespace = "Net.Rest.Api.NetworkContextExtensions",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Request"] = {
            Location = "Net.Rest.Api.Core.Request",
            Namespace = "Net.Rest.Api.Request",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Response"] = {
            Location = "Net.Rest.Api.Core.Response",
            Namespace = "Net.Rest.Api.Response",
            IsRunnable = true,
        },
    },
}
