return {
    Name = "Net.Rest.Api.Server",
    Namespace = "Net.Rest.Api.Server",
    Version = "0.1.0-1",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Net.Rest.Api.Core"
    },
    ModuleIndex={
        ["Net.Rest.Api.Server.Controller"] = {
            Location = "Net.Rest.Api.Server.Controller",
            Namespace = "Net.Rest.Api.Server.Controller",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Server.Endpoint"] = {
            Location = "Net.Rest.Api.Server.Endpoint",
            Namespace = "Net.Rest.Api.Server.Endpoint",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Server.EndpointBase"] = {
            Location = "Net.Rest.Api.Server.EndpointBase",
            Namespace = "Net.Rest.Api.Server.EndpointBase",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Server.ResponseTemplates"] = {
            Location = "Net.Rest.Api.Server.ResponseTemplates",
            Namespace = "Net.Rest.Api.Server.ResponseTemplates",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Server.Hosting.HostExtensions"] = {
            Location = "Net.Rest.Api.Server.Hosting.HostExtensions",
            Namespace = "Net.Rest.Api.Server.Hosting.HostExtensions",
            IsRunnable = true,
        },
    },
}
