---@meta

--- A reflection object representing a object property.
---@class FicsIt_Networks.Components.ObjectProperty : FicsIt_Networks.Components.Property
local ObjectProperty = {}

--- Returns the subclass type of this object. Meaning, the stroed objects to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Class subclass The subclass of this object.
function ObjectProperty:getSubclass()
end
