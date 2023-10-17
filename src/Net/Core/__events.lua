local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- IPAddress
        require("Net.Core.IPAddress"):Static__GetType(),
    })
end

return Events
