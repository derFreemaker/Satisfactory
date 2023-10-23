local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- Uri
        require("Net.Rest.Uri"):Static__GetType(),

        -- Api
        require("Net.Rest.Api.Request"):Static__GetType(),
        require("Net.Rest.Api.Response"):Static__GetType(),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
    require("Net.Rest.Hosting.HostExtensions")
end

return Events
