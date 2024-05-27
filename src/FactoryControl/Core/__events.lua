local JsonSerializer = require("Core.Json.JsonSerializer")

---@class FactoryControl.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    JsonSerializer.Static__Serializer:AddClasses({
        -- ControllerDto"s
        require("FactoryControl.Core.Entities.Controller.ControllerDto"),
        require("FactoryControl.Core.Entities.Controller.ConnectDto"),
        require("FactoryControl.Core.Entities.Controller.CreateDto"),
        require("FactoryControl.Core.Entities.Controller.ModifyDto"),

        -- FeatureDto"s
        require("FactoryControl.Core.Entities.Controller.Feature.Switch.SwitchDto"),
        require("FactoryControl.Core.Entities.Controller.Feature.Button.ButtonDto"),
        require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto"),
        require("FactoryControl.Core.Entities.Controller.Feature.Chart.ChartDto"),

        -- Feature Updates
        require("FactoryControl.Core.Entities.Controller.Feature.Button.Update"),
        require("FactoryControl.Core.Entities.Controller.Feature.Switch.Update"),
        require("FactoryControl.Core.Entities.Controller.Feature.Radial.Update"),
        require("FactoryControl.Core.Entities.Controller.Feature.Chart.Update"),
    })

    require("FactoryControl.Core.Extensions.NetworkContextExtensions")
end

return Events
