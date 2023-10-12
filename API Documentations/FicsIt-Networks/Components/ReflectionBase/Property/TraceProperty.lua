---@meta

--- A reflection object representing a trace property.
---@class FIN.Components.TraceProperty : FIN.Components.Property
local TraceProperty = {}

--- Returns the subclass type of this trace. Meaning, the stored traces need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Class subclass The subclass of this trace.
function TraceProperty:getSubclass()
end
