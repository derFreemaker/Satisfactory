return {
    Name = "Net.Core",
    Namespace = "Net.Core",
    Version = "0.1.0-99",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["Net.Core.__events"] = {
            Location = "Net.Core.__events",
            Namespace = "Net.Core.__events",
            IsRunnable = true,
        },

        ["Net.Core.IPAddress"] = {
            Location = "Net.Core.IPAddress",
            Namespace = "Net.Core.IPAddress",
            IsRunnable = true,
        },

        ["Net.Core.Method"] = {
            Location = "Net.Core.Method",
            Namespace = "Net.Core.Method",
            IsRunnable = true,
        },

        ["Net.Core.NetworkClient"] = {
            Location = "Net.Core.NetworkClient",
            Namespace = "Net.Core.NetworkClient",
            IsRunnable = true,
        },

        ["Net.Core.NetworkContext"] = {
            Location = "Net.Core.NetworkContext",
            Namespace = "Net.Core.NetworkContext",
            IsRunnable = true,
        },

        ["Net.Core.NetworkFuture"] = {
            Location = "Net.Core.NetworkFuture",
            Namespace = "Net.Core.NetworkFuture",
            IsRunnable = true,
        },

        ["Net.Core.NetworkPort"] = {
            Location = "Net.Core.NetworkPort",
            Namespace = "Net.Core.NetworkPort",
            IsRunnable = true,
        },

        ["Net.Core.StatusCodes"] = {
            Location = "Net.Core.StatusCodes",
            Namespace = "Net.Core.StatusCodes",
            IsRunnable = true,
        },

        ["Net.Core.Hosting.HostExtensions"] = {
            Location = "Net.Core.Hosting.HostExtensions",
            Namespace = "Net.Core.Hosting.HostExtensions",
            IsRunnable = true,
        },
    },
}
