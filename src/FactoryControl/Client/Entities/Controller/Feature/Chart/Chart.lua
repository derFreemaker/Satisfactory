---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private m_xAxisName string
---@field private m_yAxisName string
---@field private m_data table<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Chart = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Chart:__init(baseFunc, chartDto, controller)
    baseFunc(chartDto.Id, chartDto.Name, "Chart", controller)

    self.m_xAxisName = chartDto.XAxisName
    self.m_yAxisName = chartDto.YAxisName
    self.m_data = chartDto.Data
end

-- //TODO: complete

return Utils.Class.CreateClass(Chart, "FactoryControl.Client.Entities.Controller.Feature.Chart",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
