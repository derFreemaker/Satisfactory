return {
    Name = "Net.Rest.Api.Client",
    Namespace = "Net.Rest.Api.Client",
    Version = "0.1.0-1",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Net.Rest.Api.Core"
    },
    ModuleIndex={
        ["Net.Rest.Api.Client.Client"] = {
            Location = "Net.Rest.Api.Client.Client",
            Namespace = "Net.Rest.Api.Client.Client",
            IsRunnable = true,
        },
    },
}
