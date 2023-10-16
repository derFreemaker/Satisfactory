---@class FactoryControl.Core.Entities.Controller.Feature.RadialDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, min: number?, max: number?, setting: number?) : FactoryControl.Core.Entities.Controller.Feature.RadialDto
local RadialFeatureDto = {}

---@private
---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function RadialFeatureDto:__init(baseFunc, id, min, max, setting)
    baseFunc(id, "Radial")

    self.Min = min or 0
    self.Max = max or 1

    if setting == nil then
        setting = self.Min
    else
        if self.Min > setting or self.Max < setting then
            error("setting: " .. setting .. " is out of range: " .. self.Min .. " - " .. self.Max)
        end
    end

    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function RadialFeatureDto:Serialize()
    return self.Id, self.Min, self.Max, self.Setting
end

---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@return FactoryControl.Core.Entities.Controller.Feature.RadialDto
function RadialFeatureDto.Static__Deserialize(id, min, max, setting)
    return RadialFeatureDto(id, min, max, setting)
end

return Utils.Class.CreateClass(RadialFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.RadialDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto]])
