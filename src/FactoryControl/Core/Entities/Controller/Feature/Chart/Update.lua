---@class FactoryControl.Core.Entities.Controller.Feature.Chart.Update : FactoryControl.Core.Entities.Controller.Feature.Update
---@field Data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil
---@overload fun(id: Core.UUID, data: FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType) : FactoryControl.Core.Entities.Controller.Feature.Chart.Update
local Update = {}

---@private
---@param id Core.UUID
---@param data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil
---@param super FactoryControl.Core.Entities.Controller.Feature.Update.Constructor
function Update:__init(super, id, data)
    super(id)
    self.Data = data
end

---@return Core.UUID id, FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil data
function Update:Serialize()
    return self.FeatureId, self.Data
end

return class("FactoryControl.Core.Entities.Controller.Feature.Chart.Update", Update,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Update") })
