---@class FactoryControl.Client.Entities.Controller.Feature.Switch.Update : Core.Json.Serializable
---@field Id Core.UUID
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Client.Entities.Controller.Feature.Switch.Update
local Update = {}

---@private
function Update:__init(id, IsEnabled)
    self.Id = id
    self.IsEnabled = IsEnabled
end

---@return Core.UUID id, boolean isEnabled
function Update:Serialize()
    return self.Id, self.IsEnabled
end

---@param id Core.UUID
---@param isEnabled boolean
---@return FactoryControl.Client.Entities.Controller.Feature.Switch.Update
function Update:Static__Deserialize(id, isEnabled)
    return Update(id, isEnabled)
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Switch.Update",
    require("Core.Json.Serializable"))
