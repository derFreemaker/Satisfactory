---@class FactoryControl.Core.Entities.Controller.CreateDto : object, Core.Json.Serializable
---@field Name string
---@field IPAddress Net.IPAddress
---@field Features table<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(name: string, ipAddress: Net.IPAddress, features: table<string, FactoryControl.Core.Entities.Controller.FeatureDto>?) : FactoryControl.Core.Entities.Controller.CreateDto
local ControllerDto = {}

---@private
---@param name string
---@param ipAddress Net.IPAddress
---@param features table<string, FactoryControl.Core.Entities.Controller.FeatureDto>?
function ControllerDto:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return string name, Net.IPAddress ipAddress, table<string, FactoryControl.Core.Entities.Controller.FeatureDto> features
function ControllerDto:Serialize()
    return self.Name, self.IPAddress, self.Features
end

return class("FactoryControl.Core.Entities.Controller.CreateDto", ControllerDto,
    { Inherit = require("Core.Json.Serializable") })
