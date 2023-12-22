return {
    Name = "DNS.Server",
    Namespace = "DNS.Server",
    Version = "0.1.4-87",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database",
        "DNS.Core",
        "Hosting",
        "Net.Rest"
    },
    ModuleIndex={
        ["DNSServer__main"] = {
            Location = "DNS.Server.__main",
            Namespace = "DNS.Server.__main",
            IsRunnable = true,
            StartPos = 51,
            EndPos = 1354,
        },

        ["DNSServerAddressDatabase"] = {
            Location = "DNS.Server.AddressDatabase",
            Namespace = "DNS.Server.AddressDatabase",
            IsRunnable = true,
            StartPos = 1424,
            EndPos = 3574,
        },

        ["DNSServerEndpoints"] = {
            Location = "DNS.Server.Endpoints",
            Namespace = "DNS.Server.Endpoints",
            IsRunnable = true,
            StartPos = 3632,
            EndPos = 5982,
        },

    },
}
