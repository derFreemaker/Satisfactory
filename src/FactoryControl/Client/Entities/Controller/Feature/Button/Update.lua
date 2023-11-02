---@class FactoryControl.Client.Entities.Controller.Feature.Button.Update : FactoryControl.Client.Entities.Controller.Feature.Update
---@overload fun(id: Core.UUID) : FactoryControl.Client.Entities.Controller.Feature.Button.Update
local Update = {}

---@private
---@param id Core.UUID
---@param super FactoryControl.Client.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, id)
    super(id)
end

---@return Core.UUID id
function Update:Serialize()
    return self.FeatureId
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Button.Update",
    require("Core.Json.Serializable"))
