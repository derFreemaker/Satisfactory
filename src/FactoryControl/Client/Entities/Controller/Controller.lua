local ButtonFeature = require("FactoryControl.Client.Entities.Controller.Feature.Button")
local SwitchFeature = require("FactoryControl.Client.Entities.Controller.Feature.Switch")
local RadialFeature = require("FactoryControl.Client.Entities.Controller.Feature.Radial")
local ChartFeature = require("FactoryControl.Client.Entities.Controller.Feature.Chart")

---@class FactoryControl.Client.Entities.Controller : object
---@field Id Core.UUID
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
local Controller = {}

---@private
---@param controllerDto FactoryControl.Core.Entities.Controller.ControllerDto
function Controller:__init(controllerDto)
    self.Id = controllerDto.Id
    self.Name = controllerDto.Name
    self.IPAddress = controllerDto.IPAddress

    ---@type Dictionary<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
    local features = {}

    for id, feature in pairs(controllerDto.Features) do
        if feature.Type == "Button" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ButtonDto
            features[id] = ButtonFeature(feature)
        elseif feature.Type == "Switch" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.SwitchDto
            features[id] = SwitchFeature(feature)
        elseif feature.Type == "Radial" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.RadialDto
            features[id] = RadialFeature(feature)
        elseif feature.Type == "Chart" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ChartDto
            features[id] = ChartFeature(feature)
        end
    end

    self.Features = features
end

return Utils.Class.CreateClass(Controller, "FactoryControl.Client.Entities.Controller")
