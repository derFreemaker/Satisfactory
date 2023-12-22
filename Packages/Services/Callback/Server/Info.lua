return {
    Name = "Services.Callback.Server",
    Namespace = "Services.Callback.Server",
    Version = "0.1.0-5",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Services.Callback.Core"
    },
    ModuleIndex={
        ["ServicesCallbackServerCallbackService"] = {
            Location = "Services.Callback.Server.CallbackService",
            Namespace = "Services.Callback.Server.CallbackService",
            IsRunnable = true,
            StartPos = 103,
            EndPos = 2361,
        },

    },
}
