---@meta

--- A reflection object representing a class property.
---@class FIN.Components.ClassProperty : FIN.Components.Property
local ClassProperty = {}

--- Returns the subclass type of this class. Meaning the stored classes need to be of this type.
--- ### Flags:
--- * Runtime Synchronous - Can be called/changed in Game Tick
--- * Runtime Parallel - Can be called/changed in Satisfactory Factory Tick
---@return FIN.Components.Class subclass The subclass of this class property.
function ClassProperty:getSubclass()
end
