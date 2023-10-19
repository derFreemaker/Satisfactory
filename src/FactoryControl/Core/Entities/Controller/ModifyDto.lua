---@class FactoryControl.Core.Entities.Controller.ModifyDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(id: Core.UUID, features: Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param id Core.UUID
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:__init(id, features)
    self.Id = id
    self.Features = features
end

---@return Core.UUID id, Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:Serialize()
    return self.Id, self.Features
end

return Utils.Class.CreateClass(ModifyDto, "FactoryControl.Core.Entities.Controller.ModifyDto",
    require("Core.Json.Serializable"))
