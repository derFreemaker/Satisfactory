local Update = require("FactoryControl.Client.Entities.Controller.Feature.Radial.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field Min number
---@field Max number
---@field Setting number
---@field private m_old_Min number
---@field private m_old_Max number
---@field private m_old_Setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Radial:__init(baseFunc, radialDto, controller)
    baseFunc(radialDto.Id, radialDto.Name, "Radial", controller)

    self.Min = radialDto.Min
    self.m_old_Min = radialDto.Min

    self.Max = radialDto.Max
    self.m_old_Max = radialDto.Max

    self.Setting = radialDto.Setting
    self.m_old_Setting = radialDto.Setting
end

function Radial:Update()
    if self.Min < self.Max then
        error("max cannot be smaller then min")
    end

    if self.Min > self.Setting or self.Setting > self.Max then
        error("setting is out of bounds of " .. self.Min .. " - " .. self.Max)
    end

    if self.m_old_Min == self.Min and self.m_old_Max == self.Max and self.m_old_Setting == self.Setting then
        return
    end

    local update = Update(self.Id, self.Min, self.Max, self.Setting)

    self.m_client:UpdateRadial(self.Owner.IPAddress, update)
end

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
