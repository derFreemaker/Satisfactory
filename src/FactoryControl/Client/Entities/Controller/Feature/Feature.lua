---@class FactoryControl.Client.Entities.Controller.Feature : object
---@field Id Core.UUID
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@private
---@param id Core.UUID
---@param name string
---@param type FactoryControl.Core.Entities.Controller.Feature.Type
function Feature:__init(id, name, type)
    self.Id = id
    self.Name = name
    self.Type = type
end

return Utils.Class.CreateClass(Feature, "FactoryControl.Client.Entities.Controller.Feature")
