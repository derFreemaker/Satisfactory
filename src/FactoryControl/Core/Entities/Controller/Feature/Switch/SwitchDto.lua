---@class FactoryControl.Core.Entities.Controller.Feature.SwitchDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.SwitchDto
local SwitchDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param isEnabled boolean?
---@param super FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function SwitchDto:__init(super, id, name, controllerId, isEnabled)
    super(id, name, "Switch", controllerId)

    if isEnabled == nil then
        self.IsEnabled = false
        return
    end
    self.IsEnabled = isEnabled
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Switch.Update
function SwitchDto:OnUpdate(featureUpdate)
    self.IsEnabled = featureUpdate.IsEnabled
end

---@return Core.UUID id, string name, Core.UUID controllerId, boolean isEnabled
function SwitchDto:Serialize()
    return self.Id, self.Name, self.ControllerId, self.IsEnabled
end

return Utils.Class.CreateClass(SwitchDto, "FactoryControl.Core.Entities.Controller.Feature.SwitchDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto"))
