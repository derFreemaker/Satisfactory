---@class FactoryControl.Core.Entities.Controller.Feature.RadialDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, name: string, min: number?, max: number?, setting: number?) : FactoryControl.Core.Entities.Controller.Feature.RadialDto
local RadialFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param min number
---@param max number
---@param setting number
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function RadialFeatureDto:__init(baseFunc, id, name, min, max, setting)
    baseFunc(id, name, "Radial")

    self.Min = min or 0
    self.Max = max or 1

    if self.Min > self.Max then
        error("min: " .. self.Min .. " cannot be bigger then max: " .. self.Max)
        return
    end

    if setting == nil then
        setting = self.Min
    else
        if self.Min > setting or self.Max < setting then
            error("setting: " .. setting .. " is out of range: " .. self.Min .. " - " .. self.Max)
            return
        end
    end

    self.Setting = setting
end

---@return Core.UUID id, string name, number min, number max, number setting
function RadialFeatureDto:Serialize()
    return self.Id, self.Name, self.Min, self.Max, self.Setting
end

return Utils.Class.CreateClass(RadialFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.FeatureDto]])
