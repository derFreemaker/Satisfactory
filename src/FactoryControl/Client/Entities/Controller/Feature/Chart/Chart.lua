---@class FactoryControl.Client.Entities.Controller.Feature.Chart : FactoryControl.Client.Entities.Controller.Feature
---@field private _XAxisName string
---@field private _YAxisName string
---@field private _Data Dictionary<number, any>
---@overload fun(chartDto: FactoryControl.Core.Entities.Controller.Feature.ChartDto, controller: FactoryControl.Client.Entities.Controller) : FactoryControl.Client.Entities.Controller.Feature.Chart
local Button = {}

---@private
---@param chartDto FactoryControl.Core.Entities.Controller.Feature.ChartDto
---@param controller FactoryControl.Client.Entities.Controller
---@param baseFunc fun(id: Core.UUID, name: string, type: FactoryControl.Core.Entities.Controller.Feature.Type, controller: FactoryControl.Client.Entities.Controller)
function Button:__init(baseFunc, chartDto, controller)
    baseFunc(chartDto.Id, chartDto.Name, "Button", controller)

    self._XAxisName = chartDto.XAxisName
    self._YAxisName = chartDto.YAxisName
    self._Data = chartDto.Data
end

-- //TODO: complete

return Utils.Class.CreateClass(Button, "FactoryControl.Client.Entities.Controller.Feature.Button",
    require("FactoryControl.Client.Entities.Controller.Feature.Feature") --[[@as FactoryControl.Client.Entities.Controller.Feature]])
