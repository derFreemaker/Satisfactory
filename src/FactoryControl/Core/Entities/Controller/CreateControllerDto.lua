---@class FactoryControl.Core.Entities.Controller.CreateDto : Core.Json.Serializable
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.CreateDto
local ControllerDto = {}

---@private
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(ipAddress, features)
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.IPAddress, self.Features
end

---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.CreateDto
function ControllerDto.Static__Deserialize(ipAddress, features)
    return ControllerDto(ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.CreateDto",
    require("Core.Json.Serializable"))
