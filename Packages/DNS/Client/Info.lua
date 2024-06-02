return {
    Name = "DNS.Client",
    Namespace = "DNS.Client",
    Version = "0.1.1-96",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "DNS.Core",
        "Net.Core",
        "Net.Rest.Api.Client",
        "Net.Rest.Api.Core"
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
