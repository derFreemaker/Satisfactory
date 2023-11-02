---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Update : FactoryControl.Client.Entities.Controller.Feature.Update
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, min: number, max: number, setting: number) : FactoryControl.Client.Entities.Controller.Feature.Radial.Update
local Update = {}

---@private
---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@param baseFunc FactoryControl.Client.Entities.Controller.Feature.Update.Constructor
function Update:__init(baseFunc, id, min, max, setting)
    baseFunc(id)

    self.Min = min
    self.Max = max
    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function Update:Serialize()
    return self.FeatureId, self.Min, self.Max, self.Setting
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Radial.Update",
    require("FactoryControl.Client.Entities.Controller.Feature.Update"))

-- //TODO: use feature update base class
