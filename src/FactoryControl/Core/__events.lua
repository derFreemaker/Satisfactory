local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- ControllerDto's
        require("FactoryControl.Core.Entities.Controller.ControllerDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.CreateDto"):Static__GetType(),

        -- FeatureDto's
        require("FactoryControl.Core.Entities.Controller.Feature.SwitchDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.ButtonDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.RadialDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.ChartDto"):Static__GetType(),
    })
end

return Events
