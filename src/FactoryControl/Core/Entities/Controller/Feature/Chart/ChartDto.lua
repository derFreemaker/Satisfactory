---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.FeatureDto
---@field XAxisName string
---@field YAxisName string
---@field Data table<number, any>
---@overload fun(id: Core.UUID, name: string, controllerId: Core.UUID, xAxisName: string, yAxisName: string, data: table<number, any>?) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartDto = {}

---@private
---@param id Core.UUID
---@param name string
---@param controllerId Core.UUID
---@param xAxisName string
---@param yAxisName string
---@param data table<number, any>?
---@param super FactoryControl.Core.Entities.Controller.FeatureDto.Constructor
function ChartDto:__init(super, id, name, controllerId, xAxisName, yAxisName, data)
    super(id, name, "Chart", controllerId)

    self.XAxisName = xAxisName
    self.YAxisName = yAxisName
    self.Data = data or {}
end

---@param featureUpdate FactoryControl.Core.Entities.Controller.Feature.Chart.Update
function ChartDto:OnUpdate(featureUpdate)
    self.Data = featureUpdate.Data
end

---@return Core.UUID id, string name, Core.UUID controllerId, string xAxisName, string yAxisName, table<number, any> data
function ChartDto:Serialize()
    return self.Id, self.Name, self.ControllerId, self.XAxisName, self.YAxisName, self.Data
end

return Utils.Class.CreateClass(ChartDto, "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto"))
