return {
    Name = "Services.Callback.Client",
    Namespace = "Services.Callback.Client",
    Version = "0.1.0-13",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core",
        "Services.Callback.Core"
    },
    ModuleIndex={
        ["ServicesCallbackClient__events"] = {
            Location = "Services.Callback.Client.__events",
            Namespace = "Services.Callback.Client.__events",
            IsRunnable = true,
            StartPos = 89,
            EndPos = 145,
        },

        ["ServicesCallbackClientCallback"] = {
            Location = "Services.Callback.Client.Callback",
            Namespace = "Services.Callback.Client.Callback",
            IsRunnable = true,
            StartPos = 235,
            EndPos = 2121,
        },

        ["ServicesCallbackClientCallbackService"] = {
            Location = "Services.Callback.Client.CallbackService",
            Namespace = "Services.Callback.Client.CallbackService",
            IsRunnable = true,
            StartPos = 2225,
            EndPos = 5502,
        },

        ["ServicesCallbackClientEventCallback"] = {
            Location = "Services.Callback.Client.EventCallback",
            Namespace = "Services.Callback.Client.EventCallback",
            IsRunnable = true,
            StartPos = 5602,
            EndPos = 7043,
        },

    },
}
