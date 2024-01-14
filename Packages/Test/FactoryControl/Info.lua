return {
    Name = "Test.FactoryControl",
    Namespace = "Test.FactoryControl",
    Version = "0.1.0-34",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "FactoryControl.Client",
        "Hosting",
        "Net.Core",
        "Test.Framework"
    },
    ModuleIndex={
        ["Test.FactoryControl.__main"] = {
            Location = "Test/FactoryControl/__main",
            Namespace = "Test.FactoryControl.__main",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Helper"] = {
            Location = "Test/FactoryControl/Helper",
            Namespace = "Test.FactoryControl.Helper",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Connection"] = {
            Location = "Test/FactoryControl/Tests/Connection",
            Namespace = "Test.FactoryControl.Tests.Connection",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Controlling"] = {
            Location = "Test/FactoryControl/Tests/Controlling",
            Namespace = "Test.FactoryControl.Tests.Controlling",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Features.Button"] = {
            Location = "Test/FactoryControl/Tests/Features/Button",
            Namespace = "Test.FactoryControl.Tests.Features.Button",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Features.Chart"] = {
            Location = "Test/FactoryControl/Tests/Features/Chart",
            Namespace = "Test.FactoryControl.Tests.Features.Chart",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Features.Radial"] = {
            Location = "Test/FactoryControl/Tests/Features/Radial",
            Namespace = "Test.FactoryControl.Tests.Features.Radial",
            IsRunnable = true,
        },

        ["Test.FactoryControl.Tests.Features.Switch"] = {
            Location = "Test/FactoryControl/Tests/Features/Switch",
            Namespace = "Test.FactoryControl.Tests.Features.Switch",
            IsRunnable = true,
        },
    },
}
