---@meta

--- Object that contains all information about a type.
---@class FicsIt_Networks.Components.Class : FicsIt_Networks.Components.Struct
local Class = {}

--- Returns all the signals of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Signal[] signals The signals this specific type implements (excluding signals from parent types).
function Class:getSignals()
end

--- Returns all the signals of this and its parent types.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Signal[] signals The signals this type and all it parents implements.
function Class:getAllSignals()
end
