return {
    Name = "Services.Callback.Client",
    Namespace = "Services.Callback.Client",
    Version = "0.1.0-33",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Services.Callback.Core"
    },
    ModuleIndex={
        ["Services.Callback.Client.__events"] = {
            Location = "Services.Callback.Client.__events",
            Namespace = "Services.Callback.Client.__events",
            IsRunnable = true,
        },

        ["Services.Callback.Client.Callback"] = {
            Location = "Services.Callback.Client.Callback",
            Namespace = "Services.Callback.Client.Callback",
            IsRunnable = true,
        },

        ["Services.Callback.Client.CallbackService"] = {
            Location = "Services.Callback.Client.CallbackService",
            Namespace = "Services.Callback.Client.CallbackService",
            IsRunnable = true,
        },

        ["Services.Callback.Client.EventCallback"] = {
            Location = "Services.Callback.Client.EventCallback",
            Namespace = "Services.Callback.Client.EventCallback",
            IsRunnable = true,
        },
    },
}
