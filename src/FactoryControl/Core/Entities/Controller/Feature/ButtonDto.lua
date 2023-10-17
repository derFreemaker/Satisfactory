---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@overload fun(id: Core.UUID, name: string) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ButtonFeatureDto:__init(baseFunc, id, name)
    baseFunc(id, name, "Button")
end

---@return Core.UUID id, string name
function ButtonFeatureDto:Serialize()
    return self.Id, self.Name
end

---@param id Core.UUID
---@param name string
---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function ButtonFeatureDto.Static__Deserialize(id, name)
    return ButtonFeatureDto(id, name)
end

return Utils.Class.CreateClass(ButtonFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto]])
