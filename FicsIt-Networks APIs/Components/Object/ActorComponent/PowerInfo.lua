---@meta


--- A actor component that provides information and mainly statistics about the power connection it is attached to.
---@class FicsIt_Networks.Components.PowerInfo : FicsIt_Networks.Components.ActorComponent
---@field dynProduction float The production capacity this connection provided last tick.
---@field baseProduction float The base production capacity this connection always provides.
---@field maxDynProduction float The maximum production capacity this connection could have provided to the circuit in the last tick.
---@field targetConsumption float The amount of energy the connection wanted to consume from the circuit on the last tick.
---@field consumption float The amount of energy the connection actually consumed in the last tick.
---@field hasPower boolean True if the connection has satisfied power values and counts as beeing powered. (True if it has power)
local PowerInfo = {}


--- Returns the power circuit this info component is part of.
---@return FicsIt_Networks.Components.PowerCircuit circuit The Power Circuit this info component is attached to.
function PowerInfo:getCircuit() end