return {
    Name = "Services.Callback.Server",
    Namespace = "Services.Callback.Server",
    Version = "0.1.0-22",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Services.Callback.Core"
    },
    ModuleIndex={
        ["Services.Callback.Server.CallbackService"] = {
            Location = "Services.Callback.Server.CallbackService",
            Namespace = "Services.Callback.Server.CallbackService",
            IsRunnable = true,
        },
    },
}
