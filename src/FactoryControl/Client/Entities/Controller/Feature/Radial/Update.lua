---@class FactoryControl.Client.Entities.Controller.Feature.Radial.Update : Core.Json.Serializable
---@field Id Core.UUID
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
function Update:__init(id, min, max, setting)
    self.Id = id
    self.Min = min
    self.Max = max
    self.Setting = setting
end

---@return Core.UUID id, number min, number max, number setting
function Update:Serialize()
    return self.Id, self.Min, self.Max, self.Setting
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Radial.Update",
    require("Core.Json.Serializable"))
