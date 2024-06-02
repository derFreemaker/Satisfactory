return {
    Name = "DNS.Core",
    Namespace = "DNS.Core",
    Version = "0.1-78",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["DNS.Core.__events"] = {
            Location = "DNS.Core.__events",
            Namespace = "DNS.Core.__events",
            IsRunnable = true,
        },

        ["DNS.Core.Entities.Address.Address"] = {
            Location = "DNS.Core.Entities.Address.Address",
            Namespace = "DNS.Core.Entities.Address.Address",
            IsRunnable = true,
        },

        ["DNS.Core.Entities.Address.Create"] = {
            Location = "DNS.Core.Entities.Address.Create",
            Namespace = "DNS.Core.Entities.Address.Create",
            IsRunnable = true,
        },
    },
}
