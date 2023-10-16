local JsonSerializer = require("Core.Json.JsonSerializer")

local SerializeableTypes = {
    require("Net.Core.IPAddress"):Static__GetType(),
}

---@class Net.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos(SerializeableTypes)
end

return Events
