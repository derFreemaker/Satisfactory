---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param baseFunc FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function ButtonDto:__init(baseFunc, id, name, controllerId)
    baseFunc(id, name, "Button", controllerId)
end

---@return Core.UUID id, string name
function ButtonDto:Serialize()
    return self.Id, self.Name
end

return Utils.Class.CreateClass(ButtonDto, "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.FeatureDto]])
