return {
    Name = "DNS.Server",
    Namespace = "DNS.Server",
    Version = "0.1.4-104",
    PackageType = "Application",
    RequiredPackages = {
        "Core",
        "Database",
        "DNS.Core",
        "Hosting",
        "Net.Rest"
    },
    ModuleIndex={
        ["DNS.Server.__main"] = {
            Location = "DNS/Server/__main",
            Namespace = "DNS.Server.__main",
            IsRunnable = true,
        },

        ["DNS.Server.AddressDatabase"] = {
            Location = "DNS/Server/AddressDatabase",
            Namespace = "DNS.Server.AddressDatabase",
            IsRunnable = true,
        },

        ["DNS.Server.Endpoints"] = {
            Location = "DNS/Server/Endpoints",
            Namespace = "DNS.Server.Endpoints",
            IsRunnable = true,
        },
    },
}
