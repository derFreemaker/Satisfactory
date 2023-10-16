---@class FactoryControl.Core.Entities.Controller.Feature.ButtonDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@overload fun(id: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.ButtonDto
local ButtonFeatureDto = {}

---@private
---@param id Core.UUID
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ButtonFeatureDto:__init(baseFunc, id)
    baseFunc(id, "Button")
end

---@return Core.UUID
function ButtonFeatureDto:Serialize()
    return self.Id
end

---@param id Core.UUID
---@return FactoryControl.Core.Entities.Controller.Feature.ButtonDto
function ButtonFeatureDto.Static__Deserialize(id)
    return ButtonFeatureDto(id)
end

return Utils.Class.CreateClass(ButtonFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ButtonDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto]])
