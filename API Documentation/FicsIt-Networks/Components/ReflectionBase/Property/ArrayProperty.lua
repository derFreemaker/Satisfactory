---@meta

--- A reflection object representing a array property
---@class FicsIt_Networks.Components.ArrayProperty : FicsIt_Networks.Components.Property
local ArrayProperty = {}

--- Returns the inner type of this array
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Property Inner The inner type of this array.
function ArrayProperty:getInner()
end
