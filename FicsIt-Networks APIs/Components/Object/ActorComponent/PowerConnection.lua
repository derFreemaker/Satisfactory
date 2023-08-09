---@diagnostic disable


--- A actor component that allows for a connection point to the power network. Basically a point were a power cable can get attached to.
---@class FicsIt_Networks.Components.PowerConnection : FicsIt_Networks.Components.ActorComponent
---@field connections integer The amount of connections this power connection has.
---@field maxConnections integer The maximum amount of connections this power connection can handle.
local PowerConnection = {}


--- Returns the power info component of this power connection.
---@return FicsIt_Networks.Components.PowerInfo power The power info component this power connection uses.
function PowerConnection:getPower() end


--- Returns the power circuit to wich this connection component is attached to.
---@return FicsIt_Networks.Components.PowerCircuit circuit The Power Circuit this connection component is attached to.
function PowerConnection:getCircuit() end
