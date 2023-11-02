---@class FactoryControl.Client.Entities.Controller.Feature.Switch.Update : FactoryControl.Client.Entities.Controller.Feature.Update
---@field IsEnabled boolean
---@overload fun(id: Core.UUID, isEnabled: boolean) : FactoryControl.Client.Entities.Controller.Feature.Switch.Update
local Update = {}

---@private
---@param featureId Core.UUID
---@param IsEnabled boolean
---@param super FactoryControl.Client.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, featureId, IsEnabled)
    super(featureId)
    self.IsEnabled = IsEnabled
end

---@return Core.UUID id, boolean isEnabled
function Update:Serialize()
    return self.FeatureId, self.IsEnabled
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Switch.Update",
    require("FactoryControl.Client.Entities.Controller.Feature.Update"))
