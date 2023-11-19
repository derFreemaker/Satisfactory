---@meta

--- A actor component that allows for a connection point to the power network. Basically a point were a power cable can get attached to.
---@class Satisfactory.Components.PowerConnection : Satisfactory.Components.ActorComponent
local PowerConnection = {}

--- The amount of connections this power connection has.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
PowerConnection.connections = nil

--- The maximum amount of connections this power connection can handle.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type integer
PowerConnection.maxConnections = nil

--- Returns the power info component of this power connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.PowerInfo power The power info component this power connection uses.
function PowerConnection:getPower()
end

--- Returns the power circuit to wich this connection component is attached to.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.PowerCircuit circuit The Power Circuit this connection component is attached to.
function PowerConnection:getCircuit()
end
