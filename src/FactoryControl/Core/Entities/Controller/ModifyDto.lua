---@class FactoryControl.Core.Entities.Controller.ModifyDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Features table<string, FactoryControl.Core.Entities.Controller.FeatureDto>
---@overload fun(features: table<string, FactoryControl.Core.Entities.Controller.FeatureDto>) : FactoryControl.Core.Entities.Controller.ModifyDto
local ModifyDto = {}

---@private
---@param features table<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:__init(features)
    self.Features = features
end

---@return table<string, FactoryControl.Core.Entities.Controller.FeatureDto>
function ModifyDto:Serialize()
    return self.Features
end

return Utils.Class.CreateClass(ModifyDto, "FactoryControl.Core.Entities.Controller.ModifyDto",
    require("Core.Json.Serializable"))
