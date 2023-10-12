---@meta

--- A reflection object representing a array property
---@class FIN.Components.ArrayProperty : FIN.Components.Property
local ArrayProperty = {}

--- Returns the inner type of this array
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Property Inner The inner type of this array.
function ArrayProperty:getInner()
end
