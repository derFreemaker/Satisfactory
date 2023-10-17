---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field _XAxisName string
---@field _YAxisName string
---@field _Data Dictionary<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Button = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function Button:__init(baseFunc, chartDto)
    baseFunc(chartDto.Id, chartDto.Name, "Button")

    self._XAxisName = chartDto.XAxisName
    self._YAxisName = chartDto.YAxisName
    self._Data = chartDto.Data
end

-- //TODO: complete

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
