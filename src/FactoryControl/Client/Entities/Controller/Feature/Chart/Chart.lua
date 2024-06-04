local ChartDto = require("FactoryControl.Core.Entities.Controller.Feature.Chart.ChartDto")
local Update = require("FactoryControl.Core.Entities.Controller.Feature.Chart.Update")

---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Data
---@field XAxisName string | nil
---@field YAxisName string | nil
---@field Data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType | nil

---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private m_xAxisName string
---@field private m_yAxisName string
---@field private m_data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, client: FactoryControl.Client) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Chart = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param client FactoryControl.Client
---@param super FactoryControl.Client.Entities.Controller.Feature.Constructor
function Chart:__init(super, chartDto, client)
    super(chartDto, client)

    self.m_xAxisName = chartDto.XAxisName
    self.m_yAxisName = chartDto.YAxisName
    self.m_data = chartDto.Data
end

---@private
---@param update FactoryControl.Core.Entities.Controller.Feature.Chart.Update
function Chart:OnUpdate(update)
    for key, value in pairs(update.Data or {}) do
        self.m_data[key] = value
    end
end

---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto
function Chart:ToDto()
    return ChartDto(self.Id, self.Name, self.ControllerId, self.m_xAxisName, self.m_yAxisName, self.m_data)
end

---@return string x, string y
function Chart:GetAxisNames()
    return self.m_xAxisName, self.m_yAxisName
end

---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType
function Chart:GetData()
    return Utils.Table.Copy(self.m_data)
end

---@class FactoryControl.Client.Entities.Controller.Feature.Chart.Modify
---@field Data FactoryControl.Core.Entities.Controller.Feature.ChartDto.DataType

---@param func fun(modify: FactoryControl.Client.Entities.Controller.Feature.Chart.Modify)
function Chart:Modify(func)
    ---@type FactoryControl.Client.Entities.Controller.Feature.Chart.Modify
    local modify = { Data = {} }

    func(modify)

    local update = Update(self.Id, modify.Data)
    self.m_client:UpdateFeature(update)
end

return class("FactoryControl.Client.Entities.Controller.Feature.Chart", Chart,
    { Inherit = require("FactoryControl.Client.Entities.Controller.Feature.Feature") })
