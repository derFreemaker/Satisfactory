---@meta

--- A reflection object representing a class property.
---@class FicsIt_Networks.Components.ClassProperty : FicsIt_Networks.Components.Property
local ClassProperty = {}

--- Returns the subclass type of this class. Meaning the stored classes need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FicsIt_Networks.Components.Class subclass The subclass of this class property.
function ClassProperty:getSubclass()
end
