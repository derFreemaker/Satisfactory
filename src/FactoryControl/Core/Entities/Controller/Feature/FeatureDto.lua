---@alias FactoryControl.Core.Entities.Controller.Feature.Type
---|"Switch"
---|"Button"
---|"Radial"
---|"Chart"

---@class FactoryControl.Core.Entities.Controller.FeatureDto : Core.Json.Serializable
---@field Id Core.UUID
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field ControllerId Core.UUID
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Core.Entities.Controller.FeatureDto
local FeatureDto = {}

---@alias FactoryControl.Core.Entities.Controller.FeatureDto.Constructor fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controllerId: Core.UUID)

---@private
---@param id Core.UUID
---@param name string
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
---@param controllerId Core.UUID
function FeatureDto:__init(id, name, type, controllerId)
    self.Id = id
    self.Name = name
    self.Type = type
    self.ControllerId = controllerId
end

-- No Seriliaze function because this class should only be used as base not for instances

return Utils.Class.CreateClass(FeatureDto, "FactoryControl.Core.Entities.Controller.FeatureDto",
    require("Core.Json.Serializable"))
