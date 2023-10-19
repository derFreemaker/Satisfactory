---@class FactoryControl.Client.Entities.Controller.Feature.

---@class FactoryControl.Client.Entities.Controller.Feature : FactoryControl.Client.Entities.Entity
---@field Name string
---@field Type FactoryControl.Core.Entities.Controller.Feature.Type
---@field Owner FactoryControl.Client.Entities.Controller
---@overload fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature
local Feature = {}

---@private
---@param id Core.UUID
---@param name string
---@param featureType FactoryControl.Core.Entities.Controller.Feature.Type
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, client: FactoryControl.Client)
function Feature:__init(baseFunc, id, name, featureType, controller)
    baseFunc(id, controller._Client)

    self.Name  = name
    self.Type  = featureType
    self.Owner = controller
end

return Utils.Class.CreateClass(Feature, "FactoryControl.Client.Entities.Controller.Feature",
    require("FactoryControl.Client.Entities.Entitiy"))
