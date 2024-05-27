---@class FactoryControl.Core.Entities.Controller.Feature.Switch.Update : FactoryControl.Core.Entities.Controller.Feature.Update
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Core.Entities.Controller.Feature.Switch.Update
local Update = {}

---@private
---@param featureId Core.UUID
---@param IsEnabled boolean
---@param super FactoryControl.Core.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, featureId, IsEnabled)
    super(featureId)
    self.IsEnabled = IsEnabled
end

---@return Core.UUID id, boolean isEnabled
function Update:Serialize()
    return self.FeatureId, self.IsEnabled
end

return class("FactoryControl.Core.Entities.Controller.Feature.Switch.Update", Update,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Update") })
