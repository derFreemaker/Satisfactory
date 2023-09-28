---@meta

---@class FicsIt_Networks.Components.Factory.PipelinePump : FicsIt_Networks.Components.Factory.FGBuildablePipelineAttachment
---@field maxHeadlift float The Maximum amount of headlift this pump can provide.
---@field designedHeadlift float The amount of headlift this pump is designed for.
---@field indicatorHeadlift float The amount of headlift the indicator shows.
---@field indicatorHeadliftPct float The amount of headlift the indicator shows as percantage from max.
---@field userFlowLimit float The flow limit of this pump the user can specifiy. Use -1 for now user set limit. (in m^3/s)
---@field flowLimit float The overal flow limit of this pump. (in m^3/s)
---@field flowLimitPtc float The overal flow limit of this pump. (in percent)
---@field flow float The current flow amount. (in m^3/s)
---@field flowPct float The current flow amount. (in percent)
local PipelinePump = {}

-- //TODO: add flags to all fields
