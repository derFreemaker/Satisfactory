---@meta

---@class Satisfactory.Components.PipelinePump : Satisfactory.Components.FGBuildablePipelineAttachment
local PipelinePump = {}

--- The Maximum amount of headlift this pump can provide.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.maxHeadlift = nil

--- The amount of headlift this pump is designed for.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.designedHeadlift = nil

--- The amount of headlift the indicator shows.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.indicatorHeadlift = nil

--- The amount of headlift the indicator shows as percantage from max.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type any
PipelinePump.indicatorHeadliftPct = nil

--- The flow limit of this pump the user can specifiy. Use -1 for now user set limit. (in m^3/s)
--- ### Flags:
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@type any
PipelinePump.userFlowLimit = nil

--- The overal flow limit of this pump. (in m^3/s)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type any
PipelinePump.flowLimit = nil

--- The overal flow limit of this pump. (in percent)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.flowLimitPtc = nil

--- The current flow amount. (in m^3/s)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.flow = nil

--- The current flow amount. (in percent)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipelinePump.flowPct = nil
