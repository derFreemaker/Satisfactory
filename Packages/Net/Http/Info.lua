return {
    Name = "Http",
    Namespace = "Net.Http",
    Version = "0.1.0-78",
    PackageType = "Library",
    RequiredPackages = {
        "Net.Core"
    },
    ModuleIndex={
        ["Net.Http.Client"] = {
            Location = "Net.Http.Client",
            Namespace = "Net.Http.Client",
            IsRunnable = true,
        },

        ["Net.Http.Request"] = {
            Location = "Net.Http.Request",
            Namespace = "Net.Http.Request",
            IsRunnable = true,
        },

        ["Net.Http.RequestOptions"] = {
            Location = "Net.Http.RequestOptions",
            Namespace = "Net.Http.RequestOptions",
            IsRunnable = true,
        },

        ["Net.Http.Response"] = {
            Location = "Net.Http.Response",
            Namespace = "Net.Http.Response",
            IsRunnable = true,
        },
    },
}
