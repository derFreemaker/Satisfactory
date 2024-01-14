return {
    Name = "Services.Callback.Core",
    Namespace = "Services.Callback.Core",
    Version = "0.1.0-20",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "Net.Core"
    },
    ModuleIndex={
        ["Services.Callback.Core.__events"] = {
            Location = "Services/Callback/Core/__events",
            Namespace = "Services.Callback.Core.__events",
            IsRunnable = true,
        },

        ["Services.Callback.Core.Entities.CallbackInfo"] = {
            Location = "Services/Callback/Core/Entities/CallbackInfo",
            Namespace = "Services.Callback.Core.Entities.CallbackInfo",
            IsRunnable = true,
        },

        ["Services.Callback.Core.Extensions.NetworkContextExtensions"] = {
            Location = "Services/Callback/Core/Extensions/NetworkContextExtensions",
            Namespace = "Services.Callback.Core.Extensions.NetworkContextExtensions",
            IsRunnable = true,
        },
    },
}
