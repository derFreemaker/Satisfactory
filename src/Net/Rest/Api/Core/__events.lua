local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- Api
        require("Net.Rest.Api.Request"),
        require("Net.Rest.Api.Response"),
    })

    require("Net.Rest.Api.NetworkContextExtensions")
end

return Events
