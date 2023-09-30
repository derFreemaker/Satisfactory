---@meta

--- A actor component base that is a connection point to which a pipe for fluid or hyper can get attached to.
---@class FicsIt_Networks.Components.PipeConnection : FicsIt_Networks.Components.ActorComponent
local PipeConnection = {}

--- True if something is connected to this connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
PipeConnection.isConnected = nil

--- Returns the amount of fluid this fluid container contains.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxConent = nil

--- Returns the height of this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxHeight = nil

--- Returns the laminar height of this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxLaminarHeight = nil

--- Returns the amount of fluid flowing through this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxFlowThrough = nil

--- Returns the fill rate of this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxFlowFill = nil

--- Returns the drain rate of this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxFlowDrain = nil

--- Returns the maximum flow limit of this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PipeConnection.fluidBoxFlowLimit = nil

--- Returns the network ID of the pipe network this connection is associated with.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
PipeConnection.networkID = nil

--- Returns the item type of the fluid in this fluid container.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return FicsIt_Networks.Components.ItemType fluidDescriptor The item type the fluid in this fluid container.
function PipeConnection:getFluidDescriptor()
end

--- Flush the associated pipe network.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
function PipeConnection:flushPipeNetwork()
end
