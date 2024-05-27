---@class FactoryControl.Core.Entities.Controller.Feature.Update : object, Core.Json.ISerializable
---@field FeatureId Core.UUID
local Update = {}

---@alias FactoryControl.Core.Entities.Controller.Feature.Update.Constructor fun(featureId: Core.UUID) : FactoryControl.Core.Entities.Controller.Feature.Update

---@private
---@param featureId Core.UUID
function Update:__init(featureId)
    self.FeatureId = featureId
end

return class("FactoryControl.Core.Entities.Controller.Feature.Update", Update,
    { IsAbstract = true, Inherit = require("Core.Json.ISerializable") })
