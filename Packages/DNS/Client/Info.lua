return {
    Name = "DNS.Client",
    Namespace = "DNS.Client",
    Version = "0.1.1-77",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Net.Rest"
    },
    ModuleIndex={
        ["DNSClient__events"] = {
            Location = "DNS.Client.__events",
            Namespace = "DNS.Client.__events",
            IsRunnable = true,
            StartPos = 61,
            EndPos = 236,
        },

        ["DNSClientClient"] = {
            Location = "DNS.Client.Client",
            Namespace = "DNS.Client.Client",
            IsRunnable = true,
            StartPos = 294,
            EndPos = 4037,
        },

        ["DNSClientHostingHostExtensions"] = {
            Location = "DNS.Client.Hosting.HostExtensions",
            Namespace = "DNS.Client.Hosting.HostExtensions",
            IsRunnable = true,
            StartPos = 4127,
            EndPos = 5489,
        },

    },
}
