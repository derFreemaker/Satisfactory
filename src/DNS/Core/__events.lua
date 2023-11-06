local JsonSerializer = require("Core.Json.JsonSerializer")

---@class DNS.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        require("DNS.Core.Entities.Address.Address"),
        require("DNS.Core.Entities.Address.Create"),
    })
end

return Events
