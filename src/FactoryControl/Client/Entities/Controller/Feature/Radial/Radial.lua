local RadialDto = require("FactoryControl.Core.Entities.Controller.Feature.Radial.RadialDto")

local Update = require("FactoryControl.Core.Entities.Controller.Feature.Radial.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Data
---@field Min number?
---@field Max number?
---@field Setting number?

---@class FactoryControl.Client.Entities.Controller.Feature.Radial : FactoryControl.Client.Entities.Controller.Feature
---@field m_min number
---@field m_max number
---@field m_setting number
---@overload fun(radialDto: FactoryControl.Core.Entities.Controller.Feature.RadialDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Radial
local Radial = {}

---@private
---@param radialDto FactoryControl.Core.Entities.Controller.Feature.RadialDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Radial:__init(super, radialDto, client)
    super(radialDto, client)

    self.m_min = radialDto.Min
    self.m_max = radialDto.Max
    self.m_setting = radialDto.Setting

    if self.m_max < self.m_min then
        error("max cannot be smaller then min")
    end

    if self.m_setting < self.m_min or self.m_setting > self.m_max then
        error("setting is out of bounds of " .. self.m_min .. " - " .. self.m_max)
    end
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Radial.Update
function Radial:OnUpdate(update)
    self.m_min = update.Min
    self.m_max = update.Max
    self.m_setting = update.Setting
end

---@return FactoryControl.Core.Entities.Controller.Feature.RadialDto
function Radial:ToDto()
    return RadialDto(self.Id, self.Name, self.ControllerId, self.m_min, self.m_max, self.m_setting)
end

---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Modify
---@field Min number
---@field Max number
---@field Setting number

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Feature.Radial.Modify)
function Radial:Modify(func)
    ---@type FactoryControl.Client.Entities.Controller.Feature.Radial.Modify
    local modify = { Min = self.m_min, Max = self.m_max, Setting = self.m_setting }

    func(modify)

    if modify.Max < modify.Min then
        error("max cannot be smaller then min")
    end

    if modify.Setting < modify.Min or modify.Setting > modify.Max then
        error("setting is out of bounds of " .. self.m_min .. " - " .. self.m_max)
    end

    local update = Update(self.Id, self.m_min, self.m_max, self.m_setting)
    self.m_client:UpdateFeature(update)
end

return Utils.Class.CreateClass(Radial, "FactoryControl.Client.Entities.Controller.Feature.Radial",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature"))
