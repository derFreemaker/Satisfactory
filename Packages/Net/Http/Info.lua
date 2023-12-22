return {
    Name = "Http",
    Namespace = "Net.Http",
    Version = "0.1.0-65",
    PackageType = "Library",
    RequiredPackages = {
        "Net.Core"
    },
    ModuleIndex={
        ["NetHttpClient"] = {
            Location = "Net.Http.Client",
            Namespace = "Net.Http.Client",
            IsRunnable = true,
            StartPos = 53,
            EndPos = 2797,
        },

        ["NetHttpRequest"] = {
            Location = "Net.Http.Request",
            Namespace = "Net.Http.Request",
            IsRunnable = true,
            StartPos = 2853,
            EndPos = 3683,
        },

        ["NetHttpRequestOptions"] = {
            Location = "Net.Http.RequestOptions",
            Namespace = "Net.Http.RequestOptions",
            IsRunnable = true,
            StartPos = 3753,
            EndPos = 4118,
        },

        ["NetHttpResponse"] = {
            Location = "Net.Http.Response",
            Namespace = "Net.Http.Response",
            IsRunnable = true,
            StartPos = 4176,
            EndPos = 5046,
        },

    },
}
