---@meta


--- A actor component base that is a connection point to which a pipe for fluid or hyper can get attached to.
---@class FicsIt_Networks.Components.PipeConnectionBase : FicsIt_Networks.Components.ActorComponent
---@field isConnected boolean True if something is connected to this connection.
local PipeConnectionBase = {}


--- Returns the connected pipe connection component.
---@return FicsIt_Networks.Components.PipeConnectionBase connected The connected pipe connection component.
function PipeConnectionBase:getConnection() end