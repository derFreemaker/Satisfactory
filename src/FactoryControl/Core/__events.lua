local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddTypeInfos({
        -- ControllerDto's
        require("FactoryControl.Core.Entities.Controller.ControllerDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.ConnectDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.CreateDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.ModifyDto"):Static__GetType(),

        -- FeatureDto's
        require("FactoryControl.Core.Entities.Controller.Feature.Switch.SwitchDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Button.ButtonDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Chart.ChartDto"):Static__GetType(),

        -- Feature Updates
        require("FactoryControl.Core.Entities.Controller.Feature.Button.Update"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Switch.Update"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Radial.Update"):Static__GetType(),
        require("FactoryControl.Core.Entities.Controller.Feature.Chart.Update"):Static__GetType(),
    })

    require("FactoryControl.Core.Extensions.NetworkContextExtensions")
end

return Events
