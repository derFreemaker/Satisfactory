---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Update : FactoryControl.Client.Entities.Controller.Feature.Update
---@field Data table<number, any>
---@overload fun(id: Core.UUID, data: table<number, any>) : FactoryControl.Client.Entities.Controller.Feature.Chart.Update
local Update = {}

---@private
---@param id Core.UUID
---@param data table<number, any>
---@param super FactoryControl.Client.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, id, data)
    super(id)
    self.Data = data
end

---@return Core.UUID id, table<number, any> data
function Update:Serialize()
    return self.FeatureId, self.Data
end

return Utils.Class.CreateClass(Update, "FactoryControl.Client.Entities.Controller.Feature.Chart.Update",
    require("FactoryControl.Client.Entities.Controller.Feature.Update"))
