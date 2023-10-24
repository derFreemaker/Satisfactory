local JsonSerializer = require("Core.Json.JsonSerializer")

---@class DNS.Core.__events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        require("DNS.Core.Entities.Address.Address"):Static__GetType(),
        require("DNS.Core.Entities.Address.Create"):Static__GetType(),
    })
end

return Events
