---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field XAxisName string
---@field YAxisName string
---@field Data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, xAxisName: string, yAxisName: string, data: FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartDto = {}

---@alias FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType table<number, number>

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param xAxisName string
---@param yAxisName string
---@param data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil
---@param super FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function ChartDto:__init(super, id, name, controllerId, xAxisName, yAxisName, data)
    super(id, name, "Chart", controllerId)

    self.XAxisName = xAxisName
    self.YAxisName = yAxisName
    self.Data = data or {}
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Chart.Update
function ChartDto:OnUpdate(featureUpdate)
    self.Data = featureUpdate.Data or {}
end

---@return Core.UUID id, string name, Core.UUID controllerId, string xAxisName, string yAxisName, FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType data
function ChartDto:Serialize()
    return self.Id, self.Name, self.ControllerId, self.XAxisName, self.YAxisName, self.Data
end

return class("FactoryControl.Core.Entities.Controller.Feature.ChartDto", ChartDto,
    { Inherit = require("FactoryControl.Core.Entities.Controller.Feature.Dto") })
