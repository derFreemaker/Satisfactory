return {
    Name = "Net.Rest",
    Namespace = "Net.Rest",
    Version = "0.1.0-48",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core"
    },
    ModuleIndex={
        ["Net.Rest.__events"] = {
            Location = "Net.Rest.__events",
            Namespace = "Net.Rest.__events",
            IsRunnable = true,
        },

        ["Net.Rest.Uri"] = {
            Location = "Net.Rest.Uri",
            Namespace = "Net.Rest.Uri",
            IsRunnable = true,
        },

        ["Net.Rest.Api.NetworkContextExtensions"] = {
            Location = "Net.Rest.Api.NetworkContextExtensions",
            Namespace = "Net.Rest.Api.NetworkContextExtensions",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Request"] = {
            Location = "Net.Rest.Api.Request",
            Namespace = "Net.Rest.Api.Request",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Response"] = {
            Location = "Net.Rest.Api.Response",
            Namespace = "Net.Rest.Api.Response",
            IsRunnable = true,
        },

        ["Net.Rest.Api.Client.Client"] = {
            Location = "Net.Rest.Api.Client.Client",
            Namespace = "Net.Rest.Api.Client.Client",
            IsRunnable = true,
        },

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

        ["Net.Rest.Hosting.HostExtensions"] = {
            Location = "Net.Rest.Hosting.HostExtensions",
            Namespace = "Net.Rest.Hosting.HostExtensions",
            IsRunnable = true,
        },
    },
}
