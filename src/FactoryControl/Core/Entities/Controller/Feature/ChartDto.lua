---@class FactoryControl.Core.Entities.Controller.Feature.ChartDto : FactoryControl.Core.Entities.Controller.Feature.FeatureDto
---@field Data Dictionary<number, any>
---@overload fun(id: Core.UUID, data: Dictionary<number, any>?) : FactoryControl.Core.Entities.Controller.Feature.ChartDto
local ChartFeatureDto = {}

---@private
---@param id Core.UUID
---@param data Dictionary<number, any>?
---@param baseFunc fun(id: Core.UUID, type: FactoryControl.Core.Entities.Controller.Feature.Type)
function ChartFeatureDto:__init(baseFunc, id, data)
    baseFunc(id, "Chart")

    self.Data = data or {}
end

---@return Core.UUID id, Dictionary<number, any> data
function ChartFeatureDto:Serialize()
    return self.Id, self.Data
end

---@param id Core.UUID
---@param data Dictionary<number, any>
---@return FactoryControl.Core.Entities.Controller.Feature.ChartDto
function ChartFeatureDto.Static__Deserialize(id, data)
    return ChartFeatureDto(id, data)
end

return Utils.Class.CreateClass(ChartFeatureDto, "FactoryControl.Core.Entities.Controller.Feature.ChartDto",
    require("FactoryControl.Core.Entities.Controller.Feature.FeatureDto") --[[@as FactoryControl.Core.Entities.Controller.Feature.FeatureDto]])
