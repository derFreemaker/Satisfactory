local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- Button
        require("FactoryControl.Client.Entities.Controller.Feature.Button.Update"):Static__GetType(),

        -- Switch
        require("FactoryControl.Client.Entities.Controller.Feature.Switch.Update"):Static__GetType(),

        -- Radial
        require("FactoryControl.Client.Entities.Controller.Feature.Radial.Update"):Static__GetType(),

        -- Chart
        require("FactoryControl.Client.Entities.Controller.Feature.Chart.Update"):Static__GetType(),
    })

    require("FactoryControl.Client.Extensions.NetworkContextExtensions")
end

return Events
