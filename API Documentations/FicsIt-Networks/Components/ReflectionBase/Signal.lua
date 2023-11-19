---@meta

--- A reflection object representing a signal.
---@class FIN.Components.Signal : FIN.Components.ReflectionBase
local Signal = {}

--- True if this signal has a variable amount of arguments.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
--- * Read Only - The value of this property can not be changed by code
---@type boolean
Signal.isVarArgs = nil

--- Returns all the parameters of this signal.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property[] parameters The parameters this signal.
function Signal:getParameters()
end
