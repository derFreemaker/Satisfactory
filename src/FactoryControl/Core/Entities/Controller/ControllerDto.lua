---@class FactoryControl.Core.Entities.Controller.ControllerDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Name string
---@field IPAddress Net.Core.IPAddress
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@overload fun(id: Core.UUID, name: string, ipAddress: Net.Core.IPAddress, features: Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?) : FactoryControl.Core.Entities.Controller.ControllerDto
local ControllerDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>?
function ControllerDto:__init(id, name, ipAddress, features)
    self.Id = id
    self.Name = name
    self.IPAddress = ipAddress
    self.Features = features or {}
end

---@return string name, Core.UUID id, Net.Core.IPAddress ipAddress, Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto> features
function ControllerDto:Serialize()
    return self.Name, self.Id, self.IPAddress, self.Features
end

---@param id Core.UUID
---@param name string
---@param ipAddress Net.Core.IPAddress
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.Feature.FeatureDto>
---@return FactoryControl.Core.Entities.Controller.ControllerDto
function ControllerDto.Static__Deserialize(id, name, ipAddress, features)
    return ControllerDto(id, name, ipAddress, features)
end

return Utils.Class.CreateClass(ControllerDto, "FactoryControl.Core.Entities.Controller.ControllerDto",
    require("Core.Json.Serializable"))
