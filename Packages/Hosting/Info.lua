return {
    Name = "Hosting",
    Namespace = "Hosting",
    Version = "0.1.0-15",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["HostingHost"] = {
            Location = "Hosting.Host",
            Namespace = "Hosting.Host",
            IsRunnable = true,
            StartPos = 47,
            EndPos = 2160,
        },

        ["HostingServiceCollection"] = {
            Location = "Hosting.ServiceCollection",
            Namespace = "Hosting.ServiceCollection",
            IsRunnable = true,
            StartPos = 2234,
            EndPos = 2849,
        },

    },
}
