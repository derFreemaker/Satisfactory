---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field XAxisName string
---@field YAxisName string
---@field Data Dictionary<number, any>
---@overload fun(id: Core.UUID, name: string, xAxisName: string, yAxisName: string, data: Dictionary<number, any>?) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartFeatureDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param xAxisName string
---@param yAxisName string
---@param data Dictionary<number, any>?
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ChartFeatureDto:__init(baseFunc, id, name, xAxisName, yAxisName, data)
    baseFunc(id, name, "Chart")

    self.XAxisName = xAxisName
    self.YAxisName = yAxisName
    self.Data = data or {}
end

---@return Core.UUID id, string name, string xAxisName, string yAxisName, Dictionary<number, any> data
function ChartFeatureDto:Serialize()
    return self.Id, self.Name, self.XAxisName, self.YAxisName, self.Data
end

return Utils.Class.CreateClass(ChartFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.FeatureDto]])
