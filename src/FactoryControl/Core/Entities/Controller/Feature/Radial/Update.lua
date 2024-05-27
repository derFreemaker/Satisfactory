---@class FactoryControl.Core.Entities.Controller.Feature.Radial.Update : FactoryControl.Core.Entities.Controller.Feature.Update
---@field Min number
---@field Max number
---@field Setting number
---@overload fun(id: Core.UUID, min: number, max: number, setting: number) : FactoryControl.Core.Entities.Controller.Feature.Radial.Update
local Update = {}

---@private
---@param id Core.UUID
---@param min number
---@param max number
---@param setting number
---@param super FactoryControl.Core.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, id, min, max, setting)
    super(id)

    self.Min = min
    self.Max = max
    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function Update:Serialize()
    return self.FeatureId, self.Min, self.Max, self.Setting
end

return class("FactoryControl.Core.Entities.Controller.Feature.Radial.Update", Update,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Update") })
