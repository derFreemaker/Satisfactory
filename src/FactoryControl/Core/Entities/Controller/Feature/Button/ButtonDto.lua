---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param super FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function ButtonDto:__init(super, id, name, controllerId)
    super(id, name, "Button", controllerId)
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Button.Update
function ButtonDto:OnUpdate(featureUpdate)
end

---@return Core.UUID id, string name, Core.UUID controllerId
function ButtonDto:Serialize()
    return self.Id, self.Name, self.ControllerId
end

return class("FactoryControl.Core.Entities.Controller.Feature.ButtonDto", ButtonDto,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Dto") })
