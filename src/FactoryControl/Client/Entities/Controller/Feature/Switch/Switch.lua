local Update = require("FactoryControl.Client.Entities.Controller.Feature.Switch.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Switch : FactoryControl.Client.Entities.Controller.Feature
---@field private m_isEnabled boolean
---@field private m_old_isEnabled boolean
---@overload fun(switchDto: FactoryControl.Core.Entities.Controller.Feature.SwitchDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Switch
local Switch = {}

---@private
---@param switchDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Switch:__init(baseFunc, switchDto, controller)
    baseFunc(switchDto.Id, switchDto.Name, "Button", controller)

    self.m_isEnabled = switchDto.IsEnabled
    self.m_old_isEnabled = switchDto.IsEnabled
end

---@private
function Switch:Update()
    if self.m_isEnabled == self.m_old_isEnabled then
        return
    end

    local update = Update(self.Id, self.m_isEnabled)

    self.m_client:UpdateSwitch(self.Owner.IPAddress, update)
end

---@return boolean isEnabled
function Switch:IsEnabled()
    return self.m_isEnabled
end

function Switch:Enable()
    self.m_isEnabled = true

    self:Update()
end

function Switch:Disable()
    self.m_isEnabled = false

    self:Update()
end

function Switch:Toggle()
    self.m_isEnabled = not self.m_isEnabled

    self:Update()
end

return Utils.Class.CreateClass(Switch, "FactoryControl.Client.Entities.Controller.Feature.Switch",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
