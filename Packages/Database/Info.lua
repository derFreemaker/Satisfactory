return {
    Name = "Database",
    Namespace = "Database",
    Version = "0.1-97",
    PackageType = "Library",
    RequiredPackages = {
        "Core"
    },
    ModuleIndex={
        ["Database.DbTable"] = {
            Location = "Database.DbTable",
            Namespace = "Database.DbTable",
            IsRunnable = true,
        },
    },
}
