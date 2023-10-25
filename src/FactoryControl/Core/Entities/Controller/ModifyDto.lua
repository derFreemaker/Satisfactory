---@class FactoryControl.Core.Entities.Controller.ModifyDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(features: Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param features Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:__init(features)
    self.Features = features
end

---@return Dictionary<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:Serialize()
    return self.Features
end

return Utils.Class.CreateClass(ModifyDto, "FactoryControl.Core.Entities.Controller.ModifyDto",
    require("Core.Json.Serializable"))
