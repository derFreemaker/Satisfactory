local ButtonFeature = require("FactoryControl.Client.Entities.Controller.Feature.Button.Button")
local SwitchFeature = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Switch")
local RadialFeature = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Radial")
local ChartFeature = require("FactoryControl.Client.Entities.Controller.Feature.Chart.Chart")

---@class FactoryControl.Client.Entities.Controller : FactoryControl.Client.Entities.Entity
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
---@overload fun(controllerDto: FactoryControl.Core.Entities.Controller.ControllerDto, client: FactoryControl.Client.Client) : FactoryControl.Client.Entities.Controller
local Controller = {}

---@private
---@param controllerDto FactoryControl.Core.Entities.Controller.ControllerDto
---@param client FactoryControl.Client.Client
---@param baseFunc fun(id: Core.UUID, client: FactoryControl.Client.Client)
function Controller:__init(baseFunc, controllerDto, client)
    baseFunc(controllerDto.Id, client)

    self.Name = controllerDto.Name
    self.IPAddress = controllerDto.IPAddress

    ---@type Dictionary<Core.UUID, FactoryControl.Client.Entities.Controller.Feature>
    local features = {}

    for id, feature in pairs(controllerDto.Features) do
        if feature.Type == "Button" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ButtonDto
            features[id] = ButtonFeature(feature, self)
        elseif feature.Type == "Switch" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.SwitchDto
            features[id] = SwitchFeature(feature, self)
        elseif feature.Type == "Radial" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.RadialDto
            features[id] = RadialFeature(feature, self)
        elseif feature.Type == "Chart" then
            ---@cast feature FactoryControl.Core.Entities.Controller.Feature.ChartDto
            features[id] = ChartFeature(feature, self)
        end
    end

    self.Features = features
end

return Utils.Class.CreateClass(Controller, "FactoryControl.Client.Entities.Controller",
    require("FactoryControl.Client.Entities.Entitiy"))
