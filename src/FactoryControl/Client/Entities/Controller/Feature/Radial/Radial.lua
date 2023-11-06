local RadialDto = require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Radial.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field Min number
---@field Max number
---@field Setting number
---@field private m_old_Min number
---@field private m_old_Max number
---@field private m_old_Setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Radial:__init(super, radialDto, client)
    super(radialDto, client)

    self.Min = radialDto.Min
    self.m_old_Min = radialDto.Min

    self.Max = radialDto.Max
    self.m_old_Max = radialDto.Max

    self.Setting = radialDto.Setting
    self.m_old_Setting = radialDto.Setting
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Radial.Update
function Radial:OnUpdate(update)
    self.Min = update.Min
    self.m_old_Min = update.Min

    self.Max = update.Max
    self.m_old_Max = update.Max

    self.Setting = update.Setting
    self.m_old_Setting = update.Setting
end

---@return FactoryControl.Core.Entities.Controller.Feature.RadialDto
function Radial:ToDto()
    return RadialDto(self.Id, self.Name, self.ControllerId, self.Min, self.Max, self.Setting)
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
    self.m_client:UpdateFeature(update)
end

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
