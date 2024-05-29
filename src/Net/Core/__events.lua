local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Net.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- IPAddress
        require("Net.Core.IPAddress"),
    })

    -- Loading Host Extensions
    require("Net.Core.Hosting.HostExtensions")
end

return Events
