return {
    Name = "HotReload.Client",
    Namespace = "HotReload.Client",
    Version = "0.1.0-1",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Hosting",
        "Net.Core"
    },
    ModuleIndex={
        ["HotReload.Client.__events"] = {
            Location = "HotReload.Client.__events",
            Namespace = "HotReload.Client.__events",
            IsRunnable = true,
        },

        ["HotReload.Client.Extensions.HostExtensions"] = {
            Location = "HotReload.Client.Extensions.HostExtensions",
            Namespace = "HotReload.Client.Extensions.HostExtensions",
            IsRunnable = true,
        },
    },
}
