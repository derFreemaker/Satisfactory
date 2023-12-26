return {
    Name = "Adapter.Computer",
    Namespace = "Adapter.Computer",
    Version = "0.1.0-51",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["Adapter.Computer.InternetCard"] = {
            Location = "Adapter.Computer.InternetCard",
            Namespace = "Adapter.Computer.InternetCard",
            IsRunnable = true,
        },

        ["Adapter.Computer.NetworkCard"] = {
            Location = "Adapter.Computer.NetworkCard",
            Namespace = "Adapter.Computer.NetworkCard",
            IsRunnable = true,
        },
    },
}
