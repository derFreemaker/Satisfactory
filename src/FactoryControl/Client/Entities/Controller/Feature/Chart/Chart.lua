local Task = require("Core.Task")

local ChartDto = require("FactoryControl.Core.Entities.Controller.Feature.ChartDto")

---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private m_xAxisName string
---@field private m_yAxisName string
---@field private m_data table<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Chart = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param client FactoryControl.Client
---@param baseFunc FactoryControl.Client.Entities.Controller.Feature.Constructor
function Chart:__init(baseFunc, chartDto, client)
    baseFunc(chartDto, client)

    self.m_xAxisName = chartDto.XAxisName
    self.m_yAxisName = chartDto.YAxisName
    self.m_data = chartDto.Data

    self.OnChanged:AddListener(Task(self.OnUpdate, self))
end

---@param update FactoryControl.Client.Entities.Controller.Feature.Chart.Update
function Chart:OnUpdate(update)
    for key, value in pairs(update.Data) do
        self.m_data[key] = value
    end
end

---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto
function Chart:ToDto()
    return ChartDto(self.Id, self.Name, self.ControllerId, self.m_xAxisName, self.m_yAxisName, self.m_data)
end

-- //TODO: complete

return Utils.Class.CreateClass(Chart, "FactoryControl.Client.Entities.Controller.Feature.Chart",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
