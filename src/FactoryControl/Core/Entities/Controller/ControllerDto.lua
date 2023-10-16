---@class FactoryControl.Core.Entities.Controller.ControllerDto : Core.Json.Serializable
---@field Id Core.UUID
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(id: Core.UUID, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.ControllerDto
local ControllerDto = {}

---@private
---@param id Core.UUID
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(id, ipAddress, features)
    self.Id = id
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return Core.UUID id, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.Id, self.IPAddress, self.Features
end

---@param id Core.UUID
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.ControllerDto
function ControllerDto.Static__Deserialize(id, ipAddress, features)
    return ControllerDto(id, ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.ControllerDto",
    require("Core.Json.Serializable"))
