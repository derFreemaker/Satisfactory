---@meta

--- A actor component base that is a connection point to which a pipe for fluid or hyper can get attached to.
---@class Satisfactory.Components.PipeConnectionBase : Satisfactory.Components.ActorComponent
local PipeConnection = {}

--- True if something is connected to this connection.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
PipeConnection.isConnected = nil

--- Returns the connected pipe connection component.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.PipeConnectionBase connected The connected pipe connection component.
function PipeConnection:getConnection()
end
