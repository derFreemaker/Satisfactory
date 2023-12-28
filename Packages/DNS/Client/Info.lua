return {
    Name = "DNS.Client",
    Namespace = "DNS.Client",
    Version = "0.1.1-92",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Net.Rest"
    },
    ModuleIndex={
        ["DNS.Client.__events"] = {
            Location = "DNS.Client.__events",
            Namespace = "DNS.Client.__events",
            IsRunnable = true,
        },

        ["DNS.Client.Client"] = {
            Location = "DNS.Client.Client",
            Namespace = "DNS.Client.Client",
            IsRunnable = true,
        },

        ["DNS.Client.Hosting.HostExtensions"] = {
            Location = "DNS.Client.Hosting.HostExtensions",
            Namespace = "DNS.Client.Hosting.HostExtensions",
            IsRunnable = true,
        },
    },
}
