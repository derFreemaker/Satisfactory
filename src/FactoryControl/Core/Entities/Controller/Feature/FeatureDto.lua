---@alias FactoryControl.Core.Entities.Controller.Feature.Type
---|"Switch"
---|"Button"
---|"Radial"
---|"Chart"

---@class FactoryControl.Core.Entities.Controller.Feature.FeatureDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@overload fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
local FeatureDto = {}

---@private
---@param id Core.UUID
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
function FeatureDto:__init(id, type)
    self.Id = id
    self.Type = type
end

return Utils.Class.CreateClass(FeatureDto, "FactoryControl.Core.Entities.Controller.FeatureDto",
    require("Core.Json.Serializable"))
