---@alias FactoryControl.Core.Entities.Controller.Feature.Type
---|"Switch"
---|"Button"
---|"Radial"
---|"Chart"

---@class FactoryControl.Core.Entities.Controller.Feature.FeatureDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
local FeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
function FeatureDto:__init(id, name, type)
    self.Id = id
    self.Name = name
    self.Type = type
end

return Utils.Class.CreateClass(FeatureDto, "FactoryControl.Core.Entities.Controller.FeatureDto",
    require("Core.Json.Serializable"))
