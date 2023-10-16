---@class FactoryControl.Core.Entities.Controller.Feature.SwitchDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.SwitchDto
local SwitchFeatureDto = {}

---@private
---@param id Core.UUID
---@param isEnabled boolean?
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function SwitchFeatureDto:__init(baseFunc, id, isEnabled)
    baseFunc(id, "Switch")

    if isEnabled == nil then
        self.IsEnabled = false
        return
    end
    self.IsEnabled = isEnabled
end

function SwitchFeatureDto:Serialize()
    return self.Id, self.IsEnabled
end

---@param id Core.UUID
---@param isEnabled boolean
---@return FactoryControl.Core.Entities.Controller.Feature.SwitchDto
function SwitchFeatureDto.Static__Deserialize(id, isEnabled)
    return SwitchFeatureDto(id, isEnabled)
end

return Utils.Class.CreateClass(SwitchFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto]])
