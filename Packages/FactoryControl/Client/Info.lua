return {
    Name = "FactoryControl.Client",
    Namespace = "FactoryControl.Client",
    Version = "0.1-58",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "FactoryControl.Core",
        "Net.Core",
        "Net.Http",
        "Services.Callback.Client"
    },
    ModuleIndex={
        ["FactoryControl.Client.Client"] = {
            Location = "FactoryControl.Client.Client",
            Namespace = "FactoryControl.Client.Client",
            IsRunnable = true,
        },

        ["FactoryControl.Client.DataClient"] = {
            Location = "FactoryControl.Client.DataClient",
            Namespace = "FactoryControl.Client.DataClient",
            IsRunnable = true,
        },

        ["FactoryControl.Client.EventNames"] = {
            Location = "FactoryControl.Client.EventNames",
            Namespace = "FactoryControl.Client.EventNames",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Entity"] = {
            Location = "FactoryControl.Client.Entities.Entity",
            Namespace = "FactoryControl.Client.Entities.Entity",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Controller"] = {
            Location = "FactoryControl.Client.Entities.Controller.Controller",
            Namespace = "FactoryControl.Client.Entities.Controller.Controller",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Modify"] = {
            Location = "FactoryControl.Client.Entities.Controller.Modify",
            Namespace = "FactoryControl.Client.Entities.Controller.Modify",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Factory"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Factory",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Factory",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Feature"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Feature",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Feature",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Button.Button"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Button.Button",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Chart.Chart"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Chart.Chart",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Radial.Radial"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Radial.Radial",
            IsRunnable = true,
        },

        ["FactoryControl.Client.Entities.Controller.Feature.Switch.Switch"] = {
            Location = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
            Namespace = "FactoryControl.Client.Entities.Controller.Feature.Switch.Switch",
            IsRunnable = true,
        },
    },
}
