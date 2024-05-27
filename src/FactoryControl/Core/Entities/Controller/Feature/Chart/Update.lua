---@class FactoryControl.Core.Entities.Controller.Feature.Chart.Update : FactoryControl.Core.Entities.Controller.Feature.Update
---@field Data table<number, any>
---@overload fun(id: Core.UUID, data: table<number, any>) : FactoryControl.Core.Entities.Controller.Feature.Chart.Update
local Update = {}

---@private
---@param id Core.UUID
---@param data table<number, any>
---@param super FactoryControl.Core.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, id, data)
    super(id)
    self.Data = data
end

---@return Core.UUID id, table<number, any> data
function Update:Serialize()
    return self.FeatureId, self.Data
end

return class("FactoryControl.Core.Entities.Controller.Feature.Chart.Update", Update,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Update") })
