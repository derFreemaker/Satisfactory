---@meta

--- A actor component that provides information and mainly statistics about the power connection it is attached to.
---@class Satisfactory.Components.PowerInfo : Satisfactory.Components.ActorComponent
local PowerInfo = {}

--- The production capacity this connection provided last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerInfo.dynProduction = nil

--- The base production capacity this connection always provides.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerInfo.baseProduction = nil

--- The maximum production capacity this connection could have provided to the circuit in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerInfo.maxDynProduction = nil

--- The amount of energy the connection wanted to consume from the circuit on the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerInfo.targetConsumption = nil

--- The amount of energy the connection actually consumed in the last tick.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type float
PowerInfo.consumption = nil

--- True if the connection has satisfied power values and counts as beeing powered. (True if it has power)
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
PowerInfo.hasPower = nil

--- Returns the power circuit this info component is part of.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick.
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick.
---@return Satisfactory.Components.PowerCircuit circuit The Power Circuit this info component is attached to.
function PowerInfo:getCircuit()
end
