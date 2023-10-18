local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- Button
        require("FactoryControl.Client.Entities.Controller.Feature.Button.Pressed"):Static__GetType(),
    })
end

return Events
