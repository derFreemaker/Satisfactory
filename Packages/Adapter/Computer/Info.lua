return {
    Name = "Adapter.Computer",
    Namespace = "Adapter.Computer",
    Version = "0.1.0-38",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["AdapterComputerInternetCard"] = {
            Location = "Adapter.Computer.InternetCard",
            Namespace = "Adapter.Computer.InternetCard",
            IsRunnable = true,
            StartPos = 81,
            EndPos = 1535,
        },

        ["AdapterComputerNetworkCard"] = {
            Location = "Adapter.Computer.NetworkCard",
            Namespace = "Adapter.Computer.NetworkCard",
            IsRunnable = true,
            StartPos = 1615,
            EndPos = 3974,
        },

    },
}
