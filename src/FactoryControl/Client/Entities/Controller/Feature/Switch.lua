---@class FactoryControl.Client.Entities.Controller.Feature.Switch : FactoryControl.Client.Entities.Controller.Feature
---@field private _IsEnabled boolean
---@overload fun(switchDto: FactoryControl.Core.Entities.Controller.Feature.SwitchDto) : FactoryControl.Client.Entities.Controller.Feature.Switch
local Switch = {}

---@private
---@param switchDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function Switch:__init(baseFunc, switchDto)
    baseFunc(switchDto.Id, switchDto.Name, "Button")

    self._IsEnabled = switchDto.IsEnabled
end

---@return boolean isEnabled
function Switch:IsEnabled()
    return self._IsEnabled
end

-- //TODO: complete

return Utils.Class.CreateClass(Switch, "FactoryControl.Client.Entities.Controller.Feature.Switch",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
