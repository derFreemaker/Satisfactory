return {
    Name = "Adapter.Computer",
    Namespace = "Adapter.Computer",
    Version = "0.1.0-37",
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
            EndPos = 1538,
        },

        ["AdapterComputerNetworkCard"] = {
            Location = "Adapter.Computer.NetworkCard",
            Namespace = "Adapter.Computer.NetworkCard",
            IsRunnable = true,
            StartPos = 1618,
            EndPos = 3977,
        },

    },
}
