---@meta

--- A reflection object representing a object property.
---@class FIN.Components.ObjectProperty : FIN.Components.Property
local ObjectProperty = {}

--- Returns the subclass type of this object. Meaning, the stroed objects to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Class subclass The subclass of this object.
function ObjectProperty:getSubclass()
end
