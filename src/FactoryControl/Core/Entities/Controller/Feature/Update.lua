---@class FactoryControl.Core.Entities.Controller.Feature.Update : Core.Json.Serializable
---@field FeatureId Core.UUID
local Update = {}

---@alias FactoryControl.Core.Entities.Controller.Feature.Update.Constructor fun(featureId: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.Update

---@private
---@param featureId Core.UUID
function Update:__init(featureId)
    self.FeatureId = featureId
end

return Utils.Class.CreateClass(Update, "FactoryControl.Core.Entities.Controller.Feature.Update",
    require("Core.Json.Serializable"))
