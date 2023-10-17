---@class FactoryControl.Core.Entities.Controller.CreateDto : Core.Json.Serializable
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(name: string, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.CreateDto
local ControllerDto = {}

---@private
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(name, ipAddress, features)
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return string name, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.Name, self.IPAddress, self.Features
end

---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.CreateDto
function ControllerDto.Static__Deserialize(name, ipAddress, features)
    return ControllerDto(name, ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.CreateDto",
    require("Core.Json.Serializable"))
