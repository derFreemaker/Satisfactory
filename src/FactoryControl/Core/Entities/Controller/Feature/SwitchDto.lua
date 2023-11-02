---@class FactoryControl.Core.Entities.Controller.Feature.SwitchDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.SwitchDto
local SwitchFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param isEnabled boolean?
---@param baseFunc FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function SwitchFeatureDto:__init(baseFunc, id, name, controllerId, isEnabled)
    baseFunc(id, name, "Switch", controllerId)

    if isEnabled == nil then
        self.IsEnabled = false
        return
    end
    self.IsEnabled = isEnabled
end

---@return Core.UUID id, string name, boolean isEnabled
function SwitchFeatureDto:Serialize()
    return self.Id, self.Name, self.IsEnabled
end

return Utils.Class.CreateClass(SwitchFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.FeatureDto]])
