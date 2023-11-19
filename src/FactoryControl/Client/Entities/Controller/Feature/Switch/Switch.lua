local SwitchDto = require("FactoryControl.Core.Entities.Controller.Feature.Switch.SwitchDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Switch.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Switch : FactoryControl.Client.Entities.Controller.Feature
---@field private m_isEnabled boolean
---@field private m_old_isEnabled boolean
---@overload fun(switchDto: FactoryControl.Core.Entities.Controller.Feature.SwitchDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Switch
local Switch = {}

---@private
---@param switchDto FactoryControl.Core.Entities.Controller.Feature.SwitchDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Switch:__init(super, switchDto, client)
    super(switchDto, client)

    self.m_isEnabled = switchDto.IsEnabled
    self.m_old_isEnabled = switchDto.IsEnabled
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Switch.Update
function Switch:OnUpdate(update)
    self.m_isEnabled = update.IsEnabled
    self.m_old_isEnabled = update.IsEnabled
end

---@return FactoryControl.Core.Entities.Controller.Feature.SwitchDto
function Switch:ToDto()
    return SwitchDto(self.Id, self.Name, self.ControllerId, self.m_isEnabled)
end

---@private
function Switch:update()
    if self.m_isEnabled == self.m_old_isEnabled then
        return
    end

    local update = Update(self.Id, self.m_isEnabled)
    self.m_client:UpdateFeature(update)
end

---@return boolean isEnabled
function Switch:IsEnabled()
    return self.m_isEnabled
end

function Switch:Enable()
    self.m_isEnabled = true

    self:update()
end

function Switch:Disable()
    self.m_isEnabled = false

    self:update()
end

function Switch:Toggle()
    self.m_isEnabled = not self.m_isEnabled

    self:update()
end

return Utils.Class.CreateClass(Switch, "FactoryControl.Client.Entities.Controller.Feature.Switch",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
