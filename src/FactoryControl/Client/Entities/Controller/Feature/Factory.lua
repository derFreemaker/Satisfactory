local ButtonFeature = require("FactoryControl.Client.Entities.Controller.Feature.Button.Button")
local ChartFeature = require("FactoryControl.Client.Entities.Controller.Feature.Chart.Chart")
local RadialFeature = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Radial")
local SwitchFeature = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Switch")

---@class FactoyControl.Client.Entities.Controller.Feature.Factory
local Factory = {}

---@param featureDto FactoryControl.Core.Entities.Controller.FeatureDto
---@param client FactoryControl.Client
---@return FactoryControl.Client.Entities.Controller.Feature
function Factory.Create(featureDto, client)
    if featureDto.Type == "Button" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.ButtonDto
        return ButtonFeature(featureDto, client)
    elseif featureDto.Type == "Chart" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
        return ChartFeature(featureDto, client)
    elseif featureDto.Type == "Radial" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
        return RadialFeature(featureDto, client)
    elseif featureDto.Type == "Switch" then
        ---@cast featureDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
        return SwitchFeature(featureDto, client)
    else
        error("unsupported feature type")
    end
end

return Factory
