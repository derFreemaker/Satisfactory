---@class FactoryControl.Core.Entities.Controller.Feature.RadialDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, min: number?, max: number?, setting: number?) : FactoryControl.Core.Entities.Controller.Feature.RadialDto
local RadialDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param min number
---@param max number
---@param setting number
---@param super FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function RadialDto:__init(super, id, name, controllerId, min, max, setting)
    super(id, name, "Radial", controllerId)

    self.Min = min or 0
    self.Max = max or 1

    -- //TODO: put some where else
    -- if self.Min > self.Max then
    --     error("min: " .. self.Min .. " cannot be bigger then max: " .. self.Max)
    --     return
    -- end

    -- if setting == nil then
    --     setting = self.Min
    -- else
    --     if self.Min > setting or self.Max < setting then
    --         error("setting: " .. setting .. " is out of range: " .. self.Min .. " - " .. self.Max)
    --         return
    --     end
    -- end

    self.Setting = setting
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Radial.Update
function RadialDto:OnUpdate(featureUpdate)
    self.Min = featureUpdate.Min
    self.Max = featureUpdate.Max
    self.Setting = featureUpdate.Setting
end

---@return Core.UUID id, string name, Core.UUID controllerId, number min, number max, number setting
function RadialDto:Serialize()
    return self.Id, self.Name, self.ControllerId, self.Min, self.Max, self.Setting
end

return class("FactoryControl.Core.Entities.Controller.Feature.RadialDto", RadialDto,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Dto") })
