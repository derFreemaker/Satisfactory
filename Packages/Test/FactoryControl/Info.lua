return {
    Name = "Test.FactoryControl",
    Namespace = "Test.FactoryControl",
    Version = "0.1.0-17",
    PackageType = "Library",
    RequiredPackages = {
        "Core",
        "FactoryControl.Client",
        "Hosting",
        "Net.Core",
        "Test.Framework"
    },
    ModuleIndex={
        ["TestFactoryControl__main"] = {
            Location = "Test.FactoryControl.__main",
            Namespace = "Test.FactoryControl.__main",
            IsRunnable = true,
            StartPos = 75,
            EndPos = 535,
        },

        ["TestFactoryControlHelper"] = {
            Location = "Test.FactoryControl.Helper",
            Namespace = "Test.FactoryControl.Helper",
            IsRunnable = true,
            StartPos = 611,
            EndPos = 1299,
        },

        ["TestFactoryControlTestsConnection"] = {
            Location = "Test.FactoryControl.Tests.Connection",
            Namespace = "Test.FactoryControl.Tests.Connection",
            IsRunnable = true,
            StartPos = 1395,
            EndPos = 1858,
        },

        ["TestFactoryControlTestsControlling"] = {
            Location = "Test.FactoryControl.Tests.Controlling",
            Namespace = "Test.FactoryControl.Tests.Controlling",
            IsRunnable = true,
            StartPos = 1956,
            EndPos = 3310,
        },

        ["TestFactoryControlTestsFeaturesButton"] = {
            Location = "Test.FactoryControl.Tests.Features.Button",
            Namespace = "Test.FactoryControl.Tests.Features.Button",
            IsRunnable = true,
            StartPos = 3416,
            EndPos = 4133,
        },

        ["TestFactoryControlTestsFeaturesChart"] = {
            Location = "Test.FactoryControl.Tests.Features.Chart",
            Namespace = "Test.FactoryControl.Tests.Features.Chart",
            IsRunnable = true,
            StartPos = 4237,
            EndPos = 5310,
        },

        ["TestFactoryControlTestsFeaturesRadial"] = {
            Location = "Test.FactoryControl.Tests.Features.Radial",
            Namespace = "Test.FactoryControl.Tests.Features.Radial",
            IsRunnable = true,
            StartPos = 5416,
            EndPos = 6393,
        },

        ["TestFactoryControlTestsFeaturesSwitch"] = {
            Location = "Test.FactoryControl.Tests.Features.Switch",
            Namespace = "Test.FactoryControl.Tests.Features.Switch",
            IsRunnable = true,
            StartPos = 6499,
            EndPos = 7363,
        },

    },
}
