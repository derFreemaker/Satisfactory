return {
    Name = "DNS.Core",
    Namespace = "DNS.Core",
    Version = "0.1-60",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["DNSCore__events"] = {
            Location = "DNS.Core.__events",
            Namespace = "DNS.Core.__events",
            IsRunnable = true,
            StartPos = 57,
            EndPos = 406,
        },

        ["DNSCoreEntitiesAddressAddress"] = {
            Location = "DNS.Core.Entities.Address.Address",
            Namespace = "DNS.Core.Entities.Address.Address",
            IsRunnable = true,
            StartPos = 496,
            EndPos = 1247,
        },

        ["DNSCoreEntitiesAddressCreate"] = {
            Location = "DNS.Core.Entities.Address.Create",
            Namespace = "DNS.Core.Entities.Address.Create",
            IsRunnable = true,
            StartPos = 1335,
            EndPos = 1995,
        },

    },
}
