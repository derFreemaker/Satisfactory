return {
    Name = "Hosting",
    Namespace = "Hosting",
    Version = "0.1.0-33",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["Hosting.Host"] = {
            Location = "Hosting/Host",
            Namespace = "Hosting.Host",
            IsRunnable = true,
        },

        ["Hosting.ServiceCollection"] = {
            Location = "Hosting/ServiceCollection",
            Namespace = "Hosting.ServiceCollection",
            IsRunnable = true,
        },
    },
}
