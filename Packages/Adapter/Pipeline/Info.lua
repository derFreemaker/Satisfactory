return {
    Name = "Adapter.Pipeline",
    Namespace = "Adapter.Pipeline",
    Version = "0.1.0-26",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["AdapterPipelineValve"] = {
            Location = "Adapter.Pipeline.Valve",
            Namespace = "Adapter.Pipeline.Valve",
            IsRunnable = true,
            StartPos = 67,
            EndPos = 2362,
        },

    },
}
