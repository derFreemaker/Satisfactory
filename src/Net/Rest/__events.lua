local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- Uri
        require("Net.Rest.Uri"),

        -- Api
        require("Net.Rest.Api.Request"),
        require("Net.Rest.Api.Response"),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
    require("Net.Rest.Hosting.HostExtensions")
end

return Events
